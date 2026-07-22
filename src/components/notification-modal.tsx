import { useState, useEffect, useCallback } from 'react';
import { View, Text, Pressable, Modal, ScrollView } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { router } from 'expo-router';
import Animated from 'react-native-reanimated';
import { lightImpact, successNotification } from '@/hooks/use-haptics';

export type NotificationType = 'alert' | 'insight' | 'transaction' | 'security';

type Notification = {
  id: string;
  title: string;
  message: string;
  type: NotificationType;
  time: string;
  read: boolean;
};

const MOCK_NOTIFICATIONS: Notification[] = [
  { id: '1', title: 'Large Transaction Detected', message: 'A transaction of $12,500 was detected. Review recommended.', type: 'alert', time: '2 min ago', read: false },
  { id: '2', title: 'AI Insight Available', message: 'New investment opportunity identified in your portfolio.', type: 'insight', time: '15 min ago', read: false },
  { id: '3', title: 'Security Check Passed', message: 'Regular security scan complete. No threats detected.', type: 'security', time: '1 hour ago', read: false },
  { id: '4', title: 'Monthly Report Ready', message: 'Your June financial summary is now available.', type: 'insight', time: '3 hours ago', read: true },
  { id: '5', title: 'Budget Alert', message: 'You have used 80% of your monthly spending limit.', type: 'alert', time: '5 hours ago', read: true },
  { id: '6', title: 'Deposit Received', message: '$3,200 deposited into Checking Account.', type: 'transaction', time: '1 day ago', read: true },
];

const TYPE_CONFIG = {
  alert: { icon: 'warning' as const, bg: 'bg-error-container', color: '#ba1a1a' },
  insight: { icon: 'auto-awesome' as const, bg: 'bg-secondary-container', color: '#1A1A1A' },
  transaction: { icon: 'account-balance' as const, bg: 'bg-primary-container', color: '#0A1F5C' },
  security: { icon: 'verified-user' as const, bg: 'bg-tertiary-container', color: '#321ed2' },
};

const TYPE_ROUTES: Record<NotificationType, string> = {
  alert: '/(tabs)/fraud-protection',
  insight: '/(tabs)',
  transaction: '/(tabs)/wealth-growth',
  security: '/(tabs)/security',
};

export function NotificationIcon({ onPress, count }: { onPress: () => void; count: number }) {
  return (
    <Pressable onPress={onPress} className="p-2 rounded-full active:scale-95 relative">
      <MaterialIcons name="notifications" size={22} color="#43474d" />
      {count > 0 && (
        <View className="absolute -top-0.5 -right-0.5 min-w-[18px] h-[18px] rounded-full bg-error items-center justify-center px-1" style={{ borderWidth: 2, borderColor: '#fff' }}>
          <Text className="text-white text-[10px] font-bold">{count > 9 ? '9+' : count}</Text>
        </View>
      )}
    </Pressable>
  );
}

export function NotificationModal({ visible, onClose }: { visible: boolean; onClose: () => void }) {
  const [notifications, setNotifications] = useState(MOCK_NOTIFICATIONS);

  useEffect(() => {
    if (visible) {
      setNotifications((prev) => prev.map((n) => ({ ...n, read: true })));
    }
  }, [visible]);

  const unreadCount = notifications.filter((n) => !n.read).length;

  const handleNotificationPress = (n: Notification) => {
    lightImpact();
    setNotifications((prev) => prev.map((item) => item.id === n.id ? { ...item, read: true } : item));
    const route = TYPE_ROUTES[n.type];
    if (route) router.push(route as any);
    onClose();
  };

  const handleMarkAllRead = useCallback(() => {
    successNotification();
    setNotifications((prev) => prev.map((n) => ({ ...n, read: true })));
  }, []);

  return (
    <Modal visible={visible} transparent animationType="none" onRequestClose={onClose}>
      <Pressable className="flex-1 bg-black/40" onPress={onClose}>
        <View className="mt-20 mx-4 bg-white rounded-3xl max-h-[70%] overflow-hidden" style={{ shadowColor: '#000', shadowOffset: { width: 0, height: 8 }, shadowOpacity: 0.15, shadowRadius: 24, elevation: 16 }}>
          <View className="flex-row items-center justify-between px-6 pt-6 pb-4 border-b border-outline-variant/30">
            <View className="flex-row items-center gap-3">
              <Text className="font-headline-md text-primary font-bold">Notifications</Text>
              {unreadCount > 0 && (
                <View className="bg-error px-2 py-0.5 rounded-full"><Text className="text-white text-xs font-bold">{unreadCount} new</Text></View>
              )}
            </View>
            <Pressable onPress={onClose} className="w-8 h-8 rounded-full bg-surface-variant items-center justify-center active:scale-90">
              <MaterialIcons name="close" size={18} color="#43474d" />
            </Pressable>
          </View>
          <ScrollView className="px-6 py-4" contentContainerStyle={{ paddingBottom: 24 }}>
            {notifications.length === 0 ? (
              <View className="items-center py-12">
                <MaterialIcons name="notifications-none" size={48} color="#c4c6ca" />
                <Text className="text-on-surface-variant text-body-md mt-4">No notifications yet</Text>
              </View>
            ) : (
              notifications.map((n, i) => {
                const config = TYPE_CONFIG[n.type];
                return (
                  <View key={n.id}>
                    <Pressable onPress={() => handleNotificationPress(n)} className={`flex-row gap-4 p-4 rounded-xl mb-3 active:scale-[0.98] ${n.read ? 'bg-white' : 'bg-secondary-container/20'}`}>
                      <View className={`w-10 h-10 rounded-full items-center justify-center ${config.bg}`}>
                        <MaterialIcons name={config.icon} size={20} color={config.color} />
                      </View>
                      <View className="flex-1">
                        <View className="flex-row justify-between items-start">
                          <Text className={`font-label-md flex-1 ${n.read ? 'text-on-surface' : 'text-primary font-bold'}`}>{n.title}</Text>
                          <Text className="text-caption text-on-surface-variant ml-2">{n.time}</Text>
                        </View>
                        <Text className="text-body-md text-on-surface-variant mt-1">{n.message}</Text>
                      </View>
                      <View className="justify-center">
                        <MaterialIcons name="chevron-right" size={18} color="#c4c6ca" />
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
  const [notifications] = useState(MOCK_NOTIFICATIONS);
  const unreadCount = notifications.filter((n) => !n.read).length;
  return { notifications, unreadCount };
}
