import { useEffect, useState } from 'react';
import { ScrollView, View, Text, Pressable, ActivityIndicator } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { router } from 'expo-router';
import { getLinkedAccounts } from '@/lib/api/services/settings';

type BankAccount = {
  id: string;
  bank_name: string;
  account_type: string;
  account_number: string;
  balance: number;
  logo: string;
};

export default function LinkedAccounts() {
  const [accounts, setAccounts] = useState<BankAccount[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    getLinkedAccounts()
      .then((data) => setAccounts(data))
      .catch(() => {})
      .finally(() => setLoading(false));
  }, []);

  const totalBalance = accounts.reduce((sum, a) => sum + a.balance, 0);

  return (
    <View className="flex-1 bg-surface-bright">
      <View className="bg-surface-bright pt-14 pb-3 px-margin-mobile" style={{ shadowColor: '#000', shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.04, elevation: 4 }}>
        <View className="flex-row items-center justify-between">
          <View className="flex-row items-center gap-3">
            <Pressable onPress={() => router.back()} className="w-9 h-9 rounded-xl bg-surface-variant items-center justify-center active:scale-90">
              <MaterialIcons name="arrow-back" size={20} color="#43474d" />
            </Pressable>
            <Text className="font-headline-md text-primary font-bold">Linked Accounts</Text>
          </View>
          <Pressable onPress={() => router.push('/(tabs)/account-link')} className="bg-primary px-4 py-2 rounded-xl active:scale-95">
            <Text className="text-on-primary font-label-md font-bold">+ Link New</Text>
          </Pressable>
        </View>
      </View>

      <ScrollView className="flex-1 px-margin-mobile" contentContainerStyle={{ paddingBottom: 120 }} showsVerticalScrollIndicator={false}>
        {loading ? (
          <View className="flex-1 items-center justify-center mt-20">
            <ActivityIndicator size="large" color="#00705e" />
          </View>
        ) : (
          <View className="mt-4 mb-6">
            <View className="bg-primary rounded-2xl p-6 mb-4 relative overflow-hidden">
              <View className="absolute -top-16 -right-16 w-40 h-40 bg-secondary/10 rounded-full" />
              <Text className="text-on-primary font-caption uppercase tracking-wider text-xs">Total Balance</Text>
              <Text className="font-display-lg text-display-lg text-white font-bold mt-1">${totalBalance.toLocaleString('en-US', { minimumFractionDigits: 2 })}</Text>
              <Text className="text-on-primary/80 text-sm mt-1">{accounts.length} linked accounts</Text>
            </View>

            <View className="bg-white border border-outline-variant/20 rounded-2xl overflow-hidden">
              <View className="px-4 py-3.5 border-b border-outline-variant/10">
                <Text className="font-label-md text-primary font-bold">Your Bank Accounts</Text>
              </View>
              {accounts.length === 0 ? (
                <View className="p-8 items-center">
                  <MaterialIcons name="account-balance" size={40} color="#c4c6ca" />
                  <Text className="text-on-surface-variant text-sm mt-2">No linked accounts yet</Text>
                </View>
              ) : (
                accounts.map((account, i) => (
                  <Pressable key={account.id} className={`flex-row items-center gap-3 p-4 ${i < accounts.length - 1 ? 'border-b border-outline-variant/10' : ''} active:scale-[0.98]`}>
                    <View className="w-12 h-12 rounded-xl bg-surface-container items-center justify-center">
                      <MaterialIcons name={(account.logo || 'account-balance') as any} size={24} color="#43474d" />
                    </View>
                    <View className="flex-1">
                      <Text className="font-label-md font-bold text-primary">{account.bank_name}</Text>
                      <Text className="text-caption text-on-surface-variant text-xs">{account.account_type} {account.account_number}</Text>
                    </View>
                    <View className="items-end">
                      <Text className="font-label-md font-bold text-primary">${account.balance.toLocaleString('en-US', { minimumFractionDigits: 2 })}</Text>
                      <Text className="text-caption text-on-surface-variant text-xs">Available</Text>
                    </View>
                  </Pressable>
                ))
              )}
            </View>

            <View className="bg-white border border-outline-variant/20 rounded-2xl p-5 mt-4">
              <View className="flex-row items-center gap-2 mb-3">
                <MaterialIcons name="info" size={16} color="#006b5a" />
                <Text className="font-label-md font-bold text-primary">Link a New Bank</Text>
              </View>
              <Text className="text-body-md text-on-surface-variant text-sm mb-4">Connect your bank accounts to get a complete view of your finances. We use bank-grade encryption (AES-256) to protect your data.</Text>
              <View className="flex-row flex-wrap" style={{ gap: 12 }}>
                <Pressable className="flex-1 min-w-[120px] flex-row items-center gap-2 p-3.5 bg-surface-container-low rounded-xl border border-outline-variant/20 active:scale-[0.98]">
                  <MaterialIcons name="account-balance" size={20} color="#43474d" />
                  <Text className="font-label-md font-bold text-primary">Plaid</Text>
                </Pressable>
                <Pressable className="flex-1 min-w-[120px] flex-row items-center gap-2 p-3.5 bg-surface-container-low rounded-xl border border-outline-variant/20 active:scale-[0.98]">
                  <MaterialIcons name="account-balance" size={20} color="#43474d" />
                  <Text className="font-label-md font-bold text-primary">MX</Text>
                </Pressable>
                <Pressable className="flex-1 min-w-[120px] flex-row items-center gap-2 p-3.5 bg-surface-container-low rounded-xl border border-outline-variant/20 active:scale-[0.98]">
                  <MaterialIcons name="sync" size={20} color="#43474d" />
                  <Text className="font-label-md font-bold text-primary">Manual Entry</Text>
                </Pressable>
              </View>
            </View>
          </View>
        )}
      </ScrollView>
    </View>
  );
}
