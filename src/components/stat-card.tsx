import { MaterialIcons } from '@expo/vector-icons';
import { View, Text } from 'react-native';
import { View } from 'react-native';

type Props = {
  label: string;
  value: string;
  trend?: { direction: 'up' | 'down'; text: string; positive?: boolean };
  className?: string;
  index?: number;
};

export function StatCard({ label, value, trend, className = '', index = 0 }: Props) {
  return (
    <View
      className={`p-4 rounded-xl bg-surface-bright border border-outline-variant ${className}`}
    >
      <Text className="text-caption text-on-surface-variant uppercase tracking-wider mb-1">{label}</Text>
      <Text className="font-headline-md text-headline-md text-primary">{value}</Text>
      {trend && (
        <View className="flex-row items-center gap-1 mt-1">
          <MaterialIcons
            name={trend.direction === 'up' ? 'trending-up' : 'trending-down'}
            size={14}
            color={trend.positive !== false ? '#006b5a' : '#ba1a1a'}
          />
          <Text className={`text-caption ${trend.positive !== false ? 'text-secondary' : 'text-error'}`}>
            {trend.text}
          </Text>
        </View>
      )}
    </View>
  );
}
