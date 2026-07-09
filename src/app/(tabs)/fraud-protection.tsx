import { useEffect } from 'react';
import { ScrollView, View, Text, Pressable, ActivityIndicator } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import Svg, { Circle } from 'react-native-svg';
import { useDashboardStore } from '@/stores/dashboard-store';
import { router } from 'expo-router';
import { NotificationIcon, NotificationModal } from '@/components/notification-modal';
import { UserAvatar } from '@/components/user-avatar';

export default function FraudProtection() {
  const data = useDashboardStore((s) => s.fraudProtection);
  const isLoading = useDashboardStore((s) => s.isLoading);
  const load = useDashboardStore((s) => s.loadFraudProtection);
  useEffect(() => { load(); }, [load]);

  if (!data) {
    return <View className="flex-1 bg-background items-center justify-center"><ActivityIndicator size="large" color="#006b5a" /></View>;
  }

  const d = data;
  const statusCards = [
    { icon: 'lock-open' as const, label: 'Encryption', value: 'End-to-End Tunnel', status: 'Active', bg: 'bg-primary-container', color: '#768dad', dot: 'bg-secondary' },
    { icon: 'psychology' as const, label: 'AI Monitoring', value: 'Neural Engine v4.2', status: 'Learning', bg: 'bg-secondary-container', color: '#00705e', dot: 'bg-secondary' },
    { icon: 'key' as const, label: 'Key Custody', value: 'Hardware Isolated', status: 'Protected', bg: 'bg-tertiary-fixed', color: '#321ed2', dot: 'bg-secondary' },
    { icon: 'verified-user' as const, label: 'Identity', value: 'Verified Account', status: 'Confirmed', bg: 'bg-primary-container', color: '#000f22', dot: 'bg-secondary' },
  ];

  return (
    <View className="flex-1 bg-background">
      <View className="bg-surface-bright pt-14 pb-3 px-margin-mobile" style={{ shadowColor: '#000', shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.04, elevation: 4 }}>
        <View className="flex-row items-center justify-between">
          <View className="flex-row items-center gap-3">
            <View className="w-9 h-9 rounded-xl bg-primary items-center justify-center">
              <MaterialIcons name="shield" size={18} color="#fff" />
            </View>
            <Text className="font-headline-md text-primary font-bold">Protection</Text>
          </View>
          <View className="flex-row items-center gap-3">
            <NotificationIcon />
            <UserAvatar size={36} />
          </View>
        </View>
      </View>

      <ScrollView className="flex-1 px-margin-mobile" contentContainerStyle={{ paddingBottom: 120 }} showsVerticalScrollIndicator={false}>
        <View className="mt-4 mb-4">
          <View className="flex-row items-center gap-2 bg-secondary-container px-3 py-1.5 rounded-full self-start mb-3">
            <MaterialIcons name="verified-user" size={14} color="#00705e" />
            <Text className="text-on-secondary-container font-label-md font-bold">Vigilance Active</Text>
          </View>
          <Text className="font-headline-lg text-headline-lg text-primary">Fraud Protection</Text>
          <Text className="text-on-surface-variant text-body-md">Bank-grade AI monitoring your assets 24/7.</Text>
        </View>

        <View className="bg-surface-container-lowest rounded-2xl p-5 border border-outline-variant/20 mb-4 relative overflow-hidden">
          <View className="absolute -top-12 -right-12 w-40 h-40 bg-secondary/5 rounded-full" />
          <View className="flex-row items-center justify-between mb-4">
            <Text className="font-headline-md text-primary font-bold">Security Score</Text>
            <MaterialIcons name="info" size={20} color="#006b5a" />
          </View>
          <View className="items-center py-2">
            <View className="relative w-36 h-36 items-center justify-center">
              <Svg width={144} height={144} viewBox="0 0 100 100" style={{ transform: [{ rotate: '-90deg' }] }}>
                <Circle cx={50} cy={50} r={45} fill="none" stroke="#e0e3e6" strokeWidth={8} />
                <Circle cx={50} cy={50} r={45} fill="none" stroke="#006b5a" strokeDasharray="282.7" strokeDashoffset={282.7 - (282.7 * d.security_score / 100)} strokeLinecap="round" strokeWidth={8} />
              </Svg>
              <View className="absolute items-center">
                <Text className="font-display-lg text-display-lg text-primary">{d.security_score}</Text>
                <Text className="font-label-md text-on-surface-variant uppercase tracking-widest text-xs">Optimal</Text>
              </View>
            </View>
          </View>
          <View className="flex-row gap-3 mt-2">
            <View className="flex-1 flex-row items-center gap-2 p-2.5 bg-surface-container rounded-xl">
              <MaterialIcons name="check-circle" size={16} color="#006b5a" />
              <Text className="text-body-md text-xs flex-1">Identity Verified</Text>
              <Text className="text-secondary font-bold text-xs">Safe</Text>
            </View>
            <View className="flex-1 flex-row items-center gap-2 p-2.5 bg-surface-container rounded-xl">
              <MaterialIcons name="check-circle" size={16} color="#006b5a" />
              <Text className="text-body-md text-xs flex-1">Encryption</Text>
              <Text className="text-secondary font-bold text-xs">{d.metrics.encryption_level}</Text>
            </View>
          </View>
        </View>

        <View className="flex-row flex-wrap mb-4" style={{ gap: 12 }}>
          {statusCards.map((card) => (
            <View key={card.label} className="flex-row items-center gap-3 p-4 rounded-xl bg-white border border-outline-variant/20" style={{ width: '47%', shadowColor: '#000', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.04, shadowRadius: 8, elevation: 1 }}>
              <View className={`w-10 h-10 rounded-xl ${card.bg} items-center justify-center`}>
                <MaterialIcons name={card.icon} size={18} color={card.color} />
              </View>
              <View className="flex-1">
                <Text className="text-caption text-on-surface-variant uppercase tracking-tighter text-[10px]">{card.label}</Text>
                <Text className="font-bold text-sm text-primary" numberOfLines={1}>{card.value}</Text>
                <View className="flex-row items-center gap-1 mt-0.5">
                  <View className={`w-1.5 h-1.5 rounded-full ${card.dot}`} />
                  <Text className="text-xs text-secondary font-medium">{card.status}</Text>
                </View>
              </View>
            </View>
          ))}
        </View>

        <View className="bg-surface-container-lowest rounded-2xl p-5 border border-outline-variant/20 mb-4">
          <View className="flex-row justify-between items-center mb-4">
            <Text className="font-headline-md text-primary font-bold">Real-time Monitoring</Text>
            <Pressable className="bg-surface-variant p-2 rounded-lg"><MaterialIcons name="filter-list" size={18} color="#43474d" /></Pressable>
          </View>
          {d.events.map((event, i) => (
            <View key={event.id || i} className="flex-row items-start gap-3 p-3.5 bg-surface-container-low rounded-xl mb-2.5" style={{ borderLeftWidth: 3, borderLeftColor: event.severity === 'critical' ? '#ba1a1a' : event.severity === 'warning' ? '#006b5a' : '#060045' }}>
              <View className={`p-2 rounded-full ${event.severity === 'critical' ? 'bg-error-container' : 'bg-secondary-container'}`}>
                <MaterialIcons name={event.severity === 'critical' ? 'warning' : 'verified-user'} size={18} color={event.severity === 'critical' ? '#ba1a1a' : '#00705e'} />
              </View>
              <View className="flex-1">
                <View className="flex-row justify-between items-start">
                  <Text className="font-label-md font-bold text-primary">{event.event_type}</Text>
                  <Text className="text-caption text-on-surface-variant text-xs">{getTimeAgo(event.timestamp)}</Text>
                </View>
                <Text className="text-on-surface-variant text-body-md text-sm mt-0.5">{event.description}</Text>
              </View>
            </View>
          ))}
          <Pressable className="mt-2 w-full py-3 items-center rounded-xl active:scale-[0.98]"><Text className="text-secondary font-label-md font-bold">View Historical Logs</Text></Pressable>
        </View>

        <View className="bg-primary rounded-2xl overflow-hidden p-5 relative mb-4">
          <View className="absolute -bottom-12 -right-12 w-48 h-48 bg-secondary/10 rounded-full" />
          <View className="flex-row items-center justify-between mb-3">
            <Text className="font-headline-md text-white font-bold">The Finovault Shield</Text>
            <MaterialIcons name="security" size={24} color="#58fbda" />
          </View>
          <Text className="text-white/80 text-body-md mb-4">Multi-dimensional fraud detection analyzing 500+ signals across our global network.</Text>
          <View className="flex-row flex-wrap gap-3">
            <Pressable onPress={() => router.push('/(tabs)/guardrails' as any)} className="bg-secondary px-5 py-2.5 rounded-full active:scale-95">
              <Text className="text-on-secondary font-bold text-sm">Configure Guardrails</Text>
            </Pressable>
            <Pressable onPress={() => router.push('/(tabs)/audit-report' as any)} className="border border-white/30 px-5 py-2.5 rounded-full active:scale-95">
              <Text className="text-white font-bold text-sm">Audit Report</Text>
            </Pressable>
          </View>
        </View>
      </ScrollView>

      <NotificationModal />
    </View>
  );
}

function getTimeAgo(timestamp: string): string {
  const diff = Date.now() - new Date(timestamp).getTime();
  const mins = Math.floor(diff / 60000);
  if (mins < 2) return '1 min ago';
  if (mins < 60) return `${mins} mins ago`;
  const hours = Math.floor(mins / 60);
  if (hours < 2) return '1 hour ago';
  return `${hours} hours ago`;
}
