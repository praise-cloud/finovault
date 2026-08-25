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
# feature/pension

This branch contains the **Pension** feature of the Finovault Flutter app.

## What it is
A flexible micro‑pension that splits savings into a **short‑term** and a
**long‑term** pot, with recurring contributions and a projected retirement value.

## What was achieved
- `PensionScreen` dashboard: projected value at retirement, two progress‑ring pots
  (short‑term / long‑term), a contribution summary, and a recent‑contributions list.
- `PensionSetupScreen`: configure frequency (e.g. weekly / monthly), assumed return %,
  inflation %, auto‑debit on/off, and the short/long‑term split.
- `Contribute` flow (bottom sheet): choose pot, amount, and source account.
- State and API surface in `lib/core/state/money.dart` and `FinovaultApi`
  (`contributePension`, `pensionPlan`, `pensionContributions`, `pensionProjection`).

The complete app (onboarding, auth, money screens, insights, tests, theming) is
also present on this branch; this README focuses on the pension work.
# feature/insights-csv

This branch contains the **Insights** feature of the Finovault Flutter app.

## What it is
The Insights tab visualises spending and saving behaviour and lets the user
export the data for further analysis.

## What was achieved
- `InsightsTab` with a spending‑breakdown **pie chart** built using `fl_chart`.
- A **CSV export** of the insights/transactions data (web‑safe via
  `dart:html` shim, native via `csv_export_native.dart` / `csv_export_web.dart`).
- Wiring of insights data through `FinovaultApi` / `core/state/money.dart`.

The complete app (onboarding, auth, money screens, pension, tests, theming) is
also present on this branch; this README focuses on the insights/CSV work.
# feature/widget-tests-ci

This branch contains the **widget test suite and CI** for the Finovault
Flutter app.

## What it is
Automated tests that pump every screen and assert there are no layout‑overflow
or runtime errors, plus a brand‑colour regression test for onboarding/auth, and
a GitHub Actions workflow that runs the suite on every push.

## What was achieved
- `test/helpers.dart`: shared `pumpScreen` + provider‑container helpers (logged‑in
  and logged‑out) so every screen can be pumped inside the real provider tree.
- `test/screens_test.dart`: smoke tests for all screens (no overflow / no errors),
  including money screens, tabs, auth, and onboarding.
- `test/onboarding_text_test.dart`: asserts onboarding/auth text renders in the
  brand‑primary colour (light mode) and that `RoleScreen` uses a theme‑aware
  background (dark mode).
- `.github/workflows/*`: CI running `flutter test` on push.

The complete app source is also present on this branch; this README focuses on
the testing/CI work.

# feature/overflow-fixes

This branch contains the **layout‑overflow fixes** for the Finovault Flutter app.

## What it is
Five screens previously overflowed horizontally at a phone viewport (393×852).
This branch makes them fit.

## What was achieved
- `VaultTab`: the two action buttons are stacked vertically (`Column` +
  `expanded`) so each gets full width; `FvButton` is also made ellipsis‑safe
  when narrow.
- `BudgetsScreen`: the "spent / amount" cluster is now `Flexible` with ellipsis
  so long MUR amounts can't overflow the card row.
- `InvoicesScreen`: the amount is stacked above the status badge + check button
  (two‑line right column) instead of cramming one row.
- `PensionScreen`: `_Row` label/value use `Flexible` + ellipsis.
- `TransferScreen`: the `DropdownButtonFormField` uses `isExpanded` plus an
  ellipsis `selectedItemBuilder` so the account name + balance shrink.

The complete app source is also present on this branch; this README focuses on
the overflow‑fix work.
# feature/onboarding-branding

This branch contains the **onboarding / auth branding** work for the Finovault
Flutter app — fixing white/invisible text and applying the brand‑primary colour.

## What it is
On the early (pre‑auth) and onboarding screens, text was coloured white in dark
mode while some backgrounds stayed light, making it invisible. This branch makes
all such text render in the brand‑primary blue and ensures backgrounds are
theme‑aware.

## What was achieved
- `lib/widgets/ui.dart`: `fvText` / `fvTextSecondary` resolve to `FvColors.primary`
  in light mode, and `FvTextField` label, typed text, hint, and outline are
  brand‑primary in both modes.
- `RoleScreen`: background switched to the theme‑aware `fvPageDecoration` (dark
  navy gradient in dark mode) and all headings/descriptions/option labels set to
  brand‑primary.
- `GoalsScreen` / `LinkAccountsScreen`: headings and clickable option labels set
  to brand‑primary.
- `test/onboarding_text_test.dart`: asserts onboarding/auth text is brand‑primary
  in light mode and that `RoleScreen` uses a dark background in dark mode.

The complete app source is also present on this branch; this README focuses on
the branding work.
