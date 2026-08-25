# Finovault (Flutter)

Finovault is a mobile money‑management app built with Flutter. Its tagline is
**"Vault Your Future. Grow Your Wealth."** — it helps people save toward goals,
budget, invoice clients, move money, and build a flexible micro‑pension, all
through a **role‑aware** experience for Individuals, Freelancers, SMEs, and
Entrepreneurs (including a Women‑led / Female‑founder path).

> The app runs against an in‑memory mock backend by default, so no server is
> required for local development or the demo.

## Features

### Onboarding & authentication
- Guided flow: **Welcome → Role** (Individual / Freelancer / SME / Entrepreneur,
  plus a Women‑led path) **→ Goals** (with risk tolerance) **→ Link accounts**.
- Email/password **Login** and **Sign up** (with a demo account).

### Home (role‑aware)
- Five‑tab shell: **Home · Insights · Vault · Pay · Profile**.
- The Home tab renders a persona‑specific hero metric and modules
  (`IndividualHome`, `FreelancerHome`, `SMEHome`, `EntrepreneurHome`).

### Vault & goals
- Total saved across goals, per‑goal progress rings, create/edit goals, goal detail.

### Budgets
- Monthly category budgets with spend‑vs‑target and a progress indicator.

### Invoices
- Track client invoices, an "unpaid total" card, and mark‑as‑paid.

### Transfers & Pay
- Send money between linked accounts, saved payees, and transparent fee calculation.

### Pension
- Short‑term and long‑term pots, contributions, and a projected retirement value.

### Vendors & Bills
- Recurring vendors and bills tracking.

### Insights
- Spending‑breakdown **pie chart** (via `fl_chart`) and **CSV export**.

### Security & Profile
- Two‑factor toggle, profile management.

## Architecture

- **State management:** [Riverpod](https://riverpod.dev). Providers live in
  `lib/core/providers.dart`; state in `lib/core/state/*` (auth, money,
  onboarding, preferences).
- **Data layer:** a `FinovaultApi` abstraction with two implementations —
  `MockFinovaultApi` (in‑memory, the default) and `HttpFinovaultApi`
  (the BFF / REST contract). Swap them via provider overrides.
- **Persistence:** a `KvStore` interface backed by `shared_preferences`; a mock
  DB is hydrated on startup to seed demo data.
- **UI kit:** `lib/widgets/ui.dart` provides `FvButton`, `FvCard`, `FvTextField`,
  `MoneyText`, `ProgressRing`, and `FvContext` theme shortcuts. Brand tokens are
  in `lib/theme/tokens.dart`; themes (light + dark, brand‑primary blue) in
  `lib/theme/app_theme.dart`.
- **Design language:** brand‑primary blue text/accents on light surfaces, with a
  theme‑aware page background (`fvPageDecoration`) that switches to a dark navy
  gradient in dark mode.

## Getting started

Requirements: Flutter SDK `^3.13` and a device/emulator (iOS / Android / Web).

```bash
flutter pub get
flutter run
```

Demo login:

```
email:    demo@finovault.app
password: Vault123!
```

## Testing

```bash
flutter test
```

- `test/screens_test.dart` — smoke tests that pump **every** screen and assert
  there are no layout‑overflow or runtime errors.
- `test/onboarding_text_test.dart` — asserts that onboarding/auth text renders in
  the brand‑primary color (light mode) and that `RoleScreen` uses a theme‑aware
  background (dark mode).
- `test/helpers.dart` — shared pump / provider‑container helpers.

CI runs `flutter test` on every push (see `.github/workflows`).

## Project structure

```
lib/
  main.dart                 # entry, provider scope, RootGate (auth/onboarding routing)
  theme/                    # tokens + app_theme (light/dark)
  core/                     # models, providers, state, mock db, format, api
  widgets/                  # ui kit (FvButton, FvCard, FvTextField, MoneyText, ...)
  screens/
    welcome_screen.dart
    role_screen.dart         # onboarding role choice
    onboarding/             # goals, link_accounts
    auth/                   # login, signup
    home_shell.dart         # 5-tab shell + persona homes
    tabs/                   # vault, insights, pay, profile
    money/                  # budgets, invoices, transfer, pension, goals,
                            #   vendors, bills, security, transactions, accounts
test/                       # widget tests + helpers
```

## License

See the repository root.
