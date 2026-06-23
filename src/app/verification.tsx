import { Input, InputField } from '@gluestack-ui/themed';
import { router, useLocalSearchParams } from 'expo-router';
import { useEffect, useRef, useState } from 'react';
import { View, Text, Pressable, Alert, ActivityIndicator } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import Animated, { useAnimatedStyle, useSharedValue, withRepeat, withSequence, withTiming, interpolate, Easing } from 'react-native-reanimated';
import Svg, { Circle, Defs, Pattern, Rect } from 'react-native-svg';
import { useAuthStore } from '@/stores/auth-store';

function FloatingLock() {
  const bounce = useSharedValue(0);
  useEffect(() => {
    bounce.value = withRepeat(
      withSequence(
        withTiming(1, { duration: 1500, easing: Easing.inOut(Easing.ease) }),
        withTiming(0, { duration: 1500, easing: Easing.inOut(Easing.ease) })
      ), -1, true
    );
  }, []);
  const anim = useAnimatedStyle(() => ({ transform: [{ translateY: interpolate(bounce.value, [0, 1], [0, -6]) }] }));
  return (
    <Animated.View style={anim} className="absolute top-0 right-0 w-12 h-12 bg-secondary-container rounded-xl items-center justify-center shadow-lg">
      <MaterialIcons name="lock" size={16} color="#00705e" />
    </Animated.View>
  );
}

function FloatingSecurity() {
  const pulse = useSharedValue(1);
  useEffect(() => {
    pulse.value = withRepeat(
      withSequence(
        withTiming(0.6, { duration: 2000, easing: Easing.inOut(Easing.ease) }),
        withTiming(1, { duration: 2000, easing: Easing.inOut(Easing.ease) })
      ), -1, true
    );
  }, []);
  const anim = useAnimatedStyle(() => ({ opacity: pulse.value }));
  return (
    <Animated.View style={anim} className="absolute bottom-4 left-0 w-10 h-10 bg-primary-container rounded-lg items-center justify-center shadow-md">
      <MaterialIcons name="security" size={16} color="#768dad" />
    </Animated.View>
  );
}

