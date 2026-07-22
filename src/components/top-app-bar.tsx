import { Image } from '@gluestack-ui/themed';
import { Platform, View, Text, Pressable } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';

type Props = {
  title?: string;
  showBack?: boolean;
  onBackPress?: () => void;
  rightElement?: React.ReactNode;
};

export function TopAppBar({ title = 'Finovault AI', showBack, onBackPress, rightElement }: Props) {
  return (
    <View className="bg-surface-bright w-full pt-12 pb-3 px-margin-mobile flex-row items-center justify-between" style={Platform.select({ web: { paddingTop: 16 } })}>
      <View className="flex-row items-center gap-3">
        {showBack && (
          <Pressable onPress={onBackPress} className="active:scale-95">
            <MaterialIcons name="arrow-back" size={24} color="#0A1F5C" />
          </Pressable>
        )}
        <Text className="font-headline-md text-primary font-bold">{title}</Text>
      </View>
      {rightElement || (
        <Pressable className="active:scale-95">
          <View className="w-10 h-10 rounded-full bg-surface-container-high items-center justify-center overflow-hidden border border-outline-variant">
            <MaterialIcons name="person" size={20} color="#43474d" />
          </View>
        </Pressable>
      )}
    </View>
  );
}
