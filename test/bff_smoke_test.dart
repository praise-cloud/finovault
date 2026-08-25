import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:finovault_flutter/core/mock/api.dart';
import 'package:finovault_flutter/core/mock/db.dart';
import 'package:finovault_flutter/core/mock/http_api.dart';
import 'package:finovault_flutter/core/providers.dart';

/// Verifies the BFF wiring: `apiProvider` yields `HttpFinovaultApi` only when a
/// backend URL is configured, otherwise the in-app mock. Run the guarded test
/// against a real backend with `flutter test --dart-define=API_BASE_URL=...`.
void main() {
  test('apiProvider exposes HttpFinovaultApi when a base URL is configured', () {
    final container = ProviderContainer(
      overrides: [apiProvider.overrideWithValue(HttpFinovaultApi(baseUrl: 'https://bff.example.com'))],
    );
    expect(container.read(apiProvider), isA<HttpFinovaultApi>());
  });

  test('apiProvider falls back to MockFinovaultApi without a base URL', () {
    final container = ProviderContainer(
      overrides: [apiProvider.overrideWithValue(MockFinovaultApi(db: MockDb()))],
    );
    expect(container.read(apiProvider), isA<MockFinovaultApi>());
  });

  test(
    'live round-trip against a real BFF (skipped unless API_BASE_URL is set)',
    () async {
      final api = HttpFinovaultApi(baseUrl: const String.fromEnvironment('API_BASE_URL'));
      final auth = await api.login(email: 'demo@finovault.app', password: 'Vault123!');
      expect(auth.token, isNotEmpty);
      final accounts = await api.accounts(auth.token);
      expect(accounts, isA<List>());
    },
    skip: !const bool.hasEnvironment('API_BASE_URL') ||
        const String.fromEnvironment('API_BASE_URL').isEmpty,
  );

  test('apiBaseUrlProvider persists the configured URL across containers', () async {
    final kv = _MemoryKv();
    final container = ProviderContainer(overrides: [kvStoreProvider.overrideWithValue(kv)]);
    final controller = container.read(apiBaseUrlProvider.notifier);
    await controller.set('https://live.example.com');
    expect(container.read(apiBaseUrlProvider), 'https://live.example.com');

    final container2 = ProviderContainer(overrides: [kvStoreProvider.overrideWithValue(kv)]);
    expect(container2.read(apiBaseUrlProvider), 'https://live.example.com');

    await container2.read(apiBaseUrlProvider.notifier).set('');
    expect(container2.read(apiBaseUrlProvider), isNull);
  });
}

class _MemoryKv implements KvStore {
  final Map<String, String> _m = {};
  @override
  String? getString(String key) => _m[key];
  @override
  Future<void> setString(String key, String value) async => _m[key] = value;
  @override
  Future<void> remove(String key) async => _m.remove(key);
}
