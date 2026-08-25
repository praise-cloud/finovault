import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/state/onboarding.dart';
import '../l10n/app_localizations.dart';
import '../theme/tokens.dart';
import '../widgets/ui.dart';
import '../widgets/vault_mark.dart';
import 'auth/login_screen.dart';

/// Welcome entry screen — branded hero over a light-blue gradient.
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context)!;
    return Scaffold(
      body: Container(
        decoration: context.fvPageDecoration,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: FvSpacing.x6),
            child: Column(
              children: [
                const Spacer(flex: 2),
                const VaultMark(size: 88),
                const SizedBox(height: 20),
                Text(
                  'Finovault',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: FvColors.primary,
                  ),
                ),
                const SizedBox(height: FvSpacing.x3),
                Text(
                  s.appTagline,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17, color: context.fvTextSecondary, height: 1.5),
                ),
                const Spacer(flex: 3),
                FvButton(
                  label: s.getStarted,
                  onPressed: () => ref.read(onboardingProvider.notifier).start(),
                ),
                const SizedBox(height: FvSpacing.x3),
                TextButton(
                  onPressed: () => pushScreen(context, const LoginScreen()),
                  child: Text.rich(
                    TextSpan(
                      text: s.alreadyHaveAccount,
                      style: TextStyle(color: context.fvTextSecondary, fontSize: 13.5),
                      children: [
                        TextSpan(text: s.login, style: const TextStyle(color: FvColors.primary, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: FvSpacing.x5),
                Text(
                  s.securedEncrypted,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: context.fvTextSecondary),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
