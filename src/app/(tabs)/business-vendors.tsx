import { useEffect, useState } from 'react';
import { ScrollView, View, Text, Pressable, ActivityIndicator, TextInput } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { router } from 'expo-router';
import { getBusinessVendors, addVendor, deleteVendor } from '@/lib/api/services/business';

export default function BusinessVendors() {
  const [loading, setLoading] = useState(true);
  const [vendors, setVendors] = useState<any[]>([]);
  const [showAdd, setShowAdd] = useState(false);
  const [newVendorName, setNewVendorName] = useState('');
  const [newVendorCategory, setNewVendorCategory] = useState('');

  const loadVendors = () => {
    setLoading(true);
    getBusinessVendors()
      .then((data: any) => setVendors(data?.vendors || []))
      .catch(() => {})
      .finally(() => setLoading(false));
  };

  useEffect(() => {
    loadVendors();
  }, []);

  const handleAdd = async () => {
    if (!newVendorName.trim()) return;
    try {
      await addVendor({ name: newVendorName, category: newVendorCategory });
      setNewVendorName('');
      setNewVendorCategory('');
      setShowAdd(false);
      loadVendors();
    } catch {}
  };

  const handleDelete = async (id: string) => {
    try {
      await deleteVendor(id);
      loadVendors();
    } catch {}
  };

  if (loading) {
    return (
      <View className="flex-1 bg-surface-bright items-center justify-center">
        <ActivityIndicator size="large" color="#006b5a" />
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
          <Text className="font-headline-md text-headline-md text-primary font-bold">Vendors</Text>
          <Pressable onPress={() => setShowAdd(true)} className="w-10 h-10 rounded-full bg-secondary items-center justify-center active:scale-90">
            <MaterialIcons name="add" size={20} color="#ffffff" />
          </Pressable>
        </View>
      </View>

      <ScrollView className="flex-1 px-margin-mobile" contentContainerStyle={{ paddingBottom: 120 }}>
        <View className="mt-6 mb-8">
          <Text className="font-headline-lg text-headline-lg text-primary mb-2">Vendor Management</Text>
          <Text className="font-body-md text-body-md text-on-surface-variant">{vendors.length} vendor{vendors.length !== 1 ? 's' : ''} registered.</Text>
        </View>

        {showAdd && (
          <View className="bg-surface-container-low rounded-2xl p-5 mb-6" style={{ elevation: 4, shadowColor: '#000', shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.08 }}>
            <Text className="font-label-md text-label-md text-primary font-bold mb-4">Add Vendor</Text>
            <TextInput
              className="bg-surface-bright border border-outline-variant rounded-xl px-4 py-3 font-body-md text-body-md text-primary mb-3"
              placeholder="Vendor name"
              placeholderTextColor="#74777e"
              value={newVendorName}
              onChangeText={setNewVendorName}
            />
            <TextInput
              className="bg-surface-bright border border-outline-variant rounded-xl px-4 py-3 font-body-md text-body-md text-primary mb-4"
              placeholder="Category (optional)"
              placeholderTextColor="#74777e"
              value={newVendorCategory}
              onChangeText={setNewVendorCategory}
            />
            <View className="flex-row gap-3">
              <Pressable onPress={() => { setShowAdd(false); setNewVendorName(''); setNewVendorCategory(''); }} className="flex-1 py-3 rounded-xl border border-outline-variant items-center">
                <Text className="font-label-md text-label-md text-on-surface">Cancel</Text>
              </Pressable>
              <Pressable onPress={handleAdd} className="flex-1 py-3 rounded-xl bg-secondary items-center">
                <Text className="font-label-md text-label-md text-white font-bold">Save</Text>
              </Pressable>
            </View>
          </View>
        )}

        {vendors.length === 0 && !showAdd && (
          <View className="items-center py-16">
            <MaterialIcons name="store" size={48} color="#c4c6ca" />
            <Text className="font-body-md text-body-md text-on-surface-variant mt-4">No vendors yet. Tap + to add one.</Text>
          </View>
        )}

        <View className="gap-3">
          {vendors.map((vendor: any, i: number) => (
            <View key={vendor.id || i} className="bg-surface-container-low rounded-2xl p-4 flex-row items-center gap-4" style={{ elevation: 2, shadowColor: '#000', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.06 }}>
              <View className="w-12 h-12 rounded-full bg-secondary-container items-center justify-center">
                <MaterialIcons name="business" size={22} color="#00705e" />
              </View>
              <View className="flex-1">
                <Text className="font-label-md text-label-md text-primary font-bold">{vendor.name}</Text>
                {vendor.category && <Text className="text-caption text-on-surface-variant">{vendor.category}</Text>}
              </View>
              <Pressable onPress={() => handleDelete(vendor.id)} className="w-8 h-8 rounded-full bg-error-container items-center justify-center" style={{ backgroundColor: '#9f4e3c20' }}>
                <MaterialIcons name="delete-outline" size={16} color="#9f4e3c" />
              </Pressable>
            </View>
          ))}
        </View>
      </ScrollView>
    </View>
  );
}
