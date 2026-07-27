import { MaterialIcons } from '@expo/vector-icons';
import { View, Text, useColorScheme } from 'react-native';

type Props = {
  label: string;
  value: string;
  trend?: { direction: 'up' | 'down'; text: string; positive?: boolean };
  className?: string;
  index?: number;
};

export function StatCard({ label, value, trend, className = '', index = 0 }: Props) {
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';
  return (
    <View
      className={`p-4 rounded-xl border ${className}`}
      style={{ backgroundColor: isDark ? '#1A1A1A' : '#FFFFFF', borderColor: isDark ? '#2A2A2A' : '#c4c6ce' }}
    >
      <Text className={`text-caption uppercase tracking-wider mb-1 ${isDark ? 'text-[#9CA3B0]' : 'text-on-surface-variant'}`}>{label}</Text>
      <Text className={`font-headline-md text-headline-md ${isDark ? 'text-[#D4AF37]' : 'text-primary'}`}>{value}</Text>
      {trend && (
        <View className="flex-row items-center gap-1 mt-1">
          <MaterialIcons
            name={trend.direction === 'up' ? 'trending-up' : 'trending-down'}
            size={14}
            color={trend.positive !== false ? (isDark ? '#D4AF37' : '#08142E') : '#ba1a1a'}
          />
          <Text className={`text-caption ${isDark ? 'text-[#9CA3B0]' : (trend.positive !== false ? 'text-secondary' : 'text-error')}`}>
            {trend.text}
          </Text>
        </View>
      )}
    </View>
  );
}
