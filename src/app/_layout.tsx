import '@/src/global.css';
import '@/src/lib/i18n/i18n';

import { AnimatedSplashOverlay } from "@/src/components/animated-icon";
import { ErrorBoundary } from "@/src/components/error-boundary";
import { ToastProvider } from "@/src/components/toast";
import { useFinovaultFonts } from "@/src/hooks/use-fonts";
import { FinovaultProvider } from "@/src/lib/gluestack-provider";
import "@/src/lib/nativewind-interop";
import { useAuthStore } from "@/src/stores/auth-store";
import { usePreferencesStore } from "@/src/stores/preferences-store";
import { Stack } from "expo-router";
import * as SplashScreen from "expo-splash-screen";
import { StatusBar } from "expo-status-bar";
import { useEffect, useState } from "react";
import { ActivityIndicator, Pressable, Text, View, useColorScheme } from "react-native";

try {
  SplashScreen.preventAutoHideAsync();
} catch (e) {
  console.warn('SplashScreen.preventAutoHideAsync failed', e);
}

export default function RootLayout() {
  return (
    <ErrorBoundary>
      <RootContent />
    </ErrorBoundary>
  );
}

function RootContent() {
  const fontsLoaded = useFinovaultFonts();
  const initialize = useAuthStore((s) => s.initialize);
  const isLoading = useAuthStore((s) => s.isLoading);
  const user = useAuthStore((s) => s.user);
  const loadPreferences = usePreferencesStore((s) => s.loadPreferences);
  const [fatalError, setFatalError] = useState<Error | null>(null);
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';

  useEffect(() => {
    void initialize();
  }, [initialize]);

  useEffect(() => {
    if (user) void loadPreferences();
  }, [user, loadPreferences]);

  useEffect(() => {
    const errorUtils = globalThis as typeof globalThis & {
      ErrorUtils?: {
        getGlobalHandler?: () => ((error: Error, isFatal?: boolean) => void) | undefined;
        setGlobalHandler?: (handler: (error: Error, isFatal?: boolean) => void) => void;
      };
    };

    const previousHandler = errorUtils.ErrorUtils?.getGlobalHandler?.();
    errorUtils.ErrorUtils?.setGlobalHandler?.((error, isFatal) => {
      if (isFatal) {
        setFatalError(error);
      }
      previousHandler?.(error, isFatal);
    });

    return () => {
      if (previousHandler && errorUtils.ErrorUtils?.setGlobalHandler) {
        errorUtils.ErrorUtils.setGlobalHandler(previousHandler);
      }
    };
  }, []);

  useEffect(() => {
    if (fontsLoaded) {
      SplashScreen.hideAsync().catch((e) =>
        console.warn('SplashScreen.hideAsync failed', e)
      );
    }
  }, [fontsLoaded]);

  if (!fontsLoaded || isLoading) {
    return (
      <View
        style={{
          flex: 1,
          justifyContent: "center",
          alignItems: "center",
          backgroundColor: isDark ? "#08142E" : "#FFFFFF",
        }}
      >
        <ActivityIndicator size="small" color={isDark ? "#D4AF37" : "#08142E"} />
      </View>
    );
  }

  if (fatalError) {
    return (
      <View
        style={{
          flex: 1,
          justifyContent: "center",
          alignItems: "center",
          backgroundColor: isDark ? "#08142E" : "#FFFFFF",
          padding: 24,
        }}
      >
        <Text style={{ fontSize: 18, fontWeight: "700", color: isDark ? "#FFFFFF" : "#1A1A1A", marginBottom: 8, textAlign: "center" }}>
          App failed to start
        </Text>
        <Text style={{ fontSize: 13, color: isDark ? "#FFFFFF80" : "#43474D", textAlign: "center", marginBottom: 20 }}>
          {fatalError.message}
        </Text>
        <Pressable
          onPress={() => setFatalError(null)}
          style={{ backgroundColor: "#08142E", paddingHorizontal: 24, paddingVertical: 12, borderRadius: 9999 }}
        >
          <Text style={{ color: "#FFFFFF", fontWeight: "600" }}>Try Again</Text>
        </Pressable>
      </View>
    );
  }

  return (
    <FinovaultProvider>
      <StatusBar style={isDark ? "light" : "dark"} />
      <AnimatedSplashOverlay />
      <ToastProvider>
        <Stack screenOptions={{ headerShown: false }}>
          <Stack.Screen name="index" />
          <Stack.Screen name="preferences" />
          <Stack.Screen name="financial-interview" />
          <Stack.Screen name="financial-profile" />
         <Stack.Screen name="account-created" />
          <Stack.Screen name="login" />
          <Stack.Screen name="signup" />
          <Stack.Screen name="(tabs)" />
        </Stack>
      </ToastProvider>
    </FinovaultProvider>
  );
}
