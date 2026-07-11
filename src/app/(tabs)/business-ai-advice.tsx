import { useEffect, useState } from 'react';
import { ScrollView, View, Text, Pressable, ActivityIndicator, RefreshControl } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { router } from 'expo-router';
import { getBusinessAiAdvice } from '@/lib/api/services/business';

export default function BusinessAiAdvice() {
  const [loading, setLoading] = useState(true);
  const [advice, setAdvice] = useState<any>(null);
  const [refreshing, setRefreshing] = useState(false);

  const loadAdvice = async () => {
    try {
      const data = await getBusinessAiAdvice();
      setAdvice(data);
    } catch {
      // silently fail
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  useEffect(() => {
    loadAdvice();
  }, []);

  const onRefresh = () => {
    setRefreshing(true);
    loadAdvice();
  };

  if (loading) {
    return (
      <View className="flex-1 bg-surface-bright items-center justify-center">
        <ActivityIndicator size="large" color="#006b5a" />
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
          <Text className="font-headline-md text-headline-md text-primary font-bold">AI Advice</Text>
          <Pressable onPress={onRefresh} className="w-10 h-10 rounded-full bg-surface-container items-center justify-center active:scale-90">
            <MaterialIcons name="refresh" size={20} color="#181c1e" />
          </Pressable>
        </View>
      </View>

      <ScrollView
        className="flex-1 px-margin-mobile"
        contentContainerStyle={{ paddingBottom: 120 }}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} tintColor="#006b5a" />}
      >
        <View className="mt-6 mb-8">
          <Text className="font-headline-lg text-headline-lg text-primary mb-2">AI-Powered Insights</Text>
          <Text className="font-body-md text-body-md text-on-surface-variant">Personalized recommendations based on your business data.</Text>
        </View>

        {advice?.summary && (
          <View className="bg-surface-container-low rounded-2xl p-6 mb-6" style={{ elevation: 2, shadowColor: '#000', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.06 }}>
            <View className="flex-row items-center gap-3 mb-4">
              <View className="w-10 h-10 rounded-full bg-secondary-container items-center justify-center">
                <MaterialIcons name="psychology" size={22} color="#00705e" />
              </View>
              <Text className="font-headline-md text-headline-md text-primary font-bold flex-1">Overview</Text>
            </View>
            <Text className="font-body-md text-body-md text-on-surface leading-6">{advice.summary}</Text>
          </View>
        )}

        {advice?.recommendations?.length > 0 && (
          <View className="mb-6">
            <Text className="font-headline-md text-headline-md text-primary font-bold mb-4">Recommendations</Text>
            <View className="gap-3">
              {advice.recommendations.map((rec: any, i: number) => (
                <View key={i} className="bg-surface-container-low rounded-2xl p-5" style={{ elevation: 2, shadowColor: '#000', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.06 }}>
                  <View className="flex-row items-start gap-3">
                    <View className="w-8 h-8 rounded-full bg-secondary-container items-center justify-center">
                      <Text className="font-label-md text-label-md text-secondary font-bold">{i + 1}</Text>
                    </View>
                    <View className="flex-1">
                      <Text className="font-label-md text-label-md text-primary font-bold mb-1">{rec.title}</Text>
                      <Text className="font-body-md text-body-md text-on-surface-variant">{rec.description}</Text>
                    </View>
                  </View>
                </View>
              ))}
            </View>
          </View>
        )}

        {advice?.action_items?.length > 0 && (
          <View>
            <Text className="font-headline-md text-headline-md text-primary font-bold mb-4">Action Items</Text>
            {advice.action_items.map((item: string, i: number) => (
              <View key={i} className="bg-surface-container-low rounded-2xl p-4 flex-row items-center gap-3 mb-3" style={{ elevation: 2, shadowColor: '#000', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.06 }}>
                <MaterialIcons name="check-circle-outline" size={22} color="#006b5a" />
                <Text className="font-body-md text-body-md text-on-surface flex-1">{item}</Text>
              </View>
            ))}
          </View>
        )}
      </ScrollView>
    </View>
  );
}
