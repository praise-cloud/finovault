import { View, Text, Pressable } from 'react-native';
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
    iconColor: '#00705e',
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
    iconColor: '#000f22',
    titleColor: 'text-on-primary-container',
  },
};

export function AlertCard({ type, title, message, action, dismissible, onDismiss }: Props) {
  const c = CONFIG[type];

  return (
    <View className={`flex-row items-start gap-3 p-4 rounded-xl border-l-4 ${c.bg} ${c.border}`}>
      <MaterialIcons name={c.icon} size={22} color={c.iconColor} style={{ marginTop: 1 }} />
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
          <MaterialIcons name="close" size={18} color="#74777e" />
        </Pressable>
      )}
    </View>
  );
}
