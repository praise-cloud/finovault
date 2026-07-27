import { useState, useEffect, useCallback } from 'react';
import { View, Text, Pressable, Modal, ScrollView, useColorScheme, ActivityIndicator } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { router } from 'expo-router';
import { lightImpact, successNotification } from '@/src/hooks/use-haptics';
import * as NotificationsService from '@/src/lib/api/services/notifications';
import type { AppNotification } from '@/src/lib/api/services/notifications';
import { useNotificationStore } from '@/src/stores/notification-store';

const TYPE_CONFIG: Record<string, { icon: keyof typeof MaterialIcons.glyphMap; bg: string; color: string }> = {
  alert: { icon: 'warning', bg: 'bg-error-container', color: '#ba1a1a' },
  insight: { icon: 'auto-awesome', bg: 'bg-secondary-container', color: '#1A1A1A' },
  coaching: { icon: 'support-agent', bg: 'bg-secondary-container', color: '#1A1A1A' },
  fraud: { icon: 'verified-user', bg: 'bg-tertiary-container', color: '#321ed2' },
  milestone: { icon: 'emoji-events', bg: 'bg-primary-container', color: '#0A1F5C' },
};

const TYPE_ROUTES: Record<string, string> = {
  alert: '/(tabs)/fraud-protection',
  insight: '/(tabs)',
  fraud: '/(tabs)/security',
  milestone: '/(tabs)/wealth-growth',
};

function timeAgo(dateStr: string): string {
  const diff = Date.now() - new Date(dateStr).getTime();
  const mins = Math.floor(diff / 60000);
  if (mins < 2) return '1m ago';
  if (mins < 60) return `${mins}m ago`;
  const hours = Math.floor(mins / 60);
  if (hours < 2) return '1h ago';
  if (hours < 24) return `${hours}h ago`;
  const days = Math.floor(hours / 24);
  return `${days}d ago`;
}

export function NotificationIcon({ onPress, count }: { onPress: () => void; count: number }) {
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';
  return (
    <Pressable onPress={onPress} className="p-2 rounded-full active:scale-95 relative">
      <MaterialIcons name="notifications" size={22} color={isDark ? '#FFFFFF' : '#43474d'} />
      {count > 0 && (
        <View className="absolute -top-0.5 -right-0.5 min-w-[18px] h-[18px] rounded-full bg-error items-center justify-center px-1" style={{ borderWidth: 2, borderColor: isDark ? '#1A1A1A' : '#fff' }}>
          <Text className="text-white text-[10px] font-bold">{count > 9 ? '9+' : count}</Text>
        </View>
      )}
    </Pressable>
  );
}

