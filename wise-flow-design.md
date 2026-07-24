# Finovault × Wise-Style UX — Frontend Build Specification
### How to translate Wise's clean, functional flow into Finovault's vault/gold identity

> **Relationship to the main design system**: This document does not replace `finovault-design-system.md` — it **overrides the layout, density, and interaction patterns** in that file with a simpler, Wise-inspired approach, while keeping Finovault's brand tokens (colors, logo, name) from that file intact. Where the two documents conflict on *flow and layout*, follow this one. Where they discuss *brand assets* (logo, palette, tone), the original document still governs.

---

## 1. What We're Borrowing From Wise (and Why)

Wise's interface works because it is **radically simple, fast, and legible** — not because of decoration. The screenshots show a consistent set of principles we are adopting wholesale:

1. **One accent color, used sparingly and functionally.** Wise's green appears almost only on primary buttons, positive amounts, and small status badges — never as a background wash. We will do the same with **Gold**.
2. **Light, airy, mostly-white canvas.** Backgrounds are white/off-white. Dark (near-black) is reserved for text and a few high-contrast elements, not for full-screen backgrounds. This is a **reversal** from the earlier "dark vault" direction — Finovault should now read as a **light, clean, premium app**, with Navy used as an ink color and structural accent, not as wallpaper.
3. **Bold, condensed, statement-style headlines** for onboarding/marketing moments ("ONE ACCOUNT FOR ALL THE MONEY IN THE WORLD") — big, tight line-height, all caps, punchy.
4. **Flat iconography, no skeuomorphism.** Icons are simple black line/flat glyphs — no gradients, no glass, no metallic shading. This applies to in-app icons; our ornate gold vault-door illustration is reserved for splash/marketing only (see Section 4).
5. **Pill-shaped buttons and chips everywhere** for actions and filters — a real departure from the previous "banking-radius" 12px button guidance. Wise uses full or near-full pill radii for buttons, tags, and filter chips.
6. **Card-based grouping with minimal chrome** — thin borders or subtle shadows only, no heavy glassmorphism.
7. **Functional, plain-spoken microcopy** — "Money added," "We pay out your SGD," "Sent," "Moved" — short, literal, present-tense status labels.
8. **A visible status timeline** for anything in-progress (transfers, transactions) — checkmarks, connecting line, timestamps, current step highlighted, future steps greyed out.
9. **Search-first, filter-chip list screens** for anything resembling a transaction/activity list.
10. **Minimal bottom navigation** — 4–5 items, simple black/ink icons, label beneath, no heavy active-pill background — just a bold vs. regular icon/label weight difference.

---

## 2. Brand Palette, Reapplied to This Flow

Same tokens as the core brand — **repurposed for a light, Wise-style canvas**:

| Role in Wise's UI | Wise's color | Finovault equivalent | Token |
|---|---|---|---|
| Primary accent (buttons, positive amounts, active badges) | Bright green | **Gold** `#D4AF37` | `--color-accent` |
| Primary text / icons | Near-black | **Deep Navy** `#08142E` (or `#1A1A1A` charcoal for body copy) | `--color-text` |
| Background | White | **Off White** `#F7F9FC` / White `#FFFFFF` | `--color-bg` |
| Secondary buttons / neutral chips | Light grey pill | Off-white / very light navy-tinted grey `#EEF0F5` | `--color-chip-bg` |
| Destructive action (e.g. "Cancel transfer") | Soft pink bg, red text | Soft garnet-tinted bg `#F6E7E7`, garnet text `#8C3A3A` | `--color-error-bg` / `--color-error` |
| Positive amount / success badge | Green | Muted emerald `#2E7D5B` for status text, **Gold** for the actual currency amount (Finovault's money numerals stay gold — this is our one deliberate divergence from Wise, since gold-as-numeral is core to Finovault's identity) | `--color-success`, `--color-accent` |
| Splash background | Bright green | **Deep Navy** `#08142E` (splash is the one screen allowed to be a bold brand-color field, matching the reference) | `--color-secondary` |

**Rule of thumb**: if you're unsure whether something should be gold, ask "would Wise make this green?" — if yes, make it gold; if it's a structural/ink element, make it navy or charcoal; the canvas itself stays light.

---

## 3. Typography Adaptation

Wise's headline type is a **bold, tight, condensed grotesk** — this does not match Cinzel (a classical serif), so we adapt as follows:

