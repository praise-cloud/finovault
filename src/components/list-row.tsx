import { View, Text, useColorScheme } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';

type Props = {
  icon: keyof typeof MaterialIcons.glyphMap;
  iconColor?: string;
  label: string;
  secondary?: string;
  amount?: string;
  amountColor?: string;
  showPlus?: boolean;
};

export function ListRow({ icon, iconColor, label, secondary, amount, amountColor, showPlus }: Props) {
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';

  const resolvedIconColor = iconColor || (isDark ? '#60A5FA' : '#123B91');
  const resolvedAmountColor = amountColor || (isDark ? '#F0F0F0' : '#1A1A1A');

  return (
    <View
      className="flex-row items-center py-3.5"
      style={{
        borderBottomWidth: 1,
        borderBottomColor: isDark ? 'rgba(255,255,255,0.06)' : 'rgba(0,0,0,0.04)',
      }}
    >
      <View
        className="w-8 h-8 rounded-full items-center justify-center mr-3"
        style={{ backgroundColor: isDark ? '#2A2A2A' : '#EEF0F5' }}
      >
        <MaterialIcons name={icon} size={16} color={resolvedIconColor} />
      </View>
      <View className="flex-1">
        <Text
          className="font-body-medium"
          style={{ fontSize: 15, color: isDark ? '#F0F0F0' : '#1A1A1A' }}
        >
          {label}
        </Text>
        {secondary && (
          <Text
            className="font-body"
            style={{ fontSize: 13, color: isDark ? '#9CA3B0' : '#6B6F76', marginTop: 1 }}
          >
            {secondary}
          </Text>
        )}
      </View>
      {amount && (
        <Text
          className="font-body-bold"
          style={{ fontSize: 15, color: resolvedAmountColor }}
        >
          {showPlus ? `+${amount}` : amount}
        </Text>
      )}
    </View>
  );
}
