import { useEffect, useState } from 'react';
import { ScrollView, View, Text, Pressable, ActivityIndicator } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { router } from 'expo-router';
import { getAuditLog } from '@/lib/api/services/settings';

type AuditEntry = {
  id: string;
  action: string;
  detail: string;
  timestamp: string;
  severity: 'info' | 'warning' | 'critical';
};

export default function AuditReport() {
  const [audits, setAudits] = useState<AuditEntry[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    getAuditLog()
      .then((data) => setAudits(data))
      .catch(() => {})
      .finally(() => setLoading(false));
  }, []);

  const getSeverityColor = (s: string) => {
    switch (s) {
      case 'critical': return { bg: 'bg-error-container', text: '#ba1a1a', icon: 'error' as const };
      case 'warning': return { bg: 'bg-secondary-container', text: '#00705e', icon: 'warning' as const };
      default: return { bg: 'bg-primary-container', text: '#ffffff', icon: 'info' as const };
    }
  };

  const criticalCount = audits.filter((a) => a.severity === 'critical').length;

  return (
    <View className="flex-1 bg-surface-bright">
      <View className="bg-surface-bright pt-14 pb-3 px-margin-mobile" style={{ shadowColor: '#000', shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.04, elevation: 4 }}>
        <View className="flex-row items-center gap-3">
          <Pressable onPress={() => router.back()} className="w-9 h-9 rounded-xl bg-surface-variant items-center justify-center active:scale-90">
            <MaterialIcons name="arrow-back" size={20} color="#43474d" />
          </Pressable>
          <Text className="font-headline-md text-primary font-bold">Audit Report</Text>
        </View>
      </View>

      <ScrollView className="flex-1 px-margin-mobile" contentContainerStyle={{ paddingBottom: 120 }} showsVerticalScrollIndicator={false}>
        {loading ? (
          <View className="flex-1 items-center justify-center mt-20">
            <ActivityIndicator size="large" color="#00705e" />
          </View>
        ) : (
          <>
            <View className="flex-row flex-wrap mt-4 mb-6" style={{ gap: 12 }}>
              <View className="bg-white border border-outline-variant/20 rounded-2xl p-4 flex-1 min-w-[100px]">
                <Text className="text-caption text-on-surface-variant uppercase tracking-wider text-xs">Total Events</Text>
                <Text className="font-headline-lg text-headline-lg text-primary font-bold">{audits.length}</Text>
              </View>
              <View className="bg-white border border-outline-variant/20 rounded-2xl p-4 flex-1 min-w-[100px]">
                <Text className="text-caption text-on-surface-variant uppercase tracking-wider text-xs">Critical</Text>
                <Text className="font-headline-lg text-headline-lg text-error font-bold">{criticalCount}</Text>
              </View>
              <View className="bg-white border border-outline-variant/20 rounded-2xl p-4 flex-1 min-w-[100px]">
                <Text className="text-caption text-on-surface-variant uppercase tracking-wider text-xs">This Month</Text>
                <Text className="font-headline-lg text-headline-lg text-primary font-bold">{audits.length}</Text>
              </View>
            </View>

            <View className="bg-white border border-outline-variant/20 rounded-2xl overflow-hidden">
              <View className="px-4 py-3.5 border-b border-outline-variant/10">
                <Text className="font-label-md text-primary font-bold">Activity Log</Text>
              </View>
              {audits.length === 0 ? (
                <View className="p-8 items-center">
                  <MaterialIcons name="assignment" size={40} color="#c4c6ca" />
                  <Text className="text-on-surface-variant text-sm mt-2">No audit events recorded</Text>
                </View>
              ) : (
                audits.map((entry, i) => {
                  const sev = getSeverityColor(entry.severity);
                  return (
                    <View key={entry.id} className={`flex-row items-start gap-3 p-4 ${i < audits.length - 1 ? 'border-b border-outline-variant/10' : ''}`}>
                      <View className={`w-9 h-9 rounded-full items-center justify-center ${sev.bg}`}>
                        <MaterialIcons name={sev.icon} size={18} color={sev.text} />
                      </View>
                      <View className="flex-1">
                        <Text className="font-label-md font-bold text-primary">{entry.action}</Text>
                        <Text className="text-body-md text-on-surface-variant text-sm">{entry.detail}</Text>
                        <Text className="text-caption text-on-surface-variant text-xs mt-0.5">{entry.timestamp}</Text>
                      </View>
                    </View>
                  );
                })
              )}
            </View>
          </>
        )}
      </ScrollView>
    </View>
  );
}
