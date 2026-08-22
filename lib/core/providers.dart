import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'mock/api.dart';
import 'mock/db.dart';

/// Session token storage key (SharedPreferences-backed via KvStore).
const sessionKey = 'finovault.session';

final kvStoreProvider = Provider<KvStore>(
  (ref) => throw UnimplementedError('kvStoreProvider must be overridden in main'),
);

final mockDbProvider = Provider<MockDb>(
  (ref) => throw UnimplementedError('mockDbProvider must be overridden in main'),
);

final apiLatencyProvider = StateProvider<Duration>((ref) => const Duration(milliseconds: 250));

final apiProvider = Provider<FinovaultApi>((ref) {
  final api = FinovaultApi(db: ref.watch(mockDbProvider), latency: ref.watch(apiLatencyProvider));
  ref.onDispose(api.db.clearStorage);
  return api;
});

String? currentToken(Ref ref) => ref.watch(kvStoreProvider).getString(sessionKey);
