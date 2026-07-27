import { useEffect } from 'react';
import { View, useColorScheme } from 'react-native';
import Animated, { useAnimatedStyle, useSharedValue, withSpring } from 'react-native-reanimated';

type Props = {
  progress: number; // 0-100
  height?: number;
  className?: string;
  trackClassName?: string;
  fillClassName?: string;
};

export function ProgressBar({ progress, height = 8, className = '', trackClassName = '', fillClassName = '' }: Props) {
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';
  const width = useSharedValue(0);

  useEffect(() => {
    width.value = withSpring(progress, { damping: 20, stiffness: 90 });
  }, [progress]);

  const animatedStyle = useAnimatedStyle(() => ({
    width: `${width.value}%`,
  }));

  return (
    <View className={`w-full overflow-hidden rounded-full ${trackClassName}`} style={{ backgroundColor: isDark ? '#2A2A2A' : '#E1E4EC', height }}>
      <Animated.View
        className={`h-full rounded-full ${fillClassName}`}
        style={[animatedStyle, { backgroundColor: fillClassName ? undefined : (isDark ? '#D4AF37' : '#123B91'), height }]}
      />
    </View>
  );
}
