import { useColorScheme } from 'react-native';
import { router } from 'expo-router';
import { useCallback, useEffect, useRef, useState } from 'react';
import { Dimensions, Pressable, Text, View } from 'react-native';
import { useAuthStore } from '@/stores/auth-store';
import Animated, {
  runOnUI,
  useAnimatedStyle,
  useSharedValue,
  withTiming,
  Easing,
} from 'react-native-reanimated';
import { MaterialIcons } from '@expo/vector-icons';
import { VaultMonogram } from '@/components/vault-monogram';

const { width: SCREEN_WIDTH } = Dimensions.get('window');

const SLIDES = [
  {
    title: 'One vault for all your money',
    subtitle: 'AI analyzes your finances, predicts trends, and optimizes your wealth in real time.',
    icon: 'account-balance' as const,
  },
  {
    title: 'Bank-grade protection, always',
    subtitle: 'AES-256 encryption and neural fraud detection keep your assets safe 24/7.',
    icon: 'shield' as const,
  },
  {
    title: 'Growth that adapts to you',
    subtitle: 'Personal AI suggestions and smart savings automation for complete financial health.',
    icon: 'trending-up' as const,
  },
];

export default function WelcomeTour() {
  const isAuthenticated = useAuthStore((s) => s.isAuthenticated);
  const [currentIndex, setCurrentIndex] = useState(0);
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';

  useEffect(() => {
    if (isAuthenticated) router.replace('/(tabs)');
  }, [isAuthenticated]);

  const currentIndexRef = useRef(0);
  const translateX = useSharedValue(0);

  const goToSlide = useCallback((index: number) => {
    currentIndexRef.current = index;
    runOnUI((nextIndex: number) => {
      'worklet';
      translateX.value = withTiming(-nextIndex * SCREEN_WIDTH, { duration: 400, easing: Easing.inOut(Easing.ease) });
    })(index);
    setCurrentIndex(index);
  }, [translateX]);

  const carouselStyle = useAnimatedStyle(() => ({ transform: [{ translateX: translateX.value }] }));
  const bg = isDark ? '#08142E' : '#F7F9FC';
  const textColor = isDark ? '#FFFFFF' : '#1A1A1A';
  const textMuted = isDark ? 'rgba(255,255,255,0.6)' : '#43474D';

  return (
    <View className="flex-1" style={{ backgroundColor: bg }}>
      {/* Thin progress bar at top */}
      <View className="absolute top-0 left-0 right-0 z-10 h-0.5" style={{ backgroundColor: isDark ? 'rgba(255,255,255,0.1)' : '#E4E7EE' }}>
        <Animated.View
          style={{
            width: `${((currentIndex + 1) / SLIDES.length) * 100}%`,
            height: '100%',
            backgroundColor: '#08142E',
          }}
        />
      </View>

      <Pressable
        onPress={() => router.replace('/login')}
        className="absolute top-14 right-5 z-10 px-5 py-2 rounded-full active:scale-95"
        style={{ backgroundColor: isDark ? 'rgba(255,255,255,0.08)' : 'rgba(0,0,0,0.04)', borderWidth: 1, borderColor: isDark ? 'rgba(255,255,255,0.1)' : 'rgba(0,0,0,0.08)' }}
      >
        <Text className="font-body-medium text-caption" style={{ color: textMuted }}>Skip</Text>
      </Pressable>

      <View className="flex-1 justify-center px-10">
        <View className="overflow-hidden" style={{ maxHeight: SCREEN_WIDTH * 0.45 }}>
          <Animated.View className="flex-row" style={[{ width: SCREEN_WIDTH * SLIDES.length, height: SCREEN_WIDTH * 0.4 }, carouselStyle]}>
            {SLIDES.map((slide, index) => (
              <View key={index} style={{ width: SCREEN_WIDTH }} className="items-center justify-center">
                <View className="w-24 h-24 rounded-full items-center justify-center" style={{ backgroundColor: isDark ? 'rgba(8,20,46,0.15)' : 'rgba(8,20,46,0.08)' }}>
                  <MaterialIcons name={slide.icon} size={36} color="#08142E" />
                </View>
              </View>
            ))}
          </Animated.View>
        </View>

        <View className="items-center px-4" style={{ marginTop: 40 }}>
          <Text
            className="font-display text-center"
            style={{ fontSize: 34, lineHeight: 38, color: textColor }}
          >
            {SLIDES[currentIndex].title}
          </Text>
          <Text
            className="font-body text-center mt-4"
            style={{ fontSize: 16, lineHeight: 24, color: textMuted }}
          >
            {SLIDES[currentIndex].subtitle}
          </Text>
        </View>

        {/* Slide indicator */}
        <View className="flex-row justify-center items-center gap-1.5 mt-8">
          {SLIDES.map((_, index) => (
            <Pressable key={index} onPress={() => goToSlide(index)} className="px-1 py-2">
              <View
                style={{
                  width: index === currentIndex ? 24 : 6,
                  height: 6,
                  borderRadius: 3,
                  backgroundColor: index === currentIndex ? '#08142E' : isDark ? 'rgba(255,255,255,0.2)' : '#c4c6ce',
                }}
              />
            </Pressable>
          ))}
        </View>
      </View>

      {/* Bottom CTAs */}
      <View className="px-8 pb-12 gap-3">
        <Pressable
          onPress={() => router.replace('/login')}
          className="w-full py-3.5 items-center justify-center active:scale-[0.98]"
          style={{ backgroundColor: 'rgba(8,20,46,0.08)', borderRadius: 9999, borderWidth: 1.5, borderColor: '#08142E' }}
        >
          <Text className="font-body-semibold" style={{ fontSize: 16, color: '#08142E' }}>Log in</Text>
        </Pressable>
        <Pressable
          onPress={() => router.replace('/signup')}
          className="w-full py-3.5 items-center justify-center active:scale-[0.98]"
          style={{ backgroundColor: isDark ? 'rgba(255,255,255,0.08)' : '#EEF0F5', borderRadius: 9999 }}
        >
          <Text className="font-body-semibold" style={{ fontSize: 16, color: isDark ? '#FFFFFF' : '#1A1A1A' }}>Register</Text>
        </Pressable>
      </View>
    </View>
  );
}
