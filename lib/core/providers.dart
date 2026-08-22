import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'mock/api.dart';
import 'mock/db.dart';
import 'mock/http_api.dart';

/// Session token storage key (SharedPreferences-backed via KvStore).
const sessionKey = 'finovault.session';

final kvStoreProvider = Provider<KvStore>(
  (ref) => throw UnimplementedError('kvStoreProvider must be overridden in main'),
);

final mockDbProvider = Provider<MockDb>(
  (ref) => throw UnimplementedError('mockDbProvider must be overridden in main'),
);

final apiLatencyProvider = StateProvider<Duration>((ref) => const Duration(milliseconds: 250));

/// When set (e.g. `--dart-define=API_BASE_URL=http://localhost:8787`), the app
/// talks to the BFF via `HttpFinovaultApi` instead of the in-memory mock.
final apiBaseUrlProvider = StateProvider<String?>((ref) =>
    const bool.hasEnvironment('API_BASE_URL') ? const String.fromEnvironment('API_BASE_URL') : null);

final apiProvider = Provider<FinovaultApi>((ref) {
  final baseUrl = ref.watch(apiBaseUrlProvider);
  if (baseUrl != null && baseUrl.isNotEmpty) {
    final api = HttpFinovaultApi(baseUrl: baseUrl);
    ref.onDispose(api.close);
    return api;
  }
  final api = MockFinovaultApi(db: ref.watch(mockDbProvider), latency: ref.watch(apiLatencyProvider));
  ref.onDispose(api.db.clearStorage);
  return api;
});

String? currentToken(Ref ref) => ref.watch(kvStoreProvider).getString(sessionKey);
