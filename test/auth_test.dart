import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:finovault_flutter/core/mock/api.dart';
import 'package:finovault_flutter/core/mock/db.dart';
import 'package:finovault_flutter/core/providers.dart';
import 'package:finovault_flutter/core/state/auth.dart';
import 'package:finovault_flutter/core/state/onboarding.dart';

void main() {
  test('login marks onboarding complete for a returning user', () async {
    final store = _MemoryKv();
    final container = ProviderContainer(
      overrides: [
        kvStoreProvider.overrideWithValue(store),
        mockDbProvider.overrideWithValue(MockDb()),
      ],
    );

    final auth = container.read(authProvider.notifier);
    expect(await auth.signup('Demo User', 'demo@finovault.app', 'Vault123!'), isTrue);
    final ok = await auth.login('demo@finovault.app', 'Vault123!');
    expect(ok, isTrue);
    expect(container.read(onboardingProvider).isComplete, isTrue);
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
