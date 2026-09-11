# FE-001 — Banking Features Implementation Summary

## Component / Scope
Four banking-phase features across auth + money screens:
1. **Phone field on signup** — new `FvTextField` (keyboardType `phone`), pattern
   validation, client + API error surfacing.
2. **Statement upload screen** — file picker (CSV/PDF), base64 payload, result
   screen with per-category rows, re-upload path.
3. **Payment handoff UI** — transfer screen "Pay via bank app" (deep link
   `mcbjuice://pay?...`) and "MauCAS QR" (bottom sheet with QR from
   `qr_flutter`) buttons.
4. **FSC regulatory copy** — footnote on signup: "financial coaching and
   budgeting insights — not regulated investment advice or asset portfolio
   management."

## Key Decisions
- Phone pattern `RegExp(r'^[5-7]\d{4,7}$')` (5–8 digits starting 5–7); client
  errors `'Phone must be 5–8 digits starting with 5–7.'`. Phone is **validated
  but not stored** — `UserProfile` has no `phone` field.
- `AuthController.signup` is now positional 4-arg
  `signup(fullName, email, password, phone)` and forward `phone:` to
  `_api.signup`. Signup screen has no `setError` on controller — uses local
  `_localError` joined with `auth.error` (email_taken).
- Statement upload validates file type (`'csv'|'pdf'`, mime from extension),
  non-empty file, account existence; `UploadStatementResult` invalides
  `accountsProvider` + `transactionsProvider` after success.
- Deep link `mcbjuice://pay?amount=<2dp>&recipient=<encoded>&account=<id>`,
  launched via `url_launcher` with `canLaunch` guard → SnackBar fallback.
- MauCAS QR data `MAUCAS:PAY:<2dp>:<encoded recipient>` rendered in bottom
  sheet (no `dataModuleStyle`; rely on white QR canvas from FL-005).
- Hardcoded strings (matches existing app convention, no l10n); existing
  `FvButton`/`FvTextField`/`EmptyState`/`ScreenPage` from `widgets/ui.dart`.

## State / API Handling
- Core/domain layer extended: `FinovaultApi` (abstract) + mock +
  `HttpFinovaultApi` all implement `signup(..., phone)` plus three new RPC
  methods `uploadStatement`, `generatePaymentLink`, `generateMauCasQr` — same
  `POST /rpc` transport, `Result.fromJson` envelope parsing.
- New models in `lib/core/models.dart`: `StatementUploadResult`,
  `PaymentLinkResult`, `MauCasQrResult`.
- BFF contract files unchanged
  (`finovault-bff/specs/api-contract.md`, `banking-contract.md`).

## Files Modified / Created
- Created: `lib/screens/money/statement_upload_screen.dart`
- Modified: `lib/screens/auth/signup_screen.dart` (phone + FSC footnote),
  `lib/screens/money/transfer_screen.dart` (handoff buttons + handlers),
  `lib/screens/money/accounts_screen.dart` ("Upload statement" entry),
  `lib/core/state/auth.dart`, `lib/core/mock/api.dart`,
  `lib/core/mock/http_api.dart`, `lib/core/models.dart`, `pubspec.yaml`
  (deps pre-added: `qr_flutter`, `url_launcher`, `file_picker`)
- Tests updated for phone param: `test/auth_test.dart`,
  `test/two_factor_test.dart`, `test/bff_smoke_test.dart`,
  `test/account_security_test.dart`

## Verification
- `flutter analyze`: **0 errors, 0 warnings**; info-level only — 22 pre-existing
  `curly_braces_in_flow_control_structures`, 3 `unnecessary_string_interpolations`
  in `test/two_factor_test.dart` (out of scope).
- `flutter test`: **84 passed** (incl. updated auth/two_factor/account_security/
  bff_smoke tests).
- No `print()`/`debugPrint` introduced.

## QA Notes
- Signup: phone field appears between email and password; error text shows
  under fields via `_localError`.
- Transfer: "Pay via bank app" + "MauCAS QR" are the last two actions in the
  action list; QR sheet shows amount + recipient + QR canvas; no asset images —
  pure QR rendering.
- Statement upload: picker errors surface as SnackBar; success screen offers
  "Upload another".

---

# FL-005 — Dark Theme Implementation Summary

## Component / Scope
Full dark-mode support across the Finovault Flutter app. Brightness-aware theme in
`app_theme.dart`, context getters in `widgets/ui.dart`, and a sweep of every
hardcoded light-mode `FvColors.*` / `Colors.white` reference to the new getters.

## Key Decisions
- `FvContext` extension exposes `fvText`, `fvTextSecondary`, `fvSurface`,
  `fvBorder`, `fvCardBorder`, `fvWash` — each branches light/dark via
  `fvIsDark` (from `Theme.of(context).brightness`).
- New dark palette tokens only in `theme/tokens.dart`: `washDark`
  `0x263B82F6`, `successDark 0xFF4ADE80`, `warningDark 0xFFFBBF24`,
  `errorDark 0xFFF87171`, `surfaceDark` (8% translucent white on `bgDark`),
  `textSecondaryDark 0xFFB0B7C3`, `borderDark`, `textDark`.
- `main.dart` `_light()` wrapper deleted — app now uses `themeMode` directly
  (light/dark/system).
- `Colors.white` kept as text/icon **on brand/gradient/primary/accent fills**
  (vault hero, OTP QR bg + check, persona hero, gradient cards) — correct in dark.
- Fixed accent-hero ink dots/borders (account_detail:95, vault_tab:147,
  persona_homes:44/66) left as-is.
