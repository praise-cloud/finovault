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

/// When set, the app talks to the BFF via `HttpFinovaultApi` instead of the
/// in-memory mock. The URL is persisted in `KvStore` (so it survives restarts
/// and can be changed from Settings without a rebuild) and is seeded from the
/// `API_BASE_URL` compile-time variable when nothing has been stored yet.
final apiBaseUrlProvider = NotifierProvider<ApiBaseUrlController, String?>(ApiBaseUrlController.new);

class ApiBaseUrlController extends Notifier<String?> {
  static const _key = 'finovault.apiBaseUrl';

  @override
  String? build() {
    final stored = ref.read(kvStoreProvider).getString(_key);
    if (stored != null && stored.trim().isNotEmpty) return stored.trim();
    final env = const bool.hasEnvironment('API_BASE_URL') ? const String.fromEnvironment('API_BASE_URL') : '';
    return env.trim().isNotEmpty ? env.trim() : null;
  }

  Future<void> set(String? url) async {
    final trimmed = (url ?? '').trim();
    state = trimmed.isEmpty ? null : trimmed;
    if (state == null) {
      await ref.read(kvStoreProvider).remove(_key);
    } else {
      await ref.read(kvStoreProvider).setString(_key, state!);
    }
  }
}

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
