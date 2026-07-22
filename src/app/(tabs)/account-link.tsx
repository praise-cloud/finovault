import { useState, useEffect } from 'react';
import { ScrollView, View, Text, Pressable, ActivityIndicator } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { router } from 'expo-router';
import { getProfileLinkedAccounts } from '@/lib/api/services/profile';

const BANK_LIST = [
  { id: 'chase', name: 'Chase', icon: 'account-balance' },
  { id: 'boa', name: 'Bank of America', icon: 'account-balance' },
  { id: 'wells', name: 'Wells Fargo', icon: 'account-balance' },
  { id: 'citi', name: 'Citibank', icon: 'account-balance' },
  { id: 'us', name: 'US Bank', icon: 'account-balance' },
  { id: 'other', name: 'Other Bank', icon: 'more-horiz' },
];

export default function AccountLink() {
  const [loading, setLoading] = useState(true);
  const [linkedAccounts, setLinkedAccounts] = useState<any[]>([]);
  const [selected, setSelected] = useState<string | null>(null);
  const [linking, setLinking] = useState(false);

  useEffect(() => {
    getProfileLinkedAccounts()
      .then((data: any) => setLinkedAccounts(data?.linked_accounts || data || []))
      .catch(() => {})
      .finally(() => setLoading(false));
  }, []);

  const handleLink = () => {
    setLinking(true);
    setTimeout(() => {
      setLinking(false);
      router.back();
    }, 1500);
  };

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
          <Text className="font-headline-md text-headline-md text-primary font-bold">Link Account</Text>
          <View className="w-10" />
        </View>
      </View>

      <ScrollView className="flex-1 px-margin-mobile" contentContainerStyle={{ paddingBottom: 120 }}>
        <View className="mt-6 mb-8">
          <Text className="font-headline-lg text-headline-lg text-primary mb-2">Connect Your Bank</Text>
          <Text className="font-body-md text-body-md text-on-surface-variant">Securely link your bank account to enable round-ups and smart savings.</Text>
        </View>

        {linkedAccounts.length > 0 && (
          <View className="mb-8">
            <Text className="font-label-md text-label-md text-primary font-bold mb-3">Already Linked</Text>
            {linkedAccounts.map((acct: any, i: number) => (
              <View key={i} className="bg-surface-container-low rounded-2xl p-4 flex-row items-center gap-3 mb-2" style={{ elevation: 2, shadowColor: '#000', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.06 }}>
                <MaterialIcons name="check-circle" size={20} color="#D4AF37" />
                <View className="flex-1">
                  <Text className="font-label-md text-label-md text-primary font-bold">{acct.bank_name || acct.name || 'Linked Account'}</Text>
                  <Text className="text-caption text-on-surface-variant">
                    {acct.mask ? `****${acct.mask}` : acct.type || 'Account'}
                  </Text>
                </View>
              </View>
            ))}
          </View>
        )}

        <Text className="font-label-md text-label-md text-primary font-bold mb-4">Select Your Bank</Text>
        <View className="gap-3 mb-8">
          {BANK_LIST.map((bank) => (
            <Pressable
              key={bank.id}
              onPress={() => setSelected(bank.id)}
              className={`flex-row items-center gap-4 p-4 rounded-2xl border ${selected === bank.id ? 'bg-primary-container border-primary' : 'bg-surface-container-low border-transparent'}`}
              style={{ elevation: selected === bank.id ? 0 : 2, shadowColor: '#000', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.06 }}
            >
              <View className={`w-12 h-12 rounded-full items-center justify-center ${selected === bank.id ? 'bg-white/20' : 'bg-surface-container-high'}`}>
                <MaterialIcons name={bank.icon as any} size={22} color={selected === bank.id ? '#ffffff' : '#43474d'} />
              </View>
              <Text className={`font-label-md text-label-md font-bold flex-1 ${selected === bank.id ? 'text-white' : 'text-primary'}`}>{bank.name}</Text>
              {selected === bank.id && <MaterialIcons name="check-circle" size={22} color="#ffffff" />}
            </Pressable>
          ))}
        </View>

        {selected && (
          <View className="bg-surface-container-low rounded-2xl p-5 mb-6" style={{ elevation: 2, shadowColor: '#000', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.06 }}>
            <View className="flex-row items-center gap-3 mb-4">
              <MaterialIcons name="security" size={22} color="#D4AF37" />
              <Text className="font-label-md text-label-md text-primary font-bold">Secure Connection</Text>
            </View>
            <Text className="font-body-md text-body-md text-on-surface-variant mb-4">
              Your credentials are encrypted. We use bank-grade security to protect your data.
            </Text>
            <Pressable onPress={handleLink} disabled={linking} className="w-full py-4 rounded-xl bg-secondary items-center justify-center active:scale-[0.98]">
              <Text className="font-label-md text-label-md text-white font-bold">{linking ? 'Linking...' : 'Link Account'}</Text>
            </Pressable>
          </View>
        )}
      </ScrollView>
    </View>
  );
}
