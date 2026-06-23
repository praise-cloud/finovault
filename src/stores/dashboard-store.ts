import { create } from 'zustand';
import { useAuthStore } from './auth-store';
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
}

const getUserId = () => useAuthStore.getState().user?.id;

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
  isLoading: false,
  error: null,

  loadSummary: async () => {
    const uid = getUserId(); if (!uid) return;
    set({ isLoading: true, error: null });
    try {
      const data = await DashboardService.getDashboardSummary(uid);
      set({ summary: data, isLoading: false });
    } catch (e: any) {
      set({ error: e.message, isLoading: false });
    }
  },

  loadWealthGrowth: async () => {
    const uid = getUserId(); if (!uid) return;
    set({ isLoading: true, error: null });
    try {
      const data = await DashboardService.getWealthGrowthData(uid);
      set({ wealthGrowth: data, isLoading: false });
    } catch (e: any) {
      set({ error: e.message, isLoading: false });
    }
  },

  loadSmartSavings: async () => {
    const uid = getUserId(); if (!uid) return;
    set({ isLoading: true, error: null });
    try {
      const data = await DashboardService.getSmartSavingsData(uid);
      set({ smartSavings: data, isLoading: false });
    } catch (e: any) {
      set({ error: e.message, isLoading: false });
    }
  },

  loadFraudProtection: async () => {
    const uid = getUserId(); if (!uid) return;
    set({ isLoading: true, error: null });
    try {
      const data = await DashboardService.getFraudProtectionData(uid);
      set({ fraudProtection: data, isLoading: false });
    } catch (e: any) {
      set({ error: e.message, isLoading: false });
    }
  },

  loadSmeDashboard: async () => {
    const uid = getUserId(); if (!uid) return;
    set({ isLoading: true, error: null });
    try {
      const data = await DashboardService.getSmeDashboardData(uid);
      set({ smeDashboard: data, isLoading: false });
    } catch (e: any) {
      set({ error: e.message, isLoading: false });
    }
  },

  loadSmeAnalytics: async () => {
    const uid = getUserId(); if (!uid) return;
    set({ isLoading: true, error: null });
    try {
      const data = await DashboardService.getSmeAnalyticsData(uid);
      set({ smeAnalytics: data, isLoading: false });
    } catch (e: any) {
      set({ error: e.message, isLoading: false });
    }
  },

  loadFreelancer: async () => {
    const uid = getUserId(); if (!uid) return;
    set({ isLoading: true, error: null });
    try {
      const data = await DashboardService.getFreelancerData(uid);
      set({ freelancer: data, isLoading: false });
    } catch (e: any) {
      set({ error: e.message, isLoading: false });
    }
  },

  loadEntrepreneur: async () => {
    const uid = getUserId(); if (!uid) return;
    set({ isLoading: true, error: null });
    try {
      const data = await DashboardService.getEntrepreneurData(uid);
      set({ entrepreneur: data, isLoading: false });
    } catch (e: any) {
      set({ error: e.message, isLoading: false });
    }
  },

  loadProfileData: async () => {
    const uid = getUserId(); if (!uid) return;
    set({ isLoading: true, error: null });
    try {
      const data = await DashboardService.getProfileData(uid);
      set({ profileData: data, isLoading: false });
    } catch (e: any) {
      set({ error: e.message, isLoading: false });
    }
  },
}));
