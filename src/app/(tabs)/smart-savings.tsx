import { View, Text, Pressable, ScrollView, Animated, ActivityIndicator, useWindowDimensions } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { useRef, useEffect, useState } from 'react';
import { useDashboardStore } from '@/stores/dashboard-store';
import { router } from 'expo-router';

export default function SmartSavings() {
  const { width } = useWindowDimensions();
  const isMd = width >= 768;
  const [progressAnim] = useState(() => new Animated.Value(0));
  const data = useDashboardStore((s) => s.smartSavings);
  const load = useDashboardStore((s) => s.loadSmartSavings);

  useEffect(() => {
    load();
  }, [load]);

  useEffect(() => {
    if (!data) return;
    const goalPct = data?.rainy_day_fund ? (data.rainy_day_fund.current_amount / data.rainy_day_fund.target_amount) * 100 : 70;
    Animated.spring(progressAnim, {
      toValue: goalPct,
      useNativeDriver: false,
      tension: 40,
      friction: 7,
    }).start();
  }, [data]);

  if (!data) {
    return <View className="flex-1 bg-[#FFFFFF] items-center justify-center"><ActivityIndicator size="large" color="#08142E" /></View>;
  }

  const d = data;

  const progressWidth = progressAnim.interpolate({
    inputRange: [0, 100],
    outputRange: ['0%', '100%'],
  });

  const goalPct = (d.rainy_day_fund.current_amount / d.rainy_day_fund.target_amount) * 100;

  return (
    <View className="flex-1 bg-[#FFFFFF]">
      <View className="bg-[#FFFFFF] pt-14 pb-3 px-margin-mobile" style={{ boxShadow: '0 4px 4px rgba(0,0,0,0.04)', elevation: 4 }}>
        <View className="flex-row items-center justify-between">
          <View className="flex-row items-center gap-4">
            <Text className="font-headline-md text-headline-md text-primary font-bold">Finovault AI</Text>
          </View>
          <View className="flex-row items-center gap-6">
            {isMd && (
              <View className="flex-row items-center gap-6">
                <Text className="font-label-md text-label-md text-on-surface-variant px-3 py-2 rounded-lg">Wealth Growth</Text>
                <Text className="font-label-md text-label-md text-primary font-bold border-b-2 border-primary py-2">Smart Savings</Text>
                <Text className="font-label-md text-label-md text-on-surface-variant px-3 py-2 rounded-lg">Fraud Protection</Text>
              </View>
            )}
            <View className="w-10 h-10 rounded-full border-2 border-primary-fixed items-center justify-center bg-surface-container-high overflow-hidden">
              <MaterialIcons name="person" size={22} color="#43474d" />
            </View>
          </View>
        </View>
      </View>

      <ScrollView className="flex-1 px-margin-mobile" contentContainerStyle={{ paddingBottom: 120 }}>
        <View className="mt-6 mb-6">
          <View className="flex-row justify-between items-end gap-4">
            <View>
              <Text className="text-secondary font-label-md text-label-md uppercase tracking-wider">Savings Overview</Text>
              <Text className="font-headline-lg text-headline-lg md:text-display-lg text-primary mt-xs">Smart Savings</Text>
            </View>
            <Pressable onPress={() => router.push('/(tabs)/savings-goals')} className="bg-primary px-6 py-3 rounded-full active:scale-95 transition-all" style={{ boxShadow: '0 4px 4px rgba(0,0,0,0.04)', elevation: 4 }}>
              <Text className="text-on-primary font-label-md text-label-md">Add Goal</Text>
            </Pressable>
          </View>
        </View>

        <View className="gap-gutter">
          <View className="flex-row flex-wrap" style={{ gap: 24 }}>
            <View className="bg-surface-container-lowest rounded-xl p-md border border-outline-variant/30 relative overflow-hidden" style={[{ boxShadow: '0 4px 20px rgba(0,0,0,0.04)', elevation: 2 }, isMd ? { flex: 2 } : { width: '100%' }]}>
              <View className="absolute top-0 right-0 p-md opacity-10"><MaterialIcons name="umbrella" size={120} color="#08142E" /></View>
              <View>
                <View className="flex-row items-center gap-2 mb-md">
                  <MaterialIcons name="water" size={24} color="#08142E" />
                  <Text className="font-headline-md text-headline-md">Rainy Day Fund</Text>
                </View>
                <View className="mb-lg">
                  <View className="flex-row justify-between items-end mb-2">
                    <Text className="font-display-lg text-display-lg text-primary">${d?.rainy_day_fund.current_amount.toLocaleString('en-US', { minimumFractionDigits: 2 }) || '$8,420.50'}</Text>
                    <Text className="font-label-md text-label-md text-on-surface-variant mb-2">Goal: ${d?.rainy_day_fund.target_amount.toLocaleString() || '$12,000'}</Text>
                  </View>
                  <View className="w-full bg-surface-container-high h-4 rounded-full overflow-hidden">
                    <Animated.View className="h-full rounded-full" style={{ width: progressWidth, backgroundColor: '#F4D35E' }} />
                  </View>
                  <View className="flex-row justify-between mt-sm">
                    <Text className="font-label-md text-label-md text-secondary">{Math.round(goalPct)}% Reached</Text>
                    <Text className="font-label-md text-label-md text-on-surface-variant italic">~{Math.round((100 - goalPct) / 15)} months until goal at current rate</Text>
                  </View>
                </View>
              </View>
              <View className="flex-row gap-4 pt-md border-t border-outline-variant/20">
                <View className="flex-row items-center gap-3 bg-surface-container px-4 py-2 rounded-lg">
                  <MaterialIcons name="trending-up" size={18} color="#2cdebf" />
                  <View>
                    <Text className="text-caption font-caption text-on-surface-variant">Last Month</Text>
                    <Text className="font-label-md text-label-md">+$420.00</Text>
                  </View>
                </View>
                <View className="flex-row items-center gap-3 bg-surface-container px-4 py-2 rounded-lg">
                  <MaterialIcons name="lock" size={18} color="#08142E" />
                  <View>
                    <Text className="text-caption font-caption text-on-surface-variant">Status</Text>
                    <Text className="font-label-md text-label-md text-secondary">Safe & Growing</Text>
                  </View>
                </View>
              </View>
            </View>

            <View className="bg-primary-container rounded-xl p-md relative overflow-hidden" style={isMd ? { flex: 1 } : { width: '100%' }}>
              <View style={{ position: 'absolute', top: -48, right: -48, width: 192, height: 192, borderRadius: 96, backgroundColor: '#08142E', opacity: 0.2 }} />
              <View>
                <View className="flex-row items-center gap-2 mb-md">
                  <MaterialIcons name="auto-awesome" size={20} color="#F4D35E" />
                  <Text className="font-label-md text-label-md text-secondary-fixed uppercase font-bold tracking-widest">AI Suggestion</Text>
                </View>
                <Text className="font-headline-md text-headline-md text-on-primary mb-md">{d?.ai_suggestion?.title || 'No AI suggestions yet.'}</Text>
                <Text className="text-body-md text-body-md text-on-primary-container mb-lg">{d?.ai_suggestion?.description || 'Start tracking your spending to get personalized savings tips.'}</Text>
              </View>
              <Pressable onPress={() => router.push('/(tabs)/ai-coach')} className="w-full bg-secondary py-3 rounded-full items-center active:scale-95 transition-all">
                <Text className="text-on-secondary font-label-md text-label-md">Enable Auto-Budgeting</Text>
              </Pressable>
            </View>
          </View>

          <View className="flex-row flex-wrap" style={{ gap: 24 }}>
            <View className="bg-surface-container-lowest rounded-xl p-md border border-outline-variant/30" style={[{ boxShadow: '0 4px 20px rgba(0,0,0,0.04)', elevation: 2 }, isMd ? { flex: 7 } : { width: '100%' }]}>
              <View className="flex-row justify-between items-center mb-md">
                <Text className="font-headline-md text-headline-md">Round-up Savings</Text>
                <View className="bg-secondary-container px-3 py-1 rounded-full"><Text className="text-on-secondary-container font-label-md text-label-md">Active</Text></View>
              </View>
              <View>
                {(d?.round_ups || []).map((r, i) => (
                  <View key={r.id || i} className="flex-row items-center justify-between p-3 border-b border-outline-variant/10">
                    <View className="flex-row items-center gap-4">
                      <View className="w-10 h-10 rounded-full bg-surface-container-high items-center justify-center">
                        <MaterialIcons name={r.category === 'food' ? 'shopping-cart' : r.category === 'transport' ? 'local-gas-station' : 'coffee'} size={18} color="#43474d" />
                      </View>
                      <View>
                        <Text className="font-label-md text-label-md">{r.merchant}</Text>
                        <Text className="text-caption font-caption text-on-surface-variant">{new Date(r.date).toLocaleDateString()}</Text>
                      </View>
                    </View>
                    <View className="items-end">
                      <Text className="font-label-md text-label-md text-primary">${r.original_amount.toFixed(2)}</Text>
                      <Text className="text-caption font-caption text-secondary font-bold">+${r.saved_amount.toFixed(2)}</Text>
                    </View>
                  </View>
                ))}
              </View>
              <Pressable onPress={() => router.push('/(tabs)/round-up-details')} className="w-full mt-md py-2 items-center"><Text className="text-on-surface-variant font-label-md text-label-md underline">View All Round-ups</Text></Pressable>
            </View>

            <View className="gap-gutter" style={isMd ? { flex: 5 } : { width: '100%' }}>
              <View className="bg-surface-container-lowest rounded-xl p-md border border-outline-variant/30 items-center" style={{ boxShadow: '0 4px 20px rgba(0,0,0,0.04)', elevation: 2 }}>
                <View className="mb-sm"><MaterialIcons name="savings" size={48} color="#08142E" /></View>
                <Text className="font-label-md text-label-md text-on-surface-variant mb-1">Total Savings Impact</Text>
                <Text className="font-headline-lg text-headline-lg text-primary">${(d?.total_savings_impact || 0).toLocaleString('en-US', { minimumFractionDigits: 2 })}</Text>
                {d?.savings_trend ? (
                <View className="flex-row items-center gap-1 mt-2">
                  <MaterialIcons name="arrow-upward" size={14} color="#2E7D5B" />
                  <Text className="text-caption font-caption text-secondary">{d.savings_trend}% increase from last quarter</Text>
                </View>
                ) : null}
              </View>

              <View className="rounded-xl p-md" style={{ backgroundColor: 'rgba(255, 255, 255, 0.7)', borderWidth: 1, borderColor: 'rgba(230, 235, 241, 0.5)' }}>
                <View className="flex-row items-start gap-4">
                  <View className="p-2 rounded-lg" style={{ backgroundColor: 'rgba(21, 0, 130, 0.1)' }}>
                    <MaterialIcons name="tips-and-updates" size={20} color="#150082" />
                  </View>
                  <View style={{ flex: 1 }}>
                    <Text className="font-label-md text-label-md font-bold mb-1">Optimization Suggestion</Text>
                    <Text className="text-caption font-caption text-on-surface-variant">{d?.micro_budget_suggestion || 'No optimization suggestions yet.'}</Text>
                  </View>
                </View>
              </View>
            </View>
          </View>
        </View>
      </ScrollView>
    </View>
  );
}