import { useState, useEffect, useCallback, useRef } from 'react';
import { View, Text, Pressable, ScrollView, TextInput, Modal, ActivityIndicator, Alert, useColorScheme } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import * as TransactionsService from '@/lib/api/services/transactions';
import { formatCurrency, convertAmount } from '@/lib/format-currency';
import { useSettingsStore } from '@/stores/settings-store';
import { FlatCard } from '@/components/flat-card';

const FILTERS = ['All', 'Income', 'Expense', 'Transfer', 'Pending', 'Completed', 'Flagged'];

function getFilterParam(label: string): { type: string; status: string } {
  const lower = label.toLowerCase();
  if (lower === 'all') return { type: '', status: '' };
  if (lower === 'income') return { type: 'income', status: '' };
  if (lower === 'expense') return { type: 'expense', status: '' };
  if (lower === 'transfer') return { type: 'transfer', status: '' };
  if (lower === 'pending') return { type: '', status: 'pending' };
  if (lower === 'completed') return { type: '', status: 'completed' };
  if (lower === 'flagged') return { type: '', status: 'flagged' };
  return { type: '', status: '' };
}

function getIconForTx(tx: any): keyof typeof MaterialIcons.glyphMap {
  if (tx.type === 'income') return 'arrow-downward';
  if (tx.type === 'expense') return 'arrow-upward';
  return 'swap-horiz';
}

