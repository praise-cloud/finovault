import { useState, useRef, useEffect } from 'react';
import { View, Text, Pressable, TextInput as RNTextInput, useColorScheme, Animated } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';

type Props = {
  label: string;
  value: string;
  onChangeText: (text: string) => void;
  placeholder?: string;
  error?: string;
  keyboardType?: 'default' | 'email-address' | 'phone-pad' | 'numeric';
  secureTextEntry?: boolean;
  autoCapitalize?: 'none' | 'sentences' | 'words' | 'characters';
  rightLabel?: string;
};

export function TextInput({
  label,
  value,
  onChangeText,
  placeholder,
  error,
  keyboardType = 'default',
  secureTextEntry,
  autoCapitalize,
  rightLabel,
}: Props) {
  const [focused, setFocused] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';
  const inputRef = useRef<RNTextInput>(null);
  const labelAnim = useRef(new Animated.Value(value ? 1 : 0)).current;

  const isPassword = secureTextEntry !== undefined;
  const effectiveSecure = isPassword && !showPassword;
  const hasValue = value.length > 0;

  useEffect(() => {
    Animated.timing(labelAnim, {
      toValue: focused || hasValue ? 1 : 0,
      duration: 200,
      useNativeDriver: false,
    }).start();
  }, [focused, hasValue, labelAnim]);

  const labelTop = labelAnim.interpolate({
    inputRange: [0, 1],
    outputRange: [16, 0],
  });

  const labelSize = labelAnim.interpolate({
    inputRange: [0, 1],
    outputRange: [16, 12],
  });

  const underlineColor = error
    ? '#8C3A3A'
    : focused
    ? '#08142E'
    : isDark
    ? 'rgba(255,255,255,0.15)'
    : '#c4c6ce';

  const bgColor = isDark ? '#1A1A1A' : '#FFFFFF';

  return (
    <View className="mb-gutter">
      <View className="flex-row justify-between items-center mb-1">
        {rightLabel && (
          <Text className="font-caption text-caption" style={{ color: isDark ? 'rgba(255,255,255,0.4)' : '#74777e', marginLeft: 'auto' }}>
            {rightLabel}
          </Text>
        )}
      </View>
      <Pressable
        onPress={() => inputRef.current?.focus()}
        style={{ backgroundColor: bgColor, borderRadius: 14 }}
      >
        <View style={{ paddingHorizontal: 16, paddingTop: 20, paddingBottom: 8 }}>
          <Animated.Text
            style={{
              position: 'absolute',
              left: 16,
              top: labelTop,
              fontSize: labelSize,
              fontFamily: 'Montserrat_500Medium',
              color: error ? '#8C3A3A' : focused ? '#08142E' : isDark ? 'rgba(255,255,255,0.4)' : '#74777e',
            }}
          >
            {label}
          </Animated.Text>
          <View className="flex-row items-center">
            <RNTextInput
              ref={inputRef}
              value={value}
              onChangeText={onChangeText}
              placeholder={focused ? placeholder : ''}
              placeholderTextColor={isDark ? 'rgba(255,255,255,0.3)' : '#9ea0a5'}
              keyboardType={keyboardType}
              secureTextEntry={effectiveSecure}
              autoCapitalize={autoCapitalize}
              onFocus={() => setFocused(true)}
              onBlur={() => setFocused(false)}
              style={{
                flex: 1,
                fontSize: 16,
                fontFamily: 'Montserrat_400Regular',
                color: isDark ? '#FFFFFF' : '#1A1A1A',
                paddingVertical: 0,
              }}
            />
            {isPassword && (
              <Pressable
                onPress={() => setShowPassword(!showPassword)}
                className="active:scale-95"
                style={{ marginLeft: 8 }}
              >
                <MaterialIcons
                  name={showPassword ? 'visibility-off' : 'visibility'}
                  size={20}
                  color={isDark ? 'rgba(255,255,255,0.4)' : '#74777e'}
                />
              </Pressable>
            )}
          </View>
        </View>
        <View
          style={{
            height: 2,
            backgroundColor: underlineColor,
            borderBottomLeftRadius: 14,
            borderBottomRightRadius: 14,
          }}
        />
      </Pressable>
      {error && (
        <Text className="text-caption mt-1" style={{ color: '#8C3A3A' }}>{error}</Text>
      )}
    </View>
  );
}
