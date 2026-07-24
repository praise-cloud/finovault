import { BentoCard } from "@/components/bento-card";
import { useDashboardStore } from "@/stores/dashboard-store";
import { useAuthStore } from "@/stores/auth-store";
import { MaterialIcons } from "@expo/vector-icons";
import { useEffect } from "react";
import {
    ActivityIndicator,
    Pressable,
    ScrollView,
    Text,
    View,
} from "react-native";
import { router } from "expo-router";

export default function EntrepreneurDashboard() {
  const data = useDashboardStore((s) => s.entrepreneur);
  const isLoading = useDashboardStore((s) => s.isLoading);
  const load = useDashboardStore((s) => s.loadEntrepreneur);
  const user = useAuthStore((s) => s.user);
  const userName = user?.user_metadata?.full_name || user?.email?.split("@")[0] || "User";

  useEffect(() => {
    load();
  }, [load]);

  if (!data) {
    return (
      <View className="flex-1 bg-surface-bright items-center justify-center">
        <ActivityIndicator size="large" color="#08142E" />
      </View>
    );
  }

  const d = data;

  return (
    <View className="flex-1 bg-surface-bright">
      <View
        className="bg-surface-bright pt-14 pb-3 px-margin-mobile md:px-margin-desktop"
        style={{
          elevation: 4,
          boxShadow: '0 4px 4px rgba(0,0,0,0.04)',
        }}
      >
        <View
          className="flex-row items-center justify-between"
          style={{ maxWidth: 1440 }}
        >
          <View className="flex-row items-center gap-4">
            <Text className="font-headline-md text-primary font-bold tracking-tight">
              Finovault AI
            </Text>
          </View>
          <View className="flex-row items-center gap-6">
            <View className="hidden md:flex-row md:flex gap-8">
              <Text className="font-label-md text-primary border-b-2 border-secondary px-1 py-1">
                Dashboard
              </Text>
              <Text className="font-label-md text-on-surface-variant px-1 py-1">
                Growth
              </Text>
              <Text className="font-label-md text-on-surface-variant px-1 py-1">
                Network
              </Text>
            </View>
            <View className="w-10 h-10 rounded-full bg-secondary-container border-2 border-white items-center justify-center overflow-hidden">
              <MaterialIcons name="person" size={20} color="#1A1A1A" />
            </View>
          </View>
        </View>
      </View>

      <ScrollView
        className="flex-1 px-margin-mobile md:px-margin-desktop"
        contentContainerStyle={{ paddingBottom: 120 }}
      >
        <View className="mt-6 mb-8">
          <Text className="font-headline-lg text-headline-lg text-primary mb-2">
            Welcome back, {userName}.
          </Text>
          <Text
            className="font-body-lg text-body-lg text-on-surface-variant"
            style={{ maxWidth: 576 }}
          >
            Your business expanded by{" "}
            <Text className="text-secondary font-bold">{d.mrr_growth}%</Text>{" "}
            this month. Explore new funding opportunities matched to your growth
            stage.
          </Text>
        </View>

        <View className="md:flex-row gap-gutter mb-gutter">
          <View className="mb-4 md:mb-0" style={{ flex: 8 }}>
            <BentoCard>
              <View className="relative overflow-hidden">
                <View className="absolute top-0 right-0 p-4 opacity-10">
                  <MaterialIcons
                    name="trending-up"
                    size={120}
                    color="#ffffff"
                  />
                </View>
                <View className="relative z-10">
                  <View className="flex-row justify-between items-start mb-8">
                    <View>
                      <Text className="font-label-md text-on-surface-variant mb-1">
                        Business Growth Velocity
                      </Text>
                      <View className="flex-row items-baseline gap-1">
                        <Text className="font-display-lg text-display-lg text-primary">
                          ${d.mrr.toLocaleString()}
                        </Text>
                        <Text
                          className="text-body-md text-on-surface-variant"
                          style={{ fontSize: 18 }}
                        >
                          MRR
                        </Text>
                      </View>
                    </View>
                    <View className="bg-secondary-container/30 px-3 py-1 rounded-full flex-row items-center gap-1">
                      <MaterialIcons
                        name="arrow-upward"
                        size={18}
                        color="#1A1A1A"
                      />
                      <Text className="text-on-secondary-container font-label-md">
                        {d.mrr_growth}% vs LY
                      </Text>
                    </View>
                  </View>
                  <View className="h-48 bg-surface-container-low rounded-lg" />
                  <View className="flex-row gap-4 mt-8">
                    <View className="flex-1 items-center p-4 rounded-xl bg-surface-container-low/50">
                      <Text className="text-caption text-on-surface-variant uppercase tracking-wider mb-1">
                        Burn Rate
                      </Text>
                      <Text className="font-headline-md text-headline-md text-primary">
                        {d.burn_rate}
                      </Text>
                    </View>
                    <View className="flex-1 items-center p-4 rounded-xl bg-surface-container-low/50">
                      <Text className="text-caption text-on-surface-variant uppercase tracking-wider mb-1">
                        CAC
                      </Text>
                      <Text className="font-headline-md text-headline-md text-primary">
                        {d.cac}
                      </Text>
                    </View>
                    <View className="flex-1 items-center p-4 rounded-xl bg-surface-container-low/50">
                      <Text className="text-caption text-on-surface-variant uppercase tracking-wider mb-1">
                        Runway
                      </Text>
                      <Text className="font-headline-md text-headline-md text-primary">
                        {d.runway}
                      </Text>
                    </View>
                  </View>
                </View>
              </View>
            </BentoCard>
          </View>

          <View className="flex-col gap-gutter" style={{ flex: 4 }}>
            <BentoCard className="bg-primary-container">
              <View className="relative overflow-hidden">
                <View className="relative z-10">
                  <View className="flex-row items-center gap-2 mb-6">
                    <MaterialIcons name="stars" size={20} color="#F4D35E" />
                    <Text className="font-label-md text-on-primary-container uppercase tracking-widest">
                      Grant Insight
                    </Text>
                  </View>
                  <Text className="font-headline-md text-white mb-4 leading-tight">
                    {d.grant.title}
                  </Text>
                  <Text className="font-body-md text-body-md text-primary-fixed-dim mb-6 opacity-90">
                    {d.grant.description}
                  </Text>
                  <Pressable
                    onPress={() => router.push("/(tabs)/ai-coach")}
                    className="bg-secondary-fixed py-4 rounded-xl flex-row items-center justify-center gap-2 active:scale-95"
                    style={{
                      boxShadow: '0 4px 12px rgba(88,251,218,0.3)',
                      elevation: 4,
                    }}
                  >
                    <Text className="text-on-secondary-fixed font-bold font-label-md">
                      View Eligibility
                    </Text>
                    <MaterialIcons
                      name="chevron-right"
                      size={18}
                      color="#00201a"
                    />
                  </Pressable>
                </View>
                <View
                  className="absolute -bottom-10 -right-10 w-40 h-40 bg-secondary-fixed opacity-10 rounded-full"
                  style={{ transform: [{ scale: 3 }] }}
                />
              </View>
            </BentoCard>

            <BentoCard>
              <View className="flex-row items-center gap-2 mb-4">
                <MaterialIcons name="verified-user" size={20} color="#08142E" />
                <Text className="font-label-md text-primary">
                  Smart Savings
                </Text>
              </View>
              <View className="flex-row justify-between items-center p-3 bg-surface-container-low rounded-lg">
                <View>
                  <Text className="font-label-md text-primary">
                    {d.smart_savings.label}
                  </Text>
                  <Text className="text-caption text-on-surface-variant">
                    {d.smart_savings.apy}
                  </Text>
                </View>
                <Text className="font-label-md font-bold">
                  ${d.smart_savings.amount.toLocaleString()}
                </Text>
              </View>
            </BentoCard>
          </View>
        </View>

        <View className="md:flex-row gap-gutter">
          <View className="mb-4 md:mb-0" style={{ flex: 4 }}>
            <BentoCard>
              <View className="flex-row justify-between items-center mb-6">
                <Text className="font-headline-md text-headline-md text-primary">
                  Circle Network
                </Text>
                <Pressable onPress={() => router.push("/(tabs)/transactions")}><Text className="text-caption text-secondary">View All</Text></Pressable>
              </View>
              {(d.network || []).map((person) => (
                <View
                  key={person.id}
                  className="flex-row items-center gap-4 mb-6"
                >
                  <View className="w-12 h-12 rounded-full bg-surface-container items-center justify-center shrink-0">
                    <MaterialIcons name="person" size={24} color="#43474d" />
                  </View>
                  <View className="flex-1">
                    <Text className="font-label-md text-primary font-bold">
                      {person.name}
                    </Text>
                    <Text className="text-caption text-on-surface-variant">
                      {person.role}
                    </Text>
                  </View>
                  <MaterialIcons name="chat" size={20} color="#0A1F5C" />
                </View>
              ))}
              <View className="mt-8 pt-6 border-t border-surface-variant/50">
                <Text className="text-caption text-on-surface-variant uppercase tracking-widest mb-4">
                  Upcoming Roundtable
                </Text>
                <View className="bg-surface-container-low rounded-xl p-4">
                  <Text className="font-label-md text-primary mb-1">
                    {d.upcoming_roundtable.title}
                  </Text>
                  <Text className="text-caption text-on-surface-variant">
                    {d.upcoming_roundtable.time}
                  </Text>
                </View>
              </View>
            </BentoCard>
          </View>

          <View style={{ flex: 8 }}>
            <BentoCard>
              <View className="flex-row justify-between items-start md:items-center mb-8">
                <View>
                  <Text className="font-headline-md text-headline-md text-primary">
                    SME Analytics Portfolio
                  </Text>
                  <Text className="font-body-md text-body-md text-on-surface-variant">
                    Distribution of investment across business sectors
                  </Text>
                </View>
                <View className="flex-row bg-surface-container-low rounded-lg p-1">
                  <Text className="px-4 py-1.5 bg-white shadow-sm rounded-md font-label-md text-primary">
                    Week
                  </Text>
                  <Text className="px-4 py-1.5 font-label-md text-on-surface-variant">
                    Month
                  </Text>
                  <Text className="px-4 py-1.5 font-label-md text-on-surface-variant">
                    Year
                  </Text>
                </View>
              </View>
              <View className="flex-col md:flex-row gap-8 items-center">
                <View
                  className="items-center justify-center"
                  style={{ flex: 1 }}
                >
                  <View className="w-48 h-48 rounded-full border-[20px] border-secondary-container relative items-center justify-center">
                    <View className="absolute top-0 right-0 w-24 h-24 overflow-hidden">
                      <View
                        className="w-48 h-48 rounded-full border-[20px] border-primary-container"
                        style={{ position: "absolute", left: -24, top: 0 }}
                      />
                    </View>
                    <View className="absolute bottom-0 left-0 w-24 h-24 overflow-hidden">
                      <View
                        className="w-48 h-48 rounded-full border-[20px] border-tertiary-fixed-dim"
                        style={{ position: "absolute", left: 0, top: -24 }}
                      />
                    </View>
                    <View className="items-center">
                      <Text className="font-display-lg text-[32px] text-primary">
                        {d.portfolio.saas_focus_pct}%
                      </Text>
                      <Text className="text-caption text-on-surface-variant uppercase">
                        SaaS Focus
                      </Text>
                    </View>
                  </View>
                </View>
                <View style={{ flex: 1 }} className="self-stretch gap-6">
                  <View className="flex-row items-center justify-between">
                    <View className="flex-row items-center gap-3">
                      <View className="w-3 h-3 rounded-full bg-primary-container" />
                      <Text className="font-label-md text-primary">
                        Product SaaS
                      </Text>
                    </View>
                    <Text className="font-label-md font-bold">
                      ${d.portfolio.saas_value.toLocaleString()}
                    </Text>
                  </View>
                  <View className="flex-row items-center justify-between">
                    <View className="flex-row items-center gap-3">
                      <View className="w-3 h-3 rounded-full bg-secondary-container" />
                      <Text className="font-label-md text-primary">
                        Marketing Ops
                      </Text>
                    </View>
                    <Text className="font-label-md font-bold">
                      ${d.portfolio.marketing_value.toLocaleString()}
                    </Text>
                  </View>
                  <View className="flex-row items-center justify-between">
                    <View className="flex-row items-center gap-3">
                      <View className="w-3 h-3 rounded-full bg-tertiary-fixed-dim" />
                      <Text className="font-label-md text-primary">
                        Human Capital
                      </Text>
                    </View>
                    <Text className="font-label-md font-bold">
                      ${d.portfolio.human_capital_value.toLocaleString()}
                    </Text>
                  </View>
                  <View className="p-4 rounded-xl bg-secondary-container/10 border border-secondary/20">
                    <Text className="font-body-md text-on-secondary-container">
                      <MaterialIcons
                        name="tips-and-updates"
                        size={18}
                        color="#1A1A1A"
                      />{" "}
                      Rebalancing suggested for Q4 based on female-led VC
                      trends.
                    </Text>
                  </View>
                </View>
              </View>
            </BentoCard>
          </View>
        </View>
      </ScrollView>
    </View>
  );
}
