import { Image } from '@gluestack-ui/themed';
import { Platform, View, Text, Pressable, useColorScheme } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';

type Props = {
  title?: string;
  showBack?: boolean;
  onBackPress?: () => void;
  rightElement?: React.ReactNode;
};

export function TopAppBar({ title = 'Finovault AI', showBack, onBackPress, rightElement }: Props) {
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';
  return (
    <View className="w-full pt-12 pb-3 px-margin-mobile flex-row items-center justify-between" style={[{ backgroundColor: isDark ? '#08142E' : undefined }, Platform.select({ web: { paddingTop: 16 } })]}>
      <View className="flex-row items-center gap-3">
        {showBack && (
          <Pressable onPress={onBackPress} className="active:scale-95">
            <MaterialIcons name="arrow-back" size={24} color={isDark ? '#D4AF37' : '#0A1F5C'} />
          </Pressable>
        )}
        <Text className={`font-headline-md font-bold ${isDark ? 'text-[#FFFFFF]' : 'text-primary'}`}>{title}</Text>
      </View>
      {rightElement || (
        <Pressable className="active:scale-95">
          <View className="w-10 h-10 rounded-full items-center justify-center overflow-hidden border" style={{ backgroundColor: isDark ? '#1A1A1A' : undefined, borderColor: isDark ? '#2A2A2A' : undefined }}>
            <MaterialIcons name="person" size={20} color={isDark ? '#FFFFFF' : '#43474d'} />
          </View>
        </Pressable>
      )}
    </View>
  );
}
