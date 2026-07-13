import { Image } from 'expo-image';
import { useEffect, useState } from 'react';
import { Dimensions, StyleSheet, View } from 'react-native';
import Animated, { useSharedValue, useAnimatedStyle, withTiming, withDelay, Easing, runOnJS } from 'react-native-reanimated';

const { height: SCREEN_HEIGHT } = Dimensions.get('screen');
const DURATION = 600;

export function AnimatedSplashOverlay() {
  const [visible, setVisible] = useState(true);
  const scale = useSharedValue(SCREEN_HEIGHT / 90);
  const opacity = useSharedValue(1);

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
    opacity: opacity.value,
  }));

  useEffect(() => {
    opacity.value = withDelay(
      120,
      withTiming(0, { duration: DURATION - 120, easing: Easing.elastic(0.7) }, (finished) => {
        if (finished) {
          runOnJS(setVisible)(false);
        }
      }),
    );
    scale.value = withDelay(
      120,
      withTiming(1, { duration: DURATION - 120, easing: Easing.elastic(0.7) }),
    );
  }, []);

  if (!visible) return null;

  return (
    <Animated.View style={[styles.backgroundSolidColor, animatedStyle]} />
  );
}

export function AnimatedIcon() {
  const iconScale = useSharedValue(INITIAL_SCALE_FACTOR);
  const glowRotate = useSharedValue(0);
  const logoScale = useSharedValue(1.3);
  const logoOpacity = useSharedValue(0);

  const iconStyle = useAnimatedStyle(() => ({
    transform: [{ scale: iconScale.value }],
  }));

  const glowStyle = useAnimatedStyle(() => ({
    transform: [{ rotateZ: `${glowRotate.value}deg` }],
  }));

  const logoStyle = useAnimatedStyle(() => ({
    transform: [{ scale: logoScale.value }],
    opacity: logoOpacity.value,
  }));

  useEffect(() => {
    iconScale.value = withTiming(1, { duration: DURATION, easing: Easing.elastic(0.7) });
    glowRotate.value = withTiming(7200, { duration: 60 * 1000 * 4 });
    logoOpacity.value = withDelay(240, withTiming(1, { duration: DURATION - 240, easing: Easing.elastic(0.7) }));
    logoScale.value = withDelay(240, withTiming(1, { duration: DURATION - 240, easing: Easing.elastic(0.7) }));
  }, []);

  return (
    <View style={styles.iconContainer}>
      <Animated.View style={[styles.glow, glowStyle]}>
        <Image style={styles.glow} source={require('@/assets/images/logo-glow.png')} />
      </Animated.View>

      <Animated.View style={[styles.background, iconStyle]} />
      <Animated.View style={[styles.imageContainer, logoStyle]}>
        <Image style={styles.image} source={require('@/assets/images/expo-logo.png')} />
      </Animated.View>
    </View>
  );
}

const INITIAL_SCALE_FACTOR = SCREEN_HEIGHT / 90;

const styles = StyleSheet.create({
  imageContainer: {
    justifyContent: 'center',
    alignItems: 'center',
  },
  glow: {
    width: 201,
    height: 201,
    position: 'absolute',
  },
  iconContainer: {
    justifyContent: 'center',
    alignItems: 'center',
    width: 128,
    height: 128,
    zIndex: 100,
  },
  image: {
    position: 'absolute',
    width: 76,
    height: 71,
  },
  background: {
    borderRadius: 40,
    backgroundColor: '#0274DF',
    width: 128,
    height: 128,
    position: 'absolute',
  },
  backgroundSolidColor: {
    ...StyleSheet.absoluteFill,
    backgroundColor: '#208AEF',
    zIndex: 1000,
  },
});
