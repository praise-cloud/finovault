import { useState, useEffect, useRef } from 'react';
import { ScrollView, View, Text, Pressable, ActivityIndicator, TextInput } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { router } from 'expo-router';
import { NotificationIcon, NotificationModal } from '@/components/notification-modal';
import { UserAvatar } from '@/components/user-avatar';
import { useNotificationStore } from '@/stores/notification-store';
import { AlertCard } from '@/components/alert-card';
import * as AIService from '@/lib/api/services/ai';
import * as TransactionsService from '@/lib/api/services/transactions';

type Insight = {
  id: string;
  title: string;
  description: string;
  type: 'opportunity' | 'alert' | 'tip';
  time: string;
};

export default function AiAnalysis() {
  const [question, setQuestion] = useState('');
  const [chat, setChat] = useState<{ role: 'user' | 'ai'; text: string }[]>([
    { role: 'ai', text: 'Hello! I\'m your AI financial coach. Ask me anything about your finances, investments, or savings strategies.' },
  ]);
  const [insights, setInsights] = useState<Insight[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const { count: notifCount, open: openNotifications, visible: notifVisible, close: closeNotifications } = useNotificationStore();
  const [isAsking, setIsAsking] = useState(false);
  const [patternSummary, setPatternSummary] = useState<{ label: string; amount: number; pct: number; color: string }[]>([]);
  const [totalSpent, setTotalSpent] = useState(0);
  const scrollRef = useRef<ScrollView>(null);

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    setIsLoading(true);
    try {
      const [suggestions, txRes] = await Promise.all([
        AIService.getSuggestions().catch(() => []),
        TransactionsService.listTransactions({ limit: 100 }).catch(() => ({ data: [] })),
      ]);
      const mapped: Insight[] = (suggestions || []).map((s: any) => ({
        id: s.id,
        title: s.title || 'AI Insight',
        description: s.description || '',
        type: (s.category === 'alert' ? 'alert' : s.category === 'tip' ? 'tip' : 'opportunity') as any,
        time: s.created_at ? timeAgo(s.created_at) : '',
      }));
      if (mapped.length === 0) {
        mapped.push(
          { id: 'welcome-1', title: 'No Insights Yet', description: 'Start tracking transactions to get personalized AI insights.', type: 'tip', time: '' },
          { id: 'welcome-2', title: 'Ask Your AI Coach', description: 'Use the chat above to ask any financial question.', type: 'opportunity', time: '' },
        );
      }
      setInsights(mapped);

      const expenses = (txRes.data || []).filter((t) => t.type === 'expense');
      const total = expenses.reduce((s, t) => s + t.amount, 0);
      setTotalSpent(total);
      const cats = new Map<string, number>();
      expenses.forEach((t) => {
        const c = t.category || 'General';
        cats.set(c, (cats.get(c) || 0) + t.amount);
      });
      const colors = ['#006b5a', '#0a2540', '#321ed2', '#ba1a1a', '#00705e', '#43474d', '#150082', '#005143'];
      let i = 0;
      const breakdown = Array.from(cats.entries())
        .sort(([, a], [, b]) => b - a)
        .slice(0, 8)
        .map(([label, amount]) => ({
          label,
          amount,
          pct: total > 0 ? Math.round((amount / total) * 100) : 0,
          color: colors[i++ % colors.length],
        }));
      setPatternSummary(breakdown);
    } catch (e) {
      console.error('Failed to load AI analysis data', e);
    }
    setIsLoading(false);
  };

  const handleAsk = async () => {
    if (!question.trim() || isAsking) return;
    const q = question;
    setQuestion('');
    setChat((prev) => [...prev, { role: 'user', text: q }]);
    setIsAsking(true);
    try {
      const res = await AIService.askCoach(q);
      setChat((prev) => [...prev, { role: 'ai', text: res.answer }]);
    } catch {
      setChat((prev) => [...prev, { role: 'ai', text: 'Sorry, I encountered an error. Please try again.' }]);
    }
    setIsAsking(false);
  };

  const getTypeStyle = (type: string) => {
    switch (type) {
      case 'opportunity': return { icon: 'trending-up' as const, bg: 'bg-secondary-container', color: '#00705e' };
      case 'alert': return { icon: 'warning' as const, bg: 'bg-error-container', color: '#ba1a1a' };
      default: return { icon: 'lightbulb' as const, bg: 'bg-primary-container', color: '#000f22' };
    }
  };

  return (
    <View className="flex-1 bg-surface-bright">
      <View className="bg-surface-bright pt-14 pb-3 px-margin-mobile" style={{ shadowColor: '#000', shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.04, elevation: 4 }}>
        <View className="flex-row items-center justify-between">
          <View className="flex-row items-center gap-3">
            <View className="w-9 h-9 rounded-xl bg-secondary items-center justify-center">
              <MaterialIcons name="auto-awesome" size={18} color="#fff" />
            </View>
            <Text className="font-headline-md text-primary font-bold">AI Analysis</Text>
          </View>
          <View className="flex-row items-center gap-3">
            <Pressable onPress={loadData} className="active:scale-90">
              <MaterialIcons name="refresh" size={24} color="#43474d" />
            </Pressable>
            <NotificationIcon onPress={openNotifications} count={notifCount} />
            <Pressable onPress={() => router.push('/(tabs)/profile')} className="active:scale-90">
              <UserAvatar size={36} />
            </Pressable>
          </View>
        </View>
      </View>

      <ScrollView ref={scrollRef} className="flex-1 px-margin-mobile" contentContainerStyle={{ paddingBottom: 120 }} showsVerticalScrollIndicator={false}>
        <View className="bg-gradient-to-br from-secondary to-[#005143] rounded-2xl p-5 mt-4 mb-4 relative overflow-hidden">
          <View className="absolute -top-8 -right-8 w-32 h-32 bg-white/5 rounded-full" />
          <View className="flex-row items-center gap-2 mb-2">
            <MaterialIcons name="auto-awesome" size={20} color="#fff" />
            <Text className="text-white font-headline-md font-bold">AI Financial Coach</Text>
          </View>
          <Text className="text-white/80 text-body-md mb-4">Ask me anything about your finances — I'm here to help you make smarter decisions.</Text>
          <View className="flex-row gap-2">
            <TextInput
              className="flex-1 bg-white/20 rounded-xl px-4 py-3 text-white text-body-md"
              placeholder="Ask a question..."
              placeholderTextColor="rgba(255,255,255,0.5)"
              value={question}
              onChangeText={setQuestion}
            />
            <Pressable onPress={handleAsk} disabled={isAsking} className="w-12 h-12 bg-white rounded-xl items-center justify-center active:scale-90">
              {isAsking ? <ActivityIndicator size="small" color="#006b5a" /> : <MaterialIcons name="send" size={20} color="#006b5a" />}
            </Pressable>
          </View>
        </View>

        {chat.length > 1 && (
          <View className="bg-surface-container-lowest border border-outline-variant/20 rounded-2xl p-4 mb-4 max-h-48 overflow-hidden">
            <ScrollView className="max-h-40">
              {chat.slice(-6).map((msg, i) => (
                <View key={i} className={`mb-2 ${msg.role === 'user' ? 'items-end' : 'items-start'}`}>
                  <View className={`max-w-[80%] rounded-2xl px-4 py-2.5 ${msg.role === 'user' ? 'bg-secondary rounded-br-sm' : 'bg-surface-container-high rounded-bl-sm'}`}>
                    <Text className={msg.role === 'user' ? 'text-on-secondary' : 'text-on-surface'}>{msg.text}</Text>
                  </View>
                </View>
              ))}
            </ScrollView>
          </View>
        )}

        {isLoading ? (
          <View className="items-center py-12"><ActivityIndicator size="large" color="#006b5a" /></View>
        ) : (
          <>
            {patternSummary.length > 0 && (
              <View className="bg-surface-container-lowest border border-outline-variant/20 rounded-2xl p-4 mb-4">
                <View className="flex-row items-center justify-between mb-3">
                  <Text className="font-headline-md text-primary font-bold">Spending Patterns</Text>
                  <Text className="text-caption text-on-surface-variant">${totalSpent.toLocaleString()} total</Text>
                </View>
                {patternSummary.map((p, i) => (
                  <View key={i} className="mb-2">
                    <View className="flex-row justify-between items-center mb-1">
                      <Text className="font-label-md text-primary">{p.label}</Text>
                      <Text className="font-label-md text-on-surface-variant">${p.amount.toLocaleString()} ({p.pct}%)</Text>
                    </View>
                    <View className="w-full bg-surface-container rounded-full h-2 overflow-hidden">
                      <View className="h-full rounded-full" style={{ width: `${p.pct}%`, backgroundColor: p.color }} />
                    </View>
                  </View>
                ))}
              </View>
            )}

            <View className="flex-row items-center justify-between mb-3">
              <Text className="font-headline-md text-primary font-bold">AI Insights</Text>
              <Text className="text-caption text-on-surface-variant">{insights.length} updates</Text>
            </View>

            <View className="space-y-3 mb-4">
              {insights.map((insight) => {
                const style = getTypeStyle(insight.type);
                return (
                  <Pressable key={insight.id} className="flex-row gap-3 p-4 bg-white border border-outline-variant/20 rounded-2xl active:scale-[0.98]">
                    <View className={`w-10 h-10 rounded-full items-center justify-center ${style.bg}`}>
                      <MaterialIcons name={style.icon} size={20} color={style.color} />
                    </View>
                    <View className="flex-1">
                      <View className="flex-row justify-between items-start">
                        <Text className="font-label-md font-bold text-primary flex-1">{insight.title}</Text>
                        {insight.time ? <Text className="text-caption text-on-surface-variant text-xs ml-2">{insight.time}</Text> : null}
                      </View>
                      <Text className="text-body-md text-on-surface-variant text-sm mt-0.5">{insight.description}</Text>
                      <Pressable onPress={() => router.push('/(tabs)/transactions')} className="mt-2"><Text className="text-secondary font-label-md text-xs font-bold">View Details</Text></Pressable>
                    </View>
                  </Pressable>
                );
              })}
            </View>

            <AlertCard type="info" title="AI Accuracy" message="Insights are generated based on your financial data and market analysis. Always verify before making major decisions." />
          </>
        )}
      </ScrollView>

      <NotificationModal visible={notifVisible} onClose={closeNotifications} />
    </View>
  );
}

function timeAgo(dateStr: string): string {
  const diff = Date.now() - new Date(dateStr).getTime();
  const mins = Math.floor(diff / 60000);
  if (mins < 2) return '1m ago';
  if (mins < 60) return `${mins}m ago`;
  const hours = Math.floor(mins / 60);
  if (hours < 2) return '1h ago';
  if (hours < 24) return `${hours}h ago`;
  const days = Math.floor(hours / 24);
  return `${days}d ago`;
}
