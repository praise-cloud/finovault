import { router } from 'expo-router';
import { useEffect, useState } from 'react';
import { Pressable, Text, View, useWindowDimensions } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { useAuthStore } from '@/src/stores/auth-store';

const BLUE = '#123B91';
const PAPER = '#F2F2F2';

export default function WelcomeTour() {
  const isAuthenticated = useAuthStore((state) => state.isAuthenticated);
  const [showSplash, setShowSplash] = useState(true);
  const { width } = useWindowDimensions();

  useEffect(() => {
    const timer = setTimeout(() => setShowSplash(false), 950);
    return () => clearTimeout(timer);
  }, []);

  useEffect(() => {
    if (isAuthenticated) router.replace('/(tabs)');
  }, [isAuthenticated]);

  if (showSplash) {
    return (
      <View style={{ flex: 1, backgroundColor: BLUE, alignItems: 'center', justifyContent: 'center' }} />
    );
  }

  return (
    <View style={{ flex: 1, backgroundColor: PAPER, alignItems: 'center', justifyContent: 'center' }}>
      <View style={{ width: Math.min(width, 390), flex: 1, maxHeight: '100%', backgroundColor: PAPER, paddingHorizontal: 18, paddingTop: 54, paddingBottom: 30 }}>
        <View style={{width: '100%', height: 5, borderRadius: 10, backgroundColor: BLUE, alignItems: 'center', justifyContent: 'center'}}></View>
        <View style={{ alignItems: 'center', marginTop: 18 }}>
          <View style={{ width: '100%', height: 246, borderRadius: 5, backgroundColor: BLUE, alignItems: 'center', justifyContent: 'center' }}>
            <MaterialIcons name="security" size={46} color="#FFFFFF" />
          </View>
          <Text style={{ alignSelf: 'flex-start', color: '#111111', fontFamily: 'Giest_800ExtraBold', fontSize: 60, lineHeight: 50, marginTop: '20%', marginBottom: '20%' }}>
            Where{`\n`}Wealth{`\n`}Feels Safe.
          </Text>
        </View>

        <View style={{ flexDirection: 'row', gap: 12 , marginBottom: '5%', marginTop: '5%' }}>
          <Pressable onPress={() => router.push('/login')} style={({ pressed }) => [styles.button, { flex: 1, opacity: pressed ? 0.78 : 1 }]}>
            <Text style={styles.buttonText}>Log In</Text>
          </Pressable>
          <Pressable onPress={() => router.push('/signup')} style={({ pressed }) => [styles.button, { flex: 1, opacity: pressed ? 0.78 : 1 }]}>
            <Text style={styles.buttonText}>Register</Text>
          </Pressable>
        </View>

      </View>
    </View>
  );
}

const styles = {
  button: { height: 52, borderRadius: 12, backgroundColor: BLUE, alignItems: 'center' as const, justifyContent: 'center' as const },
  buttonText: { color: '#FFFFFF', fontFamily: 'Montserrat_600SemiBold', fontSize: 16 },
};
