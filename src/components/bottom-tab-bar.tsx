import { MaterialIcons } from '@expo/vector-icons';
import { View, Pressable, Text, useColorScheme } from 'react-native';
import { VaultMonogram } from '@/components/vault-monogram';

type Tab = {
  key: string;
  label: string;
  icon: keyof typeof MaterialIcons.glyphMap;
};

const TABS: Tab[] = [
  { key: 'home', label: 'Home', icon: 'home' },
  { key: 'insights', label: 'Insights', icon: 'auto-awesome' },
  { key: 'vault', label: 'Vault', icon: 'lock' },
  { key: 'pay', label: 'Pay', icon: 'swap-horiz' },
  { key: 'profile', label: 'Profile', icon: 'person' },
];

type Props = {
  activeTab: string;
  onTabPress: (key: string) => void;
};

function TabItem({ tab, isActive, onPress, isDark }: { tab: Tab; isActive: boolean; onPress: () => void; isDark: boolean }) {
  return (
    <Pressable
      onPress={onPress}
      className="flex-1 items-center justify-center active:opacity-70"
      style={{ height: 50 }}
    >
      <View className="items-center justify-center">
        {tab.key === 'vault' ? (
          <VaultMonogram
            size={22}
            color={isActive ? '#08142E' : isDark ? '#FFFFFF80' : '#43474d'}
            bgColor="transparent"
            flat
          />
        ) : (
          <MaterialIcons
            name={tab.icon}
            size={22}
            color={isActive ? '#08142E' : isDark ? '#FFFFFF80' : '#43474d'}
          />
        )}
        <Text
          className={isActive ? 'font-body-semibold' : 'font-body'}
          style={{
            fontSize: 11,
            color: isActive ? '#08142E' : isDark ? 'rgba(255,255,255,0.5)' : '#43474d',
            marginTop: 3,
          }}
        >
          {tab.label}
        </Text>
      </View>
    </Pressable>
  );
}

export function BottomTabBar({ activeTab, onTabPress }: Props) {
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';

  return (
    <View
      className="md:hidden absolute bottom-0 left-0 right-0 z-50 flex-row items-center"
      style={{
        height: 60,
        paddingBottom: 4,
        backgroundColor: isDark ? '#0A1F5C' : '#FFFFFF',
        borderTopWidth: 1,
        borderTopColor: isDark ? 'rgba(255,255,255,0.08)' : 'rgba(0,0,0,0.06)',
      }}
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
