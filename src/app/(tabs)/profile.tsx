import { useEffect, useState } from 'react';
import { ScrollView, View, Text, Pressable, ActivityIndicator, TextInput, Modal, Alert, useWindowDimensions, useColorScheme } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { router } from 'expo-router';
import { useDashboardStore } from '@/src/stores/dashboard-store';
import { useAuthStore } from '@/src/stores/auth-store';
import { NotificationIcon, NotificationModal } from '@/src/components/notification-modal';
import { UserAvatar } from '@/src/components/user-avatar';
import { Logo } from '@/src/components/logo';
import { formatCurrency, convertAmount } from '@/src/lib/format-currency';
import { useSettingsStore } from '@/src/stores/settings-store';
import { useNotificationStore } from '@/src/stores/notification-store';
import * as ProfileService from '@/src/lib/api/services/profile';

const BLUE = '#123B91';
const PAPER = '#F2F2F2';
const GREEN = '#2E7D5B';
const GOLD = '#C99A2E';

const SETTINGS_ITEMS = [
  { icon: 'person' as const, label: 'Personal Info', action: 'edit' as const },
  { icon: 'security' as const, label: 'Security', route: '/(tabs)/security' as const },
  { icon: 'account-balance' as const, label: 'Linked Accounts', route: '/(tabs)/linked-accounts' as const },
  { icon: 'privacy-tip' as const, label: 'Data Privacy', route: '/(tabs)/data-privacy' as const },
  { icon: 'notifications' as const, label: 'Notifications', action: 'notifications' as const },
];

