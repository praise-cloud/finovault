import { useEffect, useState } from 'react';
import { ScrollView, View, Text, Pressable, ActivityIndicator, useColorScheme } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { router } from 'expo-router';
import { getAuditLog } from '@/src/lib/api/services/settings';

type AuditEntry = {
  id: string;
  action: string;
  detail: string;
  timestamp: string;
  severity: 'info' | 'warning' | 'critical';
};

export default function AuditReport() {
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';
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
      case 'warning': return { bg: 'bg-secondary-container', text: isDark ? '#FFFFFF' : '#1A1A1A', icon: 'warning' as const };
      default: return { bg: 'bg-primary-container', text: '#ffffff', icon: 'info' as const };
    }
  };

  const criticalCount = audits.filter((a) => a.severity === 'critical').length;

  return (
    <View className="flex-1 bg-surface-bright" style={{ backgroundColor: isDark ? '#08142E' : '#FFFFFF' }}>
      <View className="bg-surface-bright pt-14 pb-3 px-margin-mobile" style={{ boxShadow: '0 4px 4px rgba(0,0,0,0.04)', elevation: 4 }}>
        <View className="flex-row items-center gap-3">
          <Pressable onPress={() => router.back()} className="w-9 h-9 rounded-full bg-[#EEF0F5] items-center justify-center active:scale-90">
            <MaterialIcons name="arrow-back" size={20} color={isDark ? '#9CA3B0' : '#43474d'} />
          </Pressable>
          <Text className={`font-body-bold font-bold ${isDark ? 'text-white' : 'text-[#1A1A1A]'}`} style={{ fontSize: 20 }}>Audit Report</Text>
        </View>
      </View>

      <ScrollView className="flex-1 px-margin-mobile" contentContainerStyle={{ paddingBottom: 120 }} showsVerticalScrollIndicator={false}>
        {loading ? (
          <View className="flex-1 items-center justify-center mt-20">
            <ActivityIndicator size="large" color={isDark ? '#FFFFFF' : '#1A1A1A'} />
          </View>
        ) : (
          <>
            <View className="flex-row flex-wrap mt-4 mb-6" style={{ gap: 12 }}>
              <View className={`border border-outline-variant/20 rounded-2xl p-4 flex-1 min-w-[100px] ${isDark ? 'bg-[#0D1B3E]' : 'bg-white'}`}>
                <Text className={`font-body uppercase tracking-wider ${isDark ? 'text-gray-400' : 'text-[#6B6F76]'}`} style={{ fontSize: 12 }}>Total Events</Text>
                <Text className={`font-body-bold font-bold ${isDark ? 'text-white' : 'text-[#1A1A1A]'}`} style={{ fontSize: 28 }}>{audits.length}</Text>
              </View>
              <View className={`border border-outline-variant/20 rounded-2xl p-4 flex-1 min-w-[100px] ${isDark ? 'bg-[#0D1B3E]' : 'bg-white'}`}>
                <Text className={`font-body uppercase tracking-wider ${isDark ? 'text-gray-400' : 'text-[#6B6F76]'}`} style={{ fontSize: 12 }}>Critical</Text>
                <Text className="font-body-bold text-[#BA1A1A] font-bold" style={{ fontSize: 28 }}>{criticalCount}</Text>
              </View>
              <View className={`border border-outline-variant/20 rounded-2xl p-4 flex-1 min-w-[100px] ${isDark ? 'bg-[#0D1B3E]' : 'bg-white'}`}>
                <Text className={`font-body uppercase tracking-wider ${isDark ? 'text-gray-400' : 'text-[#6B6F76]'}`} style={{ fontSize: 12 }}>This Month</Text>
                <Text className={`font-body-bold font-bold ${isDark ? 'text-white' : 'text-[#1A1A1A]'}`} style={{ fontSize: 28 }}>{audits.length}</Text>
              </View>
            </View>

            <View className={`border border-outline-variant/20 rounded-2xl overflow-hidden ${isDark ? 'bg-[#0D1B3E]' : 'bg-white'}`}>
              <View className="px-4 py-3.5 border-b border-outline-variant/10">
                <Text className={`font-body-semibold font-bold ${isDark ? 'text-white' : 'text-[#1A1A1A]'}`} style={{ fontSize: 14 }}>Activity Log</Text>
              </View>
              {audits.length === 0 ? (
                <View className="p-8 items-center">
                  <MaterialIcons name="assignment" size={40} color={isDark ? 'rgba(255,255,255,0.2)' : '#c4c6ca'} />
                  <Text className={`${isDark ? 'text-gray-400' : 'text-[#6B6F76]'}`} style={{ fontSize: 14 }}>No audit events recorded</Text>
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
                        <Text className={`font-body-semibold font-bold ${isDark ? 'text-white' : 'text-[#1A1A1A]'}`} style={{ fontSize: 14 }}>{entry.action}</Text>
                        <Text className={`${isDark ? 'text-gray-400' : 'text-[#6B6F76]'}`} style={{ fontSize: 14 }}>{entry.detail}</Text>
                        <Text className={`font-body mt-0.5 ${isDark ? 'text-gray-400' : 'text-[#6B6F76]'}`} style={{ fontSize: 12 }}>{entry.timestamp}</Text>
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
