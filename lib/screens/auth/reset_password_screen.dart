import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/tokens.dart';
import '../../widgets/ui.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, required this.resetToken});

  final String resetToken;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;
  bool _done = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final s = AppLocalizations.of(context);
    final next = _password.text;
    if (next.length < 8) {
      setState(() => _error = s.passwordTooShort);
      return;
    }
    if (next != _confirm.text) {
      setState(() => _error = s.passwordsDontMatch);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(apiProvider).resetPassword(widget.resetToken, next);
      if (mounted) setState(() => _done = true);
    } catch (_) {
      if (mounted) setState(() => _error = s.resetFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final strength = FvFormat.passwordStrength(_password.text);
    const strengthLabels = ['Too weak', 'Weak', 'Fair', 'Good', 'Strong'];

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
                        s.resetPasswordTitle,
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
                      s.resetPasswordHint,
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
                          if (_done) ...[
                            Container(
                              padding: const EdgeInsets.all(FvSpacing.x3),
                              decoration: BoxDecoration(
                                color: FvColors.successBg,
                                borderRadius: BorderRadius.circular(
                                  FvRadius.input,
                                ),
                              ),
                              child: Text(
                                s.resetSuccess,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: context.fvSuccess,
                                ),
                              ),
                            ),
                            const SizedBox(height: FvSpacing.x4),
                            FvButton(
                              label: s.loginCta,
                              onPressed: () => Navigator.of(context)
                                  .pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (_) => const FvLightTheme(
                                        child: LoginScreen(),
                                      ),
                                    ),
                                    (r) => r.isFirst,
                                  ),
                            ),
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
                              label: s.newPassword,
                              controller: _password,
                              obscure: true,
                            ),
                            if (_password.text.isNotEmpty) ...[
                              const SizedBox(height: FvSpacing.x2),
                              Row(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(2),
                                      child: LinearProgressIndicator(
                                        value: strength / 4,
                                        minHeight: 4,
                                        backgroundColor: context.fvBorder,
                                        color: strength >= 3
                                            ? context.fvSuccess
                                            : (strength == 2
                                                  ? context.fvWarning
                                                  : context.fvError),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: FvSpacing.x2),
                                  Text(
                                    strengthLabels[strength],
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: context.fvTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: FvSpacing.x4),
                            FvTextField(
                              label: s.confirmNewPassword,
                              controller: _confirm,
                              obscure: true,
                            ),
                            const SizedBox(height: FvSpacing.x5),
                            FvButton(
                              label: s.resetPasswordCta,
                              loading: _busy,
                              onPressed: _busy ? null : _submit,
                            ),
                          ],
                        ],
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
