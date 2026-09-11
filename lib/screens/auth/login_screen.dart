import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/state/auth.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/tokens.dart';
import '../../widgets/ui.dart';
import 'forgot_password_screen.dart';
import 'otp_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final ok = await ref
        .read(authProvider.notifier)
        .login(_email.text, _password.text);
    if (!mounted) return;
    final auth = ref.read(authProvider);
    if (auth.isMfaPending) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => OtpScreen(
            mode: OtpMode.loginVerify,
            challengeId: auth.mfaChallengeId,
            mfaMethods: auth.mfaMethods,
          ),
        ),
      );
      return;
    }
    if (ok) {
      Navigator.of(context).popUntil((r) => r.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final error = auth.error;
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
                        s.welcomeBack,
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
                      s.loginSubtitle,
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
                          if (error != null) ...[
                            Container(
                              padding: const EdgeInsets.all(FvSpacing.x3),
                              decoration: BoxDecoration(
                                color: FvColors.errorBg,
                                borderRadius: BorderRadius.circular(
                                  FvRadius.input,
                                ),
                              ),
                              child: Text(
                                error,
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
                          const SizedBox(height: FvSpacing.x4),
                          FvTextField(
                            label: s.password,
                            controller: _password,
                            obscure: true,
                          ),
                          const SizedBox(height: FvSpacing.x1),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => pushScreen(
                                context,
                                const FvLightTheme(
                                  child: ForgotPasswordScreen(),
                                ),
                              ),
                              child: Text(
                                s.forgotPassword,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: context.fvPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: FvSpacing.x3),
                          FvButton(
                            label: s.loginCta,
                            onPressed: auth.busy ? null : _submit,
                            loading: auth.busy,
                          ),
                          const SizedBox(height: FvSpacing.x3),
                          TextButton(
                            onPressed: () => pushScreen(
                              context,
                              const FvLightTheme(child: SignupScreen()),
                            ),
                            child: Text.rich(
                              TextSpan(
                                text: s.signUpPrompt,
                                style: TextStyle(
                                  color: context.fvTextSecondary,
                                  fontSize: 13,
                                ),
                                children: [
                                  TextSpan(
                                    text: s.signUp,
                                    style: TextStyle(
                                      color: context.fvPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: FvSpacing.x4),
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
