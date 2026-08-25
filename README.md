# Feature: Full i18n (en / fr)

Adds internationalization to the Flutter app: a localization framework, a
language switcher, locale-aware currency formatting, and translated copy for the
primary screens.

## What this branch adds
- **Framework**: `flutter_localizations` + `intl`, configured via `l10n.yaml`
  with `flutter: generate: true`. Message catalogs live in `lib/l10n/`
  (`app_en.arb` template + `app_fr.arb`); `flutter gen-l10n` produces
  `AppLocalizations`.
- **Locale wiring**: `lib/main.dart` sets `MaterialApp.locale` from
  `preferencesProvider.language` and registers `AppLocalizations.delegate`
  (+ Material/Widgets/Cupertino delegates) and `supportedLocales`.
- **Language switcher**: the Profile → Settings sheet lets the user pick
  English / Français (`PreferencesController.setLanguage`); the choice persists
  and the whole UI re-localizes instantly.
- **Currency symbols**: `lib/core/format.dart` now maps currency codes to
  display symbols (e.g. `MUR` → `Rs`, `USD` → `$`, `EUR` → `€`) while keeping
  the existing `language`-aware grouping/decimal separators.
- **Translated copy**: welcome, role selection (incl. role labels), login,
  home navigation + greeting, the settings sheet, and the onboarding
  (goals/risk/link-accounts) and money-screen titles are now sourced from
  `AppLocalizations`.

## How to add a language / string
1. Add the key to `lib/l10n/app_en.arb` (and a translation in every other
   `app_*.arb`). Add an `@key` block for descriptions.
2. Run `flutter gen-l10n`.
3. Replace the literal with `AppLocalizations.of(context)!.key`.

## Verification
- `flutter analyze` — no errors.
- `flutter test` — all green (the test harness in `test/helpers.dart` now
  provides the localization delegates so `AppLocalizations.of(context)` resolves).
- Demo login (mock mode): `demo@finovault.app` / `Vault123!`. Switch language
  from Profile → Settings to see fr take effect.

## Coverage note
The catalog covers the primary user-facing flows (onboarding, auth, navigation,
greeting, settings, money titles). The deeper persona-home and tab internals
still contain some English literals; their strings can be externalized into the
ARB catalog incrementally following the steps above.
