import { useState, useEffect } from 'react';
import { ScrollView, View, Text, Pressable, ActivityIndicator } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { useDashboardStore } from '@/stores/dashboard-store';
import { router } from 'expo-router';
import { NotificationIcon, NotificationModal } from '@/components/notification-modal';

export default function IndividualDashboard() {
  const summary = useDashboardStore((s) => s.summary);
  const isLoading = useDashboardStore((s) => s.isLoading);
  const loadSummary = useDashboardStore((s) => s.loadSummary);
  const [notifVisible, setNotifVisible] = useState(false);

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
          <View className="flex-row items-center gap-3">
            <View className="w-9 h-9 rounded-xl bg-primary items-center justify-center">
              <Text className="text-on-primary font-bold text-sm">F</Text>
            </View>
            <Text className="font-headline-md text-primary font-bold">Dashboard</Text>
          </View>
          <View className="flex-row items-center gap-3">
            <NotificationIcon onPress={() => setNotifVisible(true)} count={3} />
            <Pressable onPress={() => router.push('/(tabs)/profile')} className="w-9 h-9 rounded-full overflow-hidden border border-outline-variant bg-surface-container-high items-center justify-center active:scale-90">
              <MaterialIcons name="person" size={20} color="#43474d" />
            </Pressable>
          </View>
        </View>
      </View>

      <ScrollView className="flex-1 px-margin-mobile" contentContainerStyle={{ paddingBottom: 120 }} showsVerticalScrollIndicator={false}>
        <View className="flex-row flex-wrap mt-4" style={{ gap: 12 }}>
          <View className="bg-primary-container rounded-2xl p-5 relative overflow-hidden" style={{ width: '48%' }}>
            <View className="absolute -top-8 -right-8 w-24 h-24 bg-secondary/10 rounded-full" />
            <Text className="text-on-primary-container font-caption uppercase tracking-wider mb-1">Net Worth</Text>
            <Text className="font-headline-lg text-headline-lg text-on-primary font-bold">${data.total_net_worth.toLocaleString('en-US', { minimumFractionDigits: 0 })}</Text>
            {data.net_worth_change > 0 && (
              <View className="flex-row items-center mt-1">
                <MaterialIcons name="arrow-upward" size={14} color="#58fbda" />
                <Text className="text-secondary-fixed font-label-md ml-1">+{data.net_worth_change_pct}%</Text>
              </View>
            )}
          </View>
          <View className="bg-surface-container-lowest border border-outline-variant/20 rounded-2xl p-5" style={{ width: '48%' }}>
            <Text className="font-caption text-on-surface-variant uppercase tracking-wider mb-1">Spending</Text>
            <Text className="font-headline-lg text-headline-lg text-primary font-bold">${data.monthly_spending.toLocaleString('en-US', { minimumFractionDigits: 0 })}</Text>
            {data.spending_trend === 'up' && (
              <View className="flex-row items-center mt-1">
                <MaterialIcons name="trending-up" size={14} color="#ba1a1a" />
                <Text className="text-error font-label-md ml-1">{Math.round((data.monthly_spending / (data.spending_limit || 1)) * 100)}%</Text>
              </View>
            )}
          </View>
        </View>

        {data.next_best_move && (
          <View className="bg-gradient-to-br from-secondary to-[#005143] rounded-2xl p-5 mt-4 relative overflow-hidden">
            <View className="absolute -top-8 -right-8 w-32 h-32 bg-white/5 rounded-full" />
            <View className="flex-row items-center gap-2 mb-2">
              <MaterialIcons name="auto-awesome" size={16} color="#58fbda" />
              <Text className="text-secondary-fixed font-label-md font-bold">AI Recommendation</Text>
            </View>
            <Text className="text-white font-headline-md font-bold mb-1">{data.next_best_move.title}</Text>
            <Text className="text-white/80 text-body-md mb-4">{data.next_best_move.description}</Text>
            <Pressable className="bg-white/20 backdrop-blur-md px-5 py-2.5 rounded-xl self-start active:scale-95 border border-white/20">
              <Text className="text-white font-label-md font-bold">Execute Transfer</Text>
            </Pressable>
          </View>
        )}

        <View className="mt-4">
          <View className="flex-row items-center justify-between mb-3">
            <Text className="font-headline-md text-primary font-bold">Asset Allocation</Text>
            <Pressable><Text className="text-secondary font-label-md font-bold">View All</Text></Pressable>
          </View>
          <View className="bg-surface-container-lowest border border-outline-variant/20 rounded-2xl p-4">
            {data.asset_allocations.length > 0 ? (
              data.asset_allocations.map((item: any) => (
                <View key={item.id} className="flex-row items-center gap-3 py-3 border-b border-outline-variant/10 last:border-b-0">
                  <View className="w-9 h-9 rounded-full items-center justify-center" style={{ backgroundColor: item.color + '20' }}>
                    <MaterialIcons name={item.icon as any} size={18} color={item.color} />
                  </View>
                  <View className="flex-1">
                    <View className="flex-row justify-between items-center">
                      <Text className="font-label-md font-bold text-primary">{item.category}</Text>
                      <Text className="font-label-md text-primary font-bold">${item.value.toLocaleString()}</Text>
                    </View>
                    <View className="w-full bg-surface-container rounded-full h-1.5 mt-1.5 overflow-hidden">
                      <View className="h-full rounded-full" style={{ width: `${item.percentage}%`, backgroundColor: item.color }} />
                    </View>
                  </View>
                </View>
              ))
            ) : (
              <Text className="text-on-surface-variant text-body-md text-center py-6">No assets allocated yet.</Text>
            )}
          </View>
        </View>

        <View className="mt-4">
          <View className="flex-row items-center justify-between mb-3">
            <Text className="font-headline-md text-primary font-bold">Recent Activity</Text>
            <Pressable><Text className="text-secondary font-label-md font-bold">View All</Text></Pressable>
          </View>
          <View className="bg-surface-container-lowest border border-outline-variant/20 rounded-2xl overflow-hidden">
            {data.recent_transactions.length > 0 ? (
              data.recent_transactions.slice(0, 4).map((tx: any, i: number) => (
                <View key={tx.id || i} className="flex-row items-center gap-3 px-4 py-3.5 border-b border-outline-variant/10 last:border-b-0">
                  <View className={`w-9 h-9 rounded-full items-center justify-center ${tx.type === 'income' ? 'bg-secondary-container' : 'bg-error-container'}`}>
                    <MaterialIcons name={tx.type === 'income' ? 'arrow-downward' : 'arrow-upward'} size={18} color={tx.type === 'income' ? '#00705e' : '#ba1a1a'} />
                  </View>
                  <View className="flex-1">
                    <Text className="font-label-md font-bold text-primary">{tx.description}</Text>
                    <Text className="text-caption text-on-surface-variant">{tx.merchant || tx.category}</Text>
                  </View>
                  <Text className={`font-label-md font-bold ${tx.type === 'income' ? 'text-secondary' : 'text-on-surface'}`}>
                    {tx.type === 'income' ? '+' : '-'}${tx.amount.toLocaleString('en-US', { minimumFractionDigits: 2 })}
                  </Text>
                </View>
              ))
            ) : (
              <Text className="text-on-surface-variant text-body-md text-center py-8">No recent activity.</Text>
            )}
          </View>
        </View>

        <View className="flex-row flex-wrap mt-4" style={{ gap: 12 }}>
          <Pressable className="bg-surface-container-lowest border border-outline-variant/20 rounded-2xl p-4 flex-row items-center gap-3 active:scale-[0.98]" style={{ width: '48%' }}>
            <View className="w-10 h-10 rounded-xl bg-secondary-container items-center justify-center">
              <MaterialIcons name="trending-up" size={20} color="#00705e" />
            </View>
            <View className="flex-1">
              <Text className="font-label-md font-bold text-primary">Wealth</Text>
              <Text className="text-caption text-on-surface-variant">Track growth</Text>
            </View>
          </Pressable>
          <Pressable className="bg-surface-container-lowest border border-outline-variant/20 rounded-2xl p-4 flex-row items-center gap-3 active:scale-[0.98]" style={{ width: '48%' }}>
            <View className="w-10 h-10 rounded-xl bg-primary-container items-center justify-center">
              <MaterialIcons name="savings" size={20} color="#000f22" />
            </View>
            <View className="flex-1">
              <Text className="font-label-md font-bold text-primary">Savings</Text>
              <Text className="text-caption text-on-surface-variant">Smart goals</Text>
            </View>
          </Pressable>
        </View>
      </ScrollView>

      <NotificationModal visible={notifVisible} onClose={() => setNotifVisible(false)} />
    </View>
  );
}
