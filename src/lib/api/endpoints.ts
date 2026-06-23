export const ENDPOINTS = {
  auth: {
    signup: '/auth/signup',
    login: '/auth/login',
    logout: '/auth/logout',
    verifyOtp: '/auth/verify-otp',
    resendOtp: '/auth/resend-otp',
    google: '/auth/google',
    apple: '/auth/apple',
  },
  profile: {
    me: '/profile/me',
    update: '/profile/update',
  },
  preferences: {
    get: '/preferences',
    save: '/preferences',
    update: '/preferences',
  },
  dashboard: {
    summary: '/dashboard/summary',
    wealthGrowth: '/dashboard/wealth-growth',
    smartSavings: '/dashboard/smart-savings',
    fraudProtection: '/dashboard/fraud-protection',
    smeDashboard: '/dashboard/sme',
    smeAnalytics: '/dashboard/sme-analytics',
    freelancer: '/dashboard/freelancer',
    entrepreneur: '/dashboard/entrepreneur',
    profile: '/dashboard/profile-data',
  },
  transactions: {
    list: '/transactions',
    create: '/transactions',
  },
  savings: {
    goals: '/savings/goals',
    roundUps: '/savings/round-ups',
  },
  vendors: {
    list: '/vendors',
  },
  fraud: {
    events: '/fraud/events',
    metrics: '/fraud/metrics',
  },
  ai: {
    suggestions: '/ai/suggestions',
    insights: '/ai/insights',
  },
};
