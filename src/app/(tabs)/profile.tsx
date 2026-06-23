import { useEffect } from 'react';
import { ScrollView, View, Text, Pressable, ActivityIndicator } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { useDashboardStore } from '@/stores/dashboard-store';
import { useAuthStore } from '@/stores/auth-store';
import { router } from 'expo-router';

const SETTINGS = [
  { icon: 'person' as const, label: 'Personal Info', active: true },
  { icon: 'security' as const, label: 'Security', active: false },
  { icon: 'account-balance' as const, label: 'Linked Accounts', active: false },
  { icon: 'privacy-tip' as const, label: 'Data Privacy', active: false },
  { icon: 'notifications' as const, label: 'Notifications', active: false },
];

export default function Profile() {
  const data = useDashboardStore((s) => s.profileData);
  const isLoading = useDashboardStore((s) => s.isLoading);
  const load = useDashboardStore((s) => s.loadProfileData);
  const signOut = useAuthStore((s) => s.signOut);

  useEffect(() => { load(); }, [load]);

  const handleSignOut = async () => {
    await signOut();
    router.replace('/');
  };

  if (!data) {
    return <View className="flex-1 bg-surface-bright items-center justify-center"><ActivityIndicator size="large" color="#006b5a" /></View>;
  }

  const d = data;

  return (
    <View className="flex-1 bg-surface-bright">
      <View className="bg-surface-bright pt-14 pb-3 px-margin-mobile md:px-margin-desktop" style={{ elevation: 4, shadowColor: '#000', shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.04 }}>
        <View className="flex-row items-center justify-between">
          <View className="flex-row items-center gap-4">
            <Pressable className="active:scale-95 md:hidden"><MaterialIcons name="menu" size={24} color="#000f22" /></Pressable>
            <Text className="font-headline-md text-primary font-bold">Finovault AI</Text>
          </View>
          <View className="flex-row items-center gap-6">
            <View className="hidden md:flex-row md:gap-8">
              <Pressable className="px-3 py-2 rounded-lg"><Text className="font-label-md text-on-surface-variant">Wealth Growth</Text></Pressable>
              <Pressable className="px-3 py-2 rounded-lg"><Text className="font-label-md text-on-surface-variant">Smart Savings</Text></Pressable>
            </View>
            <View className="w-10 h-10 rounded-full border-2 border-primary-fixed items-center justify-center bg-surface-container-high overflow-hidden"><MaterialIcons name="person" size={22} color="#43474d" /></View>
          </View>
        </View>
      </View>

      <ScrollView className="flex-1 px-margin-mobile md:px-margin-desktop" contentContainerStyle={{ paddingBottom: 120 }}>
        <View className="bg-primary-container rounded-xl overflow-hidden p-lg mt-4 mb-md">
          <View className="flex-col md:flex-row items-center gap-md">
            <View className="w-32 h-32 rounded-full border-4 border-white/20 overflow-hidden bg-surface-container items-center justify-center"><MaterialIcons name="person" size={60} color="#43474d" /></View>
            <View className="flex-1 items-center md:items-start">
              <View className="flex-row items-center gap-2 mb-1">
                <Text className="font-headline-lg text-headline-lg text-white font-bold">{d.profile.full_name}</Text>
                <MaterialIcons name="verified" size={18} color="#58fbda" />
              </View>
              <View className="flex-row items-center gap-2">
                <MaterialIcons name="workspace-premium" size={14} color="#768dad" />
                <Text className="text-on-primary-container text-body-md">{d.plan.name}</Text>
              </View>
              <View className="flex-row flex-wrap gap-2 mt-4">
                <View className="bg-white/10 px-4 py-1 rounded-full"><Text className="text-white/80 font-label-md text-label-md">Account ID: {d.profile.account_id}</Text></View>
                <View className="bg-secondary-container px-4 py-1 rounded-full"><Text className="text-on-secondary-container font-label-md text-label-md font-bold">PRO MEMBER</Text></View>
              </View>
            </View>
            <View className="md:ml-auto">
              <Pressable className="bg-secondary-fixed px-6 py-3 rounded-xl flex-row items-center gap-2 active:scale-95" style={{ shadowColor: 'rgba(88,251,218,0.3)', shadowOffset: { width: 0, height: 4 }, shadowRadius: 12, elevation: 4 }}>
                <MaterialIcons name="edit" size={18} color="#00201a" />
                <Text className="text-on-secondary-fixed font-bold">Edit Profile</Text>
              </Pressable>
            </View>
          </View>
        </View>

        <View className="flex-col md:flex-row gap-md">
          <View className="md:w-[25%] space-y-2">
            {SETTINGS.map((item) => (
              <Pressable key={item.label} className={`flex-row items-center gap-3 px-4 py-3 rounded-xl ${item.active ? 'bg-secondary-container' : ''} active:scale-[0.98]`}>
                <MaterialIcons name={item.icon} size={22} color={item.active ? '#00705e' : '#43474d'} />
                <Text className={`font-label-md ${item.active ? 'text-on-secondary-container font-bold' : 'text-on-surface-variant'}`}>{item.label}</Text>
              </Pressable>
            ))}
            <View className="h-[1px] bg-outline-variant my-4 mx-2" />
            <Pressable onPress={handleSignOut} className="flex-row items-center gap-3 px-4 py-3 rounded-xl active:scale-[0.98]">
              <MaterialIcons name="logout" size={22} color="#ba1a1a" />
              <Text className="font-label-md text-error">Sign Out</Text>
            </Pressable>
          </View>

          <View className="flex-1 space-y-md">
            <View className="flex-col md:flex-row gap-md">
              <View className="flex-1 bg-white/70 border border-[#e6ebf1] rounded-xl p-md">
                <View className="flex-row justify-between items-center mb-6">
                  <Text className="font-headline-md text-primary font-bold">Personal Info</Text>
                  <Pressable><Text className="text-secondary font-bold text-label-md">Change</Text></Pressable>
                </View>
                <View className="space-y-4">
                  <View><Text className="text-on-surface-variant text-caption uppercase tracking-wider">Full Name</Text><Text className="font-body-md font-medium">{d.profile.full_name}</Text></View>
                  <View><Text className="text-on-surface-variant text-caption uppercase tracking-wider">Email Address</Text><Text className="font-body-md font-medium">{d.profile.email}</Text></View>
                  <View><Text className="text-on-surface-variant text-caption uppercase tracking-wider">Phone Number</Text><Text className="font-body-md font-medium">{d.profile.phone || 'Not set'}</Text></View>
                </View>
              </View>

              <View className="flex-1 bg-white/70 border border-[#e6ebf1] rounded-xl p-md">
                <View className="flex-row justify-between items-center mb-6">
                  <Text className="font-headline-md text-primary font-bold">Plan Details</Text>
                  <View className="bg-secondary-container/50 px-3 py-1 rounded-full"><Text className="text-on-secondary-container text-caption font-bold">ACTIVE</Text></View>
                </View>
                <View className="items-center py-4">
                  <View className="w-16 h-16 bg-primary/5 rounded-full items-center justify-center mb-4"><MaterialIcons name="auto-awesome" size={32} color="#000f22" /></View>
                  <Text className="font-headline-md">{d.plan.name}</Text>
                  <Text className="text-on-surface-variant text-body-md mb-4">${d.plan.price} / {d.plan.billing}</Text>
                  <Pressable className="w-full bg-primary py-3 rounded-xl items-center active:scale-95"><Text className="text-on-primary font-bold">Manage Subscription</Text></Pressable>
                </View>
              </View>
            </View>

            <View className="bg-white/70 border border-[#e6ebf1] rounded-xl p-md">
              <View className="flex-row items-center justify-between mb-6">
                <Text className="font-headline-md text-primary font-bold">Security & Protection</Text>
                <View className="flex-row items-center gap-1"><MaterialIcons name="shield-moon" size={16} color="#006b5a" /><Text className="text-secondary font-bold text-label-md">Safe Status</Text></View>
              </View>
              <View className="flex-col md:flex-row gap-md">
                <View className="flex-1 p-4 rounded-xl bg-surface-container-low border border-outline-variant/30 flex-row items-start gap-3">
                  <MaterialIcons name={d.security.identity_verified ? 'lock-open' : 'lock'} size={18} color="#006b5a" />
                  <View><Text className="font-label-md font-bold text-primary">Two-Factor Auth</Text><Text className="text-caption text-on-surface-variant">Enabled via App</Text></View>
                </View>
                <View className="flex-1 p-4 rounded-xl bg-surface-container-low border border-outline-variant/30 flex-row items-start gap-3">
                  <MaterialIcons name="history" size={18} color="#006b5a" />
                  <View><Text className="font-label-md font-bold text-primary">Last Login</Text><Text className="text-caption text-on-surface-variant">{new Date(d.security.last_login).toLocaleDateString()}</Text></View>
                </View>
                <View className="flex-1 p-4 rounded-xl bg-surface-container-low border border-outline-variant/30 flex-row items-start gap-3">
                  <MaterialIcons name="devices" size={18} color="#006b5a" />
                  <View><Text className="font-label-md font-bold text-primary">Active Devices</Text><Text className="text-caption text-on-surface-variant">{d.security.active_devices} connected devices</Text></View>
                </View>
              </View>
            </View>

            <View className="bg-white/70 border border-[#e6ebf1] rounded-xl p-md">
              <View className="flex-row justify-between items-center mb-6">
                <Text className="font-headline-md text-primary font-bold">Linked Accounts</Text>
                <Pressable className="flex-row items-center gap-1 bg-surface-container-high px-4 py-2 rounded-lg active:scale-95"><MaterialIcons name="add" size={16} color="#000f22" /><Text className="text-label-md font-bold">Link Bank</Text></Pressable>
              </View>
              <View className="space-y-4">
                {d.linked_accounts.map((account) => (
                  <Pressable key={account.id} className="flex-row items-center justify-between p-4 bg-white rounded-xl border border-outline-variant/20 active:scale-[0.98]">
                    <View className="flex-row items-center gap-4">
                      <View className="w-12 h-12 bg-surface-container items-center justify-center rounded-lg"><MaterialIcons name={account.account_type === 'Checking' ? 'account-balance' : 'savings'} size={22} color="#43474d" /></View>
                      <View>
                        <Text className="font-body-md font-bold text-primary">{account.bank_name}</Text>
                        <Text className="text-caption text-on-surface-variant">{account.account_type} {account.account_number}</Text>
                      </View>
                    </View>
                    <MaterialIcons name="chevron-right" size={20} color="#43474d" />
                  </Pressable>
                ))}
              </View>
            </View>
          </View>
        </View>
      </ScrollView>
    </View>
  );
}