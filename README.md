# Finovault (Flutter)

Cross-platform financial application built with Flutter, Riverpod, and a pure neo-brutalist light theme. Features streamlined authentication, student vault allowance tracking, custom alert modals, dynamic user currency configuration, and seamless backend synchronization with `finovault-bff`.

## Highlights
- **Streamlined Authentication & Onboarding**:
  - Direct, frictionless onboarding: Welcome screen leads straight to account creation (Full Name, Email, Phone, Password) via **Get Started**, or directly to **Log in** for existing users.
  - Multi-step questionnaire and unneeded wizard screens have been removed for an instant, direct path to the application.
  - Demo login (mock mode): `demo@finovault.app` / `Vault123!`.
- **User-Selectable Currency & Half-Screen Settings Drawer**:
  - **Half-Screen Drawer**: Settings & Plan opens in a tactile half-screen modal drawer (55% viewport height) with grab handle, title, and close button, allowing scrollable configuration without blocking the entire screen.
  - **Comprehensive Currency Dropdown**: Users can select from 20 global and African currencies via a tactile neo-brutalist dropdown (`USD $`, `EUR €`, `GBP £`, `NGN ₦`, `MUR Rs`, `ZAR R`, `KES KSh`, `GHS GH₵`, `CAD $`, `AUD $`, `INR ₹`, `JPY ¥`, `CNY ¥`, `AED AED`, `EGP E£`, `RWF FRw`, `TZS TSh`, `UGX USh`, `XOF CFA`, `XAF FCFA`).
  - Currency preferences persist locally in `SharedPreferences` and instantly sync across all active screens, the Student Vault fuel gauge, transaction history, budget caps, merchant hangout spots, and savings pots.
- **Pure Neo-Brutalist Light Mode**:
  - Dedicated light mode across the full application (`#F3F1EA` page background, crisp `#FFFFFF` cards, 2px solid `#0A0A0A` ink black borders, 3px hard drop shadows, and pure black typography). Unneeded dark theme toggles and backend URL manual inputs have been removed to preserve design consistency and direct automatic backend connection.
  - **Edit Profile**: Text and input field outlines are rendered in solid black (`#0A0A0A`) with clean borders across normal, focused, and disabled states.
  - Full accessibility compliance with semantic labels and toggle states (`profile_a11y_test.dart`).
- **Custom Modals & Floating Notifications**:
  - `FvAlertDialog`: High-contrast brutalist confirmation modal supporting `info`, `warning`, `danger`, and `success` severities (wired to budget/expense deletions and logout confirmation).
  - `FvNotification`: Floating toast notifications with progress countdown indicators for validation errors, currency updates, backend URL changes, and transaction logging.
- **Student Vault & Backend Synchronization**:
  - Budget tracking, allowance fuel gauge, quick log pad, customizable category budgets, and savings pots.
  - Synchronizes optimistically with `finovault-bff` via `HttpFinovaultApi` RPC calls (`POST /rpc`), falling back to local storage and mock mode when offline.
- **i18n (en / fr)**:
  - `flutter_localizations` + `intl` catalogs in `lib/l10n/` (`app_en.arb` + `app_fr.arb`), wired to `preferencesProvider.language` with an in-app language switcher.
- **Security & Biometric Unlock**:
  - Biometric authentication gate (`local_auth`) configurable in Settings.
  - Two-factor authentication (2FA), password changes, and active session management.

## Develop
```bash
flutter pub get
flutter gen-l10n      # regenerate AppLocalizations from lib/l10n/*.arb
flutter test          # run all unit, widget, and accessibility tests
flutter run --dart-define=API_BASE_URL=http://localhost:8787
```

## Project Layout
- `lib/core/` — Models, providers, mock & HTTP API clients (`FinovaultApi`), formatting helpers (`FvFormat`), and Riverpod state controllers (`auth`, `preferences`, `student_vault`, `money`, `biometric`).
- `lib/screens/` — Screen implementations:
  - `welcome_screen.dart` — App hero entry screen.
  - `auth/` — Login, signup, password reset, and OTP screens.
  - `home_shell.dart` — Tab scaffold for Insights, Vault, Pay, and Profile.
  - `student_home_screen.dart` — Student Vault allowance gauge and quick actions.
  - `profile/` — Edit profile and change password screens.
  - `tabs/` — Main tab views (`profile_tab.dart`, `student_budget_tab.dart`, `student_history_tab.dart`, `vault_tab.dart`, `pay_tab.dart`, `insights_tab.dart`).
- `lib/widgets/` — Reusable brutalist UI components:
  - `fv_alert_dialog.dart` — Neo-brutalist alert and confirm dialogs.
  - `fv_notification.dart` — Floating notification toasts.
  - `student_vault/` — Fuel gauge, merchant spots bar, quick log pad, edit modal, and period wrap modal.
- `lib/l10n/` — ARB translation files and generated localization delegates.
- `test/` — Unit, widget, accessibility, and integration smoke test suites.
