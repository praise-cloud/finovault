# feature/onboarding-branding

This branch contains the **onboarding / auth branding** work for the Finovault
Flutter app — fixing white/invisible text and applying the brand‑primary colour.

## What it is
On the early (pre‑auth) and onboarding screens, text was coloured white in dark
mode while some backgrounds stayed light, making it invisible. This branch makes
all such text render in the brand‑primary blue and ensures backgrounds are
theme‑aware.

## What was achieved
- `lib/widgets/ui.dart`: `fvText` / `fvTextSecondary` resolve to `FvColors.primary`
  in light mode, and `FvTextField` label, typed text, hint, and outline are
  brand‑primary in both modes.
- `RoleScreen`: background switched to the theme‑aware `fvPageDecoration` (dark
  navy gradient in dark mode) and all headings/descriptions/option labels set to
  brand‑primary.
- `GoalsScreen` / `LinkAccountsScreen`: headings and clickable option labels set
  to brand‑primary.
- `test/onboarding_text_test.dart`: asserts onboarding/auth text is brand‑primary
  in light mode and that `RoleScreen` uses a dark background in dark mode.

The complete app source is also present on this branch; this README focuses on
the branding work.
