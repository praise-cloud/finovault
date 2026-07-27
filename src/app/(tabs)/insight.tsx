import { useEffect, useState } from 'react';
import { ScrollView, View, Text, Pressable, ActivityIndicator, useColorScheme } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { router } from 'expo-router';
import { useDashboardStore } from '@/src/stores/dashboard-store';
import { useSettingsStore } from '@/src/stores/settings-store';
import { NotificationIcon, NotificationModal } from '@/src/components/notification-modal';
import { UserAvatar } from '@/src/components/user-avatar';
import { Logo } from '@/src/components/logo';
import { FlatCard } from '@/src/components/flat-card';
import { ListRow } from '@/src/components/list-row';
import { formatCurrency, convertAmount } from '@/src/lib/format-currency';
import { useNotificationStore } from '@/src/stores/notification-store';

const BLUE = '#123B91';
const OUTCOME_RED = '#C0392B';
const OUTCOME_RED_LIGHT = '#E8746A';

function SegmentedControl({
  options,
  value,
  onChange,
  activeColor,
  isDark,
}: {
  options: string[];
  value: string;
  onChange: (v: string) => void;
  activeColor: string;
  isDark?: boolean;
}) {
  return (
    <View style={{ flexDirection: 'row', backgroundColor: isDark ? 'rgba(255,255,255,0.08)' : '#EEF0F5', borderRadius: 9999, padding: 3, alignSelf: 'flex-start' }}>
      {options.map((opt) => {
        const active = opt === value;
        return (
          <Pressable
            key={opt}
            onPress={() => onChange(opt)}
            accessibilityRole="button"
            style={{
              paddingHorizontal: 20,
              paddingVertical: 9,
              borderRadius: 9999,
              backgroundColor: active ? activeColor : 'transparent',
            }}
          >
            <Text
              style={{
                fontFamily: 'Montserrat_600SemiBold',
                fontSize: 13,
                color: active ? '#FFFFFF' : (isDark ? 'rgba(255,255,255,0.5)' : '#4B5163'),
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

export default function InsightScreen() {
  const summary = useDashboardStore((s) => s.summary);
  const isLoading = useDashboardStore((s) => s.isLoading);
  const loadSummary = useDashboardStore((s) => s.loadSummary);
  const { currency, loaded: settingsLoaded, loadSettings } = useSettingsStore();
  const { count: notifCount, open: openNotifications, visible: notifVisible, close: closeNotifications } = useNotificationStore();
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';
  const [mode, setMode] = useState<'Income' | 'Outcome'>('Income');

  useEffect(() => {
    loadSummary();
    if (!settingsLoaded) loadSettings();
  }, [loadSummary, loadSettings, settingsLoaded]);

  const data = summary || {
    insight_amount: 0,
    insight_period_label: '',
    withheld_amount: 0,
    goal_pct: 0,
    income_transactions: [],
    outcome_transactions: [],
  } as any;

  if (isLoading && !summary) {
    return (
      <View className="flex-1 items-center justify-center" style={{ backgroundColor: isDark ? '#08142E' : '#FFFFFF' }}>
        <ActivityIndicator size="large" color={isDark ? '#D4AF37' : BLUE} />
      </View>
    );
  }

  const isIncome = mode === 'Income';
  const cardColor = isIncome ? (isDark ? '#D4AF37' : BLUE) : OUTCOME_RED;
  const rowIconColor = isIncome ? (isDark ? '#D4AF37' : BLUE) : OUTCOME_RED;
  const rowIconBg = isIncome ? 'rgba(18,59,145,0.1)' : 'rgba(192,57,43,0.1)';
  const transactions = isIncome ? data.income_transactions : data.outcome_transactions;

  return (
    <View className="flex-1" style={{ backgroundColor: isDark ? '#08142E' : '#FFFFFF' }}>
      <View className="px-margin-mobile pt-14 pb-3" style={{ backgroundColor: isDark ? '#08142E' : '#FFFFFF' }}>
        <View className="flex-row items-center justify-between">
          <View className="flex-row items-center gap-2">
            <Logo width={20} height={18} color={isDark ? '#FFFFFF' : BLUE} />
            <Text className="font-display-bold" style={{ fontSize: 18, color: isDark ? '#FFFFFF' : '#1A1A1A' }}>
              Statics
            </Text>
          </View>
          <View className="flex-row items-center gap-3">
            <NotificationIcon onPress={openNotifications} count={notifCount} />
            <Pressable onPress={() => router.push('/(tabs)/profile')} accessibilityLabel="Profile" accessibilityRole="button" className="active:scale-90">
              <UserAvatar size={32} />
            </Pressable>
          </View>
        </View>
      </View>

      <ScrollView className="flex-1 px-margin-mobile" contentContainerStyle={{ paddingBottom: 120 }} showsVerticalScrollIndicator={false}>
        <View className="mt-2">
          <SegmentedControl options={['Income', 'Outcome']} value={mode} onChange={(v) => setMode(v as any)} activeColor={cardColor} isDark={isDark} />
        </View>

        {/* Amount card — recolors between blue (Income) and red (Outcome) */}
        <View style={{ backgroundColor: cardColor, borderRadius: 20, padding: 20, marginTop: 16 }}>
          <Text className="font-display-bold" style={{ fontSize: 34, lineHeight: 40, color: '#FFFFFF' }}>
            {formatCurrency(convertAmount(data.insight_amount, currency.rate), currency.code)}
          </Text>
          <Text className="font-body" style={{ fontSize: 13, color: 'rgba(255,255,255,0.75)', marginTop: 2 }}>
            {data.insight_period_label || 'Recommended for this quarter'}
          </Text>

          <View style={{ marginTop: 16 }}>
            <ProgressBar progress={data.goal_pct} trackColor="rgba(255,255,255,0.25)" fillColor="#FFFFFF" />
          </View>

          <View className="flex-row items-center justify-between" style={{ marginTop: 10 }}>
            <Text className="font-body" style={{ fontSize: 12, color: 'rgba(255,255,255,0.8)' }}>
              Withheld: {formatCurrency(convertAmount(data.withheld_amount, currency.rate), currency.code)}
            </Text>
            <Text className="font-body" style={{ fontSize: 12, color: 'rgba(255,255,255,0.8)' }}>
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
            <Pressable>
              <Text className="font-body-semibold" style={{ fontSize: 14, color: cardColor }}>See all</Text>
            </Pressable>
          </View>
          <FlatCard className="px-4">
            {transactions && transactions.length > 0 ? (
              transactions.map((tx: any, i: number) => (
                <ListRow
                  key={tx.id || i}
                  icon={isIncome ? 'call-received' : 'call-made'}
                  iconColor={rowIconColor}
                  iconBackground={rowIconBg}
                  label={tx.description}
                  secondary={`Added: ${tx.date_label || tx.merchant || tx.category}`}
                  amount={formatCurrency(convertAmount(tx.amount, currency.rate), currency.code)}
                  amountColor={isIncome ? (isDark ? '#FFFFFF' : '#1A1A1A') : OUTCOME_RED}
                />
              ))
            ) : (
              <View className="py-8 items-center">
                <Text className="font-body text-caption" style={{ color: isDark ? 'rgba(255,255,255,0.4)' : '#6B6F76' }}>
                  No {mode.toLowerCase()} activity yet
                </Text>
              </View>
            )}
          </FlatCard>
        </View>
      </ScrollView>

      <NotificationModal visible={notifVisible} onClose={closeNotifications} />
    </View>
  );
}
