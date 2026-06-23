import { router } from 'expo-router';
import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { Alert, Dimensions, PanResponder, Pressable, Text, View } from 'react-native';
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
    title: 'Predict',
    subtitle: 'Harness advanced AI to forecast market trends and optimize your asset allocation with institutional precision.',
    icon: 'trending-up' as const,
    color: '#006b5a',
    animationDelay: 0,
  },
  {
    title: 'Protect',
    subtitle: 'Rest easy with enterprise-grade fraud detection and real-time security monitoring powered by our neural network.',
    icon: 'shield' as const,
    color: '#0a2540',
    animationDelay: 1000,
  },
  {
    title: 'Empower',
    subtitle: 'Transform raw data into actionable intelligence. Grow your wealth through personalized AI-driven suggestions.',
    icon: 'auto-awesome' as const,
    color: '#006b5a',
    animationDelay: 2000,
  },
  {
    title: 'SME Intelligence',
    subtitle: 'Scale your business with dedicated tools for operational efficiency and automated financial reporting.',
    icon: 'business' as const,
    color: '#150082',
    animationDelay: 3500,
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
  const floatingY4 = useSharedValue(0);
  const floatingValues = [floatingY1, floatingY2, floatingY3, floatingY4];

  useEffect(() => {
    SLIDES.forEach((slide, index) => {
      floatingValues[index].value = withDelay(
        slide.animationDelay,
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
  const float4Style = useAnimatedStyle(() => ({
    transform: [{ translateY: floatingY4.value }],
  }));
  const floatStyles = [float1Style, float2Style, float3Style, float4Style];

  const handleHelpPress = useCallback(() => {
    Alert.alert('Help', 'Finovault AI Tour');
  }, []);

  const handleDotPress = useCallback((index: number) => {
    goToSlide(index);
  }, [goToSlide]);

  return (
    <View className="flex-1 bg-background">
      <View className="flex-row items-center justify-between px-margin-mobile pt-14 pb-4">
        <Text className="font-headline-lg-mobile text-headline-lg-mobile text-primary font-semibold">
          Finovault AI
        </Text>
        <Pressable
          className="w-10 h-10 rounded-full bg-surface-container-high items-center justify-center active:opacity-80"
          onPress={handleHelpPress}
        >
          <MaterialIcons name="help-outline" size={20} color="#43474d" />
        </Pressable>
      </View>

      <View className="flex-1 overflow-hidden">
        <View className="absolute top-20 -right-20 w-80 h-80 rounded-full bg-secondary-container/20 pointer-events-none" />
        <View className="absolute bottom-20 -left-20 w-80 h-80 rounded-full bg-primary-container/10 pointer-events-none" />

        <View className="px-margin-mobile mb-8 items-center">
          <Text className="font-label-md text-label-md text-secondary uppercase tracking-widest mb-2">
            Getting Started
          </Text>
          <Text className="font-headline-lg-mobile text-headline-lg-mobile text-on-background text-center">
            Welcome, Alex! Let's get you started.
          </Text>
        </View>

        <View className="overflow-hidden" style={{ height: 480 }} {...panResponder.panHandlers}>
          <Animated.View className="flex-row" style={[{ width: SCREEN_WIDTH * SLIDES.length }, carouselStyle]}>
            {SLIDES.map((slide, index) => (
              <View key={index} style={{ width: SCREEN_WIDTH }} className="items-center justify-center px-margin-mobile">
                <View
                  className="rounded-xl p-8 w-full max-w-sm items-center"
                  style={{
                    backgroundColor: 'rgba(255,255,255,0.7)',
                    borderWidth: 1,
                    borderColor: 'rgba(230,235,241,1)',
                    shadowColor: '#000',
                    shadowOffset: { width: 0, height: 4 },
                    shadowOpacity: 0.04,
                    shadowRadius: 20,
                    elevation: 2,
                  }}
                >
                  <Animated.View style={[floatStyles[index], { marginBottom: 32 }]}>
                    <View
                      className="w-48 h-48 rounded-full items-center justify-center"
                      style={{ backgroundColor: `${slide.color}10` }}
                    >
                      <MaterialIcons name={slide.icon} size={72} color={slide.color} />
                    </View>
                  </Animated.View>
                  <Text className="font-headline-md text-headline-md text-primary mb-3">
                    {slide.title}
                  </Text>
                  <Text className="font-body-md text-body-md text-on-surface-variant text-center">
                    {slide.subtitle}
                  </Text>
                </View>
              </View>
            ))}
          </Animated.View>
        </View>

        <View className="mt-8 items-center">
          <View className="flex-row gap-2 mb-10">
            {SLIDES.map((_, index) => (
              <Pressable key={index} onPress={() => handleDotPress(index)}>
                <View
                  className={`rounded-full ${index === currentIndex ? 'w-6 bg-secondary' : 'w-2 h-2 bg-outline/30'}`}
                  style={{ height: 8 }}
                />
              </Pressable>
            ))}
          </View>

          <View className="w-full px-margin-mobile max-w-sm">
            <Pressable
              onPress={() => router.push(isAuthenticated ? '/(tabs)' : '/preferences')}
              className="w-full py-4 rounded-xl bg-secondary items-center justify-center flex-row"
              style={{
                shadowColor: 'rgba(0,107,90,0.25)',
                shadowOffset: { width: 0, height: 4 },
                shadowRadius: 14,
                elevation: 4,
              }}
            >
              <Text className="font-label-md text-label-md text-on-primary mr-2">
                Go to My Dashboard
              </Text>
              <MaterialIcons name="arrow-forward" size={20} color="#ffffff" />
            </Pressable>
          </View>
        </View>
      </View>

      <View className="flex-row justify-center items-center pb-8 gap-6">
        <Pressable
          onPress={prevSlide}
          className="w-12 h-12 items-center justify-center active:opacity-70"
        >
          <MaterialIcons name="chevron-left" size={28} color="#74777e" />
        </Pressable>
        <View className="w-2 h-2 rounded-full bg-secondary scale-110" />
        <Pressable
          onPress={nextSlide}
          className="w-12 h-12 items-center justify-center active:opacity-70"
        >
          <MaterialIcons name="chevron-right" size={28} color="#74777e" />
        </Pressable>
      </View>
    </View>
  );
}