- **Cinzel Bold is retained only for the wordmark "FINOVAULT" itself** (logo lockups, splash, app store icon) — it is not used for in-app headlines anymore under this flow direction.
- **In-app statement headlines** (onboarding screens, empty states, big screen titles) switch to **Montserrat ExtraBold**, set large (32–44px), tight line-height (1.05–1.1), often in sentence case rather than Wise's all-caps (all-caps reads more "shouty startup," Finovault should feel confident but not loud — use sentence case: e.g. *"One vault for all your money"*).
- **Body/UI text**: Montserrat, as before — Regular/Medium/SemiBold across body, captions, buttons.
- **Numerals** (balances, amounts): Montserrat Bold/ExtraBold in **Gold**, not Cinzel — cleaner, more legible at a glance, matching Wise's crisp numeral treatment while keeping our brand color.

| Role | Size | Font | Weight | Color |
|---|---|---|---|---|
| Onboarding statement | 32–44px | Montserrat | ExtraBold | Navy/Charcoal |
| Screen title (H2) | 22–26px | Montserrat | Bold | Navy/Charcoal |
| Card title (H3) | 17–19px | Montserrat | SemiBold | Navy/Charcoal |
| Body | 15–16px | Montserrat | Regular | Charcoal |
| Caption/metadata | 13–14px | Montserrat | Regular/Medium | Muted grey-navy |
| Button label | 16px | Montserrat | SemiBold | Navy (on gold) / White (on navy) |
| Balance numeral | 34–40px | Montserrat | ExtraBold | Gold |
| Transaction amount | 15–16px | Montserrat | Bold | Gold (credit) / Charcoal (debit) |

---

## 4. Logo Usage in This Flow

- **Splash screen**: full-bleed **Deep Navy** background, the flat/simplified monogram (V + vault wheel + keyhole, no rivets/hinge/dial detail) centered, small and confident — mirroring how Wise's splash is just a flat mark on a solid color field, not an illustration.
- **In-app**: use only the **flattened, single-color monogram** (gold or navy line version) at small sizes in headers/nav — never the full ornate 3D vault-door illustration inside the product itself. The ornate version is reserved for marketing pages, onboarding illustration accents, and the app store icon only.
- **Onboarding illustration**: replace the literal 3D vault-door render with a **simpler flat/line illustration** in the onboarding carousel — e.g., a minimal line-art vault wheel with a small upward growth arrow or coin motif, in gold on white, echoing Wise's simple 3D-ish but flat-colored globe/coins illustration. Keep it to 1–2 colors (gold + navy), not a photorealistic gold-metal render.

---

## 5. Screen-by-Screen Flow (Wise-Mapped)

