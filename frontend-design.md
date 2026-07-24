# Finovault — Mobile App Design System
### Complete Frontend Build Specification for AI Coding Agents

> **How to use this file**: This is the single source of truth for building Finovault's UI. Every screen, component, color, and interaction should trace back to something in this document. If a design decision isn't covered here, default to the **Vault Metaphor** (Section 1) and the **Design Tokens** (Section 6) rather than inventing a new direction.

---

## 1. Brand Foundation

**Product**: Finovault — an AI-powered financial intelligence platform (personal finance, portfolio/wealth tracking, payments, AI-driven insights).

**Tagline**: "Vault Your Future. Grow Your Wealth."

**Core Metaphor**: A bank vault. Every "container" in the UI (cards, balance panels, savings goals, portfolio views) should visually behave like something being *secured, stored, and grown* inside a vault — not a generic rounded rectangle. This metaphor is the design's signature and should recur deliberately, not decoratively.

**Market**: Mauritius, with broader relevance to premium African / Indian Ocean fintech users. This means:
- Bilingual UI support: **English (primary) + French (secondary)** — every string in the copy layer needs an FR fallback.
- Currency: **MUR (Mauritian Rupee)** formatted prominently and correctly (e.g. `MUR 125,000.00` — not `Rs.` or `$`).
- Tone: aspirational but trustworthy — this is a "premium bank," not a scrappy startup app. Avoid playful/casual fintech tropes (emoji confetti, cartoon mascots). Avoid generic "Silicon Valley fintech" clichés (bright purple gradients, cartoon illustrations, comic-sans-adjacent rounded fonts).
- Local sensitivity: any Mauritius-specific motifs (map outline, dodo silhouette) must be a **subtle watermark only** — never a loud illustration. The vault/gold motif carries the brand; local flavor is a whisper, not a shout.

**Positioning statement for the agent**: Every screen should look like it belongs inside a premium financial institution — clean, secure, expensive, calm. **Light theme is the default**: white/off-white backgrounds (`#F7F9FC` / `#FFFFFF`) with Deep Navy (`#08142E` / `#0A1F5C`) reserved for elevated surfaces, headers, and dark mode. Dark mode inverts this: Deep Navy becomes the background, white becomes the surface.

---

## 2. Logo System

