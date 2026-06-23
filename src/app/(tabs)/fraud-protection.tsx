import { useEffect } from 'react';
import { ScrollView, View, Text, Pressable, ActivityIndicator } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import Svg, { Circle } from 'react-native-svg';
import { useDashboardStore } from '@/stores/dashboard-store';

export default function FraudProtection() {
  const data = useDashboardStore((s) => s.fraudProtection);
  const isLoading = useDashboardStore((s) => s.isLoading);
  const load = useDashboardStore((s) => s.loadFraudProtection);

  useEffect(() => { load(); }, [load]);

  if (!data) {
    return <View className="flex-1 bg-background items-center justify-center"><ActivityIndicator size="large" color="#006b5a" /></View>;
  }

  const d = data;

  return (
    <View className="flex-1 bg-background">
      <View className="bg-surface-bright pt-14 pb-3 px-margin-mobile" style={{ shadowColor: '#000', shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.04, elevation: 4 }}>
        <View className="flex-row items-center justify-between">
          <View className="flex-row items-center gap-4">
            <Pressable className="active:scale-95 md:hidden"><MaterialIcons name="menu" size={24} color="#000f22" /></Pressable>
            <Text className="font-headline-md text-primary font-bold">Finovault AI</Text>
          </View>
          <View className="hidden md:flex-row md:gap-8 md:items-center">
            <View className="flex-row gap-6">
              <Text className="text-on-surface-variant font-label-md">Wealth Growth</Text>
              <Text className="text-on-surface-variant font-label-md">Smart Savings</Text>
              <Text className="text-primary font-label-md font-bold">Fraud Protection</Text>
              <Text className="text-on-surface-variant font-label-md">SME Analytics</Text>
            </View>
            <View className="w-10 h-10 rounded-full bg-surface-variant overflow-hidden border border-outline-variant items-center justify-center"><MaterialIcons name="person" size={22} color="#43474d" /></View>
          </View>
          <View className="md:hidden"><MaterialIcons name="account-circle" size={24} color="#000f22" /></View>
        </View>
      </View>

      <ScrollView className="flex-1 px-margin-mobile" contentContainerStyle={{ paddingBottom: 120 }}>
        <View className="mt-6 mb-6">
          <View className="flex-col md:flex-row md:items-end justify-between gap-4">
            <View>
              <Text className="font-headline-lg text-headline-lg text-primary mb-2">Fraud Protection</Text>
              <Text className="text-on-surface-variant text-body-lg max-w-2xl">Bank-grade vigilant AI monitoring your assets 24/7. Real-time encryption and neural threat detection active.</Text>
            </View>
            <View className="flex-row items-center gap-2 bg-secondary-container px-4 py-2 rounded-full self-start">
              <MaterialIcons name="verified-user" size={16} color="#00705e" />
              <Text className="text-on-secondary-container font-label-md font-bold">Vigilance Active</Text>
            </View>
          </View>
        </View>

        <View className="flex-row flex-wrap" style={{ gap: 24 }}>
          <View className="bg-surface-container-lowest rounded-xl p-md border border-outline-variant relative overflow-hidden" style={{ width: '100%', shadowColor: '#000', shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.04, shadowRadius: 20, elevation: 2 }}>
            <View className="relative z-10">
              <View className="flex-row justify-between items-start mb-lg">
                <Text className="font-headline-md text-primary">Security Score</Text>
                <MaterialIcons name="info" size={20} color="#006b5a" />
              </View>
              <View className="items-center py-4">
                <View className="relative w-48 h-48 items-center justify-center">
                  <Svg width={192} height={192} viewBox="0 0 100 100" style={{ transform: [{ rotate: '-90deg' }] }}>
                    <Circle cx={50} cy={50} r={45} fill="none" stroke="#e0e3e6" strokeWidth={8} />
                    <Circle cx={50} cy={50} r={45} fill="none" stroke="#006b5a" strokeDasharray="282.7" strokeDashoffset={282.7 - (282.7 * d.security_score / 100)} strokeLinecap="round" strokeWidth={8} />
                  </Svg>
                  <View className="absolute items-center">
                    <Text className="font-display-lg text-display-lg text-primary">{d.security_score}</Text>
                    <Text className="font-label-md text-on-surface-variant uppercase tracking-widest">Optimal</Text>
                  </View>
                </View>
              </View>
              <View style={{ gap: 16 }}>
                <View className="flex-row items-center justify-between p-3 bg-surface-container rounded-lg">
                  <View className="flex-row items-center gap-3">
                    <MaterialIcons name="check-circle" size={20} color="#006b5a" />
                    <Text className="text-body-md">Identity Verified</Text>
                  </View>
                  <Text className="text-secondary font-bold">Safe</Text>
                </View>
                <View className="flex-row items-center justify-between p-3 bg-surface-container rounded-lg">
                  <View className="flex-row items-center gap-3">
                    <MaterialIcons name="check-circle" size={20} color="#006b5a" />
                    <Text className="text-body-md">Encryption Level</Text>
                  </View>
                  <Text className="text-secondary font-bold">{d.metrics.encryption_level}</Text>
                </View>
              </View>
            </View>
            <View className="absolute top-0 right-0 w-64 h-64 bg-secondary/5 rounded-full" style={{ marginRight: -64, marginTop: -64 }} />
          </View>

          <View className="bg-surface-container-lowest rounded-xl p-md border border-outline-variant flex-1" style={{ shadowColor: '#000', shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.04, shadowRadius: 20, elevation: 2 }}>
            <View className="flex-row justify-between items-center mb-md">
              <Text className="font-headline-md text-primary">Real-time Monitoring</Text>
              <Pressable className="bg-surface-variant p-2 rounded-lg"><MaterialIcons name="filter-list" size={20} color="#43474d" /></Pressable>
            </View>
            <View style={{ gap: 12 }}>
              {d.events.map((event, i) => (
                <View key={event.id || i} className="p-md bg-surface-container-low rounded-xl flex-row items-start gap-4" style={{ borderLeftWidth: 4, borderLeftColor: event.severity === 'critical' ? '#ba1a1a' : event.severity === 'warning' ? '#006b5a' : '#060045' }}>
                  <View className={`p-3 rounded-full ${event.severity === 'critical' ? 'bg-error-container' : 'bg-secondary-container'}`}>
                    <MaterialIcons name={event.severity === 'critical' ? 'warning' : 'verified-user'} size={20} color={event.severity === 'critical' ? '#ba1a1a' : '#00705e'} />
                  </View>
                  <View className="flex-1">
                    <View className="flex-row justify-between">
                      <Text className="font-bold text-body-lg text-primary">{event.event_type}</Text>
                      <Text className="text-caption text-on-surface-variant">{getTimeAgo(event.timestamp)}</Text>
                    </View>
                    <Text className="text-on-surface-variant text-body-md mt-1">{event.description}</Text>
                  </View>
                </View>
              ))}
            </View>
            <Pressable className="mt-md w-full py-3 items-center rounded-xl"><Text className="text-secondary font-label-md">View Historical Logs</Text></Pressable>
          </View>

          <View className="w-full flex-row flex-wrap" style={{ gap: 24 }}>
            <View className="flex-1 min-w-[100px] flex-row items-center gap-4 p-md rounded-xl" style={{ backgroundColor: 'rgba(255,255,255,0.7)', borderWidth: 1, borderColor: 'rgba(230,235,241,0.5)' }}>
              <View className="w-12 h-12 rounded-xl bg-primary-container items-center justify-center"><MaterialIcons name="lock-open" size={20} color="#768dad" /></View>
              <View>
                <Text className="text-caption text-on-surface-variant uppercase tracking-tighter">Encryption</Text>
                <Text className="font-bold text-body-lg text-primary">End-to-End Tunnel</Text>
                <View className="flex-row items-center gap-1 mt-1"><View className="w-2 h-2 rounded-full bg-secondary" /><Text className="text-xs text-secondary">Active</Text></View>
              </View>
            </View>
            <View className="flex-1 min-w-[100px] flex-row items-center gap-4 p-md rounded-xl" style={{ backgroundColor: 'rgba(255,255,255,0.7)', borderWidth: 1, borderColor: 'rgba(230,235,241,0.5)' }}>
              <View className="w-12 h-12 rounded-xl bg-secondary-container items-center justify-center"><MaterialIcons name="psychology" size={20} color="#00705e" /></View>
              <View>
                <Text className="text-caption text-on-surface-variant uppercase tracking-tighter">AI Monitoring</Text>
                <Text className="font-bold text-body-lg text-primary">Neural Engine v4.2</Text>
                <View className="flex-row items-center gap-1 mt-1"><View className="w-2 h-2 rounded-full bg-secondary" /><Text className="text-xs text-secondary">Learning</Text></View>
              </View>
            </View>
            <View className="flex-1 min-w-[100px] flex-row items-center gap-4 p-md rounded-xl" style={{ backgroundColor: 'rgba(255,255,255,0.7)', borderWidth: 1, borderColor: 'rgba(230,235,241,0.5)' }}>
              <View className="w-12 h-12 rounded-xl bg-tertiary-fixed items-center justify-center"><MaterialIcons name="key" size={20} color="#321ed2" /></View>
              <View>
                <Text className="text-caption text-on-surface-variant uppercase tracking-tighter">Key Custody</Text>
                <Text className="font-bold text-body-lg text-primary">Hardware Isolated</Text>
                <View className="flex-row items-center gap-1 mt-1"><View className="w-2 h-2 rounded-full bg-secondary" /><Text className="text-xs text-secondary">Protected</Text></View>
              </View>
            </View>
          </View>

          <View className="w-full bg-primary rounded-xl overflow-hidden min-h-[300px] relative">
            <View className="absolute inset-0 opacity-40">
              <View className="absolute inset-0" style={{ backgroundColor: '#000f22' }} />
              <View className="absolute inset-0" style={{ backgroundColor: '#006b5a', opacity: 0.3 }} />
            </View>
            <View className="relative z-10 p-lg flex-col md:flex-row items-center justify-between gap-8">
              <View className="flex-1">
                <Text className="font-headline-lg text-headline-lg text-white mb-4">The Finovault Shield</Text>
                <Text className="text-body-md text-white/80 mb-6 leading-relaxed">Our proprietary AI architecture uses multi-dimensional analysis to detect fraud before it happens. Every transaction is cross-referenced with over 500 signals across our global network.</Text>
                <View className="flex-row flex-wrap gap-4">
                  <Pressable className="bg-secondary px-6 py-3 rounded-full active:scale-95"><Text className="text-on-secondary font-bold">Configure Guardrails</Text></Pressable>
                  <Pressable className="border border-outline-variant px-6 py-3 rounded-full active:scale-95"><Text className="text-white font-bold">Audit Report</Text></Pressable>
                </View>
              </View>
              <View className="w-64 h-64 bg-secondary/10 rounded-full border border-secondary/30 items-center justify-center p-4">
                <View className="w-full h-full bg-secondary/20 rounded-full border border-secondary/50 items-center justify-center p-4">
                  <View className="w-full h-full bg-secondary/40 rounded-full border border-secondary/70 items-center justify-center">
                    <MaterialIcons name="security" size={48} color="#ffffff" />
                  </View>
                </View>
              </View>
            </View>
          </View>
        </View>
      </ScrollView>
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