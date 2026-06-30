import { useEffect, useState } from 'react';
import { ScrollView, View, Text, Pressable, ActivityIndicator, TextInput } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { router } from 'expo-router';
import { NotificationIcon, NotificationModal } from '@/components/notification-modal';
import { UserAvatar } from '@/components/user-avatar';
import { AlertCard } from '@/components/alert-card';

type Insight = {
  id: string;
  title: string;
  description: string;
  type: 'opportunity' | 'alert' | 'tip';
  time: string;
};

const MOCK_INSIGHTS: Insight[] = [
  { id: '1', title: 'Portfolio Rebalance Suggested', description: 'Your SME equity allocation has grown 12% above target. Consider rebalancing to maintain optimal risk.', type: 'opportunity', time: '2 hours ago' },
  { id: '2', title: 'Spending Pattern Change', description: 'Your lifestyle spending increased 8% this month. AI recommends reviewing subscription services.', type: 'alert', time: '5 hours ago' },
  { id: '3', title: 'Savings Opportunity', description: 'Round-up savings could earn you $240 more this year by switching to the smart savings plan.', type: 'tip', time: '1 day ago' },
  { id: '4', title: 'Market Insight', description: 'Tech sector showing bullish signals. Consider increasing allocation by 3-5%.', type: 'opportunity', time: '1 day ago' },
  { id: '5', title: 'Tax Optimization', description: 'You have unused tax allowances. Consult your AI coach for optimization strategies.', type: 'tip', time: '2 days ago' },
];

export default function AiAnalysis() {
  const [notifVisible, setNotifVisible] = useState(false);
  const [question, setQuestion] = useState('');
  const [chat, setChat] = useState<{ role: 'user' | 'ai'; text: string }[]>([
    { role: 'ai', text: 'Hello! I\'m your AI financial coach. Ask me anything about your finances, investments, or savings strategies.' },
  ]);

  const handleAsk = () => {
    if (!question.trim()) return;
    setChat((prev) => [...prev, { role: 'user', text: question }]);
    setQuestion('');
    setTimeout(() => {
      setChat((prev) => [...prev, { role: 'ai', text: 'Great question! Based on your financial profile, I recommend reviewing your asset allocation. Your current portfolio is weighted heavily toward growth assets. Consider diversifying into more stable options to balance risk. Would you like me to prepare a detailed analysis?' }]);
    }, 1000);
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
            <NotificationIcon onPress={() => setNotifVisible(true)} count={2} />
            <Pressable onPress={() => router.push('/(tabs)/profile')} className="active:scale-90">
              <UserAvatar size={36} />
            </Pressable>
          </View>
        </View>
      </View>

      <ScrollView className="flex-1 px-margin-mobile" contentContainerStyle={{ paddingBottom: 120 }} showsVerticalScrollIndicator={false}>
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
            <Pressable onPress={handleAsk} className="w-12 h-12 bg-white rounded-xl items-center justify-center active:scale-90">
              <MaterialIcons name="send" size={20} color="#006b5a" />
            </Pressable>
          </View>
        </View>

        <View className="bg-surface-container-lowest border border-outline-variant/20 rounded-2xl p-4 mb-4 max-h-48 overflow-hidden">
          <ScrollView className="max-h-40">
            {chat.map((msg, i) => (
              <View key={i} className={`mb-2 ${msg.role === 'user' ? 'items-end' : 'items-start'}`}>
                <View className={`max-w-[80%] rounded-2xl px-4 py-2.5 ${msg.role === 'user' ? 'bg-secondary rounded-br-sm' : 'bg-surface-container-high rounded-bl-sm'}`}>
                  <Text className={msg.role === 'user' ? 'text-on-secondary' : 'text-on-surface'}>{msg.text}</Text>
                </View>
              </View>
            ))}
          </ScrollView>
        </View>

        <View className="flex-row items-center justify-between mb-3">
          <Text className="font-headline-md text-primary font-bold">AI Insights</Text>
          <Text className="text-caption text-on-surface-variant">{MOCK_INSIGHTS.length} updates</Text>
        </View>

        <View className="space-y-3 mb-4">
          {MOCK_INSIGHTS.map((insight) => {
            const style = getTypeStyle(insight.type);
            return (
              <Pressable key={insight.id} className="flex-row gap-3 p-4 bg-white border border-outline-variant/20 rounded-2xl active:scale-[0.98]">
                <View className={`w-10 h-10 rounded-full items-center justify-center ${style.bg}`}>
                  <MaterialIcons name={style.icon} size={20} color={style.color} />
                </View>
                <View className="flex-1">
                  <View className="flex-row justify-between items-start">
                    <Text className="font-label-md font-bold text-primary flex-1">{insight.title}</Text>
                    <Text className="text-caption text-on-surface-variant text-xs ml-2">{insight.time}</Text>
                  </View>
                  <Text className="text-body-md text-on-surface-variant text-sm mt-0.5">{insight.description}</Text>
                  <Pressable className="mt-2"><Text className="text-secondary font-label-md text-xs font-bold">View Details</Text></Pressable>
                </View>
              </Pressable>
            );
          })}
        </View>

        <AlertCard type="info" title="AI Accuracy" message="Insights are generated based on your financial data and market analysis. Always verify before making major decisions." />
      </ScrollView>

      <NotificationModal visible={notifVisible} onClose={() => setNotifVisible(false)} />
    </View>
  );
}
