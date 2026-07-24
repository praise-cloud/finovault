import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';
import en from './locales/en.json';
import fr from './locales/fr.json';

i18n.use(initReactI18next).init({
  resources: {
    en: { translation: en },
    fr: { translation: fr },
  },
  lng: 'en',
  fallbackLng: 'en',
  interpolation: {
    escapeValue: false,
  },
  compatibilityJSON: 'v4',
});

export default i18n;

export const t = i18n.t.bind(i18n);

export function formatCurrency(amount: number, currencyCode = 'USD'): string {
  try {
    const lang = i18n.language;
    return new Intl.NumberFormat(lang === 'fr' ? 'fr-MU' : 'en-US', {
      style: 'currency',
      currency: currencyCode,
      minimumFractionDigits: 2,
      maximumFractionDigits: 2,
    }).format(amount);
  } catch {
    const sym = currencyCode === 'MUR' ? 'MUR ' : '$';
    return `${sym}${amount.toLocaleString('en-US', { minimumFractionDigits: 2 })}`;
  }
}

export function useLanguage() {
  return {
    language: i18n.language,
    setLanguage: (lng: string) => i18n.changeLanguage(lng),
    isFrench: i18n.language === 'fr',
  };
}
