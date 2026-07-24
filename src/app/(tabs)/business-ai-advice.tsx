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
        <ActivityIndicator size="large" color="#08142E" />
      </View>
    );
  }

  return (
    <View className="flex-1 bg-surface-bright">
      <View className="pt-14 pb-3 px-margin-mobile bg-surface-bright" style={{ boxShadow: '0 4px 4px rgba(0,0,0,0.04)', elevation: 4 }}>
        <View className="flex-row items-center justify-between">
          <Pressable onPress={() => router.back()} className="w-10 h-10 rounded-full bg-[#EEF0F5] items-center justify-center active:scale-90">
            <MaterialIcons name="arrow-back" size={20} color="#181c1e" />
          </Pressable>
          <Text className="font-body-bold text-[#1A1A1A] font-bold" style={{ fontSize: 20 }}>AI Advice</Text>
          <Pressable onPress={onRefresh} className="w-10 h-10 rounded-full bg-[#EEF0F5] items-center justify-center active:scale-90">
            <MaterialIcons name="refresh" size={20} color="#181c1e" />
          </Pressable>
        </View>
      </View>

      <ScrollView
        className="flex-1 px-margin-mobile"
        contentContainerStyle={{ paddingBottom: 120 }}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} tintColor="#08142E" />}
      >
        <View className="mt-6 mb-8">
          <Text className="font-body-bold text-[#1A1A1A] mb-2" style={{ fontSize: 28 }}>AI-Powered Insights</Text>
          <Text className="text-[#6B6F76]" style={{ fontSize: 16 }}>Personalized recommendations based on your business data.</Text>
        </View>

        {advice?.summary && (
          <View className="bg-[#EEF0F5] rounded-2xl p-6 mb-6" style={{ boxShadow: '0 2px 4px rgba(0,0,0,0.06)', elevation: 2 }}>
            <View className="flex-row items-center gap-3 mb-4">
              <View className="w-10 h-10 rounded-full bg-secondary-container items-center justify-center">
                <MaterialIcons name="psychology" size={22} color="#1A1A1A" />
              </View>
              <Text className="font-body-bold text-[#1A1A1A] font-bold flex-1" style={{ fontSize: 20 }}>Overview</Text>
            </View>
            <Text className="font-body-md text-on-surface leading-6" style={{ fontSize: 16 }}>{advice.summary}</Text>
          </View>
        )}

        {advice?.recommendations?.length > 0 && (
          <View className="mb-6">
            <Text className="font-body-bold text-[#1A1A1A] font-bold mb-4" style={{ fontSize: 20 }}>Recommendations</Text>
            <View className="gap-3">
              {advice.recommendations.map((rec: any, i: number) => (
                <View key={i} className="bg-[#EEF0F5] rounded-2xl p-5" style={{ boxShadow: '0 2px 4px rgba(0,0,0,0.06)', elevation: 2 }}>
                  <View className="flex-row items-start gap-3">
                    <View className="w-8 h-8 rounded-full bg-secondary-container items-center justify-center">
                      <Text className="font-body-semibold text-[#08142E] font-bold" style={{ fontSize: 14 }}>{i + 1}</Text>
                    </View>
                    <View className="flex-1">
                      <Text className="font-body-semibold text-[#1A1A1A] font-bold mb-1" style={{ fontSize: 14 }}>{rec.title}</Text>
                      <Text className="text-[#6B6F76]" style={{ fontSize: 16 }}>{rec.description}</Text>
                    </View>
                  </View>
                </View>
              ))}
            </View>
          </View>
        )}

        {advice?.action_items?.length > 0 && (
          <View>
            <Text className="font-body-bold text-[#1A1A1A] font-bold mb-4" style={{ fontSize: 20 }}>Action Items</Text>
            {advice.action_items.map((item: string, i: number) => (
              <View key={i} className="bg-[#EEF0F5] rounded-2xl p-4 flex-row items-center gap-3 mb-3" style={{ boxShadow: '0 2px 4px rgba(0,0,0,0.06)', elevation: 2 }}>
                <MaterialIcons name="check-circle-outline" size={22} color="#08142E" />
                <Text className="font-body-md text-on-surface flex-1" style={{ fontSize: 16 }}>{item}</Text>
              </View>
            ))}
          </View>
        )}
      </ScrollView>
    </View>
  );
}
