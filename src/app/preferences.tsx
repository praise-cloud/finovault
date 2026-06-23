import { router } from 'expo-router';
import { useState } from 'react';
import { View, Text, Pressable, ScrollView, Switch, Alert, ActivityIndicator } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { usePreferencesStore } from '@/stores/preferences-store';

const ROLES = [
  { key: 'individual', label: 'Individual', icon: 'person' as const },
  { key: 'sme', label: 'SME', icon: 'store' as const },
  { key: 'entrepreneur', label: 'Woman Entrepreneur', icon: 'female' as const },
  { key: 'freelancer', label: 'Freelancer', icon: 'work' as const },
];

const GOALS = [
  { key: 'wealth', label: 'Wealth Growth', desc: 'Maximize returns with AI-driven investment strategies.', icon: 'trending-up' as const },
  { key: 'savings', label: 'Smart Savings', desc: 'Automated budgeting and rainy-day funds.', icon: 'savings' as const },
  { key: 'fraud', label: 'Fraud Protection', desc: '24/7 bank-grade monitoring and alerts.', icon: 'shield' as const },
  { key: 'sme-analytics', label: 'SME Analytics', desc: 'Deep insights into business cashflow and vendor health.', icon: 'analytics' as const },
];

export default function Preferences() {
  const [isSaving, setIsSaving] = useState(false);
  const selectedRole = usePreferencesStore((s) => s.role);
  const selectedGoals = usePreferencesStore((s) => s.goals);
  const aiInsights = usePreferencesStore((s) => s.aiInsights);
  const securityAlerts = usePreferencesStore((s) => s.securityAlerts);
  const setRole = usePreferencesStore((s) => s.setRole);
  const toggleGoal = usePreferencesStore((s) => s.toggleGoal);
  const setAiInsights = usePreferencesStore((s) => s.setAiInsights);
  const setSecurityAlerts = usePreferencesStore((s) => s.setSecurityAlerts);
  const savePreferences = usePreferencesStore((s) => s.savePreferences);

  const handleContinue = async () => {
    setIsSaving(true);
    try {
      await savePreferences();
      router.push('/signup');
    } catch (e: any) {
      Alert.alert('Error', e.message);
    } finally {
      setIsSaving(false);
    }
  };

  return (
    <View className="flex-1 bg-background">
      <View className="flex-row items-center px-margin-mobile pt-14 pb-4 bg-background">
        <Pressable onPress={() => router.back()} className="mr-2">
          <MaterialIcons name="arrow-back" size={24} color="#000f22" />
        </Pressable>
        <Text className="flex-1 text-headline-lg-mobile text-primary font-semibold">Finovault AI</Text>
        <View className="h-1 w-24 bg-surface-container-high rounded-full overflow-hidden">
          <View className="h-full w-2/3 bg-secondary rounded-full" />
        </View>
      </View>

      <ScrollView className="flex-1 px-margin-mobile" showsVerticalScrollIndicator={false} contentContainerStyle={{ paddingBottom: 160, paddingTop: 24 }}>
        <View className="mb-10">
          <Text className="text-headline-lg-mobile text-primary mb-2">Let's personalize your experience</Text>
          <Text className="text-body-md text-on-surface-variant">Help us tailor our AI insights to your specific professional needs and financial landscape.</Text>
        </View>

        <View className="mb-12">
          <Text className="text-label-md text-outline uppercase tracking-widest mb-6">WHO ARE YOU?</Text>
          <View className="flex-row flex-wrap" style={{ marginHorizontal: -8 }}>
            {ROLES.map((role) => {
              const selected = selectedRole === role.key;
              return (
                <View key={role.key} className="w-1/2" style={{ padding: 8 }}>
                  <Pressable
                    onPress={() => setRole(role.key)}
                    className={`items-center p-6 rounded-xl ${selected ? 'bg-[#f0fffb] border border-secondary' : 'bg-white border border-[#E6EBF1]'}`}
                    style={{ shadowColor: '#000', shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.04, shadowRadius: 20, elevation: 2, transform: [{ scale: selected ? 0.98 : 1 }] }}
                  >
                    <View className={`w-12 h-12 rounded-full items-center justify-center mb-4 ${selected ? 'bg-secondary-container' : 'bg-surface-container'}`}>
                      <MaterialIcons name={role.icon} size={24} color="#006b5a" />
                    </View>
                    <Text className="text-label-md text-on-surface text-center">{role.label}</Text>
                  </Pressable>
                </View>
              );
            })}
          </View>
        </View>

        <View className="mb-12">
          <Text className="text-label-md text-outline uppercase tracking-widest mb-6">WHAT ARE YOUR FINANCIAL GOALS?</Text>
          <View className="gap-4">
            {GOALS.map((goal) => {
              const selected = selectedGoals.includes(goal.key);
              return (
                <Pressable
                  key={goal.key}
                  onPress={() => toggleGoal(goal.key)}
                  className={`p-8 rounded-xl ${selected ? 'bg-[#f0fffb] border border-secondary' : 'bg-white border border-[#E6EBF1]'}`}
                  style={{ shadowColor: '#000', shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.04, shadowRadius: 20, elevation: 2 }}
                >
                  {goal.key === 'sme-analytics' ? (
                    <View className="flex-row items-center">
                      <View className="flex-1">
                        <Text className="text-headline-md text-primary mb-1">{goal.label}</Text>
                        <Text className="text-body-md text-on-surface-variant">{goal.desc}</Text>
                      </View>
                      <MaterialIcons name={goal.icon} size={40} color="#006b5a" />
                    </View>
                  ) : (
                    <>
                      <MaterialIcons name={goal.icon} size={28} color="#006b5a" style={{ marginBottom: 8 }} />
                      <Text className="text-headline-md text-primary mb-1">{goal.label}</Text>
                      <Text className="text-body-md text-on-surface-variant">{goal.desc}</Text>
                    </>
                  )}
                </Pressable>
              );
            })}
          </View>
        </View>

        <View className="mb-16">
          <View className="bg-white rounded-2xl p-8 border border-[#E6EBF1]" style={{ shadowColor: '#000', shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.04, shadowRadius: 20, elevation: 2 }}>
            <Text className="text-headline-md text-primary mb-6">Notification Preferences</Text>
            <View className="flex-row items-center justify-between">
              <View className="flex-row gap-4 flex-1 items-start">
                <View className="p-2 bg-surface-container rounded-lg">
                  <MaterialIcons name="auto-awesome" size={20} color="#43474d" />
                </View>
                <View className="flex-1">
                  <Text className="text-label-md text-on-surface">AI Financial Insights</Text>
                  <Text className="text-caption text-on-surface-variant mt-0.5">Receive personalized suggestions based on your spending.</Text>
                </View>
              </View>
              <Switch value={aiInsights} onValueChange={() => setAiInsights(!aiInsights)} trackColor={{ false: '#e0e3e6', true: '#54f8d7' }} thumbColor="#ffffff" />
            </View>
            <View className="h-[1px] bg-surface-variant opacity-50 my-6" />
            <View className="flex-row items-center justify-between">
              <View className="flex-row gap-4 flex-1 items-start">
                <View className="p-2 bg-surface-container rounded-lg">
                  <MaterialIcons name="notifications-active" size={20} color="#43474d" />
                </View>
                <View className="flex-1">
                  <Text className="text-label-md text-on-surface">Critical Security Alerts</Text>
                  <Text className="text-caption text-on-surface-variant mt-0.5">Instant notification for large transactions or login attempts.</Text>
                </View>
              </View>
              <Switch value={securityAlerts} onValueChange={() => setSecurityAlerts(!securityAlerts)} trackColor={{ false: '#e0e3e6', true: '#54f8d7' }} thumbColor="#ffffff" />
            </View>
          </View>
        </View>
      </ScrollView>

      <View className="absolute bottom-0 left-0 right-0 px-margin-mobile pb-8 pt-4 bg-surface-bright/80">
        <Pressable
          onPress={handleContinue}
          disabled={isSaving}
          className="w-full py-4 rounded-xl items-center justify-center flex-row gap-2"
          style={{ backgroundColor: '#006b5a', shadowColor: 'rgba(0,107,90,0.2)', shadowOffset: { width: 0, height: 4 }, shadowRadius: 12, elevation: 4 }}
        >
          {isSaving ? (
            <ActivityIndicator size="small" color="#ffffff" />
          ) : (
            <>
              <Text className="text-on-primary text-label-md">Continue</Text>
              <MaterialIcons name="arrow-forward" size={20} color="#ffffff" />
            </>
          )}
        </Pressable>
        <Text className="text-caption text-outline text-center mt-3">Step 2 of 4 • Preferences</Text>
      </View>
    </View>
  );
}