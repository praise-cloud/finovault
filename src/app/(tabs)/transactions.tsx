import { useState, useEffect, useCallback } from 'react';
import { View, Text, Pressable, ScrollView, TextInput, Modal, ActivityIndicator, Alert } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { router } from 'expo-router';
import * as TransactionsService from '@/lib/api/services/transactions';
import { formatCurrency } from '@/lib/format-currency';
import { convertAmount } from '@/lib/format-currency';
import { useSettingsStore } from '@/stores/settings-store';

export default function TransactionsScreen() {
  const [transactions, setTransactions] = useState<TransactionsService.Transaction[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [showAddModal, setShowAddModal] = useState(false);
  const [showFilter, setShowFilter] = useState(false);
  const [filterType, setFilterType] = useState<string>('');
  const [filterStatus, setFilterStatus] = useState<string>('');
  const { currency } = useSettingsStore();

  const load = useCallback(async () => {
    setIsLoading(true);
    try {
      const params: any = {};
      if (filterType) params.type = filterType;
      if (filterStatus) params.status = filterStatus;
      const res = await TransactionsService.listTransactions(params);
      setTransactions(res.data);
    } catch (e: any) {
      console.error('Failed to load transactions', e.message);
    }
    setIsLoading(false);
  }, [filterType, filterStatus]);

  useEffect(() => { load(); }, [load]);

  const handleDelete = (id: string) => {
    Alert.alert('Delete Transaction', 'Are you sure?', [
      { text: 'Cancel', style: 'cancel' },
      { text: 'Delete', style: 'destructive', onPress: async () => {
        await TransactionsService.deleteTransaction(id);
        load();
      }},
    ]);
  };

  return (
    <View className="flex-1 bg-surface-bright">
      <View className="bg-surface-bright pt-14 pb-3 px-margin-mobile" style={{ shadowColor: '#000', shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.04, elevation: 4 }}>
        <View className="flex-row items-center justify-between">
          <View className="flex-row items-center gap-3">
            <Pressable onPress={() => router.back()} className="active:scale-90">
              <MaterialIcons name="arrow-back" size={24} color="#000f22" />
            </Pressable>
            <Text className="font-headline-md text-primary font-bold">Transactions</Text>
          </View>
          <View className="flex-row items-center gap-3">
            <Pressable onPress={() => setShowFilter(true)} className="active:scale-90">
              <MaterialIcons name="filter-list" size={24} color="#43474d" />
            </Pressable>
            <Pressable onPress={() => setShowAddModal(true)} className="bg-primary px-4 py-2 rounded-xl active:scale-90">
              <MaterialIcons name="add" size={20} color="#fff" />
            </Pressable>
          </View>
        </View>
      </View>

      <ScrollView className="flex-1 px-margin-mobile" contentContainerStyle={{ paddingBottom: 120 }}>
        {isLoading ? (
          <View className="flex-1 items-center justify-center py-20">
            <ActivityIndicator size="large" color="#006b5a" />
          </View>
        ) : transactions.length === 0 ? (
          <View className="flex-1 items-center justify-center py-20">
            <MaterialIcons name="receipt-long" size={64} color="#c4c7cb" />
            <Text className="text-on-surface-variant text-body-md mt-4">No transactions yet.</Text>
            <Pressable onPress={() => setShowAddModal(true)} className="bg-primary px-6 py-3 rounded-xl mt-4 active:scale-95">
              <Text className="text-on-primary font-label-md">Add Transaction</Text>
            </Pressable>
          </View>
        ) : (
          <View className="mt-4 gap-3">
            {transactions.map((tx) => (
              <View key={tx.id} className="bg-surface-container-lowest border border-outline-variant/20 rounded-2xl p-4 flex-row items-center gap-3">
                <View className={`w-10 h-10 rounded-full items-center justify-center ${tx.type === 'income' ? 'bg-secondary-container' : tx.type === 'expense' ? 'bg-error-container' : 'bg-primary-container'}`}>
                  <MaterialIcons
                    name={tx.type === 'income' ? 'arrow-downward' : tx.type === 'expense' ? 'arrow-upward' : 'swap-horiz'}
                    size={20}
                    color={tx.type === 'income' ? '#00705e' : tx.type === 'expense' ? '#ba1a1a' : '#006b5a'}
                  />
                </View>
                <View className="flex-1">
                  <View className="flex-row justify-between items-start">
                    <View className="flex-1">
                      <Text className="font-label-md font-bold text-primary">{tx.description}</Text>
                      <Text className="text-caption text-on-surface-variant">
                        {tx.merchant || tx.category || 'General'} {tx.status === 'flagged' ? '• Flagged' : ''}
                      </Text>
                    </View>
                    <Text className={`font-label-md font-bold ${tx.type === 'income' ? 'text-secondary' : 'text-on-surface'}`}>
                      {tx.type === 'income' ? '+' : '-'}{formatCurrency(convertAmount(tx.amount, currency.rate), currency.code)}
                    </Text>
                  </View>
                  <View className="flex-row justify-between items-center mt-2">
                    <Text className="text-caption text-on-surface-variant">{new Date(tx.date).toLocaleDateString()}</Text>
                    <View className="flex-row gap-2">
                      <Pressable onPress={() => handleDelete(tx.id)} className="active:scale-90">
                        <MaterialIcons name="delete-outline" size={18} color="#ba1a1a" />
                      </Pressable>
                    </View>
                  </View>
                </View>
              </View>
            ))}
          </View>
        )}
      </ScrollView>

      <AddTransactionModal
        visible={showAddModal}
        onClose={() => setShowAddModal(false)}
        onSaved={() => { setShowAddModal(false); load(); }}
      />

      <FilterModal
        visible={showFilter}
        onClose={() => setShowFilter(false)}
        filterType={filterType}
        filterStatus={filterStatus}
        onApply={(t, s) => { setFilterType(t); setFilterStatus(s); setShowFilter(false); }}
      />
    </View>
  );
}

function AddTransactionModal({ visible, onClose, onSaved }: { visible: boolean; onClose: () => void; onSaved: () => void }) {
  const [type, setType] = useState<'income' | 'expense' | 'transfer'>('expense');
  const [amount, setAmount] = useState('');
  const [description, setDescription] = useState('');
  const [category, setCategory] = useState('');
  const [merchant, setMerchant] = useState('');
  const [saving, setSaving] = useState(false);

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
      <Pressable className="flex-1 bg-black/40" onPress={onClose}>
        <Pressable className="flex-1 justify-end" onPress={() => {}}>
          <Pressable className="bg-white rounded-t-3xl p-6" style={{ maxHeight: '80%' }} onPress={() => {}}>
            <View className="items-center pt-3 pb-1">
              <View className="w-10 h-1 rounded-full bg-outline/40" />
            </View>
            <Text className="font-headline-md text-primary font-bold mb-4">Add Transaction</Text>

            <View className="flex-row gap-2 mb-4">
              {(['expense', 'income', 'transfer'] as const).map((t) => (
                <Pressable key={t} onPress={() => setType(t)} className={`px-4 py-2 rounded-xl ${type === t ? 'bg-primary' : 'bg-surface-container'}`}>
                  <Text className={`font-label-md ${type === t ? 'text-on-primary' : 'text-on-surface-variant'}`}>
                    {t.charAt(0).toUpperCase() + t.slice(1)}
                  </Text>
                </Pressable>
              ))}
            </View>

            <TextInput
              placeholder="Amount"
              value={amount}
              onChangeText={setAmount}
              keyboardType="decimal-pad"
              className="bg-surface-container rounded-xl px-4 py-3 mb-3 font-label-md"
            />
            <TextInput
              placeholder="Description"
              value={description}
              onChangeText={setDescription}
              className="bg-surface-container rounded-xl px-4 py-3 mb-3 font-label-md"
            />
            <TextInput
              placeholder="Category (optional)"
              value={category}
              onChangeText={setCategory}
              className="bg-surface-container rounded-xl px-4 py-3 mb-3 font-label-md"
            />
            <TextInput
              placeholder="Merchant (optional)"
              value={merchant}
              onChangeText={setMerchant}
              className="bg-surface-container rounded-xl px-4 py-3 mb-3 font-label-md"
            />

            <Pressable
              onPress={handleSave}
              disabled={saving}
              className="bg-primary py-3 rounded-xl items-center mt-2 active:scale-95"
            >
              <Text className="text-on-primary font-label-md font-bold">
                {saving ? 'Saving...' : 'Save Transaction'}
              </Text>
            </Pressable>
          </Pressable>
        </Pressable>
      </Pressable>
    </Modal>
  );
}

