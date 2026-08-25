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