export function NotificationModal({ visible, onClose }: { visible: boolean; onClose: () => void }) {
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';
  const [notifications, setNotifications] = useState<AppNotification[]>([]);
  const [loading, setLoading] = useState(false);
  const refreshCount = useNotificationStore((s) => s.refreshCount);

  useEffect(() => {
    if (visible) {
      setLoading(true);
      NotificationsService.listNotifications()
        .then(setNotifications)
        .catch(() => {})
        .finally(() => setLoading(false));
    }
  }, [visible]);

  const unreadCount = notifications.filter((n) => !n.read).length;

  const handleNotificationPress = async (n: AppNotification) => {
    lightImpact();
    if (!n.read) {
      await NotificationsService.markRead(n.id).catch(() => {});
      setNotifications((prev) => prev.map((item) => item.id === n.id ? { ...item, read: true } : item));
      refreshCount();
    }
    const route = TYPE_ROUTES[n.type];
    if (route) router.push(route as any);
    onClose();
  };

  const handleMarkAllRead = useCallback(async () => {
    successNotification();
    await NotificationsService.markAllRead().catch(() => {});
    setNotifications((prev) => prev.map((n) => ({ ...n, read: true })));
    refreshCount();
  }, [refreshCount]);

  return (
    <Modal visible={visible} transparent animationType="none" onRequestClose={onClose}>
      <Pressable className="flex-1 bg-black/40" onPress={onClose}>
        <View className="mt-20 mx-4 rounded-3xl max-h-[70%] overflow-hidden" style={{ backgroundColor: isDark ? '#1A1A1A' : '#FFFFFF', boxShadow: isDark ? '0 8px 24px rgba(0,0,0,0.4)' : '0 8px 24px rgba(0,0,0,0.15)', elevation: 16 }}>
          <View className="flex-row items-center justify-between px-6 pt-6 pb-4 border-b border-outline-variant/30">
            <View className="flex-row items-center gap-3">
              <Text className="font-headline-md text-primary font-bold">Notifications</Text>
              {unreadCount > 0 && (
                <View className="bg-error px-2 py-0.5 rounded-full"><Text className="text-white text-xs font-bold">{unreadCount} new</Text></View>
              )}
            </View>
            <Pressable onPress={onClose} className="w-8 h-8 rounded-full items-center justify-center active:scale-90" style={{ backgroundColor: isDark ? '#2A2A2A' : undefined }}>
              <MaterialIcons name="close" size={18} color={isDark ? '#FFFFFF' : '#43474d'} />
            </Pressable>
          </View>
          <ScrollView className="px-6 py-4" contentContainerStyle={{ paddingBottom: 24 }}>
            {loading ? (
              <View className="items-center py-12">
                <ActivityIndicator size="large" color="#08142E" />
              </View>
            ) : notifications.length === 0 ? (
              <View className="items-center py-12">
                <MaterialIcons name="notifications-none" size={48} color={isDark ? '#6B6F7A' : '#c4c6ca'} />
                <Text className="text-on-surface-variant text-body-md mt-4">No notifications yet</Text>
              </View>
            ) : (
              notifications.map((n, i) => {
                const config = TYPE_CONFIG[n.type] || TYPE_CONFIG.insight;
                return (
                  <View key={n.id}>
                    <Pressable onPress={() => handleNotificationPress(n)} className={`flex-row gap-4 p-4 rounded-xl mb-3 active:scale-[0.98] ${n.read ? '' : 'bg-secondary-container/20'}`} style={n.read ? { backgroundColor: isDark ? '#0F1A30' : '#FFFFFF' } : undefined}>
                      <View className={`w-10 h-10 rounded-full items-center justify-center ${config.bg}`}>
                        <MaterialIcons name={config.icon} size={20} color={config.color} />
                      </View>
                      <View className="flex-1">
                        <View className="flex-row justify-between items-start">
                          <Text className={`font-label-md flex-1 ${n.read ? 'text-on-surface' : 'text-primary font-bold'}`}>{n.title}</Text>
                          <Text className="text-caption text-on-surface-variant ml-2">{timeAgo(n.created_at)}</Text>
                        </View>
                        <Text className="text-body-md text-on-surface-variant mt-1">{n.body}</Text>
                      </View>
                      <View className="justify-center">
                        <MaterialIcons name="chevron-right" size={18} color={isDark ? '#6B6F7A' : '#c4c6ca'} />
                      </View>
                    </Pressable>
                  </View>
                );
              })
            )}
          </ScrollView>
          <View className="px-6 py-4 border-t border-outline-variant/30">
            <Pressable onPress={handleMarkAllRead} className="w-full py-3 bg-primary rounded-xl items-center active:scale-[0.98]">
              <Text className="text-on-primary font-label-md font-bold">Mark All as Read</Text>
            </Pressable>
          </View>
        </View>
      </Pressable>
    </Modal>
  );
}

export function useNotifications() {
  const [notifications, setNotifications] = useState<AppNotification[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    NotificationsService.listNotifications(20)
      .then(setNotifications)
      .catch(() => {})
      .finally(() => setLoading(false));
  }, []);

  const unreadCount = notifications.filter((n) => !n.read).length;
  return { notifications, unreadCount, loading };
}
