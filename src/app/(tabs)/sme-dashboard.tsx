import { useEffect } from 'react';
import { ScrollView, View, Text, Pressable, ActivityIndicator } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import Svg, { Circle } from 'react-native-svg';
import { useDashboardStore } from '@/stores/dashboard-store';
import { useAuthStore } from '@/stores/auth-store';
import { router } from 'expo-router';

export default function SmeDashboard() {
  const data = useDashboardStore((s) => s.smeDashboard);
  const isLoading = useDashboardStore((s) => s.isLoading);
  const load = useDashboardStore((s) => s.loadSmeDashboard);
  const user = useAuthStore((s) => s.user);
  const userName = user?.user_metadata?.full_name?.split(' ')[0] || 'User';

  useEffect(() => { load(); }, [load]);

  if (!data) {
    return <View className="flex-1 bg-surface-bright items-center justify-center"><ActivityIndicator size="large" color="#006b5a" /></View>;
  }

  const d = data;

  return (
    <View className="flex-1 bg-surface-bright">
      <View className="bg-surface-bright pt-14 pb-3 px-margin-mobile" style={{ elevation: 4, shadowColor: '#000', shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.04 }}>
        <View className="flex-row items-center justify-between">
          <View className="flex-row items-center gap-4">
            <Text className="font-headline-md text-headline-md text-primary font-bold">Finovault AI</Text>
          </View>
          <View className="hidden md:flex flex-row items-center gap-8">
            <View className="flex-row gap-6">
              <Text className="font-label-md text-label-md text-primary font-bold">Dashboard</Text>
              <Text className="font-label-md text-label-md text-on-surface-variant px-2 py-1 rounded-lg">Markets</Text>
              <Text className="font-label-md text-label-md text-on-surface-variant px-2 py-1 rounded-lg">Reports</Text>
            </View>
          </View>
          <View className="w-10 h-10 rounded-full bg-primary-container items-center justify-center border-2 border-outline-variant overflow-hidden"><MaterialIcons name="person" size={20} color="#ffffff" /></View>
        </View>
      </View>

      <ScrollView className="flex-1 px-margin-mobile" contentContainerStyle={{ paddingBottom: 120 }}>
        <View className="mt-6 mb-8 flex-row items-end justify-between">
          <View className="flex-1">
            <Text className="font-headline-lg text-headline-lg text-primary mb-2">Good Morning, {userName}</Text>
            <Text className="text-on-surface-variant text-body-md">Here&apos;s your SME health overview.</Text>
          </View>
          <Pressable onPress={() => router.push('/(tabs)/transactions')} className="bg-secondary px-6 py-2 rounded-full flex-row items-center gap-2 active:scale-95 transition-transform ml-4">
            <MaterialIcons name="add" size={20} color="#ffffff" />
            <Text className="text-on-primary font-label-md text-label-md font-bold">New Transaction</Text>
          </Pressable>
        </View>

        <View className="flex-row flex-wrap" style={{ gap: 24 }}>
          <View className="bg-surface-container-lowest rounded-xl p-6 border border-[#E6EBF1] flex-[2] min-w-[300px]" style={{ shadowColor: '#000', shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.04, shadowRadius: 20, elevation: 2 }}>
            <View className="flex-row justify-between items-center mb-6">
              <Text className="font-headline-md text-headline-md flex-row items-center gap-2"><MaterialIcons name="payments" size={22} color="#006b5a" />{' Cash Flow Analysis'}</Text>
              <View className="bg-secondary-container px-3 py-1 rounded-full"><Text className="text-on-secondary-container text-caption font-bold">LIVE</Text></View>
            </View>
            <View className="flex-row flex-wrap" style={{ gap: 24 }}>
              <View className="flex-1 min-w-[120px] p-4 rounded-xl bg-surface-bright border border-outline-variant">
                <Text className="text-caption text-on-surface-variant uppercase mb-1 tracking-wider">Incoming</Text>
                <Text className="font-headline-md text-headline-md text-secondary">${d.cashflow.incoming.toLocaleString('en-US', { minimumFractionDigits: 2 })}</Text>
                <View className="flex-row items-center gap-1 mt-2"><MaterialIcons name="trending-up" size={14} color="#006b5a" /><Text className="text-caption text-secondary">+{d.cashflow.incoming_change}% vs last month</Text></View>
              </View>
              <View className="flex-1 min-w-[120px] p-4 rounded-xl bg-surface-bright border border-outline-variant">
                <Text className="text-caption text-on-surface-variant uppercase mb-1 tracking-wider">Outgoing</Text>
                <Text className="font-headline-md text-headline-md text-primary">${d.cashflow.outgoing.toLocaleString('en-US', { minimumFractionDigits: 2 })}</Text>
                <View className="flex-row items-center gap-1 mt-2"><MaterialIcons name="trending-flat" size={14} color="#43474d" /><Text className="text-caption text-on-surface-variant">{d.cashflow.outgoing_trend}</Text></View>
              </View>
              <View className="flex-1 min-w-[120px] p-4 rounded-xl bg-primary-container">
                <Text className="text-caption text-on-primary-container uppercase mb-1 tracking-wider">Net Position</Text>
                <Text className="font-headline-md text-headline-md text-white">${d.cashflow.net_position.toLocaleString('en-US', { minimumFractionDigits: 2 })}</Text>
                <View className="w-full bg-white/20 h-1 rounded-full mt-4 overflow-hidden">
                  <View className="bg-secondary-fixed h-full" style={{ width: `${d.cashflow.incoming > 0 ? Math.min((d.cashflow.net_position / d.cashflow.incoming) * 100, 100) : 0}%` }} />
                </View>
              </View>
            </View>
            <View className="relative h-64 w-full bg-surface-container-low rounded-xl overflow-hidden mt-6">
              <View className="absolute top-4 left-6"><Text className="text-caption font-bold text-primary">Monthly AI Forecast Overlay</Text></View>
              <View className="absolute inset-0 flex items-end p-6">
                <View className="w-full flex-row items-end justify-between gap-1 h-32">
                  {(d.cashflow?.forecast || []).map((h, i) => (
                    <View key={i} className={`flex-1 rounded-t-sm ${i === 5 ? 'bg-secondary' : 'bg-secondary/40'}`} style={{ height: `${h}%` }} />
                  ))}
                </View>
              </View>
            </View>
          </View>

          <View className="bg-surface-container-lowest rounded-xl p-6 border border-[#E6EBF1] flex-1 min-w-[260px]" style={{ shadowColor: '#000', shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.04, shadowRadius: 20, elevation: 2 }}>
            <Text className="font-headline-md text-headline-md flex-row items-center gap-2 mb-6"><MaterialIcons name="event-note" size={22} color="#060045" />{' Payroll Tasks'}</Text>
            <View className="gap-4">
              {(d.payroll_tasks || []).map((task) => (
                <View key={task.id} className={`p-4 rounded-xl ${task.status === 'overdue' ? 'bg-error-container/30 border-l-4 border-error' : 'bg-surface-bright border border-outline-variant'}`}>
                  <View className="flex-row gap-4">
                    <View className={`p-2 rounded-lg ${task.status === 'overdue' ? 'bg-error' : task.status === 'completed' ? 'bg-secondary-container' : 'bg-tertiary-fixed'}`}>
                      <MaterialIcons name={task.status === 'overdue' ? 'priority-high' : task.status === 'completed' ? 'check-circle' : 'person-add'} size={18} color={task.status === 'overdue' ? '#ffffff' : task.status === 'completed' ? '#00705e' : '#321ed2'} />
                    </View>
                    <View className="flex-1">
                      <Text className="font-label-md text-label-md text-primary font-bold">{task.title}</Text>
                      <Text className="text-caption text-on-surface-variant">{task.description}</Text>
                      {task.status === 'overdue' && <Pressable onPress={() => router.push('/(tabs)/transactions')} className="mt-2"><Text className="text-error font-bold text-caption underline">Resolve Now</Text></Pressable>}
                    </View>
                  </View>
                </View>
              ))}
            </View>
            <View className="mt-auto bg-surface-container p-4 rounded-xl mt-4">
              <Text className="text-caption font-bold mb-2">Payroll Health Score</Text>
              <View className="flex-row items-center gap-4">
                <View className="relative w-12 h-12 items-center justify-center">
                  <Svg width={48} height={48} viewBox="0 0 48 48">
                    <Circle cx={24} cy={24} r={20} fill="transparent" stroke="#e0e3e6" strokeWidth={4} />
                    <Circle cx={24} cy={24} r={20} fill="transparent" stroke="#006b5a" strokeDasharray="125.6" strokeDashoffset={125.6 - (125.6 * d.payroll_health_score / 100)} strokeWidth={4} />
                  </Svg>
                  <Text className="absolute text-[10px] font-bold">{d.payroll_health_score}%</Text>
                </View>
                <Text className="text-caption text-on-surface-variant flex-1">Optimized but watch compliance dates.</Text>
              </View>
            </View>
          </View>
        </View>

        <View className="bg-surface-container-lowest rounded-xl p-6 border border-[#E6EBF1] mt-6" style={{ shadowColor: '#000', shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.04, shadowRadius: 20, elevation: 2 }}>
          <View className="flex-row justify-between items-center mb-6">
            <Text className="font-headline-md text-headline-md flex-row items-center gap-2"><MaterialIcons name="business" size={22} color="#006b5a" />{' B2B Vendor Ecosystem'}</Text>
            <View className="flex-row items-center gap-2">
              <Text className="text-caption text-on-surface-variant">Sort by:</Text>
              <View className="flex-row items-center"><Text className="font-label-md text-label-md">Health Score</Text><MaterialIcons name="arrow-drop-down" size={20} color="#43474d" /></View>
            </View>
          </View>
          <View className="flex-row flex-wrap" style={{ gap: 16 }}>
            {(d.vendors || []).map((v) => (
              <View key={v.id} className="flex-1 min-w-[160px] bg-surface-bright p-4 rounded-xl border border-outline-variant">
                <View className="flex-row justify-between items-start mb-4">
                  <View className="w-10 h-10 rounded-lg bg-surface-container items-center justify-center"><MaterialIcons name={v.icon as any} size={18} color="#000f22" /></View>
                  <View className="items-end"><Text className="text-[20px] font-bold" style={{ color: v.health_score >= 80 ? '#006b5a' : v.health_score >= 50 ? '#181c1e' : '#ba1a1a' }}>{v.health_score}</Text><Text className="text-[8px] uppercase font-bold text-on-surface-variant">Score</Text></View>
                </View>
                <Text className="font-label-md text-label-md font-bold mb-1">{v.name}</Text>
                <Text className="text-caption text-on-surface-variant mb-4">{v.description}</Text>
                <View className="flex-row justify-between items-center">
                  <View className={`px-2 py-0.5 rounded ${v.badge_bg}`}><Text className={`text-[10px] font-bold ${v.badge_text}`}>{v.badge}</Text></View>
                  <MaterialIcons name="chevron-right" size={18} color="#43474d" />
                </View>
              </View>
            ))}
          </View>
        </View>

        <View className="mt-8">
          <Text className="font-headline-md text-headline-md text-primary font-bold mb-4">Quick Actions</Text>
          <View className="flex-row flex-wrap" style={{ gap: 12 }}>
            <Pressable onPress={() => router.push('/(tabs)/business-health')} className="flex-1 min-w-[140px] bg-surface-container-lowest rounded-xl p-4 border border-outline-variant active:scale-95" style={{ elevation: 2, shadowColor: '#000', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.04 }}>
              <MaterialIcons name="monitor-heart" size={24} color="#006b5a" />
              <Text className="font-label-md text-label-md text-primary font-bold mt-2">Health</Text>
              <Text className="text-caption text-on-surface-variant">Business health score</Text>
            </Pressable>
            <Pressable onPress={() => router.push('/(tabs)/business-forecast')} className="flex-1 min-w-[140px] bg-surface-container-lowest rounded-xl p-4 border border-outline-variant active:scale-95" style={{ elevation: 2, shadowColor: '#000', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.04 }}>
              <MaterialIcons name="insights" size={24} color="#006b5a" />
              <Text className="font-label-md text-label-md text-primary font-bold mt-2">Forecast</Text>
              <Text className="text-caption text-on-surface-variant">Revenue projections</Text>
            </Pressable>
            <Pressable onPress={() => router.push('/(tabs)/business-vendors')} className="flex-1 min-w-[140px] bg-surface-container-lowest rounded-xl p-4 border border-outline-variant active:scale-95" style={{ elevation: 2, shadowColor: '#000', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.04 }}>
              <MaterialIcons name="store" size={24} color="#006b5a" />
              <Text className="font-label-md text-label-md text-primary font-bold mt-2">Vendors</Text>
              <Text className="text-caption text-on-surface-variant">Manage vendors</Text>
            </Pressable>
            <Pressable onPress={() => router.push('/(tabs)/business-ai-advice')} className="flex-1 min-w-[140px] bg-surface-container-lowest rounded-xl p-4 border border-outline-variant active:scale-95" style={{ elevation: 2, shadowColor: '#000', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.04 }}>
              <MaterialIcons name="psychology" size={24} color="#006b5a" />
              <Text className="font-label-md text-label-md text-primary font-bold mt-2">AI Advice</Text>
              <Text className="text-caption text-on-surface-variant">AI recommendations</Text>
            </Pressable>
          </View>
        </View>

        <View className="flex-row flex-wrap mt-6" style={{ gap: 24 }}>
          <View className="bg-primary-container rounded-xl p-6 flex-1 min-w-[260px]">
            <Text className="font-headline-md text-headline-md text-white mb-2">Growth Pulse AI</Text>
            <Text className="text-body-md text-white/80 mb-6">Real-time analysis of your market competitiveness.</Text>
            <View className="mt-auto gap-4">
              <View className="flex-row justify-between items-center border-b border-white/10 pb-2">
                <Text className="text-caption text-white/70">Market Share Growth</Text>
                <Text className="font-bold text-secondary-fixed">+{d.growth_pulse.market_share_growth}%</Text>
              </View>
              <View className="flex-row justify-between items-center border-b border-white/10 pb-2">
                <Text className="text-caption text-white/70">Customer Lifetime Value</Text>
                <Text className="font-bold text-white">${d.growth_pulse.customer_lifetime_value.toLocaleString()}</Text>
              </View>
              <View className="flex-row justify-between items-center">
                <Text className="text-caption text-white/70">Burn Rate Efficiency</Text>
                <Text className="font-bold text-secondary-fixed">{d.growth_pulse.burn_rate_efficiency}</Text>
              </View>
            </View>
          </View>

          <View className="bg-surface-container-lowest rounded-xl p-6 border border-[#E6EBF1] flex-[2] min-w-[300px]" style={{ shadowColor: '#000', shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.04, shadowRadius: 20, elevation: 2 }}>
            <View className="flex-row items-center justify-between mb-6">
              <View className="flex-row items-center gap-3">
                <View className="w-10 h-10 rounded-full bg-secondary-container items-center justify-center"><MaterialIcons name="security" size={20} color="#00705e" /></View>
                <Text className="font-headline-md text-headline-md">Fraud Protection</Text>
              </View>
              <View className="bg-surface-variant px-3 py-1 rounded-full"><Text className="text-on-surface-variant text-caption font-bold">24/7 MONITORING ACTIVE</Text></View>
            </View>
            <View className="gap-4">
              {d.fraud_events.length > 0 ? d.fraud_events.map((event) => (
                <View key={event.id} className="flex-row items-center justify-between p-4 bg-surface-bright rounded-xl border border-outline-variant">
                  <View className="flex-row items-center gap-4 flex-1">
                    <View className={`w-2 h-2 rounded-full ${event.severity === 'critical' ? 'bg-error' : 'bg-secondary'}`} />
                    <View className="flex-1">
                      <Text className="font-label-md text-label-md font-bold">{event.event_type}</Text>
                      <Text className="text-caption text-on-surface-variant">{event.description}</Text>
                    </View>
                  </View>
                  <MaterialIcons name={event.severity === 'critical' ? 'warning' : 'verified'} size={20} color={event.severity === 'critical' ? '#ba1a1a' : '#006b5a'} />
                </View>
              )) : (
                <View className="py-8 items-center">
                  <MaterialIcons name="security" size={40} color="#c4c7cb" />
                  <Text className="text-on-surface-variant text-body-md mt-3">No fraud events detected.</Text>
                  <Text className="text-caption text-on-surface-variant">Your account is secure.</Text>
                </View>
              )}
            </View>
          </View>
        </View>
      </ScrollView>
    </View>
  );
}