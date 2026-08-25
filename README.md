# Feature: Backend wiring (HttpFinovaultApi)

Verifies and hardens the real BFF client `HttpFinovaultApi` without needing a live
server, and makes the model `fromJson` factories tolerate missing numeric fields
from the backend.

## What this branch adds
- `test/http_api_test.dart` — drives `HttpFinovaultApi` through a `MockClient`
  (`package:http/testing`) and asserts:
  - `login` posts the `{ "method", "args" }` RPC envelope to `/rpc` and decodes the
    `data` envelope into an `AuthResult` (no `Authorization` header before auth).
  - Authenticated RPCs send `Authorization: Bearer <token>`.
  - Enums are encoded as their `.name` and `DateTime` as ISO-8601 (asserted round-trip
    on `createInvoice` / `payBill` / `createTransfer`).
  - `createTransfer` forwards the `idempotencyKey`.
  - An `{ "error": { "code", "message" } }` envelope is surfaced as `FvApiException`.
- `lib/core/models.dart` — numeric `fromJson` fields (`amount`, `balance`, etc.) are now
  null-safe: `(j['x'] as num?)?.toDouble() ?? 0` instead of a hard `as num` cast, so a
  missing/zero value from the BFF no longer throws.

## How the app talks to the real backend
`lib/core/providers.dart` already swaps the implementation: when `apiBaseUrlProvider`
(backed by `--dart-define=API_BASE_URL`) is set, `apiProvider` returns
`HttpFinovaultApi`; otherwise it returns the in-app `MockFinovaultApi`. No UI change
required — wire the BFF by building with:

```
flutter run --dart-define=API_BASE_URL=https://your-bff.example.com
```

## Verification
- `flutter analyze` — no errors.
- `flutter test test/http_api_test.dart` — 6/6 pass.
- Full suite (`flutter test`) — all green.

Demo login (mock mode): `demo@finovault.app` / `Vault123!`
