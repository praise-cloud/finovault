import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/mock/api.dart';
import '../../core/models.dart';
import '../../core/providers.dart';
import '../../core/state/auth.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/tokens.dart';
import '../../widgets/ui.dart';

enum OtpMode { setup, loginVerify, disable }

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({
    super.key,
    required this.mode,
    this.challengeId,
    this.mfaMethods,
    this.setupData,
    this.onCompleted,
  });

  final OtpMode mode;
  final String? challengeId;
  final List<String>? mfaMethods;
  final TwoFactorSetup? setupData;
  final VoidCallback? onCompleted;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _codeController = TextEditingController();
  bool _busy = false;
  String? _error;
  bool _showBackupCodes = false;
  bool _setupComplete = false;
  Timer? _resendTimer;
  int _resendSeconds = 0;
  String _selectedMethod = 'totp';

  @override
  void initState() {
    super.initState();
    if (widget.mfaMethods != null && widget.mfaMethods!.contains('email')) {
      _selectedMethod = 'email';
    }
    _startResendTimer();
  }

  void _startResendTimer() {
    _resendSeconds = 30;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _resendSeconds--;
        if (_resendSeconds <= 0) t.cancel();
      });
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final s = AppLocalizations.of(context);
    final code = _codeController.text.trim();
    if (code.length < 6) {
      setState(() => _error = s.twoFactorCodeRequired);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final api = ref.read(apiProvider);

      switch (widget.mode) {
        case OtpMode.setup:
          final token = ref.read(kvStoreProvider).getString(sessionKey);
          await api.verifyTwoFactorSetup(token, code);
          if (!mounted) return;
          setState(() {
            _setupComplete = true;
            _busy = false;
          });
          return;

        case OtpMode.loginVerify:
          final result = await api.verifyTwoFactorChallenge(
            widget.challengeId!,
            code,
          );
          await ref.read(kvStoreProvider).setString(sessionKey, result.token);
          ref.read(authProvider.notifier).setUser(result.user);
          if (!mounted) return;
          widget.onCompleted?.call();
          Navigator.of(context).popUntil((r) => r.isFirst);
          return;

        case OtpMode.disable:
          final token = ref.read(kvStoreProvider).getString(sessionKey);
          await api.disableTwoFactor(token, code);
          if (!mounted) return;
          widget.onCompleted?.call();
          Navigator.of(context).pop();
          return;
      }
    } on FvApiException catch (e) {
      if (mounted)
        setState(() {
          _error = e.message;
          _busy = false;
        });
    }
  }

  Future<void> _resend() async {
    if (_resendSeconds > 0) return;
    try {
      final api = ref.read(apiProvider);
      final token = ref.read(kvStoreProvider).getString(sessionKey);
      await api.resendOtp(
        token,
        challengeId: widget.challengeId ?? '',
        method: _selectedMethod,
      );
      if (mounted) _startResendTimer();
    } on FvApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_setupComplete) return _buildSuccess();
    if (_showBackupCodes && widget.setupData != null)
      return _buildBackupCodes();
    return widget.mode == OtpMode.setup ? _buildSetup() : _buildVerify();
  }

  Widget _buildSetup() {
    final setup = widget.setupData;
    final setupSecret = setup?.secret;
    final s = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.twoFactorSetupTitle),
        backgroundColor: context.fvSurface,
        elevation: 0,
        iconTheme: IconThemeData(color: context.fvPrimary),
      ),
      body: ListView(
        padding: const EdgeInsets.all(FvSpacing.x5),
        children: [
          Text(
            s.twoFactorScanInstruction,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: FvSpacing.x5),
          Center(
            child: QrImageView(
              data: setup?.qrUrl ?? '',
              version: QrVersions.auto,
              size: 220,
              backgroundColor:
                  Colors.white, // ponytail: QR codes need light bg to scan
            ),
          ),
          const SizedBox(height: FvSpacing.x5),
          if (setupSecret != null) ...[
            Text(
              s.twoFactorManualKey,
              style: TextStyle(fontSize: 13, color: context.fvTextSecondary),
            ),
            const SizedBox(height: FvSpacing.x2),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: setupSecret));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(s.twoFactorSecretCopied)),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(FvSpacing.x3),
                decoration: BoxDecoration(
                  color: context.fvWash,
                  borderRadius: BorderRadius.circular(FvRadius.input),
                ),
                child: Text(
                  setupSecret,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: FvSpacing.x5),
          FvTextField(
            label: s.twoFactorEnterCode,
            controller: _codeController,
            keyboardType: TextInputType.number,
            onChanged: (_) {
              if (_codeController.text.length > 6) {
                _codeController.text = _codeController.text.substring(0, 6);
                _codeController.selection = TextSelection.collapsed(
                  offset: _codeController.text.length,
                );
              }
            },
          ),
          if (_error != null) ...[
            const SizedBox(height: FvSpacing.x3),
            Text(
              _error!,
              style: TextStyle(color: context.fvError, fontSize: 13),
            ),
          ],
          const SizedBox(height: FvSpacing.x4),
          FvButton(
            label: s.twoFactorVerifyEnable,
            onPressed: _busy ? null : _submit,
            loading: _busy,
          ),
          const SizedBox(height: FvSpacing.x3),
          TextButton(
            onPressed: () => setState(() => _showBackupCodes = true),
            child: Text(
              s.twoFactorViewBackup,
              style: TextStyle(color: context.fvPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerify() {
    final s = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.twoFactorVerifyTitle),
        backgroundColor: context.fvSurface,
        elevation: 0,
        iconTheme: IconThemeData(color: context.fvPrimary),
      ),
      body: ListView(
        padding: const EdgeInsets.all(FvSpacing.x5),
        children: [
          Text(
            s.twoFactorEnter6Digit,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: FvSpacing.x5),
          if (widget.mfaMethods != null &&
              widget.mfaMethods!.contains('email')) ...[
            SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'totp',
                  label: Text(s.twoFactorAuthenticator),
                ),
                ButtonSegment(value: 'email', label: Text(s.twoFactorEmail)),
              ],
              selected: {_selectedMethod},
              onSelectionChanged: (s) =>
                  setState(() => _selectedMethod = s.first),
            ),
            const SizedBox(height: FvSpacing.x4),
          ],
          FvTextField(
            label: s.twoFactorCodeLabel,
            controller: _codeController,
            keyboardType: TextInputType.number,
            onChanged: (_) {
              if (_codeController.text.length > 6) {
                _codeController.text = _codeController.text.substring(0, 6);
                _codeController.selection = TextSelection.collapsed(
                  offset: _codeController.text.length,
                );
              }
            },
          ),
          if (_error != null) ...[
            const SizedBox(height: FvSpacing.x3),
            Text(
              _error!,
              style: TextStyle(color: context.fvError, fontSize: 13),
            ),
          ],
          const SizedBox(height: FvSpacing.x4),
          FvButton(
            label: s.twoFactorVerify,
            onPressed: _busy ? null : _submit,
            loading: _busy,
          ),
          const SizedBox(height: FvSpacing.x3),
          TextButton(
            onPressed: _resendSeconds > 0 ? null : _resend,
            child: Text(
              _resendSeconds > 0
                  ? s.twoFactorResendIn(_resendSeconds)
                  : s.twoFactorResend,
              style: TextStyle(
                color: _resendSeconds > 0
                    ? context.fvTextSecondary
                    : context.fvPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackupCodes() {
    final codes = widget.setupData?.backupCodes ?? [];
    final s = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.twoFactorBackupTitle),
        backgroundColor: context.fvSurface,
        elevation: 0,
        iconTheme: IconThemeData(color: context.fvPrimary),
      ),
      body: ListView(
        padding: const EdgeInsets.all(FvSpacing.x5),
        children: [
          Text(
            s.twoFactorBackupInstruction,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: FvSpacing.x5),
          Container(
            padding: const EdgeInsets.all(FvSpacing.x4),
            decoration: BoxDecoration(
              color: context.fvWash,
              borderRadius: BorderRadius.circular(FvRadius.input),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final code in codes)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      code,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 15,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: FvSpacing.x5),
          FvButton(
            label: s.twoFactorSavedCodes,
            onPressed: () {
              setState(() {
                _showBackupCodes = false;
                _codeController.clear();
                _error = null;
              });
            },
          ),
          const SizedBox(height: FvSpacing.x3),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              s.twoFactorCancelSetup,
              style: TextStyle(color: context.fvError),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    final s = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(FvSpacing.x6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: FvColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 40),
              ),
              const SizedBox(height: FvSpacing.x5),
              Text(
                s.twoFactorEnabledTitle,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: FvSpacing.x3),
              Text(
                s.twoFactorEnabledBody,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: FvSpacing.x6),
              FvButton(
                label: s.twoFactorDone,
                onPressed: () {
                  widget.onCompleted?.call();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
