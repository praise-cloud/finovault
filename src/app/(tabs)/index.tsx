import { useEffect, useState } from 'react';
import { ScrollView, View, Text, Pressable, ActivityIndicator, useColorScheme } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { useDashboardStore } from '@/src/stores/dashboard-store';
import { useSettingsStore } from '@/src/stores/settings-store';
import { useAuthStore } from '@/src/stores/auth-store';
import { router } from 'expo-router';
import { NotificationIcon, NotificationModal } from '@/src/components/notification-modal';
import { UserAvatar } from '@/src/components/user-avatar';
import { FlatCard } from '@/src/components/flat-card';
import { ListRow } from '@/src/components/list-row';
import { formatCurrency, convertAmount } from '@/src/lib/format-currency';
import { useSheet } from './_layout';
import { useNotificationStore } from '@/src/stores/notification-store';

const BLUE = '#123B91';

function SegmentedControl({
  options,
  value,
  onChange,
}: {
  options: string[];
  value: string;
  onChange: (v: string) => void;
}) {
  return (
    <View style={{ flexDirection: 'row', backgroundColor: '#EEF0F5', borderRadius: 9999, padding: 3 }}>
      {options.map((opt) => {
        const active = opt === value;
        return (
          <Pressable
            key={opt}
            onPress={() => onChange(opt)}
            style={{
              paddingHorizontal: 18,
              paddingVertical: 8,
              borderRadius: 9999,
              backgroundColor: active ? BLUE : 'transparent',
            }}
          >
            <Text
              style={{
                fontFamily: 'Montserrat_600SemiBold',
                fontSize: 13,
                color: active ? '#FFFFFF' : '#4B5163',
              }}
            >
              {opt}
            </Text>
          </Pressable>
        );
      })}
    </View>
  );
}

function ProgressBar({ progress, trackColor, fillColor }: { progress: number; trackColor: string; fillColor: string }) {
  return (
    <View style={{ height: 4, borderRadius: 2, backgroundColor: trackColor, overflow: 'hidden' }}>
      <View style={{ height: '100%', width: `${Math.min(100, Math.max(0, progress))}%`, backgroundColor: fillColor, borderRadius: 2 }} />
    </View>
  );
}

