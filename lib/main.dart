import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/providers.dart';
import 'core/state/auth.dart';
import 'core/state/onboarding.dart';
import 'core/state/preferences.dart';
import 'core/mock/db.dart';
import 'screens/home_shell.dart';
import 'screens/onboarding/goals_screen.dart';
import 'screens/onboarding/link_accounts_screen.dart';
import 'screens/role_screen.dart';
import 'screens/welcome_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/ui.dart';
import 'widgets/vault_mark.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final store = SharedPrefsStore(prefs);
  final db = MockDb(store: store);
  await db.hydrate();

  runApp(ProviderScope(
    overrides: [
      kvStoreProvider.overrideWithValue(store),
      mockDbProvider.overrideWithValue(db),
      initialPreferencesProvider.overrideWithValue(loadInitialPreferences(store)),
      initialOnboardingProvider.overrideWithValue(loadInitialOnboarding(store)),
    ],
    child: const FinovaultApp(),
  ));
}

class SharedPrefsStore extends KvStore {
  SharedPrefsStore(this._prefs);
  final SharedPreferences _prefs;

  @override
  String? getString(String key) => _prefs.getString(key);
  @override
  Future<void> setString(String key, String value) => _prefs.setString(key, value);
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
    Future.microtask(() => ref.read(authProvider.notifier).restore());
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(preferencesProvider);
    return MaterialApp(
      title: 'Finovault',
      debugShowCheckedModeBanner: false,
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
          decoration: context.fvPageDecoration,
          child: const Center(child: const VaultMark(size: 64)),
        ),
      );
    }

    if (!auth.isAuthenticated) {
      if (onboarding.step == OnboardingStep.welcome || onboarding.step == OnboardingStep.complete) {
        return const WelcomeScreen();
      }
      return switch (onboarding.step) {
        OnboardingStep.role => const RoleScreen(),
        OnboardingStep.goals => const GoalsScreen(),
        OnboardingStep.linkAccounts => const LinkAccountsScreen(),
        _ => const WelcomeScreen(),
      };
    }

    if (!onboarding.isComplete) {
      return switch (onboarding.step) {
        OnboardingStep.role => const RoleScreen(),
        OnboardingStep.goals => const GoalsScreen(),
        OnboardingStep.linkAccounts => const LinkAccountsScreen(),
        _ => const HomeShell(),
      };
    }

    return const HomeShell();
  }
}
