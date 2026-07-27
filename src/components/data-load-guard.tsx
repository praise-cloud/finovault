import { type ReactNode } from 'react';
import { ActivityIndicator, Pressable, Text, View, type ViewStyle } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';

type Props = {
  isLoading: boolean;
  error?: string | null;
  isEmpty?: boolean;
  emptyTitle?: string;
  emptyMessage?: string;
  emptyIcon?: keyof MaterialIcons.glyphMap;
  children: ReactNode;
  onRetry?: () => void;
  className?: string;
  style?: ViewStyle;
  isDark?: boolean;
};

export default function DataLoadGuard({
  isLoading,
  error,
  isEmpty = false,
  emptyTitle = 'No data',
  emptyMessage = 'Nothing to show yet.',
  emptyIcon = 'inbox',
  children,
  onRetry,
  className = '',
  style,
  isDark = false,
}: Props) {
  const vaultContainer: ViewStyle = {
    backgroundColor: isDark ? 'rgba(255,255,255,0.08)' : '#FFFFFF',
    borderRadius: 16,
    borderWidth: 1,
    borderColor: isDark ? 'rgba(255,255,255,0.15)' : '#c4c6ce',
    padding: 32,
    alignItems: 'center',
    justifyContent: 'center',
  };

  if (isLoading) {
    return (
      <View className={className} style={[vaultContainer, style]}>
        <ActivityIndicator size="large" color={isDark ? '#D4AF37' : '#123B91'} />
      </View>
    );
  }

  if (error) {
    return (
      <View className={className} style={[vaultContainer, { gap: 16 }, style]}>
        <MaterialIcons name="error-outline" size={48} color="#8C3A3A" />
        <Text
          style={{
            fontSize: 16,
            color: isDark ? '#FFFFFF' : '#1A1A1A',
            textAlign: 'center',
            fontFamily: 'Montserrat',
          }}
        >
          {error}
        </Text>
        {onRetry ? (
          <Pressable
            onPress={onRetry}
            style={{
              borderWidth: 1,
              borderColor: '#D4AF37',
              borderRadius: 12,
              paddingVertical: 10,
              paddingHorizontal: 24,
            }}
          >
            <Text
              style={{
                color: '#D4AF37',
                fontSize: 16,
                fontWeight: '600',
                fontFamily: 'Montserrat',
              }}
            >
              Retry
            </Text>
          </Pressable>
        ) : null}
      </View>
    );
  }

  if (isEmpty) {
    return (
      <View className={className} style={[vaultContainer, { gap: 16 }, style]}>
        <MaterialIcons name={emptyIcon} size={48} color="#D4AF37" />
        <Text
          style={{
            fontSize: 18,
            fontWeight: '600',
            color: isDark ? '#FFFFFF' : '#1A1A1A',
            textAlign: 'center',
            fontFamily: 'Montserrat',
          }}
        >
          {emptyTitle}
        </Text>
        <Text
          style={{
            fontSize: 14,
            color: isDark ? '#B0B4BA' : '#43474D',
            textAlign: 'center',
            fontFamily: 'Montserrat',
          }}
        >
          {emptyMessage}
        </Text>
        {onRetry ? (
          <Pressable
            onPress={onRetry}
            style={{
              borderWidth: 1,
              borderColor: '#D4AF37',
              borderRadius: 12,
              paddingVertical: 10,
              paddingHorizontal: 24,
            }}
          >
            <Text
              style={{
                color: '#D4AF37',
                fontSize: 16,
                fontWeight: '600',
                fontFamily: 'Montserrat',
              }}
            >
              Add
            </Text>
          </Pressable>
        ) : null}
      </View>
    );
  }

  return <>{children}</>;
}