### 2.1 Primary Mark — The Vault Door
The core visual is a **circular bank vault door**, rendered in gold metallic tones against a deep navy field:
- Outer ring: brushed gold with a **visible bolt/rivet pattern** running around the circumference (evenly spaced circular studs).
- Hinge: a gold barrel hinge on the left edge, showing the door is "ajar" in illustrative/hero contexts, fully closed in the icon/lockup context.
- **Center element (mandatory)**: a gold **spoked wheel lock** (like a ship's helm / vault wheel — 6–8 spokes radiating from a center hub) with a **keyhole cut into the hub**. This keyhole-in-wheel is the single most important recognizable asset in the identity — reuse it everywhere a compact mark is needed.
- Optional secondary detail (combination dial): a small circular combination lock dial can sit beside the main wheel in expanded/editorial lockups (see Image 3 reference) — reserve this for marketing/splash contexts, not for small UI icons where it would be unreadable.

### 2.2 Wordmark
- "FINOVAULT" set in a **bold classical serif** (Cinzel Bold or equivalent engraved-serif style), all caps, gold, generous letter-spacing.
- A thin gold rule or small diamond glyph often divides the wordmark from the tagline beneath it.
- Tagline "Vault Your Future. Grow Your Wealth." in the same gold, smaller, wide letter-spacing, all caps or small-caps.

### 2.3 Monogram / App Icon (the asset the user specifically requested)
Use the **"V" inside the vault wheel with the keyhole** as the compact monogram:
- A circular gold vault-wheel outline, navy fill inside, with a bold gold **"V"** centered where the keyhole/hub would be (the V's negative space or a small cutout at its base can double as the keyhole notch).
- This is the version to use for: app icon, favicon, splash logo mark, loading spinners, empty-state watermarks, and the small mark in the top-left of navigation/headers.
- Rounded-square container for the app icon (iOS/Android adaptive icon safe zone), navy background, gold mark centered, optional wordmark small beneath it only if the icon is used at large sizes (e.g. app store listing) — omit wordmark at 48px and below.

### 2.4 Logo Usage Rules
- Never place the gold mark on a light background without a navy container behind it — contrast is part of the brand's "premium/secure" feeling.
- Minimum clear space around the mark: half the mark's own height on all sides.
- Do not recolor the mark (no blue-on-gold inversions, no flat single-color versions except a monochrome white version for very small/dark contexts like status bars).
- Combination-dial detail and rivet ring are for hero/splash/marketing use only — strip them at icon sizes and keep just the wheel + keyhole for legibility.

---

## 3. Color System

| Token | Name | Hex (Light / Dark) | Primary Usage |
|---|---|---|---|---|
| `--color-primary` | Royal Blue | `#0A1F5C` (both) | Headers, elevated surfaces, tab bars |
| `--color-bg` | Background | `#F7F9FC` / `#08142E` | Page background (light / dark) |
| `--color-surface` | Surface | `#FFFFFF` / `rgba(255,255,255,0.08)` | Card / container fill |
| `--color-accent` | Gold | `#D4AF37` (both) | CTAs, active states, key numbers, icons |
| `--color-accent-light` | Light Gold | `#F4D35E` (both) | Hover/pressed states, chart peaks |
| `--color-text` | Text | `#1A1A1A` / `#FFFFFF` | Primary body text |
| `--color-text-secondary` | Text Secondary | `#43474D` / `#B0B4BA` | Captions, metadata |
| `--color-border` | Border | `#c4c6ce` / `rgba(255,255,255,0.15)` | Dividers, input borders |
| `--color-charcoal` | Charcoal | `#1A1A1A` (both) | Muted text, dark elements |

**Semantic additions the agent should derive (not in the source palette, but required for a real app — keep them harmonized with the gold/navy world):**
- Success (financial health "good", income, positive change): a **muted emerald green** (~`#2E7D5B`), never a loud neon green — it must sit quietly next to gold.
- Warning/attention: a **warm amber**, distinct from the brand gold so alerts don't get lost — desaturate the brand gold slightly and shift warmer.
- Error/negative change: a **deep muted red/garnet** (~`#8C3A3A`) — avoid pure `#FF0000`, which clashes with the luxury tone.
- All semantic colors should be tested at the same "quiet luxury" saturation as the rest of the palette — nothing neon.

**Usage rules**:
- **Light theme is the default** (`#F7F9FC` background, `#1A1A1A` text). Dark mode is the companion theme (`#08142E` background, `#FFFFFF` text). Every screen must support both.
- Every container uses theme-aware background: `isDark ? '#08142E' : '#F7F9FC'` for page backgrounds, with `#0A1F5C` (Royal Blue) reserved for headers, tab bars, and elevated surfaces in dark mode.
- Gold is a scarce resource. It marks: primary actions, money amounts, active nav state, focus rings, chart lines/highlights, and the vault iconography. If more than ~15% of a screen is gold, pull back.
- Maintain WCAG AA contrast: `#1A1A1A` on `#F7F9FC` passes easily in light mode; white text on navy passes in dark mode. Gold text on navy passes for large text/headings — use white or off-white for small body copy in dark mode, reserve gold for headings, labels, and numerals.

---

## 4. Typography

**Display / Headings — Cinzel Bold** (or nearest licensed equivalent: e.g. "Cormorant" family for a softer alternative, or a genuine engraved serif). Use only for: logo lockups, H1 hero titles, and large balance/amount displays where a "carved gold plaque" feeling is wanted. Do not use for body paragraphs — it is a display face and loses legibility at small sizes.

**Body / UI — Montserrat**. Use for everything functional: body copy, labels, buttons, form fields, navigation labels, table/list content.

**Type Scale**:
| Role | Size | Font | Weight | Notes |
|---|---|---|---|---|
| H1 | 32–40px | Cinzel Bold | Bold | Hero titles, splash |
| H2 | 24–28px | Cinzel Bold or Montserrat SemiBold | Bold/SemiBold | Section headers |
| H3 | 20–22px | Montserrat SemiBold | SemiBold | Card titles, screen titles |
| Body | 16px | Montserrat | Regular | Default body text |
| Caption | 14px | Montserrat | Regular/Medium | Metadata, timestamps, helper text |
| Button | 16–18px | Montserrat | Medium/SemiBold | All CTAs |
| Numeral / Balance | 32–48px | Cinzel Bold or Montserrat Bold | Bold | Large money figures — test both; numerals in Cinzel can look ornate at very large sizes, Montserrat Bold may read cleaner for pure digits |

**Rules**: Line height 1.4–1.6. Heading letter-spacing −0.02em. Never set Cinzel below ~18px (legibility). Never use Cinzel for dense paragraphs.

---

## 5. UI/UX Principles

### 5.1 Overall Aesthetic
- **Light theme first** with a companion dark theme. Default background is `#F7F9FC` (off-white), text is `#1A1A1A` (charcoal). Dark mode inverts: `#08142E` background, `#FFFFFF` text.
- **Depth over flatness**: subtle shadows, soft metallic gradients on gold elements, and glassmorphism on cards (`rgba(0,0,0,0.04)` fill in light mode, `rgba(255,255,255,0.08)` fill in dark mode, thin gold-tinted border, soft inner highlight).
- **Micro-interactions**: buttons should feel mechanical/tactile — a slight "press and release" like a vault lever, not a generic material-design ripple. Loading states can reference the vault wheel rotating slightly.
- **Trust signals throughout**: lock icons, shield icons, biometric prompts styled in gold-line-icon language, "Secured" microcopy near sensitive actions.
- Avoid the three generic "AI-app" looks (cream+terracotta, black+neon-green, hairline-broadsheet newspaper). This brand already has a strong, specific direction — stay inside it rather than defaulting to any of those.

### 5.2 Screen-by-Screen Spec

**Splash Screen**
- Full-bleed background (light: `#F7F9FC`, dark: `#08142E`).
- Animated vault door: door appears closed, wheel rotates slightly, door swings open (or simply the wheel spins into place) as the wordmark fades/rises in beneath it.
- Keep the animation under ~1.5s total — premium apps feel instant, not slow.

**Onboarding**
- 2–4 cards, swipeable, each pairing a short benefit headline (Montserrat SemiBold) with a simple vault/growth-chart line illustration in gold.
- Progress dots in gold (active) / muted (inactive), not a percentage bar — keep it light-touch.

**Login / Auth**
- Full-screen background (light: `#F7F9FC`, dark: `#08142E`).
- Centered vault monogram logo at top.
- Form wrapped in a **centered glass card** with subtle gold border on white/light background.
- Inputs: glass/light fill, floating labels, **gold underline appears on focus** (not a full gold border — reserve full borders for the active/selected state of larger components).
- Single-column centered layout (no desktop split-panel). Trust signals (lock, encryption, biometric) placed beneath the form.
- Biometric (Face ID / fingerprint) prompt available immediately below the form, with a small gold shield/lock icon — this is a trust signal moment, don't bury it in settings only.

**Bottom Tab Navigation** (5 items, gold line icons, label beneath icon):
1. **Home** — dashboard/house icon
2. **Insights** — brain/AI icon
3. **Vault** — the vault-wheel icon (portfolio/holdings) — this tab should visually use the *actual brand mark*, not a generic folder/briefcase icon, since "Vault" is the product's core noun
4. **Pay** — send/receive arrows icon
5. **Profile** — user icon

Active tab: icon + label in Gold. Inactive: icon + label in a muted off-white/charcoal. Active tab may get a subtle glow or a small gold dot indicator above it — avoid a heavy colored pill background, which reads as generic Material Design rather than "vault."

**Dashboard / Home**
- Background: theme-aware (`isDark ? '#08142E' : '#F7F9FC'`).
- Top: personalized greeting ("Good morning, [Name]") + notification bell, small monogram mark top-left as a persistent brand anchor.
- Total balance in large gold numerals, currency prefix "MUR" clearly visible, with a small percentage-change indicator beneath (green up / garnet down, with arrow).
- **Financial Health Gauge**: a circular/radial progress ring (e.g. 78% "Good") — gold/green gradient arc on a dark track, percentage centered in the ring in bold numerals, status word ("Good" / "Excellent" / "Needs Attention") beneath.
- Quick Actions row: 4 compact glass cards/buttons — Send, Receive, Invest, Budget — each with a gold line icon and label.
- Portfolio performance chart: dark background (or light in light mode), gold line for the primary series, a secondary muted-blue or light-gold line if comparing benchmarks.

**Vault (Portfolio) Screen**
- List/grid of holdings or goals, each rendered as a **glass "safety deposit box" card**: glass fill, thin gold border, small vault-adjacent icon (lock, coin stack, or growth arrow depending on asset type), name, current value in gold numerals, change indicator.
- Consider a literal visual metaphor here if time allows: goals or holdings as individually "locked" cards that visually "unlock" (subtle animation) when tapped into detail — reinforces the vault metaphor at the screen that matters most.

**Insights (AI) Screen**
- Conversational or card-based AI recommendations. Use the AI-insight icon (brain-circuit, gold line) as the recurring marker for anything AI-generated, so users always know what's a system recommendation vs. their own data.
- Keep AI copy in active voice and specific: "You spent 18% more on dining this month" rather than vague encouragement.

**Pay / Send**
- Card component styled to resemble a literal bank/vault card: navy base, gold chip icon, gold "FINOVAULT" wordmark, masked card number, expiry — matches the physical card reference in the brand sheet.
- Transfer flow should foreground security microcopy ("Encrypted transfer," "Verified recipient") using shield/lock iconography.

**Profile / Settings**
- Security section should be visually prioritized (not buried at the bottom): biometric toggle, 2FA, device management, all with lock/shield iconography consistent with the rest of the app.
- Language toggle (EN/FR) should live here, clearly, given the bilingual Mauritius market.

### 5.3 Components

**Cards (Glassmorphic)** — the default container everywhere:
- Fill: Light mode → `rgba(255,255,255,0.8)` / Dark mode → `rgba(255,255,255,0.08)`.
- Border: 1px, gold at low opacity (~20–30%) rather than full-strength gold, to keep it a hint of luxury rather than a heavy frame.
- Corner radius: moderate (12–16px) — rounded enough to feel modern, not so rounded it feels playful/toylike (avoid pill-shaped cards; save full pill shapes for buttons/tags).
- Soft outer shadow for elevation; optional soft inner highlight along the top edge to sell the "glass" read.

**Buttons**:
- Primary: Gold fill, Deep Navy text, medium-bold, rounded (not full pill — a refined 10–14px radius reads more "banking," full pill reads more "consumer social app"). Subtle metallic gradient/sheen optional on primary buttons only.
- Secondary: transparent/navy-outline, gold text, gold 1–1.5px border.
- Disabled: charcoal fill, muted text, no gold anywhere.
- Pressed state: slightly darker gold + a subtle scale-down (98%) to feel mechanical/tactile.

**Inputs**:
- Light/glass background in light mode, dark/glass in dark mode, floating label pattern (label sits inside field at rest, animates up on focus/filled).
- Underline or border shifts to gold only on focus — resting state should be a quiet charcoal/off-white low-opacity border so the interface isn't gold-saturated by default.

**Charts**:
- Theme-aware background. Primary data series in gold; secondary series in a muted royal blue or light gold; never introduce a bright non-brand color for data unless it's a semantic status color (green/garnet) for a designated positive/negative encoding.

**Iconography**:
- Consistent **gold line-icon** style throughout (not filled/solid icons) — shield, chart bars, wallet, brain/circuit, building/columns, the vault wheel. Line weight should be consistent (e.g. 1.5–2px stroke) across the whole set; do not mix a line-icon nav with filled-icon cards.

### 5.4 Motion
- Vault-door and wheel motifs are the brand's signature animation language: use a slight rotation/turn easing (not a bouncy spring) for loading spinners, pull-to-refresh, and the splash sequence — it should feel like a mechanism turning, not a cartoon bounce.
- Keep everyday transitions (screen pushes, tab switches) fast and minimal — 150–250ms, standard ease. Reserve the more elaborate vault-themed motion for splash, onboarding, and moments of real significance (e.g., successfully securing/locking in a savings goal), not for routine navigation. Overusing the signature animation everywhere dilutes it.

---

## 6. Design Tokens (Developer Reference)

```css
/* Light Theme (default) */
:root {
  --color-primary: #0A1F5C;        /* Royal Blue — headers, elevated surfaces */
  --color-secondary: #08142E;      /* Deep Navy — dark mode bg */
  --color-bg: #F7F9FC;             /* Light theme page background */
  --color-surface: #FFFFFF;        /* Card surface in light mode */
  --color-surface-glass: rgba(255, 255, 255, 0.8); /* Glass card fill (light) */
  --color-text: #1A1A1A;           /* Primary text */
  --color-text-secondary: #43474D; /* Secondary text */
  --color-accent: #D4AF37;         /* Gold — CTAs, active, numerals */
  --color-accent-light: #F4D35E;   /* Light Gold */
  --color-border: #c4c6ce;         /* Borders, dividers */
  --color-charcoal: #1A1A1A;
}

/* Dark Theme */
[data-theme="dark"] {
  --color-bg: #08142E;             /* Deep Navy */
  --color-surface: rgba(255, 255, 255, 0.08);
  --color-text: #FFFFFF;
  --color-text-secondary: #B0B4BA;
  --color-border: rgba(255, 255, 255, 0.15);
}

/* Shared (both themes) */
:root {
  --color-accent: #D4AF37;
  --color-accent-light: #F4D35E;
  --color-success: #2E7D5B;
  --color-warning: #C99A2E;
  --color-error: #8C3A3A;

  --font-display: 'Cinzel', serif;
  --font-body: 'Montserrat', sans-serif;

  --fs-h1: 36px;
  --fs-h2: 26px;
  --fs-h3: 21px;
  --fs-body: 16px;
  --fs-caption: 14px;
  --fs-button: 17px;
  --fs-numeral: 40px;

  --line-height-default: 1.5;
  --letter-spacing-heading: -0.02em;

  --radius-card: 14px;
  --radius-button: 12px;
  --radius-input: 10px;
  --radius-icon-container: 999px;

  --shadow-card: 0 4px 24px rgba(0, 0, 0, 0.12);
  --shadow-inner-highlight: inset 0 1px 0 rgba(255, 255, 255, 0.06);
}
```

---

## 7. Localization Checklist (Mauritius Market)
- [ ] Every UI string has an EN and FR version; no hardcoded English in components.
- [ ] Currency formatting uses MUR with correct thousand separators and 2 decimal places (e.g. `MUR 125,000.00`).
- [ ] Date formats should support both EN and FR conventions used locally (DD/MM/YYYY is standard).
- [ ] Any local cultural motif (map outline, dodo silhouette) appears only as a faint background watermark on non-critical screens (e.g. splash, empty states) — never on data-dense screens where it could reduce legibility.

---

## 8. Build Priority for the Agent
When implementing, build in this order so the "vault" identity is established before feature depth:
1. Design tokens (Section 6) wired into the theme/style system — light-theme-first with dark companion.
2. Logo assets (Section 2): the monogram (V + wheel + keyhole) as an SVG/icon component, reusable at multiple sizes.
3. Splash → Onboarding → Login (establishes brand + motion language early).
4. Bottom nav + Dashboard shell (glass card component, button component, input component built here first, then reused everywhere).
5. Vault (Portfolio), Insights, Pay, Profile screens, reusing the component library from step 4 rather than one-off styling per screen.

**Golden rule for the agent**: if a new screen or component doesn't obviously map to "a premium, secure vault rendered digitally," stop and check it against Sections 1, 3, and 6 before shipping it.
