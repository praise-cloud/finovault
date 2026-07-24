import { useEffect } from 'react';
import { ScrollView, View, Text, Pressable, ActivityIndicator } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { useDashboardStore } from '@/stores/dashboard-store';
import { useAuthStore } from '@/stores/auth-store';
import { router } from 'expo-router';

type IconName = React.ComponentProps<typeof MaterialIcons>['name'];

const navItems: { name: string; icon: IconName; active: boolean }[] = [
  { name: 'Dashboard', icon: 'dashboard', active: true },
  { name: 'Wealth Growth', icon: 'trending-up', active: false },
  { name: 'Smart Savings', icon: 'savings', active: false },
  { name: 'Fraud Protection', icon: 'security', active: false },
  { name: 'SME Analytics', icon: 'analytics', active: false },
];

export default function FreelancerDashboard() {
  const data = useDashboardStore((s) => s.freelancer);
  const isLoading = useDashboardStore((s) => s.isLoading);
  const load = useDashboardStore((s) => s.loadFreelancer);
  const user = useAuthStore((s) => s.user);
  const userName = user?.user_metadata?.full_name || user?.email?.split('@')[0] || 'User';

  useEffect(() => { load(); }, [load]);

  if (!data) {
    return <View className="flex-1 bg-surface-bright items-center justify-center"><ActivityIndicator size="large" color="#08142E" /></View>;
  }

  const d = data;

  return (
    <View className="flex-1 bg-surface-bright">
      <View className="bg-surface-bright pt-14 pb-3 px-margin-mobile md:px-margin-desktop" style={{ elevation: 4, boxShadow: '0 4px 4px rgba(0,0,0,0.04)' }}>
        <View className="flex-row items-center justify-between max-w-[1440px] mx-auto w-full">
          <View className="flex-row items-center gap-4">
            <Text className="font-headline-md text-headline-md text-primary font-bold">Finovault AI</Text>
          </View>
          <View className="flex-row items-center gap-4">
            <Text className="hidden md:block font-label-md text-label-md text-on-surface-variant">Welcome, {userName}</Text>
            <View className="w-8 h-8 rounded-full border-2 border-primary-fixed items-center justify-center bg-surface-container-high"><MaterialIcons name="person" size={18} color="#43474d" /></View>
          </View>
        </View>
      </View>

      <View className="flex-1 flex-row max-w-[1440px] mx-auto w-full">
        <View className="hidden md:flex w-80 bg-surface-container rounded-r-xl py-6" style={{ boxShadow: '0 12px 40px rgba(0,0,0,0.08)', elevation: 8 }}>
          <View className="px-6 mb-8 flex-row items-center gap-3">
            <View className="w-10 h-10 rounded-full bg-surface-container-high items-center justify-center"><MaterialIcons name="person" size={22} color="#43474d" /></View>
            <View><Text className="font-label-md font-bold text-on-surface">{userName}</Text><Text className="text-[12px] text-on-surface-variant">Individual Pro Plan • Verified</Text></View>
          </View>
          <View className="flex-1 gap-1">
            {navItems.map((item) => (
              <Pressable key={item.name} onPress={() => {
                const routes: Record<string, string> = {
                  'Dashboard': '/(tabs)',
                  'Wealth Growth': '/(tabs)/wealth-growth',
                  'Smart Savings': '/(tabs)/savings-goals',
                  'Fraud Protection': '/(tabs)/fraud-protection',
                  'SME Analytics': '/(tabs)/sme-analytics',
                };
                if (routes[item.name]) router.push(routes[item.name] as any);
              }} className={`flex-row items-center gap-3 mx-2 px-4 py-3 rounded-full ${item.active ? 'bg-secondary-container' : ''}`}>
                <MaterialIcons name={item.icon} size={20} color={item.active ? '#1A1A1A' : '#43474d'} />
                <Text className={`font-bold ${item.active ? 'text-on-secondary-container' : 'text-on-surface-variant'}`}>{item.name}</Text>
              </Pressable>
            ))}
          </View>
        </View>

        <ScrollView className="flex-1 px-margin-mobile md:px-margin-desktop" contentContainerStyle={{ paddingBottom: 120 }}>
          <View className="my-8">
            <Text className="font-headline-lg text-headline-lg text-primary mb-2">Freelance Overview</Text>
            <Text className="font-body-md text-body-md text-on-surface-variant">Managing your income and tax strategy in real-time.</Text>
          </View>

          <View className="flex-row flex-wrap gap-gutter">
            <View className="w-full md:flex-[2] md:min-w-0 min-w-[280px] p-md rounded-xl relative overflow-hidden" style={{ backgroundColor: 'rgba(255,255,255,0.8)', borderWidth: 1, borderColor: '#E6EBF1', boxShadow: '0 4px 20px rgba(0,0,0,0.04)', elevation: 2 }}>
              <View className="absolute top-0 right-0 w-32 h-32 opacity-10 rounded-bl-full" style={{ backgroundColor: '#F4D35E' }} />
              <View>
                <View className="flex-row justify-between items-start mb-4">
                  <View className="bg-secondary-container px-3 py-1 rounded-full"><Text className="text-caption text-on-secondary-container">Estimated Tax Liability</Text></View>
                  <MaterialIcons name="info" size={20} color="#74777e" />
                </View>
                <Text className="font-display-lg text-display-lg text-primary tracking-tighter">${d.tax_liability.toLocaleString('en-US', { minimumFractionDigits: 2 })}</Text>
                <Text className="font-label-md text-label-md text-on-surface-variant mt-2">Recommended for Q3 2023</Text>
              </View>
              <View className="mt-8">
                <View className="w-full bg-surface-variant h-2 rounded-full mb-3 overflow-hidden">
                  <View className="bg-secondary h-full rounded-full" style={{ width: `${d.tax_goal_pct}%` }} />
                </View>
                <View className="flex-row justify-between font-label-md">
                  <Text className="text-on-surface-variant">Withheld: ${d.tax_withheld.toLocaleString('en-US', { minimumFractionDigits: 2 })}</Text>
                  <Text className="text-secondary font-bold">Goal: {d.tax_goal_pct}%</Text>
                </View>
              </View>
            </View>

            <View className="w-full md:flex-1 md:min-w-0 min-w-[200px] p-md rounded-xl" style={{ backgroundColor: 'rgba(255,255,255,0.8)', borderWidth: 1, borderColor: '#E6EBF1', boxShadow: '0 4px 20px rgba(0,0,0,0.04)', elevation: 2 }}>
              <View className="flex-row items-center gap-3 mb-6">
                <View className="p-2 bg-primary-fixed rounded-lg"><MaterialIcons name="work" size={20} color="#0A1F5C" /></View>
                <Text className="font-headline-md text-[18px] font-bold">Income Tracking</Text>
              </View>
              <View className="flex-1">
                <View className="flex-row justify-between items-center mb-4">
                  <Text className="font-label-md text-on-surface-variant">Project-based</Text>
                  <Text className="font-label-md font-bold text-primary">${d.income.project_based.toLocaleString()}</Text>
                </View>
                <View className="flex-row justify-between items-center mb-4">
                  <Text className="font-label-md text-on-surface-variant">Retainers</Text>
                  <Text className="font-label-md font-bold text-primary">${d.income.retainers.toLocaleString()}</Text>
                </View>
              </View>
              <Pressable onPress={() => router.push('/(tabs)/transactions')} className="mt-4 w-full py-2 bg-surface-container-high rounded-lg items-center active:scale-95">
                <Text className="font-label-md text-primary">View Details</Text>
              </Pressable>
            </View>

            <View className="w-full md:flex-1 md:min-w-0 min-w-[200px] p-md rounded-xl bg-primary" style={{ boxShadow: '0 4px 20px rgba(0,0,0,0.04)', elevation: 2 }}>
              <View className="flex-row justify-between items-center mb-6">
                <MaterialIcons name="receipt-long" size={24} color="#F4D35E" />
                <View className="bg-secondary px-2 py-0.5 rounded"><Text className="text-[10px] text-on-secondary uppercase font-bold">{d.overdue_count} Overdue</Text></View>
              </View>
              <Text className="font-label-md text-on-primary-container mb-1">Unpaid Invoices</Text>
              <Text className="font-headline-lg text-headline-lg text-white font-bold">${d.unpaid_invoices.toLocaleString('en-US', { minimumFractionDigits: 2 })}</Text>
              <View className="mt-auto pt-4">
                <View className="flex-row -space-x-2">
                  {[1, 2, 3].map((i) => (
                    <View key={i} className="w-8 h-8 rounded-full bg-surface-variant border-2 border-primary items-center justify-center -ml-2 first:ml-0">
                      {i < 3 ? <MaterialIcons name="business" size={12} color="#43474d" /> : <Text className="text-[10px] text-primary font-bold">+1</Text>}
                    </View>
                  ))}
                </View>
              </View>
            </View>

            <View className="w-full md:flex-[3] md:min-w-0 min-w-[280px] rounded-xl overflow-hidden" style={{ backgroundColor: 'rgba(255,255,255,0.8)', borderWidth: 1, borderColor: '#E6EBF1', boxShadow: '0 4px 20px rgba(0,0,0,0.04)', elevation: 2 }}>
              <View className="p-md border-b border-outline-variant flex-row justify-between items-center">
                <Text className="font-headline-md text-[20px] font-bold">Recent Projects & Status</Text>
                <Pressable onPress={() => router.push('/(tabs)/transactions')} className="flex-row items-center gap-1"><Text className="text-secondary font-label-md">All Projects</Text><MaterialIcons name="arrow-forward" size={18} color="#08142E" /></Pressable>
              </View>
              <View className="overflow-x-auto">
                <View className="flex-row bg-surface-container-low px-md py-3">
                  <Text className="flex-[2] font-label-md text-on-surface-variant">Project Name</Text>
                  <Text className="flex-[1.5] font-label-md text-on-surface-variant">Client</Text>
                  <Text className="flex-[1] font-label-md text-on-surface-variant">Amount</Text>
                  <Text className="flex-[1] font-label-md text-on-surface-variant">Status</Text>
                  <View className="w-8" />
                </View>
                {(d.projects || []).map((proj) => (
                  <View key={proj.id} className="flex-row items-center px-md py-4 border-b border-outline-variant/50">
                    <Text className="flex-[2] font-label-md font-bold">{proj.name}</Text>
                    <Text className="flex-[1.5] font-body-md text-on-surface-variant">{proj.client}</Text>
                    <Text className="flex-[1] font-body-md">${proj.amount.toLocaleString('en-US', { minimumFractionDigits: 2 })}</Text>
                    <View className="flex-1">
                      <View className={`self-start px-3 py-1 rounded-full ${proj.status === 'Invoiced' ? 'bg-secondary-container' : proj.status === 'In Progress' ? 'bg-primary-container' : 'bg-error-container'}`}>
                        <Text className={`text-caption ${proj.status === 'Invoiced' ? 'text-on-secondary-container' : proj.status === 'In Progress' ? 'text-on-primary-container' : 'text-on-error-container'}`}>{proj.status}</Text>
                      </View>
                    </View>
                    <Pressable onPress={() => router.push('/(tabs)/transactions')} className="w-8 items-center"><MaterialIcons name="more-vert" size={20} color="#74777e" /></Pressable>
                  </View>
                ))}
              </View>
            </View>

            <View className="w-full md:flex-1 md:min-w-0 min-w-[200px] p-md rounded-xl items-center justify-center" style={{ backgroundColor: 'rgba(255,255,255,0.8)', borderWidth: 1, borderColor: '#E6EBF1', boxShadow: '0 4px 20px rgba(0,0,0,0.04)', elevation: 2 }}>
              <Pressable onPress={() => router.push('/(tabs)/transactions')} className="items-center active:scale-95">
                <View className="w-12 h-12 rounded-full bg-secondary-container items-center justify-center mb-3"><MaterialIcons name="add" size={24} color="#1A1A1A" /></View>
                <Text className="font-label-md font-bold">New Invoice</Text>
              </Pressable>
            </View>
          </View>

          <View className="mt-12 bg-primary-container rounded-2xl p-lg relative overflow-hidden">
            <View className="flex-row flex-wrap gap-md">
              <View className="flex-1 min-w-[280px]">
                <Text className="font-headline-lg text-headline-lg text-white mb-4">Optimize your Tax Shield</Text>
                <Text className="font-body-md text-on-primary-container mb-6 max-w-md">{d.tax_shield_message}</Text>
                <Pressable onPress={() => router.push('/(tabs)/ai-coach')} className="bg-secondary-fixed px-6 py-3 rounded-full self-start active:scale-95">
                  <Text className="font-label-md font-bold text-on-secondary-fixed">Review Strategy</Text>
                </Pressable>
              </View>
              <View className="items-center flex-1 min-w-[200px]">
                <View className="bg-white/5 p-6 rounded-2xl border border-white/10 w-full max-w-[200px]">
                  <View className="flex-row justify-between items-center mb-4">
                    <Text className="font-label-md text-white/70">Projected Savings</Text>
                    <Text className="text-secondary-fixed font-bold">↑ 12%</Text>
                  </View>
                  <View className="h-32 flex-row items-end gap-2">
                    <View className="flex-1 bg-secondary/40 h-12 rounded-t-sm" />
                    <View className="flex-1 bg-secondary/60 h-20 rounded-t-sm" />
                    <View className="flex-1 bg-secondary h-28 rounded-t-sm" />
                    <View className="flex-1 bg-secondary-fixed h-24 rounded-t-sm" />
                  </View>
                </View>
              </View>
            </View>
          </View>
        </ScrollView>
      </View>
    </View>
  );
}