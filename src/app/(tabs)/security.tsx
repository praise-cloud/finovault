import { useEffect, useState } from 'react';
import { ScrollView, View, Text, Pressable, ActivityIndicator } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { router } from 'expo-router';
import { getSecuritySettings } from '@/lib/api/services/settings';

export default function Security() {
  const [twoFactorEnabled, setTwoFactorEnabled] = useState(false);
  const [activeDevices, setActiveDevices] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    getSecuritySettings()
      .then((data) => {
        setTwoFactorEnabled(data.two_factor_enabled);
        setActiveDevices(data.active_devices != null ? `${data.active_devices} devices` : null);
      })
      .catch(() => {})
      .finally(() => setLoading(false));
  }, []);

  const items = [
    { icon: 'lock-open' as const, label: 'Two-Factor Authentication', description: 'Add an extra layer of security to your account', route: '/(tabs)/two-factor-auth', status: loading ? null : (twoFactorEnabled ? 'Enabled' : 'Disabled') },
    { icon: 'history' as const, label: 'Last Login', description: 'View your recent login activity', route: '/(tabs)/last-login', status: null },
    { icon: 'devices' as const, label: 'Active Devices', description: 'Manage devices connected to your account', route: null, status: activeDevices },
    { icon: 'key' as const, label: 'Passkeys & Security Keys', description: 'Manage hardware security keys', route: null, status: null },
    { icon: 'lock' as const, label: 'Password & PIN', description: 'Update your password or set a transaction PIN', route: null, status: null },
    { icon: 'devices-other' as const, label: 'Active Sessions', description: 'Review and manage your active sessions', route: null, status: null },
  ];

  return (
    <View className="flex-1 bg-surface-bright">
      <View className="bg-surface-bright pt-14 pb-3 px-margin-mobile" style={{ shadowColor: '#000', shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.04, elevation: 4 }}>
        <View className="flex-row items-center gap-3">
          <Pressable onPress={() => router.back()} className="w-9 h-9 rounded-xl bg-surface-variant items-center justify-center active:scale-90">
            <MaterialIcons name="arrow-back" size={20} color="#43474d" />
          </Pressable>
          <Text className="font-headline-md text-primary font-bold">Security</Text>
        </View>
      </View>

      <ScrollView className="flex-1 px-margin-mobile" contentContainerStyle={{ paddingBottom: 120 }} showsVerticalScrollIndicator={false}>
        {loading ? (
          <View className="flex-1 items-center justify-center mt-20">
            <ActivityIndicator size="large" color="#00705e" />
          </View>
        ) : (
          <View className="mt-4 mb-6">
            <View className="bg-white border border-outline-variant/20 rounded-2xl p-5 mb-4">
              <View className="flex-row items-center gap-3 mb-4">
                <View className="w-12 h-12 rounded-full bg-secondary-container items-center justify-center">
                  <MaterialIcons name="shield-moon" size={24} color="#00705e" />
                </View>
                <View className="flex-1">
                  <Text className="font-headline-md text-primary font-bold">Security Status</Text>
                  <View className="flex-row items-center gap-1 mt-0.5">
                    <View className="w-2 h-2 rounded-full bg-secondary" />
                    <Text className="text-secondary font-label-md">All Safe</Text>
                  </View>
                </View>
              </View>
              <View className="flex-row gap-3">
                <View className="flex-1 bg-surface-container-low rounded-xl p-3 items-center">
                  <Text className="font-display-lg text-display-lg text-primary font-bold">92</Text>
                  <Text className="text-caption text-on-surface-variant text-xs">Security Score</Text>
                </View>
                <View className="flex-1 bg-surface-container-low rounded-xl p-3 items-center">
                  <Text className="font-display-lg text-display-lg text-primary font-bold">256</Text>
                  <Text className="text-caption text-on-surface-variant text-xs">Encryption</Text>
                </View>
              </View>
            </View>

            <View className="bg-white border border-outline-variant/20 rounded-2xl overflow-hidden">
              {items.map((item, i) => (
                <Pressable
                  key={item.label}
                  onPress={() => item.route ? router.push(item.route as any) : null}
                  className={`flex-row items-center gap-3 p-4 ${i < items.length - 1 ? 'border-b border-outline-variant/10' : ''} active:scale-[0.98]`}
                >
                  <View className="w-10 h-10 rounded-xl bg-primary-container items-center justify-center">
                    <MaterialIcons name={item.icon} size={20} color="#ffffff" />
                  </View>
                  <View className="flex-1">
                    <Text className="font-label-md font-bold text-primary">{item.label}</Text>
                    <Text className="text-caption text-on-surface-variant text-xs">{item.description}</Text>
                  </View>
                  {item.status && (
                    <View className="bg-secondary-container/50 px-3 py-1 rounded-full mr-1">
                      <Text className="text-on-secondary-container text-xs font-bold">{item.status}</Text>
                    </View>
                  )}
                  <MaterialIcons name="chevron-right" size={18} color="#c4c6ca" />
                </Pressable>
              ))}
            </View>
          </View>
        )}
      </ScrollView>
    </View>
  );
}
