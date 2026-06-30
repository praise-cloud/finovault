import { useEffect } from 'react';
import { ScrollView, View, Text, Pressable, ActivityIndicator } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { useDashboardStore } from '@/stores/dashboard-store';

export default function IndividualDashboard() {
  const summary = useDashboardStore((s) => s.summary);
  const isLoading = useDashboardStore((s) => s.isLoading);
  const loadSummary = useDashboardStore((s) => s.loadSummary);

  useEffect(() => {
    loadSummary();
  }, [loadSummary]);

  const data = summary || {
    total_net_worth: 0,
    net_worth_change: 0,
    net_worth_change_pct: 0,
    monthly_spending: 0,
    spending_limit: 0,
    spending_trend: null,
    next_best_move: null,
    recent_transactions: [],
    asset_allocations: [],
  } as any;

  if (isLoading && !summary) {
    return (
      <View className="flex-1 bg-surface-bright items-center justify-center">
        <ActivityIndicator size="large" color="#006b5a" />
      </View>
    );
  }
    return (
    <View className="flex-1 bg-surface-bright">
      <View className="bg-surface-bright pt-14 pb-3 px-margin-mobile" style={{ shadowColor: '#000', shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.04, shadowRadius: 20, elevation: 4 }}>
        <View className="flex-row items-center justify-between">
          <View className="flex-row items-center gap-4">
            <Pressable className="md:hidden active:scale-95">
              <MaterialIcons name="menu" size={24} color="#000f22" />
            </Pressable>
            <Text className="font-headline-md text-primary font-bold">Finovault AI</Text>
          </View>
          <View className="flex-row items-center gap-4">
            <Pressable className="p-2 rounded-full active:scale-95">
              <MaterialIcons name="notifications" size={22} color="#43474d" />
            </Pressable>
            <View className="w-10 h-10 rounded-full overflow-hidden border border-outline-variant bg-surface-container-high items-center justify-center">
              <MaterialIcons name="person" size={22} color="#43474d" />
            </View>
          </View>
        </View>
      </View>

      <ScrollView className="flex-1 px-margin-mobile" contentContainerStyle={{ paddingBottom: 120 }}>
        <View className="relative overflow-hidden bg-primary-container rounded-3xl p-8 mt-4" style={{ shadowColor: '#000', shadowOffset: { width: 0, height: 4 }, shadowRadius: 12, elevation: 4 }}>
          <View className="relative z-10">
            <Text className="text-on-primary-container font-label-md uppercase tracking-widest mb-2">Total Net Worth</Text>
            <View className="flex-row items-baseline gap-3">
              <Text className="font-display-lg text-display-lg text-on-primary">${data.total_net_worth.toLocaleString('en-US', { minimumFractionDigits: 2 })}</Text>
              {data.net_worth_change > 0 && (
                <View className="bg-secondary/20 px-2 py-1 rounded-lg flex-row items-center">
                  <MaterialIcons name="arrow-upward" size={14} color="#58fbda" />
                  <Text className="text-secondary-fixed font-label-md ml-1">{data.net_worth_change_pct}%</Text>
                </View>
              )}
            </View>
            <Text className="text-on-primary-container mt-4 font-body-md">Your wealth has grown by ${data.net_worth_change.toLocaleString()} this month, primarily driven by your diversified SME equity portfolio.</Text>
            <View className="flex-row gap-4 mt-6">
              <Pressable className="bg-secondary-fixed px-6 py-3 rounded-full active:scale-95" style={{ shadowColor: 'rgba(0,107,90,0.25)', shadowOffset: { width: 0, height: 4 }, shadowRadius: 8 }}>
                <Text className="text-on-secondary-fixed font-bold">Add Asset</Text>
              </Pressable>
              <Pressable className="bg-white/10 backdrop-blur-md px-6 py-3 rounded-full border border-white/20 active:scale-95">
                <Text className="text-white font-bold">Detailed Report</Text>
              </Pressable>
            </View>
          </View>
        </View>

        <View className="flex-col gap-gutter mt-6">
          {data.next_best_move && (
            <View className="bg-surface-container-lowest border border-outline-variant/30 rounded-3xl p-6 relative overflow-hidden">
              <View className="absolute -top-12 -right-12 w-48 h-48 bg-secondary/10 rounded-full" />
              <View className="relative z-10">
                <View className="flex-row items-center gap-2 mb-6">
                  <MaterialIcons name="auto-awesome" size={20} color="#006b5a" />
                  <Text className="font-headline-md text-headline-md text-primary">Next Best Move</Text>
                </View>
                <View className="bg-surface-bright p-5 rounded-2xl border border-secondary-fixed/30 mb-4">
                  <Text className="font-body-lg text-primary font-medium mb-1">{data.next_best_move.title}</Text>
                  <Text className="text-on-surface-variant text-label-md">{data.next_best_move.description}</Text>
                </View>
                <View className="flex-row items-center gap-4">
                  <Pressable className="flex-1 bg-secondary py-3 rounded-xl items-center active:scale-95">
                    <Text className="text-on-secondary font-bold">Execute Transfer</Text>
                  </Pressable>
                  <Pressable className="p-3 border border-outline-variant rounded-xl active:scale-95">
                    <MaterialIcons name="more-horiz" size={20} color="#43474d" />
                  </Pressable>
                </View>
              </View>
            </View>
          )}

          <View className="bg-surface-container-lowest border border-outline-variant/30 rounded-3xl p-6">
            <Text className="font-label-md text-on-surface-variant uppercase mb-4 tracking-wider">Monthly Spending</Text>
            <View>
              <Text className="font-headline-lg text-headline-lg text-primary">${data.monthly_spending.toLocaleString('en-US', { minimumFractionDigits: 2 })}</Text>
              {data.spending_trend === 'up' && (
                <View className="flex-row items-center mt-1">
                  <MaterialIcons name="trending-up" size={16} color="#ba1a1a" />
                  <Text className="text-error font-label-md ml-1">{Math.round((data.monthly_spending / data.spending_limit - 1) * 100)}% above limit</Text>
                </View>
              )}
            </View>
            <View className="mt-6 space-y-3">
              <View className="flex-row justify-between items-center text-label-md">
                <Text className="text-on-surface-variant">Housing</Text>
                <Text className="font-bold">$3,200</Text>
              </View>
              <View className="w-full bg-surface-container rounded-full h-1.5 overflow-hidden">
                <View className="bg-primary h-full" style={{ width: '45%' }} />
              </View>
              <View className="flex-row justify-between items-center text-label-md">
                <Text className="text-on-surface-variant">Lifestyle</Text>
                <Text className="font-bold">$2,100</Text>
              </View>
              <View className="w-full bg-surface-container rounded-full h-1.5 overflow-hidden">
                <View className="bg-secondary h-full" style={{ width: '70%' }} />
              </View>
            </View>
          </View>

          <View className="bg-surface-container-lowest border border-outline-variant/30 rounded-3xl p-6">
            <View className="flex-row justify-between items-center mb-6">
              <Text className="font-headline-md text-headline-md text-primary">Asset Allocation</Text>
              <MaterialIcons name="info" size={20} color="#43474d" />
            </View>
            <View className="space-y-4">
              {data.asset_allocations.length > 0 ? data.asset_allocations.map((item: any) => (
                <Pressable key={item.id} className="flex-row items-center gap-4 p-3 rounded-xl active:scale-[0.98]">
                  <View className="w-10 h-10 rounded-full items-center justify-center" style={{ backgroundColor: item.color + '20' }}>
                    <MaterialIcons name={item.icon as any} size={20} color={item.color} />
                  </View>
                  <View className="flex-1">
                    <Text className="font-bold text-primary">{item.category}</Text>
                    <Text className="text-caption text-on-surface-variant">{item.percentage}% of portfolio</Text>
                  </View>
                  <Text className="font-bold text-primary">${item.value.toLocaleString()}</Text>
                </Pressable>
              )) : (
                <Text className="text-on-surface-variant text-body-md text-center py-4">No assets allocated yet.</Text>
              )}
            </View>
          </View>

          <View className="bg-surface-container-lowest border border-outline-variant/30 rounded-3xl p-6">
            <View className="flex-row justify-between items-center mb-6">
              <Text className="font-headline-md text-headline-md text-primary">Recent Flux</Text>
              <Pressable><Text className="text-secondary font-label-md">View all</Text></Pressable>
            </View>
            <View className="space-y-5">
              {data.recent_transactions.length > 0 ? data.recent_transactions.slice(0, 3).map((tx: any, i: number) => (
                <View key={tx.id || i} className="flex-row gap-4">
                  <View className={`w-2 h-10 rounded-full ${tx.type === 'income' ? 'bg-secondary' : 'bg-error opacity-60'}`} />
                  <View className="flex-1">
                    <Text className="font-label-md text-primary font-bold">{tx.description}</Text>
                    <Text className="text-caption text-on-surface-variant">{tx.merchant || tx.category} • {new Date(tx.date).toLocaleDateString()}</Text>
                    <Text className={`font-bold text-label-md ${tx.type === 'income' ? 'text-secondary' : 'text-on-surface'}`}>
                      {tx.type === 'income' ? '+' : '-'}${tx.amount.toLocaleString('en-US', { minimumFractionDigits: 2 })}
                    </Text>
                  </View>
                </View>
              )) : (
                <Text className="text-on-surface-variant text-body-md text-center py-4">No recent transactions.</Text>
              )}
            </View>
          </View>
        </View>
      </ScrollView>
    </View>
  );
}