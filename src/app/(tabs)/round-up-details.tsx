import { useEffect, useState } from 'react';
import { ScrollView, View, Text, Pressable, ActivityIndicator } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { router } from 'expo-router';
import { listRoundUps } from '@/lib/api/services/savings';

export default function RoundUpDetails() {
  const [loading, setLoading] = useState(true);
  const [roundUps, setRoundUps] = useState<any[]>([]);

  useEffect(() => {
    listRoundUps()
      .then((data) => setRoundUps(data || []))
      .catch(() => {})
      .finally(() => setLoading(false));
  }, []);

  const totalSaved = roundUps.reduce((sum, r) => sum + Number(r.amount), 0);

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
          <Text className="font-body-bold text-[#1A1A1A] font-bold" style={{ fontSize: 20 }}>Round-up Details</Text>
          <View className="w-10" />
        </View>
      </View>

      <ScrollView className="flex-1 px-margin-mobile" contentContainerStyle={{ paddingBottom: 120 }}>
        <View className="flex-row gap-4 mt-6 mb-8">
          <View className="flex-1 bg-[#EEF0F5] rounded-2xl p-5" style={{ boxShadow: '0 2px 4px rgba(0,0,0,0.06)', elevation: 2 }}>
            <View className="flex-row items-center gap-2 mb-3">
              <MaterialIcons name="savings" size={20} color="#08142E" />
              <Text className="font-body-semibold text-[#6B6F76]" style={{ fontSize: 14 }}>Total Saved</Text>
            </View>
            <Text className="font-display-md text-display-md text-primary font-bold">${totalSaved.toFixed(2)}</Text>
          </View>
          <View className="flex-1 bg-[#EEF0F5] rounded-2xl p-5" style={{ boxShadow: '0 2px 4px rgba(0,0,0,0.06)', elevation: 2 }}>
            <View className="flex-row items-center gap-2 mb-3">
              <MaterialIcons name="receipt-long" size={20} color="#08142E" />
              <Text className="font-body-semibold text-[#6B6F76]" style={{ fontSize: 14 }}>Round-ups</Text>
            </View>
            <Text className="font-display-md text-display-md text-primary font-bold">{roundUps.length}</Text>
          </View>
        </View>

        <Text className="font-headline-md text-headline-md text-primary font-bold mb-4">Round-up History</Text>

        <View className="gap-3">
          {roundUps.map((item) => (
            <View key={item.id} className="bg-[#EEF0F5] rounded-2xl p-4" style={{ boxShadow: '0 2px 4px rgba(0,0,0,0.06)', elevation: 2 }}>
              <View className="flex-row items-center justify-between mb-2">
                <Text className="font-label-md text-label-md text-primary font-bold flex-1">Round-up Saving</Text>
                <Text className="font-label-md text-label-md font-bold" style={{ color: '#08142E' }}>+${Number(item.amount).toFixed(2)}</Text>
              </View>
              <View className="flex-row items-center justify-between">
                <Text className="text-caption text-on-surface-variant">{new Date(item.date).toLocaleDateString()}</Text>
                <View className="px-2 py-0.5 rounded-full bg-[rgba(8,20,46,0.08)]">
                  <Text className="text-caption text-[#08142E]">Saved</Text>
                </View>
              </View>
            </View>
          ))}
        </View>
      </ScrollView>
    </View>
  );
}
