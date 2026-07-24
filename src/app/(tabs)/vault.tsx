import { useEffect } from 'react';
import { ScrollView, View, Text, Pressable, ActivityIndicator, useColorScheme } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { useDashboardStore } from '@/stores/dashboard-store';
import { useSettingsStore } from '@/stores/settings-store';
import { router } from 'expo-router';
import { VaultMonogram } from '@/components/vault-monogram';
import { FlatCard } from '@/components/flat-card';
import { formatCurrency, convertAmount } from '@/lib/format-currency';

const HOLDING_COLORS = ['#08142E', '#0A1F5C', '#2E7D5B', '#8C3A3A', '#C99A2E'];

export default function VaultScreen() {
  const summary = useDashboardStore((s) => s.summary);
  const isLoading = useDashboardStore((s) => s.isLoading);
  const loadSummary = useDashboardStore((s) => s.loadSummary);
  const { currency, loaded: settingsLoaded, loadSettings } = useSettingsStore();
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';

  useEffect(() => {
    loadSummary();
    if (!settingsLoaded) loadSettings();
  }, [loadSummary, settingsLoaded]);

  const data = summary || {
    total_net_worth: 0,
    asset_allocations: [],
  } as any;

  if (isLoading && !summary) {
    return (
      <View className="flex-1 items-center justify-center" style={{ backgroundColor: isDark ? '#08142E' : '#F7F9FC' }}>
        <ActivityIndicator size="large" color="#08142E" />
      </View>
    );
  }

  return (
    <View className="flex-1" style={{ backgroundColor: isDark ? '#08142E' : '#F7F9FC' }}>
      <View className="px-margin-mobile pt-14 pb-3" style={{ backgroundColor: isDark ? '#08142E' : '#F7F9FC' }}>
        <View className="flex-row items-center gap-3">
          <VaultMonogram size={36} />
          <Text className={`font-body-semibold text-headline-md ${isDark ? 'text-white' : 'text-primary'}`}>Vault</Text>
        </View>
      </View>

      <ScrollView className="flex-1 px-margin-mobile" contentContainerStyle={{ paddingBottom: 120 }} showsVerticalScrollIndicator={false}>
        <FlatCard className="p-5 mt-4">
          <Text className="font-body-medium text-caption mb-1" style={{ color: isDark ? 'rgba(255,255,255,0.6)' : '#6B6F76' }}>
            Total Portfolio Value
          </Text>
          <Text className="font-display-bold" style={{ fontSize: 34, color: '#08142E' }}>
            {formatCurrency(convertAmount(data.total_net_worth, currency.rate), currency.code)}
          </Text>
          <View className="flex-row items-center mt-1">
            <MaterialIcons name="arrow-upward" size={14} color="#2E7D5B" />
            <Text className="font-body-medium" style={{ fontSize: 13, color: '#2E7D5B', marginLeft: 4 }}>+2.4% today</Text>
          </View>
        </FlatCard>

        <Text className="font-body-bold" style={{ fontSize: 17, color: isDark ? '#FFFFFF' : '#1A1A1A', marginTop: 20, marginBottom: 12 }}>
          Holdings
        </Text>

        {(data.asset_allocations?.length ?? 0) > 0 ? (
          data.asset_allocations.map((item: any, i: number) => (
            <FlatCard key={item.id || i} className="p-4 mb-2" onPress={() => router.push('/(tabs)/wealth-growth')}>
              <View className="flex-row items-center gap-3">
                <View
                  className="w-10 h-10 rounded-full items-center justify-center"
                  style={{ backgroundColor: `${HOLDING_COLORS[i % HOLDING_COLORS.length]}20` }}
                >
                  <MaterialIcons name={item.icon || 'account-balance'} size={20} color={HOLDING_COLORS[i % HOLDING_COLORS.length]} />
                </View>
                <View className="flex-1">
                  <View className="flex-row justify-between items-center">
                    <Text className="font-body-medium" style={{ fontSize: 15, color: isDark ? '#FFFFFF' : '#1A1A1A' }}>
                      {item.category}
                    </Text>
                    <Text className="font-body-semibold" style={{ fontSize: 15, color: isDark ? '#FFFFFF' : '#1A1A1A' }}>
                      {formatCurrency(convertAmount(item.value, currency.rate), currency.code)}
                    </Text>
                  </View>
                  <View className="flex-row items-center gap-2 mt-1.5">
                    <View className="flex-1 rounded-full h-1.5" style={{ backgroundColor: isDark ? 'rgba(255,255,255,0.1)' : '#e0e3e6' }}>
                      <View
                        className="h-full rounded-full"
                        style={{ width: `${item.percentage}%`, backgroundColor: HOLDING_COLORS[i % HOLDING_COLORS.length] }}
                      />
                    </View>
                    <Text className="font-body text-caption" style={{ color: isDark ? 'rgba(255,255,255,0.4)' : '#6B6F76' }}>
                      {item.percentage}%
                    </Text>
                  </View>
                </View>
                <MaterialIcons name="chevron-right" size={20} color={isDark ? 'rgba(255,255,255,0.2)' : '#c4c6ce'} />
              </View>
            </FlatCard>
          ))
        ) : (
          <FlatCard className="p-8 items-center">
            <Text className="font-body text-body-md text-center" style={{ color: isDark ? 'rgba(255,255,255,0.5)' : '#6B6F76' }}>
              No holdings yet. Link a bank account to get started.
            </Text>
            <Pressable
              onPress={() => router.push('/(tabs)/linked-accounts')}
              className="mt-5 py-3 px-6 active:scale-95"
              style={{ backgroundColor: 'rgba(8,20,46,0.08)', borderWidth: 1.5, borderColor: '#08142E', borderRadius: 9999 }}
            >
              <Text className="font-body-semibold" style={{ fontSize: 15, color: '#08142E' }}>Link Bank Account</Text>
            </Pressable>
          </FlatCard>
        )}
      </ScrollView>
    </View>
  );
}
