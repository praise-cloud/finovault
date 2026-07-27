import { router } from 'expo-router';
import { Pressable, Text, View, useWindowDimensions, useColorScheme } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { usePreferencesStore } from '@/src/stores/preferences-store';
import { Logo } from '@/src/components/logo';

const BLUE = '#123B91';
const PAPER = '#F2F2F2';

const ROLES = [
  { key: 'individual', label: 'Individual', icon: 'person' as const },
  { key: 'sme', label: 'SME', icon: 'business' as const },
  { key: 'entrepreneur', label: 'Woman\nEntrepreneur', icon: 'woman' as const },
  { key: 'freelancer', label: 'Freelancer', icon: 'work' as const },
];

export default function Preferences() {
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';
  const { width } = useWindowDimensions();
  const selectedRole = usePreferencesStore((state) => state.role);
  const setRole = usePreferencesStore((state) => state.setRole);

  return (
    <View style={{ flex: 1, backgroundColor: isDark ? '#08142E' : PAPER, alignItems: 'center' }}>
      <View style={{ width: Math.min(width, 600), flex: 1, backgroundColor: isDark ? '#08142E' : PAPER, paddingHorizontal: 24, paddingTop: 60 }}>
        <View style={styles.topbar}>
          <Pressable onPress={() => router.back()} accessibilityRole="button" accessibilityLabel="Go back" hitSlop={12}>
            <MaterialIcons name="arrow-back" size={24} color={isDark ? '#D4AF37' : BLUE} />
          </Pressable>
          <Logo width={26} height={23.5} color={isDark ? '#D4AF37' : BLUE} />
        </View>

        <Text style={[styles.title, { color: isDark ? '#FFFFFF' : '#111111' }]}>Let's personalize your{'\n'}experience</Text>
        <Text style={[styles.subtitle, { color: isDark ? '#B0B0B0' : '#666B76' }]}>
          Help us tailor our AI insights to your specific professional needs and financial landscape.
        </Text>

        <Text style={[styles.label, { color: isDark ? '#8C8F9E' : '#8A8E98' }]}>WHO ARE YOU?</Text>

        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 12 }}>
          {ROLES.map((role) => {
            const selected = selectedRole === role.key;
            return (
              <Pressable
                key={role.key}
                onPress={() => setRole(role.key)}
                accessibilityRole="button"
                style={[
                  styles.role,
                  { backgroundColor: isDark ? '#1A1A1A' : '#FFFFFF', borderColor: isDark ? '#2A2A2A' : '#E1E4EC' },
                  selected && { borderColor: BLUE, backgroundColor: isDark ? '#0F2040' : '#EEF1FB' },
                ]}
              >
                <View style={[
                  styles.iconCircle,
                  { backgroundColor: isDark ? '#2A2A2A' : '#EEF0F5' },
                  selected && { backgroundColor: isDark ? '#1A2A5C' : '#DCE3F7' },
                ]}>
                  <MaterialIcons name={role.icon} size={22} color={BLUE} />
                </View>
                <Text style={[styles.roleText, { color: isDark ? '#FFFFFF' : '#20232A' }]}>{role.label}</Text>
              </Pressable>
            );
          })}
        </View>

        <Pressable onPress={() => router.push('/financial-profile')} accessibilityRole="button" style={[styles.cta, { marginTop: 24 }]}>
          <Text style={styles.ctaText}>Continue</Text>
          <MaterialIcons name="arrow-forward" size={18} color="#FFFFFF" />
        </Pressable>

        <Text style={[styles.helper, { color: isDark ? '#8C8F9E' : '#969AA3' }]}>Step 2 of 4 • Preferences</Text>
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
  title: {
    color: '#111111',
    fontFamily: 'Montserrat_700Bold',
    fontSize: 26,
    lineHeight: 32,
    marginBottom: 10,
  },
  subtitle: {
    color: '#666B76',
    fontFamily: 'Montserrat_400Regular',
    fontSize: 15,
    lineHeight: 21,
    marginBottom: 28,
  },
  label: {
    color: '#8A8E98',
    fontFamily: 'Montserrat_600SemiBold',
    fontSize: 12,
    letterSpacing: 0.6,
    marginBottom: 12,
  },
  role: {
    width: '48%' as const,
    minHeight: 130,
    backgroundColor: '#FFFFFF',
    borderRadius: 16,
    borderWidth: 1.5,
    borderColor: '#E1E4EC',
    alignItems: 'center' as const,
    justifyContent: 'center' as const,
    paddingVertical: 20,
  },
  selected: {
    borderColor: BLUE,
    backgroundColor: '#EEF1FB',
  },
  iconCircle: {
    width: 44,
    height: 44,
    borderRadius: 22,
    backgroundColor: '#EEF0F5',
    alignItems: 'center' as const,
    justifyContent: 'center' as const,
    marginBottom: 10,
  },
  iconCircleSelected: {
    backgroundColor: '#DCE3F7',
  },
  roleText: {
    color: '#20232A',
    fontFamily: 'Montserrat_600SemiBold',
    fontSize: 13,
    textAlign: 'center' as const,
    lineHeight: 17,
  },
  cta: {
    height: 56,
    borderRadius: 14,
    backgroundColor: BLUE,
    flexDirection: 'row' as const,
    alignItems: 'center' as const,
    justifyContent: 'center' as const,
    gap: 8,
  },
  ctaText: {
    color: '#FFFFFF',
    fontFamily: 'Montserrat_600SemiBold',
    fontSize: 16,
  },
  helper: {
    textAlign: 'center' as const,
    color: '#969AA3',
    fontFamily: 'Montserrat_400Regular',
    fontSize: 13,
    marginTop: 14,
  },
};