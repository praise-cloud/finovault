import { useState } from 'react';
import { ScrollView, View, Text, Pressable, TextInput, ActivityIndicator, useColorScheme } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { router } from 'expo-router';
import { submitFinancialInterview } from '@/lib/api/services/onboarding';

const STEPS = [
  { title: 'Your Profile', icon: 'person' },
  { title: 'Income & Expenses', icon: 'payments' },
  { title: 'Financial Goals', icon: 'flag' },
  { title: 'Risk Tolerance', icon: 'speed' },
];

export default function FinancialInterview() {
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';
  const [step, setStep] = useState(0);
  const [loading, setLoading] = useState(false);
  const [answers, setAnswers] = useState<Record<string, any>>({
    employment_status: '',
    annual_income: '',
    monthly_expenses: '',
    savings_goal: '',
    investment_horizon: '',
    risk_level: '',
  });

  const updateAnswer = (key: string, value: string) => {
    setAnswers((prev) => ({ ...prev, [key]: value }));
  };

  const handleNext = async () => {
    if (step < STEPS.length - 1) {
      setStep(step + 1);
    } else {
      setLoading(true);
      try {
        await submitFinancialInterview(answers);
        router.replace('/signup');
      } catch {
      } finally {
        setLoading(false);
      }
    }
  };

  const renderStep = () => {
    const muted = isDark ? 'rgba(255,255,255,0.6)' : '#6B6F76';
    const textColor = isDark ? '#FFFFFF' : '#1A1A1A';
    const inputBg = isDark ? '#1A1A1A' : '#F7F9FC';
    const inputBorder = isDark ? 'rgba(255,255,255,0.12)' : '#E4E7EE';
    const chipBg = isDark ? 'rgba(255,255,255,0.08)' : '#EEF0F5';

    switch (step) {
      case 0:
        return (
          <View className="gap-6">
            <Text className="font-body" style={{ fontSize: 15, color: muted }}>Tell us about yourself to personalize your experience.</Text>
            <View>
              <Text className="font-body-semibold" style={{ fontSize: 14, color: textColor, marginBottom: 8 }}>Employment Status</Text>
              <View className="flex-row flex-wrap gap-3">
                {['Employed', 'Self-Employed', 'Business Owner', 'Student', 'Retired'].map((opt) => {
                  const isActive = answers.employment_status === opt;
                  return (
                    <Pressable
                      key={opt}
                      onPress={() => updateAnswer('employment_status', opt)}
                      style={{ borderRadius: 9999, paddingHorizontal: 20, paddingVertical: 12, backgroundColor: isActive ? 'rgba(8,20,46,0.08)' : chipBg, borderWidth: 1.5, borderColor: isActive ? '#08142E' : inputBorder }}
                    >
                      <Text className="font-body-semibold" style={{ fontSize: 14, color: isActive ? '#08142E' : textColor }}>{opt}</Text>
                    </Pressable>
                  );
                })}
              </View>
            </View>
          </View>
        );
      case 1:
        return (
          <View className="gap-6">
            <Text className="font-body" style={{ fontSize: 15, color: muted }}>This helps us understand your financial situation.</Text>
            <View>
              <Text className="font-body-semibold" style={{ fontSize: 14, color: textColor, marginBottom: 8 }}>Annual Income (USD)</Text>
              <TextInput
                style={{ backgroundColor: inputBg, borderWidth: 1, borderColor: inputBorder, borderRadius: 14, paddingHorizontal: 16, paddingVertical: 12, fontSize: 15, fontFamily: 'Montserrat_400Regular', color: textColor }}
                placeholder="e.g. 75000"
                placeholderTextColor={muted}
                keyboardType="numeric"
                value={answers.annual_income}
                onChangeText={(v) => updateAnswer('annual_income', v)}
              />
            </View>
            <View>
              <Text className="font-body-semibold" style={{ fontSize: 14, color: textColor, marginBottom: 8 }}>Monthly Expenses (USD)</Text>
              <TextInput
                style={{ backgroundColor: inputBg, borderWidth: 1, borderColor: inputBorder, borderRadius: 14, paddingHorizontal: 16, paddingVertical: 12, fontSize: 15, fontFamily: 'Montserrat_400Regular', color: textColor }}
                placeholder="e.g. 3000"
                placeholderTextColor={muted}
                keyboardType="numeric"
                value={answers.monthly_expenses}
                onChangeText={(v) => updateAnswer('monthly_expenses', v)}
              />
            </View>
          </View>
        );
      case 2:
        return (
          <View className="gap-6">
            <Text className="font-body" style={{ fontSize: 15, color: muted }}>What are you saving towards?</Text>
            <View>
              <Text className="font-body-semibold" style={{ fontSize: 14, color: textColor, marginBottom: 8 }}>Primary Savings Goal</Text>
              <View className="flex-row flex-wrap gap-3">
                {['Emergency Fund', 'Home Purchase', 'Retirement', 'Education', 'Travel', 'Business Growth'].map((opt) => {
                  const isActive = answers.savings_goal === opt;
                  return (
                    <Pressable
                      key={opt}
                      onPress={() => updateAnswer('savings_goal', opt)}
                      style={{ borderRadius: 9999, paddingHorizontal: 20, paddingVertical: 12, backgroundColor: isActive ? 'rgba(8,20,46,0.08)' : chipBg, borderWidth: 1.5, borderColor: isActive ? '#08142E' : inputBorder }}
                    >
                      <Text className="font-body-semibold" style={{ fontSize: 14, color: isActive ? '#08142E' : textColor }}>{opt}</Text>
                    </Pressable>
                  );
                })}
              </View>
            </View>
            <View>
              <Text className="font-body-semibold" style={{ fontSize: 14, color: textColor, marginBottom: 8 }}>Investment Horizon</Text>
              <View className="flex-row flex-wrap gap-3">
                {['Short-term (<1 year)', 'Medium-term (1-5 years)', 'Long-term (5+ years)'].map((opt) => {
                  const isActive = answers.investment_horizon === opt;
                  return (
                    <Pressable
                      key={opt}
                      onPress={() => updateAnswer('investment_horizon', opt)}
                      style={{ borderRadius: 9999, paddingHorizontal: 20, paddingVertical: 12, backgroundColor: isActive ? 'rgba(8,20,46,0.08)' : chipBg, borderWidth: 1.5, borderColor: isActive ? '#08142E' : inputBorder }}
                    >
                      <Text className="font-body-semibold" style={{ fontSize: 14, color: isActive ? '#08142E' : textColor }}>{opt}</Text>
                    </Pressable>
                  );
                })}
              </View>
            </View>
          </View>
        );
      case 3:
        return (
          <View className="gap-6">
            <Text className="font-body" style={{ fontSize: 15, color: muted }}>How do you feel about investment risk?</Text>
            <View className="gap-4">
              {[
                { value: 'conservative', label: 'Conservative', desc: 'I prefer safe, stable returns', icon: 'shield' },
                { value: 'moderate', label: 'Moderate', desc: 'I balance risk and reward', icon: 'balance' },
                { value: 'aggressive', label: 'Aggressive', desc: 'I aim for high growth', icon: 'trending-up' },
              ].map((opt) => {
                const isActive = answers.risk_level === opt.value;
                return (
                  <Pressable
                    key={opt.value}
                    onPress={() => updateAnswer('risk_level', opt.value)}
                    style={{ borderRadius: 18, padding: 20, backgroundColor: isActive ? 'rgba(8,20,46,0.08)' : 'transparent', borderWidth: 1.5, borderColor: isActive ? '#08142E' : inputBorder }}
                  >
                    <View className="flex-row items-center gap-4">
                      <MaterialIcons name={opt.icon as any} size={24} color={isActive ? '#08142E' : muted} />
                      <View className="flex-1">
                        <Text className="font-body-semibold" style={{ fontSize: 15, color: isActive ? '#08142E' : textColor }}>{opt.label}</Text>
                        <Text className="font-body" style={{ fontSize: 13, color: isActive ? 'rgba(8,20,46,0.7)' : muted, marginTop: 2 }}>{opt.desc}</Text>
                      </View>
                    </View>
                  </Pressable>
                );
              })}
            </View>
          </View>
        );
    }
  };

  const bg = isDark ? '#08142E' : '#F7F9FC';
  const textColor = isDark ? '#FFFFFF' : '#1A1A1A';
  const muted = isDark ? 'rgba(255,255,255,0.6)' : '#6B6F76';

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

      <View className="flex-row px-margin-mobile pt-6 pb-4 gap-2">
        {STEPS.map((s, i) => (
          <View key={i} className="flex-1 h-1.5 rounded-full" style={{ backgroundColor: i <= step ? '#08142E' : isDark ? 'rgba(255,255,255,0.12)' : '#E4E7EE' }} />
        ))}
      </View>

      <ScrollView className="flex-1 px-margin-mobile" contentContainerStyle={{ paddingBottom: 120 }}>
        <View className="mb-8">
          <View className="flex-row items-center gap-3 mb-2">
            <View className="w-10 h-10 rounded-full items-center justify-center" style={{ backgroundColor: isDark ? 'rgba(8,20,46,0.15)' : 'rgba(8,20,46,0.08)' }}>
              <MaterialIcons name={STEPS[step].icon as any} size={20} color="#08142E" />
            </View>
            <Text className="font-body-bold" style={{ fontSize: 22, color: textColor }}>{STEPS[step].title}</Text>
          </View>
          <Text className="font-body" style={{ fontSize: 13, color: muted }}>Step {step + 1} of {STEPS.length}</Text>
        </View>

        {renderStep()}
      </ScrollView>

      <View className="px-margin-mobile pb-8 pt-2" style={{ backgroundColor: bg, borderTopWidth: 1, borderTopColor: isDark ? 'rgba(255,255,255,0.08)' : '#E4E7EE' }}>
        <Pressable
          onPress={handleNext}
          disabled={loading}
          className="w-full py-4 items-center justify-center active:scale-[0.98]"
          style={{ backgroundColor: 'rgba(8,20,46,0.08)', borderRadius: 9999, borderWidth: 1.5, borderColor: '#08142E' }}
        >
          {loading ? (
            <ActivityIndicator size="small" color="#08142E" />
          ) : (
            <Text className="font-body-semibold" style={{ fontSize: 16, color: '#08142E' }}>
              {step < STEPS.length - 1 ? 'Continue' : 'Complete Setup'}
            </Text>
          )}
        </Pressable>
      </View>
    </View>
  );
}
