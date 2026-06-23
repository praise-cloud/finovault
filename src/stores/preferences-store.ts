import { create } from 'zustand';
import * as ProfileService from '@/lib/api/services/profile';
import { useAuthStore } from './auth-store';

interface PreferencesState {
  role: string;
  goals: string[];
  aiInsights: boolean;
  securityAlerts: boolean;
  isLoading: boolean;

  setRole: (role: string) => void;
  toggleGoal: (key: string) => void;
  setAiInsights: (v: boolean) => void;
  setSecurityAlerts: (v: boolean) => void;
  loadPreferences: () => Promise<void>;
  savePreferences: () => Promise<void>;
}

export const usePreferencesStore = create<PreferencesState>((set, get) => ({
  role: 'individual',
  goals: ['wealth', 'savings'],
  aiInsights: true,
  securityAlerts: true,
  isLoading: false,

  setRole: (role) => set({ role }),
  toggleGoal: (key) =>
    set((state) => ({
      goals: state.goals.includes(key)
        ? state.goals.filter((g) => g !== key)
        : [...state.goals, key],
    })),
  setAiInsights: (v) => set({ aiInsights: v }),
  setSecurityAlerts: (v) => set({ securityAlerts: v }),

  loadPreferences: async () => {
    const user = useAuthStore.getState().user;
    if (!user) return;

    set({ isLoading: true });
    const prefs = await ProfileService.getPreferences(user.id);
    if (prefs) {
      set({
        role: prefs.role,
        goals: prefs.goals,
        aiInsights: prefs.ai_insights_enabled,
        securityAlerts: prefs.security_alerts_enabled,
      });
    }
    set({ isLoading: false });
  },

  savePreferences: async () => {
    const user = useAuthStore.getState().user;
    if (!user) return;

    const { role, goals, aiInsights, securityAlerts } = get();
    await ProfileService.savePreferences(user.id, {
      role: role as any,
      goals,
      ai_insights_enabled: aiInsights,
      security_alerts_enabled: securityAlerts,
    });
  },
}));
