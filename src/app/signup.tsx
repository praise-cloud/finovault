import { router } from 'expo-router';
import { useState } from 'react';
import { View, Text, Pressable, ScrollView, Alert, ActivityIndicator, useColorScheme } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { useAuthStore } from '@/stores/auth-store';
import { signInWithGoogle } from '@/lib/api/services/auth';
import { TextInput } from '@/components/ui/text-input';
import { VaultMonogram } from '@/components/vault-monogram';
import { FlatCard } from '@/components/flat-card';

export default function SignUp() {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [phone, setPhone] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
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
    if (error) { Alert.alert('Sign Up Failed', error); return; }
    router.replace('/(tabs)');
  };

  const handleGoogleSignIn = async () => {
    try { await signInWithGoogle(); }
    catch { Alert.alert('Error', 'Failed to sign in with Google'); }
  };

  const bg = isDark ? '#08142E' : '#FFFFFF';
  const textColor = isDark ? '#FFFFFF' : '#08142E';
  const mutedColor = isDark ? 'rgba(255,255,255,0.5)' : '#43474D';

  return (
    <View className="flex-1" style={{ backgroundColor: bg }}>
      <ScrollView className="flex-1" contentContainerStyle={{ flexGrow: 1, justifyContent: 'center', padding: 24 }}>
        <Pressable
          onPress={() => router.back()}
          className="w-10 h-10 rounded-full items-center justify-center active:scale-90 mb-6"
          style={{ backgroundColor: isDark ? 'rgba(255,255,255,0.08)' : 'rgba(0,0,0,0.05)' }}
        >
          <MaterialIcons name="arrow-back" size={22} color={isDark ? '#FFFFFF' : '#0A1F5C'} />
        </Pressable>

        <FlatCard className="p-8" style={{ maxWidth: 400, alignSelf: 'center', width: '100%' }}>
          <View className="items-center mb-8">
            <VaultMonogram size={56} />
            <Text className="font-display-bold mt-4" style={{ color: isDark ? '#FFFFFF' : '#0A1F5C', fontSize: 34, lineHeight: 38 }}>
              Create an account
            </Text>
            <Text className="font-body text-body-md mt-1" style={{ color: mutedColor }}>
              Start your financial intelligence journey
            </Text>
          </View>

          <TextInput
            label="Full Name"
            value={name}
            onChangeText={setName}
            placeholder="John Doe"
            error={errors.name}
          />

          <TextInput
            label="Email address"
            value={email}
            onChangeText={setEmail}
            placeholder="name@example.com"
            error={errors.email}
            keyboardType="email-address"
          />

          <TextInput
            label="Phone Number"
            value={phone}
            onChangeText={setPhone}
            placeholder="+1 (555) 000-0000"
            keyboardType="phone-pad"
            rightLabel="Optional"
          />

          <TextInput
            label="Password"
            value={password}
            onChangeText={setPassword}
            placeholder="••••••••"
            error={errors.password}
            secureTextEntry
          />

          <View className="mb-4">
            <View className="flex-row gap-1 mb-1">
              {[1, 2, 3, 4].map((i) => (
                <View
                  key={i}
                  className="h-1 flex-1 rounded-full"
                  style={{
                    backgroundColor: i <= strength ? '#08142E' : isDark ? 'rgba(255,255,255,0.15)' : '#e0e3e6',
                  }}
                />
              ))}
            </View>
            <Text className="font-caption text-caption text-[#08142E]">{strengthLabel} password</Text>
          </View>

          <TextInput
            label="Confirm Password"
            value={confirmPassword}
            onChangeText={setConfirmPassword}
            placeholder="••••••••"
            error={errors.confirmPassword}
            secureTextEntry
          />

          <Pressable
            onPress={handleSubmit}
            disabled={isSubmitting}
            className="w-full py-3.5 items-center justify-center flex-row active:scale-[0.98] mt-2"
            style={{
              backgroundColor: isSubmitting ? '#1A1A1A' : 'rgba(8,20,46,0.08)',
              borderRadius: 9999,
              borderWidth: 1.5,
              borderColor: '#08142E',
            }}
          >
            {isSubmitting ? (
              <ActivityIndicator size="small" color="#74777e" />
            ) : (
              <>
                <Text className="font-body-semibold" style={{ fontSize: 16, color: '#08142E' }}>Create Free Account</Text>
                <MaterialIcons name="arrow-forward" size={20} color="#08142E" style={{ marginLeft: 8 }} />
              </>
            )}
          </Pressable>

          <View className="flex-row items-center my-6">
            <View className="flex-1 h-px" style={{ backgroundColor: isDark ? 'rgba(255,255,255,0.1)' : '#e0e3e6' }} />
            <Text className="font-caption text-caption mx-4" style={{ color: mutedColor }}>Or continue with</Text>
            <View className="flex-1 h-px" style={{ backgroundColor: isDark ? 'rgba(255,255,255,0.1)' : '#e0e3e6' }} />
          </View>

          <View className="flex-row gap-3">
            <Pressable
              onPress={handleGoogleSignIn}
              className="flex-1 flex-row items-center justify-center gap-2 py-3.5 active:scale-95"
              style={{
                backgroundColor: isDark ? 'rgba(255,255,255,0.06)' : '#EEF0F5',
                borderRadius: 9999,
              }}
            >
              <MaterialIcons name="g-mobiledata" size={20} color="#08142E" />
              <Text className="font-body-medium" style={{ fontSize: 16, color: textColor }}>Google</Text>
            </Pressable>
            <Pressable
              className="flex-1 flex-row items-center justify-center gap-2 py-3.5 active:scale-95"
              style={{
                backgroundColor: isDark ? 'rgba(255,255,255,0.06)' : '#EEF0F5',
                borderRadius: 9999,
              }}
            >
              <MaterialIcons name="apple" size={20} color="#08142E" />
              <Text className="font-body-medium" style={{ fontSize: 16, color: textColor }}>Apple</Text>
            </Pressable>
          </View>

          <View className="mt-6 items-center">
            <Text className="font-body text-body-md" style={{ color: mutedColor }}>
              Already have an account?{' '}
              <Text className="text-[#08142E] font-body-semibold" onPress={() => router.push('/login')}>Login</Text>
            </Text>
          </View>

          <View className="mt-6 items-center">
            <View className="flex-row items-center gap-2">
              <MaterialIcons name="lock" size={14} color="#08142E" />
              <Text className="font-caption" style={{ color: mutedColor }}>
                Bank-grade encryption
              </Text>
              <View className="w-1 h-1 rounded-full" style={{ backgroundColor: isDark ? 'rgba(255,255,255,0.2)' : '#c4c6ce' }} />
              <MaterialIcons name="verified" size={14} color="#08142E" />
              <Text className="font-caption" style={{ color: mutedColor }}>
                Your data is safe
              </Text>
            </View>
          </View>
        </FlatCard>
      </ScrollView>
    </View>
  );
}
