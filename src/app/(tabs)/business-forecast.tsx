import { useEffect, useState } from 'react';
import { ScrollView, View, Text, Pressable, ActivityIndicator } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { router } from 'expo-router';
import { getBusinessForecast } from '@/lib/api/services/business';

export default function BusinessForecast() {
  const [loading, setLoading] = useState(true);
  const [forecast, setForecast] = useState<any>(null);

  useEffect(() => {
    getBusinessForecast()
      .then(setForecast)
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

  return (
    <View className="flex-1 bg-surface-bright">
      <View className="pt-14 pb-3 px-margin-mobile bg-surface-bright" style={{ boxShadow: '0 4px 4px rgba(0,0,0,0.04)', elevation: 4 }}>
        <View className="flex-row items-center justify-between">
          <Pressable onPress={() => router.back()} className="w-10 h-10 rounded-full bg-surface-container items-center justify-center active:scale-90">
            <MaterialIcons name="arrow-back" size={20} color="#181c1e" />
          </Pressable>
          <Text className="font-body-bold text-[#1A1A1A] font-bold" style={{ fontSize: 20 }}>Business Forecast</Text>
          <View className="w-10" />
        </View>
      </View>

      <ScrollView className="flex-1 px-margin-mobile" contentContainerStyle={{ paddingBottom: 120 }}>
        <View className="mt-6 mb-8">
          <Text className="font-body-bold text-[#1A1A1A] mb-2" style={{ fontSize: 28 }}>Revenue Forecast</Text>
          <Text className="text-[#6B6F76]" style={{ fontSize: 16 }}>Projected revenue and growth insights for the upcoming period.</Text>
        </View>

        {forecast?.summary && (
          <View className="bg-white rounded-2xl p-6 mb-6" style={{ boxShadow: '0 2px 4px rgba(0,0,0,0.06)', elevation: 2 }}>
            <View className="flex-row items-center gap-3 mb-4">
              <MaterialIcons name="insights" size={28} color="#08142E" />
              <Text className="font-body-bold text-[#1A1A1A] font-bold" style={{ fontSize: 20 }}>Summary</Text>
            </View>
            <Text className="font-body-md text-on-surface" style={{ fontSize: 16 }}>{forecast.summary}</Text>
          </View>
        )}

        {forecast?.projected_revenue !== undefined && (
          <View className="bg-white rounded-2xl p-6 mb-6" style={{ boxShadow: '0 2px 4px rgba(0,0,0,0.06)', elevation: 2 }}>
            <Text className="font-body-semibold text-[#6B6F76] mb-1" style={{ fontSize: 14 }}>Projected Revenue</Text>
            <Text className="font-body-bold text-[#1A1A1A] font-bold" style={{ fontSize: 40 }}>
              ${forecast.projected_revenue.toLocaleString()}
            </Text>
            {forecast.growth_rate !== undefined && (
              <View className="flex-row items-center gap-1 mt-2">
                <MaterialIcons name={forecast.growth_rate >= 0 ? 'arrow-upward' : 'arrow-downward'} size={16} color={forecast.growth_rate >= 0 ? '#08142E' : '#9f4e3c'} />
                <Text className="font-body-semibold" style={{ fontSize: 14, color: forecast.growth_rate >= 0 ? '#08142E' : '#9f4e3c' }}>
                  {forecast.growth_rate >= 0 ? '+' : ''}{forecast.growth_rate.toFixed(1)}% vs last period
                </Text>
              </View>
            )}
          </View>
        )}

        {forecast?.monthly_breakdown?.length > 0 && (
          <View className="mb-6">
            <Text className="font-body-bold text-[#1A1A1A] font-bold mb-4" style={{ fontSize: 20 }}>Monthly Breakdown</Text>
            <View className="gap-3">
              {forecast.monthly_breakdown.map((month: any, i: number) => (
                <View key={i} className="bg-white rounded-2xl p-4" style={{ boxShadow: '0 2px 4px rgba(0,0,0,0.06)', elevation: 2 }}>
                  <View className="flex-row items-center justify-between mb-2">
                    <Text className="font-body-semibold text-[#1A1A1A] font-bold" style={{ fontSize: 14 }}>{month.month}</Text>
                    <Text className="font-body-semibold font-bold" style={{ fontSize: 14, color: month.revenue >= 0 ? '#08142E' : '#9f4e3c' }}>
                      ${month.revenue.toLocaleString()}
                    </Text>
                  </View>
                  {month.confidence !== undefined && (
                    <Text className="font-body text-[#6B6F76]" style={{ fontSize: 12 }}>Confidence: {month.confidence}%</Text>
                  )}
                </View>
              ))}
            </View>
          </View>
        )}

        {forecast?.recommendations?.length > 0 && (
          <View>
            <Text className="font-body-bold text-[#1A1A1A] font-bold mb-4" style={{ fontSize: 20 }}>Recommendations</Text>
            {forecast.recommendations.map((rec: string, i: number) => (
              <View key={i} className="bg-white rounded-2xl p-4 flex-row items-start gap-3 mb-3" style={{ boxShadow: '0 2px 4px rgba(0,0,0,0.06)', elevation: 2 }}>
                <MaterialIcons name="check-circle" size={20} color="#08142E" style={{ marginTop: 2 }} />
                <Text className="font-body-md text-on-surface flex-1" style={{ fontSize: 16 }}>{rec}</Text>
              </View>
            ))}
          </View>
        )}
      </ScrollView>
    </View>
  );
}
