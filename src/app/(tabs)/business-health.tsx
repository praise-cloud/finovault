import { useEffect, useState } from 'react';
import { ScrollView, View, Text, Pressable, ActivityIndicator } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { router } from 'expo-router';
import { getBusinessHealth } from '@/lib/api/services/business';

export default function BusinessHealth() {
  const [loading, setLoading] = useState(true);
  const [health, setHealth] = useState<any>(null);

  useEffect(() => {
    getBusinessHealth()
      .then(setHealth)
      .catch(() => {})
      .finally(() => setLoading(false));
  }, []);

  if (loading) {
    return (
      <View className="flex-1 bg-surface-bright items-center justify-center">
        <ActivityIndicator size="large" color="#08142E" />
      </View>
    );
  }

  const metrics = [
    { label: 'Cash Flow', value: health?.cash_flow, icon: 'account-balance', color: '#08142E' },
    { label: 'Profit Margin', value: health?.profit_margin, icon: 'trending-up', color: '#1b7f63' },
    { label: 'Revenue Growth', value: health?.revenue_growth, icon: 'bar-chart', color: '#08142E' },
    { label: 'Expense Ratio', value: health?.expense_ratio, icon: 'receipt', color: '#9f4e3c' },
  ];

  return (
    <View className="flex-1 bg-surface-bright">
      <View className="pt-14 pb-3 px-margin-mobile bg-surface-bright" style={{ boxShadow: '0 4px 4px rgba(0,0,0,0.04)', elevation: 4 }}>
        <View className="flex-row items-center justify-between">
          <Pressable onPress={() => router.back()} className="w-10 h-10 rounded-full bg-surface-container items-center justify-center active:scale-90">
            <MaterialIcons name="arrow-back" size={20} color="#181c1e" />
          </Pressable>
          <Text className="font-body-bold text-[#1A1A1A] font-bold" style={{ fontSize: 20 }}>Business Health</Text>
          <View className="w-10" />
        </View>
      </View>

      <ScrollView className="flex-1 px-margin-mobile" contentContainerStyle={{ paddingBottom: 120 }}>
        <View className="mt-6 mb-8">
          <Text className="font-body-bold text-[#1A1A1A] mb-2" style={{ fontSize: 28 }}>Health Overview</Text>
          <Text className="text-[#6B6F76]" style={{ fontSize: 16 }}>Real-time metrics and health indicators for your business.</Text>
        </View>

        <View className="flex-row flex-wrap gap-4 mb-8">
          {metrics.map((metric, i) => (
            <View key={i} className="flex-1 min-w-[45%] bg-[#EEF0F5] rounded-2xl p-5" style={{ boxShadow: '0 2px 4px rgba(0,0,0,0.06)', elevation: 2 }}>
              <View className="flex-row items-center gap-2 mb-4">
                <View className="w-10 h-10 rounded-full items-center justify-center" style={{ backgroundColor: metric.color + '20' }}>
                  <MaterialIcons name={metric.icon as any} size={20} color={metric.color} />
                </View>
                <Text className="font-body-semibold text-[#6B6F76] flex-1" style={{ fontSize: 14 }}>{metric.label}</Text>
              </View>
              <Text className="font-body-bold text-[#1A1A1A] font-bold" style={{ fontSize: 36 }}>
                {typeof metric.value === 'number' ? `${metric.value.toFixed(1)}%` : '-'}
              </Text>
            </View>
          ))}
        </View>

        {health?.score !== undefined && (
          <View className="bg-[#EEF0F5] rounded-2xl p-6 mb-6" style={{ boxShadow: '0 2px 4px rgba(0,0,0,0.06)', elevation: 2 }}>
            <Text className="font-body-bold text-[#1A1A1A] font-bold mb-2" style={{ fontSize: 20 }}>Overall Health Score</Text>
            <View className="flex-row items-end gap-3">
              <Text className="font-body-bold font-bold" style={{ fontSize: 40, color: health.score >= 70 ? '#08142E' : health.score >= 40 ? '#b8860b' : '#9f4e3c' }}>
                {health.score}
              </Text>
              <Text className="font-body-semibold text-[#6B6F76] mb-2" style={{ fontSize: 14 }}>/ 100</Text>
            </View>
            <View className="mt-3 h-3 bg-outline-variant/30 rounded-full overflow-hidden">
              <View
                className="h-full rounded-full"
                style={{
                  width: `${health.score}%`,
                  backgroundColor: health.score >= 70 ? '#08142E' : health.score >= 40 ? '#b8860b' : '#9f4e3c',
                }}
              />
            </View>
          </View>
        )}

        {health?.insights?.length > 0 && (
          <View className="gap-3">
            <Text className="font-body-bold text-[#1A1A1A] font-bold mb-2" style={{ fontSize: 20 }}>Insights</Text>
            {health.insights.map((insight: string, i: number) => (
              <View key={i} className="bg-[#EEF0F5] rounded-2xl p-4 flex-row items-start gap-3" style={{ boxShadow: '0 2px 4px rgba(0,0,0,0.06)', elevation: 2 }}>
                <MaterialIcons name="lightbulb" size={20} color="#08142E" style={{ marginTop: 2 }} />
                <Text className="font-body-md text-on-surface flex-1" style={{ fontSize: 16 }}>{insight}</Text>
              </View>
            ))}
          </View>
        )}
      </ScrollView>
    </View>
  );
}
