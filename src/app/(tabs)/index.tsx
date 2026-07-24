import { useEffect } from 'react';
import { ScrollView, View, Text, Pressable, ActivityIndicator, useColorScheme } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { useDashboardStore } from '@/stores/dashboard-store';
import { useSettingsStore } from '@/stores/settings-store';
import { useAuthStore } from '@/stores/auth-store';
import { router } from 'expo-router';
import { NotificationIcon, NotificationModal } from '@/components/notification-modal';
import { UserAvatar } from '@/components/user-avatar';
import { VaultMonogram } from '@/components/vault-monogram';
import { FlatCard } from '@/components/flat-card';
import { ListRow } from '@/components/list-row';
import { formatCurrency, convertAmount } from '@/lib/format-currency';
import { useSheet } from './_layout';
import { useNotificationStore } from '@/stores/notification-store';

function getGreeting(name?: string) {
  const hour = new Date().getHours();
  const period = hour < 12 ? 'morning' : hour < 18 ? 'afternoon' : 'evening';
  return { period, text: `Good ${period}${name ? `, ${name.split(' ')[0]}` : ''}` };
}

export default function IndividualDashboard() {
  const summary = useDashboardStore((s) => s.summary);
  const isLoading = useDashboardStore((s) => s.isLoading);
  const loadSummary = useDashboardStore((s) => s.loadSummary);
  const user = useAuthStore((s) => s.user);
  const { currency, loaded: settingsLoaded, loadSettings } = useSettingsStore();
  const { showSheet } = useSheet();
  const { count: notifCount, open: openNotifications, visible: notifVisible, close: closeNotifications } = useNotificationStore();
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';

  useEffect(() => {
    loadSummary();
    if (!settingsLoaded) loadSettings();
  }, [loadSummary, loadSettings, settingsLoaded]);

  const data = summary || {
    total_net_worth: 0,
    net_worth_change: 0,
    net_worth_change_pct: 0,
    monthly_spending: 0,
    spending_limit: 0,
    recent_transactions: [],
  } as any;

  if (isLoading && !summary) {
    return (
      <View className="flex-1 items-center justify-center" style={{ backgroundColor: isDark ? '#08142E' : '#F7F9FC' }}>
        <ActivityIndicator size="large" color="#08142E" />
      </View>
    );
  }

  const userName = user?.user_metadata?.full_name?.split(' ')[0] || '';
  const greeting = getGreeting(user?.user_metadata?.full_name);

  return (
    <View className="flex-1" style={{ backgroundColor: isDark ? '#08142E' : '#F7F9FC' }}>
      <View className="px-margin-mobile pt-14 pb-3" style={{ backgroundColor: isDark ? '#08142E' : '#F7F9FC' }}>
        <View className="flex-row items-center justify-between">
          <View className="flex-row items-center gap-3">
            <VaultMonogram size={34} flat />
            <View>
              <Text className="font-body-semibold text-body-md" style={{ color: isDark ? '#FFFFFF' : '#1A1A1A' }}>
                {greeting.text}
              </Text>
            </View>
          </View>
          <View className="flex-row items-center gap-3">
            {false && (
              <Pressable className="flex-row items-center gap-1.5 py-1.5 px-3 active:scale-95" style={{ backgroundColor: 'rgba(8,20,46,0.08)', borderWidth: 1.5, borderColor: '#08142E', borderRadius: 9999 }}>
                <Text className="font-body-semibold" style={{ fontSize: 12, color: '#08142E' }}>Earn MUR 100</Text>
                <MaterialIcons name="chevron-right" size={14} color="#08142E" />
              </Pressable>
            )}
            <NotificationIcon onPress={openNotifications} count={notifCount} />
            <Pressable onPress={() => router.push('/(tabs)/profile')} className="active:scale-90">
              <UserAvatar size={36} />
            </Pressable>
          </View>
        </View>
      </View>

      <ScrollView className="flex-1 px-margin-mobile" contentContainerStyle={{ paddingBottom: 120 }} showsVerticalScrollIndicator={false}>
        {/* Headline */}
        <Text className="font-display-bold" style={{ fontSize: 22, color: isDark ? '#FFFFFF' : '#1A1A1A', marginTop: 8 }}>
          {userName ? `Welcome to ${userName}` : 'Welcome'}
        </Text>

        {/* Action pill row */}
        <View className="flex-row mt-4" style={{ gap: 10 }}>
          <Pressable
            onPress={() => router.push('/(tabs)/pay')}
            className="flex-1 py-3 items-center active:scale-[0.98]"
            style={{ backgroundColor: 'rgba(8,20,46,0.08)', borderWidth: 1.5, borderColor: '#08142E', borderRadius: 9999 }}
          >
            <Text className="font-body-semibold" style={{ fontSize: 15, color: '#08142E' }}>Send</Text>
          </Pressable>
          <Pressable
            onPress={() => router.push('/(tabs)/pay')}
            className="flex-1 py-3 items-center active:scale-[0.98]"
            style={{ backgroundColor: isDark ? 'rgba(255,255,255,0.08)' : '#EEF0F5', borderRadius: 9999 }}
          >
            <Text className="font-body-semibold" style={{ fontSize: 15, color: isDark ? '#FFFFFF' : '#1A1A1A' }}>Add money</Text>
          </Pressable>
          <Pressable
            onPress={() => router.push('/(tabs)/pay')}
            className="flex-1 py-3 items-center active:scale-[0.98]"
            style={{ backgroundColor: isDark ? 'rgba(255,255,255,0.08)' : '#EEF0F5', borderRadius: 9999 }}
          >
            <Text className="font-body-semibold" style={{ fontSize: 15, color: isDark ? '#FFFFFF' : '#1A1A1A' }}>Request</Text>
          </Pressable>
        </View>

        {/* Balance card */}
        <FlatCard className="p-5 mt-4">
          <View className="flex-row items-center justify-between">
            <View className="flex-row items-center gap-2">
              <View className="w-6 h-6 rounded-full items-center justify-center" style={{ backgroundColor: '#08142E' }}>
                <Text className="font-body-bold" style={{ fontSize: 10, color: '#08142E' }}>{currency.code.slice(0, 2)}</Text>
              </View>
              <Text className="font-body-semibold text-caption" style={{ color: isDark ? 'rgba(255,255,255,0.7)' : '#6B6F76' }}>
                {currency.code} • {currency.symbol}
              </Text>
            </View>
          </View>
          <Text className="font-body text-caption mt-3" style={{ color: isDark ? 'rgba(255,255,255,0.4)' : '#6B6F76' }}>
            {currency.code} {currency.symbol}0.00
          </Text>
          <Text className="font-display-bold" style={{ fontSize: 34, lineHeight: 38, color: '#08142E', marginTop: 4 }}>
            {formatCurrency(convertAmount(data.total_net_worth, currency.rate), currency.code)}
          </Text>
          {data.net_worth_change > 0 && (
            <View className="flex-row items-center mt-2">
              <MaterialIcons name="arrow-upward" size={14} color="#2E7D5B" />
              <Text className="font-body-medium" style={{ fontSize: 13, color: '#2E7D5B', marginLeft: 4 }}>
                +{data.net_worth_change_pct}% this month
              </Text>
            </View>
          )}
        </FlatCard>

        {/* Transactions section */}
        <View className="mt-6">
          <View className="flex-row items-center justify-between mb-1">
            <Text className="font-body-bold" style={{ fontSize: 17, color: isDark ? '#FFFFFF' : '#1A1A1A' }}>
              Transactions
            </Text>
            <Pressable onPress={() => showSheet({ title: 'All Activity', children: activitySheetContent() })}>
              <Text className="font-body-semibold" style={{ fontSize: 14, color: '#08142E' }}>See all</Text>
            </Pressable>
          </View>
          <FlatCard className="px-4">
            {data.recent_transactions.length > 0 ? (
              data.recent_transactions.slice(0, 3).map((tx: any, i: number) => (
                <ListRow
                  key={tx.id || i}
                  icon={tx.type === 'income' ? 'arrow-downward' : 'arrow-upward'}
                  iconColor={tx.type === 'income' ? '#2E7D5B' : '#1A1A1A'}
                  label={tx.description}
                  secondary={tx.merchant || tx.category}
                  amount={formatCurrency(convertAmount(tx.amount, currency.rate), currency.code)}
                  amountColor={tx.type === 'income' ? '#2E7D5B' : (isDark ? '#FFFFFF' : '#1A1A1A')}
                  showPlus={tx.type === 'income'}
                />
              ))
            ) : (
              <View className="py-8 items-center">
                <Text className="font-body text-caption" style={{ color: isDark ? 'rgba(255,255,255,0.4)' : '#6B6F76' }}>
                  No recent activity
                </Text>
              </View>
            )}
          </FlatCard>
        </View>
      </ScrollView>

      <NotificationModal visible={notifVisible} onClose={closeNotifications} />
    </View>
  );

  function activitySheetContent() {
    return data.recent_transactions.length > 0 ? data.recent_transactions.map((tx: any, i: number) => (
      <ListRow
        key={tx.id || i}
        icon={tx.type === 'income' ? 'arrow-downward' : 'arrow-upward'}
        iconColor={tx.type === 'income' ? '#2E7D5B' : '#1A1A1A'}
        label={tx.description}
        secondary={tx.merchant || tx.category}
        amount={formatCurrency(convertAmount(tx.amount, currency.rate), currency.code)}
        amountColor={tx.type === 'income' ? '#2E7D5B' : (isDark ? '#FFFFFF' : '#1A1A1A')}
        showPlus={tx.type === 'income'}
      />
    )) : (
      <View className="py-8 items-center">
        <Text className="font-body text-caption" style={{ color: isDark ? 'rgba(255,255,255,0.4)' : '#6B6F76' }}>
          No recent activity
        </Text>
      </View>
    );
  }
}
