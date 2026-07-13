import { create } from 'zustand';
import AsyncStorage from '@react-native-async-storage/async-storage';

const STORAGE_KEY = 'finovault_settings';

export type Currency = {
  code: string;
  symbol: string;
  name: string;
  rate: number;
};

export const CURRENCIES: Currency[] = [
  { code: 'USD', symbol: '$', name: 'US Dollar', rate: 1 },
  { code: 'EUR', symbol: '€', name: 'Euro', rate: 0.92 },
  { code: 'GBP', symbol: '£', name: 'British Pound', rate: 0.79 },
  { code: 'NGN', symbol: '₦', name: 'Nigerian Naira', rate: 1550 },
  { code: 'KES', symbol: 'KSh', name: 'Kenyan Shilling', rate: 145 },
  { code: 'ZAR', symbol: 'R', name: 'South African Rand', rate: 18.5 },
  { code: 'GHS', symbol: '₵', name: 'Ghanaian Cedi', rate: 12.3 },
  { code: 'XOF', symbol: 'CFA', name: 'CFA Franc', rate: 605 },
  { code: 'EGP', symbol: 'E£', name: 'Egyptian Pound', rate: 48 },
  { code: 'MAD', symbol: 'DH', name: 'Moroccan Dirham', rate: 10.1 },
];

export const LOCATIONS = [
  { label: 'United States', value: 'US', currency: 'USD', lang: 'en' },
  { label: 'United Kingdom', value: 'GB', currency: 'GBP', lang: 'en' },
  { label: 'Nigeria', value: 'NG', currency: 'NGN', lang: 'en' },
  { label: 'Kenya', value: 'KE', currency: 'KES', lang: 'en' },
  { label: 'South Africa', value: 'ZA', currency: 'ZAR', lang: 'en' },
  { label: 'Ghana', value: 'GH', currency: 'GHS', lang: 'en' },
  { label: 'France', value: 'FR', currency: 'EUR', lang: 'fr' },
  { label: 'Germany', value: 'DE', currency: 'EUR', lang: 'de' },
  { label: 'Egypt', value: 'EG', currency: 'EGP', lang: 'ar' },
  { label: 'Morocco', value: 'MA', currency: 'MAD', lang: 'ar' },
];

export const LANGUAGES = [
  { label: 'English', value: 'en' },
  { label: 'French', value: 'fr' },
  { label: 'German', value: 'de' },
  { label: 'Arabic', value: 'ar' },
  { label: 'Portuguese', value: 'pt' },
];

interface SettingsState {
  currency: Currency;
  location: string;
  language: string;
  loaded: boolean;
  setCurrency: (code: string) => void;
  setLocation: (value: string) => void;
  setLanguage: (value: string) => void;
  loadSettings: () => Promise<void>;
  saveSettings: () => Promise<void>;
}

export const useSettingsStore = create<SettingsState>((set, get) => ({
  currency: CURRENCIES[0],
  location: 'US',
  language: 'en',
  loaded: false,

  setCurrency: (code) => {
    const currency = CURRENCIES.find((c) => c.code === code) || CURRENCIES[0];
    set({ currency });
    get().saveSettings().catch(() => {});
  },

  setLocation: (value) => {
    const loc = LOCATIONS.find((l) => l.value === value);
    if (loc) {
      const currency = CURRENCIES.find((c) => c.code === loc.currency) || CURRENCIES[0];
      set({ location: value, currency, language: loc.lang });
    }
    get().saveSettings().catch(() => {});
  },

  setLanguage: (value) => {
    set({ language: value });
    get().saveSettings().catch(() => {});
  },

  loadSettings: async () => {
    try {
      const stored = await AsyncStorage.getItem(STORAGE_KEY);
      if (stored) {
        const parsed = JSON.parse(stored);
        const currency = CURRENCIES.find((c) => c.code === parsed.currencyCode) || CURRENCIES[0];
        set({ currency, location: parsed.location || 'US', language: parsed.language || 'en', loaded: true });
      } else {
        set({ loaded: true });
      }
    } catch {
      set({ loaded: true });
    }
  },

  saveSettings: async () => {
    const { currency, location, language } = get();
    try {
      await AsyncStorage.setItem(STORAGE_KEY, JSON.stringify({ currencyCode: currency.code, location, language }));
    } catch {}
  },
}));