const ASSET_ICONS: Record<string, keyof typeof MaterialIcons.glyphMap> = {
  'real-estate': 'apartment',
  'liquid-cash': 'account-balance',
  default: 'account-balance-wallet',
};

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
  const [view, setView] = useState<'Budgets' | 'Accounts'>('Budgets');

  useEffect(() => {
    loadSummary();
    if (!settingsLoaded) loadSettings();
  }, [loadSummary, loadSettings, settingsLoaded]);

  const data = summary || {
    total_net_worth: 0,
    net_worth_change: 0,
    net_worth_change_pct: 0,
    estimated_tax_liability: 0,
    tax_period_label: '',
    withheld_amount: 0,
    goal_pct: 0,
    recent_transactions: [],
    asset_allocation: [],
  } as any;

  if (isLoading && !summary) {
    return (
      <View className="flex-1 items-center justify-center" style={{ backgroundColor: isDark ? '#0D1117' : '#FFFFFF' }}>
        <ActivityIndicator size="large" color={BLUE} />
      </View>
    );
  }

  const userName = user?.user_metadata?.full_name?.split(' ')[0] || '';

  return (
    <View className="flex-1" style={{ backgroundColor: isDark ? '#0D1117' : '#FFFFFF' }}>
      <View className="px-margin-mobile pt-14 pb-3" style={{ backgroundColor: isDark ? '#0D1117' : '#FFFFFF' }}>
        <View className="flex-row items-center justify-between">
          <View>
            <Text className="font-body" style={{ fontSize: 13, color: isDark ? 'rgba(255,255,255,0.6)' : '#6B6F76' }}>
              Welcome back
            </Text>
            <Text className="font-display-bold" style={{ fontSize: 22, color: isDark ? '#FFFFFF' : '#1A1A1A', marginTop: 2 }}>
              {userName || 'there'}
            </Text>
          </View>
          <View className="flex-row items-center gap-3">
            <NotificationIcon onPress={openNotifications} count={notifCount} />
            <Pressable onPress={() => router.push('/(tabs)/profile')} className="active:scale-90">
              <UserAvatar size={36} />
            </Pressable>
          </View>
        </View>
      </View>

      <ScrollView className="flex-1 px-margin-mobile" contentContainerStyle={{ paddingBottom: 120 }} showsVerticalScrollIndicator={false}>
        {/* Segment control + net worth */}
        <View className="flex-row items-center justify-between mt-2">
          <SegmentedControl options={['Budgets', 'Accounts']} value={view} onChange={(v) => setView(v as any)} />
          <View style={{ alignItems: 'flex-end' }}>
            <Text className="font-body" style={{ fontSize: 11, color: isDark ? 'rgba(255,255,255,0.5)' : '#8A8E98' }}>
              Net worth
            </Text>
            <Text className="font-body-semibold" style={{ fontSize: 13, color: isDark ? '#FFFFFF' : '#1A1A1A' }}>
              {formatCurrency(convertAmount(data.total_net_worth, currency.rate), currency.code)}
            </Text>
          </View>
        </View>

        {/* Balance / tax liability card */}
        <View style={{ backgroundColor: BLUE, borderRadius: 20, padding: 20, marginTop: 16 }}>
          <View className="flex-row items-center justify-between">
            <View style={{ backgroundColor: 'rgba(46,125,91,0.9)', borderRadius: 9999, paddingHorizontal: 12, paddingVertical: 5 }}>
              <Text className="font-body-semibold" style={{ fontSize: 11, color: '#FFFFFF' }}>
                Estimated Tax Liability
              </Text>
            </View>
            <Pressable hitSlop={10}>
              <MaterialIcons name="more-horiz" size={20} color="rgba(255,255,255,0.7)" />
            </Pressable>
          </View>

          <Text className="font-display-bold" style={{ fontSize: 34, lineHeight: 40, color: '#FFFFFF', marginTop: 14 }}>
            {formatCurrency(convertAmount(data.estimated_tax_liability, currency.rate), currency.code)}
          </Text>
          <Text className="font-body" style={{ fontSize: 13, color: 'rgba(255,255,255,0.7)', marginTop: 2 }}>
            {data.tax_period_label || 'Recommended for this quarter'}
          </Text>

          <View style={{ marginTop: 16 }}>
            <ProgressBar progress={data.goal_pct} trackColor="rgba(255,255,255,0.2)" fillColor="#FFFFFF" />
          </View>

          <View className="flex-row items-center justify-between" style={{ marginTop: 10 }}>
            <Text className="font-body" style={{ fontSize: 12, color: 'rgba(255,255,255,0.75)' }}>
              Withheld: {formatCurrency(convertAmount(data.withheld_amount, currency.rate), currency.code)}
            </Text>
            <Text className="font-body" style={{ fontSize: 12, color: 'rgba(255,255,255,0.75)' }}>
              Goal: {data.goal_pct}%
            </Text>
          </View>
        </View>

        {/* Transactions */}
        <View className="mt-6">
          <View className="flex-row items-center justify-between mb-1">
            <Text className="font-body-bold" style={{ fontSize: 17, color: isDark ? '#FFFFFF' : '#1A1A1A' }}>
              Transactions
            </Text>
            <Pressable onPress={() => showSheet({ title: 'All Activity', children: activitySheetContent() })}>
              <Text className="font-body-semibold" style={{ fontSize: 14, color: BLUE }}>See all</Text>
            </Pressable>
          </View>
          <FlatCard className="px-4">
            {data.recent_transactions.length > 0 ? (
              data.recent_transactions.slice(0, 1).map((tx: any, i: number) => (
                <ListRow
                  key={tx.id || i}
                  icon={tx.type === 'income' ? 'arrow-downward' : 'arrow-upward'}
                  iconColor={tx.type === 'income' ? '#2E7D5B' : '#1A1A1A'}
                  label={tx.description}
                  secondary={`Added: ${tx.date_label || tx.merchant || tx.category}`}
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

        {/* Asset allocation */}
        <View className="mt-6">
          <View className="flex-row items-center justify-between mb-1">
            <Text className="font-body-bold" style={{ fontSize: 17, color: isDark ? '#FFFFFF' : '#1A1A1A' }}>
              Asset Allocation
            </Text>
            <Pressable onPress={() => router.push('/(tabs)/vault')}>
              <Text className="font-body-semibold" style={{ fontSize: 14, color: BLUE }}>See all</Text>
            </Pressable>
          </View>
          <FlatCard className="px-4">
            {data.asset_allocation.length > 0 ? (
              data.asset_allocation.map((asset: any, i: number) => (
                <ListRow
                  key={asset.id || i}
                  icon={ASSET_ICONS[asset.category_key] || ASSET_ICONS.default}
                  iconColor={BLUE}
                  label={asset.label}
                  secondary={`${asset.portfolio_pct}% of portfolio`}
                  amount={formatCurrency(convertAmount(asset.value, currency.rate), currency.code)}
                  amountColor={isDark ? '#FFFFFF' : '#1A1A1A'}
                />
              ))
            ) : (
              <View className="py-8 items-center">
                <Text className="font-body text-caption" style={{ color: isDark ? 'rgba(255,255,255,0.4)' : '#6B6F76' }}>
                  No assets linked yet
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
        secondary={`Added: ${tx.date_label || tx.merchant || tx.category}`}
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