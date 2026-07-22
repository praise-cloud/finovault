import { useEffect, useState } from 'react';
import { ScrollView, View, Text, Pressable, ActivityIndicator, Alert } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { router } from 'expo-router';
import { getSecuritySettings, updateGuardrails } from '@/lib/api/services/settings';

type Guardrail = {
  key: string;
  label: string;
  description: string;
  enabled: boolean;
  icon: keyof typeof MaterialIcons.glyphMap;
};

export default function Guardrails() {
  const [guardrails, setGuardrails] = useState<Guardrail[]>([]);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    getSecuritySettings()
      .then((data) => {
        if (data.guardrails && data.guardrails.length > 0) {
          setGuardrails(data.guardrails);
        }
      })
      .catch(() => {})
      .finally(() => setLoading(false));
  }, []);

  const toggleGuardrail = (key: string) => {
    setGuardrails((prev) => prev.map((g) => g.key === key ? { ...g, enabled: !g.enabled } : g));
  };

  const handleSave = async () => {
    setSaving(true);
    try {
      await updateGuardrails(guardrails);
      Alert.alert('Saved', 'Guardrails have been updated successfully.');
    } catch {
      Alert.alert('Error', 'Failed to save guardrails. Please try again.');
    } finally {
      setSaving(false);
    }
  };

  return (
    <View className="flex-1 bg-surface-bright">
      <View className="bg-surface-bright pt-14 pb-3 px-margin-mobile" style={{ shadowColor: '#000', shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.04, elevation: 4 }}>
        <View className="flex-row items-center gap-3">
          <Pressable onPress={() => router.back()} className="w-9 h-9 rounded-xl bg-surface-variant items-center justify-center active:scale-90">
            <MaterialIcons name="arrow-back" size={20} color="#43474d" />
          </Pressable>
          <Text className="font-headline-md text-primary font-bold">Configure Guardrails</Text>
        </View>
      </View>

      <ScrollView className="flex-1 px-margin-mobile" contentContainerStyle={{ paddingBottom: 120 }} showsVerticalScrollIndicator={false}>
        {loading ? (
          <View className="flex-1 items-center justify-center mt-20">
            <ActivityIndicator size="large" color="#1A1A1A" />
          </View>
        ) : (
          <>
            <View className="mt-4 mb-6">
              <Text className="text-on-surface-variant text-body-md">Set automated safety rules for your financial transactions and account activity.</Text>
            </View>

            <View className="bg-white border border-outline-variant/20 rounded-2xl overflow-hidden">
              {guardrails.map((g, i) => (
                <View key={g.key} className={`flex-row items-center gap-3 p-4 ${i < guardrails.length - 1 ? 'border-b border-outline-variant/10' : ''}`}>
                  <View className={`w-10 h-10 rounded-xl items-center justify-center ${g.enabled ? 'bg-secondary-container' : 'bg-surface-variant'}`}>
                    <MaterialIcons name={g.icon} size={20} color={g.enabled ? '#1A1A1A' : '#9ea0a5'} />
                  </View>
                  <View className="flex-1">
                    <Text className={`font-label-md font-bold ${g.enabled ? 'text-primary' : 'text-on-surface-variant'}`}>{g.label}</Text>
                    <Text className="text-caption text-on-surface-variant text-xs">{g.description}</Text>
                  </View>
                  <Pressable
                    onPress={() => toggleGuardrail(g.key)}
                    className={`w-12 h-7 rounded-full items-center justify-center ${g.enabled ? 'bg-secondary' : 'bg-surface-variant'}`}
                  >
                    <View className={`w-5 h-5 rounded-full bg-white ${g.enabled ? 'self-end mr-0.5' : 'self-start ml-0.5'}`} style={{ shadowColor: '#000', shadowOffset: { width: 0, height: 1 }, shadowOpacity: 0.2, shadowRadius: 2, elevation: 2 }} />
                  </Pressable>
                </View>
              ))}
            </View>

            <Pressable
              onPress={handleSave}
              disabled={saving}
              className="mt-6 w-full bg-secondary py-3.5 rounded-xl items-center active:scale-[0.98]"
            >
              {saving ? (
                <ActivityIndicator size="small" color="#ffffff" />
              ) : (
                <Text className="text-on-secondary font-label-md font-bold">Save Guardrails</Text>
              )}
            </Pressable>
          </>
        )}
      </ScrollView>
    </View>
  );
}
