import { router } from 'expo-router';
import { useEffect } from 'react';
import { Pressable, Text, View, useWindowDimensions, useColorScheme } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { useAuthStore } from '@/src/stores/auth-store';

const BLUE = '#123B91';
const PAPER = '#F2F2F2';

export default function WelcomeTour() {
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';
  const isAuthenticated = useAuthStore((state) => state.isAuthenticated);
  const { width } = useWindowDimensions();

  useEffect(() => {
    if (isAuthenticated) router.replace('/(tabs)');
  }, [isAuthenticated]);

  return (
    <View style={{ flex: 1, backgroundColor: isDark ? '#08142E' : PAPER, alignItems: 'center', justifyContent: 'center' }}>
      <View style={{ width: Math.min(width, 600), flex: 1, maxHeight: '100%', backgroundColor: isDark ? '#08142E' : PAPER, paddingHorizontal: 18, paddingTop: 54, paddingBottom: 30 }}>
        <View style={{width: '100%', height: 5, borderRadius: 10, backgroundColor: BLUE, alignItems: 'center', justifyContent: 'center'}}></View>
        <View style={{ alignItems: 'center', marginTop: 18 }}>
          <View style={{ width: '100%', height: 246, borderRadius: 5, backgroundColor: BLUE, alignItems: 'center', justifyContent: 'center' }}>
            <MaterialIcons name="security" size={46} color="#FFFFFF" />
          </View>
          <Text style={{ alignSelf: 'flex-start', color: isDark ? '#FFFFFF' : '#111111', fontFamily: 'Montserrat_800ExtraBold', fontSize: 60, lineHeight: 50, marginTop: '20%', marginBottom: '20%' }}>
            Where{`\n`}Wealth{`\n`}Feels Safe.
          </Text>
        </View>

        <View style={{ flexDirection: 'row', gap: 12 , marginBottom: '5%', marginTop: '5%' }}>
          <Pressable onPress={() => router.push('/login')} accessibilityRole="button" style={({ pressed }) => [styles.button, { flex: 1, opacity: pressed ? 0.78 : 1 }]}>
            <Text style={styles.buttonText}>Log In</Text>
          </Pressable>
          <Pressable onPress={() => router.push('/signup')} accessibilityRole="button" style={({ pressed }) => [styles.button, { flex: 1, opacity: pressed ? 0.78 : 1 }]}>
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