export default function Verification() {
  const [otp, setOtp] = useState(['', '', '', '', '', '']);
  const inputs = useRef<any[]>([]);
  const [isVerifying, setIsVerifying] = useState(false);
  const [isResending, setIsResending] = useState(false);
  const [cooldown, setCooldown] = useState(0);
  const verifyOtp = useAuthStore((s) => s.verifyOtp);
  const resendOtp = useAuthStore((s) => s.resendOtp);
  const user = useAuthStore((s) => s.user);

  const email = user?.email || '';

  useEffect(() => {
    if (cooldown > 0) {
      const timer = setTimeout(() => setCooldown(cooldown - 1), 1000);
      return () => clearTimeout(timer);
    }
  }, [cooldown]);

  const handleOtpChange = (text: string, index: number) => {
    const newOtp = [...otp];
    newOtp[index] = text;
    setOtp(newOtp);
    if (text && index < 5) {
      inputs.current[index + 1]?.focus?.();
    }
  };

  const handleKeyDown = (e: any, index: number) => {
    if (e.nativeEvent.key === 'Backspace' && !otp[index] && index > 0) {
      inputs.current[index - 1]?.focus?.();
    }
  };

  const handleVerify = async () => {
    const token = otp.join('');
    if (token.length !== 6) {
      Alert.alert('Error', 'Please enter the full 6-digit code');
      return;
    }
    setIsVerifying(true);
    const error = await verifyOtp(email, otp.join(''));
    setIsVerifying(false);
    if (error) {
      Alert.alert('Verification Failed', error);
      return;
    }
    router.push('/(tabs)');
  };

  const handleResend = async () => {
    if (cooldown > 0) return;
    setIsResending(true);
    const error = await resendOtp(email);
    setIsResending(false);
    if (error) {
      if (error.includes('429') || error.includes('rate')) {
        Alert.alert('Too Many Requests', 'Please wait 60 seconds before requesting a new code.');
      } else {
        Alert.alert('Error', error);
      }
      return;
    }
    setCooldown(60);
    Alert.alert('Code Sent', 'A new verification code has been sent to your email.');
  };

  return (
    <View className="flex-1 bg-background">
      <View className="flex-row items-center justify-center px-margin-mobile pt-14 pb-4">
        <Pressable onPress={() => router.back()} className="absolute left-4 active:scale-95">
          <MaterialIcons name="arrow-back" size={24} color="#000f22" />
        </Pressable>
        <Text className="font-headline-lg-mobile text-primary font-semibold">Finovault AI</Text>
        <View className="w-6" />
      </View>

      <View className="flex-1 items-center justify-center px-margin-mobile">
        <View className="relative w-48 h-48 items-center justify-center mb-8">
          <View className="absolute w-48 h-48 bg-secondary-container opacity-10 rounded-full" />
          <View className="w-32 h-32 bg-surface-container-lowest rounded-3xl items-center justify-center border border-surface-variant overflow-hidden" style={{ shadowColor: '#000', shadowOffset: { width: 0, height: 4 }, shadowRadius: 12, elevation: 6 }}>
            <Svg width="100%" height="100%" className="absolute inset-0 opacity-[0.05]">
              <Defs>
                <Pattern id="dots" x="0" y="0" width="10" height="10" patternUnits="userSpaceOnUse">
                  <Circle cx="1" cy="1" r="0.5" fill="#006b5a" />
                </Pattern>
              </Defs>
              <Rect width="100%" height="100%" fill="url(#dots)" />
            </Svg>
            <MaterialIcons name="verified-user" size={48} color="#0a2540" />
          </View>
          <FloatingLock />
          <FloatingSecurity />
        </View>

        <View className="items-center mb-10">
          <Text className="font-headline-lg-mobile text-headline-lg-mobile text-on-surface mb-3">Verify your Identity</Text>
          <Text className="font-body-md text-body-md text-on-surface-variant text-center px-4">
            We've sent a 6-digit code to {email || 'your email'}.
          </Text>
        </View>

        <View className="w-full max-w-sm mb-12">
          <View className="flex-row gap-sm justify-center">
            {otp.map((digit, index) => (
              <Input key={index} className="w-12 h-12 bg-surface-container-lowest border-2 border-surface-variant rounded-xl" variant="outline" size="md">
                <InputField
                  ref={(el) => { inputs.current[index] = el; }}
                  value={digit}
                  onChangeText={(text: string) => handleOtpChange(text, index)}
                  onKeyPress={(e) => handleKeyDown(e, index)}
                  keyboardType="number-pad"
                  maxLength={1}
                  className="text-center font-headline-md text-headline-md text-primary"
                  style={{ textAlign: 'center' }}
                />
              </Input>
            ))}
          </View>
          <Pressable onPress={handleResend} disabled={isResending || cooldown > 0} className="items-center mt-8 active:scale-95">
            {isResending ? (
              <ActivityIndicator size="small" color="#006b5a" />
            ) : cooldown > 0 ? (
              <Text className="font-label-md text-label-md text-outline">Resend in {cooldown}s</Text>
            ) : (
              <Text className="font-label-md text-label-md text-secondary">Resend Code</Text>
            )}
          </Pressable>
        </View>

        <View className="w-full max-w-sm">
          <Pressable
            onPress={handleVerify}
            disabled={isVerifying}
            className="w-full py-4 rounded-2xl bg-gradient-to-r from-secondary to-[#005143] items-center active:scale-[0.98] overflow-hidden"
            style={{ shadowColor: '#000', shadowOffset: { width: 0, height: 4 }, shadowRadius: 14, elevation: 6 }}
          >
            {isVerifying ? (
              <ActivityIndicator size="small" color="#ffffff" />
            ) : (
              <Text className="text-on-primary font-headline-md">Verify & Continue</Text>
            )}
          </Pressable>
          <Text className="font-caption text-caption text-outline text-center mt-4 px-gutter">
            By continuing, you agree to Finovault's security protocols and data usage policies.
          </Text>
        </View>
      </View>

      <View className="items-center pb-8">
        <View className="flex-row items-center gap-1 opacity-40">
          <MaterialIcons name="verified-user" size={14} color="#43474d" />
          <Text className="font-label-md text-[10px] tracking-widest uppercase text-on-surface-variant">Secured by AI-Vault Tech</Text>
        </View>
      </View>
    </View>
  );
}