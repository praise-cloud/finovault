import { router } from 'expo-router';
import { useState } from 'react';
import { ActivityIndicator, Pressable, ScrollView, Text, View, useWindowDimensions, useColorScheme } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { useAuthStore } from '@/src/stores/auth-store';
import { TextInput } from '@/src/components/ui/text-input';

const BLUE = '#123B91';
const PAPER = '#F2F2F2';

export default function Login() {
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';
  const signIn = useAuthStore((state) => state.signIn);
  const { width } = useWindowDimensions();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const submit = async () => {
    if (!email.trim() || !password) {
      setError('Enter your email and password.');
      return;
    }
    setLoading(true);
    const result = await signIn({ email: email.trim(), password });
    setLoading(false);
    if (result) {
      setError(result);
      return;
    }
    router.replace('/(tabs)');
  };

  return (
    <View style={{ flex: 1, backgroundColor: isDark ? '#08142E' : PAPER, alignItems: 'center' }}>
      <View style={{ width: Math.min(width, 390), flex: 1, backgroundColor: isDark ? '#08142E' : PAPER, paddingHorizontal: 24, paddingTop: 60 }}>
        <View style={styles.topbar}>
          <Pressable onPress={() => router.back()} hitSlop={12}>
            <MaterialIcons name="arrow-back" size={24} color={isDark ? '#D4AF37' : BLUE} />
          </Pressable>
          <Pressable onPress={() => router.push('/signup')} hitSlop={12}>
            <Text style={styles.signUp}>Sign UP</Text>
          </Pressable>
        </View>

        <ScrollView showsVerticalScrollIndicator={false} contentContainerStyle={{ paddingBottom: 30 }}>
          <Text style={[styles.title, { color: isDark ? '#FFFFFF' : '#111111' }]}>Welcome back!</Text>
          <Text style={[styles.subtitle, { color: isDark ? '#B0B0B0' : '#666B76' }]}>Let's get you back into building wealth</Text>

          <TextInput
            label="Email address"
            value={email}
            onChangeText={setEmail}
            placeholder="name@example.com"
            keyboardType="email-address"
            autoCapitalize="none"
          />

          <TextInput
            label="Password"
            value={password}
            onChangeText={setPassword}
            placeholder="••••••••"
            secureTextEntry
          />

          <Pressable style={{ alignSelf: 'flex-start', marginTop: 4, marginBottom: 24 }}>
            <Text style={styles.link}>Forgot your password?</Text>
          </Pressable>

          {!!error && <Text style={styles.error}>{error}</Text>}

          <Pressable
            onPress={submit}
            disabled={loading}
            style={({ pressed }) => [styles.cta, { opacity: pressed ? 0.85 : 1 }]}
          >
            {loading ? <ActivityIndicator color="#FFFFFF" size="small" /> : <Text style={styles.ctaText}>Log in</Text>}
          </Pressable>
        </ScrollView>
      </View>
    </View>
  );
}

const styles = {
  topbar: {
    flexDirection: 'row' as const,
    justifyContent: 'space-between' as const,
    alignItems: 'center' as const,
    marginBottom: 32,
  },
  signUp: {
    color: BLUE,
    fontFamily: 'Montserrat_600SemiBold',
    fontSize: 14,
  },
  title: {
    color: '#111111',
    fontFamily: 'Montserrat_700Bold',
    fontSize: 32,
    marginBottom: 8,
  },
  subtitle: {
    color: '#666B76',
    fontFamily: 'Montserrat_400Regular',
    fontSize: 15,
    lineHeight: 20,
    marginBottom: 28,
  },
  cta: {
    height: 56,
    borderRadius: 14,
    backgroundColor: BLUE,
    alignItems: 'center' as const,
    justifyContent: 'center' as const,
    marginTop: 4,
  },
  ctaText: {
    color: '#FFFFFF',
    fontFamily: 'Montserrat_600SemiBold',
    fontSize: 16,
  },
  link: {
    color: BLUE,
    fontFamily: 'Montserrat_600SemiBold',
    fontSize: 14,
  },
  error: {
    color: '#8C3A3A',
    fontFamily: 'Montserrat_400Regular',
    fontSize: 13,
    marginBottom: 12,
  },
};