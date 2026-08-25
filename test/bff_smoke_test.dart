import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:finovault_flutter/core/mock/api.dart';
import 'package:finovault_flutter/core/mock/db.dart';
import 'package:finovault_flutter/core/mock/http_api.dart';
import 'package:finovault_flutter/core/providers.dart';

/// Verifies the BFF wiring: `apiProvider` returns the HTTP client only when an
/// `apiBaseUrlProvider` is supplied (set via `--dart-define=API_BASE_URL=...`),
/// otherwise the in-app mock is used. This is the smoke test for a real backend
/// — point `API_BASE_URL` at your BFF and the rest of the app talks to it
/// unchanged.
void main() {
  test('apiProvider uses HttpFinovaultApi when API_BASE_URL is set', () {
    final container = ProviderContainer(
      overrides: [
        apiBaseUrlProvider.overrideWith((ref) => 'https://bff.example.com'),
      ],
    );
    expect(container.read(apiProvider), isA<HttpFinovaultApi>());
  });

  test('apiProvider falls back to MockFinovaultApi without API_BASE_URL', () {
    final container = ProviderContainer(
      overrides: [
        mockDbProvider.overrideWithValue(MockDb()),
        apiBaseUrlProvider.overrideWith((ref) => null),
      ],
    );
    expect(container.read(apiProvider), isA<MockFinovaultApi>());
  });
}
