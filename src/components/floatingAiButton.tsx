import { Pressable } from 'react-native';
import { router } from 'expo-router';
import { Logo } from '@/src/components/logo';

const BLUE = '#123B91';

type FloatingAIButtonProps = {
  bottom?: number;
};

/**
 * Floating circular button (Finovault mark on a navy disc) that opens the
 * Vault AI assistant chat. Drop this into any screen that should offer quick
 * access to the assistant — it's absolutely positioned, so the parent screen
 * just needs `position: 'relative'` (or nothing, since RN views default to
 * relative) and enough bottom padding in its scroll content so this doesn't
 * cover the last item.
 */
export function FloatingAIButton({ bottom = 90 }: FloatingAIButtonProps) {
  return (
    <Pressable
      onPress={() => router.push('/(tabs)/vault')}
      hitSlop={8}
      style={({ pressed }) => ({
        position: 'absolute',
        right: 20,
        bottom,
        width: 52,
        height: 52,
        borderRadius: 26,
        backgroundColor: BLUE,
        alignItems: 'center',
        justifyContent: 'center',
        opacity: pressed ? 0.85 : 1,
        transform: [{ scale: pressed ? 0.96 : 1 }],
        shadowColor: '#000000',
        shadowOpacity: 0.2,
        shadowRadius: 8,
        shadowOffset: { width: 0, height: 4 },
        elevation: 6,
      })}
    >
      <Logo width={20} height={18} color="#FFFFFF" />
    </Pressable>
  );
}