import { useState, useRef, useEffect } from 'react';
import { View, Text, Pressable, TextInput, ScrollView, ActivityIndicator, KeyboardAvoidingView, Platform } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { router } from 'expo-router';
import * as AIService from '@/lib/api/services/ai';

interface Message {
  role: 'user' | 'assistant';
  content: string;
}

export default function AICoachScreen() {
  const [messages, setMessages] = useState<Message[]>([
    { role: 'assistant', content: 'Hi! I\'m your financial AI coach. Ask me anything about your finances, savings, investments, or budgeting.' },
  ]);
  const [input, setInput] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const scrollRef = useRef<ScrollView>(null);

  useEffect(() => {
    scrollRef.current?.scrollToEnd({ animated: true });
  }, [messages]);

  const handleSend = async () => {
    const question = input.trim();
    if (!question || isLoading) return;

    setInput('');
    setMessages((prev) => [...prev, { role: 'user', content: question }]);
    setIsLoading(true);

    try {
      const res = await AIService.askCoach(question);
      setMessages((prev) => [...prev, { role: 'assistant', content: res.answer }]);
    } catch (e: any) {
      setMessages((prev) => [...prev, { role: 'assistant', content: `Sorry, I encountered an error: ${e.message}` }]);
    }
    setIsLoading(false);
  };

  return (
    <KeyboardAvoidingView className="flex-1 bg-surface-bright" behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
      <View className="bg-surface-bright pt-14 pb-3 px-margin-mobile" style={{ shadowColor: '#000', shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.04, elevation: 4 }}>
        <View className="flex-row items-center gap-3">
          <Pressable onPress={() => router.back()} className="active:scale-90">
            <MaterialIcons name="arrow-back" size={24} color="#000f22" />
          </Pressable>
          <View className="flex-1">
            <Text className="font-headline-md text-primary font-bold">AI Coach</Text>
            <Text className="text-caption text-on-surface-variant">Your personal financial advisor</Text>
          </View>
          <MaterialIcons name="auto-awesome" size={24} color="#006b5a" />
        </View>
      </View>

      <ScrollView ref={scrollRef} className="flex-1 px-margin-mobile" contentContainerStyle={{ paddingVertical: 16, paddingBottom: 16 }}>
        {messages.map((msg, i) => (
          <View key={i} className={`mb-4 ${msg.role === 'user' ? 'items-end' : 'items-start'}`}>
            <View className={`max-w-[80%] rounded-2xl px-4 py-3 ${msg.role === 'user' ? 'bg-primary' : 'bg-surface-container-lowest border border-outline-variant/20'}`}>
              <Text className={`font-body-md ${msg.role === 'user' ? 'text-on-primary' : 'text-on-surface'}`}>
                {msg.content}
              </Text>
            </View>
          </View>
        ))}
        {isLoading && (
          <View className="items-start mb-4">
            <View className="bg-surface-container-lowest border border-outline-variant/20 rounded-2xl px-4 py-3">
              <View className="flex-row gap-1">
                <View className="w-2 h-2 rounded-full bg-secondary animate-pulse" />
                <View className="w-2 h-2 rounded-full bg-secondary animate-pulse" style={{ opacity: 0.6 }} />
                <View className="w-2 h-2 rounded-full bg-secondary animate-pulse" style={{ opacity: 0.3 }} />
              </View>
            </View>
          </View>
        )}
      </ScrollView>

      <View className="px-margin-mobile pb-6 pt-2 bg-surface-bright border-t border-outline-variant/10">
        <View className="flex-row items-center gap-2 bg-surface-container-lowest border border-outline-variant/30 rounded-2xl px-4 py-2">
          <TextInput
            className="flex-1 font-body-md py-2"
            placeholder="Ask your financial coach..."
            value={input}
            onChangeText={setInput}
            multiline
            maxLength={2000}
          />
          <Pressable
            onPress={handleSend}
            disabled={isLoading || !input.trim()}
            className={`w-10 h-10 rounded-full items-center justify-center ${input.trim() ? 'bg-primary' : 'bg-surface-container'}`}
          >
            <MaterialIcons name="send" size={20} color={input.trim() ? '#fff' : '#c4c7cb'} />
          </Pressable>
        </View>
      </View>
    </KeyboardAvoidingView>
  );
}
