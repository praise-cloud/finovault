import { router } from 'expo-router';
import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { Dimensions, PanResponder, Pressable, Text, View } from 'react-native';
import { useAuthStore } from '@/stores/auth-store';
import Animated, {
  Easing,
  useAnimatedStyle,
  useSharedValue,
  withDelay,
  withRepeat,
  withSequence,
  withSpring,
  withTiming,
} from 'react-native-reanimated';
import { MaterialIcons } from '@expo/vector-icons';
import { playSound } from '@/lib/sounds';

const { width: SCREEN_WIDTH } = Dimensions.get('window');

const SLIDES = [
  {
    title: 'Smart Financial AI',
    subtitle: 'Finovault uses advanced AI to analyze your finances, predict market trends, and optimize your wealth in real time.',
    icon: 'auto-awesome' as const,
    animationDelay: 0,
  },
  {
    title: 'Bank-Grade Protection',
    subtitle: 'Enterprise-level fraud detection and AES-256 encryption keep your assets safe, monitored 24/7 by our neural network.',
    icon: 'shield' as const,
    animationDelay: 1000,
  },
  {
    title: 'Intelligent Growth',
    subtitle: 'Personalized AI-driven suggestions, smart savings automation, and a complete view of your financial health in one place.',
    icon: 'auto-awesome' as const,
    animationDelay: 2000,
  },
];

export default function WelcomeTour() {
  const isAuthenticated = useAuthStore((s) => s.isAuthenticated);
  const [currentIndex, setCurrentIndex] = useState(0);
  const skipTimerRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  useEffect(() => {
    if (isAuthenticated) {
      router.replace('/(tabs)');
    }
  }, [isAuthenticated]);

  const currentIndexRef = useRef(0);
  const translateX = useSharedValue(0);
  const floatY1 = useSharedValue(0);
  const floatY2 = useSharedValue(0);
  const floatY3 = useSharedValue(0);
  const floatStyle1 = useAnimatedStyle(() => ({ transform: [{ translateY: floatY1.value }] }));
  const floatStyle2 = useAnimatedStyle(() => ({ transform: [{ translateY: floatY2.value }] }));
  const floatStyle3 = useAnimatedStyle(() => ({ transform: [{ translateY: floatY3.value }] }));
  const floatStyles = [floatStyle1, floatStyle2, floatStyle3];

  useEffect(() => {
    [floatY1, floatY2, floatY3].forEach((y, i) => {
      y.value = withDelay(i * 1000, withRepeat(withSequence(withTiming(-15, { duration: 3000, easing: Easing.inOut(Easing.sin) }), withTiming(0, { duration: 3000, easing: Easing.inOut(Easing.sin) })), -1, true));
    });
  }, []);

  const goToSlide = useCallback((index: number) => {
    currentIndexRef.current = index;
    translateX.value = withTiming(-index * SCREEN_WIDTH, { duration: 400, easing: Easing.inOut(Easing.ease) });
    requestAnimationFrame(() => setCurrentIndex(index));
  }, [translateX]);

  const nextSlide = useCallback(() => goToSlide((currentIndexRef.current + 1) % SLIDES.length), [goToSlide]);
  const prevSlide = useCallback(() => goToSlide((currentIndexRef.current - 1 + SLIDES.length) % SLIDES.length), [goToSlide]);

  useEffect(() => {
    const id = setInterval(() => goToSlide((currentIndexRef.current + 1) % SLIDES.length), 5000);
    return () => clearInterval(id);
  }, [goToSlide]);

  useEffect(() => {
    playSound('welcome');
  }, []);

  const panResponder = useMemo(() => PanResponder.create({
    onMoveShouldSetPanResponder: (_, gs) => Math.abs(gs.dx) > 5 && Math.abs(gs.dx) > Math.abs(gs.dy),
    onPanResponderRelease: (_, gs) => {
      if (Math.abs(gs.dx) > 50) {
        if (gs.dx > 0) prevSlide();
        else nextSlide();
      }
    },
  }), [prevSlide, nextSlide]);

  const carouselStyle = useAnimatedStyle(() => ({ transform: [{ translateX: translateX.value }] }));

  const handleSkip = () => {
    router.replace('/getting-started');
  };

  return (
    <View className="flex-1 bg-primary">
      <View className="absolute -top-24 -right-24 w-72 h-72 rounded-full bg-white/5" />
      <View className="absolute top-1/3 -left-20 w-56 h-56 rounded-full bg-white/5" />
      <View className="absolute bottom-40 -right-16 w-48 h-48 rounded-full bg-white/5" />

      <Pressable onPress={handleSkip} className="absolute top-14 right-5 z-10 px-5 py-2 rounded-full bg-white/15 active:scale-95">
        <Text className="text-white font-label-md font-bold">Skip</Text>
      </Pressable>

      <View className="flex-1 justify-center">
        <View className="items-center mt-16 mb-6">
          <View className="w-20 h-20 rounded-2xl bg-white/20 items-center justify-center mb-3" style={{ shadowColor: '#000', shadowOffset: { width: 0, height: 8 }, shadowOpacity: 0.2, shadowRadius: 24, elevation: 8 }}>
            <Text className="text-white font-bold text-4xl">F</Text>
          </View>
          <Text className="font-headline-lg text-headline-lg text-white font-bold">Finovault AI</Text>
        </View>

        <View className="overflow-hidden" style={{ height: 360 }} {...panResponder.panHandlers}>
          <Animated.View className="flex-row" style={[{ width: SCREEN_WIDTH * SLIDES.length }, carouselStyle]}>
            {SLIDES.map((slide, index) => (
              <View key={index} style={{ width: SCREEN_WIDTH }} className="items-center justify-center px-8 py-8">
                <View className="items-center">
                  <Animated.View style={[floatStyles[index], { marginBottom: 24 }]}>
                    <View className="w-36 h-36 rounded-full bg-white/15 items-center justify-center">
                      <MaterialIcons name={slide.icon} size={56} color="#ffffff" />
                    </View>
                  </Animated.View>
                  <Text className="font-headline-md text-headline-md text-white font-bold mb-3 text-center">{slide.title}</Text>
                  <Text className="font-body-md text-body-md text-white/80 text-center leading-relaxed">{slide.subtitle}</Text>
                </View>
              </View>
            ))}
          </Animated.View>
        </View>

        <View className="flex-row justify-center gap-2 mt-4 mb-8">
          {SLIDES.map((_, index) => (
            <Pressable key={index} onPress={() => goToSlide(index)}>
              <View className={`rounded-full ${index === currentIndex ? 'w-6 bg-white' : 'w-2 h-2 bg-white/30'}`} style={{ height: 8 }} />
            </Pressable>
          ))}
        </View>

        <View className="px-8 max-w-sm mx-auto w-full">
          <Pressable
            onPress={() => {
              playSound('open');
              router.replace('/getting-started');
            }}
            className="w-full py-4 rounded-xl bg-white items-center justify-center flex-row active:scale-[0.98]"
            style={{ shadowColor: '#000', shadowOffset: { width: 0, height: 4 }, shadowRadius: 14, elevation: 4 }}
          >
            <Text className="font-label-md text-label-md text-primary mr-2 font-bold">Get Started</Text>
            <MaterialIcons name="arrow-forward" size={20} color="#006b5a" />
          </Pressable>
        </View>
      </View>
    </View>
  );
}
