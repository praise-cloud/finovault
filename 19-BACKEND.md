# Connecting Finovault to a backend

The app is **BFF-ready**. It ships with two transports, selected by the
configured backend URL:

| Source                          | Used when                                  | Behaviour |
| ------------------------------- | ------------------------------------------ | --------- |
| In-app `MockFinovaultApi`       | no backend URL configured (default)        | All data served from an in-memory store seeded on startup. |
| `HttpFinovaultApi` (real HTTP)  | a backend URL **is** configured            | `POST {baseUrl}/rpc` with the `{method, args}` envelope; Bearer auth. |

The wire contract is documented in [`18-API-CONTRACTS.md`](./18-API-CONTRACTS.md).

## Option A — Run against the reference mock BFF (no backend needed)

A reference server lives in `tool/mock_bff/server.dart`. It implements every
RPC method from the contract so the app runs end-to-end over real HTTP.

```bash
# From the repo root:
./tool/run_with_mock_bff.sh      # macOS / Linux
# or
.\tool\run_with_mock_bff.ps1     # Windows
```

This starts the mock BFF on port `8080` and launches the app with
`--dart-define=API_BASE_URL=http://localhost:8080`.

From the **device/emulator**, point at the host instead:

```bash
# Android emulator
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
# iOS simulator
flutter run --dart-define=API_BASE_URL=http://localhost:8080
```

You can also set the URL at runtime from **Settings → Backend URL** (persisted)
and use **Test Connection** to verify reachability.

Demo credentials against the mock BFF: `demo@finovault.app` / `Vault123!`.

## Option B — Point at a hosted / production backend

The app only needs one thing: the base URL of a server that speaks the
`/rpc` envelope from `18-API-CONTRACTS.md`.

1. **Build-time:** `flutter run --dart-define=API_BASE_URL=https://your-bff.example.com`
   (also honoured from the environment when the app starts).
2. **Runtime:** open **Settings → Backend URL**, paste the URL, tap **Save**,
   then **Test Connection**. The choice is persisted in local storage and the
   `apiProvider` swaps to `HttpFinovaultApi` immediately.

## Verifying the connection

`test/bff_smoke_test.dart` starts the reference mock BFF **in-process** and
asserts the real `HttpFinovaultApi` can log in and fetch accounts through it —
so the client↔server path is exercised on every `flutter test` run (no external
server required).

## What is still required for a real production backend

- **Hosting** the BFF (the mock is a contract reference, not a real datastore).
- **Auth & security:** real token issuance/refresh, password hashing, rate
  limiting, TLS — the mock returns a static token.
- **Push (FCM/APNs):** wire `NotificationService` to `firebase_messaging`.
  Local on-device notifications are already implemented.
- **Biometric unlock** is wired (iOS/Android) and needs a device with
  biometrics enrolled to exercise.
