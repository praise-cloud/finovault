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
  withTiming,
} from 'react-native-reanimated';
import { MaterialIcons } from '@expo/vector-icons';

const { width: SCREEN_WIDTH } = Dimensions.get('window');

const SLIDES = [
  {
    title: 'Smart Financial AI',
    subtitle: 'Finovault uses advanced artificial intelligence to analyze your finances, predict market trends, and optimize your wealth — all in real time.',
    icon: 'auto-awesome' as const,
    color: '#006b5a',
    animationDelay: 0,
  },
  {
    title: 'Bank-Grade Protection',
    subtitle: 'Enterprise-level fraud detection and AES-256 encryption keep your assets safe. Our neural network monitors transactions 24/7 for suspicious activity.',
    icon: 'shield' as const,
    color: '#0a2540',
    animationDelay: 1000,
  },
  {
    title: 'Intelligent Growth',
    subtitle: 'Get personalized AI-driven investment suggestions, smart savings automation, and a complete view of your financial health — all in one place.',
    icon: 'auto-awesome' as const,
    color: '#006b5a',
    animationDelay: 2000,
  },
];

export default function WelcomeTour() {
  const isAuthenticated = useAuthStore((s) => s.isAuthenticated);
  const [currentIndex, setCurrentIndex] = useState(0);

  useEffect(() => {
    if (isAuthenticated) {
      router.replace('/(tabs)');
    }
  }, [isAuthenticated]);
  const currentIndexRef = useRef(0);
  const translateX = useSharedValue(0);
  const floatingY1 = useSharedValue(0);
  const floatingY2 = useSharedValue(0);
  const floatingY3 = useSharedValue(0);
  const floatingValues = [floatingY1, floatingY2, floatingY3];

  useEffect(() => {
    SLIDES.forEach((_, index) => {
      floatingValues[index].value = withDelay(
        index * 1000,
        withRepeat(
          withSequence(
            withTiming(-20, { duration: 3000, easing: Easing.inOut(Easing.sin) }),
            withTiming(0, { duration: 3000, easing: Easing.inOut(Easing.sin) }),
          ),
          -1,
          true,
        ),
      );
    });
  }, []);

  const goToSlide = useCallback((index: number) => {
    currentIndexRef.current = index;
    setCurrentIndex(index);
    translateX.value = withTiming(-index * SCREEN_WIDTH, {
      duration: 400,
      easing: Easing.inOut(Easing.ease),
    });
  }, [translateX]);

  const nextSlide = useCallback(() => {
    const next = (currentIndexRef.current + 1) % SLIDES.length;
    goToSlide(next);
  }, [goToSlide]);

  const prevSlide = useCallback(() => {
    const prev = (currentIndexRef.current - 1 + SLIDES.length) % SLIDES.length;
    goToSlide(prev);
  }, [goToSlide]);

  useEffect(() => {
    const id = setInterval(() => {
      const next = (currentIndexRef.current + 1) % SLIDES.length;
      goToSlide(next);
    }, 5000);
    return () => clearInterval(id);
  }, [goToSlide]);

  const panResponder = useMemo(() => PanResponder.create({
    onMoveShouldSetPanResponder: (_, gs) => Math.abs(gs.dx) > 5 && Math.abs(gs.dx) > Math.abs(gs.dy),
    onPanResponderRelease: (_, gs) => {
      if (Math.abs(gs.dx) > 50) {
        if (gs.dx > 0) prevSlide();
        else nextSlide();
      }
    },
  }), [prevSlide, nextSlide]);

  const carouselStyle = useAnimatedStyle(() => ({
    transform: [{ translateX: translateX.value }],
  }));

  const float1Style = useAnimatedStyle(() => ({
    transform: [{ translateY: floatingY1.value }],
  }));
  const float2Style = useAnimatedStyle(() => ({
    transform: [{ translateY: floatingY2.value }],
  }));
  const float3Style = useAnimatedStyle(() => ({
    transform: [{ translateY: floatingY3.value }],
  }));
  const floatStyles = [float1Style, float2Style, float3Style];

  const handleDotPress = useCallback((index: number) => {
    goToSlide(index);
  }, [goToSlide]);

  return (
    <View className="flex-1 bg-background">
      <View className="absolute top-20 -right-20 w-80 h-80 rounded-full bg-secondary-container/20 pointer-events-none" />
      <View className="absolute bottom-20 -left-20 w-80 h-80 rounded-full bg-primary-container/10 pointer-events-none" />

      <View className="flex-1 justify-center">
        <View className="items-center mt-16 mb-4">
          <View className="w-20 h-20 rounded-2xl bg-primary items-center justify-center mb-4" style={{ shadowColor: '#006b5a', shadowOffset: { width: 0, height: 8 }, shadowOpacity: 0.3, shadowRadius: 24, elevation: 8 }}>
            <Text className="text-on-primary font-bold text-4xl">F</Text>
          </View>
          <Text className="font-headline-lg text-headline-lg text-primary font-bold">Finovault AI</Text>
          <Text className="font-body-md text-body-md text-on-surface-variant mt-1">Your Adaptive Financial Intelligence</Text>
        </View>

        <View className="overflow-hidden" style={{ height: 400 }} {...panResponder.panHandlers}>
          <Animated.View className="flex-row" style={[{ width: SCREEN_WIDTH * SLIDES.length }, carouselStyle]}>
            {SLIDES.map((slide, index) => (
              <View key={index} style={{ width: SCREEN_WIDTH }} className="items-center justify-center px-margin-mobile">
                <View
                  className="rounded-2xl p-8 w-full max-w-sm items-center"
                  style={{
                    backgroundColor: 'rgba(255,255,255,0.8)',
                    borderWidth: 1,
                    borderColor: 'rgba(230,235,241,0.8)',
                    shadowColor: '#000',
                    shadowOffset: { width: 0, height: 4 },
                    shadowOpacity: 0.06,
                    shadowRadius: 24,
                    elevation: 3,
                  }}
                >
                  <Animated.View style={[floatStyles[index], { marginBottom: 28 }]}>
                    <View
                      className="w-40 h-40 rounded-full items-center justify-center"
                      style={{ backgroundColor: `${slide.color}10` }}
                    >
                      <MaterialIcons name={slide.icon} size={64} color={slide.color} />
                    </View>
                  </Animated.View>
                  <Text className="font-headline-md text-headline-md text-primary mb-3 text-center">
                    {slide.title}
                  </Text>
                  <Text className="font-body-md text-body-md text-on-surface-variant text-center leading-relaxed">
                    {slide.subtitle}
                  </Text>
                </View>
              </View>
            ))}
          </Animated.View>
        </View>

        <View className="flex-row justify-center gap-2 mt-6 mb-6">
          {SLIDES.map((_, index) => (
            <Pressable key={index} onPress={() => handleDotPress(index)}>
              <View
                className={`rounded-full ${index === currentIndex ? 'w-6 bg-secondary' : 'w-2 h-2 bg-outline/30'}`}
                style={{ height: 8 }}
              />
            </Pressable>
          ))}
        </View>

        <View className="px-margin-mobile max-w-sm mx-auto w-full">
          <Pressable
            onPress={() => router.push(isAuthenticated ? '/(tabs)' : '/preferences')}
            className="w-full py-4 rounded-xl bg-secondary items-center justify-center flex-row active:scale-[0.98]"
            style={{
              shadowColor: 'rgba(0,107,90,0.25)',
              shadowOffset: { width: 0, height: 4 },
              shadowRadius: 14,
              elevation: 4,
            }}
          >
            <Text className="font-label-md text-label-md text-on-primary mr-2 font-bold">
              Get Started
            </Text>
            <MaterialIcons name="arrow-forward" size={20} color="#ffffff" />
          </Pressable>
        </View>
      </View>

      <View className="flex-row justify-center items-center pb-10 gap-6">
        <Pressable onPress={prevSlide} className="w-12 h-12 items-center justify-center active:opacity-70">
          <MaterialIcons name="chevron-left" size={28} color="#74777e" />
        </Pressable>
        <View className="w-2 h-2 rounded-full bg-secondary" />
        <Pressable onPress={nextSlide} className="w-12 h-12 items-center justify-center active:opacity-70">
          <MaterialIcons name="chevron-right" size={28} color="#74777e" />
        </Pressable>
      </View>
    </View>
  );
}
