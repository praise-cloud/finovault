import { router } from 'expo-router';
import { useState } from 'react';
import { View, Text, Pressable, ScrollView, Alert, ActivityIndicator, useColorScheme } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { useAuthStore } from '@/stores/auth-store';
import { signInWithGoogle } from '@/lib/api/services/auth';
import { mediumImpact, successNotification, errorNotification } from '@/hooks/use-haptics';
import { TextInput } from '@/components/ui/text-input';
import { VaultMonogram } from '@/components/vault-monogram';
import { FlatCard } from '@/components/flat-card';

export default function Login() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [errors, setErrors] = useState<Record<string, string>>({});
  const signIn = useAuthStore((s) => s.signIn);
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';

  const validate = () => {
    const errs: Record<string, string> = {};
    if (!email.trim()) errs.email = 'Email is required';
    if (!password) errs.password = 'Password is required';
    setErrors(errs);
    return Object.keys(errs).length === 0;
  };

  const handleLogin = async () => {
    if (!validate()) { errorNotification(); return; }
    mediumImpact();
    setIsSubmitting(true);
    const error = await signIn({ email, password });
    setIsSubmitting(false);
    if (error) { errorNotification(); Alert.alert('Login Failed', error); return; }
    successNotification();
    router.replace('/(tabs)');
  };

  const handleGoogleSignIn = async () => {
    try { mediumImpact(); await signInWithGoogle(); }
    catch { errorNotification(); Alert.alert('Error', 'Failed to sign in with Google'); }
  };

  const bg = isDark ? '#08142E' : '#F7F9FC';
  const textColor = isDark ? '#FFFFFF' : '#1A1A1A';
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
              Welcome back
            </Text>
            <Text className="font-body text-body-md mt-1" style={{ color: mutedColor }}>
              Log in to your Finovault account
            </Text>
          </View>

          <TextInput
            label="Email address"
            value={email}
            onChangeText={setEmail}
            placeholder="name@example.com"
            error={errors.email}
            keyboardType="email-address"
          />

          <TextInput
            label="Password"
            value={password}
            onChangeText={setPassword}
            placeholder="••••••••"
            error={errors.password}
            secureTextEntry
          />

          <Pressable
            onPress={handleLogin}
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
                <Text className="font-body-semibold" style={{ fontSize: 16, color: '#08142E' }}>Log In</Text>
                <MaterialIcons name="arrow-forward" size={20} color="#08142E" style={{ marginLeft: 8 }} />
              </>
            )}
          </Pressable>

          <View className="flex-row items-center my-6">
            <View className="flex-1 h-px" style={{ backgroundColor: isDark ? 'rgba(255,255,255,0.1)' : '#e0e3e6' }} />
            <Text className="font-caption text-caption mx-4" style={{ color: mutedColor }}>Or continue with</Text>
            <View className="flex-1 h-px" style={{ backgroundColor: isDark ? 'rgba(255,255,255,0.1)' : '#e0e3e6' }} />
          </View>

          <Pressable
            onPress={handleGoogleSignIn}
            className="flex-row items-center justify-center gap-3 py-3.5 active:scale-95"
            style={{
              backgroundColor: isDark ? 'rgba(255,255,255,0.06)' : '#EEF0F5',
              borderRadius: 9999,
            }}
          >
            <MaterialIcons name="g-mobiledata" size={20} color="#08142E" />
            <Text className="font-body-medium" style={{ fontSize: 16, color: textColor }}>Google</Text>
          </Pressable>

          <Pressable className="flex-row items-center justify-center mt-6 gap-2">
            <MaterialIcons name="fingerprint" size={20} color="#08142E" />
            <Text className="font-body text-body-md text-[#08142E]">Use Face ID to log in faster</Text>
          </Pressable>

          <View className="mt-6 items-center">
            <Text className="font-body text-body-md" style={{ color: mutedColor }}>
              Don't have an account?{' '}
              <Text className="text-[#08142E] font-body-semibold" onPress={() => router.push('/signup')}>Sign Up</Text>
            </Text>
          </View>

          <View className="mt-6 items-center">
            <View className="flex-row items-center gap-2">
              <MaterialIcons name="lock" size={14} color="#08142E" />
              <Text className="font-caption" style={{ color: mutedColor }}>
                AES-256 encrypted
              </Text>
              <View className="w-1 h-1 rounded-full" style={{ backgroundColor: isDark ? 'rgba(255,255,255,0.2)' : '#c4c6ce' }} />
              <MaterialIcons name="verified" size={14} color="#08142E" />
              <Text className="font-caption" style={{ color: mutedColor }}>
                Verified secure
              </Text>
            </View>
          </View>
        </FlatCard>
      </ScrollView>
    </View>
  );
}
