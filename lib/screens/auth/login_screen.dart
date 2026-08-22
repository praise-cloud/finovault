import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/state/auth.dart';
import '../../theme/tokens.dart';
import '../../widgets/ui.dart';
import '../../widgets/vault_mark.dart';
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
    final ok = await ref.read(authProvider.notifier).login(_email.text, _password.text);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).popUntil((r) => r.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final error = auth.error;

    return Scaffold(
      body: Container(
        decoration: context.fvPageDecoration,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(FvSpacing.x6),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const VaultMark(size: 44),
                    const SizedBox(height: FvSpacing.x3),
                    Center(
                      child: Text('Welcome back',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.4,
                              color: context.fvText)),
                    ),
                    const SizedBox(height: 6),
                    Text('Log in to keep growing your wealth.',
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
                              child: Text(error,
                                  style: const TextStyle(fontSize: 13, color: FvColors.error)),
                            ),
                            const SizedBox(height: FvSpacing.x4),
                          ],
                          FvTextField(
                            label: 'Email',
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            hint: 'you@example.com',
                          ),
                          const SizedBox(height: FvSpacing.x4),
                          FvTextField(label: 'Password', controller: _password, obscure: true),
                          const SizedBox(height: FvSpacing.x5),
                          FvButton(
                            label: 'Log In',
                            onPressed: auth.busy ? null : _submit,
                            loading: auth.busy,
                          ),
                          const SizedBox(height: FvSpacing.x3),
                          TextButton(
                            onPressed: () => pushScreen(context, const SignupScreen()),
                            child: Text.rich(
                              TextSpan(
                                text: "Don't have an account? ",
                                style: TextStyle(color: context.fvTextSecondary, fontSize: 13),
                                children: const [
                                  TextSpan(text: 'Sign up', style: TextStyle(color: FvColors.primary, fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: FvSpacing.x5),
                    FvCard(
                      child: Row(
                        children: [
                          const Icon(Icons.bolt, size: 18, color: FvColors.primary),
                          const SizedBox(width: FvSpacing.x2),
                          Expanded(
                            child: Text(
                              'Demo account — demo@finovault.app / Vault123!',
                              style: TextStyle(fontSize: 12.5, color: context.fvTextSecondary),
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
