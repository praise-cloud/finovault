import { useEffect, useRef } from 'react';
import { Animated, StyleSheet, Text, View } from 'react-native';
import { Image } from 'expo-image';

const DURATION = 600;

export function AnimatedSplashOverlay() {
  const fadeAnim = useRef(new Animated.Value(0)).current;
  const visible = useRef(new Animated.Value(1)).current;
  const scaleAnim = fadeAnim.interpolate({ inputRange: [0, 1], outputRange: [0.94, 1] });

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
      style={[styles.overlay, { opacity: visible, pointerEvents: 'none' }]}
    >
      <Animated.View style={{ opacity: fadeAnim, transform: [{ scale: scaleAnim }], alignItems: 'center' }}>
        <View style={styles.logoHolder}>
          <Image
            source={require('@/assets/images/logo-image.png')}
            style={styles.logo}
            contentFit="contain"
          />
        </View>
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
    backgroundColor: '#0D358C',
  },
  logoHolder: {
    width: 104,
    height: 104,
    alignItems: 'center',
    justifyContent: 'center',
  },
  logo: {
    width: 78,
    height: 78,
  },
  wordmark: {
    fontFamily: 'Montserrat_600SemiBold',
    fontSize: 12,
    color: '#FFFFFF',
    letterSpacing: 4.5,
    marginTop: 10,
  },
});
