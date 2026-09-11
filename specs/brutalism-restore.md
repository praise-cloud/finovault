# Brutalism Restoration — Implementation Spec

## Overview

This spec covers the **5 remaining fixes** needed after the brutalism tokens and theme were restored. The bulk of the restoration is already in place (`tokens.dart`, `app_theme.dart`, `ui.dart`, `components.dart`, screen-level hero cards). These are surgical fixes to achieve full consistency.

## Fix 1: Page & Onboarding Backgrounds → Cream

**File**: `lib/widgets/ui.dart`

### Current (broken)

```dart
BoxDecoration get fvPageDecoration => const BoxDecoration(color: Colors.white);
BoxDecoration get fvOnboardingDecoration => const BoxDecoration(color: Colors.white);
```

### Target

```dart
BoxDecoration get fvPageDecoration => const BoxDecoration(color: FvColors.bg);
BoxDecoration get fvOnboardingDecoration => const BoxDecoration(color: FvColors.bg);
```

**Impact**: Affects `HomeShell` body container (`home_shell.dart:44`) and all `_light()` wrapped screens in `main.dart`. The cream background will now show through instead of pure white.

**Risk**: None — `FvColors.bg` is already the scaffold default, this just makes the explicit decorations match.

---

## Fix 2: Navigation Bar Indicator → Rectangular

**File**: `lib/theme/app_theme.dart`

### Current (rounded — inconsistent with zero-radius system)

```dart
navigationBarTheme: NavigationBarThemeData(
  backgroundColor: FvColors.surface,
  indicatorColor: FvColors.wash,
  indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
),
```

### Target

```dart
navigationBarTheme: NavigationBarThemeData(
  backgroundColor: FvColors.surface,
  indicatorColor: FvColors.wash,
  indicatorShape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(FvRadius.card), // 0.0 = sharp
  ),
),
```

**Impact**: The selected tab indicator becomes a sharp rectangle instead of a rounded pill. This is the **only remaining rounded element** in the theme.

**Alternative**: If the rounded pill indicator is desired for contrast (the `FvRadius.pill` exception), keep `BorderRadius.circular(12)` and document it as an intentional exception. But for pure brutalism, use `FvRadius.card` (0.0).

---

## Fix 3: Dark Mode Input Borders → Thick Ink

**File**: `lib/theme/app_theme.dart`

### Current (dark mode has thin soft borders)

The current code already uses `FvColors.ink` for all input borders in both light and dark mode (lines 71–84). This was **already fixed** in the current `app_theme.dart`.

**Status**: ✅ No change needed — dark mode inputs already use `FvBorders.width` (2.5px) ink borders.

---

## Fix 4: Dark Mode Card Borders → Ink

**File**: `lib/theme/app_theme.dart`

### Current

```dart
cardTheme: CardThemeData(
  color: FvColors.surface,
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(FvRadius.card),
    side: const BorderSide(color: FvColors.ink, width: FvBorders.width),
  ),
),
```

### Analysis

The current `app_theme.dart` does NOT branch on `isDark` for card styling — it uses `FvColors.ink` for both modes. This is correct for brutalism: the thick ink border is the signature trait regardless of dark/light mode.

**Status**: ✅ No change needed — dark mode cards already use ink borders.

---

## Fix 5: Verify Screen-Level Usage

These screens already correctly use brutalist tokens and need **no changes**:

| Screen | File | Brutal tokens used |
|--------|------|--------------------|
| HeroCard | `persona_homes.dart:29-37` | `FvShadows.brutal`, `FvBorders.ink`, `FvRadius.card` |
| WealthCard | `vault_tab.dart:102-108` | `FvShadows.brutal`, `FvBorders.ink`, `FvRadius.card` |
| Coach FAB | `home_shell.dart:118-128` | `FvShadows.brutal`, `FvBorders.ink`, `FvRadius.card` |
| Role cards | `role_screen.dart:140,215` | `FvShadows.brutal` |
| Goal cards | `goals_screen.dart:150,191` | `FvShadows.brutalSm`, `FvShadows.brutal` |
| Account banner | `accounts_screen.dart:150` | `FvShadows.brutal` |
| Account detail | `account_detail_screen.dart:69` | `FvShadows.brutal` |
| Coach chat bubbles | `coach_screen.dart:186` | `FvShadows.brutalSm` |

---

## Summary of Changes

| # | File | Change | Lines |
|---|------|--------|-------|
| 1 | `lib/widgets/ui.dart` | `Colors.white` → `FvColors.bg` (2 places) | 20, 25 |
| 2 | `lib/theme/app_theme.dart` | `BorderRadius.circular(12)` → `BorderRadius.circular(FvRadius.card)` | 100 |
| **Total** | **2 files, 3 line changes** | | |

## What This Does NOT Touch

- `tokens.dart` — already correct
- `models.dart` — crash/schema fixes, out of scope
- Backend files — out of scope
- Screen-level components — already brutalist
- `FvCard`, `FvButton`, `FvTextField` — already brutalist
- Any new components or abstractions — not needed

## Dark Mode Decision

**Recommendation: Keep dual-mode (light + dark)**. The original brutalism design had `bgDark`, `surfaceDark`, `textDark`, `borderDark` variants and the current theme already wires them correctly. The dark mode should use the same zero-radius + hard shadow system but with the deep-blue surface palette. No changes needed for dark mode — it's already correct.

## Verification

After applying fixes 1–2:

1. `flutter analyze` — no errors
2. Visual check: scaffold backgrounds show cream (`#F3F1EA`) not white
3. Visual check: nav bar selected indicator is a sharp rectangle
4. All existing `FvShadows.brutal` / `FvBorders.ink` usages unchanged
5. Dark mode: cards still have ink borders, inputs still have 2.5px borders
