import { useEffect, useRef } from 'react';
import { Animated, View, Text, StyleSheet, useColorScheme } from 'react-native';
import { VaultMonogram } from './vault-monogram';

const DURATION = 600;

export function AnimatedSplashOverlay() {
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';
  const fadeAnim = useRef(new Animated.Value(0)).current;
  const visible = useRef(new Animated.Value(1)).current;

  const scaleAnim = fadeAnim.interpolate({
    inputRange: [0, 1],
    outputRange: [0.92, 1],
  });

  useEffect(() => {
    Animated.sequence([
      Animated.timing(fadeAnim, {
        toValue: 1,
        duration: DURATION,
        useNativeDriver: true,
      }),
      Animated.timing(visible, {
        toValue: 0,
        duration: 200,
        delay: 400,
        useNativeDriver: true,
      }),
    ]).start();
  }, [fadeAnim, visible]);

  return (
    <Animated.View
      style={[styles.overlay, { opacity: visible, backgroundColor: isDark ? '#08142E' : '#F7F9FC', pointerEvents: 'none' }]}
    >
      <Animated.View style={{ opacity: fadeAnim, transform: [{ scale: scaleAnim }], alignItems: 'center' }}>
        <VaultMonogram size={72} flat />
        <Text style={styles.wordmark}>FINOVAULT</Text>
      </Animated.View>
    </Animated.View>
  );
}

export function AnimatedIcon() {
  return null;
}

const styles = StyleSheet.create({
  overlay: {
    ...StyleSheet.absoluteFillObject,
    zIndex: 1000,
    justifyContent: 'center',
    alignItems: 'center',
  },
  wordmark: {
    fontFamily: 'Cinzel_700Bold',
    fontSize: 28,
    color: '#08142E',
    letterSpacing: 4,
    marginTop: 16,
  },
});
