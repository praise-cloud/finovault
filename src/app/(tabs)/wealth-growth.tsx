import { useEffect } from 'react';
import { ScrollView, View, Text, Pressable, ActivityIndicator } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import Svg, { Circle } from 'react-native-svg';
import { useDashboardStore } from '@/stores/dashboard-store';

export default function WealthGrowth() {
  const data = useDashboardStore((s) => s.wealthGrowth);
  const isLoading = useDashboardStore((s) => s.isLoading);
  const load = useDashboardStore((s) => s.loadWealthGrowth);

  useEffect(() => { load(); }, [load]);

  if (!data) {
    return <View className="flex-1 bg-surface-bright items-center justify-center"><ActivityIndicator size="large" color="#006b5a" /></View>;
  }

  const d = data;

  return (
    <View className="flex-1 bg-surface-bright">
      <View className="bg-surface-bright w-full" style={{ shadowColor: '#000', shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.04, elevation: 4 }}>
        <View className="flex-row items-center justify-between px-margin-mobile md:px-margin-desktop h-16 max-w-[1440px] mx-auto">
          <View className="flex-row items-center gap-4">
            <Pressable className="active:scale-95 md:hidden"><MaterialIcons name="menu" size={24} color="#000f22" /></Pressable>
            <Text className="font-headline-md text-primary font-bold">Finovault AI</Text>
          </View>
          <View className="flex-row items-center gap-6">
            <View className="hidden md:flex-row gap-8">
              <Text className="font-label-md text-primary font-bold">Wealth Growth</Text>
              <Text className="font-label-md text-on-surface-variant">Smart Savings</Text>
              <Text className="font-label-md text-on-surface-variant">Fraud Protection</Text>
            </View>
            <View className="w-10 h-10 rounded-full border-2 border-primary items-center justify-center bg-surface-container-high">
              <MaterialIcons name="person" size={22} color="#43474d" />
            </View>
          </View>
        </View>
      </View>

      <ScrollView className="flex-1 px-margin-mobile md:px-margin-desktop" contentContainerStyle={{ paddingBottom: 120 }}>
        <View className="mb-lg mt-md">
          <View className="flex-col md:flex-row md:items-end justify-between gap-4">
            <View>
              <View className="bg-secondary-container px-3 py-1 rounded-full self-start mb-sm">
                <Text className="text-secondary font-label-md">AI Analysis Active</Text>
              </View>
              <Text className="font-headline-lg mt-xs">Wealth Growth Portfolio</Text>
              <Text className="font-body-md text-on-surface-variant max-w-2xl">Visualizing your path to financial freedom with real-time institutional-grade forecasts and automated risk mitigation.</Text>
            </View>
            <View className="flex-row gap-4">
              <Pressable className="bg-primary px-6 py-3 rounded-xl flex-row items-center gap-2 active:scale-95" style={{ shadowColor: '#006b5a', shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.2, shadowRadius: 8, elevation: 4 }}>
                <MaterialIcons name="add-circle" size={20} color="#ffffff" />
                <Text className="text-on-primary font-label-md">Optimize Allocation</Text>
              </Pressable>
            </View>
          </View>
        </View>

        <View className="flex-col gap-gutter">
          <View className="flex-col md:flex-row gap-gutter">
            <View className="w-full md:w-[66.6667%] bg-surface-container-lowest rounded-xl p-md border border-outline-variant shadow-sm">
              <View className="flex-row justify-between items-center mb-md">
                <View>
                  <Text className="font-headline-md text-primary">Performance Forecast</Text>
                  <Text className="font-caption text-on-surface-variant">AI-projected growth over 12 months</Text>
                </View>
                <View className="flex-row gap-2 bg-surface-container-low p-1 rounded-lg">
                  <Pressable className="px-4 py-1 bg-white rounded shadow-sm"><Text className="font-label-md text-primary">1Y</Text></Pressable>
                  <Pressable className="px-4 py-1"><Text className="font-label-md text-on-surface-variant">5Y</Text></Pressable>
                  <Pressable className="px-4 py-1"><Text className="font-label-md text-on-surface-variant">MAX</Text></Pressable>
                </View>
              </View>
              <View className="h-80 w-full relative overflow-hidden rounded-lg bg-surface-bright flex items-end px-4 pb-8">
                <View className="absolute inset-0 opacity-10 bg-surface-bright"><View className="h-full w-full" style={{ backgroundColor: '#006b5a' }} /></View>
                <View className="flex-row items-end justify-between w-full h-full gap-2 z-10">
                  {d.performance_forecast.map((h, i) => (
                    <View key={i} className="flex-1 rounded-t-sm" style={{ height: `${h}%`, backgroundColor: i > 5 ? '#006b5a' : '#0a2540', opacity: i > 5 ? 0.8 : 0.2 + (i * 0.1) }} />
                  ))}
                </View>
                <View className="absolute right-0 top-0 h-full w-1/3 flex items-center justify-center" style={{ backgroundColor: 'rgba(0,107,90,0.03)' }}>
                  <Text className="text-[10px] font-bold tracking-widest text-secondary/40 uppercase" style={{ transform: [{ rotate: '90deg' }] }}>AI Projection</Text>
                </View>
              </View>
            </View>

            <View className="w-full md:w-[33.3333%] bg-surface-container-lowest rounded-xl p-md border border-outline-variant shadow-sm">
              <Text className="font-headline-md text-primary mb-sm">Asset Allocation</Text>
              <View className="items-center my-md">
                <View className="relative w-48 h-48 items-center justify-center">
                  <Svg width={192} height={192} viewBox="0 0 192 192" style={{ transform: [{ rotate: '-90deg' }] }}>
                    <Circle cx={96} cy={96} r={80} fill="transparent" stroke="#ebeef1" strokeWidth={24} />
                    <Circle cx={96} cy={96} r={80} fill="transparent" stroke="#000f22" strokeDasharray="502" strokeDashoffset="150" strokeWidth={24} />
                    <Circle cx={96} cy={96} r={80} fill="transparent" stroke="#006b5a" strokeDasharray="502" strokeDashoffset="400" strokeWidth={24} />
                    <Circle cx={96} cy={96} r={80} fill="transparent" stroke="#321ed2" strokeDasharray="502" strokeDashoffset="450" strokeWidth={24} />
                  </Svg>
                  <View className="absolute items-center">
                    <Text className="font-caption text-on-surface-variant uppercase tracking-tighter">Total Wealth</Text>
                    <Text className="font-headline-md font-bold">${d.total_wealth.toLocaleString()}</Text>
                  </View>
                </View>
              </View>
              {d.allocations.map((item) => (
                <View key={item.id} className="flex-row items-center justify-between py-2">
                  <View className="flex-row items-center gap-3">
                    <View className="w-3 h-3 rounded-full" style={{ backgroundColor: item.color }} />
                    <Text className="font-label-md">{item.category}</Text>
                  </View>
                  <Text className="font-label-md font-bold">{item.percentage}%</Text>
                </View>
              ))}
            </View>
          </View>

          <View className="flex-col md:flex-row gap-gutter">
            <View className="w-full md:w-[58.3333%] bg-surface-container-lowest rounded-xl p-md border border-outline-variant shadow-sm">
              <View className="flex-row items-center justify-between mb-md">
                <Text className="font-headline-md text-primary">Market Intelligence</Text>
                <MaterialIcons name="psychology" size={24} color="#006b5a" />
              </View>
              {d.market_insights.map((item, i) => (
                <View key={item.id || i} className="flex-row gap-md items-start p-sm rounded-lg">
                  <View className="w-20 h-20 rounded-xl overflow-hidden bg-surface-container-high flex-shrink-0" />
                  <View className="flex-1">
                    <View className="flex-row items-center gap-2 mb-1">
                      <View className={`${item.badge_bg} px-2 py-0.5 rounded`}>
                        <Text className={`${item.badge_text} text-[10px] font-bold uppercase`}>{item.badge}</Text>
                      </View>
                      <Text className="font-caption text-on-surface-variant">{item.time_label}</Text>
                    </View>
                    <Text className="font-label-md font-bold">{item.title}</Text>
                    <Text className="font-caption text-on-surface-variant mt-xs" numberOfLines={2}>{item.description}</Text>
                  </View>
                </View>
              ))}
              <Pressable className="w-full mt-md py-3 border border-secondary/20 rounded-xl items-center active:scale-95">
                <Text className="font-label-md text-secondary">View All Forecasts</Text>
              </Pressable>
            </View>

            <View className="w-full md:w-[41.6667%] bg-primary-container rounded-xl p-md overflow-hidden relative min-h-[300px]">
              <View className="relative z-10">
                <View className="flex-row items-center gap-2 mb-md">
                  <View className="p-2 bg-secondary/20 rounded-lg"><MaterialIcons name="security" size={20} color="#58fbda" /></View>
                  <Text className="font-headline-md text-white">Risk Shield</Text>
                </View>
                <Text className="text-on-primary-container opacity-80 mb-lg">
                  {d.risk_shield_message} Adjusting your portfolio now could save <Text className="text-white font-bold">${d.risk_shield_potential_savings.toLocaleString()}</Text> in annual returns.
                </Text>
                <View className="bg-white/5 rounded-xl p-sm border border-white/10 mb-md">
                  <View className="flex-row justify-between items-center mb-1">
                    <Text className="font-caption text-white/70">Correction Progress</Text>
                    <Text className="font-caption text-white/70">{d.risk_shield_progress}% Complete</Text>
                  </View>
                  <View className="w-full bg-white/10 h-2 rounded-full overflow-hidden">
                    <View className="bg-secondary h-full rounded-full" style={{ width: `${d.risk_shield_progress}%` }} />
                  </View>
                </View>
                <Pressable className="w-full bg-secondary py-4 rounded-xl flex-row items-center justify-center gap-2 active:scale-95">
                  <Text className="text-on-secondary font-bold">Execute Optimization</Text>
                  <MaterialIcons name="bolt" size={20} color="#ffffff" />
                </Pressable>
              </View>
              <View className="absolute -right-20 -bottom-20 w-64 h-64 bg-secondary/10 rounded-full" style={{ opacity: 0.3 }} />
              <View className="absolute -left-20 top-0 w-48 h-48 bg-primary/20 rounded-full" style={{ opacity: 0.2 }} />
            </View>
          </View>
        </View>
      </ScrollView>
    </View>
  );
}