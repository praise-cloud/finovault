import { router } from 'expo-router';
import { useState } from 'react';
import { ActivityIndicator, Pressable, ScrollView, Text, View, useWindowDimensions } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { useAuthStore } from '@/src/stores/auth-store';
import { TextInput } from '@/src/components/ui/text-input';
import { Logo } from '@/src/components/logo';

const BLUE = '#123B91';
const PAPER = '#F2F2F2';

export default function SignUp() {
  const signUp = useAuthStore((state) => state.signUp);
  const { width } = useWindowDimensions();
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [phone, setPhone] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const submit = async () => {
    if (!name.trim() || !email.trim() || password.length < 8 || password !== confirmPassword) {
      setError('Complete the fields and make sure both passwords match.');
      return;
    }
    setLoading(true);
    const result = await signUp({ fullName: name.trim(), email: email.trim(), phone: phone.trim() || undefined, password });
    setLoading(false);
    if (result) { setError(result); return; }
    router.push('/preferences');
  };

  return (
    <View style={{ flex: 1, backgroundColor: PAPER, alignItems: 'center' }}>
      <View style={{ width: Math.min(width, 390), flex: 1, backgroundColor: PAPER, paddingHorizontal: 20, paddingTop: 54 }}>
        <View style={styles.topbar}>
          <Pressable onPress={() => router.back()}>
            <MaterialIcons name="arrow-back" size={24} color={BLUE} />
          </Pressable>
          <Logo width={40} height={40} />
        </View>

        <ScrollView showsVerticalScrollIndicator={false} contentContainerStyle={{ paddingBottom: 30, paddingTop: 20 }}>
          <Text style={styles.title}>Personal details</Text>
          <Text style={styles.subtitle}>Tell us a little about yourself to get started.</Text>

          <TextInput label="Full Name" value={name} onChangeText={setName} placeholder="John Doe" />
          <TextInput label="Email Address" value={email} onChangeText={setEmail} placeholder="name@example.com" keyboardType="email-address" autoCapitalize="none" />
          <TextInput label="Phone Number" value={phone} onChangeText={setPhone} placeholder="+1 555 000 0000" keyboardType="phone-pad" />
          <TextInput label="Password" value={password} onChangeText={setPassword} placeholder="••••••••" secureTextEntry />

          <View style={{ flexDirection: 'row', gap: 2, marginTop: -17, marginBottom: 9 }}>
            {[0, 1, 2, 3].map((item) => (
              <View
                key={item}
                style={{
                  height: 2,
                  flex: 1,
                  backgroundColor: item < Math.min(4, Math.floor(password.length / 3)) ? BLUE : '#C8CEDA',
                }}
              />
            ))}
          </View>

          <TextInput label="Confirm Password" value={confirmPassword} onChangeText={setConfirmPassword} placeholder="••••••••" secureTextEntry />

          {!!error && <Text style={styles.error}>{error}</Text>}

          <Pressable onPress={submit} disabled={loading} style={styles.cta}>
            {loading ? (
              <ActivityIndicator color="#FFFFFF" size="small" />
            ) : (
              <>
                <Text style={styles.ctaText}>Continue</Text>
                <MaterialIcons name="arrow-forward" size={14} color="#FFFFFF" />
              </>
            )}
          </Pressable>

          <Text style={styles.helper}>Step 1 of 3</Text>
        </ScrollView>
      </View>
    </View>
  );
}

const styles = {
  topbar: { flexDirection: 'row' as const, justifyContent: 'space-between' as const, alignItems: 'center' as const, marginBottom: 17 },
  title: { color: '#111111', fontFamily: 'Montserrat_700Bold', fontSize: 35, marginBottom: 2 },
  subtitle: { color: '#666B76', fontFamily: 'Montserrat_400Regular', fontSize: 16, lineHeight: 20, marginBottom: 40 },
  cta: { height: 52, borderRadius: 12, backgroundColor: BLUE, flexDirection: 'row' as const, alignItems: 'center' as const, justifyContent: 'center' as const, gap: 7, marginTop: 4 },
  ctaText: { color: '#FFFFFF', fontFamily: 'Montserrat_600SemiBold', fontSize: 16 },
  helper: { textAlign: 'center' as const, color: '#969AA3', fontFamily: 'Montserrat_400Regular', fontSize: 16, marginTop: 12 },
  error: { color: '#8C3A3A', fontFamily: 'Montserrat_400Regular', fontSize: 8, marginBottom: 8 },
};