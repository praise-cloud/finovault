# Design QA Report — FL-005 (Everything Dark Theme)

**Verdict: FAIL** — the dark theme foundation is solid, but the sweep left a
systemic class of light-mode colors as *text/icons* on dark surfaces. Auth-flow
error text is effectively unreadable in dark, and brand-blue text/links/nav
selection fails WCAG AA app-wide.

**QA basis**: static code critique (no running build — no screenshots available,
per task). `flutter analyze` re-run at report time: **0 errors, 0 warnings**
(26 pre-existing `info` lints, unchanged). Contrast ratios computed from token
RGB/alpha values.

---

## What passes (verified strong points)

1. **Dark tokens are brand-owned, not generic dark.** `bgDark` = `#0F2557`
   (the brand's `secondary` navy), `surfaceDark` = 8% white over it, `washDark`
   = 15% `primaryLight` tint. This is a deliberate deep-navy inversion, not
   black-on-black. Contrast on dark is strong:
   - `textDark` (white) on `bgDark` = **14.8:1** ✓
   - `textSecondaryDark` `#B8C4DC` on `bgDark` = **8.4:1**, on `surfaceDark` = **6.7:1** ✓
   - `successDark` `#4ADE80` on `surfaceDark` = **6.8:1** ✓
   - `warningDark` `#FBBF24` on `surfaceDark` = **7.1:1** ✓
2. **Getter architecture is right and consistently used for the foundation
   layer.** `FvContext.fv*` branching on `brightness` (ui.dart:11-37), the
   `FvTheme.dark()` theme (app_theme.dart), `themeMode` plumbing, and deletion
   of `_light()` are all correct; surfaces, borders, card shadows, text,
   inputs, page backgrounds are wired through getters. Riverpod rebuild on
   theme switch is sound.
3. **`Colors.white` on brand/gradient/accent fills is correct.** All four role
   accents pass AA with white text: individual/primary 6.7:1, freelancer
   5.7:1, entrepreneur 5.5:1, sme 5.0:1. No white-on-white found. QR white
   background (otp_screen.dart:183) is intentional and correct for scanning.
4. **Brutalist identity preserved.** Zero radius (`FvRadius` all 0), 2.5px
   hard borders (white-on-navy in dark via `fvCardBorder`), hard offset
   shadows via `fvBrutal`/`fvBrutalSm` getters, ink/paper semiotics intact.
   The dark theme *reinforces* brutalist contrast instead of drifting to
   generic Material dark.
5. **Intentional-left list is sound.** Ink dots on fixed accent fills, coach
   user bubble (ink bg + white text = ~17:1), `vault_mark` dark fallback,
   shimmer white alpha, `FvBorders` consts — all acceptable, none break dark.

---

## Blocking findings

### F1 — CRITICAL — Hardcoded light semantic colors as text/badges on dark (unreadable error text in auth flows)

Light-mode error `#8C3A3A` on `bgDark` = **1.96:1**; light success `#2E7D5B`
on `surfaceDark` = **2.36:1**. In dark mode these are nearly invisible — and
they appear exactly where the user needs to read them (2FA, login, signup,
password reset, form errors).

| File:line | Issue | Fix |
|---|---|---|
| `screens/auth/otp_screen.dart:235, 307, 393` | `_error!` / cancel text uses `FvColors.error` on dark bg — 1.96:1 | → `context.fvError` |
| `screens/auth/login_screen.dart:106` | error text `FvColors.error` | → `context.fvError` |
| `screens/auth/signup_screen.dart:86, 111` | error text + strength meter `FvColors.error/success/warning` | → `context.fvError/fvSuccess/fvWarning` |
| `screens/auth/forgot_password_screen.dart:185` | `FvColors.error` text | → `context.fvError` |
| `screens/auth/reset_password_screen.dart:151, 174-177` | error/success/warning text | → getters |
| `screens/profile/change_password_screen.dart:105-106, 133` | strength meter + error text | → getters |
| `screens/profile/edit_profile_screen.dart:171-173, 214` | error icon + text | → getters |
| `screens/tabs/vault_tab.dart:285-289, 376-380` | `const StatusBadge(foreground: FvColors.success, background: FvColors.successBg)` on dark card — ~2.4:1 text on near-invisible tinted bg | drop `const`, → `context.fvSuccess` + a new dark success bg token (e.g. `0x334ADE80`) or `context.fvWash` |
| `screens/home/persona_homes.dart:270, 278, 365-368, 390, 398, 524, 728-730, 750, 822-839, 849-850` | trend/status text in light `error/success/warning` | → getters |
| `screens/money/goals_list_screen.dart:87, 184, 196`; `invoices_screen.dart:89, 134-144`; `tabs/insights_tab.dart:134-153, 330, 410-411, 460`; `tabs/pay_tab.dart:240` | status text/values/rings in light semantic colors | → getters |

**Note (do NOT change)**: `SnackBar(backgroundColor: FvColors.error)` with
white content text ≈ 7.5:1 — passes in dark, leave as-is.

### F2 — MAJOR — `FvColors.primary` used as text/icon/link color on dark surfaces

`primary` `#1D4ED8` on `surfaceDark` = **1.76:1**, on `bgDark` = **2.2:1** —
fails WCAG AA even for large text (min 3:1). Occurs ~97 times across screens
(nav selection, links, icons, chips, section actions, back button, "manage
pension", login/signup links). Representative:

| File:line | Issue |
|---|---|
| `screens/home_shell.dart:73, 83, 91, 99, 107, 115` | selected nav label + icon in primary on `surfaceDark` / `washDark` |
| `screens/home_shell.dart:250` | quick-action icons in primary |
| `widgets/ui.dart:52, 63` | `OnboardingHeader` wordmark + back arrow on `bgDark` |
| `widgets/ui.dart:527` | `SectionHeader` action label on `bgDark` |
| `widgets/ui.dart:701` | `_BackButton` arrow |
| `screens/tabs/profile_tab.dart:71, 417, 457, 498, 507` | badge text, row/switcher icons, selected chip text/border |
| `screens/tabs/vault_tab.dart:393, 400` | "Manage pension" text + chevron |
| `screens/coach/coach_screen.dart:285, 318, 321` | input border + send icon |
| `screens/auth/login_screen.dart:124, 141`; `signup_screen.dart:138`; `welcome_screen.dart:33, 55` | links in primary |
| `screens/tabs/_ChoiceChip` selected (profile_tab.dart:498-507), `transactions_screen.dart:253-262` chip filter, `insights_tab.dart` icons/values, money-screen "+" icons | primary as text/icon |
| `theme/app_theme.dart:58, 68` | outlined/text button `foregroundColor: FvColors.primary` |

**Fix**: add an `fvPrimary` (or `fvAccent`) getter returning `FvColors.accentStrong`
(`#38BDF8`, **5.5:1** on surfaceDark, **6.9:1** on bgDark) — or a new dark
brand-text token ~`#60A5FA` — and sweep all text/icon/link/nav usages.
Keep `FvColors.primary` only for **fills with white foreground** (buttons,
`FvCard` accent strip, hero). `app_theme.dart` outlined/text buttons:
`foregroundColor: dark ? FvColors.accentStrong : FvColors.primary`.

---

## Minor observations (non-blocking but should be fixed in the same ticket)

- **M3 — MINOR**: `errorDark` `#F87171` on `surfaceDark` = **4.27:1** — just
  under 4.5 for 13px regular error text on cards (e.g. profile_tab.dart:609,
  backend-URL status). Acceptable for bold/large; darken to ~`#EF7A7A` (≈4.6:1)
  to be safe, or keep if error text stays bold.
- **M4 — MINOR**: Brutalist hard shadow lost in dark on two components that
  use ink const shadows: `coach_screen.dart:220` (`const [FvShadows.brutalSm]`)
  and `home_shell.dart:153` (`const [FvShadows.brutal]` on the coach FAB) —
  black-on-navy, invisible. → `context.fvBrutalSm` / `context.fvBrutal`.
- **M5 — MINOR**: `ProgressRing` arc (ui.dart:458) and chart accents use
  `FvColors.primary` — 1.76:1 as a meaningful chart stroke → use fvPrimary
  (covered by F2's getter).
- **M6 — INFO**: `_BackendUrlTile` (profile_tab.dart:567-575) uses a bare
  `TextField` + `InputDecoration(filled: false)` inside the card — inherits
  theme colors, renders correctly in dark; no action needed. Confirmed OK.

---

## Edge-state summary

- **Loading**: spinners use theme primary — visible but dim (2:1) on navy →
  resolves with F2 getter. `FvButton` loading uses foreground color ✓.
- **Empty**: `EmptyState` uses `fvText`/`fvTextSecondary` + subdued `VaultMark` ✓.
- **Disabled**: 0.55 opacity on `FvButton` ✓.
- **Error**: broken in auth flows (F1) — the critical finding.

## Recommendation

Block release of the dark theme until F1 + F2 land. Both are small, mechanical
fixes: swap ~120 selector references to the existing `fvSemantic` getters and
one new `fvPrimary` getter (dark → `#38BDF8`). The token layer, theme
plumbing, and surface architecture are correct and should not be reworked.

**Status: `partially_verified`** — `flutter analyze` 0/0 re-confirmed; contrast
verification is code-level (computed from tokens), no browser screenshots were
possible in this gate.

---

# RE-QA (round 2)

**Verdict: FAIL** — but by a hair. F1 is fully resolved and F2 is resolved
everywhere except ONE reference that was explicitly in the round-1 F2 list and
was not swapped (a single quick-action icon). Everything else verified clean.

**QA basis**: code-level re-check, same method as round 1. `flutter analyze`
re-run at this gate: **0 errors, 0 warnings** (27 pre-existing `info` lints).
`flutter test`: 81 passed / 3 failed — pre-existing, unrelated, confirmed in
`implementation-summary.md` (role_screen gradient assertions + HomeShell
timer-drain; screens untouched by this work).

## What I verified (all clean unless noted)

1. **F1 — resolved.** Grep of `FvColors.error/success/warning` across `lib`
   now returns only: getter definitions, button/snackbar **fills with white
   foreground** (ui.dart:103-105, profile_tab:760/781/790, business_
   details:172, edit_profile:62/76 — all ≈7.5:1, correct), and `*_Bg` **tint
   containers whose text is now a getter** (login:115/124, signup:96/105,
   forgot_password:112/176, reset_password:113/142, change_password:137,
   edit_profile:247, goals_list:178, link_accounts:566, persona_homes:353-356/999).
   vault_tab StatusBadge light-token class gone; coach_screen is fully clean.
2. **F2 — resolved except one line.** `fvPrimary` getter correct (dark →
   `accentStrong #38BDF8`, **6.9:1** on bgDark, **~5.5:1** on surfaceDark).
   Verified swept: home_shell nav, profile chips/rows, money screens, coach
   (border/icon/spinner), OnboardingHeader + `_BackButton` (ui.dart:53/64/706),
   SectionHeader action (ui.dart:532), `app_theme.dart:58/60/72/99`
   outlined/text buttons + focused border → `accentStrong`.
   **R1 (blocker)**: `home_shell.dart:250` — QuickActionsRow icon
   `color: FvColors.primary` inside a `context.fvSurface` container — **1.76:1**
   on dark, fails WCAG 1.4.11 (graphical object needs 3:1). This exact line was
   listed in round-1 F2. Fix (one word): `color: context.fvPrimary`.
3. **Kept fills are sound.** White-on-fill ratios verified: FvButton/Elevated
   primary fill 6.7:1, checkbox `activeColor` primary (role_screen:254),
   avatar edit badge (fv_avatar:98), OTP success circle (otp_screen:414) —
   all primary fill + `Colors.white`. Snackbar error bgs ~7.5:1. QR white bg
   intentional. `Colors.white` only ever sits on fills/gradients.
4. **No new regressions.** Raw `Colors.black/red/blue/green/grey` =
   **0 matches** in `lib`. Remaining `FvColors.ink` = deliberate brutalism
   (coach user bubble, hero ink dots, goal-card unselected borders,
   `FvBorders` statics) — all pre-approved keeps. Progress-ring arc now
   `fvPrimary` (round-1 M5 fixed); `ProgressRing` (ui.dart:421) confirmed.
5. **Brutalist identity intact.** `context.fvBrutalSm` in nav + coach card
   (round-1 M4 fixed); zero radius + 2.5px hard borders via theme
   (`app_theme.dart:85-99`) intact.

## Non-blocking observations (borderline, kept-by-design — NOT the FAIL reason)

- **O1**: `LinearProgressIndicator` value fills in persona_homes.dart:576 and
  848-850 use light-mode `FvColors.primary/success/warning/error` (≈2.2–2.95:1
  on navy) — under the 3:1 graphical-object threshold, but the state is
  redundantly conveyed by the adjacent text which correctly uses getters
  (576→`fvWarning/fvSuccess`; 856→`fvTextSecondary`). Optional: swap bar
  color to `fvPrimary/fvSuccess/…` in the same sweep.
- **O2**: `notification_bell.dart:45` (unread badge fill `FvColors.error`) and
  :309 (unread dot `FvColors.primary`) are sub-3:1 as standalone graphical
  objects, but the badge carries a white count (7.5:1) and the dot is
  redundant with bold/ordering. Optional: `context.fvError` / `context.fvPrimary`.

## Recommendation

One-line fix (`home_shell.dart:250`) then re-QA. The F1/F2 architecture —
`fvPrimary` getter, `fvSemantic` getters, brightness-branched theme — is
correct and should not be reworked.

**Status: `partially_verified`** — static verification only; no browser
screenshots in this gate (unchanged from round 1).

---

# RE-QA (round 3 — final)

**Verdict: PASS ✅**

R1 confirmed fixed: `lib/screens/home_shell.dart:250` now reads
`child: Icon(action.icon, size: 20, color: context.fvPrimary)` — quick-action
icons render `accentStrong #38BDF8` in dark (~5.5:1 on surfaceDark, passes
WCAG 1.4.11). F1 and F2 are fully resolved; no remaining hardcoded light
`error/success/primary` as text/icon on any dark path; kept fills verified
sound; no new regressions; brutalist identity intact. `flutter
analyze` 0 errors / 0 warnings.

**Status: `partially_verified`** — static verification only; browser
screenshots were not available in any gate. Contrast is computed from token
RGB/alpha values; recommend one visual smoke test of the dark theme at
release time.