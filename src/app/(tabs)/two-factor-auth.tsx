import { useEffect, useState } from 'react';
import { ScrollView, View, Text, Pressable, ActivityIndicator, useColorScheme } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { router } from 'expo-router';
import { getSecuritySettings, updateTwoFactor } from '@/src/lib/api/services/settings';

export default function TwoFactorAuth() {
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';
  const [enabled, setEnabled] = useState(false);
  const [method, setMethod] = useState<'app' | 'sms'>('app');
  const [loading, setLoading] = useState(true);
  const [recoveryCodes, setRecoveryCodes] = useState<string[]>(() =>
    Array.from({ length: 5 }, () => {
      const part1 = Math.random().toString(36).substring(2, 6).toUpperCase();
      const part2 = Math.random().toString(36).substring(2, 6).toUpperCase();
      return `${part1}-${part2}`;
    })
  );

  const generateNewCodes = () => {
    setRecoveryCodes(
      Array.from({ length: 5 }, () => {
        const part1 = Math.random().toString(36).substring(2, 6).toUpperCase();
        const part2 = Math.random().toString(36).substring(2, 6).toUpperCase();
        return `${part1}-${part2}`;
      })
    );
  };

  useEffect(() => {
    getSecuritySettings()
      .then((data) => {
        setEnabled(data.two_factor_enabled);
        if (data.two_factor_method === 'app' || data.two_factor_method === 'sms') {
          setMethod(data.two_factor_method);
        }
      })
      .catch(() => {})
      .finally(() => setLoading(false));
  }, []);

  const handleToggle = () => {
    const newEnabled = !enabled;
    setEnabled(newEnabled);
    updateTwoFactor(newEnabled, method).catch(() => {
      setEnabled(!newEnabled);
    });
  };

  const handleMethodChange = (newMethod: 'app' | 'sms') => {
    setMethod(newMethod);
    updateTwoFactor(enabled, newMethod).catch(() => {
      setMethod(method);
    });
  };

  return (
    <View className="flex-1 bg-surface-bright" style={{ backgroundColor: isDark ? '#08142E' : '#FFFFFF' }}>
      <View className="bg-surface-bright pt-14 pb-3 px-margin-mobile" style={{ boxShadow: '0 4px 4px rgba(0,0,0,0.04)', elevation: 4 }}>
        <View className="flex-row items-center gap-3">
          <Pressable onPress={() => router.back()} className="w-9 h-9 rounded-xl bg-surface-variant items-center justify-center active:scale-90" accessibilityLabel="Go back" accessibilityRole="button">
            <MaterialIcons name="arrow-back" size={20} color={isDark ? '#FFFFFF' : '#43474d'} />
          </Pressable>
          <Text className="font-headline-md text-primary font-bold">Two-Factor Auth</Text>
        </View>
      </View>

      <ScrollView className="flex-1 px-margin-mobile" contentContainerStyle={{ paddingBottom: 120 }} showsVerticalScrollIndicator={false}>
        {loading ? (
          <View className="flex-1 items-center justify-center mt-20">
            <ActivityIndicator size="large" color={isDark ? '#FFFFFF' : '#1A1A1A'} />
          </View>
        ) : (
          <View className="mt-4">
            <View className={`border border-outline-variant/20 rounded-2xl p-5 mb-4 ${isDark ? 'bg-[#0D1B3E]' : 'bg-white'}`}>
              <View className="flex-row items-center justify-between mb-4">
                <View className="flex-row items-center gap-2">
                  <View className="w-10 h-10 rounded-xl bg-secondary-container items-center justify-center">
                    <MaterialIcons name="lock-open" size={20} color={isDark ? '#FFFFFF' : '#1A1A1A'} />
                  </View>
                  <View>
                    <Text className="font-headline-md text-primary font-bold">Status</Text>
                    <Text className="text-caption text-on-surface-variant text-xs">Two-factor authentication</Text>
                  </View>
                </View>
                <Pressable
                  onPress={handleToggle}
                  className={`w-14 h-8 rounded-full items-center justify-center ${enabled ? 'bg-secondary' : 'bg-surface-variant'}`}
                  accessibilityRole="switch"
                  accessibilityLabel="Toggle two-factor authentication"
                  accessibilityState={{ checked: enabled }}
                >
                  <View className={`w-6 h-6 rounded-full bg-white ${enabled ? 'self-end mr-0.5' : 'self-start ml-0.5'}`} style={{ boxShadow: '0 1px 2px rgba(0,0,0,0.2)', elevation: 2 }} />
                </Pressable>
              </View>

              {enabled && (
                <View className="bg-surface-container-low rounded-xl p-3 flex-row items-center gap-2">
                  <MaterialIcons name="check-circle" size={16} color={isDark ? '#D4AF37' : '#08142E'} />
                  <Text className="text-secondary font-label-md text-sm font-bold">Two-factor authentication is active</Text>
                </View>
              )}
            </View>

            <Text className="font-headline-md text-primary font-bold mb-3">Authentication Method</Text>
            <View className={`border border-outline-variant/20 rounded-2xl overflow-hidden mb-4 ${isDark ? 'bg-[#0D1B3E]' : 'bg-white'}`}>
              <Pressable
                onPress={() => handleMethodChange('app')}
                className={`flex-row items-center gap-3 p-4 border-b border-outline-variant/10 ${method === 'app' ? 'bg-secondary-container/20' : ''}`}
                accessibilityRole="button"
              >
                <View className={`w-6 h-6 rounded-full border-2 items-center justify-center ${method === 'app' ? 'border-secondary' : 'border-outline'}`}>
                  {method === 'app' && <View className="w-3 h-3 rounded-full bg-secondary" />}
                </View>
                <View className="w-10 h-10 rounded-xl bg-primary-container items-center justify-center">
                  <MaterialIcons name="smartphone" size={20} color={isDark ? '#D4AF37' : '#0A1F5C'} />
                </View>
                <View className="flex-1">
                  <Text className="font-label-md font-bold text-primary">Authenticator App</Text>
                  <Text className="text-caption text-on-surface-variant text-xs">Google Authenticator, Authy, or similar</Text>
                </View>
              </Pressable>
              <Pressable
                onPress={() => handleMethodChange('sms')}
                className={`flex-row items-center gap-3 p-4 ${method === 'sms' ? 'bg-secondary-container/20' : ''}`}
                accessibilityRole="button"
              >
                <View className={`w-6 h-6 rounded-full border-2 items-center justify-center ${method === 'sms' ? 'border-secondary' : 'border-outline'}`}>
                  {method === 'sms' && <View className="w-3 h-3 rounded-full bg-secondary" />}
                </View>
                <View className="w-10 h-10 rounded-xl bg-primary-container items-center justify-center">
                  <MaterialIcons name="sms" size={20} color={isDark ? '#D4AF37' : '#0A1F5C'} />
                </View>
                <View className="flex-1">
                  <Text className="font-label-md font-bold text-primary">SMS Text Message</Text>
                  <Text className="text-caption text-on-surface-variant text-xs">Receive codes via SMS</Text>
                </View>
              </Pressable>
            </View>

            <View className={`border border-outline-variant/20 rounded-2xl p-5 mb-4 ${isDark ? 'bg-[#0D1B3E]' : 'bg-white'}`}>
              <View className="flex-row items-center gap-2 mb-3">
                <MaterialIcons name="info" size={16} color={isDark ? '#D4AF37' : '#08142E'} />
                <Text className="font-label-md font-bold text-primary">Recovery Codes</Text>
              </View>
              <Text className="text-body-md text-on-surface-variant text-sm mb-4">Save these recovery codes in a secure place. Each code can only be used once.</Text>
              <View className="bg-surface-container-low rounded-xl p-4">
                {recoveryCodes.map((code) => (
                  <Text key={code} className="font-mono text-sm text-primary tracking-widest py-0.5">{code}</Text>
                ))}
              </View>
              <Pressable onPress={generateNewCodes} className="mt-4 w-full py-3.5 bg-primary rounded-xl items-center active:scale-[0.98]" accessibilityRole="button">
                <Text className="text-on-primary font-label-md font-bold">Generate New Codes</Text>
              </Pressable>
            </View>
          </View>
        )}
      </ScrollView>
    </View>
  );
}
