import { useState, useRef } from 'react';
import { View, Text, Pressable, TextInput as RNTextInput, StyleProp, ViewStyle, useColorScheme } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';

type Props = {
  label?: string;
  value: string;
  onChangeText: (text: string) => void;
  placeholder?: string;
  error?: string;
  keyboardType?: 'default' | 'email-address' | 'phone-pad' | 'numeric';
  secureTextEntry?: boolean;
  autoCapitalize?: 'none' | 'sentences' | 'words' | 'characters';
  rightLabel?: string;
  style?: StyleProp<ViewStyle>;
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
  style,
}: Props) {
  const [focused, setFocused] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const colorScheme = useColorScheme();
  const isDark = colorScheme === 'dark';
  const inputRef = useRef<RNTextInput>(null);

  const isPassword = secureTextEntry !== undefined;
  const effectiveSecure = isPassword && !showPassword;

  // Border no longer changes on focus — stays constant unless there's an error.
  const borderColor = error ? '#8C3A3A' : isDark ? 'rgba(255,255,255,0.15)' : '#D8DBE3';

  const bgColor = isDark ? '#1A1A1A' : '#FFFFFF';

  return (
    <View className="mb-gutter">
      {(label || rightLabel) && (
        <View className="flex-row justify-between items-center mb-2">
          {label && (
            <Text
              style={{
                fontSize: 14,
                fontFamily: 'Montserrat_500Medium',
                color: error ? '#8C3A3A' : isDark ? 'rgba(255,255,255,0.7)' : '#111111',
              }}
            >
              {label}
            </Text>
          )}
          {rightLabel && (
            <Text
              className="font-caption text-caption"
              style={{ color: isDark ? 'rgba(255,255,255,0.4)' : '#74777e', marginLeft: 'auto' }}
            >
              {rightLabel}
            </Text>
          )}
        </View>
      )}

      <Pressable
        onPress={() => inputRef.current?.focus()}
        style={[
          {
            backgroundColor: bgColor,
            borderRadius: 10,
            borderWidth: 1,
            borderColor,
            paddingHorizontal: 16,
            height: 52,
            justifyContent: 'center',
          },
          style,
        ]}
      >
        <View className="flex-row items-center">
          <RNTextInput
            ref={inputRef}
            value={value}
            onChangeText={onChangeText}
            placeholder={placeholder}
            placeholderTextColor={isDark ? 'rgba(255,255,255,0.3)' : '#9ea0a5'}
            keyboardType={keyboardType}
            secureTextEntry={effectiveSecure}
            autoCapitalize={autoCapitalize}
            onFocus={() => setFocused(true)}
            onBlur={() => setFocused(false)}
            underlineColorAndroid="transparent"
            style={[
              {
                flex: 1,
                fontSize: 16,
                fontFamily: 'Montserrat_400Regular',
                color: isDark ? '#FFFFFF' : '#1A1A1A',
                paddingVertical: 0,
              },
              // Strips the browser's native focus ring on web only.
              { outlineStyle: 'none' } as any,
            ]}
          />
          {isPassword && (
            <Pressable onPress={() => setShowPassword(!showPassword)} className="active:scale-95" style={{ marginLeft: 8 }}>
              <MaterialIcons
                name={showPassword ? 'visibility-off' : 'visibility'}
                size={20}
                color={isDark ? 'rgba(255,255,255,0.4)' : '#74777e'}
              />
            </Pressable>
          )}
        </View>
      </Pressable>

      {error && <Text className="text-caption mt-1" style={{ color: '#8C3A3A' }}>{error}</Text>}
    </View>
  );
}