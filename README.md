# Finovault (Flutter)

Cross-platform money app (onboarding/auth, role-aware home, money features,
pension, insights + CSV export, and a BFF-ready API abstraction) with
brand-primary theming, no layout-overflow, and full en/fr internationalization.

## Highlights
- **Onboarding & auth**: welcome → role (Individual / Freelancer / Entrepreneur /
  SME, incl. female-founder path) → goals & risk → link accounts → signup/login.
  Demo login (mock mode): `demo@finovault.app` / `Vault123!`.
- **Role-aware home**: each persona sees its own hero metric and modules (never a
  generic dashboard). Insights, Vault, Pay and Profile tabs.
- **Money features**: accounts, transactions, budgets, goals, invoices, vendors,
  transfers (with fee + idempotency), bills, security, and a micro-pension
  (short/long pots + projection).
- **Backend wiring**: `HttpFinovaultApi` talks to the BFF over the RPC envelope
  documented in `18-API-CONTRACTS.md`. `lib/core/providers.dart` swaps the
  implementation based on `apiBaseUrlProvider` (set via
  `--dart-define=API_BASE_URL`); otherwise the in-app `MockFinovaultApi` is used.
  Model `fromJson` factories are null-safe against missing numeric fields.
- **i18n (en / fr)**: `flutter_localizations` + `intl`, catalogs in `lib/l10n/`
  (`app_en.arb` + `app_fr.arb`), locale wired from `preferencesProvider.language`
  with a live language switcher in Profile → Settings. `FvFormat` renders
  currency symbols (`MUR` → `Rs`, `USD` → `$`, …) with locale-aware grouping.

## Develop
```
flutter pub get
flutter gen-l10n      # regenerate AppLocalizations from lib/l10n/*.arb
flutter test          # widget/unit tests, overflow + brand-color checks
flutter run --dart-define=API_BASE_URL=https://your-bff.example.com
```

## Project layout
- `lib/core/` — models, providers, mock API (`MockFinovaultApi` + `HttpFinovaultApi`),
  formatting, and state controllers (auth, preferences, onboarding, money).
- `lib/screens/` — onboarding, auth, role, home shell, and money feature screens.
- `lib/l10n/` — ARB message catalogs and generated localization code.
- `test/` — `helpers.dart` (provider + MaterialApp harness with localization
  delegates), screen/overflow tests, API tests, money & state tests.