export default function TransactionsScreen() {
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';
  const [transactions, setTransactions] = useState<TransactionsService.Transaction[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [activeFilter, setActiveFilter] = useState('All');
  const [showAddModal, setShowAddModal] = useState(false);
  const { currency } = useSettingsStore();
  const abortRef = useRef<AbortController | null>(null);

  const filterParams = getFilterParam(activeFilter);

  const load = useCallback(async () => {
    abortRef.current?.abort();
    const controller = new AbortController();
    abortRef.current = controller;
    setIsLoading(true);
    try {
      const params: any = {};
      if (filterParams.type) params.type = filterParams.type;
      if (filterParams.status) params.status = filterParams.status;
      if (search.trim()) params.search = search.trim();
      const res = await TransactionsService.listTransactions(params, { signal: controller.signal });
      if (controller.signal.aborted) return;
      const items = Array.isArray(res) ? res : (res?.data ?? []);
      setTransactions(items);
    } catch (e: any) {
      if (e?.name === 'AbortError') return;
      console.error('Failed to load transactions', e.message);
    }
    setIsLoading(false);
  }, [filterParams.type, filterParams.status, search]);

  useEffect(() => { load(); return () => abortRef.current?.abort(); }, [load]);

  const handleDelete = (id: string) => {
    Alert.alert('Delete Transaction', 'Are you sure?', [
      { text: 'Cancel', style: 'cancel' },
      { text: 'Delete', style: 'destructive', onPress: async () => {
        try {
          await TransactionsService.deleteTransaction(id);
        } catch (e: any) {
          Alert.alert('Error', e.message || 'Failed to delete');
        }
        load();
      }},
    ]);
  };

  const bg = isDark ? '#08142E' : '#F7F9FC';
  const textColor = isDark ? '#FFFFFF' : '#1A1A1A';
  const mutedColor = isDark ? 'rgba(255,255,255,0.5)' : '#6B6F76';

  return (
    <View className="flex-1" style={{ backgroundColor: bg }}>
      {/* Header */}
      <View className="pt-14 pb-2 px-margin-mobile" style={{ backgroundColor: bg }}>
        <View className="flex-row items-center justify-between">
          <View className="flex-row items-center gap-3">
            <Pressable onPress={() => {}} className="active:scale-90">
              <MaterialIcons name="arrow-back" size={24} color={isDark ? '#FFFFFF' : '#1A1A1A'} />
            </Pressable>
            <Text className="font-body-bold" style={{ fontSize: 22, color: textColor }}>Transactions</Text>
          </View>
          <Pressable onPress={() => setShowAddModal(true)} className="active:scale-90"
            style={{ backgroundColor: 'rgba(8,20,46,0.08)', borderWidth: 1.5, borderColor: '#08142E', borderRadius: 9999, paddingHorizontal: 16, paddingVertical: 8 }}
          >
            <View className="flex-row items-center gap-1">
              <MaterialIcons name="add" size={18} color="#08142E" />
              <Text className="font-body-semibold" style={{ fontSize: 13, color: '#08142E' }}>Add</Text>
            </View>
          </Pressable>
        </View>

        {/* Search bar */}
        <View
          className="flex-row items-center px-4 mt-3"
          style={{
            backgroundColor: isDark ? 'rgba(255,255,255,0.08)' : '#EEF0F5',
            borderRadius: 14,
            height: 42,
          }}
        >
          <MaterialIcons name="search" size={18} color={isDark ? 'rgba(255,255,255,0.4)' : '#9ea0a5'} />
          <TextInput
            placeholder="Search transactions"
            placeholderTextColor={isDark ? 'rgba(255,255,255,0.3)' : '#9ea0a5'}
            value={search}
            onChangeText={setSearch}
            className="flex-1 ml-2"
            style={{ fontSize: 15, fontFamily: 'Montserrat_400Regular', color: textColor }}
          />
          {search.length > 0 && (
            <Pressable onPress={() => setSearch('')}>
              <MaterialIcons name="close" size={18} color={mutedColor} />
            </Pressable>
          )}
        </View>

        {/* Filter chips */}
        <ScrollView horizontal showsHorizontalScrollIndicator={false} className="mt-3 pb-1" contentContainerStyle={{ gap: 8 }}>
          {FILTERS.map((f) => {
            const isActive = activeFilter === f;
            return (
              <Pressable
                key={f}
                onPress={() => setActiveFilter(f)}
                className="px-4 py-2 active:scale-[0.97]"
                style={{
                  borderRadius: 9999,
                  backgroundColor: isActive ? 'rgba(8,20,46,0.08)' : isDark ? 'rgba(255,255,255,0.08)' : '#EEF0F5',
                  borderWidth: isActive ? 0 : 1,
                  borderColor: isActive ? '#08142E' : isDark ? 'rgba(255,255,255,0.1)' : '#E4E7EE',
                }}
              >
                <Text
                  className="font-body-medium"
                  style={{
                    fontSize: 13,
                    color: isActive ? '#08142E' : mutedColor,
                  }}
                >
                  {f}
                </Text>
              </Pressable>
            );
          })}
        </ScrollView>
      </View>

      {/* Transaction list */}
      <ScrollView className="flex-1 px-margin-mobile" contentContainerStyle={{ paddingBottom: 120 }} showsVerticalScrollIndicator={false}>
        {isLoading ? (
          <View className="items-center justify-center py-20">
            <ActivityIndicator size="large" color="#08142E" />
          </View>
        ) : transactions.length === 0 ? (
          <View className="items-center justify-center py-20">
            <MaterialIcons name="receipt-long" size={56} color={isDark ? 'rgba(255,255,255,0.2)' : '#c4c7cb'} />
            <Text className="font-body" style={{ fontSize: 15, color: mutedColor, marginTop: 12 }}>No transactions yet.</Text>
            <Pressable
              onPress={() => setShowAddModal(true)}
              className="mt-5 py-3 px-6 active:scale-95"
              style={{ backgroundColor: 'rgba(8,20,46,0.08)', borderWidth: 1.5, borderColor: '#08142E', borderRadius: 9999 }}
            >
              <Text className="font-body-semibold" style={{ fontSize: 15, color: '#08142E' }}>Add Transaction</Text>
            </Pressable>
          </View>
        ) : (
          <View className="mt-2">
            {transactions.map((tx: any) => {
              const icon = getIconForTx(tx);
              const iconColor = tx.type === 'income' ? '#2E7D5B' : tx.type === 'expense' ? '#BA1A1A' : '#08142E';
              const amountStr = `${tx.type === 'income' ? '+' : '-'}${formatCurrency(convertAmount(tx.amount, currency.rate), currency.code)}`;
              const amountColor = tx.type === 'income' ? '#2E7D5B' : textColor;
              const detail = [tx.merchant || tx.category || 'General', tx.status === 'flagged' ? '🚩 Flagged' : ''].filter(Boolean).join(' • ');
              return (
                <View key={tx.id}>
                  <View
                    className="flex-row items-center py-3.5"
                    style={{
                      borderBottomWidth: 1,
                      borderBottomColor: isDark ? 'rgba(255,255,255,0.06)' : 'rgba(0,0,0,0.04)',
                    }}
                  >
                    <View
                      className="w-8 h-8 rounded-full items-center justify-center mr-3"
                      style={{ backgroundColor: isDark ? 'rgba(255,255,255,0.08)' : '#EEF0F5' }}
                    >
                      <MaterialIcons name={icon} size={16} color={iconColor} />
                    </View>
                    <View className="flex-1">
                      <Text className="font-body-medium" style={{ fontSize: 15, color: textColor }}>
                        {tx.description}
                      </Text>
                      <Text className="font-body" style={{ fontSize: 13, color: mutedColor, marginTop: 1 }}>
                        {detail} • {new Date(tx.date).toLocaleDateString()}
                      </Text>
                    </View>
                    <Pressable onPress={() => handleDelete(tx.id)} className="pr-1 pl-3 active:scale-90">
                      <MaterialIcons name="delete-outline" size={18} color={isDark ? 'rgba(255,255,255,0.3)' : '#BA1A1A'} />
                    </Pressable>
                  </View>
                </View>
              );
            })}
          </View>
        )}
      </ScrollView>

      <AddTransactionModal
        visible={showAddModal}
        onClose={() => setShowAddModal(false)}
        onSaved={() => { setShowAddModal(false); load(); }}
        isDark={isDark}
      />
    </View>
  );
}

function AddTransactionModal({ visible, onClose, onSaved, isDark }: {
  visible: boolean;
  onClose: () => void;
  onSaved: () => void;
  isDark: boolean;
}) {
  const [type, setType] = useState<'income' | 'expense' | 'transfer'>('expense');
  const [amount, setAmount] = useState('');
  const [description, setDescription] = useState('');
  const [category, setCategory] = useState('');
  const [merchant, setMerchant] = useState('');
  const [saving, setSaving] = useState(false);
  const textColor = isDark ? '#FFFFFF' : '#1A1A1A';
  const muted = isDark ? 'rgba(255,255,255,0.5)' : '#6B6F76';
  const inputBg = isDark ? '#1A1A1A' : '#F7F9FC';
  const inputBorder = isDark ? 'rgba(255,255,255,0.12)' : '#E4E7EE';

  const handleSave = async () => {
    if (!amount || !description) {
      Alert.alert('Required', 'Amount and description are required.');
      return;
    }
    setSaving(true);
    try {
      await TransactionsService.createTransaction({
        type,
        amount: parseFloat(amount),
        description,
        category: category || undefined,
        merchant: merchant || undefined,
      });
      onSaved();
    } catch (e: any) {
      Alert.alert('Error', e.message);
    }
    setSaving(false);
  };

  return (
    <Modal visible={visible} transparent animationType="slide" onRequestClose={onClose}>
      <Pressable className="flex-1" style={{ backgroundColor: 'rgba(0,0,0,0.4)' }} onPress={onClose}>
        <Pressable className="flex-1 justify-end" onPress={() => {}}>
          <View style={{ backgroundColor: isDark ? '#1A1A1A' : '#FFFFFF', borderTopLeftRadius: 18, borderTopRightRadius: 18, padding: 24, maxHeight: '80%' }}>
            <View className="items-center pb-3">
              <View className="w-10 h-1 rounded-full" style={{ backgroundColor: isDark ? 'rgba(255,255,255,0.2)' : '#c4c6ce' }} />
            </View>
            <Text className="font-body-bold" style={{ fontSize: 20, color: textColor, marginBottom: 20 }}>Add Transaction</Text>

            {/* Type pills */}
            <View className="flex-row gap-2 mb-5">
              {(['expense', 'income', 'transfer'] as const).map((t) => (
                <Pressable
                  key={t}
                  onPress={() => setType(t)}
                  style={{
                    paddingHorizontal: 16,
                    paddingVertical: 8,
                    borderRadius: 9999,
                    backgroundColor: type === t ? 'rgba(8,20,46,0.08)' : isDark ? 'rgba(255,255,255,0.08)' : '#EEF0F5',
                  }}
                >
                  <Text className="font-body-semibold" style={{ fontSize: 13, color: type === t ? '#08142E' : muted }}>
                    {t.charAt(0).toUpperCase() + t.slice(1)}
                  </Text>
                </Pressable>
              ))}
            </View>

            <TextInput
              placeholder="Amount"
              placeholderTextColor={muted}
              value={amount}
              onChangeText={setAmount}
              keyboardType="decimal-pad"
              style={{
                backgroundColor: inputBg,
                borderWidth: 1,
                borderColor: inputBorder,
                borderRadius: 14,
                paddingHorizontal: 16,
                paddingVertical: 12,
                fontSize: 15,
                fontFamily: 'Montserrat_400Regular',
                color: textColor,
                marginBottom: 12,
              }}
            />
            <TextInput
              placeholder="Description"
              placeholderTextColor={muted}
              value={description}
              onChangeText={setDescription}
              style={{
                backgroundColor: inputBg,
                borderWidth: 1,
                borderColor: inputBorder,
                borderRadius: 14,
                paddingHorizontal: 16,
                paddingVertical: 12,
                fontSize: 15,
                fontFamily: 'Montserrat_400Regular',
                color: textColor,
                marginBottom: 12,
              }}
            />
            <TextInput
              placeholder="Category (optional)"
              placeholderTextColor={muted}
              value={category}
              onChangeText={setCategory}
              style={{
                backgroundColor: inputBg,
                borderWidth: 1,
                borderColor: inputBorder,
                borderRadius: 14,
                paddingHorizontal: 16,
                paddingVertical: 12,
                fontSize: 15,
                fontFamily: 'Montserrat_400Regular',
                color: textColor,
                marginBottom: 12,
              }}
            />
            <TextInput
              placeholder="Merchant (optional)"
              placeholderTextColor={muted}
              value={merchant}
              onChangeText={setMerchant}
              style={{
                backgroundColor: inputBg,
                borderWidth: 1,
                borderColor: inputBorder,
                borderRadius: 14,
                paddingHorizontal: 16,
                paddingVertical: 12,
                fontSize: 15,
                fontFamily: 'Montserrat_400Regular',
                color: textColor,
                marginBottom: 12,
              }}
            />

            <Pressable
              onPress={handleSave}
              disabled={saving}
              className="w-full py-3.5 items-center mt-2 active:scale-[0.98]"
              style={{ backgroundColor: 'rgba(8,20,46,0.08)', borderWidth: 1.5, borderColor: '#08142E', borderRadius: 9999 }}
            >
              <Text className="font-body-semibold" style={{ fontSize: 15, color: '#08142E' }}>
                {saving ? 'Saving...' : 'Save Transaction'}
              </Text>
            </Pressable>
          </View>
        </Pressable>
      </Pressable>
    </Modal>
  );
}
