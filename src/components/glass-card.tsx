import { PropsWithChildren } from 'react';
import { Pressable, useColorScheme } from 'react-native';
import Animated, { useAnimatedStyle, useSharedValue, withSpring } from 'react-native-reanimated';
import { lightImpact } from '@/hooks/use-haptics';

type Props = PropsWithChildren<{
  className?: string;
  onPress?: () => void;
  index?: number;
}>;

const GLASS_FILL = 'rgba(255,255,255,0.08)';
const NAVY_BORDER = 'rgba(8,20,46,0.2)';

export function GlassCard({ children, className = '', onPress }: Props) {
  const scale = useSharedValue(1);
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
  }));

  const handlePressIn = () => {
    scale.value = withSpring(0.98, { damping: 15 });
    if (onPress) lightImpact();
  };

  const handlePressOut = () => {
    scale.value = withSpring(1, { damping: 15 });
  };

  const content = (
    <Animated.View
      style={[
        animatedStyle,
        {
          backgroundColor: isDark ? GLASS_FILL : 'rgba(255,255,255,0.7)',
          borderWidth: 1,
          borderColor: isDark ? NAVY_BORDER : 'rgba(8,20,46,0.12)',
          borderRadius: 14,
          boxShadow: `0 4px 24px rgba(0,0,0,${isDark ? 0.5 : 0.35})`,
          elevation: 8,
        },
      ]}
    >
      <Animated.View
        style={{
          position: 'absolute',
          top: 0,
          left: 0,
          right: 0,
          height: 1,
          backgroundColor: 'rgba(255,255,255,0.06)',
          borderTopLeftRadius: 14,
          borderTopRightRadius: 14,
        }}
      />
      {children}
    </Animated.View>
  );

  if (onPress) {
    return (
      <Pressable onPress={onPress} onPressIn={handlePressIn} onPressOut={handlePressOut}>
        {content}
      </Pressable>
    );
  }

  return content;
}
