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
        <ActivityIndicator size="large" color="#D4AF37" />
      </View>
    );
  }

  return (
    <View className="flex-1 bg-surface-bright">
      <View className="pt-14 pb-3 px-margin-mobile bg-surface-bright" style={{ elevation: 4, shadowColor: '#000', shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.04 }}>
        <View className="flex-row items-center justify-between">
          <Pressable onPress={() => router.back()} className="w-10 h-10 rounded-full bg-surface-container items-center justify-center active:scale-90">
            <MaterialIcons name="arrow-back" size={20} color="#181c1e" />
          </Pressable>
          <Text className="font-headline-md text-headline-md text-primary font-bold">Business Forecast</Text>
          <View className="w-10" />
        </View>
      </View>

      <ScrollView className="flex-1 px-margin-mobile" contentContainerStyle={{ paddingBottom: 120 }}>
        <View className="mt-6 mb-8">
          <Text className="font-headline-lg text-headline-lg text-primary mb-2">Revenue Forecast</Text>
          <Text className="font-body-md text-body-md text-on-surface-variant">Projected revenue and growth insights for the upcoming period.</Text>
        </View>

        {forecast?.summary && (
          <View className="bg-surface-container-low rounded-2xl p-6 mb-6" style={{ elevation: 2, shadowColor: '#000', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.06 }}>
            <View className="flex-row items-center gap-3 mb-4">
              <MaterialIcons name="insights" size={28} color="#D4AF37" />
              <Text className="font-headline-md text-headline-md text-primary font-bold">Summary</Text>
            </View>
            <Text className="font-body-md text-body-md text-on-surface">{forecast.summary}</Text>
          </View>
        )}

        {forecast?.projected_revenue !== undefined && (
          <View className="bg-surface-container-low rounded-2xl p-6 mb-6" style={{ elevation: 2, shadowColor: '#000', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.06 }}>
            <Text className="font-label-md text-label-md text-on-surface-variant mb-1">Projected Revenue</Text>
            <Text className="font-display-xl text-display-xl text-primary font-bold">
              ${forecast.projected_revenue.toLocaleString()}
            </Text>
            {forecast.growth_rate !== undefined && (
              <View className="flex-row items-center gap-1 mt-2">
                <MaterialIcons name={forecast.growth_rate >= 0 ? 'arrow-upward' : 'arrow-downward'} size={16} color={forecast.growth_rate >= 0 ? '#D4AF37' : '#9f4e3c'} />
                <Text className="font-label-md text-label-md" style={{ color: forecast.growth_rate >= 0 ? '#D4AF37' : '#9f4e3c' }}>
                  {forecast.growth_rate >= 0 ? '+' : ''}{forecast.growth_rate.toFixed(1)}% vs last period
                </Text>
              </View>
            )}
          </View>
        )}

        {forecast?.monthly_breakdown?.length > 0 && (
          <View className="mb-6">
            <Text className="font-headline-md text-headline-md text-primary font-bold mb-4">Monthly Breakdown</Text>
            <View className="gap-3">
              {forecast.monthly_breakdown.map((month: any, i: number) => (
                <View key={i} className="bg-surface-container-low rounded-2xl p-4" style={{ elevation: 2, shadowColor: '#000', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.06 }}>
                  <View className="flex-row items-center justify-between mb-2">
                    <Text className="font-label-md text-label-md text-primary font-bold">{month.month}</Text>
                    <Text className="font-label-md text-label-md font-bold" style={{ color: month.revenue >= 0 ? '#D4AF37' : '#9f4e3c' }}>
                      ${month.revenue.toLocaleString()}
                    </Text>
                  </View>
                  {month.confidence !== undefined && (
                    <Text className="text-caption text-on-surface-variant">Confidence: {month.confidence}%</Text>
                  )}
                </View>
              ))}
            </View>
          </View>
        )}

        {forecast?.recommendations?.length > 0 && (
          <View>
            <Text className="font-headline-md text-headline-md text-primary font-bold mb-4">Recommendations</Text>
            {forecast.recommendations.map((rec: string, i: number) => (
              <View key={i} className="bg-surface-container-low rounded-2xl p-4 flex-row items-start gap-3 mb-3" style={{ elevation: 2, shadowColor: '#000', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.06 }}>
                <MaterialIcons name="check-circle" size={20} color="#D4AF37" style={{ marginTop: 2 }} />
                <Text className="font-body-md text-body-md text-on-surface flex-1">{rec}</Text>
              </View>
            ))}
          </View>
        )}
      </ScrollView>
    </View>
  );
}
