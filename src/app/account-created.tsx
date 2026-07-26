import { useEffect } from 'react';
import { router } from 'expo-router';
import { Text, View, useColorScheme } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';

const BLUE = '#123B91';
const PAPER = '#F2F2F2';

export default function AccountCreated() {
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';
  useEffect(() => {
    const timer = setTimeout(() => {
      router.replace('/(tabs)');
    }, 1800);
    return () => clearTimeout(timer);
  }, []);

  return (
    <View style={{ flex: 1, backgroundColor: isDark ? '#08142E' : PAPER, alignItems: 'center', justifyContent: 'center' }}>
      <View style={styles.checkCircle}>
        <MaterialIcons name="check" size={44} color="#FFFFFF" />
      </View>
      <Text style={[styles.text, { color: isDark ? '#FFFFFF' : '#111111' }]}>Account successfully Created!</Text>
    </View>
  );
}

const styles = {
  checkCircle: {
    width: 88,
    height: 88,
    borderRadius: 44,
    backgroundColor: BLUE,
    alignItems: 'center' as const,
    justifyContent: 'center' as const,
    marginBottom: 24,
  },
  text: {
    color: '#111111',
    fontFamily: 'Montserrat_700Bold',
    fontSize: 18,
    textAlign: 'center' as const,
  },
};