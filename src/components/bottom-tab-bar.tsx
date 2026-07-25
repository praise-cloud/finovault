import { MaterialIcons } from '@expo/vector-icons';
import { View, Pressable, Text, useColorScheme } from 'react-native';
import { VaultMonogram } from '@/src/components/vault-monogram';

type Tab = {
  key: string;
  label: string;
  icon: keyof typeof MaterialIcons.glyphMap;
  route: string;
};

type Role = 'individual' | 'sme' | 'entrepreneur' | 'freelancer';

const CORE_TABS: Tab[] = [
  { key: 'vault', label: 'Vault', icon: 'lock', route: '/(tabs)/vault' },
  { key: 'pay', label: 'Pay', icon: 'swap-horiz', route: '/(tabs)/pay' },
  { key: 'profile', label: 'Profile', icon: 'person', route: '/(tabs)/profile' },
];

const ROLE_TABS: Record<Role, Tab[]> = {
  individual: [
    { key: 'home', label: 'Home', icon: 'home', route: '/(tabs)' },
    { key: 'insights', label: 'Insights', icon: 'auto-awesome', route: '/(tabs)/insight' },
  ],
  sme: [
    { key: 'sme-dashboard', label: 'Dashboard', icon: 'business', route: '/(tabs)/sme-dashboard' },
    { key: 'sme-analytics', label: 'Analytics', icon: 'analytics', route: '/(tabs)/sme-analytics' },
  ],
  entrepreneur: [
    { key: 'entrepreneur', label: 'Growth', icon: 'trending-up', route: '/(tabs)/entrepreneur' },
    { key: 'insights', label: 'Insights', icon: 'auto-awesome', route: '/(tabs)/insight' },
  ],
  freelancer: [
    { key: 'freelancer', label: 'Work', icon: 'computer', route: '/(tabs)/freelancer' },
    { key: 'insights', label: 'Insights', icon: 'auto-awesome', route: '/(tabs)/insight' },
  ],
};

function getTabs(role: Role): Tab[] {
  const roleTabs = ROLE_TABS[role] || ROLE_TABS.individual;
  return [...roleTabs, ...CORE_TABS];
}

type Props = {
  activeTab: string;
  onTabPress: (key: string) => void;
  role?: string;
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
            color={isActive ? '#60A5FA' : isDark ? '#FFFFFF80' : '#43474d'}
            bgColor="transparent"
            flat
          />
        ) : (
          <MaterialIcons
            name={tab.icon}
            size={22}
            color={isActive ? '#60A5FA' : isDark ? '#FFFFFF80' : '#43474d'}
          />
        )}
        <Text
          className={isActive ? 'font-body-semibold' : 'font-body'}
          style={{
            fontSize: 11,
            color: isActive ? '#60A5FA' : isDark ? 'rgba(255,255,255,0.5)' : '#43474d',
            marginTop: 3,
          }}
        >
          {tab.label}
        </Text>
      </View>
    </Pressable>
  );
}

export function BottomTabBar({ activeTab, onTabPress, role = 'individual' }: Props) {
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';
  const tabs = getTabs(role as Role);

  return (
    <View
      className="md:hidden absolute bottom-0 left-0 right-0 z-50 flex-row items-center"
      style={{
        height: 60,
        paddingBottom: 4,
        backgroundColor: isDark ? '#0D1117' : '#FFFFFF',
        borderTopWidth: 1,
        borderTopColor: isDark ? 'rgba(255,255,255,0.08)' : 'rgba(0,0,0,0.06)',
      }}
    >
      {tabs.map((tab) => (
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
