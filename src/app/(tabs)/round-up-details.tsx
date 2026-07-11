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
          <Text className="font-headline-md text-headline-md text-primary font-bold">Round-up Details</Text>
          <View className="w-10" />
        </View>
      </View>

      <ScrollView className="flex-1 px-margin-mobile" contentContainerStyle={{ paddingBottom: 120 }}>
        <View className="flex-row gap-4 mt-6 mb-8">
          <View className="flex-1 bg-surface-container-low rounded-2xl p-5" style={{ elevation: 2, shadowColor: '#000', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.06 }}>
            <View className="flex-row items-center gap-2 mb-3">
              <MaterialIcons name="savings" size={20} color="#006b5a" />
              <Text className="font-label-md text-label-md text-on-surface-variant">Total Saved</Text>
            </View>
            <Text className="font-display-md text-display-md text-primary font-bold">${totalSaved.toFixed(2)}</Text>
          </View>
          <View className="flex-1 bg-surface-container-low rounded-2xl p-5" style={{ elevation: 2, shadowColor: '#000', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.06 }}>
            <View className="flex-row items-center gap-2 mb-3">
              <MaterialIcons name="receipt-long" size={20} color="#006b5a" />
              <Text className="font-label-md text-label-md text-on-surface-variant">Round-ups</Text>
            </View>
            <Text className="font-display-md text-display-md text-primary font-bold">{roundUps.length}</Text>
          </View>
        </View>

        <Text className="font-headline-md text-headline-md text-primary font-bold mb-4">Round-up History</Text>

        <View className="gap-3">
          {roundUps.map((item) => (
            <View key={item.id} className="bg-surface-container-low rounded-2xl p-4" style={{ elevation: 2, shadowColor: '#000', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.06 }}>
              <View className="flex-row items-center justify-between mb-2">
                <Text className="font-label-md text-label-md text-primary font-bold flex-1">Round-up Saving</Text>
                <Text className="font-label-md text-label-md font-bold" style={{ color: '#006b5a' }}>+${Number(item.amount).toFixed(2)}</Text>
              </View>
              <View className="flex-row items-center justify-between">
                <Text className="text-caption text-on-surface-variant">{new Date(item.date).toLocaleDateString()}</Text>
                <View className="px-2 py-0.5 rounded-full bg-[#006b5a20]">
                  <Text className="text-caption text-[#006b5a]">Saved</Text>
                </View>
              </View>
            </View>
          ))}
        </View>
      </ScrollView>
    </View>
  );
}
