import { MaterialIcons } from '@expo/vector-icons';
import { View, Pressable, Text } from 'react-native';

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

export function BottomTabBar({ activeTab, onTabPress }: Props) {
  return (
    <View
      className="md:hidden absolute bottom-0 left-0 right-0 z-50 flex-row justify-around items-center h-20 px-margin-mobile bg-surface-container-lowest"
      style={{ shadowColor: '#000', shadowOffset: { width: 0, height: -4 }, shadowOpacity: 0.04, shadowRadius: 20, elevation: 8 }}
    >
      {TABS.map((tab) => {
        const isActive = activeTab === tab.key;
        return (
          <Pressable
            key={tab.key}
            onPress={() => onTabPress(tab.key)}
            className={`flex-col items-center justify-center active:scale-90 transition-all duration-200 ${
              isActive ? 'bg-secondary-container text-on-secondary-container rounded-2xl px-6 py-1' : 'opacity-70'
            }`}
          >
            <MaterialIcons
              name={(isActive && tab.activeIcon ? tab.activeIcon : tab.icon) as any}
              size={24}
              color={isActive ? '#00705e' : '#43474d'}
            />
            <Text className={`font-label-md text-xs ${isActive ? 'text-on-secondary-container font-bold' : 'text-on-surface-variant'}`}>
              {tab.label}
            </Text>
          </Pressable>
        );
      })}
    </View>
  );
}
