import { BottomTabBar } from "@/src/components/bottom-tab-bar";
import { useAuthStore } from "@/src/stores/auth-store";
import { useDashboardStore } from "@/src/stores/dashboard-store";
import { usePreferencesStore } from "@/src/stores/preferences-store";
import { MaterialIcons } from "@expo/vector-icons";
import { Stack, router } from "expo-router";
import { createContext, useContext, useEffect, useRef, useState } from "react";
import {
    ActivityIndicator,
    Modal,
    Pressable,
    ScrollView,
    Text,
    View,
    useColorScheme,
} from "react-native";

type SheetContent = {
  title: string;
  children: React.ReactNode;
} | null;

type SheetContextType = {
  showSheet: (content: SheetContent) => void;
  hideSheet: () => void;
};

const SheetContext = createContext<SheetContextType>({
  showSheet: () => {},
  hideSheet: () => {},
});

export function useSheet() {
  return useContext(SheetContext);
}

const ROLE_HOME: Record<string, string> = {
  individual: "home",
  sme: "sme-dashboard",
  entrepreneur: "entrepreneur",
  freelancer: "freelancer",
};

const ROLE_ROUTE: Record<string, string> = {
  individual: "/(tabs)",
  sme: "/(tabs)/sme-dashboard",
  entrepreneur: "/(tabs)/entrepreneur",
  freelancer: "/(tabs)/freelancer",
};

const ROLE_LOADER: Record<string, (s: any) => () => Promise<void>> = {
  individual: (s) => s.loadSummary,
  sme: (s) => s.loadSmeDashboard,
  entrepreneur: (s) => s.loadEntrepreneur,
  freelancer: (s) => s.loadFreelancer,
};

export default function TabsLayout() {
  const [activeTab, setActiveTab] = useState("home");
  const [sheetContent, setSheetContent] = useState<SheetContent>(null);
  const isAuthenticated = useAuthStore((s) => s.isAuthenticated);
  const role = usePreferencesStore((s) => s.role);
  const prefsLoaded = usePreferencesStore((s) => !s.isLoading);
  const loadPreferences = usePreferencesStore((s) => s.loadPreferences);
  const dashboardStore = useDashboardStore();
  const colorScheme = useColorScheme();
  const isDark = colorScheme === "dark";
  const initialRedirectDone = useRef(false);

  const defaultTab = ROLE_HOME[role] || "home";

  useEffect(() => {
    if (!isAuthenticated) {
      router.replace("/");
      return;
    }
    loadPreferences();
  }, [isAuthenticated, loadPreferences]);

  useEffect(() => {
    if (!isAuthenticated || !prefsLoaded || initialRedirectDone.current) return;
    initialRedirectDone.current = true;

    const loader = ROLE_LOADER[role];
    if (loader) loader(dashboardStore)();

    const targetRoute = ROLE_ROUTE[role] || "/(tabs)";
    setActiveTab(defaultTab);
    router.replace(targetRoute as any);
  }, [isAuthenticated, prefsLoaded, role, defaultTab, dashboardStore]);

  const handleTabPress = (key: string) => {
    setActiveTab(key);
    const routeMap: Record<string, string> = {
      home: "/(tabs)",
      insights: "/(tabs)/insight",
      vault: "/(tabs)/vault",
      pay: "/(tabs)/pay",
      profile: "/(tabs)/profile",
      "sme-dashboard": "/(tabs)/sme-dashboard",
      "sme-analytics": "/(tabs)/sme-analytics",
      entrepreneur: "/(tabs)/entrepreneur",
      freelancer: "/(tabs)/freelancer",
    };
    const route = routeMap[key];
    if (route) router.push(route as any);
  };

  return (
    <SheetContext.Provider
      value={{
        showSheet: setSheetContent,
        hideSheet: () => setSheetContent(null),
      }}
    >
      <View
        className={`flex-1 ${isDark ? "bg-[#0A1F5C]" : "bg-surface-bright"}`}
      >
        {!prefsLoaded ? (
          <View className="flex-1 items-center justify-center">
            <ActivityIndicator size="large" color="#D4AF37" />
          </View>
        ) : (
        <><Stack screenOptions={{ headerShown: false }}>
          <Stack.Screen name="index" />
          <Stack.Screen name="insight" />
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

        <BottomTabBar activeTab={activeTab} onTabPress={handleTabPress} role={role} />
        </>)}

        {sheetContent && (
          <Modal
            visible
            transparent
            animationType="slide"
            onRequestClose={() => setSheetContent(null)}
          >
            <Pressable
              className="flex-1 bg-black/40"
              onPress={() => setSheetContent(null)}
            >
              <Pressable className="flex-1 justify-end" onPress={() => {}}>
                <Pressable
                  className={`${isDark ? "bg-[#1A1A1A]" : "bg-white"} rounded-t-3xl`}
                  style={{
                    maxHeight: "80%",
                    boxShadow: "0 -8px 24px rgba(0,0,0,0.1)",
                    elevation: 16,
                  }}
                  onPress={() => {}}
                >
                  <View className="items-center pt-3 pb-1">
                    <View className="w-10 h-1 rounded-full bg-outline/40" />
                  </View>
                  <View className="flex-row items-center justify-between px-6 py-4 border-b border-outline-variant/20">
                    <Text className="font-headline-md text-primary font-bold">
                      {sheetContent.title}
                    </Text>
                    <Pressable
                      onPress={() => setSheetContent(null)}
                      className="w-8 h-8 rounded-full bg-surface-variant items-center justify-center active:scale-90"
                    >
                      <MaterialIcons name="close" size={18} color="#43474d" />
                    </Pressable>
                  </View>
                  <ScrollView
                    className="px-6 py-4"
                    contentContainerStyle={{ paddingBottom: 40 }}
                  >
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
