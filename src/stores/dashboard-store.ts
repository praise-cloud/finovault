import { create } from 'zustand';
import * as DashboardService from '@/lib/api/services/dashboard';
import type {
  DashboardSummary,
  WealthGrowthData,
  SmartSavingsData,
  FraudProtectionData,
  SmeDashboardData,
  SmeAnalyticsData,
  FreelancerData,
  EntrepreneurData,
  ProfileData,
} from '@/lib/supabase-types';

interface DashboardState {
  summary: DashboardSummary | null;
  wealthGrowth: WealthGrowthData | null;
  smartSavings: SmartSavingsData | null;
  fraudProtection: FraudProtectionData | null;
  smeDashboard: SmeDashboardData | null;
  smeAnalytics: SmeAnalyticsData | null;
  freelancer: FreelancerData | null;
  entrepreneur: EntrepreneurData | null;
  profileData: ProfileData | null;
  loadingCount: number;
  isLoading: boolean;
  error: string | null;

  loadSummary: () => Promise<void>;
  loadWealthGrowth: () => Promise<void>;
  loadSmartSavings: () => Promise<void>;
  loadFraudProtection: () => Promise<void>;
  loadSmeDashboard: () => Promise<void>;
  loadSmeAnalytics: () => Promise<void>;
  loadFreelancer: () => Promise<void>;
  loadEntrepreneur: () => Promise<void>;
  loadProfileData: () => Promise<void>;
  loadAll: () => Promise<void>;
}

const withLoading = (set: any, fn: () => Promise<void>) => {
  set((s: DashboardState) => ({ loadingCount: s.loadingCount + 1, isLoading: true, error: null }));
  return fn().finally(() => {
    set((s: DashboardState) => {
      const next = Math.max(0, s.loadingCount - 1);
      return { loadingCount: next, isLoading: next > 0 };
    });
  });
};

export const useDashboardStore = create<DashboardState>((set) => ({
  summary: null,
  wealthGrowth: null,
  smartSavings: null,
  fraudProtection: null,
  smeDashboard: null,
  smeAnalytics: null,
  freelancer: null,
  entrepreneur: null,
  profileData: null,
  loadingCount: 0,
  isLoading: false,
  error: null,

  loadSummary: async () => withLoading(set, async () => {
    const data = await DashboardService.getDashboardSummary();
    set({ summary: data });
  }),

  loadWealthGrowth: async () => withLoading(set, async () => {
    const data = await DashboardService.getWealthGrowthData();
    set({ wealthGrowth: data });
  }),

  loadSmartSavings: async () => withLoading(set, async () => {
    const data = await DashboardService.getSmartSavingsData();
    set({ smartSavings: data });
  }),

  loadFraudProtection: async () => withLoading(set, async () => {
    const data = await DashboardService.getFraudProtectionData();
    set({ fraudProtection: data });
  }),

  loadSmeDashboard: async () => withLoading(set, async () => {
    const data = await DashboardService.getSmeDashboardData();
    set({ smeDashboard: data });
  }),

  loadSmeAnalytics: async () => withLoading(set, async () => {
    const data = await DashboardService.getSmeAnalyticsData();
    set({ smeAnalytics: data });
  }),

  loadFreelancer: async () => withLoading(set, async () => {
    const data = await DashboardService.getFreelancerData();
    set({ freelancer: data });
  }),

  loadEntrepreneur: async () => withLoading(set, async () => {
    const data = await DashboardService.getEntrepreneurData();
    set({ entrepreneur: data });
  }),

  loadProfileData: async () => withLoading(set, async () => {
    const data = await DashboardService.getProfileData();
    set({ profileData: data });
  }),

  loadAll: async () => withLoading(set, async () => {
    const results = await Promise.allSettled([
      DashboardService.getDashboardSummary(),
      DashboardService.getWealthGrowthData(),
      DashboardService.getSmartSavingsData(),
      DashboardService.getFraudProtectionData(),
      DashboardService.getSmeDashboardData(),
      DashboardService.getSmeAnalyticsData(),
      DashboardService.getFreelancerData(),
      DashboardService.getEntrepreneurData(),
      DashboardService.getProfileData(),
    ]);
    const [
      summary, wealthGrowth, smartSavings, fraudProtection,
      smeDashboard, smeAnalytics, freelancer, entrepreneur, profileData,
    ] = results.map((r) => (r.status === 'fulfilled' ? r.value : null));
    const errors = results.filter((r) => r.status === 'rejected').map((r: any) => r.reason?.message).filter(Boolean);
    set({
      summary, wealthGrowth, smartSavings, fraudProtection,
      smeDashboard, smeAnalytics, freelancer, entrepreneur, profileData,
      error: errors.length > 0 ? errors.join('; ') : null,
    });
  }),
}));
