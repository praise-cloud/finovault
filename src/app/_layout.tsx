import '@/lib/nativewind-interop';
import { Stack } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { FinovaultProvider } from '@/lib/gluestack-provider';
import { AnimatedSplashOverlay } from '@/components/animated-icon';
import { useFinovaultFonts } from '@/hooks/use-fonts';
import { ToastProvider } from '@/components/toast';
import { ActivityIndicator, View } from 'react-native';
import { useEffect } from 'react';
import { useAuthStore } from '@/stores/auth-store';
import { preloadSounds } from '@/lib/sounds';

export default function RootLayout() {
  const fontsLoaded = useFinovaultFonts();
  const initialize = useAuthStore((s) => s.initialize);
  const isLoading = useAuthStore((s) => s.isLoading);

  useEffect(() => {
    initialize();
  }, [initialize]);

  useEffect(() => {
    if (fontsLoaded) {
      preloadSounds();
    }
  }, [fontsLoaded]);

  if (!fontsLoaded || isLoading) {
    return (
      <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center', backgroundColor: '#f7fafd' }}>
        <ActivityIndicator size="small" color="#006b5a" />
      </View>
    );
  }

  return (
    <FinovaultProvider>
      <StatusBar style="dark" />
      <AnimatedSplashOverlay />
      <ToastProvider>
      <Stack screenOptions={{ headerShown: false }}>
        <Stack.Screen name="index" />
        <Stack.Screen name="getting-started" />
        <Stack.Screen name="preferences" />
        <Stack.Screen name="login" />
        <Stack.Screen name="signup" />
        <Stack.Screen name="(tabs)" />
      </Stack>
      </ToastProvider>
    </FinovaultProvider>
  );
}
