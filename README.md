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
