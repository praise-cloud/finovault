import { View, Text, Pressable, useColorScheme } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';

type AlertType = 'success' | 'error' | 'warning' | 'info';

type Props = {
  type: AlertType;
  title?: string;
  message: string;
  action?: { label: string; onPress: () => void };
  dismissible?: boolean;
  onDismiss?: () => void;
};

const CONFIG = {
  success: {
    icon: 'check-circle' as const,
    bg: 'bg-secondary-container',
    border: 'border-secondary',
    iconColor: '#1A1A1A',
    titleColor: 'text-on-secondary-container',
  },
  error: {
    icon: 'error' as const,
    bg: 'bg-error-container',
    border: 'border-error',
    iconColor: '#ba1a1a',
    titleColor: 'text-on-error-container',
  },
  warning: {
    icon: 'warning' as const,
    bg: 'bg-[#fff3e0]',
    border: 'border-[#ff9800]',
    iconColor: '#ff9800',
    titleColor: 'text-[#e65100]',
  },
  info: {
    icon: 'info' as const,
    bg: 'bg-primary-container',
    border: 'border-primary',
    iconColor: '#0A1F5C',
    titleColor: 'text-on-primary-container',
  },
};

export function AlertCard({ type, title, message, action, dismissible, onDismiss }: Props) {
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';
  const c = CONFIG[type];
  const iconColor = isDark
    ? { success: '#34D399', error: '#F87171', warning: '#FBBF24', info: '#60A5FA' }[type]
    : c.iconColor;

  return (
    <View className={`flex-row items-start gap-3 p-4 rounded-xl border-l-4 ${c.bg} ${c.border}`}>
      <MaterialIcons name={c.icon} size={22} color={iconColor} style={{ marginTop: 1 }} />
      <View className="flex-1">
        {title && <Text className={`font-label-md font-bold ${c.titleColor} mb-0.5`}>{title}</Text>}
        <Text className="font-body-md text-body-md text-on-surface-variant">{message}</Text>
        {action && (
          <Pressable onPress={action.onPress} className="mt-2 self-start">
            <Text className="font-label-md font-bold text-primary underline">{action.label}</Text>
          </Pressable>
        )}
      </View>
      {dismissible && onDismiss && (
        <Pressable onPress={onDismiss} className="p-1 active:scale-90">
          <MaterialIcons name="close" size={18} color={isDark ? '#9CA3B0' : '#74777e'} />
        </Pressable>
      )}
    </View>
  );
}
