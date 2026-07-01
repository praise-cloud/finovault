import { useState, useEffect, useCallback } from 'react';
import { View, Text, Pressable, ScrollView, TextInput, Modal, ActivityIndicator, Alert } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { router } from 'expo-router';
import * as SavingsService from '@/lib/api/services/savings';
import { formatCurrency } from '@/lib/format-currency';
import { convertAmount } from '@/lib/format-currency';
import { useSettingsStore } from '@/stores/settings-store';

export default function SavingsGoalsScreen() {
  const [goals, setGoals] = useState<SavingsService.SavingsGoal[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [showAddModal, setShowAddModal] = useState(false);
  const { currency } = useSettingsStore();

  const load = useCallback(async () => {
    setIsLoading(true);
    try {
      const data = await SavingsService.listGoals();
      setGoals(data || []);
    } catch (e: any) {
      console.error('Failed to load goals', e.message);
    }
    setIsLoading(false);
  }, []);

  useEffect(() => { load(); }, [load]);

  const handleDelete = (id: string) => {
    Alert.alert('Delete Goal', 'Are you sure?', [
      { text: 'Cancel', style: 'cancel' },
      { text: 'Delete', style: 'destructive', onPress: async () => {
        await SavingsService.deleteGoal(id);
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
            <Text className="font-headline-md text-primary font-bold">Savings Goals</Text>
          </View>
          <Pressable onPress={() => setShowAddModal(true)} className="bg-primary px-4 py-2 rounded-xl flex-row items-center gap-1 active:scale-90">
            <MaterialIcons name="add" size={20} color="#fff" />
            <Text className="text-on-primary font-label-md">Goal</Text>
          </Pressable>
        </View>
      </View>

      <ScrollView className="flex-1 px-margin-mobile" contentContainerStyle={{ paddingBottom: 120 }}>
        {isLoading ? (
          <View className="flex-1 items-center justify-center py-20">
            <ActivityIndicator size="large" color="#006b5a" />
          </View>
        ) : goals.length === 0 ? (
          <View className="flex-1 items-center justify-center py-20">
            <MaterialIcons name="savings" size={64} color="#c4c7cb" />
            <Text className="text-on-surface-variant text-body-md mt-4">No savings goals yet.</Text>
            <Pressable onPress={() => setShowAddModal(true)} className="bg-primary px-6 py-3 rounded-xl mt-4 active:scale-95">
              <Text className="text-on-primary font-label-md">Create Goal</Text>
            </Pressable>
          </View>
        ) : (
          <View className="mt-4 gap-4">
            {goals.map((goal) => {
              const pct = goal.target_amount > 0 ? Math.min((goal.current_amount / goal.target_amount) * 100, 100) : 0;
              return (
                <View key={goal.id} className="bg-surface-container-lowest border border-outline-variant/20 rounded-2xl p-5">
                  <View className="flex-row justify-between items-start mb-3">
                    <View className="flex-1">
                      <View className="flex-row items-center gap-2">
                        <Text className="font-headline-md text-primary font-bold">{goal.name}</Text>
                        {goal.status === 'completed' && (
                          <MaterialIcons name="check-circle" size={18} color="#006b5a" />
                        )}
                      </View>
                      <Text className="text-caption text-on-surface-variant mt-1">
                        {goal.goal_type === 'rainy_day' ? 'Rainy Day Fund' : 'General Goal'} • {goal.status}
                      </Text>
                    </View>
                    <Pressable onPress={() => handleDelete(goal.id)} className="active:scale-90">
                      <MaterialIcons name="delete-outline" size={20} color="#ba1a1a" />
                    </Pressable>
                  </View>

                  <View className="flex-row justify-between mb-2">
                    <Text className="font-label-md text-primary">
                      {formatCurrency(convertAmount(goal.current_amount, currency.rate), currency.code)}
                    </Text>
                    <Text className="font-label-md text-on-surface-variant">
                      of {formatCurrency(convertAmount(goal.target_amount, currency.rate), currency.code)}
                    </Text>
                  </View>

                  <View className="w-full bg-surface-container rounded-full h-3 overflow-hidden">
                    <View className="h-full rounded-full bg-secondary" style={{ width: `${pct}%` }} />
                  </View>
                  <Text className="text-caption text-on-surface-variant mt-1">{Math.round(pct)}% complete</Text>
                </View>
              );
            })}
          </View>
        )}
      </ScrollView>

      <AddGoalModal
        visible={showAddModal}
        onClose={() => setShowAddModal(false)}
        onSaved={() => { setShowAddModal(false); load(); }}
      />
    </View>
  );
}

function AddGoalModal({ visible, onClose, onSaved }: { visible: boolean; onClose: () => void; onSaved: () => void }) {
  const [name, setName] = useState('');
  const [targetAmount, setTargetAmount] = useState('');
  const [currentAmount, setCurrentAmount] = useState('');
  const [goalType, setGoalType] = useState<'rainy_day' | 'general'>('general');
  const [saving, setSaving] = useState(false);

  const handleSave = async () => {
    if (!name || !targetAmount) {
      Alert.alert('Required', 'Name and target amount are required.');
      return;
    }
    setSaving(true);
    try {
      await SavingsService.createGoal({
        name,
        target_amount: parseFloat(targetAmount),
        current_amount: currentAmount ? parseFloat(currentAmount) : 0,
        goal_type: goalType,
      });
      onSaved();
      setName('');
      setTargetAmount('');
      setCurrentAmount('');
    } catch (e: any) {
      Alert.alert('Error', e.message);
    }
    setSaving(false);
  };

  return (
    <Modal visible={visible} transparent animationType="slide" onRequestClose={onClose}>
      <Pressable className="flex-1 bg-black/40" onPress={onClose}>
        <Pressable className="flex-1 justify-end" onPress={() => {}}>
          <Pressable className="bg-white rounded-t-3xl p-6" onPress={() => {}}>
            <View className="items-center pt-3 pb-1">
              <View className="w-10 h-1 rounded-full bg-outline/40" />
            </View>
            <Text className="font-headline-md text-primary font-bold mb-4">Create Savings Goal</Text>

            <TextInput
              placeholder="Goal name"
              value={name}
              onChangeText={setName}
              className="bg-surface-container rounded-xl px-4 py-3 mb-3 font-label-md"
            />
            <TextInput
              placeholder="Target amount"
              value={targetAmount}
              onChangeText={setTargetAmount}
              keyboardType="decimal-pad"
              className="bg-surface-container rounded-xl px-4 py-3 mb-3 font-label-md"
            />
            <TextInput
              placeholder="Current amount (optional)"
              value={currentAmount}
              onChangeText={setCurrentAmount}
              keyboardType="decimal-pad"
              className="bg-surface-container rounded-xl px-4 py-3 mb-3 font-label-md"
            />

            <View className="flex-row gap-2 mb-4">
              {(['general', 'rainy_day'] as const).map((t) => (
                <Pressable key={t} onPress={() => setGoalType(t)} className={`px-4 py-2 rounded-xl ${goalType === t ? 'bg-primary' : 'bg-surface-container'}`}>
                  <Text className={`font-label-md ${goalType === t ? 'text-on-primary' : 'text-on-surface-variant'}`}>
                    {t === 'rainy_day' ? 'Rainy Day' : 'General'}
                  </Text>
                </Pressable>
              ))}
            </View>

            <Pressable
              onPress={handleSave}
              disabled={saving}
              className="bg-primary py-3 rounded-xl items-center mt-2 active:scale-95"
            >
              <Text className="text-on-primary font-label-md font-bold">
                {saving ? 'Creating...' : 'Create Goal'}
              </Text>
            </Pressable>
          </Pressable>
        </Pressable>
      </Pressable>
    </Modal>
  );
}