function FilterModal({ visible, onClose, filterType, filterStatus, onApply }: {
  visible: boolean;
  onClose: () => void;
  filterType: string;
  filterStatus: string;
  onApply: (type: string, status: string) => void;
}) {
  const [localType, setLocalType] = useState(filterType);
  const [localStatus, setLocalStatus] = useState(filterStatus);

  return (
    <Modal visible={visible} transparent animationType="slide" onRequestClose={onClose}>
      <Pressable className="flex-1 bg-black/40" onPress={onClose}>
        <Pressable className="flex-1 justify-end" onPress={() => {}}>
          <Pressable className="bg-white rounded-t-3xl p-6" onPress={() => {}}>
            <View className="items-center pt-3 pb-1">
              <View className="w-10 h-1 rounded-full bg-outline/40" />
            </View>
            <Text className="font-headline-md text-primary font-bold mb-4">Filter Transactions</Text>

            <Text className="font-label-md font-bold mb-2">Type</Text>
            <View className="flex-row flex-wrap gap-2 mb-4">
              {['', 'income', 'expense', 'transfer'].map((t) => (
                <Pressable key={t} onPress={() => setLocalType(t)} className={`px-4 py-2 rounded-xl ${localType === t ? 'bg-primary' : 'bg-surface-container'}`}>
                  <Text className={`font-label-md ${localType === t ? 'text-on-primary' : 'text-on-surface-variant'}`}>
                    {t || 'All'}
                  </Text>
                </Pressable>
              ))}
            </View>

            <Text className="font-label-md font-bold mb-2">Status</Text>
            <View className="flex-row flex-wrap gap-2 mb-6">
              {['', 'pending', 'completed', 'flagged'].map((s) => (
                <Pressable key={s} onPress={() => setLocalStatus(s)} className={`px-4 py-2 rounded-xl ${localStatus === s ? 'bg-primary' : 'bg-surface-container'}`}>
                  <Text className={`font-label-md ${localStatus === s ? 'text-on-primary' : 'text-on-surface-variant'}`}>
                    {s || 'All'}
                  </Text>
                </Pressable>
              ))}
            </View>

            <Pressable onPress={() => onApply(localType, localStatus)} className="bg-primary py-3 rounded-xl items-center active:scale-95">
              <Text className="text-on-primary font-label-md font-bold">Apply Filters</Text>
            </Pressable>
          </Pressable>
        </Pressable>
      </Pressable>
    </Modal>
  );
}