- Coach screen: user chat bubble stays black (`FvColors.ink`) for contrast;
  bot bubble uses `context.fvSurface`. All borders/text ink → context getters.
- `vault_mark.dart` top-level fn (no BuildContext) left with `textSecondaryDark`
  fallback — works in dark, fine in light.

## State / Theme Handling
- Riverpod `themeMode` from `preferencesProvider` drives MaterialApp `themeMode`.
- All UI consumes `context.fv*` getters — no rebuild needed on switch; Material
  rebuilds on theme change.
- `FvButton`/`FvCard`/`FvTextField` in `ui.dart` re-wired to getters.

## Files Modified
- `lib/theme/tokens.dart`, `lib/theme/app_theme.dart`, `lib/widgets/ui.dart`,
  `lib/main.dart`
- `lib/widgets/`: `notification_bell.dart`, `components.dart`, `fv_avatar.dart`
- `lib/screens/home_shell.dart`, `lib/screens/home/persona_homes.dart`
- `lib/screens/tabs/`: `vault_tab.dart`, `pay_tab.dart`, `profile_tab.dart`,
  `insights_tab.dart`
- `lib/screens/money/`: `accounts`/`account_detail`/`bills`/`budgets`/
  `goals_list`/`invoices`/`pension`/`transactions`/`vendors`/`transfer`/
  `security` screens
- `lib/screens/coach/coach_screen.dart`
- `lib/screens/auth/`: `forgot_password`, `reset_password`, `otp` screens
- `lib/screens/role_screen.dart`
- `lib/screens/onboarding/link_accounts_screen.dart`
- `tool/gen_icon.dart` (removed 1 unused var)

## Verification
- `flutter analyze`: **0 errors, 0 warnings** (26 pre-existing info lints —
  `curly_braces_in_flow_control_structures`, test string interpolation — left
  untouched per scope)
- No `print()`/`debugPrint` in changed files (3 pre-existing in mock/notification
  infra, out of scope)
- Intentionally light/left: decorative ink dots on fixed accent fills, coach
  user bubble, `vault_mark` top-level fn, shimmer white alpha, `FvBorders`
  static consts (brutalist token — see `tokens.dart:171/173`)

## QA Follow-up (designer round 2)

Follow-up sweep for QA polish pass (F1/F2 findings, coach M4 shadow):

### New token
- `fvPrimary` context getter in `widgets/ui.dart`: `accent` in light, new
  `FvColors.accentStrong 0xFF38BDF8` in dark — for primary **text / icons /
  links / nav / badges** (not fills).

### Surface swaps (text / icons / links / badges → context getters)
- All 4 tabs: profile (Free badge, danger row icon, switch thumb+icon, chip
  border/text), vault (Done/Auto status badges, manage-pension text+chevron),
  insights (psych icon, category value colors, all `_InsightRow` colors, tips
  icon), pay (send/receipt/schedule icons, scheduled badge, payee avatar
  initial, completed check → fvSuccess).
- Home shell nav (active icon/label `fvPrimary`, shadow → `fvBrutal`).
- Money screens: accounts, account_detail (focused border), bills, budgets,
  goals_list (Done badge), invoices (`_invoiceRow` → `switch` on status:
  overdue→fvError, paid→fvSuccess, sent/draft→fvWarning; badge bg → fvWash;
  check icon → fvSuccess), pension, pension_setup (switch thumb), security,
  transactions (add icon, chip border/text, `color ?? fvPrimary`), vendors.
- persona_homes: trend arrow, runway text, `_ForecastItem` colors, vendors
  error text, compliance dots, both `statusColor`s, pre-seed badge fg,
  primary icons/text → `fvPrimary`.
- Onboarding: link_accounts (type chip fg, focused/error border, linked icon+
  text+StatusBadge), transfer receipt success avatar (bg fvWash + icon
  fvSuccess, const dropped).

### Status badge pattern
`const` dropped; bg → `context.fvWash`; fg → dark getter (no `fv*Bg` getters
exist).

### Minor fixes
- M4 shadow done: bottom nav + coach card use `context.fvBrutalSm` (list, now
  single list value — one intermediate wrong edit caught & fixed).
- coach input border/send icon/spinner → `fvPrimary`.
- Invoices: transient `If` typo caught & fixed; `_add` re-wired to header
  button; link_accounts edit had zero leftovers.

### Deliberately kept (fills / tints / progress)
- `successBg/errorBg/warningBg` tint containers: profile/vault/invoices
  badges, transfer linked row (L566), persona_homes runway L353-356, pre-seed
  badge L999, diary entry header.
- Progress/fill colors (persona_homes L576/L849-850/L1271, budgets overage),
  legend/status dots, FvCard accent strips, button fills, `FvColors.primary`
  active states (link_accounts radio L324, persona_homes legend L1153),
  `primaryBorder` (link_accounts L473), snackbar `FvColors.error` bgs,
  `Colors.white` QR bg.
- M3 token (errorDark) not changed; fvError luminance high enough — verified
  via UI spot-check, no designer blockers hit it again.

## Verification (final)
- `flutter analyze`: **0 errors, 0 warnings**; 27 pre-existing info lints
  (curly braces, string interpolation, test files) — out of scope.
- `flutter test`: 81 passed; 3 pre-existing failures unrelated to this work —
  `role_screen` background-gradient assertions (screen untouched) and
  HomeShell pending-timer assertion (`NotificationsController` 15s polling
  timer never drained). All money/tab/coach tests pass.
- No `print()`/`debugPrint` introduced.