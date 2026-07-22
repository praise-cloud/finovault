import { useCallback, useEffect, useRef } from 'react';
import { Animated, Dimensions, Easing, StyleSheet, View } from 'react-native';

const { height: SCREEN_HEIGHT } = Dimensions.get('screen');
const DURATION = 600;

export function AnimatedSplashOverlay() {
  const opacity = useRef(new Animated.Value(1)).current;
  const scale = useRef(new Animated.Value(SCREEN_HEIGHT / 90)).current;

  const onFinish = useCallback(() => {
    Animated.parallel([
      Animated.timing(opacity, {
        toValue: 0,
        duration: DURATION - 120,
        delay: 120,
        easing: Easing.elastic(0.7),
        useNativeDriver: true,
      }),
      Animated.timing(scale, {
        toValue: 1,
        duration: DURATION - 120,
        delay: 120,
        easing: Easing.elastic(0.7),
        useNativeDriver: true,
      }),
    ]).start();
  }, [opacity, scale]);

  useEffect(() => {
    onFinish();
  }, [onFinish]);

  return (
    <Animated.View
      style={[
        styles.backgroundSolidColor,
        { opacity, transform: [{ scale }] },
      ]}
      pointerEvents="none"
    />
  );
}

export function AnimatedIcon() {
  return null;
}

const styles = StyleSheet.create({
  backgroundSolidColor: {
    ...StyleSheet.absoluteFill,
    backgroundColor: '#0A1F5C',
    zIndex: 1000,
  },
});
