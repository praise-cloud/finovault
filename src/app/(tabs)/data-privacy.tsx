import { useEffect, useState } from 'react';
import { ScrollView, View, Text, Pressable, ActivityIndicator } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { router } from 'expo-router';
import { getDataPrivacy, updatePrivacyToggles } from '@/lib/api/services/settings';

type PrivacyToggle = {
  key: string;
  label: string;
  description: string;
  enabled: boolean;
  icon: keyof typeof MaterialIcons.glyphMap;
};

export default function DataPrivacy() {
  const [toggles, setToggles] = useState<PrivacyToggle[]>([]);
  const [lastUpdated, setLastUpdated] = useState('');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    getDataPrivacy()
      .then((data) => {
        if (data.privacy_toggles) setToggles(data.privacy_toggles);
        if (data.last_updated) setLastUpdated(data.last_updated);
      })
      .catch(() => {})
      .finally(() => setLoading(false));
  }, []);

  const toggle = (key: string) => {
    const newToggles = toggles.map((t) => t.key === key ? { ...t, enabled: !t.enabled } : t);
    setToggles(newToggles);
    updatePrivacyToggles(newToggles).catch(() => {
      setToggles(toggles);
    });
  };

  return (
    <View className="flex-1 bg-surface-bright">
      <View className="bg-surface-bright pt-14 pb-3 px-margin-mobile" style={{ shadowColor: '#000', shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.04, elevation: 4 }}>
        <View className="flex-row items-center gap-3">
          <Pressable onPress={() => router.back()} className="w-9 h-9 rounded-xl bg-surface-variant items-center justify-center active:scale-90">
            <MaterialIcons name="arrow-back" size={20} color="#43474d" />
          </Pressable>
          <Text className="font-headline-md text-primary font-bold">Data Privacy</Text>
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
                <View className="w-12 h-12 rounded-full bg-primary-container items-center justify-center">
                  <MaterialIcons name="privacy-tip" size={24} color="#000f22" />
                </View>
                <View className="flex-1">
                  <Text className="font-headline-md text-primary font-bold">Your Privacy Matters</Text>
                  <Text className="text-body-md text-on-surface-variant text-sm">We use AES-256 encryption to protect your data. You control what is shared.</Text>
                </View>
              </View>
              <View className="bg-primary-container/30 rounded-xl p-3">
                <View className="flex-row items-center gap-2">
                  <MaterialIcons name="verified-user" size={16} color="#006b5a" />
                  <Text className="text-secondary font-label-md text-sm font-bold">Your data is encrypted end-to-end</Text>
                </View>
              </View>
            </View>

            <Text className="font-headline-md text-primary font-bold mb-3">Privacy Controls</Text>
            <View className="bg-white border border-outline-variant/20 rounded-2xl overflow-hidden mb-4">
              {toggles.map((item, i) => (
                <View key={item.key} className={`flex-row items-center gap-3 p-4 ${i < toggles.length - 1 ? 'border-b border-outline-variant/10' : ''}`}>
                  <View className={`w-10 h-10 rounded-xl items-center justify-center ${item.enabled ? 'bg-secondary-container' : 'bg-surface-variant'}`}>
                    <MaterialIcons name={item.icon} size={20} color={item.enabled ? '#00705e' : '#9ea0a5'} />
                  </View>
                  <View className="flex-1">
                    <Text className={`font-label-md font-bold ${item.enabled ? 'text-primary' : 'text-on-surface-variant'}`}>{item.label}</Text>
                    <Text className="text-caption text-on-surface-variant text-xs">{item.description}</Text>
                  </View>
                  <Pressable
                    onPress={() => toggle(item.key)}
                    className={`w-12 h-7 rounded-full items-center justify-center ${item.enabled ? 'bg-secondary' : 'bg-surface-variant'}`}
                  >
                    <View className={`w-5 h-5 rounded-full bg-white ${item.enabled ? 'self-end mr-0.5' : 'self-start ml-0.5'}`} style={{ shadowColor: '#000', shadowOffset: { width: 0, height: 1 }, shadowOpacity: 0.2, shadowRadius: 2, elevation: 2 }} />
                  </Pressable>
                </View>
              ))}
            </View>

            <View className="bg-white border border-outline-variant/20 rounded-2xl p-5 mb-4">
              <View className="flex-row items-center gap-2 mb-4">
                <MaterialIcons name="download" size={16} color="#006b5a" />
                <Text className="font-label-md font-bold text-primary">Your Data</Text>
              </View>
              <Text className="text-body-md text-on-surface-variant text-sm mb-4">You can request a copy of all data we have stored or delete your account permanently.</Text>
              <View className="flex-row gap-3">
                <Pressable className="flex-1 py-3 rounded-xl border border-outline-variant items-center active:scale-[0.98]">
                  <Text className="font-label-md text-primary font-bold">Export Data</Text>
                </Pressable>
                <Pressable className="flex-1 py-3 rounded-xl bg-error-container items-center active:scale-[0.98]">
                  <Text className="font-label-md text-error font-bold">Delete Account</Text>
                </Pressable>
              </View>
            </View>

            <View className="bg-white border border-outline-variant/20 rounded-2xl p-5">
              <Text className="font-label-md font-bold text-primary mb-2">Privacy Policy</Text>
              <Text className="text-body-md text-on-surface-variant text-sm mb-3">Last updated: {lastUpdated || 'June 15, 2026'}</Text>
              <Text className="text-body-md text-on-surface-variant text-sm leading-relaxed">Finovault AI is committed to protecting your privacy. We collect only the data necessary to provide our financial intelligence services and never sell your personal information to third parties. All data is encrypted using AES-256 standards both in transit and at rest.</Text>
            </View>
          </View>
        )}
      </ScrollView>
    </View>
  );
}
