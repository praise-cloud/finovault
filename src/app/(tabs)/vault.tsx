import { useRef, useState } from 'react';
import {
  KeyboardAvoidingView,
  Platform,
  Pressable,
  ScrollView,
  Text,
  TextInput,
  View,
  useWindowDimensions,
} from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { router } from 'expo-router';
import { NotificationIcon, NotificationModal } from '@/src/components/notification-modal';
import { UserAvatar } from '@/src/components/user-avatar';
import { Logo } from '@/src/components/logo';
import { useNotificationStore } from '@/src/stores/notification-store';
import { useAuthStore } from '@/src/stores/auth-store';
// TODO: replace the local `send()` stub below with a real call, e.g.:
// import { askVaultAssistant } from '@/src/lib/api/services/assistant';

const BLUE = '#123B91';
const PAPER = '#F2F2F2';

type Message = { id: string; role: 'user' | 'assistant'; text: string };

const SUGGESTIONS = [
  'What was my budget last month?',
  'What is our current financial stance and what direction do we need to go?',
];

export default function VaultAssistant() {
  const { width } = useWindowDimensions();
  const user = useAuthStore((s) => s.user);
  const { count: notifCount, open: openNotifications, visible: notifVisible, close: closeNotifications } = useNotificationStore();
  const userName = user?.user_metadata?.full_name?.split(' ')[0] || 'there';

  const [messages, setMessages] = useState<Message[]>([
    { id: 'greeting', role: 'assistant', text: `Hey, ${userName}` },
  ]);
  const [input, setInput] = useState('');
  const [sending, setSending] = useState(false);
  const scrollRef = useRef<ScrollView>(null);

  const send = async (text?: string) => {
    const content = (text ?? input).trim();
    if (!content) return;

    const userMsg: Message = { id: `u-${Date.now()}`, role: 'user', text: content };
    setMessages((prev) => [...prev, userMsg]);
    setInput('');
    setSending(true);

    try {
      // TODO: replace with a real backend call, e.g.:
      // const reply = await askVaultAssistant(content);
      await new Promise((resolve) => setTimeout(resolve, 600));
      setMessages((prev) => [
        ...prev,
        { id: `a-${Date.now()}`, role: 'assistant', text: "I'm looking into that for you." },
      ]);
    } finally {
      setSending(false);
      requestAnimationFrame(() => scrollRef.current?.scrollToEnd({ animated: true }));
    }
  };

  const hasConversation = messages.length > 1;

  return (
    <KeyboardAvoidingView style={{ flex: 1, backgroundColor: PAPER }} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
      <View style={{ flex: 1, alignItems: 'center' }}>
        <View style={{ width: Math.min(width, 390), flex: 1 }}>
          <View style={{ paddingHorizontal: 20, paddingTop: 60, paddingBottom: 12 }}>
            <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' }}>
              <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8 }}>
                <Logo width={20} height={18} color={BLUE} />
                <Text style={{ fontFamily: 'Montserrat_700Bold', fontSize: 18, color: '#1A1A1A' }}>Vault</Text>
              </View>
              <View style={{ flexDirection: 'row', alignItems: 'center', gap: 12 }}>
                <NotificationIcon onPress={openNotifications} count={notifCount} />
                <Pressable onPress={() => router.push('/(tabs)/profile')}>
                  <UserAvatar size={32} />
                </Pressable>
              </View>
            </View>
          </View>

          <ScrollView
            ref={scrollRef}
            style={{ flex: 1, paddingHorizontal: 20 }}
            contentContainerStyle={{ paddingBottom: 16 }}
            showsVerticalScrollIndicator={false}
          >
            {messages.map((m) => (
              <View
                key={m.id}
                style={{
                  flexDirection: 'row',
                  justifyContent: m.role === 'user' ? 'flex-end' : 'flex-start',
                  marginBottom: 10,
                }}
              >
                {m.role === 'assistant' && (
                  <View
                    style={{
                      width: 26,
                      height: 26,
                      borderRadius: 13,
                      backgroundColor: BLUE,
                      alignItems: 'center',
                      justifyContent: 'center',
                      marginRight: 8,
                    }}
                  >
                    <Logo width={11} height={10} color="#FFFFFF" />
                  </View>
                )}
                <View
                  style={{
                    maxWidth: '75%',
                    backgroundColor: m.role === 'user' ? BLUE : '#FFFFFF',
                    borderRadius: 16,
                    borderTopLeftRadius: m.role === 'assistant' ? 4 : 16,
                    borderTopRightRadius: m.role === 'user' ? 4 : 16,
                    paddingHorizontal: 14,
                    paddingVertical: 10,
                    borderWidth: m.role === 'assistant' ? 1 : 0,
                    borderColor: '#E1E4EC',
                  }}
                >
                  <Text
                    style={{
                      fontFamily: 'Montserrat_400Regular',
                      fontSize: 14,
                      lineHeight: 19,
                      color: m.role === 'user' ? '#FFFFFF' : '#1A1A1A',
                    }}
                  >
                    {m.text}
                  </Text>
                </View>
              </View>
            ))}

            {sending && (
              <View style={{ flexDirection: 'row', alignItems: 'center', marginBottom: 10 }}>
                <View
                  style={{
                    width: 26,
                    height: 26,
                    borderRadius: 13,
                    backgroundColor: BLUE,
                    alignItems: 'center',
                    justifyContent: 'center',
                    marginRight: 8,
                  }}
                >
                  <Logo width={11} height={10} color="#FFFFFF" />
                </View>
                <Text style={{ fontFamily: 'Montserrat_400Regular', fontSize: 13, color: '#8A8E98' }}>Typing…</Text>
              </View>
            )}

            {!hasConversation && (
              <View style={{ marginTop: 8, gap: 8 }}>
                {SUGGESTIONS.map((s) => (
                  <Pressable
                    key={s}
                    onPress={() => send(s)}
                    style={{
                      alignSelf: 'flex-start',
                      backgroundColor: '#FFFFFF',
                      borderWidth: 1,
                      borderColor: '#E1E4EC',
                      borderRadius: 14,
                      paddingHorizontal: 14,
                      paddingVertical: 10,
                      maxWidth: '90%',
                    }}
                  >
                    <Text style={{ fontFamily: 'Montserrat_500Medium', fontSize: 13, color: BLUE }}>{s}</Text>
                  </Pressable>
                ))}
              </View>
            )}
          </ScrollView>

          <View style={{ paddingHorizontal: 20, paddingBottom: 24, paddingTop: 8 }}>
            <View
              style={{
                flexDirection: 'row',
                alignItems: 'center',
                backgroundColor: '#FFFFFF',
                borderRadius: 9999,
                borderWidth: 1,
                borderColor: '#E1E4EC',
                paddingLeft: 18,
                paddingRight: 6,
                height: 52,
              }}
            >
              <TextInput
                value={input}
                onChangeText={setInput}
                placeholder="Ask Vault anything…"
                placeholderTextColor="#9AA0AC"
                style={{ flex: 1, fontFamily: 'Montserrat_400Regular', fontSize: 14, color: '#1A1A1A' }}
                onSubmitEditing={() => send()}
                returnKeyType="send"
              />
              <Pressable hitSlop={8} style={{ padding: 6 }}>
                <MaterialIcons name="mic-none" size={20} color={BLUE} />
              </Pressable>
              <Pressable
                onPress={() => send()}
                disabled={!input.trim()}
                style={{
                  width: 38,
                  height: 38,
                  borderRadius: 19,
                  backgroundColor: input.trim() ? BLUE : '#C9CEDD',
                  alignItems: 'center',
                  justifyContent: 'center',
                  marginLeft: 6,
                }}
              >
                <MaterialIcons name="arrow-upward" size={18} color="#FFFFFF" />
              </Pressable>
            </View>
          </View>
        </View>
      </View>

      <NotificationModal visible={notifVisible} onClose={closeNotifications} />
    </KeyboardAvoidingView>
  );
}