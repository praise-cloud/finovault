import { useEffect, useState } from 'react';
import { ScrollView, View, Text, Pressable, TextInput, ActivityIndicator, useColorScheme } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { router } from 'expo-router';
import { getFinancialProfile, updateFinancialProfile } from '@/lib/api/services/onboarding';

export default function FinancialProfile() {
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [profile, setProfile] = useState<Record<string, any>>({
    employment_status: '',
    annual_income: '',
    monthly_expenses: '',
    savings_goal: '',
    investment_horizon: '',
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
      router.back();
    } catch {
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <View className="flex-1 items-center justify-center" style={{ backgroundColor: isDark ? '#08142E' : '#F7F9FC' }}>
        <ActivityIndicator size="large" color="#08142E" />
      </View>
    );
  }

  const bg = isDark ? '#08142E' : '#F7F9FC';
  const textColor = isDark ? '#FFFFFF' : '#1A1A1A';
  const muted = isDark ? 'rgba(255,255,255,0.6)' : '#6B6F76';
  const inputBg = isDark ? '#1A1A1A' : '#F7F9FC';
  const inputBorder = isDark ? 'rgba(255,255,255,0.12)' : '#E4E7EE';
  const chipBg = isDark ? 'rgba(255,255,255,0.08)' : '#EEF0F5';

  return (
    <View className="flex-1" style={{ backgroundColor: bg }}>
      <View className="pt-14 pb-3 px-margin-mobile" style={{ backgroundColor: bg }}>
        <View className="flex-row items-center justify-between">
          <Pressable onPress={() => router.back()} className="w-10 h-10 items-center justify-center active:scale-90"
            style={{ backgroundColor: isDark ? 'rgba(255,255,255,0.08)' : '#EEF0F5', borderRadius: 9999 }}>
            <MaterialIcons name="arrow-back" size={20} color={textColor} />
          </Pressable>
          <Text className="font-body-bold" style={{ fontSize: 20, color: textColor }}>Financial Profile</Text>
          <View className="w-10" />
        </View>
      </View>

      <ScrollView className="flex-1 px-margin-mobile" contentContainerStyle={{ paddingBottom: 120 }}>
        <View className="mt-6 mb-8">
          <Text className="font-body-bold" style={{ fontSize: 28, color: textColor, marginBottom: 8 }}>Your Financial Profile</Text>
          <Text className="font-body" style={{ fontSize: 15, color: muted }}>Review and update your financial information.</Text>
        </View>

        <View className="gap-6">
          <View>
            <Text className="font-body-semibold" style={{ fontSize: 14, color: textColor, marginBottom: 12 }}>Employment Status</Text>
            <View className="flex-row flex-wrap gap-3">
              {['Employed', 'Self-Employed', 'Business Owner', 'Student', 'Retired'].map((opt) => {
                const isActive = profile.employment_status === opt;
                return (
                  <Pressable
                    key={opt}
                    onPress={() => updateField('employment_status', opt)}
                    style={{ borderRadius: 9999, paddingHorizontal: 20, paddingVertical: 12, backgroundColor: isActive ? 'rgba(8,20,46,0.08)' : chipBg, borderWidth: 1.5, borderColor: isActive ? '#08142E' : inputBorder }}
                  >
                    <Text className="font-body-semibold" style={{ fontSize: 14, color: isActive ? '#08142E' : textColor }}>{opt}</Text>
                  </Pressable>
                );
              })}
            </View>
          </View>

          <View>
            <Text className="font-body-semibold" style={{ fontSize: 14, color: textColor, marginBottom: 8 }}>Annual Income (USD)</Text>
            <TextInput
              style={{ backgroundColor: inputBg, borderWidth: 1, borderColor: inputBorder, borderRadius: 14, paddingHorizontal: 16, paddingVertical: 12, fontSize: 15, fontFamily: 'Montserrat_400Regular', color: textColor }}
              placeholder="e.g. 75000"
              placeholderTextColor={muted}
              keyboardType="numeric"
              value={profile.annual_income}
              onChangeText={(v) => updateField('annual_income', v)}
            />
          </View>

          <View>
            <Text className="font-body-semibold" style={{ fontSize: 14, color: textColor, marginBottom: 8 }}>Monthly Expenses (USD)</Text>
            <TextInput
              style={{ backgroundColor: inputBg, borderWidth: 1, borderColor: inputBorder, borderRadius: 14, paddingHorizontal: 16, paddingVertical: 12, fontSize: 15, fontFamily: 'Montserrat_400Regular', color: textColor }}
              placeholder="e.g. 3000"
              placeholderTextColor={muted}
              keyboardType="numeric"
              value={profile.monthly_expenses}
              onChangeText={(v) => updateField('monthly_expenses', v)}
            />
          </View>

          <View>
            <Text className="font-body-semibold" style={{ fontSize: 14, color: textColor, marginBottom: 12 }}>Primary Savings Goal</Text>
            <View className="flex-row flex-wrap gap-3">
              {['Emergency Fund', 'Home Purchase', 'Retirement', 'Education', 'Travel', 'Business Growth'].map((opt) => {
                const isActive = profile.savings_goal === opt;
                return (
                  <Pressable
                    key={opt}
                    onPress={() => updateField('savings_goal', opt)}
                    style={{ borderRadius: 9999, paddingHorizontal: 20, paddingVertical: 12, backgroundColor: isActive ? 'rgba(8,20,46,0.08)' : chipBg, borderWidth: 1.5, borderColor: isActive ? '#08142E' : inputBorder }}
                  >
                    <Text className="font-body-semibold" style={{ fontSize: 14, color: isActive ? '#08142E' : textColor }}>{opt}</Text>
                  </Pressable>
                );
              })}
            </View>
          </View>

          <View>
            <Text className="font-body-semibold" style={{ fontSize: 14, color: textColor, marginBottom: 12 }}>Risk Tolerance</Text>
            <View className="gap-3">
              {[
                { value: 'conservative', label: 'Conservative' },
                { value: 'moderate', label: 'Moderate' },
                { value: 'aggressive', label: 'Aggressive' },
              ].map((opt) => {
                const isActive = profile.risk_level === opt.value;
                return (
                  <Pressable
                    key={opt.value}
                    onPress={() => updateField('risk_level', opt.value)}
                    style={{ borderRadius: 18, padding: 16, backgroundColor: isActive ? 'rgba(8,20,46,0.08)' : 'transparent', borderWidth: 1.5, borderColor: isActive ? '#08142E' : inputBorder }}
                  >
                    <Text className="font-body-semibold" style={{ fontSize: 15, color: isActive ? '#08142E' : textColor }}>{opt.label}</Text>
                  </Pressable>
                );
              })}
            </View>
          </View>
        </View>
      </ScrollView>

      <View className="px-margin-mobile pb-8 pt-2" style={{ backgroundColor: bg, borderTopWidth: 1, borderTopColor: isDark ? 'rgba(255,255,255,0.08)' : '#E4E7EE' }}>
        <Pressable
          onPress={handleSave}
          disabled={saving}
          className="w-full py-4 items-center justify-center active:scale-[0.98]"
          style={{ backgroundColor: 'rgba(8,20,46,0.08)', borderRadius: 9999, borderWidth: 1.5, borderColor: '#08142E' }}
        >
          <Text className="font-body-semibold" style={{ fontSize: 16, color: '#08142E' }}>
            {saving ? 'Saving...' : 'Save Changes'}
          </Text>
        </Pressable>
      </View>
    </View>
  );
}
