import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:finovault_flutter/core/mock/db.dart';
import 'package:finovault_flutter/core/providers.dart';
import 'package:finovault_flutter/core/state/onboarding.dart';
import 'package:finovault_flutter/core/state/preferences.dart';

/// Builds a [ProviderContainer] wired to an in-memory store + mock DB so the
/// real provider/API logic runs in tests without SharedPreferences or a backend.
ProviderContainer makeContainer({KvStore? store}) {
  final s = store ?? MemoryStore();
  final db = MockDb(store: s, latency: 0);
  return ProviderContainer(
    overrides: [
      kvStoreProvider.overrideWithValue(s),
      mockDbProvider.overrideWithValue(db),
      apiLatencyProvider.overrideWith((ref) => Duration.zero),
      initialPreferencesProvider.overrideWithValue(loadInitialPreferences(s)),
      initialOnboardingProvider.overrideWithValue(loadInitialOnboarding(s)),
    ],
  );
}
