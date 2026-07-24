import { Stack, router } from 'expo-router';
import { useEffect, useState, createContext, useContext } from 'react';
import { View, Pressable, Text, Modal, ScrollView, useColorScheme } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { useAuthStore } from '@/stores/auth-store';
import { useDashboardStore } from '@/stores/dashboard-store';
import { BottomTabBar } from '@/components/bottom-tab-bar';

type SheetContent = {
  title: string;
  children: React.ReactNode;
} | null;

type SheetContextType = {
  showSheet: (content: SheetContent) => void;
  hideSheet: () => void;
};

const SheetContext = createContext<SheetContextType>({ showSheet: () => {}, hideSheet: () => {} });

export function useSheet() {
  return useContext(SheetContext);
}

export default function TabsLayout() {
  const [activeTab, setActiveTab] = useState('home');
  const [sheetContent, setSheetContent] = useState<SheetContent>(null);
  const isAuthenticated = useAuthStore((s) => s.isAuthenticated);
  const loadSummary = useDashboardStore((s) => s.loadSummary);
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';

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
      case 'home':
        router.push('/(tabs)');
        break;
      case 'insights':
        router.push('/(tabs)/ai-analysis');
        break;
      case 'vault':
        router.push('/(tabs)/vault');
        break;
      case 'pay':
        router.push('/(tabs)/pay');
        break;
      case 'profile':
        router.push('/(tabs)/profile');
        break;
    }
  };

  return (
    <SheetContext.Provider value={{ showSheet: setSheetContent, hideSheet: () => setSheetContent(null) }}>
      <View className={`flex-1 ${isDark ? 'bg-[#0A1F5C]' : 'bg-surface-bright'}`}>
        <Stack screenOptions={{ headerShown: false }}>
          <Stack.Screen name="index" />
          <Stack.Screen name="vault" />
          <Stack.Screen name="pay" />
          <Stack.Screen name="wealth-growth" />
          <Stack.Screen name="smart-savings" />
          <Stack.Screen name="savings-goals" />
          <Stack.Screen name="transactions" />
          <Stack.Screen name="ai-coach" />
          <Stack.Screen name="fraud-protection" />
          <Stack.Screen name="sme-dashboard" />
          <Stack.Screen name="sme-analytics" />
          <Stack.Screen name="entrepreneur" />
          <Stack.Screen name="freelancer" />
          <Stack.Screen name="profile" />
          <Stack.Screen name="guardrails" />
          <Stack.Screen name="audit-report" />
          <Stack.Screen name="security" />
          <Stack.Screen name="two-factor-auth" />
          <Stack.Screen name="last-login" />
          <Stack.Screen name="linked-accounts" />
          <Stack.Screen name="account-link" />
          <Stack.Screen name="data-privacy" />
          <Stack.Screen name="ai-analysis" />
          <Stack.Screen name="business-health" />
          <Stack.Screen name="business-forecast" />
          <Stack.Screen name="business-vendors" />
          <Stack.Screen name="business-ai-advice" />
          <Stack.Screen name="round-up-details" />
        </Stack>

        <BottomTabBar activeTab={activeTab} onTabPress={handleTabPress} />

        {sheetContent && (
          <Modal visible transparent animationType="slide" onRequestClose={() => setSheetContent(null)}>
            <Pressable className="flex-1 bg-black/40" onPress={() => setSheetContent(null)}>
              <Pressable className="flex-1 justify-end" onPress={() => {}}>
                <Pressable
                  className={`${isDark ? 'bg-[#1A1A1A]' : 'bg-white'} rounded-t-3xl`}
                  style={{ maxHeight: '80%', boxShadow: '0 -8px 24px rgba(0,0,0,0.1)', elevation: 16 }}
                  onPress={() => {}}
                >
                  <View className="items-center pt-3 pb-1">
                    <View className="w-10 h-1 rounded-full bg-outline/40" />
                  </View>
                  <View className="flex-row items-center justify-between px-6 py-4 border-b border-outline-variant/20">
                    <Text className="font-headline-md text-primary font-bold">{sheetContent.title}</Text>
                    <Pressable onPress={() => setSheetContent(null)} className="w-8 h-8 rounded-full bg-surface-variant items-center justify-center active:scale-90">
                      <MaterialIcons name="close" size={18} color="#43474d" />
                    </Pressable>
                  </View>
                  <ScrollView className="px-6 py-4" contentContainerStyle={{ paddingBottom: 40 }}>
                    {sheetContent.children}
                  </ScrollView>
                </Pressable>
              </Pressable>
            </Pressable>
          </Modal>
        )}
      </View>
    </SheetContext.Provider>
  );
}
