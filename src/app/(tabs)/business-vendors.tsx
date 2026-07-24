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
        <ActivityIndicator size="large" color="#08142E" />
      </View>
    );
  }

  return (
    <View className="flex-1 bg-surface-bright">
      <View className="pt-14 pb-3 px-margin-mobile bg-surface-bright" style={{ boxShadow: '0 4px 4px rgba(0,0,0,0.04)', elevation: 4 }}>
        <View className="flex-row items-center justify-between">
          <Pressable onPress={() => router.back()} className="w-10 h-10 rounded-full bg-surface-container items-center justify-center active:scale-90">
            <MaterialIcons name="arrow-back" size={20} color="#181c1e" />
          </Pressable>
          <Text className="font-body-bold text-[#1A1A1A] font-bold" style={{ fontSize: 20 }}>Vendors</Text>
          <Pressable onPress={() => setShowAdd(true)} className="w-10 h-10 rounded-full items-center justify-center active:scale-90" style={{ borderWidth: 1.5, borderColor: '#08142E', backgroundColor: 'transparent' }}>
            <MaterialIcons name="add" size={20} color="#08142E" />
          </Pressable>
        </View>
      </View>

      <ScrollView className="flex-1 px-margin-mobile" contentContainerStyle={{ paddingBottom: 120 }}>
        <View className="mt-6 mb-8">
          <Text className="font-body-bold text-[#1A1A1A] mb-2" style={{ fontSize: 28 }}>Vendor Management</Text>
          <Text className="text-[#6B6F76]" style={{ fontSize: 16 }}>{vendors.length} vendor{vendors.length !== 1 ? 's' : ''} registered.</Text>
        </View>

        {showAdd && (
          <View className="bg-surface-container-low rounded-2xl p-5 mb-6" style={{ boxShadow: '0 4px 4px rgba(0,0,0,0.08)', elevation: 4 }}>
            <Text className="font-body-semibold text-[#1A1A1A] font-bold mb-4" style={{ fontSize: 14 }}>Add Vendor</Text>
            <TextInput
              className="bg-surface-bright border border-[#E4E7EE] rounded-[14px] px-4 py-3 font-body-md text-[#1A1A1A] mb-3"
              placeholder="Vendor name"
              placeholderTextColor="#74777e"
              value={newVendorName}
              onChangeText={setNewVendorName}
            />
            <TextInput
              className="bg-surface-bright border border-[#E4E7EE] rounded-[14px] px-4 py-3 font-body-md text-[#1A1A1A] mb-4"
              placeholder="Category (optional)"
              placeholderTextColor="#74777e"
              value={newVendorCategory}
              onChangeText={setNewVendorCategory}
            />
            <View className="flex-row gap-3">
              <Pressable onPress={() => { setShowAdd(false); setNewVendorName(''); setNewVendorCategory(''); }} className="flex-1 py-3 rounded-full border border-[#E4E7EE] items-center">
                <Text className="font-body-semibold text-on-surface" style={{ fontSize: 14 }}>Cancel</Text>
              </Pressable>
              <Pressable onPress={handleAdd} className="flex-1 py-3 rounded-full items-center" style={{ backgroundColor: 'rgba(8,20,46,0.08)', borderWidth: 1.5, borderColor: '#08142E' }}>
                <Text className="font-body-semibold text-[#08142E] font-bold" style={{ fontSize: 14 }}>Save</Text>
              </Pressable>
            </View>
          </View>
        )}

        {vendors.length === 0 && !showAdd && (
          <View className="items-center py-16">
            <MaterialIcons name="store" size={48} color="#c4c6ca" />
            <Text className="text-[#6B6F76] mt-4" style={{ fontSize: 16 }}>No vendors yet. Tap + to add one.</Text>
          </View>
        )}

        <View className="gap-3">
          {vendors.map((vendor: any, i: number) => (
            <View key={vendor.id || i} className="bg-[#EEF0F5] rounded-2xl p-4 flex-row items-center gap-4" style={{ boxShadow: '0 2px 4px rgba(0,0,0,0.06)', elevation: 2 }}>
              <View className="w-12 h-12 rounded-full bg-secondary-container items-center justify-center">
                <MaterialIcons name="business" size={22} color="#1A1A1A" />
              </View>
              <View className="flex-1">
                <Text className="font-body-semibold text-[#1A1A1A] font-bold" style={{ fontSize: 14 }}>{vendor.name}</Text>
                {vendor.category && <Text className="font-body text-[#6B6F76]" style={{ fontSize: 12 }}>{vendor.category}</Text>}
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
