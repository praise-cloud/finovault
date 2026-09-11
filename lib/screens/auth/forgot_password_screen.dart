import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/tokens.dart';
import '../../widgets/ui.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _email = TextEditingController();
  bool _busy = false;
  bool _sent = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final s = AppLocalizations.of(context);
    final email = _email.text.trim();
    if (email.isEmpty) {
      setState(() => _error = s.emailRequired);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final api = ref.read(apiProvider);
    try {
      await api.requestPasswordReset(email);
      if (mounted) setState(() => _sent = true);
    } catch (_) {
      if (mounted) setState(() => _error = s.connectionFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);

    return Scaffold(
      body: Container(
        decoration: context.fvOnboardingDecoration,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(FvSpacing.x6),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    OnboardingHeader(
                      onBack: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(height: FvSpacing.x3),
                    Center(
                      child: Text(
                        s.forgotPassword,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                          color: context.fvText,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      s.forgotPasswordBody,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: context.fvTextSecondary,
                      ),
                    ),
                    const SizedBox(height: FvSpacing.x6),
                    FvCard(
                      padding: const EdgeInsets.all(FvSpacing.x5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_sent) ...[
                            Container(
                              padding: const EdgeInsets.all(FvSpacing.x3),
                              decoration: BoxDecoration(
                                color: FvColors.successBg,
                                borderRadius: BorderRadius.circular(
                                  FvRadius.input,
                                ),
                              ),
                              child: Text(
                                s.resetLinkSentBody(_email.text.trim()),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: context.fvSuccess,
                                ),
                              ),
                            ),
                            const SizedBox(height: FvSpacing.x4),
                          ] else ...[
                            if (_error != null) ...[
                              Container(
                                padding: const EdgeInsets.all(FvSpacing.x3),
                                decoration: BoxDecoration(
                                  color: FvColors.errorBg,
                                  borderRadius: BorderRadius.circular(
                                    FvRadius.input,
                                  ),
                                ),
                                child: Text(
                                  _error!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: context.fvError,
                                  ),
                                ),
                              ),
                              const SizedBox(height: FvSpacing.x4),
                            ],
                            FvTextField(
                              label: s.email,
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              hint: s.emailHint,
                            ),
                            const SizedBox(height: FvSpacing.x5),
                            FvButton(
                              label: s.sendResetLink,
                              loading: _busy,
                              onPressed: _busy ? null : _submit,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: FvSpacing.x4),
                    TextButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      child: Text(
                        'Log in',
                        style: TextStyle(
                          color: context.fvPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
