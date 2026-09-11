# Finovault Design System — Neo-Brutalist

## Design Direction

Restored neo-brutalist aesthetic: **high-contrast, thick hard borders, zero-radius corners, hard offset shadows with zero blur, warm cream background, ink-black text**. The app was originally designed this way (pre-`437ea5f`), then accidentally overwritten with a white/blue theme. This document captures the restored system.

## Color Palette

### Surface & Background

| Token | Hex | Usage |
|-------|-----|-------|
| `FvColors.bg` | `#F3F1EA` | Scaffold background (warm cream) |
| `FvColors.surface` | `#FFFFFF` | Card/input backgrounds (pure white) |
| `FvColors.ink` | `#0A0A0A` | Text, borders, hard shadows |
| `FvColors.textSecondary` | `#43474D` | Secondary/body text |

### Brand

| Token | Hex | Usage |
|-------|-----|-------|
| `FvColors.primary` | `#1D4ED8` | Buttons, focused inputs, links, nav icons |
| `FvColors.secondary` | `#0F2557` | Hero card gradient start, deep accent |
| `FvColors.wash` | `#EFF6FF` | Nav bar selected indicator bg |

### Dark Mode (dual-mode preserved)

| Token | Hex | Usage |
|-------|-----|-------|
| `FvColors.bgDark` | `#0F2557` | Dark scaffold bg |
| `FvColors.surfaceDark` | `#14FFFFFF` | Dark card bg (8% white) |
| `FvColors.textDark` | `#FFFFFF` | Dark mode text |
| `FvColors.borderDark` | `#26FFFFFF` | Dark mode borders (15% white) |

Dark mode keeps the same brutalism shape language (zero radii, hard shadows) but swaps the palette to the deep-blue surface scheme.

## Typography

- **Font family**: `Montserrat` (loaded via `app_theme.dart`)
- **Headings**: `w700`–`w800`, uppercase with `letterSpacing: 0.3–0.6` for brutalist emphasis
- **Body**: `w600` at 14–15px
- **Labels/small**: `w700–w800` uppercase at 10.5–13px

## Shape System

| Token | Value | Rationale |
|-------|-------|-----------|
| `FvRadius.card` | `0.0` | Sharp rectangular cards |
| `FvRadius.button` | `0.0` | Sharp rectangular buttons |
| `FvRadius.input` | `0.0` | Sharp rectangular inputs |
| `FvRadius.badge` | `0.0` | Sharp rectangles (except `pill = 999` for status badges) |
| `FvRadius.iconContainer` | `0.0` | Sharp icon squares |

**Exception**: `FvRadius.pill = 999.0` — used only for `StatusBadge` (rounded pill shape is deliberate for status indicators).

## Border System

| Token | Width | Color | Usage |
|-------|-------|-------|-------|
| `FvBorders.width` | `2.5px` | — | Global border width |
| `FvBorders.ink` | 2.5px | `ink` | Cards, inputs, buttons, sections |
| `FvBorders.primary` | 2.5px | `primary` | Primary-colored borders |

All borders are **hard, visible, 2.5px** — the signature brutalist trait.

## Shadow System

| Token | Offset | Blur | Color | Usage |
|-------|--------|------|-------|-------|
| `FvShadows.brutal` | `Offset(5, 5)` | `0` | `#0A0A0A` | Cards, hero cards, FAB, role cards |
| `FvShadows.brutalSm` | `Offset(3, 3)` | `0` | `#0A0A0A` | Buttons, chips, small cards |
| `FvShadows.brutalDark` | `Offset(5, 5)` | `0` | `#000000` | Dark mode brutal shadows |

Shadows are **solid, no blur** — the defining neo-brutalist trait. `FvShadows.card` (blur:24) exists but is legacy — **never use for new components**.

## Component Architecture

### Core Components (all in `lib/widgets/ui.dart`)

| Component | Border | Shadow | Radius | Notes |
|-----------|--------|--------|--------|-------|
| `FvCard` | `ink` 2.5px | `brutal` (5,5) | `0` | Accent strip optional (4px top) |
| `FvButton` | `ink` 2.5px | `brutalSm` (3,3) | `0` | 5 variants: primary/secondary/ghost/danger/success |
| `FvTextField` | `ink` 2.5px (focus: `primary`) | None | `0` | Filled white, thick borders |
| `SectionHeader` | Bottom: `primary@25%` 2px | None | — | Blue bar accent + uppercase title |

### Domain Components (in `lib/widgets/components.dart`)

| Component | Border | Shadow | Radius | Notes |
|-----------|--------|--------|--------|-------|
| `FvAccountTile` | via `FvCard` | via `FvCard` | `0` | Inherits card styling |
| `FvTransactionRow` | None | None | — | Separated by spacing, no card |
| `FvActionCard` | via `FvCard` | via `FvCard` | `0` | Module shortcut cards |
| `FvStatCard` | via parent | None | — | Standalone column, blue bar accent |
| `FvCategoryChip` | `ink` 1.5px | None | `pill` | Category pills |

### Hero Cards (in screens)

All hero cards follow the same pattern:
- Solid `accent` color background (role-specific via `FvColors.roleAccent`)
- `FvBorders.ink` 2.5px border
- `FvShadows.brutal` 5,5 offset
- White text on colored background
- Subtle `VaultMark` watermark at 16% opacity

## Screen Background Strategy

| Screen Type | Background | Token |
|-------------|-----------|-------|
| Main app (authenticated) | `Colors.white` via `fvPageDecoration` | Should be `FvColors.bg` (cream) |
| Onboarding / auth | `Colors.white` via `fvOnboardingDecoration` | Should be `FvColors.bg` (cream) |
| Scaffold default | `FvColors.bg` (`#F3F1EA`) | ✓ Already correct |

## Issues Found (Post-Restoration Audit)

1. **`FvContext.fvPageDecoration`** — hardcoded `Colors.white` → should be `FvColors.bg`
2. **`FvContext.fvOnboardingDecoration`** — hardcoded `Colors.white` → should be `FvColors.bg`
3. **Navigation bar indicator** — `BorderRadius.circular(12)` is the only rounded element → should be `BorderRadius.zero` or `BorderRadius.circular(4)` for brutalist consistency
4. **Dark mode input borders** — no thick ink border in dark mode (uses soft `borderDark` instead of `ink`)

## What NOT to Change

- Token values in `tokens.dart` — they are already correct
- `FvCard`, `FvButton`, `FvTextField` widget implementations — already brutalist
- Screen-level hero cards — already use `FvShadows.brutal` + `FvBorders.ink`
- `FvRadius.pill = 999` — keep for status badges (deliberate contrast)
- Crash/schema fixes in `models.dart` and backend — completely out of scope
