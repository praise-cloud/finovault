import { StyleSheet, View, Text } from 'react-native';
import Animated, { Keyframe, Easing } from 'react-native-reanimated';

const DURATION = 400;

const fadeIn = new Keyframe({
  0: { opacity: 0, transform: [{ scale: 0.92 }] },
  100: { opacity: 1, transform: [{ scale: 1 }], easing: Easing.out(Easing.ease) },
});

export function AnimatedSplashOverlay() {
  return null;
}

export function AnimatedIcon() {
  return (
    <View style={styles.container}>
      <Animated.View entering={fadeIn.duration(DURATION)} style={styles.content}>
        <View style={styles.monogram}>
          <View style={styles.ring}>
            <View style={styles.chevron} />
          </View>
        </View>
        <Text style={styles.wordmark}>FINOVAULT</Text>
      </Animated.View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
    width: '100%',
    zIndex: 1000,
    position: 'absolute',
    top: 138,
  },
  content: {
    alignItems: 'center',
  },
  monogram: {
    width: 72,
    height: 72,
    alignItems: 'center',
    justifyContent: 'center',
  },
  ring: {
    width: 72,
    height: 72,
    borderRadius: 36,
    borderWidth: 2,
    borderColor: '#08142E',
    alignItems: 'center',
    justifyContent: 'center',
  },
  chevron: {
    width: 0,
    height: 0,
    borderLeftWidth: 12,
    borderRightWidth: 12,
    borderBottomWidth: 20,
    borderLeftColor: 'transparent',
    borderRightColor: 'transparent',
    borderBottomColor: '#08142E',
    transform: [{ rotate: '90deg' }],
  },
  wordmark: {
    fontFamily: 'Cinzel_700Bold',
    fontSize: 28,
    color: '#08142E',
    letterSpacing: 4,
    marginTop: 16,
  },
});
