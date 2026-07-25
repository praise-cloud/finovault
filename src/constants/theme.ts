export const Colors = {
  brandPrimary: '#0D358C',
  brandSecondary: '#2B46B1',
  brandBackground: '#F0F0F0',
  brandSurface: '#FFFFFF',
  brandBorder: '#D9D9D9',
  brandText: '#111111',
  brandTextSecondary: '#5E6470',
  brandDark: '#0A1A4D',
  brandSuccess: '#2E7D5B',
  brandWarning: '#C99A2E',
  brandError: '#8C3A3A',
  light: {
    text: '#111111',
    background: '#F0F0F0',
    backgroundElement: 'rgba(13,53,140,0.05)',
    backgroundSelected: 'rgba(13,53,140,0.12)',
    textSecondary: '#5E6470',
    surface: '#FFFFFF',
    border: '#D9D9D9',
    surfaceBorder: '#D9D9D9',
    chipBg: 'rgba(13,53,140,0.06)',
    errorBg: 'rgba(140,58,58,0.12)',
  },
  dark: {
    text: '#FFFFFF',
    background: '#0A1A4D',
    backgroundElement: '#122A72',
    backgroundSelected: '#2B46B1',
    textSecondary: '#D1D6E2',
    surface: 'rgba(255,255,255,0.08)',
    border: 'rgba(255,255,255,0.15)',
    surfaceBorder: 'rgba(255,255,255,0.12)',
    chipBg: 'rgba(255,255,255,0.08)',
    errorBg: 'rgba(140,58,58,0.18)',
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

export const Radius = {
  pill: 9999,
  card: 14,
  input: 10,
  iconContainer: 9999,
} as const;

export const Spacing = {
  half: 2,
  one: 4,
  two: 8,
  three: 16,
  four: 24,
  five: 32,
  six: 64,
} as const;

export const Shadow = {
  card: {
    boxShadow: '0 4px 24px rgba(13,53,140,0.08)',
    elevation: 4,
  },
  button: {
    boxShadow: '0 4px 20px rgba(13,53,140,0.18)',
    elevation: 6,
  },
} as const;

export const BottomTabInset = 0;
export const MaxContentWidth = 800;
