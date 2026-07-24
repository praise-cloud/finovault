import { useEffect, useState } from 'react';
import { ScrollView, View, Text, Pressable, ActivityIndicator } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { BentoCard } from '@/components/bento-card';
import { useDashboardStore } from '@/stores/dashboard-store';
import { router } from 'expo-router';

export default function SmeAnalytics() {
  const data = useDashboardStore((s) => s.smeAnalytics);
  const isLoading = useDashboardStore((s) => s.isLoading);
  const load = useDashboardStore((s) => s.loadSmeAnalytics);
  const [vendorFilter, setVendorFilter] = useState('High Risk');

  useEffect(() => { load(); }, [load]);

  if (!data) {
    return <View className="flex-1 bg-[#FFFFFF] items-center justify-center"><ActivityIndicator size="large" color="#08142E" /></View>;
  }

  const d = data;

  return (
    <View className="flex-1 bg-[#FFFFFF]">
      <View className="bg-[#FFFFFF] pt-14 pb-3 px-margin-mobile md:px-margin-desktop" style={{ boxShadow: '0 4px 20px rgba(0,0,0,0.04)', elevation: 4 }}>
        <View className="flex-row items-center justify-between max-w-[1440px] mx-auto w-full">
          <View className="flex-row items-center gap-4">
            <Text className="font-headline-md text-headline-md text-primary font-bold">Finovault AI</Text>
          </View>
          <View className="hidden md:flex-row gap-8 items-center">
            <Text className="font-label-md text-label-md text-on-surface-variant">Wealth Growth</Text>
            <Text className="font-label-md text-label-md text-on-surface-variant">Smart Savings</Text>
            <Text className="font-label-md text-label-md text-on-surface-variant">Fraud Protection</Text>
            <Text className="font-label-md text-label-md text-primary font-bold border-b-2 border-primary pb-1">SME Analytics</Text>
          </View>
          <View className="w-10 h-10 rounded-full bg-primary-container items-center justify-center border-2 border-surface-variant overflow-hidden"><MaterialIcons name="person" size={20} color="#ffffff" /></View>
        </View>
      </View>

      <ScrollView className="flex-1 px-margin-mobile md:px-margin-desktop" contentContainerStyle={{ paddingBottom: 120 }}>
        <View className="my-6 md:my-8">
          <View className="flex-row items-center gap-2 mb-2"><MaterialIcons name="analytics" size={18} color="#08142E" /><Text className="font-label-md text-label-md text-secondary uppercase tracking-wider">Business Intelligence</Text></View>
          <View className="flex-col md:flex-row md:items-end justify-between gap-4">
            <View>
              <Text className="font-headline-lg text-headline-lg-mobile md:text-headline-lg text-primary">SME Analytics Dashboard</Text>
              <Text className="text-on-surface-variant mt-2 max-w-2xl">Advanced cashflow forensics and vendor risk assessment powered by Finovault AI.</Text>
            </View>
            <View className="flex-row gap-3">
              <Pressable onPress={() => router.push('/(tabs)/transactions')} className="flex-row items-center gap-2 px-4 py-2.5 rounded-xl border border-outline-variant active:scale-95">
                <MaterialIcons name="calendar-today" size={20} color="#181c1e" />
                <Text className="font-label-md text-label-md text-on-surface">Last 30 Days</Text>
              </Pressable>
              <Pressable onPress={() => router.push('/(tabs)/ai-coach')} className="flex-row items-center gap-2 px-6 py-2.5 rounded-xl bg-primary active:scale-95" style={{ boxShadow: '0 4px 12px rgba(0,0,0,0.15)' }}>
                <MaterialIcons name="file-download" size={20} color="#ffffff" />
                <Text className="font-label-md text-label-md text-on-primary">Export Report</Text>
              </Pressable>
            </View>
          </View>
        </View>

        <View className="gap-6 pb-8">
          <BentoCard>
            <View className="flex-row items-center justify-between mb-8">
              <View>
                <Text className="font-headline-md text-headline-md text-primary">Cashflow Forensics</Text>
                <Text className="text-caption text-on-surface-variant">Real-time liquidity monitoring</Text>
              </View>
              <View className="flex-row items-center gap-1.5 px-3 py-1 bg-secondary-container/30 rounded-full">
                <View className="w-2 h-2 rounded-full bg-secondary" />
                <Text className="text-caption text-on-secondary-container">Healthy</Text>
              </View>
            </View>
            <View className="h-64 relative mb-6">
              <View className="absolute inset-0 flex-row items-end justify-between px-2">
                {(d.cashflow_forensics?.chart_data || []).map((h, i) => (
                  <View key={i} className="w-[10%] rounded-t-lg" style={{ height: `${h}%`, backgroundColor: ['#d2e4ff', '#b0c8eb', '#d2e4ff', '#08142E', '#d2e4ff', '#b0c8eb', '#d2e4ff', '#b0c8eb'][i] }} />
                ))}
              </View>
              <View className="absolute inset-x-0 bottom-0 border-t border-outline-variant" />
            </View>
            <View className="flex-row gap-4 border-t border-surface-variant pt-6">
              <View className="flex-1">
                <Text className="text-caption text-on-surface-variant uppercase tracking-tighter">Net Inflow</Text>
                <Text className="font-headline-md text-headline-md text-primary">${d.cashflow_forensics.net_inflow.toLocaleString()}</Text>
                <View className="flex-row items-center gap-1"><MaterialIcons name="trending-up" size={14} color="#2E7D5B" /><Text className="text-caption text-secondary">+{d.cashflow_forensics.inflow_change}%</Text></View>
              </View>
              <View className="flex-1">
                <Text className="text-caption text-on-surface-variant uppercase tracking-tighter">Burn Rate</Text>
                <Text className="font-headline-md text-headline-md text-primary">${d.cashflow_forensics.burn_rate.toLocaleString()}</Text>
                <Text className="text-caption text-on-surface-variant">Stabilized</Text>
              </View>
              <View className="flex-1">
                <Text className="text-caption text-on-surface-variant uppercase tracking-tighter">Runway</Text>
                <Text className="font-headline-md text-headline-md text-primary">{d.cashflow_forensics.runway_months} Mo</Text>
                <View className="flex-row items-center gap-1"><MaterialIcons name="verified" size={14} color="#08142E" /><Text className="text-caption text-secondary">High Security</Text></View>
              </View>
            </View>
          </BentoCard>

          <BentoCard className="bg-primary-container border border-primary relative overflow-hidden">
            <View className="relative z-10">
              <View className="flex-row items-center gap-2 mb-4"><MaterialIcons name="star" size={20} color="#7f7bff" /><Text className="font-label-md text-label-md font-bold uppercase text-on-primary-container">Industry Benchmarking</Text></View>
              <Text className="font-headline-md text-headline-md text-white mb-6">Top 5% Performance</Text>
              <View className="gap-4">
                <View>
                  <View className="flex-row justify-between mb-1"><Text className="text-caption text-white/70">Efficiency Ratio</Text><Text className="text-caption text-white/70">{d.benchmarks.efficiency_ratio}/100</Text></View>
                  <View className="h-1.5 w-full bg-white/20 rounded-full overflow-hidden"><View className="h-full bg-secondary-fixed rounded-full" style={{ width: `${d.benchmarks.efficiency_ratio}%` }} /></View>
                </View>
                <View>
                  <View className="flex-row justify-between mb-1"><Text className="text-caption text-white/70">Customer Retention</Text><Text className="text-caption text-white/70">{d.benchmarks.customer_retention}/100</Text></View>
                  <View className="h-1.5 w-full bg-white/20 rounded-full overflow-hidden"><View className="h-full bg-secondary-fixed rounded-full" style={{ width: `${d.benchmarks.customer_retention}%`, opacity: 0.8 }} /></View>
                </View>
                <View>
                  <View className="flex-row justify-between mb-1"><Text className="text-caption text-white/70">Digital Adoption</Text><Text className="text-caption text-white/70">{d.benchmarks.digital_adoption}/100</Text></View>
                  <View className="h-1.5 w-full bg-white/20 rounded-full overflow-hidden"><View className="h-full bg-secondary-fixed rounded-full" style={{ width: `${d.benchmarks.digital_adoption}%` }} /></View>
                </View>
              </View>
              <View className="mt-8 pt-6 border-t border-white/10">
                <Text className="text-caption text-white/70">You are outperforming 85% of regional SMEs in your sector.</Text>
                <Pressable onPress={() => router.push('/(tabs)/ai-coach')} className="mt-4 flex-row items-center gap-1"><Text className="text-secondary-fixed font-label-md text-label-md">View detailed peer analysis</Text><MaterialIcons name="chevron-right" size={16} color="#F4D35E" /></Pressable>
              </View>
            </View>
            <View className="absolute -right-20 -bottom-20 w-64 h-64 bg-secondary/20 rounded-full" />
          </BentoCard>

          <BentoCard>
            <View className="flex-col md:flex-row md:items-center justify-between gap-4 mb-8">
              <View>
                <Text className="font-headline-md text-headline-md text-primary">Vendor Health Analytics</Text>
                <Text className="text-caption text-on-surface-variant">Supply chain resilience and credit worthiness tracking</Text>
              </View>
              <View className="flex-row bg-surface-container-low rounded-lg p-1">
                <Pressable onPress={() => setVendorFilter('High Risk')} className={`px-4 py-1.5 rounded-md ${vendorFilter === 'High Risk' ? 'bg-surface-container-lowest shadow-sm' : ''}`}><Text className={`font-label-md text-label-md ${vendorFilter === 'High Risk' ? 'text-primary' : 'text-on-surface-variant'}`}>High Risk</Text></Pressable>
                <Pressable onPress={() => setVendorFilter('Reliable')} className={`px-4 py-1.5 rounded-md ${vendorFilter === 'Reliable' ? 'bg-surface-container-lowest shadow-sm' : ''}`}><Text className={`font-label-md text-label-md ${vendorFilter === 'Reliable' ? 'text-primary' : 'text-on-surface-variant'}`}>Reliable</Text></Pressable>
                <Pressable onPress={() => setVendorFilter('Watchlist')} className={`px-4 py-1.5 rounded-md ${vendorFilter === 'Watchlist' ? 'bg-surface-container-lowest shadow-sm' : ''}`}><Text className={`font-label-md text-label-md ${vendorFilter === 'Watchlist' ? 'text-primary' : 'text-on-surface-variant'}`}>Watchlist</Text></Pressable>
              </View>
            </View>
            <View className="-mx-6 px-6">
              <View className="flex-row border-b border-surface-variant pb-4">
                <View className="flex-[2]"><Text className="font-label-md text-label-md text-on-surface-variant">Vendor Partner</Text></View>
                <View className="flex-1"><Text className="font-label-md text-label-md text-on-surface-variant">Monthly Spend</Text></View>
                <View className="flex-1"><Text className="font-label-md text-label-md text-on-surface-variant">Payment Reliability</Text></View>
                <View className="flex-1"><Text className="font-label-md text-label-md text-on-surface-variant">Finovault Score</Text></View>
                <View className="flex-1"><Text className="font-label-md text-label-md text-on-surface-variant">Status</Text></View>
              </View>
              {(d.vendors || []).map((row) => (
                <View key={row.id} className="flex-row items-center py-4 border-b border-surface-variant">
                  <View className="flex-[2] flex-row items-center gap-3">
                    <View className="w-10 h-10 rounded-lg bg-surface-variant items-center justify-center">
                      <Text className="font-bold text-primary">{row.name.split(' ').map((w) => w[0]).join('').slice(0, 2)}</Text>
                    </View>
                    <View>
                      <Text className="font-label-md text-label-md text-primary">{row.name}</Text>
                      <Text className="text-caption text-on-surface-variant">{row.description}</Text>
                    </View>
                  </View>
                  <View className="flex-1"><Text className="text-body-md">${row.monthly_spend.toLocaleString()}</Text></View>
                  <View className="flex-1 flex-row gap-1">
                    {[1, 2, 3, 4].map((j) => (
                      <View key={j} className="w-6 h-1 rounded-full" style={{ backgroundColor: row.health_score >= 80 ? '#08142E' : row.health_score >= 50 ? '#181c1e' : '#ba1a1a', opacity: j <= Math.round(row.health_score / 25) ? 1 : 0.2 }} />
                    ))}
                  </View>
                  <View className="flex-1">
                    <View className="self-start px-2 py-0.5 rounded-md" style={{ backgroundColor: row.health_score >= 80 ? 'rgba(8,20,46,0.2)' : row.health_score >= 50 ? 'rgba(24,28,30,0.1)' : 'rgba(186,26,26,0.2)' }}>
                      <Text className="font-bold text-label-md" style={{ color: row.health_score >= 80 ? '#08142E' : row.health_score >= 50 ? '#181c1e' : '#ba1a1a' }}>{row.health_score}/100</Text>
                    </View>
                  </View>
                  <View className="flex-1 flex-row items-center gap-1.5">
                    <View className="w-1.5 h-1.5 rounded-full" style={{ backgroundColor: row.health_score >= 80 ? '#08142E' : row.health_score >= 50 ? '#181c1e' : '#ba1a1a' }} />
                    <Text className="text-caption" style={{ color: row.health_score >= 80 ? '#08142E' : row.health_score >= 50 ? '#181c1e' : '#ba1a1a' }}>{row.health_score >= 80 ? 'Optimal' : row.health_score >= 50 ? 'Stable' : 'Delayed Risk'}</Text>
                  </View>
                </View>
              ))}
            </View>
          </BentoCard>

          <View className="flex-col md:flex-row gap-6 items-center p-8 bg-surface-container-high/50 border border-surface-variant rounded-2xl">
            <View className="w-20 h-20 bg-primary rounded-full items-center justify-center shrink-0" style={{ boxShadow: '0 4px 12px rgba(0,0,0,0.2)' }}>
              <MaterialIcons name="smart-toy" size={40} color="#ffffff" />
            </View>
            <View className="flex-grow text-center md:text-left">
              <Text className="font-headline-md text-headline-md text-primary mb-1">AI Smart Recommendation</Text>
              <Text className="text-body-md text-on-surface-variant">&ldquo;{d.ai_recommendation}&rdquo;</Text>
            </View>
            <Pressable onPress={() => router.push('/(tabs)/ai-coach')} className="px-8 py-3 bg-secondary rounded-xl active:scale-95" style={{ boxShadow: '0 4px 12px rgba(0,0,0,0.15)' }}>
              <Text className="font-label-md text-label-md text-on-secondary">Execute Audit</Text>
            </Pressable>
          </View>
        </View>
      </ScrollView>
    </View>
  );
}