export default function Settings() {
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';
  const { width } = useWindowDimensions();
  const data = useDashboardStore((s) => s.profileData);
  const summary = useDashboardStore((s) => s.summary);
  const isLoading = useDashboardStore((s) => s.isLoading);
  const load = useDashboardStore((s) => s.loadProfileData);
  const user = useAuthStore((s) => s.user);
  const signOut = useAuthStore((s) => s.signOut);
  const { currency } = useSettingsStore();
  const { count: notifCount, open: openNotifications, visible: notifVisible, close: closeNotifications } = useNotificationStore();

  const [editVisible, setEditVisible] = useState(false);
  const [editName, setEditName] = useState('');
  const [editEmail, setEditEmail] = useState('');
  const [editPhone, setEditPhone] = useState('');

  useEffect(() => {
    load();
  }, [load]);

  const openEdit = () => {
    if (!data) return;
    setEditName(data.profile.full_name);
    setEditEmail(data.profile.email);
    setEditPhone(data.profile.phone || '');
    setEditVisible(true);
  };

  const handleSaveProfile = async () => {
    try {
      if (!user?.id) return;
      await ProfileService.updateProfile(user.id, {
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

  if (!data) {
    return (
      <View style={{ flex: 1, backgroundColor: isDark ? '#08142E' : PAPER, alignItems: 'center', justifyContent: 'center' }}>
        <ActivityIndicator size="large" color={BLUE} />
      </View>
    );
  }

  const firstName = data.profile.full_name?.split(' ')[0] || 'there';
  // TODO: source these from the real dashboard summary once the backend fields exist —
  // falling back to `total_net_worth` / a placeholder budget so the screen renders meaningfully.
  const walletBalance = summary?.total_net_worth ?? 0;
  const monthlyBudget = (summary as any)?.budget_this_month ?? 40000;
  const savingsAmount = (summary as any)?.savings_balance ?? 45000;
  const linkedAccountsCount = data.linked_accounts?.length ?? 0;
  const connectedAppsCount = (data as any)?.connected_apps_count ?? 5;

  return (
    <View style={{ flex: 1, backgroundColor: isDark ? '#08142E' : PAPER, alignItems: 'center' }}>
      <View style={{ width: Math.min(width, 600), flex: 1 }}>
        <View style={{ paddingHorizontal: 20, paddingTop: 60, paddingBottom: 12 }}>
          <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' }}>
            <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8 }}>
              <Logo width={20} height={18} color={BLUE} />
              <Text style={{ fontFamily: 'Montserrat_700Bold', fontSize: 18, color: isDark ? '#FFFFFF' : '#1A1A1A' }}>Settings</Text>
            </View>
            <View style={{ flexDirection: 'row', alignItems: 'center', gap: 12 }}>
              <NotificationIcon onPress={openNotifications} count={notifCount} />
              <UserAvatar size={32} />
            </View>
          </View>
        </View>

        <ScrollView style={{ flex: 1, paddingHorizontal: 20 }} contentContainerStyle={{ paddingBottom: 40 }} showsVerticalScrollIndicator={false}>
          {/* Greeting row */}
          <Pressable onPress={openEdit} accessibilityRole="button" style={{ flexDirection: 'row', alignItems: 'center', marginTop: 4, marginBottom: 20 }}>
            <UserAvatar size={56} name={data.profile.full_name} />
            <View style={{ marginLeft: 14, flex: 1 }}>
              <Text style={{ fontFamily: 'Montserrat_700Bold', fontSize: 18, color: isDark ? '#FFFFFF' : '#1A1A1A' }}>Hey, {firstName}</Text>
              <Text style={{ fontFamily: 'Montserrat_400Regular', fontSize: 13, color: isDark ? '#9CA3B0' : '#6B6F76', marginTop: 2 }}>
                {data.profile.email}
              </Text>
            </View>
            <MaterialIcons name="chevron-right" size={20} color="#C4C6CE" />
          </Pressable>

          {/* Wallet balance / budget card */}
          <View style={{ backgroundColor: BLUE, borderRadius: 18, padding: 18, flexDirection: 'row' }}>
            <View style={{ flex: 1 }}>
              <Text style={{ fontFamily: 'Montserrat_500Medium', fontSize: 12, color: 'rgba(255,255,255,0.7)' }}>
                Total Wallet Balance
              </Text>
              <Text style={{ fontFamily: 'Montserrat_700Bold', fontSize: 20, color: '#FFFFFF', marginTop: 4 }}>
                {formatCurrency(convertAmount(walletBalance, currency.rate), currency.code)}
              </Text>
            </View>
            <View style={{ width: 1, backgroundColor: 'rgba(255,255,255,0.15)', marginHorizontal: 16 }} />
            <View style={{ flex: 1 }}>
              <Text style={{ fontFamily: 'Montserrat_500Medium', fontSize: 12, color: 'rgba(255,255,255,0.7)' }}>
                Budget For the Month
              </Text>
              <Text style={{ fontFamily: 'Montserrat_700Bold', fontSize: 20, color: '#FFFFFF', marginTop: 4 }}>
                {formatCurrency(convertAmount(monthlyBudget, currency.rate), currency.code)}
              </Text>
            </View>
          </View>

          {/* Others */}
          <Text style={{ fontFamily: 'Montserrat_700Bold', fontSize: 16, color: isDark ? '#FFFFFF' : '#1A1A1A', marginTop: 24, marginBottom: 12 }}>
            Others
          </Text>
          <View style={{ flexDirection: 'row', gap: 10 }}>
            <Pressable
              onPress={() => router.push('/(tabs)/linked-accounts')}
              accessibilityRole="button"
              style={{ flex: 1, backgroundColor: BLUE, borderRadius: 14, padding: 14, minHeight: 76, justifyContent: 'space-between' }}
            >
              <MaterialIcons name="apps" size={18} color="#FFFFFF" />
              <View>
                <Text style={{ fontFamily: 'Montserrat_700Bold', fontSize: 13, color: '#FFFFFF' }}>Apps Connected</Text>
                <Text style={{ fontFamily: 'Montserrat_400Regular', fontSize: 11, color: 'rgba(255,255,255,0.75)', marginTop: 2 }}>
                  {connectedAppsCount} apps connected
                </Text>
              </View>
            </Pressable>

            <Pressable
              onPress={() => router.push('/(tabs)/vault')}
              accessibilityRole="button"
              style={{ flex: 1, backgroundColor: GREEN, borderRadius: 14, padding: 14, minHeight: 76, justifyContent: 'space-between' }}
            >
              <MaterialIcons name="savings" size={18} color="#FFFFFF" />
              <View>
                <Text style={{ fontFamily: 'Montserrat_700Bold', fontSize: 13, color: '#FFFFFF' }}>Your Savings</Text>
                <Text style={{ fontFamily: 'Montserrat_400Regular', fontSize: 11, color: 'rgba(255,255,255,0.75)', marginTop: 2 }}>
                  {formatCurrency(convertAmount(savingsAmount, currency.rate), currency.code)}
                </Text>
              </View>
            </Pressable>

            <Pressable
              onPress={() => router.push('/(tabs)/linked-accounts')}
              accessibilityRole="button"
              style={{ flex: 1, backgroundColor: GOLD, borderRadius: 14, padding: 14, minHeight: 76, justifyContent: 'space-between' }}
            >
              <MaterialIcons name="link" size={18} color="#FFFFFF" />
              <View>
                <Text style={{ fontFamily: 'Montserrat_700Bold', fontSize: 13, color: '#FFFFFF' }}>Account Linked</Text>
                <Text style={{ fontFamily: 'Montserrat_400Regular', fontSize: 11, color: 'rgba(255,255,255,0.75)', marginTop: 2 }}>
                  {linkedAccountsCount} accounts linked
                </Text>
              </View>
            </Pressable>
          </View>

          {/* Settings list */}
          <Text style={{ fontFamily: 'Montserrat_700Bold', fontSize: 16, color: isDark ? '#FFFFFF' : '#1A1A1A', marginTop: 24, marginBottom: 12 }}>
            Settings
          </Text>
          <View style={{ backgroundColor: isDark ? '#1A1A1A' : '#FFFFFF', borderRadius: 16, borderWidth: 1, borderColor: isDark ? '#2A2A2A' : '#E4E7EE' }}>
            {SETTINGS_ITEMS.map((item, i) => (
              <Pressable
                key={item.label}
                onPress={() => {
                  if (item.action === 'edit') openEdit();
                  else if (item.action === 'notifications') openNotifications();
                  else if ('route' in item && item.route) router.push(item.route as any);
                }}
                accessibilityRole="button"
                style={{
                  flexDirection: 'row',
                  alignItems: 'center',
                  paddingHorizontal: 16,
                  paddingVertical: 14,
                  borderBottomWidth: i < SETTINGS_ITEMS.length - 1 ? 1 : 0,
                  borderBottomColor: isDark ? '#2A2A2A' : '#EEF0F5',
                }}
              >
                <MaterialIcons name={item.icon} size={20} color={isDark ? '#9CA3B0' : '#43474D'} />
                <Text style={{ flex: 1, marginLeft: 14, fontFamily: 'Montserrat_500Medium', fontSize: 15, color: isDark ? '#F0F0F0' : '#1A1A1A' }}>
                  {item.label}
                </Text>
                <MaterialIcons name="chevron-right" size={18} color="#C4C6CE" />
              </Pressable>
            ))}

            <Pressable
              onPress={handleSignOut}
              accessibilityRole="button"
              style={{ flexDirection: 'row', alignItems: 'center', paddingHorizontal: 16, paddingVertical: 14, borderTopWidth: 1, borderTopColor: isDark ? '#2A2A2A' : '#EEF0F5' }}
            >
              <MaterialIcons name="logout" size={20} color="#C0392B" />
              <Text style={{ marginLeft: 14, fontFamily: 'Montserrat_500Medium', fontSize: 15, color: '#C0392B' }}>Sign Out</Text>
            </Pressable>
          </View>
        </ScrollView>
      </View>

      {/* Edit personal info */}
      <Modal visible={editVisible} transparent animationType="slide" onRequestClose={() => setEditVisible(false)}>
        <View style={{ flex: 1, backgroundColor: 'rgba(0,0,0,0.4)', justifyContent: 'center', paddingHorizontal: 20 }}>
          <View style={{ backgroundColor: isDark ? '#1A1A1A' : '#FFFFFF', borderRadius: 20, padding: 22 }}>
            <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', marginBottom: 20 }}>
              <Text style={{ fontFamily: 'Montserrat_700Bold', fontSize: 17, color: isDark ? '#FFFFFF' : '#1A1A1A' }}>Edit Personal Info</Text>
              <Pressable onPress={() => setEditVisible(false)} accessibilityLabel="Close" accessibilityRole="button" hitSlop={8}>
                <MaterialIcons name="close" size={20} color={isDark ? '#9CA3B0' : '#6B6F76'} />
              </Pressable>
            </View>

            {[
              { label: 'Full Name', value: editName, setter: setEditName, keyboardType: 'default' as const },
              { label: 'Email Address', value: editEmail, setter: setEditEmail, keyboardType: 'email-address' as const },
              { label: 'Phone Number', value: editPhone, setter: setEditPhone, keyboardType: 'phone-pad' as const },
            ].map((field) => (
              <View key={field.label} style={{ marginBottom: 16 }}>
                <Text style={{ fontFamily: 'Montserrat_500Medium', fontSize: 13, color: isDark ? '#FFFFFF' : '#1A1A1A', marginBottom: 6 }}>
                  {field.label}
                </Text>
                <TextInput
                  value={field.value}
                  onChangeText={field.setter}
                  keyboardType={field.keyboardType}
                  accessibilityLabel={field.label}
                  style={{
                    height: 50,
                    borderRadius: 10,
                    borderWidth: 1,
                    borderColor: isDark ? '#2A2A2A' : '#E1E4EC',
                    paddingHorizontal: 14,
                    fontFamily: 'Montserrat_400Regular',
                    fontSize: 14,
                    color: isDark ? '#FFFFFF' : '#1A1A1A',
                  }}
                  placeholderTextColor="#9AA0AC"
                />
              </View>
            ))}

            <View style={{ flexDirection: 'row', gap: 10, marginTop: 6 }}>
              <Pressable
                onPress={() => setEditVisible(false)}
                accessibilityRole="button"
                style={{ flex: 1, height: 50, borderRadius: 12, borderWidth: 1.5, borderColor: isDark ? '#2A2A2A' : '#E1E4EC', alignItems: 'center', justifyContent: 'center' }}
              >
                <Text style={{ fontFamily: 'Montserrat_600SemiBold', fontSize: 15, color: isDark ? '#FFFFFF' : '#1A1A1A' }}>Cancel</Text>
              </Pressable>
              <Pressable
                onPress={handleSaveProfile}
                accessibilityRole="button"
                style={{ flex: 1, height: 50, borderRadius: 12, backgroundColor: BLUE, alignItems: 'center', justifyContent: 'center' }}
              >
                <Text style={{ fontFamily: 'Montserrat_600SemiBold', fontSize: 15, color: '#FFFFFF' }}>Save Changes</Text>
              </Pressable>
            </View>
          </View>
        </View>
      </Modal>

      <NotificationModal visible={notifVisible} onClose={closeNotifications} />
    </View>
  );
}        
