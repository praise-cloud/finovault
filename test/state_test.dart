import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:finovault_flutter/core/mock/db.dart';
import 'package:finovault_flutter/core/models.dart';
import 'package:finovault_flutter/core/providers.dart';
import 'package:finovault_flutter/core/state/auth.dart';
import 'package:finovault_flutter/core/state/onboarding.dart';
import 'package:finovault_flutter/core/state/preferences.dart';

import 'test_utils.dart';

ProviderContainer _container(KvStore store, MockDb db) => ProviderContainer(
      overrides: [
        kvStoreProvider.overrideWithValue(store),
        mockDbProvider.overrideWithValue(db),
        apiLatencyProvider.overrideWith((ref) => Duration.zero),
      ],
    );

void main() {
  group('AuthController', () {
    test('signup persists token; logout clears it', () async {
      final c = makeContainer();
      final auth = c.read(authProvider.notifier);
      expect(await auth.signup('U', 'u@e.com', 'secret123'), isTrue);
      expect(c.read(kvStoreProvider).getString(sessionKey), isNotEmpty);
      expect(c.read(authProvider).isAuthenticated, isTrue);

      await auth.logout();
      expect(c.read(authProvider).isAuthenticated, isFalse);
      expect(c.read(kvStoreProvider).getString(sessionKey), isNull);
      c.dispose();
    });

    test('login with wrong password returns false and sets error', () async {
      final c = makeContainer();
      final auth = c.read(authProvider.notifier);
      await auth.signup('U', 'u@e.com', 'secret123');
      await auth.logout();
      expect(await auth.login('u@e.com', 'wrong'), isFalse);
      expect(c.read(authProvider).error, isNotNull);
      c.dispose();
    });

    test('restore with valid persisted token authenticates', () async {
      final store = MemoryStore();
      final db = MockDb(store: store, latency: 0);
      final c = _container(store, db);
      final ar = await c.read(apiProvider).signup(fullName: 'U', email: 'u@e.com', password: 'secret123');
      await c.read(kvStoreProvider).setString(sessionKey, ar.token);

      final c2 = _container(store, db);
      expect(c2.read(authProvider).restoring, isTrue);
      await c2.read(authProvider.notifier).restore();
      expect(c2.read(authProvider).restoring, isFalse);
      expect(c2.read(authProvider).isAuthenticated, isTrue);
      c.dispose();
      c2.dispose();
    });

    test('restore with invalid token clears the session', () async {
      final store = MemoryStore();
      await store.setString(sessionKey, 'bogus-token');
      final db = MockDb(store: store, latency: 0);
      final c = _container(store, db);
      await c.read(authProvider.notifier).restore();
      expect(c.read(authProvider).restoring, isFalse);
      expect(c.read(authProvider).isAuthenticated, isFalse);
      expect(c.read(kvStoreProvider).getString(sessionKey), isNull);
      c.dispose();
    });
  });

  group('PreferencesController', () {
    test('language and theme mode persist across containers', () async {
      final store = MemoryStore();
      final c = makeContainer(store: store);
      final prefs = c.read(preferencesProvider.notifier);
      await prefs.setLanguage('fr');
      await prefs.setThemeMode(ThemeModePref.dark);
      expect(c.read(preferencesProvider).language, 'fr');
      expect(c.read(preferencesProvider).themeMode, ThemeModePref.dark);

      final c2 = makeContainer(store: store);
      expect(c2.read(preferencesProvider).language, 'fr');
      expect(c2.read(preferencesProvider).themeMode, ThemeModePref.dark);
      c.dispose();
      c2.dispose();
    });
  });

  group('OnboardingController', () {
    test('flow advances welcome -> role -> goals -> link -> complete', () async {
      final c = makeContainer();
      final ob = c.read(onboardingProvider.notifier);
      expect(c.read(onboardingProvider).step, OnboardingStep.welcome);

      await ob.start();
      expect(c.read(onboardingProvider).step, OnboardingStep.role);

      await ob.selectRole(PrimaryRole.entrepreneur, femaleFounder: true);
      expect(c.read(onboardingProvider).role, PrimaryRole.entrepreneur);
      expect(c.read(onboardingProvider).scheme, RoleScheme.femaleFounder);
      expect(c.read(onboardingProvider).step, OnboardingStep.goals);

      await ob.setGoals(['Save'], RiskTolerance.moderate);
      expect(c.read(onboardingProvider).step, OnboardingStep.linkAccounts);

      await ob.complete();
      expect(c.read(onboardingProvider).step, OnboardingStep.complete);
      c.dispose();
    });

    test('selection + completion persist to storage', () async {
      final store = MemoryStore();
      final c = makeContainer(store: store);
      final ob = c.read(onboardingProvider.notifier);
      await ob.start();
      await ob.selectRole(PrimaryRole.sme, femaleFounder: false);
      await ob.setGoals(['Grow'], null);
      await ob.complete();

      final c2 = makeContainer(store: store);
      expect(c2.read(onboardingProvider).step, OnboardingStep.complete);
      expect(c2.read(onboardingProvider).role, PrimaryRole.sme);
      c.dispose();
      c2.dispose();
    });
  });
}
