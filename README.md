# feature/backend-api

This branch contains the **backend‑ready API layer** of the Finovault Flutter app.

## What it is
A `FinovaultApi` abstraction that decouples the UI from the data source, so the
app can run against an in‑memory mock today and a real BFF/REST backend tomorrow
without touching screen code.

## What was achieved
- `FinovaultApi` interface defining every backend operation the screens need
  (auth, accounts, goals, budgets, invoices, transfers, pension, insights, etc.).
- `MockFinovaultApi`: a full in‑memory implementation used by default, seeded with
  demo data so the app is runnable with no server.
- `HttpFinovaultApi`: the real implementation that talks to the BFF over REST,
  documenting the request/response contract.
- Provider wiring in `lib/core/providers.dart` (`apiProvider`, `mockDbProvider`)
  so implementations are swapped via a single override.
- `core/mock/db.dart` in‑memory store and `core/state/*` Riverpod state layered on
  top of the API.

The complete app (onboarding, auth, money screens, insights, tests, theming) is
also present on this branch; this README focuses on the API/backend work.
