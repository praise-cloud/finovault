import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:finovault_flutter/core/mock/db.dart';
import 'package:finovault_flutter/core/providers.dart';
import 'package:finovault_flutter/core/state/preferences.dart';
import 'package:finovault_flutter/core/state/onboarding.dart';
import 'package:finovault_flutter/main.dart';
import 'package:finovault_flutter/screens/welcome_screen.dart';

ProviderScope withProviders(Widget child) {
  final store = MemoryStore();
  final db = MockDb(store: store, latency: 0);
  return ProviderScope(
    overrides: [
      kvStoreProvider.overrideWithValue(store),
      mockDbProvider.overrideWithValue(db),
      apiLatencyProvider.overrideWith((ref) => Duration.zero),
      initialPreferencesProvider.overrideWithValue(loadInitialPreferences(store)),
      initialOnboardingProvider.overrideWithValue(loadInitialOnboarding(store)),
    ],
    child: child,
  );
}

void main() {
  testWidgets('root gate shows the welcome screen when signed out', (tester) async {
    await tester.pumpWidget(withProviders(const FinovaultApp()));
    await tester.pumpAndSettle();

    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });

  testWidgets('Get Started advances into role selection', (tester) async {
    await tester.pumpWidget(withProviders(const FinovaultApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.text('How will you use Finovault?'), findsOneWidget);
  });
}
