import { PropsWithChildren } from 'react';
import { Pressable, View, useColorScheme } from 'react-native';

type Props = PropsWithChildren<{
  className?: string;
  onPress?: () => void;
  style?: any;
}>;

export function FlatCard({ children, className = '', onPress, style }: Props) {
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';

  const cardStyle = {
    backgroundColor: isDark ? 'rgba(255,255,255,0.06)' : '#FFFFFF',
    borderRadius: 18,
    borderWidth: 1,
    borderColor: isDark ? 'rgba(255,255,255,0.12)' : '#E4E7EE',
    boxShadow: isDark ? '0 2px 12px rgba(0,0,0,0.2)' : '0 2px 12px rgba(8,20,46,0.06)',
    elevation: 4,
  };

  if (onPress) {
    return (
      <Pressable onPress={onPress} className={className} style={[cardStyle, style]}>
        {children}
      </Pressable>
    );
  }

  return (
    <View className={className} style={[cardStyle, style]}>
      {children}
    </View>
  );
}
