import { Stack, router } from 'expo-router';
import { useEffect, useState } from 'react';
import { View } from 'react-native';
import { useAuthStore } from '@/stores/auth-store';
import { useDashboardStore } from '@/stores/dashboard-store';
import { BottomTabBar } from '@/components/bottom-tab-bar';

export default function TabsLayout() {
  const [activeTab, setActiveTab] = useState('dashboard');
  const isAuthenticated = useAuthStore((s) => s.isAuthenticated);
  const loadSummary = useDashboardStore((s) => s.loadSummary);

  useEffect(() => {
    if (!isAuthenticated) {
      router.replace('/');
      return;
    }
    loadSummary();
  }, [isAuthenticated, loadSummary]);

  const handleTabPress = (key: string) => {
    setActiveTab(key);
    switch (key) {
      case 'dashboard':
        router.push('/(tabs)');
        break;
      case 'protection':
        router.push('/(tabs)/fraud-protection');
        break;
      case 'profile':
        router.push('/(tabs)/profile');
        break;
    }
  };

  return (
    <View className="flex-1 bg-surface-bright">
      <Stack screenOptions={{ headerShown: false }}>
        <Stack.Screen name="index" />
        <Stack.Screen name="wealth-growth" />
        <Stack.Screen name="smart-savings" />
        <Stack.Screen name="fraud-protection" />
        <Stack.Screen name="sme-dashboard" />
        <Stack.Screen name="sme-analytics" />
        <Stack.Screen name="entrepreneur" />
        <Stack.Screen name="freelancer" />
        <Stack.Screen name="profile" />
      </Stack>
      <BottomTabBar activeTab={activeTab} onTabPress={handleTabPress} />
    </View>
  );
}