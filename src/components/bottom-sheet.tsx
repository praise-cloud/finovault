import { View, Text, Pressable, Modal, ScrollView, useColorScheme } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';

type Props = {
  visible: boolean;
  onClose: () => void;
  title: string;
  children: React.ReactNode;
};

export function BottomSheet({ visible, onClose, title, children }: Props) {
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';

  return (
    <Modal visible={visible} transparent animationType="slide" onRequestClose={onClose}>
      <Pressable className="flex-1 bg-black/40 justify-end" onPress={onClose}>
        <Pressable
          className={`${isDark ? 'bg-[#1A1A1A]' : 'bg-white'} rounded-t-3xl max-h-[80%]`}
          onPress={() => {}}
          style={{ boxShadow: '0 -8px 24px rgba(0,0,0,0.1)', elevation: 16 }}
        >
          <View className="items-center pt-3 pb-1">
            <View className="w-10 h-1 rounded-full bg-outline/40" />
          </View>
          <View className="flex-row items-center justify-between px-6 py-4 border-b border-outline-variant/20">
            <Text className={`font-headline-md font-bold ${isDark ? 'text-white' : 'text-primary'}`}>{title}</Text>
            <Pressable onPress={onClose} className="w-8 h-8 rounded-full bg-surface-variant items-center justify-center active:scale-90">
              <MaterialIcons name="close" size={18} color={isDark ? '#FFFFFF' : '#43474d'} />
            </Pressable>
          </View>
          <ScrollView className={`px-6 py-4 ${isDark ? 'bg-[#1A1A1A]' : ''}`} contentContainerStyle={{ paddingBottom: 40 }}>
            {children}
          </ScrollView>
        </Pressable>
      </Pressable>
    </Modal>
  );
}
