import { Pressable, Text, ActivityIndicator, View, useColorScheme } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';

type Variant = 'primary' | 'secondary' | 'destructive' | 'tertiary';

type Props = {
  title: string;
  onPress: () => void;
  variant?: Variant;
  loading?: boolean;
  disabled?: boolean;
  icon?: keyof typeof MaterialIcons.glyphMap;
  showArrow?: boolean;
};

export function Button({
  title,
  onPress,
  variant = 'primary',
  loading = false,
  disabled = false,
  icon,
  showArrow = false,
}: Props) {
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';

  const isDisabled = disabled || loading;

  const borderColor = variant === 'primary' && !isDisabled ? '#08142E' : 'transparent';

  const bgColor = isDisabled
    ? '#1A1A1A'
    : variant === 'primary'
    ? 'rgba(8,20,46,0.08)'
    : variant === 'secondary'
    ? '#F0F2F5'
    : variant === 'destructive'
    ? '#F6E7E7'
    : 'transparent';

  const textColor = isDisabled
    ? '#74777e'
    : variant === 'primary'
    ? '#08142E'
    : variant === 'destructive'
    ? '#8C3A3A'
    : variant === 'tertiary'
    ? '#08142E'
    : '#1A1A1A';

  return (
    <Pressable
      onPress={onPress}
      disabled={isDisabled}
      className="w-full py-4 items-center justify-center flex-row active:scale-[0.98]"
      style={{ backgroundColor: bgColor, borderRadius: 9999, borderWidth: variant === 'primary' && !isDisabled ? 1.5 : 0, borderColor }}
    >
      {loading ? (
        <ActivityIndicator size="small" color={textColor} />
      ) : (
        <>
          {icon && <MaterialIcons name={icon} size={20} color={textColor} style={{ marginRight: 8 }} />}
          <Text
            className="font-body-semibold"
            style={{ fontSize: 16, color: textColor }}
          >
            {title}
          </Text>
          {showArrow && (
            <View className="ml-auto">
              <MaterialIcons name="arrow-forward" size={20} color={textColor} />
            </View>
          )}
        </>
      )}
    </Pressable>
  );
}
