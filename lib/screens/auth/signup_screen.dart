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
  static final _mauritiusPhonePattern = RegExp(r'^(\+?230)?[5-7]\d{4,7}$');
  static final _nigerianPhonePattern = RegExp(r'^(\+?234|0)?[789][01]\d{8}$');
  String _country = 'MU';
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  String? _localError;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _localError = null);
    if (_name.text.trim().isEmpty ||
        _email.text.trim().isEmpty ||
        _phone.text.trim().isEmpty ||
        _password.text.isEmpty) {
      setState(() => _localError = 'Please fill in every field.');
      return;
    }
    final phoneClean = _phone.text.trim();
    if (_country == 'NG') {
      if (!_nigerianPhonePattern.hasMatch(phoneClean)) {
        setState(
          () => _localError =
              'Please enter a valid Nigerian mobile number (e.g. 08012345678).',
        );
        return;
      }
    } else {
      if (!_mauritiusPhonePattern.hasMatch(phoneClean)) {
        setState(
          () => _localError = 'Phone must be 5–8 digits starting with 5–7.',
        );
        return;
      }
    }
    final ok = await ref
        .read(authProvider.notifier)
        .signup(
          _name.text,
          _email.text,
          _password.text,
          phoneClean,
          country: _country,
        );
    if (!mounted) return;
    if (ok) Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final error = auth.error ?? _localError;
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
                        'Create your account',
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                          color: context.fvText,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Step 1 of your journey — next you will pick how you use Finovault.',
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Country',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: context.fvText,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () => setState(() {
                                        _country = 'MU';
                                        _localError = null;
                                      }),
                                      borderRadius: BorderRadius.circular(
                                        FvRadius.input,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _country == 'MU'
                                              ? context.fvWash
                                              : context.fvSurface,
                                          border: Border.all(
                                            color: _country == 'MU'
                                                ? context.fvPrimary
                                                : context.fvBorder,
                                            width: _country == 'MU' ? 2 : 1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            FvRadius.input,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text(
                                              '🇲🇺',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            const SizedBox(width: 6),
                                            Flexible(
                                              child: Text(
                                                'Mauritius',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: _country == 'MU'
                                                      ? FontWeight.w700
                                                      : FontWeight.w500,
                                                  color: context.fvText,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () => setState(() {
                                        _country = 'NG';
                                        _localError = null;
                                      }),
                                      borderRadius: BorderRadius.circular(
                                        FvRadius.input,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _country == 'NG'
                                              ? context.fvWash
                                              : context.fvSurface,
                                          border: Border.all(
                                            color: _country == 'NG'
                                                ? context.fvPrimary
                                                : context.fvBorder,
                                            width: _country == 'NG' ? 2 : 1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            FvRadius.input,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text(
                                              '🇳🇬',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            const SizedBox(width: 6),
                                            Flexible(
                                              child: Text(
                                                'Nigeria',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: _country == 'NG'
                                                      ? FontWeight.w700
                                                      : FontWeight.w500,
                                                  color: context.fvText,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: FvSpacing.x4),
                          FvTextField(
                            label: 'Full name',
                            controller: _name,
                            hint: 'Amina Diallo',
                          ),
                          const SizedBox(height: FvSpacing.x4),
                          FvTextField(
                            label: 'Email',
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            hint: 'you@example.com',
                          ),
                          const SizedBox(height: FvSpacing.x4),
                          FvTextField(
                            label: 'Mobile number',
                            controller: _phone,
                            keyboardType: TextInputType.phone,
                            hint: _country == 'NG'
                                ? '080xxxxxxxx · Nigerian mobile'
                                : '5xxxxxxx · Mauritius mobile',
                          ),
                          const SizedBox(height: FvSpacing.x4),
                          FvTextField(
                            label: 'Password',
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
                          const SizedBox(height: FvSpacing.x5),
                          FvButton(
                            label: 'Sign Up',
                            onPressed: auth.busy ? null : _submit,
                            loading: auth.busy,
                          ),
                          const SizedBox(height: FvSpacing.x3),
                          TextButton(
                            onPressed: () => Navigator.of(context)
                                .pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (_) => const FvLightTheme(
                                      child: LoginScreen(),
                                    ),
                                  ),
                                  (r) => r.isFirst,
                                ),
                            child: Text.rich(
                              TextSpan(
                                text: 'Already have an account? ',
                                style: TextStyle(
                                  color: context.fvTextSecondary,
                                  fontSize: 13,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Log in',
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
                    Text(
                      'Finovault provides financial coaching and budgeting '
                      'insights — not regulated investment advice or asset '
                      'portfolio management.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11.5,
                        height: 1.5,
                        color: context.fvTextSecondary,
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
