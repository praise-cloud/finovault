import { Input, InputField } from '@gluestack-ui/themed';
import { router } from 'expo-router';
import { useState } from 'react';
import { View, Text, Pressable, ScrollView, Alert, ActivityIndicator, useColorScheme } from 'react-native';
import { MaterialIcons, Ionicons } from '@expo/vector-icons';
import { useAuthStore } from '@/stores/auth-store';
import { signInWithGoogle } from '@/lib/api/services/auth';

export default function SignUp() {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [phone, setPhone] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [focusedField, setFocusedField] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [errors, setErrors] = useState<Record<string, string>>({});
  const signUp = useAuthStore((s) => s.signUp);
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';

  const getPasswordStrength = () => {
    if (!password) return 0;
    let score = 0;
    if (password.length >= 8) score++;
    if (/[A-Z]/.test(password)) score++;
    if (/[0-9]/.test(password)) score++;
    if (/[^A-Za-z0-9]/.test(password)) score++;
    return score;
  };

  const strength = getPasswordStrength();
  const strengthLabel = strength === 0 ? 'Weak' : strength === 1 ? 'Fair' : strength === 2 ? 'Good' : 'Strong';

  const validate = () => {
    const errs: Record<string, string> = {};
    if (!name.trim()) errs.name = 'Full name is required';
    if (!email.trim()) errs.email = 'Email is required';
    else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) errs.email = 'Invalid email format';
    if (!password) errs.password = 'Password is required';
    else if (password.length < 8) errs.password = 'Password must be at least 8 characters';
    if (password !== confirmPassword) errs.confirmPassword = 'Passwords do not match';
    setErrors(errs);
    return Object.keys(errs).length === 0;
  };

  const handleSubmit = async () => {
    if (!validate()) return;
    setIsSubmitting(true);
    const error = await signUp({ email, password, fullName: name, phone: phone || undefined });
    setIsSubmitting(false);
    if (error) {
      Alert.alert('Sign Up Failed', error);
      return;
    }
    router.replace('/(tabs)');
  };

  const handleGoogleSignIn = async () => {
    try {
      await signInWithGoogle();
    } catch {
      Alert.alert('Error', 'Failed to sign in with Google');
    }
  };

  const getFocusBorder = (field: string) =>
    focusedField === field ? 'border-[#D4AF37]' : errors[field] ? 'border-error' : 'border-outline-variant';

  return (
    <View className={`flex-1 flex-col md:flex-row ${isDark ? 'bg-[#0A1F5C]' : 'bg-background'}`}>
      <View className="hidden md:flex md:w-1/2 bg-[#0A1F5C] relative overflow-hidden items-center justify-center px-margin-desktop">
        <View className="relative z-10 max-w-lg">
          <View className="mb-gutter">
            <View className="self-start flex-row items-center px-sm py-xs bg-[#D4AF37]/10 border border-[#D4AF37]/20 rounded-full mb-base">
              <MaterialIcons name="verified-user" size={18} color="#D4AF37" />
              <Text className="font-label-md text-label-md text-[#D4AF37] ml-xs">Bank-Grade Security</Text>
            </View>
          </View>
          <Text className="font-display-lg text-display-lg text-[#D4AF37] mb-sm">Welcome to Finovault AI</Text>
          <Text className="font-body-lg text-body-lg text-white/70 leading-relaxed">
            Predict. Protect. Empower. Your Adaptive Financial Intelligence. Join the next generation of digital asset management.
          </Text>
          <View className="mt-xl flex-row gap-gutter opacity-80">
            <View className="flex-1 p-md bg-white/5 rounded-xl border border-white/10">
              <Text className="font-headline-md text-headline-md text-[#D4AF37] mb-xs">99.9%</Text>
              <Text className="font-caption text-caption text-white/50 uppercase tracking-wider">Uptime SLA</Text>
            </View>
            <View className="flex-1 p-md bg-white/5 rounded-xl border border-white/10">
              <Text className="font-headline-md text-headline-md text-[#D4AF37] mb-xs">AES-256</Text>
              <Text className="font-caption text-caption text-white/50 uppercase tracking-wider">Encryption</Text>
            </View>
          </View>
        </View>
        <View className="absolute -bottom-20 -right-20 w-96 h-96 bg-[#D4AF37] rounded-full opacity-10" />
      </View>

      <ScrollView className={`flex-1 w-full md:w-1/2 ${isDark ? 'bg-[#0A1F5C]' : 'bg-surface'}`}>
        <View className="px-margin-mobile md:px-margin-desktop py-lg pb-[60px] items-center">
          <View className="w-full max-w-md">
            <View className="md:hidden mb-lg">
              <View className="flex-row items-center gap-xs mb-sm">
                <Text className="font-headline-lg-mobile text-headline-lg-mobile text-[#D4AF37] font-semibold">Finovault AI</Text>
              </View>
              <Text className={`font-headline-lg-mobile text-headline-lg-mobile ${isDark ? 'text-white' : 'text-on-background'} mb-xs`}>Create an account</Text>
              <Text className={`font-body-md text-body-md ${isDark ? 'text-white/60' : 'text-on-surface-variant'}`}>Your adaptive financial intelligence journey starts here.</Text>
            </View>

            <View className="hidden md:block mb-lg">
              <Text className={`font-headline-lg text-headline-lg ${isDark ? 'text-white' : 'text-on-background'}`}>Sign up</Text>
              <Text className={`font-body-md text-body-md ${isDark ? 'text-white/60' : 'text-on-surface-variant'}`}>Join the community of intelligent investors.</Text>
            </View>

            <View className="mb-gutter">
              <Text className={`font-label-md text-label-md ${isDark ? 'text-white/80' : 'text-on-surface'} mb-xs`}>Full Name</Text>
              <Input variant="outline" size="md" className={`${isDark ? 'bg-[#1A1A1A] border-white/20' : 'bg-surface-container-lowest'} rounded-lg ${getFocusBorder('name')}`}>
                <InputField
                  placeholder="John Doe"
                  value={name}
                  onChangeText={setName}
                  className={`text-body-md placeholder:text-outline/50 ${isDark ? 'text-white' : ''}`}
                  onFocus={() => setFocusedField('name')}
                  onBlur={() => setFocusedField(null)}
                  placeholderTextColor={isDark ? '#ffffff50' : undefined}
                />
              </Input>
              {errors.name && <Text className="text-error text-caption mt-xs">{errors.name}</Text>}
            </View>

            <View className="mb-gutter">
              <Text className={`font-label-md text-label-md ${isDark ? 'text-white/80' : 'text-on-surface'} mb-xs`}>Email address</Text>
              <Input variant="outline" size="md" className={`${isDark ? 'bg-[#1A1A1A] border-white/20' : 'bg-surface-container-lowest'} rounded-lg ${getFocusBorder('email')}`}>
                <InputField
                  placeholder="name@example.com"
                  value={email}
                  onChangeText={setEmail}
                  keyboardType="email-address"
                  className={`text-body-md placeholder:text-outline/50 ${isDark ? 'text-white' : ''}`}
                  onFocus={() => setFocusedField('email')}
                  onBlur={() => setFocusedField(null)}
                  placeholderTextColor={isDark ? '#ffffff50' : undefined}
                />
              </Input>
              {errors.email && <Text className="text-error text-caption mt-xs">{errors.email}</Text>}
            </View>

            <View className="mb-gutter">
              <View className="flex-row justify-between items-center mb-xs">
                <Text className={`font-label-md text-label-md ${isDark ? 'text-white/80' : 'text-on-surface'}`}>Phone Number</Text>
                <Text className="font-caption text-caption text-outline">Optional</Text>
              </View>
              <Input variant="outline" size="md" className={`${isDark ? 'bg-[#1A1A1A] border-white/20' : 'bg-surface-container-lowest'} rounded-lg ${getFocusBorder('phone')}`}>
                <InputField
                  placeholder="+1 (555) 000-0000"
                  value={phone}
                  onChangeText={setPhone}
                  keyboardType="phone-pad"
                  className={`text-body-md placeholder:text-outline/50 ${isDark ? 'text-white' : ''}`}
                  onFocus={() => setFocusedField('phone')}
                  onBlur={() => setFocusedField(null)}
                  placeholderTextColor={isDark ? '#ffffff50' : undefined}
                />
              </Input>
            </View>

            <View className="mb-gutter">
              <Text className={`font-label-md text-label-md ${isDark ? 'text-white/80' : 'text-on-surface'} mb-xs`}>Password</Text>
              <View className="relative">
                <Input variant="outline" size="md" className={`${isDark ? 'bg-[#1A1A1A] border-white/20' : 'bg-surface-container-lowest'} rounded-lg ${getFocusBorder('password')}`}>
                  <InputField
                    placeholder="••••••••"
                    value={password}
                    onChangeText={setPassword}
                    secureTextEntry={!showPassword}
                    className={`text-body-md placeholder:text-outline/50 ${isDark ? 'text-white' : ''}`}
                    onFocus={() => setFocusedField('password')}
                    onBlur={() => setFocusedField(null)}
                    placeholderTextColor={isDark ? '#ffffff50' : undefined}
                  />
                </Input>
                <Pressable onPress={() => setShowPassword(!showPassword)} className="absolute right-3 top-1/2 -translate-y-1/2 active:scale-95">
                  <MaterialIcons name={showPassword ? 'visibility-off' : 'visibility'} size={20} color={isDark ? '#ffffff80' : '#74777e'} />
                </Pressable>
              </View>
              {errors.password && <Text className="text-error text-caption mt-xs">{errors.password}</Text>}
              <View className="mt-sm">
                <View className="flex-row gap-xs">
                  {[1, 2, 3, 4].map((i) => (
                    <View key={i} className={`h-1 flex-1 rounded-full ${i <= strength ? 'bg-[#D4AF37]' : isDark ? 'bg-white/20' : 'bg-surface-container-highest'}`} />
                  ))}
                </View>
                <Text className="font-caption text-caption text-[#D4AF37] mt-xs">{strengthLabel} password</Text>
              </View>
            </View>

            <View className="mb-gutter">
              <Text className={`font-label-md text-label-md ${isDark ? 'text-white/80' : 'text-on-surface'} mb-xs`}>Confirm Password</Text>
              <Input variant="outline" size="md" className={`${isDark ? 'bg-[#1A1A1A] border-white/20' : 'bg-surface-container-lowest'} rounded-lg ${getFocusBorder('confirmPassword')}`}>
                <InputField
                  placeholder="••••••••"
                  value={confirmPassword}
                  onChangeText={setConfirmPassword}
                  secureTextEntry
                  className={`text-body-md placeholder:text-outline/50 ${isDark ? 'text-white' : ''}`}
                  onFocus={() => setFocusedField('confirmPassword')}
                  onBlur={() => setFocusedField(null)}
                  placeholderTextColor={isDark ? '#ffffff50' : undefined}
                />
              </Input>
              {errors.confirmPassword && <Text className="text-error text-caption mt-xs">{errors.confirmPassword}</Text>}
            </View>

            <Pressable
              onPress={handleSubmit}
              disabled={isSubmitting}
              className="w-full py-md rounded-lg bg-[#D4AF37] flex-row items-center justify-center gap-sm active:scale-[0.98]"
              style={{ shadowColor: 'rgba(212,175,55,0.25)', shadowOffset: { width: 0, height: 4 }, shadowRadius: 14, elevation: 4 }}
            >
              {isSubmitting ? (
                <ActivityIndicator size="small" color="#1A1A1A" />
              ) : (
                <>
                  <Text className="text-[#1A1A1A] font-label-md text-label-md">Create Free Account</Text>
                  <MaterialIcons name="arrow-forward" size={20} color="#1A1A1A" />
                </>
              )}
            </Pressable>

            <View className="flex-row items-center my-xl">
              <View className="flex-1 h-[1px] bg-outline-variant/30" />
              <Text className="font-caption text-caption text-outline mx-md">Or continue with</Text>
              <View className="flex-1 h-[1px] bg-outline-variant/30" />
            </View>

            <View className="flex-row gap-md">
              <Pressable onPress={handleGoogleSignIn} className={`flex-1 flex-row items-center justify-center gap-sm px-md py-sm rounded-lg active:scale-95 ${isDark ? 'bg-white/10 border border-white/20' : 'bg-white border border-outline-variant'}`}>
                <Ionicons name="logo-google" size={20} color={isDark ? '#D4AF37' : '#1A1A1A'} />
                <Text className={`font-label-md text-label-md ${isDark ? 'text-white' : 'text-on-surface'}`}>Google</Text>
              </Pressable>
              <Pressable className={`flex-1 flex-row items-center justify-center gap-sm px-md py-sm rounded-lg active:scale-95 ${isDark ? 'bg-white/10 border border-white/20' : 'bg-white border border-outline-variant'}`}>
                <Ionicons name="logo-apple" size={20} color={isDark ? '#D4AF37' : '#1A1A1A'} />
                <Text className={`font-label-md text-label-md ${isDark ? 'text-white' : 'text-on-surface'}`}>Apple</Text>
              </Pressable>
            </View>

            <View className="mt-xl items-center">
              <Text className={`font-body-md text-body-md ${isDark ? 'text-white/60' : 'text-on-surface-variant'}`}>
                Already have an account?{' '}
                <Text className="text-[#D4AF37] font-semibold" onPress={() => router.push('/login')}>Login</Text>
              </Text>
            </View>

            <View className="mt-xl items-center opacity-60">
              <View className="flex-row items-center gap-xs">
                <MaterialIcons name="lock" size={16} color={isDark ? '#ffffff80' : '#43474d'} />
                <Text className={`font-caption text-caption ${isDark ? 'text-white/60' : 'text-on-surface-variant'}`}>Bank-grade encryption</Text>
                <View className="w-1 h-1 rounded-full bg-outline/50" />
                <Text className={`font-caption text-caption ${isDark ? 'text-white/60' : 'text-on-surface-variant'}`}>Your data is safe</Text>
              </View>
            </View>
          </View>
        </View>
      </ScrollView>
    </View>
  );
}
