import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:finovault_flutter/core/mock/db.dart';
import 'package:finovault_flutter/core/providers.dart';
import 'package:finovault_flutter/core/state/auth.dart';
import 'package:finovault_flutter/core/state/notifications.dart';
import 'package:finovault_flutter/core/state/onboarding.dart';
import 'package:finovault_flutter/core/state/preferences.dart';
import 'package:finovault_flutter/l10n/app_localizations.dart';

/// Logged-out container mirroring the app's provider wiring against the
/// in-memory mock backend.
Future<ProviderContainer> makeContainer({Duration latency = Duration.zero}) async {
  final store = MemoryStore();
  final db = MockDb(store: store, latency: 0);
  await db.hydrate();
  return ProviderContainer(overrides: [
    kvStoreProvider.overrideWithValue(store),
    mockDbProvider.overrideWithValue(db),
    apiLatencyProvider.overrideWith((ref) => latency),
    notificationServiceProvider.overrideWithValue(DebugNotificationService()),
    initialPreferencesProvider.overrideWithValue(loadInitialPreferences(store)),
    initialOnboardingProvider.overrideWithValue(loadInitialOnboarding(store)),
  ]);
}

/// Container with the demo user authenticated (drives money/persona screens).
Future<ProviderContainer> makeLoggedInContainer() async {
  final c = await makeContainer();
  await c.read(authProvider.notifier).login('demo@finovault.app', 'Vault123!');
  return c;
}

/// Pumps a screen inside the real provider tree + MaterialApp at a phone
/// viewport. Layout/overflow errors surface as test failures.
Future<void> pumpScreen(
  WidgetTester tester,
  Widget screen, {
  ProviderContainer? container,
  bool loggedIn = true,
  ThemeData? theme,
}) async {
  container ??= loggedIn ? await makeLoggedInContainer() : await makeContainer();
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        theme: theme ?? ThemeData.light(),
        home: screen,
      ),
    ),
  );
  await tester.pumpAndSettle();
}
