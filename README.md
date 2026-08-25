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
