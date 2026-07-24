import { useEffect, useState } from 'react';
import { ScrollView, View, Text, Pressable, ActivityIndicator } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { router } from 'expo-router';
import { getLoginActivity } from '@/lib/api/services/settings';

type LoginEntry = {
  id: string;
  device: string;
  location: string;
  ip: string;
  time: string;
  successful: boolean;
};

export default function LastLogin() {
  const [logins, setLogins] = useState<LoginEntry[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    getLoginActivity()
      .then((data) => setLogins(data))
      .catch(() => {})
      .finally(() => setLoading(false));
  }, []);

  const latest = logins.length > 0 ? logins[0] : null;

  const extractSummary = (device: string) => {
    if (device.includes('Windows')) return 'Windows 11';
    if (device.includes('iPhone')) return 'iPhone 15 Pro';
    if (device.includes('macOS') || device.includes('Mac')) return 'macOS';
    if (device.includes('Ubuntu')) return 'Ubuntu';
    return device;
  };

  const extractCity = (location: string) => {
    return location.split(',')[0] || location;
  };

  return (
    <View className="flex-1 bg-surface-bright">
      <View className="bg-surface-bright pt-14 pb-3 px-margin-mobile" style={{ boxShadow: '0 4px 4px rgba(0,0,0,0.04)', elevation: 4 }}>
        <View className="flex-row items-center gap-3">
          <Pressable onPress={() => router.back()} className="w-9 h-9 rounded-full bg-[#EEF0F5] items-center justify-center active:scale-90">
            <MaterialIcons name="arrow-back" size={20} color="#43474d" />
          </Pressable>
          <Text className="font-body-bold text-[#1A1A1A] font-bold" style={{ fontSize: 20 }}>Login Activity</Text>
        </View>
      </View>

      <ScrollView className="flex-1 px-margin-mobile" contentContainerStyle={{ paddingBottom: 120 }} showsVerticalScrollIndicator={false}>
        {loading ? (
          <View className="flex-1 items-center justify-center mt-20">
            <ActivityIndicator size="large" color="#1A1A1A" />
          </View>
        ) : (
          <View className="mt-4 mb-6">
            <View className="flex-row flex-wrap mb-4" style={{ gap: 12 }}>
              <View className="bg-white border border-outline-variant/20 rounded-2xl p-4 flex-1 min-w-[100px]">
                <Text className="font-body text-[#6B6F76] uppercase tracking-wider" style={{ fontSize: 12 }}>Last Login</Text>
                <Text className="font-body-semibold font-bold text-[#1A1A1A] mt-1" style={{ fontSize: 14 }}>{latest ? latest.time : 'N/A'}</Text>
              </View>
              <View className="bg-white border border-outline-variant/20 rounded-2xl p-4 flex-1 min-w-[100px]">
                <Text className="font-body text-[#6B6F76] uppercase tracking-wider" style={{ fontSize: 12 }}>Device</Text>
                <Text className="font-body-semibold font-bold text-[#1A1A1A] mt-1" style={{ fontSize: 14 }}>{latest ? extractSummary(latest.device) : 'N/A'}</Text>
              </View>
              <View className="bg-white border border-outline-variant/20 rounded-2xl p-4 flex-1 min-w-[100px]">
                <Text className="font-body text-[#6B6F76] uppercase tracking-wider" style={{ fontSize: 12 }}>Location</Text>
                <Text className="font-body-semibold font-bold text-[#1A1A1A] mt-1" style={{ fontSize: 14 }}>{latest ? extractCity(latest.location) : 'N/A'}</Text>
              </View>
            </View>

            <View className="bg-white border border-outline-variant/20 rounded-2xl overflow-hidden">
              <View className="px-4 py-3.5 border-b border-outline-variant/10">
                <Text className="font-body-semibold text-[#1A1A1A] font-bold" style={{ fontSize: 14 }}>Recent Login Attempts</Text>
              </View>
              {logins.length === 0 ? (
                <View className="p-8 items-center">
                  <MaterialIcons name="history" size={40} color="#c4c6ca" />
                  <Text className="text-[#6B6F76] mt-2" style={{ fontSize: 14 }}>No login activity recorded</Text>
                </View>
              ) : (
                logins.map((entry, i) => (
                  <View key={entry.id} className={`flex-row items-center gap-3 p-4 ${i < logins.length - 1 ? 'border-b border-outline-variant/10' : ''}`}>
                    <View className={`w-10 h-10 rounded-xl items-center justify-center ${entry.successful ? 'bg-secondary-container' : 'bg-error-container'}`}>
                      <MaterialIcons name={entry.successful ? 'computer' : 'warning'} size={20} color={entry.successful ? '#1A1A1A' : '#ba1a1a'} />
                    </View>
                    <View className="flex-1">
                      <View className="flex-row items-center gap-2">
                        <Text className="font-body-semibold font-bold text-[#1A1A1A]" style={{ fontSize: 14 }}>{entry.device}</Text>
                        {!entry.successful && <View className="bg-[#BA1A1A] px-1.5 py-0.5 rounded"><Text className="text-white text-[10px] font-bold">Failed</Text></View>}
                      </View>
                      <Text className="font-body text-[#6B6F76]" style={{ fontSize: 12 }}>{entry.location} • {entry.ip}</Text>
                      <Text className="font-body text-[#6B6F76] mt-0.5" style={{ fontSize: 12 }}>{entry.time}</Text>
                    </View>
                  </View>
                ))
              )}
            </View>

            <View className="bg-white border border-outline-variant/20 rounded-2xl p-5 mt-4">
              <View className="flex-row items-center gap-2 mb-3">
                <MaterialIcons name="info" size={16} color="#08142E" />
                <Text className="font-body-semibold font-bold text-[#1A1A1A]" style={{ fontSize: 14 }}>Security Tip</Text>
              </View>
              <Text className="text-[#6B6F76]" style={{ fontSize: 14 }}>If you notice any unrecognized login attempts, change your password immediately and enable two-factor authentication.</Text>
            </View>
          </View>
        )}
      </ScrollView>
    </View>
  );
}
