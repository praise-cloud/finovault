import { useEffect, useState } from 'react';
import { ScrollView, View, Text, Pressable, TextInput, ActivityIndicator } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { router } from 'expo-router';
import { getFinancialProfile, updateFinancialProfile } from '@/lib/api/services/onboarding';

export default function FinancialProfile() {
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
      // silently fail
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <View className="flex-1 bg-surface-bright items-center justify-center">
        <ActivityIndicator size="large" color="#006b5a" />
      </View>
    );
  }

  return (
    <View className="flex-1 bg-surface-bright">
      <View className="pt-14 pb-3 px-margin-mobile bg-surface-bright" style={{ elevation: 4, shadowColor: '#000', shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.04 }}>
        <View className="flex-row items-center justify-between">
          <Pressable onPress={() => router.back()} className="w-10 h-10 rounded-full bg-surface-container items-center justify-center active:scale-90">
            <MaterialIcons name="arrow-back" size={20} color="#181c1e" />
          </Pressable>
          <Text className="font-headline-md text-headline-md text-primary font-bold">Financial Profile</Text>
          <View className="w-10" />
        </View>
      </View>

      <ScrollView className="flex-1 px-margin-mobile" contentContainerStyle={{ paddingBottom: 120 }}>
        <View className="mt-6 mb-8">
          <Text className="font-headline-lg text-headline-lg text-primary mb-2">Your Financial Profile</Text>
          <Text className="font-body-md text-body-md text-on-surface-variant">Review and update your financial information.</Text>
        </View>

        <View className="gap-6">
          <View>
            <Text className="font-label-md text-label-md text-primary mb-3">Employment Status</Text>
            <View className="flex-row flex-wrap gap-3">
              {['Employed', 'Self-Employed', 'Business Owner', 'Student', 'Retired'].map((opt) => (
                <Pressable
                  key={opt}
                  onPress={() => updateField('employment_status', opt)}
                  className={`px-5 py-3 rounded-xl border ${profile.employment_status === opt ? 'bg-primary-container border-primary' : 'bg-surface-container-low border-outline-variant'}`}
                >
                  <Text className={`font-label-md text-label-md ${profile.employment_status === opt ? 'text-white' : 'text-on-surface'}`}>{opt}</Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View>
            <Text className="font-label-md text-label-md text-primary mb-2">Annual Income (USD)</Text>
            <TextInput
              className="bg-surface-container-low border border-outline-variant rounded-xl px-4 py-3 font-body-md text-body-md text-primary"
              placeholder="e.g. 75000"
              placeholderTextColor="#74777e"
              keyboardType="numeric"
              value={profile.annual_income}
              onChangeText={(v) => updateField('annual_income', v)}
            />
          </View>

          <View>
            <Text className="font-label-md text-label-md text-primary mb-2">Monthly Expenses (USD)</Text>
            <TextInput
              className="bg-surface-container-low border border-outline-variant rounded-xl px-4 py-3 font-body-md text-body-md text-primary"
              placeholder="e.g. 3000"
              placeholderTextColor="#74777e"
              keyboardType="numeric"
              value={profile.monthly_expenses}
              onChangeText={(v) => updateField('monthly_expenses', v)}
            />
          </View>

          <View>
            <Text className="font-label-md text-label-md text-primary mb-3">Primary Savings Goal</Text>
            <View className="flex-row flex-wrap gap-3">
              {['Emergency Fund', 'Home Purchase', 'Retirement', 'Education', 'Travel', 'Business Growth'].map((opt) => (
                <Pressable
                  key={opt}
                  onPress={() => updateField('savings_goal', opt)}
                  className={`px-5 py-3 rounded-xl border ${profile.savings_goal === opt ? 'bg-primary-container border-primary' : 'bg-surface-container-low border-outline-variant'}`}
                >
                  <Text className={`font-label-md text-label-md ${profile.savings_goal === opt ? 'text-white' : 'text-on-surface'}`}>{opt}</Text>
                </Pressable>
              ))}
            </View>
          </View>

          <View>
            <Text className="font-label-md text-label-md text-primary mb-3">Risk Tolerance</Text>
            <View className="gap-3">
              {[
                { value: 'conservative', label: 'Conservative' },
                { value: 'moderate', label: 'Moderate' },
                { value: 'aggressive', label: 'Aggressive' },
              ].map((opt) => (
                <Pressable
                  key={opt.value}
                  onPress={() => updateField('risk_level', opt.value)}
                  className={`p-4 rounded-xl border ${profile.risk_level === opt.value ? 'bg-primary-container border-primary' : 'bg-surface-container-low border-outline-variant'}`}
                >
                  <Text className={`font-label-md text-label-md font-bold ${profile.risk_level === opt.value ? 'text-white' : 'text-primary'}`}>{opt.label}</Text>
                </Pressable>
              ))}
            </View>
          </View>
        </View>
      </ScrollView>

      <View className="px-margin-mobile pb-8 pt-2 bg-surface-bright border-t border-outline-variant/20">
        <Pressable
          onPress={handleSave}
          disabled={saving}
          className="w-full py-4 rounded-xl bg-secondary items-center justify-center active:scale-[0.98]"
        >
          <Text className="font-label-md text-label-md text-white font-bold">{saving ? 'Saving...' : 'Save Changes'}</Text>
        </Pressable>
      </View>
    </View>
  );
}
