import { useState } from 'react';
import { ScrollView, View, Text, Pressable, TextInput as RNTextInput, useColorScheme } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';
import { VaultMonogram } from '@/components/vault-monogram';
import { FlatCard } from '@/components/flat-card';

export default function PayScreen() {
  const [activeTab, setActiveTab] = useState<'send' | 'request'>('send');
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';

  return (
    <View className="flex-1" style={{ backgroundColor: isDark ? '#08142E' : '#F7F9FC' }}>
      <View className="px-margin-mobile pt-14 pb-3" style={{ backgroundColor: isDark ? '#08142E' : '#F7F9FC' }}>
        <View className="flex-row items-center gap-3">
          <VaultMonogram size={34} flat />
          <Text className="font-body-semibold" style={{ fontSize: 22, color: isDark ? '#FFFFFF' : '#1A1A1A' }}>Pay</Text>
        </View>
      </View>

      <ScrollView className="flex-1 px-margin-mobile" contentContainerStyle={{ paddingBottom: 120 }} showsVerticalScrollIndicator={false}>
        {/* Pill segmented control */}
        <View className="flex-row mt-4" style={{ backgroundColor: isDark ? 'rgba(255,255,255,0.08)' : '#EEF0F5', borderRadius: 9999, padding: 3 }}>
          {(['send', 'request'] as const).map((tab) => (
            <Pressable
              key={tab}
              onPress={() => setActiveTab(tab)}
              className="flex-1 py-2.5 items-center active:scale-[0.98]"
              style={{ backgroundColor: activeTab === tab ? 'rgba(8,20,46,0.08)' : 'transparent', borderRadius: 9999 }}
            >
              <Text
                className="font-body-semibold"
                style={{ fontSize: 15, color: activeTab === tab ? '#08142E' : isDark ? 'rgba(255,255,255,0.5)' : '#74777e' }}
              >
                {tab === 'send' ? 'Send Money' : 'Request Money'}
              </Text>
            </Pressable>
          ))}
        </View>

        {/* Recipient / From card */}
        <FlatCard className="p-5 mt-5">
          <Text className="font-body-medium" style={{ fontSize: 13, color: isDark ? 'rgba(255,255,255,0.6)' : '#6B6F76', marginBottom: 8 }}>
            {activeTab === 'send' ? 'Recipient' : 'From'}
          </Text>
          <View
            className="flex-row items-center px-4 py-3"
            style={{
              backgroundColor: isDark ? '#1A1A1A' : '#F7F9FC',
              borderWidth: 1,
              borderColor: isDark ? 'rgba(255,255,255,0.12)' : '#E4E7EE',
              borderRadius: 14,
            }}
          >
            <MaterialIcons name="person" size={20} color={isDark ? 'rgba(255,255,255,0.4)' : '#6B6F76'} />
            <RNTextInput
              placeholder="Name, email, or phone"
              placeholderTextColor={isDark ? 'rgba(255,255,255,0.3)' : '#9ea0a5'}
              className="flex-1 ml-2"
              style={{ fontSize: 16, fontFamily: 'Montserrat_400Regular', color: isDark ? '#FFFFFF' : '#1A1A1A' }}
            />
          </View>
        </FlatCard>

        {/* Amount card */}
        <FlatCard className="p-5 mt-3">
          <Text className="font-body-medium" style={{ fontSize: 13, color: isDark ? 'rgba(255,255,255,0.6)' : '#6B6F76', marginBottom: 8 }}>
            Amount
          </Text>
          <View
            className="flex-row items-center px-4 py-3"
            style={{
              backgroundColor: isDark ? '#1A1A1A' : '#F7F9FC',
              borderWidth: 1,
              borderColor: isDark ? 'rgba(255,255,255,0.12)' : '#E4E7EE',
              borderRadius: 14,
            }}
          >
            <Text className="font-display-bold" style={{ fontSize: 22, color: '#08142E' }}>$</Text>
            <RNTextInput
              placeholder="0.00"
              placeholderTextColor={isDark ? 'rgba(255,255,255,0.3)' : '#9ea0a5'}
              keyboardType="decimal-pad"
              className="flex-1 ml-2"
              style={{ fontSize: 22, fontFamily: 'Montserrat_700Bold', color: isDark ? '#FFFFFF' : '#1A1A1A' }}
            />
          </View>
        </FlatCard>

        {/* CTA button */}
        <Pressable
          className="w-full py-3.5 items-center justify-center flex-row active:scale-[0.98] mt-5"
          style={{
            backgroundColor: 'rgba(8,20,46,0.08)',
            borderWidth: 1.5,
            borderColor: '#08142E',
            borderRadius: 9999,
          }}
        >
          <MaterialIcons name={activeTab === 'send' ? 'arrow-upward' : 'arrow-downward'} size={20} color="#08142E" />
          <Text className="font-body-semibold ml-2" style={{ fontSize: 16, color: '#08142E' }}>
            {activeTab === 'send' ? 'Send' : 'Request'}
          </Text>
        </Pressable>

        {/* Trust footer */}
        <View className="flex-row items-center justify-center mt-6 gap-2">
          <MaterialIcons name="lock" size={14} color="#08142E" />
          <Text className="font-body" style={{ fontSize: 13, color: isDark ? 'rgba(255,255,255,0.4)' : '#6B6F76' }}>
            Encrypted transfer
          </Text>
          <View className="w-1 h-1 rounded-full" style={{ backgroundColor: isDark ? 'rgba(255,255,255,0.2)' : '#c4c6ce' }} />
          <MaterialIcons name="verified" size={14} color="#08142E" />
          <Text className="font-body" style={{ fontSize: 13, color: isDark ? 'rgba(255,255,255,0.4)' : '#6B6F76' }}>
            Verified recipient
          </Text>
        </View>
      </ScrollView>
    </View>
  );
}
