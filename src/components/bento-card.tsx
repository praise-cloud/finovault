import { PropsWithChildren } from 'react';
import { View, Pressable } from 'react-native';
import {
  useAnimatedStyle,
  useSharedValue,
  withSpring,
} from 'react-native-reanimated';
import Animated from 'react-native-reanimated';
import { lightImpact } from '@/hooks/use-haptics';
import { playSound } from '@/lib/sounds';

type Props = PropsWithChildren<{
  className?: string;
  onPress?: () => void;
}>;

export function BentoCard({ children, className = '', onPress }: Props) {
  const scale = useSharedValue(1);

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
  }));

  const handlePressIn = () => {
    scale.value = withSpring(0.98, { damping: 15 });
    lightImpact();
  };

  const handlePressOut = () => {
    scale.value = withSpring(1, { damping: 15 });
  };

  const handlePress = () => {
    playSound('open');
    onPress?.();
  };

  return (
    <Pressable onPress={handlePress} onPressIn={handlePressIn} onPressOut={handlePressOut}>
      <Animated.View style={animatedStyle}>
        <View
          className={`bg-surface-container-lowest rounded-xl p-md border border-outline-variant/30 shadow-sm ${className}`}
          style={{ shadowColor: '#000', shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.04, shadowRadius: 20, elevation: 2 }}
        >
          {children}
        </View>
      </Animated.View>
    </Pressable>
  );
}
