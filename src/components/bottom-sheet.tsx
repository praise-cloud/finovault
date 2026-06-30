import { View, Text, Pressable, Modal, ScrollView } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';

type Props = {
  visible: boolean;
  onClose: () => void;
  title: string;
  children: React.ReactNode;
};

export function BottomSheet({ visible, onClose, title, children }: Props) {
  return (
    <Modal visible={visible} transparent animationType="slide" onRequestClose={onClose}>
      <Pressable className="flex-1 bg-black/40 justify-end" onPress={onClose}>
        <Pressable
          className="bg-white rounded-t-3xl max-h-[80%]"
          onPress={() => {}}
          style={{ shadowColor: '#000', shadowOffset: { width: 0, height: -8 }, shadowOpacity: 0.1, shadowRadius: 24, elevation: 16 }}
        >
          <View className="items-center pt-3 pb-1">
            <View className="w-10 h-1 rounded-full bg-outline/40" />
          </View>
          <View className="flex-row items-center justify-between px-6 py-4 border-b border-outline-variant/20">
            <Text className="font-headline-md text-primary font-bold">{title}</Text>
            <Pressable onPress={onClose} className="w-8 h-8 rounded-full bg-surface-variant items-center justify-center active:scale-90">
              <MaterialIcons name="close" size={18} color="#43474d" />
            </Pressable>
          </View>
          <ScrollView className="px-6 py-4" contentContainerStyle={{ paddingBottom: 40 }}>
            {children}
          </ScrollView>
        </Pressable>
      </Pressable>
    </Modal>
  );
}
