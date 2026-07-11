import { useState, useEffect } from 'react';
import { ScrollView, View, Text, Pressable, ActivityIndicator, TextInput, Modal, Alert } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import * as ImagePicker from 'expo-image-picker';
import { useDashboardStore } from '@/stores/dashboard-store';
import { useAuthStore } from '@/stores/auth-store';
import { router } from 'expo-router';
import { NotificationIcon, NotificationModal } from '@/components/notification-modal';
import { UserAvatar } from '@/components/user-avatar';
import { useSettingsStore, CURRENCIES, LOCATIONS, LANGUAGES } from '@/stores/settings-store';
import { useNotificationStore } from '@/stores/notification-store';
import * as ProfileService from '@/lib/api/services/profile';

const SETTINGS = [
  { icon: 'person' as const, label: 'Personal Info', route: null, active: true },
  { icon: 'security' as const, label: 'Security', route: '/(tabs)/security' as const, active: false },
  { icon: 'account-balance' as const, label: 'Linked Accounts', route: '/(tabs)/linked-accounts' as const, active: false },
  { icon: 'privacy-tip' as const, label: 'Data Privacy', route: '/(tabs)/data-privacy' as const, active: false },
  { icon: 'notifications' as const, label: 'Notifications', route: null, active: false },
];

export default function Profile() {
  const data = useDashboardStore((s) => s.profileData);
  const isLoading = useDashboardStore((s) => s.isLoading);
  const load = useDashboardStore((s) => s.loadProfileData);
  const signOut = useAuthStore((s) => s.signOut);
  const { currency, location, language, setCurrency, setLocation, setLanguage } = useSettingsStore();
  const { count: notifCount, open: openNotifications, visible: notifVisible, close: closeNotifications } = useNotificationStore();
  const [editVisible, setEditVisible] = useState(false);
  const [editName, setEditName] = useState('');
  const [editEmail, setEditEmail] = useState('');
  const [editPhone, setEditPhone] = useState('');
  const [activeSection, setActiveSection] = useState('Personal Info');
  const [showCurrencyPicker, setShowCurrencyPicker] = useState(false);
  const [showLocationPicker, setShowLocationPicker] = useState(false);
  const [showLanguagePicker, setShowLanguagePicker] = useState(false);

  const user = useAuthStore((s) => s.user);

  useEffect(() => { load(); }, [load]);

  const handleSaveProfile = async () => {
    try {
      await ProfileService.updateProfile(user?.id, {
        full_name: editName,
        email: editEmail,
        phone: editPhone,
      });
      setEditVisible(false);
      load();
    } catch (e: any) {
      Alert.alert('Error', e.message || 'Failed to save profile');
    }
  };

  const handleSignOut = async () => {
    await signOut();
    router.replace('/');
  };

  const setAvatarUri = useAuthStore((s) => s.setAvatarUri);

  const pickImage = async () => {
    const { status } = await ImagePicker.requestMediaLibraryPermissionsAsync();
    if (status !== 'granted') {
      Alert.alert('Permission Required', 'Camera roll permission is needed to change your avatar.');
      return;
    }
    const result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ['images'],
      allowsEditing: true,
      aspect: [1, 1],
      quality: 0.8,
    });
    if (!result.canceled && result.assets[0]) {
      setAvatarUri(result.assets[0].uri);
    }
  };

  const openEdit = () => {
    if (!data) return;
    setEditName(data.profile.full_name);
    setEditEmail(data.profile.email);
    setEditPhone(data.profile.phone || '');
    setEditVisible(true);
  };

  if (!data) {
    return <View className="flex-1 bg-surface-bright items-center justify-center"><ActivityIndicator size="large" color="#006b5a" /></View>;
  }

  const d = {
    ...data,
    plan: data.plan || { name: 'Free Plan', price: 0, billing: 'month' },
    security: data.security || { identity_verified: false, encryption_level: 'AES-128', last_login: new Date().toISOString(), active_devices: 0, score: 0 },
    profile: data.profile || { full_name: 'User', email: '', phone: null, account_id: 'N/A' },
    linked_accounts: data.linked_accounts || [],
  };

  return (
    <View className="flex-1 bg-surface-bright">
      <View className="bg-surface-bright pt-14 pb-3 px-margin-mobile md:px-margin-desktop" style={{ elevation: 4, shadowColor: '#000', shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.04 }}>
        <View className="flex-row items-center justify-between">
          <View className="flex-row items-center gap-3">
            <View className="w-9 h-9 rounded-xl bg-primary items-center justify-center">
              <Text className="text-on-primary font-bold text-sm">P</Text>
            </View>
            <Text className="font-headline-md text-primary font-bold">Profile</Text>
          </View>
          <View className="flex-row items-center gap-3">
            <NotificationIcon onPress={openNotifications} count={notifCount} />
            <UserAvatar size={36} showBorder />
          </View>
        </View>
      </View>

      <ScrollView className="flex-1 px-margin-mobile md:px-margin-desktop" contentContainerStyle={{ paddingBottom: 120 }} showsVerticalScrollIndicator={false}>
        <View className="bg-[#001f1a] rounded-2xl overflow-hidden p-6 mt-4 mb-4 relative">
          <View className="absolute -top-16 -right-16 w-40 h-40 bg-secondary/10 rounded-full" />
          <View className="flex-row items-center gap-4">
            <Pressable onPress={pickImage} className="w-20 h-20 rounded-full border-4 border-white/20 overflow-hidden">
              <UserAvatar size={80} name={d.profile.full_name} />
            </Pressable>
            <View className="flex-1">
              <View className="flex-row items-center gap-2">
                <Text className="font-headline-md text-white font-bold">{d.profile.full_name}</Text>
                <MaterialIcons name="verified" size={16} color="#58fbda" />
              </View>
              <View className="flex-row items-center gap-1 mt-0.5">
                <MaterialIcons name="workspace-premium" size={12} color="#768dad" />
                <Text className="text-on-primary-container text-sm">{d.plan.name}</Text>
              </View>
              <View className="flex-row flex-wrap gap-2 mt-3">
                <View className="bg-white/10 px-3 py-0.5 rounded-full"><Text className="text-white/80 text-xs">ID: {d.profile.account_id}</Text></View>
                <View className="bg-secondary-container px-3 py-0.5 rounded-full"><Text className="text-on-secondary-container text-xs font-bold">PRO MEMBER</Text></View>
              </View>
            </View>
            <Pressable onPress={openEdit} className="bg-secondary-fixed w-10 h-10 rounded-xl items-center justify-center active:scale-90">
              <MaterialIcons name="edit" size={20} color="#00201a" />
            </Pressable>
          </View>
        </View>

        <View className="flex-col md:flex-row gap-4">
          <View className="md:w-[30%]">
            <View className="bg-white border border-outline-variant/20 rounded-2xl p-3">
              {SETTINGS.map((item) => {
                const isActive = activeSection === item.label;
                return (
                  <Pressable
                    key={item.label}
                    onPress={() => {
                      setActiveSection(item.label);
                      if (item.label === 'Notifications') openNotifications();
                      else if (item.route) router.push(item.route as any);
                    }}
                    className={`flex-row items-center gap-3 px-4 py-3.5 rounded-xl mb-1 ${isActive ? 'bg-secondary-container' : ''} active:scale-[0.98]`}
                  >
                    <MaterialIcons name={item.icon} size={20} color={isActive ? '#00705e' : '#43474d'} />
                    <Text className={`font-label-md flex-1 ${isActive ? 'text-on-secondary-container font-bold' : 'text-on-surface-variant'}`}>{item.label}</Text>
                    <MaterialIcons name="chevron-right" size={16} color="#c4c6ca" />
                  </Pressable>
                );
              })}
              <View className="h-[1px] bg-outline-variant/30 my-2 mx-2" />
              <Pressable onPress={handleSignOut} className="flex-row items-center gap-3 px-4 py-3.5 rounded-xl active:scale-[0.98]">
                <MaterialIcons name="logout" size={20} color="#ba1a1a" />
                <Text className="font-label-md text-error">Sign Out</Text>
              </Pressable>
            </View>
          </View>

          <View className="flex-1">
            <View className="bg-white border border-outline-variant/20 rounded-2xl p-5 mb-4">
              <View className="flex-row justify-between items-center mb-5">
                <View className="flex-row items-center gap-2">
                  <View className="w-8 h-8 rounded-lg bg-primary-container items-center justify-center">
                    <MaterialIcons name="person" size={16} color="#ffffff" />
                  </View>
                  <Text className="font-headline-md text-primary font-bold">Personal Info</Text>
                </View>
                <Pressable onPress={openEdit} className="flex-row items-center gap-1 bg-secondary-container px-4 py-2 rounded-xl active:scale-95">
                  <MaterialIcons name="edit" size={14} color="#00705e" />
                  <Text className="text-on-secondary-container font-label-md font-bold text-sm">Change</Text>
                </Pressable>
              </View>
              <View className="flex-row flex-wrap" style={{ gap: 16 }}>
                <View className="bg-surface-container-low rounded-xl p-4 flex-1 min-w-[140px]">
                  <Text className="text-caption text-on-surface-variant uppercase tracking-wider text-xs">Full Name</Text>
                  <View className="flex-row items-center gap-2 mt-1">
                    <MaterialIcons name="badge" size={16} color="#006b5a" />
                    <Text className="font-body-md font-medium text-primary">{d.profile.full_name}</Text>
                  </View>
                </View>
                <View className="bg-surface-container-low rounded-xl p-4 flex-1 min-w-[140px]">
                  <Text className="text-caption text-on-surface-variant uppercase tracking-wider text-xs">Email</Text>
                  <View className="flex-row items-center gap-2 mt-1">
                    <MaterialIcons name="email" size={16} color="#006b5a" />
                    <Text className="font-body-md font-medium text-primary" numberOfLines={1}>{d.profile.email}</Text>
                  </View>
                </View>
                <View className="bg-surface-container-low rounded-xl p-4 flex-1 min-w-[140px]">
                  <Text className="text-caption text-on-surface-variant uppercase tracking-wider text-xs">Phone</Text>
                  <View className="flex-row items-center gap-2 mt-1">
                    <MaterialIcons name="phone" size={16} color="#006b5a" />
                    <Text className="font-body-md font-medium text-primary">{d.profile.phone || 'Not set'}</Text>
                  </View>
                </View>
              </View>
            </View>

            <View className="bg-white border border-outline-variant/20 rounded-2xl p-5 mb-4">
              <View className="flex-row items-center gap-2 mb-5">
                <View className="w-8 h-8 rounded-lg bg-secondary-container items-center justify-center">
                  <MaterialIcons name="shield-moon" size={16} color="#00705e" />
                </View>
                <Text className="font-headline-md text-primary font-bold">Security & Protection</Text>
              </View>
              <View className="flex-row flex-wrap" style={{ gap: 12 }}>
                <Pressable onPress={() => router.push('/(tabs)/two-factor-auth' as any)} className="flex-1 min-w-[140px] p-4 rounded-xl bg-surface-container-low border border-outline-variant/20 flex-row items-start gap-3 active:scale-[0.98]">
                  <MaterialIcons name="lock-open" size={18} color="#006b5a" />
                  <View className="flex-1">
                    <Text className="font-label-md font-bold text-primary">Two-Factor Auth</Text>
                    <Text className="text-caption text-on-surface-variant text-xs">Enabled via App</Text>
                    <View className="flex-row items-center gap-1 mt-1.5">
                      <View className="w-1.5 h-1.5 rounded-full bg-secondary" />
                      <Text className="text-xs text-secondary font-medium">Active</Text>
                    </View>
                  </View>
                </Pressable>
                <Pressable onPress={() => router.push('/(tabs)/last-login' as any)} className="flex-1 min-w-[140px] p-4 rounded-xl bg-surface-container-low border border-outline-variant/20 flex-row items-start gap-3 active:scale-[0.98]">
                  <MaterialIcons name="history" size={18} color="#006b5a" />
                  <View className="flex-1">
                    <Text className="font-label-md font-bold text-primary">Last Login</Text>
                    <Text className="text-caption text-on-surface-variant text-xs">{new Date(d.security.last_login).toLocaleDateString()}</Text>
                  </View>
                </Pressable>
                <Pressable className="flex-1 min-w-[140px] p-4 rounded-xl bg-surface-container-low border border-outline-variant/20 flex-row items-start gap-3 active:scale-[0.98]">
                  <MaterialIcons name="devices" size={18} color="#006b5a" />
                  <View className="flex-1">
                    <Text className="font-label-md font-bold text-primary">Active Devices</Text>
                    <Text className="text-caption text-on-surface-variant text-xs">{d.security.active_devices} connected</Text>
                  </View>
                </Pressable>
              </View>
            </View>

            <View className="bg-white border border-outline-variant/20 rounded-2xl p-5 mb-4">
              <View className="flex-row justify-between items-center mb-5">
                <View className="flex-row items-center gap-2">
                  <View className="w-8 h-8 rounded-lg bg-primary-container items-center justify-center">
                    <MaterialIcons name="account-balance" size={16} color="#ffffff" />
                  </View>
                  <Text className="font-headline-md text-primary font-bold">Linked Accounts</Text>
                </View>
                <Pressable onPress={() => router.push('/(tabs)/linked-accounts' as any)} className="flex-row items-center gap-1 bg-surface-container-high px-4 py-2 rounded-xl active:scale-95">
                  <MaterialIcons name="add" size={14} color="#000f22" />
                  <Text className="font-label-md font-bold text-sm">Link Bank</Text>
                </Pressable>
              </View>
              {d.linked_accounts.length > 0 ? (
                d.linked_accounts.map((account) => (
                  <Pressable key={account.id} onPress={() => router.push('/(tabs)/linked-accounts' as any)} className="flex-row items-center justify-between p-3.5 bg-surface-container-low rounded-xl mb-2 border border-outline-variant/10 active:scale-[0.98]">
                    <View className="flex-row items-center gap-3">
                      <View className="w-10 h-10 bg-surface-container items-center justify-center rounded-xl">
                        <MaterialIcons name={account.account_type === 'Checking' ? 'account-balance' : 'savings'} size={20} color="#43474d" />
                      </View>
                      <View>
                        <Text className="font-label-md font-bold text-primary">{account.bank_name}</Text>
                        <Text className="text-caption text-on-surface-variant">{account.account_type} ••••{account.account_number.slice(-4)}</Text>
                      </View>
                    </View>
                    <View className="flex-row items-center gap-2">
                      <Text className="font-label-md font-bold text-primary">${account.balance.toLocaleString()}</Text>
                      <MaterialIcons name="chevron-right" size={18} color="#c4c6ca" />
                    </View>
                  </Pressable>
                ))
              ) : (
                <View className="items-center py-6">
                  <MaterialIcons name="account-balance" size={40} color="#c4c6ca" />
                  <Text className="text-on-surface-variant text-body-md mt-3">No linked accounts yet</Text>
                  <Pressable onPress={() => router.push('/(tabs)/linked-accounts' as any)} className="mt-3 bg-primary px-5 py-2.5 rounded-xl active:scale-95">
                    <Text className="text-on-primary font-label-md font-bold">Link Your First Bank</Text>
                  </Pressable>
                </View>
              )}
            </View>

            <View className="bg-white border border-outline-variant/20 rounded-2xl p-5 mb-4">
              <View className="flex-row items-center gap-2 mb-5">
                <View className="w-8 h-8 rounded-lg bg-secondary-container items-center justify-center">
                  <MaterialIcons name="auto-awesome" size={16} color="#00705e" />
                </View>
                <Text className="font-headline-md text-primary font-bold">Plan Details</Text>
              </View>
              <View className="flex-row items-center gap-4 p-4 bg-[#001f1a] rounded-xl">
                <View className="w-14 h-14 bg-white/10 rounded-full items-center justify-center">
                  <MaterialIcons name="auto-awesome" size={28} color="#58fbda" />
                </View>
                <View className="flex-1">
                  <Text className="font-headline-md text-white font-bold">{d.plan.name}</Text>
                  <Text className="text-white/80 text-body-md">${d.plan.price} / {d.plan.billing}</Text>
                </View>
                <View className="bg-secondary-container/30 px-3 py-1 rounded-full"><Text className="text-secondary-fixed text-xs font-bold">ACTIVE</Text></View>
              </View>
              <Pressable className="w-full bg-primary py-3 rounded-xl items-center mt-4 active:scale-[0.98]">
                <Text className="text-on-primary font-label-md font-bold">Manage Subscription</Text>
              </Pressable>
            </View>

            <View className="bg-white border border-outline-variant/20 rounded-2xl p-5">
              <View className="flex-row items-center gap-2 mb-5">
                <View className="w-8 h-8 rounded-lg bg-primary-container items-center justify-center">
                  <MaterialIcons name="settings" size={16} color="#ffffff" />
                </View>
                <Text className="font-headline-md text-primary font-bold">App Preferences</Text>
              </View>
              <View className="space-y-12">
                <Pressable onPress={() => setShowLocationPicker(true)} className="flex-row items-center justify-between p-3.5 bg-surface-container-low rounded-xl active:scale-[0.98]">
                  <View className="flex-row items-center gap-3">
                    <MaterialIcons name="language" size={18} color="#006b5a" />
                    <View>
                      <Text className="font-label-md font-bold text-primary">Location</Text>
                      <Text className="text-caption text-on-surface-variant text-xs">{LOCATIONS.find((l) => l.value === location)?.label}</Text>
                    </View>
                  </View>
                  <MaterialIcons name="chevron-right" size={18} color="#c4c6ca" />
                </Pressable>
                <Pressable onPress={() => setShowCurrencyPicker(true)} className="flex-row items-center justify-between p-3.5 bg-surface-container-low rounded-xl active:scale-[0.98]">
                  <View className="flex-row items-center gap-3">
                    <MaterialIcons name="currency-exchange" size={18} color="#006b5a" />
                    <View>
                      <Text className="font-label-md font-bold text-primary">Currency</Text>
                      <Text className="text-caption text-on-surface-variant text-xs">{currency.symbol} {currency.code} - {currency.name}</Text>
                    </View>
                  </View>
                  <MaterialIcons name="chevron-right" size={18} color="#c4c6ca" />
                </Pressable>
                <Pressable onPress={() => setShowLanguagePicker(true)} className="flex-row items-center justify-between p-3.5 bg-surface-container-low rounded-xl active:scale-[0.98]">
                  <View className="flex-row items-center gap-3">
                    <MaterialIcons name="translate" size={18} color="#006b5a" />
                    <View>
                      <Text className="font-label-md font-bold text-primary">Language</Text>
                      <Text className="text-caption text-on-surface-variant text-xs">{LANGUAGES.find((l) => l.value === language)?.label}</Text>
                    </View>
                  </View>
                  <MaterialIcons name="chevron-right" size={18} color="#c4c6ca" />
                </Pressable>
              </View>
            </View>
          </View>
        </View>
      </ScrollView>

      <Modal visible={editVisible} transparent animationType="slide" onRequestClose={() => setEditVisible(false)}>
        <View className="flex-1 bg-black/40 justify-center px-4">
          <View className="bg-white rounded-3xl p-6" style={{ shadowColor: '#000', shadowOffset: { width: 0, height: 8 }, shadowOpacity: 0.15, shadowRadius: 24, elevation: 16 }}>
            <View className="flex-row items-center justify-between mb-6">
              <View className="flex-row items-center gap-2">
                <View className="w-8 h-8 rounded-lg bg-primary-container items-center justify-center">
                  <MaterialIcons name="edit" size={16} color="#000f22" />
                </View>
                <Text className="font-headline-md text-primary font-bold">Edit Personal Info</Text>
              </View>
              <Pressable onPress={() => setEditVisible(false)} className="w-8 h-8 rounded-full bg-surface-variant items-center justify-center active:scale-90">
                <MaterialIcons name="close" size={18} color="#43474d" />
              </Pressable>
            </View>

            <View className="mb-4">
              <Text className="font-label-md text-on-surface mb-2">Full Name</Text>
              <View className="flex-row items-center bg-surface-container-low rounded-xl border border-outline-variant/30 px-4">
                <MaterialIcons name="badge" size={18} color="#74777e" />
                <TextInput className="flex-1 py-3.5 ml-2 text-body-md text-primary" value={editName} onChangeText={setEditName} placeholderTextColor="#9ea0a5" />
              </View>
            </View>

            <View className="mb-4">
              <Text className="font-label-md text-on-surface mb-2">Email Address</Text>
              <View className="flex-row items-center bg-surface-container-low rounded-xl border border-outline-variant/30 px-4">
                <MaterialIcons name="email" size={18} color="#74777e" />
                <TextInput className="flex-1 py-3.5 ml-2 text-body-md text-primary" value={editEmail} onChangeText={setEditEmail} keyboardType="email-address" placeholderTextColor="#9ea0a5" />
              </View>
            </View>

            <View className="mb-6">
              <Text className="font-label-md text-on-surface mb-2">Phone Number</Text>
              <View className="flex-row items-center bg-surface-container-low rounded-xl border border-outline-variant/30 px-4">
                <MaterialIcons name="phone" size={18} color="#74777e" />
                <TextInput className="flex-1 py-3.5 ml-2 text-body-md text-primary" value={editPhone} onChangeText={setEditPhone} keyboardType="phone-pad" placeholderTextColor="#9ea0a5" />
              </View>
            </View>

            <View className="flex-row gap-3">
              <Pressable onPress={() => setEditVisible(false)} className="flex-1 py-3.5 rounded-xl border border-outline-variant items-center active:scale-[0.98]">
                <Text className="font-label-md text-on-surface font-bold">Cancel</Text>
              </Pressable>
              <Pressable onPress={handleSaveProfile} className="flex-1 py-3.5 rounded-xl bg-primary items-center active:scale-[0.98]">
                <Text className="font-label-md text-on-primary font-bold">Save Changes</Text>
              </Pressable>
            </View>
          </View>
        </View>
      </Modal>

      <NotificationModal visible={notifVisible} onClose={closeNotifications} />

      <Modal visible={showLocationPicker} transparent animationType="slide" onRequestClose={() => setShowLocationPicker(false)}>
        <View className="flex-1 bg-black/40 justify-end">
          <View className="bg-white rounded-t-3xl max-h-[70%]" style={{ shadowColor: '#000', shadowOffset: { width: 0, height: -8 }, shadowOpacity: 0.1, shadowRadius: 24, elevation: 16 }}>
            <View className="items-center pt-3 pb-1"><View className="w-10 h-1 rounded-full bg-outline/40" /></View>
            <View className="flex-row items-center justify-between px-6 py-4 border-b border-outline-variant/20">
              <Text className="font-headline-md text-primary font-bold">Select Location</Text>
              <Pressable onPress={() => setShowLocationPicker(false)} className="w-8 h-8 rounded-full bg-surface-variant items-center justify-center"><MaterialIcons name="close" size={18} color="#43474d" /></Pressable>
            </View>
            <ScrollView className="px-6 py-4">
              {LOCATIONS.map((loc) => (
                <Pressable key={loc.value} onPress={() => { setLocation(loc.value); setShowLocationPicker(false); }} className={`flex-row items-center gap-3 p-4 rounded-xl mb-1 ${location === loc.value ? 'bg-secondary-container' : ''} active:scale-[0.98]`}>
                  <MaterialIcons name="language" size={20} color={location === loc.value ? '#00705e' : '#43474d'} />
                  <Text className={`font-label-md flex-1 ${location === loc.value ? 'text-on-secondary-container font-bold' : 'text-on-surface'}`}>{loc.label}</Text>
                  <Text className="text-caption text-on-surface-variant">{loc.currency}</Text>
                </Pressable>
              ))}
            </ScrollView>
          </View>
        </View>
      </Modal>

      <Modal visible={showCurrencyPicker} transparent animationType="slide" onRequestClose={() => setShowCurrencyPicker(false)}>
        <View className="flex-1 bg-black/40 justify-end">
          <View className="bg-white rounded-t-3xl max-h-[70%]" style={{ shadowColor: '#000', shadowOffset: { width: 0, height: -8 }, shadowOpacity: 0.1, shadowRadius: 24, elevation: 16 }}>
            <View className="items-center pt-3 pb-1"><View className="w-10 h-1 rounded-full bg-outline/40" /></View>
            <View className="flex-row items-center justify-between px-6 py-4 border-b border-outline-variant/20">
              <Text className="font-headline-md text-primary font-bold">Select Currency</Text>
              <Pressable onPress={() => setShowCurrencyPicker(false)} className="w-8 h-8 rounded-full bg-surface-variant items-center justify-center"><MaterialIcons name="close" size={18} color="#43474d" /></Pressable>
            </View>
            <ScrollView className="px-6 py-4">
              {CURRENCIES.map((c) => (
                <Pressable key={c.code} onPress={() => { setCurrency(c.code); setShowCurrencyPicker(false); }} className={`flex-row items-center gap-3 p-4 rounded-xl mb-1 ${currency.code === c.code ? 'bg-secondary-container' : ''} active:scale-[0.98]`}>
                  <View className="w-10 h-10 rounded-full bg-primary-container items-center justify-center"><Text className="font-bold text-primary">{c.symbol}</Text></View>
                  <View className="flex-1">
                    <Text className={`font-label-md ${currency.code === c.code ? 'text-on-secondary-container font-bold' : 'text-on-surface'}`}>{c.code} - {c.name}</Text>
                  </View>
                  {currency.code === c.code && <MaterialIcons name="check-circle" size={20} color="#00705e" />}
                </Pressable>
              ))}
            </ScrollView>
          </View>
        </View>
      </Modal>

      <Modal visible={showLanguagePicker} transparent animationType="slide" onRequestClose={() => setShowLanguagePicker(false)}>
        <View className="flex-1 bg-black/40 justify-end">
          <View className="bg-white rounded-t-3xl max-h-[70%]" style={{ shadowColor: '#000', shadowOffset: { width: 0, height: -8 }, shadowOpacity: 0.1, shadowRadius: 24, elevation: 16 }}>
            <View className="items-center pt-3 pb-1"><View className="w-10 h-1 rounded-full bg-outline/40" /></View>
            <View className="flex-row items-center justify-between px-6 py-4 border-b border-outline-variant/20">
              <Text className="font-headline-md text-primary font-bold">Select Language</Text>
              <Pressable onPress={() => setShowLanguagePicker(false)} className="w-8 h-8 rounded-full bg-surface-variant items-center justify-center"><MaterialIcons name="close" size={18} color="#43474d" /></Pressable>
            </View>
            <ScrollView className="px-6 py-4">
              {LANGUAGES.map((lang) => (
                <Pressable key={lang.value} onPress={() => { setLanguage(lang.value); setShowLanguagePicker(false); }} className={`flex-row items-center gap-3 p-4 rounded-xl mb-1 ${language === lang.value ? 'bg-secondary-container' : ''} active:scale-[0.98]`}>
                  <MaterialIcons name="translate" size={20} color={language === lang.value ? '#00705e' : '#43474d'} />
                  <Text className={`font-label-md flex-1 ${language === lang.value ? 'text-on-secondary-container font-bold' : 'text-on-surface'}`}>{lang.label}</Text>
                  {language === lang.value && <MaterialIcons name="check-circle" size={20} color="#00705e" />}
                </Pressable>
              ))}
            </ScrollView>
          </View>
        </View>
      </Modal>
    </View>
  );
}
