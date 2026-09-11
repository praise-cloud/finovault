import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'l10n/app_localizations.dart';
import 'theme/app_theme.dart';

import 'core/providers.dart';
import 'core/state/auth.dart';
import 'core/state/onboarding.dart';
import 'core/state/notifications.dart';
import 'core/state/preferences.dart';
import 'core/mock/db.dart';
import 'core/state/biometric.dart';
import 'screens/home_shell.dart';
import 'screens/onboarding/business_details_screen.dart';
import 'screens/onboarding/goals_screen.dart';
import 'screens/onboarding/link_accounts_screen.dart';
import 'screens/role_screen.dart';
import 'screens/welcome_screen.dart';
import 'theme/tokens.dart';
import 'widgets/ui.dart';
import 'widgets/vault_mark.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final store = SharedPrefsStore(prefs);
  final db = MockDb(store: store);
  await db.hydrate();

  runApp(
    ProviderScope(
      overrides: [
        kvStoreProvider.overrideWithValue(store),
        mockDbProvider.overrideWithValue(db),
        initialPreferencesProvider.overrideWithValue(
          loadInitialPreferences(store),
        ),
        initialOnboardingProvider.overrideWithValue(
          loadInitialOnboarding(store),
        ),
      ],
      child: const FinovaultApp(),
    ),
  );
}

class SharedPrefsStore extends KvStore {
  SharedPrefsStore(this._prefs);
  final SharedPreferences _prefs;

  @override
  String? getString(String key) => _prefs.getString(key);
  @override
  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);
  @override
  Future<void> remove(String key) => _prefs.remove(key);
}

class FinovaultApp extends ConsumerStatefulWidget {
  const FinovaultApp({super.key});

  @override
  ConsumerState<FinovaultApp> createState() => _FinovaultAppState();
}

class _FinovaultAppState extends ConsumerState<FinovaultApp> {
  @override
  void initState() {
    super.initState();
    ref.read(notificationServiceProvider).initialize();
    Future.microtask(() => ref.read(authProvider.notifier).restore());
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(preferencesProvider);
    return MaterialApp(
      title: 'Finovault',
      debugShowCheckedModeBanner: false,
      locale: Locale(prefs.language),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: FvTheme.light(),
      darkTheme: FvTheme.dark(),
      themeMode: flutterThemeMode(prefs.themeMode),
      home: const RootGate(),
    );
  }
}

class RootGate extends ConsumerWidget {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final onboarding = ref.watch(onboardingProvider);

    if (auth.restoring) {
      return Scaffold(
        body: Container(
          decoration: context.fvOnboardingDecoration,
          child: const Center(child: VaultMark(size: 64)),
        ),
      );
    }

    if (!auth.isAuthenticated) {
      if (onboarding.step == OnboardingStep.welcome ||
          onboarding.step == OnboardingStep.complete) {
        return const FvLightTheme(child: WelcomeScreen());
      }
      return switch (onboarding.step) {
        OnboardingStep.role => const FvLightTheme(child: RoleScreen()),
        OnboardingStep.businessDetails => const FvLightTheme(
          child: BusinessDetailsScreen(),
        ),
        OnboardingStep.goals => const FvLightTheme(child: GoalsScreen()),
        OnboardingStep.linkAccounts => const FvLightTheme(
          child: LinkAccountsScreen(),
        ),
        _ => const FvLightTheme(child: WelcomeScreen()),
      };
    }

    if (!onboarding.isComplete) {
      return switch (onboarding.step) {
        OnboardingStep.role => const FvLightTheme(child: RoleScreen()),
        OnboardingStep.businessDetails => const FvLightTheme(
          child: BusinessDetailsScreen(),
        ),
        OnboardingStep.goals => const FvLightTheme(child: GoalsScreen()),
        OnboardingStep.linkAccounts => const FvLightTheme(
          child: LinkAccountsScreen(),
        ),
        _ => const HomeShell(),
      };
    }

    final biometricEnabled = ref.watch(preferencesProvider).biometricEnabled;
    if (biometricEnabled && !ref.watch(biometricSessionUnlockedProvider)) {
      return const FvLightTheme(child: BiometricGate());
    }

    return const HomeShell();
  }
}

class BiometricGate extends ConsumerStatefulWidget {
  const BiometricGate({super.key});

  @override
  ConsumerState<BiometricGate> createState() => _BiometricGateState();
}

class _BiometricGateState extends ConsumerState<BiometricGate> {
  bool _busy = false;

  Future<void> _unlock() async {
    setState(() => _busy = true);
    final ok = await ref.read(biometricServiceProvider).authenticate();
    if (ok && mounted) {
      ref.read(biometricSessionUnlockedProvider.notifier).state = true;
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    return Scaffold(
      body: Container(
        decoration: context.fvOnboardingDecoration,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(FvSpacing.x5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const VaultMark(size: 72),
                const SizedBox(height: FvSpacing.x5),
                Text(
                  s.biometricUnlock,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: FvSpacing.x2),
                Text(
                  s.biometricPrompt,
                  style: TextStyle(
                    fontSize: 13,
                    color: context.fvTextSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: FvSpacing.x5),
                FilledButton.icon(
                  onPressed: _busy ? null : _unlock,
                  icon: const Icon(Icons.fingerprint),
                  label: Text(s.biometricUnlock),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
