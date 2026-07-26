import { useEffect, useState } from 'react';
import { ActivityIndicator, Pressable, ScrollView, Text, TextInput, View, useWindowDimensions, useColorScheme } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { router } from 'expo-router';
import { getFinancialProfile, updateFinancialProfile } from '@/src/lib/api/services/onboarding';
import { Logo } from '@/src/components/logo';

const BLUE = '#123B91';
const PAPER = '#F2F2F2';

const EMPLOYMENT_OPTIONS = ['Employed', 'Self-Employed', 'Business Owner', 'Student', 'Retired'];

// Note: the reference mockup shows "Conservation" / "Moderation" — these read as typos
// for the standard financial-risk terms. Using the correct terms here; swap the `label`
// strings below if you specifically want the mockup's wording instead.
const RISK_OPTIONS = [
  { value: 'conservative', label: 'Conservative' },
  { value: 'moderate', label: 'Moderate' },
  { value: 'aggressive', label: 'Aggressive' },
];

export default function FinancialProfile() {
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';
  const { width } = useWindowDimensions();
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [profile, setProfile] = useState<Record<string, any>>({
    employment_status: '',
    annual_income: '',
    monthly_expenses: '',
    risk_level: '',
  });

  useEffect(() => {
    getFinancialProfile()
      .then((data: any) => {
        if (data) setProfile((prev: any) => ({ ...prev, ...data }));
      })
      .catch(() => {})
      .finally(() => setLoading(false));
  }, []);

  const updateField = (key: string, value: string) => {
    setProfile((prev: any) => ({ ...prev, [key]: value }));
  };

  const handleSave = async () => {
    setSaving(true);
    try {
      await updateFinancialProfile(profile);
      router.push('/financial-interview');
    } catch {
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <View style={{ flex: 1, backgroundColor: isDark ? '#08142E' : PAPER, alignItems: 'center', justifyContent: 'center' }}>
        <ActivityIndicator size="large" color={isDark ? '#D4AF37' : BLUE} />
      </View>
    );
  }

  return (
    <View style={{ flex: 1, backgroundColor: isDark ? '#08142E' : PAPER, alignItems: 'center' }}>
      <View style={{ width: Math.min(width, 390), flex: 1, backgroundColor: isDark ? '#08142E' : PAPER }}>
        <View style={{ paddingHorizontal: 24, paddingTop: 60 }}>
          <View style={styles.topbar}>
            <Pressable onPress={() => router.back()} hitSlop={12}>
              <MaterialIcons name="arrow-back" size={24} color={isDark ? '#D4AF37' : BLUE} />
            </Pressable>
            <Logo width={26} height={23.5} color={isDark ? '#D4AF37' : BLUE} />
          </View>
        </View>

        <ScrollView
          showsVerticalScrollIndicator={false}
          contentContainerStyle={{ paddingHorizontal: 24, paddingBottom: 24 }}
        >
          <Text style={[styles.title, { color: isDark ? '#FFFFFF' : '#111111' }]}>Your financial profile</Text>
          <Text style={[styles.subtitle, { color: isDark ? '#B0B0B0' : '#666B76' }]}>Review and update your financial information.</Text>

          <View style={{ marginTop: 28 }}>
            <Text style={[styles.label, { color: isDark ? '#FFFFFF' : '#111111' }]}>Employment Status</Text>
            <View style={styles.chipRow}>
              {EMPLOYMENT_OPTIONS.map((opt) => {
                const active = profile.employment_status === opt;
                return (
                  <Pressable
                    key={opt}
                    onPress={() => updateField('employment_status', opt)}
                    style={[styles.chip, { backgroundColor: isDark ? '#1A1A1A' : '#FFFFFF' }, active && styles.chipActive]}
                  >
                    <Text style={[styles.chipText, active && styles.chipTextActive]}>{opt}</Text>
                  </Pressable>
                );
              })}
            </View>
          </View>

          <View style={{ marginTop: 24 }}>
            <Text style={[styles.label, { color: isDark ? '#FFFFFF' : '#111111' }]}>Annual Income (MUR)</Text>
            <TextInput
              style={[styles.input, { backgroundColor: isDark ? '#1A1A1A' : '#FFFFFF', borderColor: isDark ? '#2A2A2A' : '#C9CEDD', color: isDark ? '#FFFFFF' : '#111111' }]}
              placeholder="e.g. 750,000"
              placeholderTextColor={isDark ? '#6B6F7A' : '#9AA0AC'}
              keyboardType="numeric"
              value={profile.annual_income}
              onChangeText={(v) => updateField('annual_income', v)}
            />
          </View>

          <View style={{ marginTop: 24 }}>
            <Text style={[styles.label, { color: isDark ? '#FFFFFF' : '#111111' }]}>Monthly Expenses (MUR)</Text>
            <TextInput
              style={[styles.input, { backgroundColor: isDark ? '#1A1A1A' : '#FFFFFF', borderColor: isDark ? '#2A2A2A' : '#C9CEDD', color: isDark ? '#FFFFFF' : '#111111' }]}
              placeholder="e.g. 30,000"
              placeholderTextColor={isDark ? '#6B6F7A' : '#9AA0AC'}
              keyboardType="numeric"
              value={profile.monthly_expenses}
              onChangeText={(v) => updateField('monthly_expenses', v)}
            />
          </View>

          <View style={{ marginTop: 24 }}>
            <Text style={[styles.label, { color: isDark ? '#FFFFFF' : '#111111' }]}>Risk Tolerance</Text>
            <View style={styles.chipRow}>
              {RISK_OPTIONS.map((opt) => {
                const active = profile.risk_level === opt.value;
                return (
                  <Pressable
                    key={opt.value}
                    onPress={() => updateField('risk_level', opt.value)}
                    style={[styles.chip, { backgroundColor: isDark ? '#1A1A1A' : '#FFFFFF' }, active && styles.chipActive]}
                  >
                    <Text style={[styles.chipText, active && styles.chipTextActive]}>{opt.label}</Text>
                  </Pressable>
                );
              })}
            </View>
          </View>
        </ScrollView>

        <View style={{ paddingHorizontal: 24, paddingBottom: 32, paddingTop: 8 }}>
          <Pressable onPress={handleSave} disabled={saving} style={styles.cta}>
            {saving ? (
              <ActivityIndicator color="#FFFFFF" size="small" />
            ) : (
              <>
                <Text style={styles.ctaText}>Continue</Text>
                <MaterialIcons name="arrow-forward" size={18} color="#FFFFFF" />
              </>
            )}
          </Pressable>
          <Text style={[styles.helper, { color: isDark ? '#8C8F9E' : '#969AA3' }]}>Step 3 of 4 • Financial Profile</Text>
        </View>
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
    textAlign: 'center' as const,
    marginBottom: 8,
  },
  subtitle: {
    color: '#666B76',
    fontFamily: 'Montserrat_400Regular',
    fontSize: 14,
    textAlign: 'center' as const,
  },
  label: {
    color: '#111111',
    fontFamily: 'Montserrat_700Bold',
    fontSize: 14,
    marginBottom: 12,
  },
  chipRow: {
    flexDirection: 'row' as const,
    flexWrap: 'wrap' as const,
    gap: 10,
  },
  chip: {
    borderRadius: 10,
    borderWidth: 1.5,
    borderColor: BLUE,
    backgroundColor: '#FFFFFF',
    paddingHorizontal: 16,
    paddingVertical: 10,
  },
  chipActive: {
    backgroundColor: BLUE,
  },
  chipText: {
    color: BLUE,
    fontFamily: 'Montserrat_500Medium',
    fontSize: 14,
  },
  chipTextActive: {
    color: '#FFFFFF',
  },
  input: {
    height: 52,
    borderRadius: 10,
    borderWidth: 1.5,
    borderColor: '#C9CEDD',
    backgroundColor: '#FFFFFF',
    paddingHorizontal: 16,
    fontSize: 15,
    fontFamily: 'Montserrat_400Regular',
    color: '#111111',
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
    marginTop: 12,
  },
};