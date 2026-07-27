import { router } from 'expo-router';
import { Pressable, Text, View, useWindowDimensions, useColorScheme } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { usePreferencesStore } from '@/src/stores/preferences-store';
import { submitFinancialInterview } from '@/src/lib/api/services/onboarding';
import { Logo } from '@/src/components/logo';

const BLUE = '#123B91';
const PAPER = '#F2F2F2';

const GOALS = [
  { key: 'sme-analytics', label: 'SME\nAnalytics', desc: 'Deep insights into business cashflow and vendor health.', icon: 'analytics' as const },
  { key: 'savings', label: 'Smart\nSavings', desc: 'Automated budgeting and rainy-day funds.', icon: 'savings' as const },
  { key: 'fraud', label: 'Fraud\nProtection', desc: '24/7 bank-grade monitoring and alerts.', icon: 'shield' as const },
  { key: 'wealth', label: 'Wealth\nGrowth', desc: 'Maximize returns with AI-driven investment strategies.', icon: 'trending-up' as const },
];

export default function FinancialInterview() {
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';
  const { width } = useWindowDimensions();
  const goals = usePreferencesStore((state) => state.goals);
  const toggleGoal = usePreferencesStore((state) => state.toggleGoal);
  const savePreferences = usePreferencesStore((state) => state.savePreferences);

  const complete = async () => {
    try {
      await savePreferences();
      await submitFinancialInterview({ goals });
    } catch (e) {
      console.warn('Financial interview submission failed', e);
    }
    router.push('/account-created');
  };

  return (
    <View style={{ flex: 1, backgroundColor: isDark ? '#08142E' : PAPER, alignItems: 'center' }}>
      <View style={{ width: Math.min(width, 390), flex: 1, backgroundColor: isDark ? '#08142E' : PAPER, paddingHorizontal: 24, paddingTop: 60 }}>
        <View style={styles.topbar}>
          <Pressable onPress={() => router.back()} hitSlop={12}>
            <MaterialIcons name="arrow-back" size={24} color={isDark ? '#D4AF37' : BLUE} />
          </Pressable>
          <Logo width={26} height={23.5} color={isDark ? '#D4AF37' : BLUE} />
        </View>

        <Text style={[styles.title, { color: isDark ? '#FFFFFF' : '#111111' }]}>What are your financial goals?</Text>
        <Text style={[styles.subtitle, { color: isDark ? '#B0B0B0' : '#666B76' }]}>Help us tailor our system to your specific financial needs.</Text>

        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 12, marginTop: 24 }}>
          {GOALS.map((goal) => {
            const selected = goals.includes(goal.key);
            return (
              <Pressable
                key={goal.key}
                onPress={() => toggleGoal(goal.key)}
                style={[
                  styles.goal,
                  { backgroundColor: isDark ? '#1A1A1A' : '#FFFFFF', borderColor: isDark ? '#2A2A2A' : '#E1E4EC' },
                  selected && { borderColor: BLUE, backgroundColor: isDark ? '#0F2040' : '#EEF1FB' },
                ]}
              >
                <View style={[
                  styles.iconBox,
                  { backgroundColor: isDark ? '#2A2A2A' : '#EEF0F5' },
                  selected && { backgroundColor: isDark ? '#1A2A5C' : '#DCE3F7' },
                ]}>
                  <MaterialIcons name={goal.icon} size={18} color={BLUE} />
                </View>
                <Text style={[styles.goalTitle, { color: isDark ? '#FFFFFF' : '#20232A' }]}>{goal.label}</Text>
                <Text style={[styles.goalDesc, { color: isDark ? '#B0B0B0' : '#666B76' }]}>{goal.desc}</Text>
              </Pressable>
            );
          })}
        </View>

        <Pressable onPress={complete} style={[styles.cta, { marginTop: 24 }]}>
          <Text style={styles.ctaText}>Continue</Text>
          <MaterialIcons name="arrow-forward" size={18} color="#FFFFFF" />
        </Pressable>

        <Text style={[styles.helper, { color: isDark ? '#8C8F9E' : '#969AA3' }]}>Step 4 of 4 • Goals</Text>
      </View>
    </View>
  );
}

const styles = {
  topbar: {
    flexDirection: 'row' as const,
    justifyContent: 'space-between' as const,
    alignItems: 'center' as const,
    marginBottom: 32,
  },
  title: {
    color: '#111111',
    fontFamily: 'Montserrat_700Bold',
    fontSize: 24,
    lineHeight: 30,
    marginBottom: 8,
  },
  subtitle: {
    color: '#666B76',
    fontFamily: 'Montserrat_400Regular',
    fontSize: 14,
    lineHeight: 20,
  },
  goal: {
    width: '48%' as const,
    minHeight: 150,
    backgroundColor: '#FFFFFF',
    borderRadius: 16,
    borderWidth: 1.5,
    borderColor: '#E1E4EC',
    padding: 16,
  },
  selected: {
    borderColor: BLUE,
    backgroundColor: '#EEF1FB',
  },
  iconBox: {
    width: 34,
    height: 34,
    borderRadius: 10,
    backgroundColor: '#EEF0F5',
    alignItems: 'center' as const,
    justifyContent: 'center' as const,
    marginBottom: 10,
  },
  iconBoxSelected: {
    backgroundColor: '#DCE3F7',
  },
  goalTitle: {
    color: '#20232A',
    fontFamily: 'Montserrat_700Bold',
    fontSize: 15,
    lineHeight: 19,
    marginBottom: 6,
  },
  goalDesc: {
    color: '#666B76',
    fontFamily: 'Montserrat_400Regular',
    fontSize: 12,
    lineHeight: 16,
  },
  cta: {
    height: 56,
    borderRadius: 14,
    backgroundColor: BLUE,
    flexDirection: 'row' as const,
    alignItems: 'center' as const,
    justifyContent: 'center' as const,
    gap: 8,
  },
  ctaText: {
    color: '#FFFFFF',
    fontFamily: 'Montserrat_600SemiBold',
    fontSize: 16,
  },
  helper: {
    textAlign: 'center' as const,
    color: '#969AA3',
    fontFamily: 'Montserrat_400Regular',
    fontSize: 13,
    marginTop: 14,
  },
};