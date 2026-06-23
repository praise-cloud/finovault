---
name: Finovault AI
colors:
  surface: '#f7fafd'
  surface-dim: '#d7dadd'
  surface-bright: '#f7fafd'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f1f4f7'
  surface-container: '#ebeef1'
  surface-container-high: '#e5e8eb'
  surface-container-highest: '#e0e3e6'
  on-surface: '#181c1e'
  on-surface-variant: '#43474d'
  inverse-surface: '#2d3133'
  inverse-on-surface: '#eef1f4'
  outline: '#74777e'
  outline-variant: '#c4c6ce'
  surface-tint: '#49607e'
  primary: '#000f22'
  on-primary: '#ffffff'
  primary-container: '#0a2540'
  on-primary-container: '#768dad'
  inverse-primary: '#b0c8eb'
  secondary: '#006b5a'
  on-secondary: '#ffffff'
  secondary-container: '#54f8d7'
  on-secondary-container: '#00705e'
  tertiary: '#060045'
  on-tertiary: '#ffffff'
  tertiary-container: '#150082'
  on-tertiary-container: '#7f7bff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d2e4ff'
  primary-fixed-dim: '#b0c8eb'
  on-primary-fixed: '#001c37'
  on-primary-fixed-variant: '#314865'
  secondary-fixed: '#58fbda'
  secondary-fixed-dim: '#2cdebf'
  on-secondary-fixed: '#00201a'
  on-secondary-fixed-variant: '#005143'
  tertiary-fixed: '#e2dfff'
  tertiary-fixed-dim: '#c3c0ff'
  on-tertiary-fixed: '#0f0069'
  on-tertiary-fixed-variant: '#321ed2'
  background: '#f7fafd'
  on-background: '#181c1e'
  surface-variant: '#e0e3e6'
typography:
  display-lg:
    fontFamily: Geist
    fontSize: 48px
    fontWeight: '600'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Geist
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Geist
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  headline-md:
    fontFamily: Geist
    fontSize: 24px
    fontWeight: '500'
    lineHeight: 32px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: Geist
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.01em
  caption:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  xs: 4px
  sm: 12px
  md: 24px
  lg: 48px
  xl: 80px
  gutter: 24px
  margin-mobile: 16px
  margin-desktop: 48px
---

## Brand & Style
The design system is engineered to project a sense of **intelligence, bank-grade security, and premium accessibility**. It balances the rigidity of traditional finance with the fluid intelligence of modern AI. The aesthetic is rooted in **Corporate Modernism** with a heavy emphasis on **soft tactile depth**—using whitespace as a functional tool to reduce cognitive load in complex data environments.

The UI should evoke a sense of "calm power," ensuring users feel in control of their assets. It avoids the frantic energy of consumer trading apps in favor of a sophisticated, institutional interface that remains approachable through high-quality typography and generous spacing.

## Colors
The palette is anchored by **Deep Blue (#0A2540)**, providing a solid foundation of trust and authority. 

- **Primary:** Deep Blue is used for core navigation, headings, and high-emphasis backgrounds.
- **Secondary:** A vibrant Teal/Green gradient (from #00D1B2 to #00BFA5) signifies growth, health, and AI-driven actions.
- **Accent:** Slate Blue (#635BFF) is reserved for interactive states and subtle highlights.
- **Neutrals:** The background uses an Off-white (#F6F9FC) to soften the glare, while Light Gray (#E6EBF1) defines borders and container separations.
- **Semantic:** Success (Emerald), Warning (Amber), and Error (Crimson) are used with low saturation to maintain the calm aesthetic.

## Typography
This design system utilizes a dual-font strategy. **Geist** provides a technical, precise edge for headings and data labels, reflecting the "AI" aspect of the brand. **Inter** is used for body copy to ensure maximum legibility and a neutral, professional tone for long-form financial data.

- **Scale:** High contrast between display titles and body text to create clear information hierarchy.
- **Weights:** Use SemiBold (600) for primary actions and Medium (500) for secondary labels to maintain a structured feel without becoming "heavy."
- **Readability:** Line heights are slightly increased (1.5x for body) to ensure data-dense screens remain breathable.

## Layout & Spacing
The layout follows a **Fixed-Fluid Hybrid** model. Content is contained within a maximum width of 1440px on desktop to prevent eye-strain across ultra-wide monitors, but fluidly scales down for smaller devices.

- **Grid:** A 12-column grid system is used for desktop (24px gutters), 8-column for tablet, and 4-column for mobile.
- **Rhythm:** An 8px linear scale governs all padding and margins. 
- **Containers:** Large internal padding (minimum 24px) is required for all card layouts to reinforce the premium, spacious feel of the brand.

## Elevation & Depth
Depth is conveyed through **Ambient Shadows** and **Tonal Layering**. Instead of harsh borders, we use soft, multi-layered shadows to lift elements off the surface.

- **Surface 0:** The Off-white base background (#F6F9FC).
- **Surface 1:** Primary cards and containers. These use a very subtle 1px border (#E6EBF1) and a soft shadow (Blur: 20px, Y: 4px, Opacity: 4% Black).
- **Surface 2:** Modals and Pop-overs. These use a more pronounced shadow (Blur: 40px, Y: 12px, Opacity: 8% Black) to indicate a higher z-index.
- **Active State:** Interactive elements should use a "pressed" effect (reducing shadow and slightly scaling down) to feel tactile and responsive.

## Shapes
The shape language is **distinctly rounded** to soften the technical nature of fintech data. 

- **Primary Radius:** 0.5rem (8px) for standard components like input fields and small buttons.
- **Large Radius (rounded-lg):** 1rem (16px) for cards, dashboard widgets, and main containers.
- **Extra Large (rounded-xl):** 1.5rem (24px) for featured promotional sections or bottom sheets.
- **Interactive:** Buttons should feel "squishy" and friendly, avoiding sharp corners entirely to maintain the "calm and empowering" tone.

## Components
Consistent styling of these components is critical to the professional identity of the design system:

- **Buttons:** Primary buttons use a linear gradient from Secondary Teal to a slightly darker shade. They feature a subtle "glow" (shadow tinted with the brand color) when hovered.
- **Input Fields:** Premium inputs feature a thick 2px focus border in Deep Blue and a faint background tint. Error states should never shift the layout; use reserved space for helper text.
- **Cards:** Sleek layouts with 16px corner radius. Use a vertical hierarchy: Headline, Value (in Geist), and a Sparkline/Trend indicator.
- **Subtle Progress Indicators:** AI processing states should use a non-linear, "pulsing" gradient rather than a traditional spinning wheel to feel more organic and intelligent.
- **Chips/Badges:** Pill-shaped with low-opacity background fills derived from the semantic color palette (e.g., a faint green background for "Verified").
- **Lists:** High-contrast list items with 16px vertical padding and subtle dividers that don't reach the container edges.