import { Image } from 'expo-image';
import { View, Text, useColorScheme } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { useAuthStore } from '@/src/stores/auth-store';

type Props = {
  size?: number;
  name?: string;
  showBorder?: boolean;
};

export function UserAvatar({ size = 36, name, showBorder }: Props) {
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';
  const avatarUri = useAuthStore((s) => s.avatarUri);
  const fullName = name || useAuthStore((s) => s.user?.user_metadata?.full_name) || 'U';
  const initial = fullName.charAt(0).toUpperCase();

  if (avatarUri) {
    return (
      <View className={`overflow-hidden ${showBorder ? 'border-2 border-primary-fixed' : ''}`}
        style={{ width: size, height: size, borderRadius: size / 2 }}
      >
        <Image source={{ uri: avatarUri }} style={{ width: size, height: size }} contentFit="cover" />
      </View>
    );
  }

  return (
    <View
      className={`items-center justify-center overflow-hidden ${showBorder ? 'border-2 border-primary-fixed' : ''}`}
      style={{ width: size, height: size, borderRadius: size / 2, backgroundColor: isDark ? '#1A1A1A' : undefined }}
    >
      <Text className="font-bold" style={{ fontSize: size * 0.45, color: isDark ? '#D4AF37' : undefined }}>{initial}</Text>
    </View>
  );
}
