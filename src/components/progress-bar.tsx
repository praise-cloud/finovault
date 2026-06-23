import { useEffect } from 'react';
import { View } from 'react-native';
import Animated, { useAnimatedStyle, useSharedValue, withTiming } from 'react-native-reanimated';

type Props = {
  progress: number; // 0-100
  height?: number;
  className?: string;
  trackClassName?: string;
  fillClassName?: string;
};

export function ProgressBar({ progress, height = 8, className = '', trackClassName = '', fillClassName = '' }: Props) {
  const width = useSharedValue(0);

  useEffect(() => {
    width.value = withTiming(progress, { duration: 1500 });
  }, [progress]);

  const animatedStyle = useAnimatedStyle(() => ({
    width: `${width.value}%`,
  }));

  return (
    <View className={`w-full bg-surface-container-high overflow-hidden rounded-full ${trackClassName}`} style={{ height }}>
      <Animated.View
        className={`h-full rounded-full ${fillClassName || 'bg-secondary'}`}
        style={[animatedStyle, { height }]}
      />
    </View>
  );
}
