import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/state/auth.dart';
import '../../theme/tokens.dart';
import '../../widgets/ui.dart';
import 'login_screen.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty || _email.text.trim().isEmpty || _password.text.isEmpty) return;
    final ok = await ref
        .read(authProvider.notifier)
        .signup(_name.text, _email.text, _password.text);
    if (!mounted) return;
    if (ok) Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final error = auth.error;
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
                    OnboardingHeader(onBack: () => Navigator.of(context).maybePop()),
                    const SizedBox(height: FvSpacing.x3),
                    Center(
                      child: Text('Create your account',
                          style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                              color: context.fvText)),
                    ),
                    const SizedBox(height: 6),
                    Text('Step 1 of your journey — next you will pick how you use Finovault.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, height: 1.5, color: context.fvTextSecondary)),
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
                                borderRadius: BorderRadius.circular(FvRadius.input),
                              ),
                              child:
                                  Text(error, style: const TextStyle(fontSize: 13, color: FvColors.error)),
                            ),
                            const SizedBox(height: FvSpacing.x4),
                          ],
                          FvTextField(label: 'Full name', controller: _name, hint: 'Amina Diallo'),
                          const SizedBox(height: FvSpacing.x4),
                          FvTextField(
                            label: 'Email',
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            hint: 'you@example.com',
                          ),
                          const SizedBox(height: FvSpacing.x4),
                          FvTextField(label: 'Password', controller: _password, obscure: true),
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
                                      color: strength >= 3 ? FvColors.success : (strength == 2 ? FvColors.warning : FvColors.error),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: FvSpacing.x2),
                                Text(strengthLabels[strength],
                                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: context.fvTextSecondary)),
                              ],
                            ),
                          ],
                          const SizedBox(height: FvSpacing.x5),
                          FvButton(
                            label: 'Sign Up',
                            onPressed: auth.busy ? null : _submit,
                            loading: auth.busy,
                          ),
                          const SizedBox(height: FvSpacing.x3),
                          TextButton(
                            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                              (r) => r.isFirst,
                            ),
                            child: Text.rich(
                              TextSpan(
                                text: 'Already have an account? ',
                                style: TextStyle(color: context.fvTextSecondary, fontSize: 13),
                                children: const [
                                  TextSpan(text: 'Log in', style: TextStyle(color: FvColors.primary, fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                          ),
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
