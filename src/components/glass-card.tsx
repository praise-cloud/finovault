import { PropsWithChildren } from 'react';
import { Pressable } from 'react-native';
import Animated, { useAnimatedStyle, useSharedValue, withSpring } from 'react-native-reanimated';
import { lightImpact } from '@/hooks/use-haptics';

type Props = PropsWithChildren<{
  className?: string;
  onPress?: () => void;
  index?: number;
}>;

export function GlassCard({ children, className = '', onPress, index = 0 }: Props) {
  const scale = useSharedValue(1);

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
      style={[animatedStyle, { backgroundColor: 'rgba(255,255,255,0.7)', borderWidth: 0 }]}
      className={`bg-white/70 rounded-xl border border-outline-variant/50 ${className}`}
    >
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
