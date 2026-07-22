import { router } from 'expo-router';
import { useEffect } from 'react';
import { View, Text, Pressable } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { useAuthStore } from '@/stores/auth-store';

export default function GettingStarted() {
  const isAuthenticated = useAuthStore((s) => s.isAuthenticated);

  useEffect(() => {
    if (isAuthenticated) {
      router.replace('/(tabs)');
    }
  }, [isAuthenticated]);

  return (
    <View className="flex-1 bg-[#0A1F5C]">
      <View className="absolute -top-24 -right-24 w-72 h-72 rounded-full bg-[#08142E]" />
      <View className="absolute bottom-60 -left-20 w-64 h-64 rounded-full bg-[#08142E]" />

      <View className="flex-1 justify-center px-8">
        <View className="items-center mb-12">
          <View className="w-24 h-24 rounded-2xl bg-[#D4AF37]/20 items-center justify-center mb-5" style={{ shadowColor: '#D4AF37', shadowOffset: { width: 0, height: 8 }, shadowOpacity: 0.2, shadowRadius: 24, elevation: 8 }}>
            <Text className="text-[#D4AF37] font-bold text-5xl">F</Text>
          </View>
          <Text className="font-headline-lg text-headline-lg text-white font-bold">Finovault AI</Text>
          <Text className="font-body-md text-body-md text-white/70 text-center mt-2">Your Adaptive Financial Intelligence</Text>
        </View>

        <View className="bg-[#D4AF37]/10 rounded-2xl p-6 mb-8 border border-[#D4AF37]/20">
          <Text className="font-body-lg text-body-lg text-[#D4AF37] font-bold text-center mb-2">Welcome to the future of finance</Text>
          <Text className="font-body-md text-body-md text-white/70 text-center">AI-powered insights, bank-grade security, and intelligent growth tools — all in one platform.</Text>
        </View>

        <Pressable
          onPress={() => router.push('/signup')}
          className="w-full py-4 rounded-xl bg-[#D4AF37] items-center justify-center flex-row active:scale-[0.98] mb-4"
          style={{ shadowColor: '#D4AF37', shadowOffset: { width: 0, height: 4 }, shadowRadius: 14, elevation: 4 }}
        >
          <MaterialIcons name="person-add" size={20} color="#1A1A1A" />
          <Text className="font-label-md text-label-md text-[#1A1A1A] ml-2 font-bold">I am new here</Text>
        </Pressable>

        <Pressable
          onPress={() => router.push('/login')}
          className="w-full py-4 rounded-xl border-2 border-[#D4AF37] items-center justify-center flex-row active:scale-[0.98]"
        >
          <MaterialIcons name="login" size={20} color="#D4AF37" />
          <Text className="font-label-md text-label-md text-[#D4AF37] ml-2 font-bold">I am back</Text>
        </Pressable>

        <View className="items-center mt-10">
          <Text className="font-caption text-caption text-white/50 text-center">By continuing, you agree to our Terms of Service and Privacy Policy.</Text>
        </View>
      </View>
    </View>
  );
}
