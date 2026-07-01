import { Input, InputField } from '@gluestack-ui/themed';
import { router } from 'expo-router';
import { useState } from 'react';
import { View, Text, Pressable, ScrollView, Alert, ActivityIndicator } from 'react-native';
import { MaterialIcons, Ionicons } from '@expo/vector-icons';
import { useAuthStore } from '@/stores/auth-store';
import { signInWithGoogle } from '@/lib/api/services/auth';
import Animated, { useAnimatedStyle, useSharedValue, withSpring, FadeInDown } from 'react-native-reanimated';
import { mediumImpact, successNotification, errorNotification } from '@/hooks/use-haptics';
import { playSound } from '@/lib/sounds';

export default function Login() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [focusedField, setFocusedField] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [errors, setErrors] = useState<Record<string, string>>({});
  const signIn = useAuthStore((s) => s.signIn);

  const buttonScale = useSharedValue(1);
  const buttonAnimatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: buttonScale.value }],
  }));

  const validate = () => {
    const errs: Record<string, string> = {};
    if (!email.trim()) errs.email = 'Email is required';
    if (!password) errs.password = 'Password is required';
    setErrors(errs);
    return Object.keys(errs).length === 0;
  };

  const handleLogin = async () => {
    if (!validate()) {
      errorNotification();
      return;
    }
    mediumImpact();
    setIsSubmitting(true);
    const error = await signIn({ email, password });
    setIsSubmitting(false);
    if (error) {
      errorNotification();
      Alert.alert('Login Failed', error);
      return;
    }
    successNotification();
    playSound('open');
    router.replace('/(tabs)');
  };

  const handleGoogleSignIn = async () => {
    try {
      mediumImpact();
      await signInWithGoogle();
    } catch {
      errorNotification();
      Alert.alert('Error', 'Failed to sign in with Google');
    }
  };

  const getFocusBorder = (field: string) =>
    focusedField === field ? 'border-[#ffffff]' : errors[field] ? 'border-error' : 'border-outline-variant';

  return (
    <View className="flex-1 bg-background flex-col md:flex-row">
      <View className="hidden md:flex md:w-1/2 bg-primary-container relative overflow-hidden items-center justify-center px-margin-desktop">
        <View className="relative z-10 max-w-lg">
          <Text className="font-display-lg text-display-lg text-primary-fixed mb-sm">Welcome Back</Text>
          <Text className="font-body-lg text-body-lg text-on-primary-container leading-relaxed">Continue your adaptive financial intelligence journey.</Text>
        </View>
        <View className="absolute -bottom-20 -right-20 w-96 h-96 bg-secondary rounded-full opacity-20" />
      </View>

      <ScrollView className="flex-1 w-full md:w-1/2 bg-surface">
        <View className="px-margin-mobile md:px-margin-desktop py-lg pb-[60px] items-center">
          <View className="w-full max-w-md">
            <Animated.View entering={FadeInDown.springify().damping(14).delay(100)}>
              <View className="md:hidden mb-lg">
                <Text className="font-headline-lg-mobile text-headline-lg-mobile text-primary font-semibold">Finovault AI</Text>
                <Text className="font-headline-lg-mobile text-headline-lg-mobile text-on-background mb-xs">Welcome back</Text>
              </View>
            </Animated.View>
            <View className="hidden md:block mb-lg">
              <Text className="font-headline-lg text-headline-lg text-on-background">Log in</Text>
              <Text className="font-body-md text-body-md text-on-surface-variant">Welcome back to Finovault AI.</Text>
            </View>

            <Animated.View entering={FadeInDown.springify().damping(14).delay(200)}>
              <View className="mb-gutter">
                <Text className="font-label-md text-label-md text-on-surface mb-xs">Email address</Text>
                <Input variant="outline" size="md" className={`bg-surface-container-lowest rounded-lg ${getFocusBorder('email')}`}>
                  <InputField placeholder="name@example.com" value={email} onChangeText={setEmail} keyboardType="email-address" className="text-body-md placeholder:text-outline/50" onFocus={() => setFocusedField('email')} onBlur={() => setFocusedField(null)} />
                </Input>
                {errors.email && <Text className="text-error text-caption mt-xs">{errors.email}</Text>}
              </View>
            </Animated.View>

            <Animated.View entering={FadeInDown.springify().damping(14).delay(300)}>
              <View className="mb-gutter">
                <Text className="font-label-md text-label-md text-on-surface mb-xs">Password</Text>
                <View className="relative">
                  <Input variant="outline" size="md" className={`bg-surface-container-lowest rounded-lg ${getFocusBorder('password')}`}>
                    <InputField placeholder="••••••••" value={password} onChangeText={setPassword} secureTextEntry={!showPassword} className="text-body-md placeholder:text-outline/50" onFocus={() => setFocusedField('password')} onBlur={() => setFocusedField(null)} />
                  </Input>
                  <Pressable onPress={() => setShowPassword(!showPassword)} className="absolute right-3 top-1/2 -translate-y-1/2 active:scale-95">
                    <MaterialIcons name={showPassword ? 'visibility-off' : 'visibility'} size={20} color="#74777e" />
                  </Pressable>
                </View>
                {errors.password && <Text className="text-error text-caption mt-xs">{errors.password}</Text>}
              </View>
            </Animated.View>

            <Animated.View entering={FadeInDown.springify().damping(14).delay(400)}>
              <Pressable
                onPressIn={() => { buttonScale.value = withSpring(0.96, { damping: 15 }); }}
                onPressOut={() => { buttonScale.value = withSpring(1, { damping: 15 }); }}
                onPress={handleLogin}
                disabled={isSubmitting}
              >
                <Animated.View
                  style={[buttonAnimatedStyle, { shadowColor: 'rgba(0,107,90,0.25)', shadowOffset: { width: 0, height: 4 }, shadowRadius: 14, elevation: 4 }]}
                  className="w-full py-md rounded-lg bg-secondary bg-gradient-to-r from-secondary to-[#005143] flex-row items-center justify-center gap-sm"
                >
                  {isSubmitting ? (
                    <ActivityIndicator size="small" color="#ffffff" />
                  ) : (
                    <>
                      <Text className="text-on-primary font-label-md text-label-md">Log In</Text>
                      <MaterialIcons name="arrow-forward" size={20} color="#ffffff" />
                    </>
                  )}
                </Animated.View>
              </Pressable>
            </Animated.View>

            <View className="flex-row items-center my-xl">
              <View className="flex-1 h-[1px] bg-outline-variant/30" />
              <Text className="font-caption text-caption text-outline mx-md">Or continue with</Text>
              <View className="flex-1 h-[1px] bg-outline-variant/30" />
            </View>

            <View className="flex-row gap-md">
              <Pressable onPress={handleGoogleSignIn} className="flex-1 flex-row items-center justify-center gap-sm px-md py-sm bg-white border border-outline-variant rounded-lg active:scale-95">
                <Ionicons name="logo-google" size={20} color="#ffffff" />
                <Text className="font-label-md text-label-md text-on-surface">Google</Text>
              </Pressable>
            </View>

            <View className="mt-xl items-center">
              <Text className="font-body-md text-body-md text-on-surface-variant">
                Don't have an account?{' '}
                <Text className="text-primary font-semibold" onPress={() => router.push('/signup')}>Sign Up</Text>
              </Text>
            </View>
          </View>
        </View>
      </ScrollView>
    </View>
  );
}