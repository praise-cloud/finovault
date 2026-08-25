# feature/stability-tests

This branch contains the **stability hardening and test coverage** work for the
Finovault Flutter app — the first phase of build‑out after the app shipped.

## What it is
Fixes that remove latent crashes and lint noise, plus a new test suite that
locks in the API contract, derived money logic, and core app state.

## What was achieved
- **Stability (analyzer: 0 issues):**
  - Fixed 10 latent `use_build_context_synchronously` crashes — every post‑`await`
    `BuildContext` use is now guarded by its own `.mounted`.
  - `dart fix` applied 30 missing `@override` annotations plus `prefer_initializing_formals`.
  - Removed dead code (`insights_tab.dart`), `unnecessary_const`, `unnecessary_underscores`,
    and the `use_null_aware_elements` pattern in `ui.dart`.
  - The intentional `dart:html` CSV web shim is suppressed for that web‑only file.
- **New tests (47 → 77 passing):**
  - `test/api_test.dart` — mock API contract: login fail, `email_taken`, goal/transfer
    `insufficient_funds`, contribute deduction, invoice lifecycle, vendor/payee CRUD,
    bill pay, scheduled bill, pension contribute.
  - `test/money_test.dart` — `FvFormat` (money/percent/date, French locale, transfer fee,
    password strength) and `moneySummaryProvider` (net worth, income, runway, tax estimate,
    top category, unpaid/overdue invoice totals).
  - `test/state_test.dart` — `AuthController` (signup/logout, wrong password, `restore`
    valid/invalid token), `PreferencesController` persistence, `OnboardingController`
    flow + persistence.
  - `test/form_test.dart` — login wrong‑password surfaces the error UI.
  - `test/test_utils.dart` — shared in‑memory `ProviderContainer` helper.

The complete app source is also present on this branch; this README focuses on the
stability/test work.