### 5.1 Splash
- Full-bleed **Deep Navy** background (matches Wise's bold single-color splash).
- Flat gold monogram centered, no animation needed beyond a quick fade/scale-in (~400–600ms) — Wise's splash is instantaneous, not a mini-movie. (This tones down the earlier "vault door opening" splash animation — keep that longer sequence, if used at all, for first-ever app open only, not every launch.)

### 5.2 Onboarding
- White/off-white background.
- One large, simple illustration per slide (flat gold/navy line art — coins, a vault wheel, a growth chart), roughly upper 40% of the screen, generous whitespace around it.
- Bold statement headline beneath in Montserrat ExtraBold, sentence case, e.g. *"One vault for all your money."*
- Two pill buttons at the bottom: **primary gold pill "Log in"**, **secondary light-grey/outline pill "Register"** — stacked or side-by-side, full pill radius (999px), matching Wise exactly.
- Optional third option: a **navy or black full-width pill** "Continue with Apple" style button beneath, if biometric/social auth is supported — mirrors Wise's black "Sign in with Apple" button (use Navy instead of pure black to stay on-brand).
- Small thin progress/scroll indicator bar at the very top (like Wise's thin top bar), not dots.

### 5.3 Home / Dashboard
- White/off-white background throughout — **this replaces the dark-navy dashboard background from the core design system.**
- Top row: small circular avatar/profile chip on the left with a status dot, a **gold pill badge** on the right for a promo/incentive (e.g. "Earn MUR 100") with a small chevron — directly mirrors Wise's top badge pattern.
- Screen headline: *"Welcome to [Name]"* in Montserrat Bold, with a small icon (e.g. a subtle gold sparkle/graph icon) beside it — not a giant balance number here; keep this line small and warm.
- **Action pill row** directly beneath: 3 pills — first one **filled gold** (primary action, e.g. "Send"), the rest **light grey/outline pills** ("Add money", "Request") — exactly matching Wise's Send/Add money/Request row.
- **Balance card**: a clean bordered card (thin 1px border, subtle shadow, white fill, generous padding) showing a small flag/currency icon + currency code top-left, account/reference number in small muted text, and the **big bold gold balance numeral** beneath. No glassmorphism here — flat white card with a thin border, exactly like Wise's account card.
- **Transactions section**: header "Transactions" (Montserrat Bold) with a "See all" link in gold, right-aligned. List rows beneath: circular icon chip on the left (flat gold-line icon on light-grey circle), label + date stacked in the middle, bold amount right-aligned (gold with `+` for credit, charcoal for debit).
- **Promo/feature banner card**: an optional dismissible card (rounded image/illustration + short copy + small "×" close in the corner) beneath transactions — mirrors Wise's "Introducing Interest" banner. Use this slot for Finovault feature announcements (e.g. AI insights, new savings goal types).
- **Bottom tab bar**: white background, thin top border/shadow separating it from content, 4–5 simple flat-line icons in navy (inactive) / gold (active), label beneath each in small Montserrat Medium, **bold weight on the active label** rather than a filled pill background — matches Wise's minimal tab treatment exactly (a clear step back from the earlier "glow/dot" tab spec).

### 5.4 Transfer / Transaction Status (Timeline Screen)
- White background, back arrow top-left, optional help "?" and "…" menu icons top-right.
- Centered **circular icon** (plus/arrow/lock depending on action) above a short label ("Adding") and a **large bold gold numeral** for the amount, currency code beneath in muted grey.
- A **secondary pill button** directly under the amount for a relevant quick action (e.g. "Money added", "Add note") — light grey/outline pill, small, centered.
- **Segmented control** ("Updates" / "Details") — two-tab horizontal switcher, active tab in bold navy text with a bottom indicator bar (gold), inactive tab in muted grey. Flat, no card background behind the whole control — just a thin bottom rule.
- **Status timeline** below: vertical line connecting steps, each step a small circle —
  - **Completed steps**: filled **gold or emerald** circle with a checkmark, timestamp + description in charcoal.
  - **Current step**: a solid gold/emerald dot (no check yet), description in bold navy.
  - **Future steps**: hollow grey circle, description in muted grey, no timestamp yet.
  - This is a direct, faithful port of Wise's timeline pattern — it should become Finovault's standard component for **any** in-progress process (transfers, KYC verification, loan applications, goal funding).
- **Destructive action** at the bottom if applicable (e.g. "Cancel transfer"): full-width pill button, **soft garnet-tinted background** with **garnet text** — not solid red, matching Wise's soft pink/red treatment exactly, just recolored to the brand's garnet.

### 5.5 Activity / Transaction List with Search & Filters
- Back arrow, small title/icon top bar, a small analytics/chart icon top-right (optional).
- **Search bar** directly beneath the header: light-grey rounded field with a search icon and placeholder text ("Search transactions…").
- **Filter chip row** beneath the search bar, horizontally scrollable: pill chips like "Includes hidden", "Type", "Balance", "Direction" — each a light-grey outline pill with small text, tap to open a filter sheet. Selected filters get a **gold border/fill** to indicate active state.
- **Grouped list by date**: a muted grey date header (e.g. "Mar 21, 2025") followed by rows — each row: small circular icon (direction arrow, flat line icon) + transaction label + short status word (Moved / Sent / Added) in muted grey beneath the label, amount bold right-aligned (gold `+` for incoming, charcoal for outgoing/neutral).
- This list pattern is the standard for **all** activity lists in the app (Vault holdings history, Pay history, Insights-triggered actions) — reuse the same row component everywhere rather than styling each list differently.

---

## 6. Components (Updated for This Flow)

**Buttons**
- **Primary**: full pill radius (999px), Gold fill, Navy text, Montserrat SemiBold. This replaces the earlier 10–14px "banking radius" guidance — Wise's full-pill shape is the new standard for this flow direction.
- **Secondary**: full pill radius, light grey/off-white fill (`#EEF0F5`), Navy or charcoal text, no border needed (Wise mostly uses filled light-grey secondary buttons, not outlines).
- **Destructive**: full pill radius, soft garnet-tinted background (`#F6E7E7`), garnet text (`#8C3A3A`).
- **Tertiary/link-style**: no background, gold text, used for "See all", "Cancel", inline links.

**Chips / Filters**
- Pill-shaped, light-grey fill or outline at rest; gold outline or gold fill (with navy text) when active/selected.

**Cards**
- Flat white/off-white fill, thin 1px border in a very light grey (`#E4E7EE`) or subtle soft shadow (`0 2px 12px rgba(8,20,46,0.06)`) — **glassmorphism is dropped in this flow direction**. Corner radius 16–20px (slightly more rounded than the earlier 12–16px spec, matching Wise's soft card corners).

**Icons**
- Flat, single-weight line icons (1.5–2px stroke), navy by default, gold when representing an active/primary/positive element. No gradients, no metallic shading, no glass — this applies everywhere except the splash/marketing vault-door illustration.

**Status Timeline** (new standard component, Section 5.4)
- Vertical connecting line, circular step markers (filled/checked, filled/current, hollow/future), timestamp + label per step.

**List Row** (new standard component, Section 5.3 & 5.5)
- Leading icon chip (circle, light-grey bg, flat icon) → label + secondary line (date/status) → trailing bold amount, right-aligned.

---

## 7. Design Tokens — Updated for the Wise-Style Flow

```css
:root {
  /* Backgrounds — light, airy canvas is now the default everywhere except splash */
  --color-bg: #F7F9FC;
  --color-surface: #FFFFFF;
  --color-surface-border: #E4E7EE;
  --color-chip-bg: #EEF0F5;

  /* Ink */
  --color-text: #1A1A1A;
  --color-text-secondary: #6B6F76;
  --color-navy: #08142E;
  --color-navy-strong: #0A1F5C;

  /* Accent (Wise-green role → Gold) */
  --color-accent: #D4AF37;
  --color-accent-light: #F4D35E;

  /* Semantic */
  --color-success: #2E7D5B;
  --color-warning: #C99A2E;
  --color-error: #8C3A3A;
  --color-error-bg: #F6E7E7;

  /* Splash-only bold field */
  --color-splash-bg: #08142E;

  /* Typography */
  --font-display: 'Montserrat', sans-serif; /* in-app headlines — NOT Cinzel */
  --font-logo: 'Cinzel', serif;              /* wordmark/logo only */
  --font-body: 'Montserrat', sans-serif;

  --fs-onboarding-statement: 38px;
  --fs-h2: 24px;
  --fs-h3: 18px;
  --fs-body: 16px;
  --fs-caption: 14px;
  --fs-button: 16px;
  --fs-balance: 36px;

  --line-height-tight: 1.08;
  --line-height-default: 1.5;

  /* Radius — pill-first system */
  --radius-pill: 999px;   /* buttons, chips, badges */
  --radius-card: 18px;    /* cards */
  --radius-input: 14px;   /* search bars, text fields */

  /* Elevation */
  --shadow-card: 0 2px 12px rgba(8, 20, 46, 0.06);
}
```

---

## 8. What Changes vs. the Original (Dark-Vault) Design System — Read This Before Building

If your agent already scaffolded screens from `finovault-design-system.md`, apply these corrections:

| Was (dark vault direction) | Now (Wise-flow direction) |
|---|---|
| Dark navy background on every screen | **Light off-white/white background** everywhere except splash |
| Heavy glassmorphic cards | **Flat white cards, thin border or soft shadow** |
| Cinzel used for in-app headlines and balances | Cinzel **only** for the logo wordmark; Montserrat ExtraBold for headlines, Montserrat Bold for balances (still gold) |
| Buttons at 10–14px radius | **Full pill radius (999px)** buttons and chips |
| Gold-bordered glass tab bar with glow | **Flat white tab bar**, thin top border, bold vs. regular label weight for active/inactive |
| Ornate 3D vault-door used throughout the app | Ornate version **only** on splash/marketing; **flattened single-color monogram + simple line icons** everywhere in-product |
| No defined activity-list or status-timeline pattern | **Standardized list row component** and **standardized status-timeline component**, reused everywhere |

Brand identity (Section 1–2 of the original doc: logo meaning, palette hex values, Mauritius localization, tone of voice) is unchanged — only the **layout density, chrome, and iconography style** shift toward Wise's lighter, flatter, pill-driven language.

---

## 9. Build Priority

1. Update design tokens (Section 7) — switch the app's default theme to light/off-white; keep dark mode as a togglable companion theme derived the same way as before (invert, don't redesign).
2. Build the **List Row** and **Status Timeline** components first — they're reused across Home, Vault, Pay, and Insights, so getting them right early saves rework.
3. Rebuild buttons/chips to full-pill radius; audit any existing components for the old 10–14px radius and correct them.
4. Splash → Onboarding → Login, using the flat monogram + simple illustration style.
5. Home dashboard: badge row → action pills → balance card → transactions list → promo banner → tab bar.
6. Transfer/status screens and Activity/search screens, reusing the components from step 2.

**Golden rule for the agent**: before shipping any screen, ask "does this look like it could sit inside the Wise app if you swapped green for gold?" If the answer is no — too dark, too glassy, too rounded-radius-inconsistent — simplify it back toward this spec.
