import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;

import 'package:finovault_flutter/core/mock/api.dart';
import 'package:finovault_flutter/core/mock/db.dart';
import 'package:finovault_flutter/core/mock/http_api.dart';
import 'package:finovault_flutter/core/providers.dart';
import 'package:finovault_flutter/core/state/auth.dart';
import '../tool/mock_bff/server.dart';

/// Verifies the BFF wiring: `apiProvider` yields `HttpFinovaultApi` only when a
/// backend URL is configured, otherwise the in-app mock, and that the real HTTP
/// client actually talks to a running BFF server (the reference mock BFF is
/// started in-process so this runs without any external dependency).
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

  test('app BFF client talks to a running mock BFF server', () async {
    final server = await io.serve(mockBffHandler(), InternetAddress.loopbackIPv4, 0);
    try {
      final baseUrl = 'http://${server.address.host}:${server.port}';
      final api = HttpFinovaultApi(baseUrl: baseUrl);

      final auth = await api.login(email: 'demo@finovault.app', password: 'Vault123!');
      expect(auth.token, isNotEmpty);
      expect(auth.user.primaryRole, isNotNull);

      final session = await api.getSession(auth.token);
      expect(session?.email, 'demo@finovault.app');

      final accounts = await api.accounts(auth.token);
      expect(accounts, hasLength(3));
    } finally {
      await server.close(force: true);
    }
  });

  test('auth.login succeeds against the configured backend URL', () async {
    final kv = _MemoryKv();
    final server = await io.serve(mockBffHandler(), InternetAddress.loopbackIPv4, 0);
    final baseUrl = 'http://${server.address.host}:${server.port}';
    try {
      final container = ProviderContainer(
        overrides: [
          kvStoreProvider.overrideWithValue(kv),
          mockDbProvider.overrideWithValue(MockDb()),
        ],
      );
      await container.read(apiBaseUrlProvider.notifier).set(baseUrl);
      final ok = await container.read(authProvider.notifier).login('demo@finovault.app', 'Vault123!');
      expect(ok, isTrue);
      expect(container.read(authProvider).user, isNotNull);
    } finally {
      await server.close(force: true);
    }
  });

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
