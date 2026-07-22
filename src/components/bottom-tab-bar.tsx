import { MaterialIcons } from '@expo/vector-icons';
import { View, Pressable, Text, useColorScheme } from 'react-native';
import Animated, { useAnimatedStyle, useSharedValue, withSpring } from 'react-native-reanimated';
import { useEffect } from 'react';
import { selection } from '@/hooks/use-haptics';

type Tab = {
  key: string;
  label: string;
  icon: keyof typeof MaterialIcons.glyphMap;
  activeIcon?: keyof typeof MaterialIcons.glyphMap;
};

const TABS: Tab[] = [
  { key: 'dashboard', label: 'Dashboard', icon: 'dashboard', activeIcon: 'dashboard' },
  { key: 'protection', label: 'Protection', icon: 'gpp-good', activeIcon: 'gpp-good' },
  { key: 'ai-analysis', label: 'AI Analysis', icon: 'auto-awesome', activeIcon: 'auto-awesome' },
  { key: 'profile', label: 'Profile', icon: 'account-circle', activeIcon: 'account-circle' },
];

type Props = {
  activeTab: string;
  onTabPress: (key: string) => void;
};

function TabItem({ tab, isActive, onPress, isDark }: { tab: Tab; isActive: boolean; onPress: () => void; isDark: boolean }) {
  const scale = useSharedValue(isActive ? 1 : 0.85);
  const opacity = useSharedValue(isActive ? 1 : 0.6);

  useEffect(() => {
    scale.value = withSpring(isActive ? 1 : 0.85, { damping: 12 });
    opacity.value = withSpring(isActive ? 1 : 0.6, { damping: 12 });
  }, [isActive]);

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
    opacity: opacity.value,
  }));

  const handlePress = () => {
    selection();
    onPress();
  };

  return (
    <Pressable key={tab.key} onPress={handlePress}>
      <Animated.View
        style={animatedStyle}
        className={`flex-col items-center justify-center px-5 py-1.5 rounded-2xl ${
          isActive ? 'bg-secondary-container' : ''
        }`}
      >
        <MaterialIcons
          name={(isActive && tab.activeIcon ? tab.activeIcon : tab.icon) as any}
          size={24}
          color={isActive ? '#1A1A1A' : isDark ? '#FFFFFF80' : '#43474d'}
        />
        <Text className={`font-label-md text-xs ${isActive ? 'text-on-secondary-container font-bold' : 'text-on-surface-variant'}`}>
          {tab.label}
        </Text>
      </Animated.View>
    </Pressable>
  );
}

export function BottomTabBar({ activeTab, onTabPress }: Props) {
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';

  return (
    <View
      className={`md:hidden absolute bottom-0 left-0 right-0 z-50 flex-row justify-around items-center h-20 px-margin-mobile ${isDark ? 'bg-[#0A1F5C]' : 'bg-surface-container-lowest'}`}
      style={{ shadowColor: '#000', shadowOffset: { width: 0, height: -4 }, shadowOpacity: 0.04, shadowRadius: 20, elevation: 8 }}
    >
      {TABS.map((tab) => (
        <TabItem
          key={tab.key}
          tab={tab}
          isActive={activeTab === tab.key}
          onPress={() => onTabPress(tab.key)}
          isDark={isDark}
        />
      ))}
    </View>
  );
}
