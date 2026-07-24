export const Colors = {
  // Core palette
  brandPrimary: '#0A1F5C',
  brandSecondary: '#08142E',
  brandText: '#1A1A1A',
  brandTextSecondary: '#43474D',
  brandCharcoal: '#1A1A1A',

  // Semantic
  brandSuccess: '#2E7D5B',
  brandWarning: '#C99A2E',
  brandError: '#8C3A3A',

  // Theme-aware — use via isDark conditional
  light: {
    text: '#08142E',
    background: '#FFFFFF',
    backgroundElement: 'rgba(8,20,46,0.04)',
    backgroundSelected: 'rgba(8,20,46,0.08)',
    textSecondary: '#43474D',
    surface: '#FFFFFF',
    border: '#E4E7EE',
    surfaceBorder: '#E4E7EE',
    chipBg: 'rgba(8,20,46,0.04)',
    errorBg: '#F6E7E7',
  },
  dark: {
    text: '#FFFFFF',
    background: '#08142E',
    backgroundElement: '#1A1A1A',
    backgroundSelected: '#2E3135',
    textSecondary: '#B0B4BA',
    surface: 'rgba(255,255,255,0.08)',
    border: 'rgba(255,255,255,0.15)',
    surfaceBorder: 'rgba(255,255,255,0.1)',
    chipBg: 'rgba(255,255,255,0.08)',
    errorBg: 'rgba(140,58,58,0.15)',
  },
} as const;

export type ThemeColor = keyof typeof Colors.light & keyof typeof Colors.dark;

export const Fonts = {
  logo: 'Cinzel_700Bold' as const,
  logoSemiBold: 'Cinzel_600SemiBold' as const,
  display: 'Montserrat_800ExtraBold' as const,
  body: 'Montserrat_400Regular' as const,
  bodyMedium: 'Montserrat_500Medium' as const,
  bodySemiBold: 'Montserrat_600SemiBold' as const,
  bodyBold: 'Montserrat_700Bold' as const,
};

// Type scale — from wise-flow-design.md Section 7
export const FontSize = {
  h1: 36,
  h2: 24,
  h3: 18,
  body: 16,
  caption: 14,
  button: 16,
  numeral: 36,
  onboardingStatement: 38,
} as const;

// Radii — pill-first system from wise-flow-design.md Section 7
export const Radius = {
  pill: 9999,
  card: 18,
  input: 14,
  iconContainer: 9999,
} as const;

// Spacing
export const Spacing = {
  half: 2,
  one: 4,
  two: 8,
  three: 16,
  four: 24,
  five: 32,
  six: 64,
} as const;

// Elevation — from wise-flow-design.md Section 7
export const Shadow = {
  card: {
    boxShadow: '0 2px 12px rgba(8,20,46,0.06)',
    elevation: 4,
  },
  button: {
    boxShadow: '0 4px 20px rgba(8,20,46,0.15)',
    elevation: 6,
  },
} as const;

// Responsive helpers
export const BottomTabInset = 0;
export const MaxContentWidth = 800;
