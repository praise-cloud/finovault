import { useState } from 'react';
import { ScrollView, View, Text, Pressable, TextInput } from 'react-native';
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
        router.replace('/preferences');
      } catch {
        // silently fail
      } finally {
        setLoading(false);
      }
    }
  };

  const renderStep = () => {
    switch (step) {
      case 0:
        return (
          <View className="gap-6">
            <Text className="font-body-md text-body-md text-on-surface-variant">Tell us about yourself to personalize your experience.</Text>
            <View>
              <Text className="font-label-md text-label-md text-primary mb-2">Employment Status</Text>
              <View className="flex-row flex-wrap gap-3">
                {['Employed', 'Self-Employed', 'Business Owner', 'Student', 'Retired'].map((opt) => (
                  <Pressable
                    key={opt}
                    onPress={() => updateAnswer('employment_status', opt)}
                    className={`px-5 py-3 rounded-xl border ${answers.employment_status === opt ? 'bg-primary-container border-primary' : 'bg-surface-container-low border-outline-variant'}`}
                  >
                    <Text className={`font-label-md text-label-md ${answers.employment_status === opt ? 'text-white' : 'text-on-surface'}`}>{opt}</Text>
                  </Pressable>
                ))}
              </View>
            </View>
          </View>
        );
      case 1:
        return (
          <View className="gap-6">
            <Text className="font-body-md text-body-md text-on-surface-variant">This helps us understand your financial situation.</Text>
            <View>
              <Text className="font-label-md text-label-md text-primary mb-2">Annual Income (USD)</Text>
              <TextInput
                className="bg-surface-container-low border border-outline-variant rounded-xl px-4 py-3 font-body-md text-body-md text-primary"
                placeholder="e.g. 75000"
                placeholderTextColor="#74777e"
                keyboardType="numeric"
                value={answers.annual_income}
                onChangeText={(v) => updateAnswer('annual_income', v)}
              />
            </View>
            <View>
              <Text className="font-label-md text-label-md text-primary mb-2">Monthly Expenses (USD)</Text>
              <TextInput
                className="bg-surface-container-low border border-outline-variant rounded-xl px-4 py-3 font-body-md text-body-md text-primary"
                placeholder="e.g. 3000"
                placeholderTextColor="#74777e"
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
            <Text className="font-body-md text-body-md text-on-surface-variant">What are you saving towards?</Text>
            <View>
              <Text className="font-label-md text-label-md text-primary mb-2">Primary Savings Goal</Text>
              <View className="flex-row flex-wrap gap-3">
                {['Emergency Fund', 'Home Purchase', 'Retirement', 'Education', 'Travel', 'Business Growth'].map((opt) => (
                  <Pressable
                    key={opt}
                    onPress={() => updateAnswer('savings_goal', opt)}
                    className={`px-5 py-3 rounded-xl border ${answers.savings_goal === opt ? 'bg-primary-container border-primary' : 'bg-surface-container-low border-outline-variant'}`}
                  >
                    <Text className={`font-label-md text-label-md ${answers.savings_goal === opt ? 'text-white' : 'text-on-surface'}`}>{opt}</Text>
                  </Pressable>
                ))}
              </View>
            </View>
            <View>
              <Text className="font-label-md text-label-md text-primary mb-2">Investment Horizon</Text>
              <View className="flex-row flex-wrap gap-3">
                {['Short-term (<1 year)', 'Medium-term (1-5 years)', 'Long-term (5+ years)'].map((opt) => (
                  <Pressable
                    key={opt}
                    onPress={() => updateAnswer('investment_horizon', opt)}
                    className={`px-5 py-3 rounded-xl border ${answers.investment_horizon === opt ? 'bg-primary-container border-primary' : 'bg-surface-container-low border-outline-variant'}`}
                  >
                    <Text className={`font-label-md text-label-md ${answers.investment_horizon === opt ? 'text-white' : 'text-on-surface'}`}>{opt}</Text>
                  </Pressable>
                ))}
              </View>
            </View>
          </View>
        );
      case 3:
        return (
          <View className="gap-6">
            <Text className="font-body-md text-body-md text-on-surface-variant">How do you feel about investment risk?</Text>
            <View className="gap-4">
              {[
                { value: 'conservative', label: 'Conservative', desc: 'I prefer safe, stable returns', icon: 'shield' },
                { value: 'moderate', label: 'Moderate', desc: 'I balance risk and reward', icon: 'balance' },
                { value: 'aggressive', label: 'Aggressive', desc: 'I aim for high growth', icon: 'trending-up' },
              ].map((opt) => (
                <Pressable
                  key={opt.value}
                  onPress={() => updateAnswer('risk_level', opt.value)}
                  className={`p-5 rounded-xl border ${answers.risk_level === opt.value ? 'bg-primary-container border-primary' : 'bg-surface-container-low border-outline-variant'}`}
                >
                  <View className="flex-row items-center gap-4">
                    <MaterialIcons name={opt.icon as any} size={24} color={answers.risk_level === opt.value ? '#ffffff' : '#43474d'} />
                    <View className="flex-1">
                      <Text className={`font-label-md text-label-md font-bold ${answers.risk_level === opt.value ? 'text-white' : 'text-primary'}`}>{opt.label}</Text>
                      <Text className={`text-caption ${answers.risk_level === opt.value ? 'text-white/70' : 'text-on-surface-variant'}`}>{opt.desc}</Text>
                    </View>
                  </View>
                </Pressable>
              ))}
            </View>
          </View>
        );
    }
  };

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

      <View className="flex-row px-margin-mobile pt-6 pb-4 gap-2">
        {STEPS.map((s, i) => (
          <View key={i} className={`flex-1 h-1.5 rounded-full ${i <= step ? 'bg-secondary' : 'bg-outline-variant'}`} />
        ))}
      </View>

      <ScrollView className="flex-1 px-margin-mobile" contentContainerStyle={{ paddingBottom: 120 }}>
        <View className="mb-8">
          <View className="flex-row items-center gap-3 mb-2">
            <View className="w-10 h-10 rounded-full bg-secondary-container items-center justify-center">
              <MaterialIcons name={STEPS[step].icon as any} size={20} color="#00705e" />
            </View>
            <Text className="font-headline-lg text-headline-lg text-primary font-bold">{STEPS[step].title}</Text>
          </View>
          <Text className="font-label-md text-label-md text-on-surface-variant">Step {step + 1} of {STEPS.length}</Text>
        </View>

        {renderStep()}
      </ScrollView>

      <View className="px-margin-mobile pb-8 pt-2 bg-surface-bright border-t border-outline-variant/20">
        <Pressable
          onPress={handleNext}
          disabled={loading}
          className="w-full py-4 rounded-xl bg-secondary items-center justify-center active:scale-[0.98]"
        >
          <Text className="font-label-md text-label-md text-white font-bold">
            {loading ? 'Saving...' : step < STEPS.length - 1 ? 'Continue' : 'Complete Setup'}
          </Text>
        </Pressable>
      </View>
    </View>
  );
}
