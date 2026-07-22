import { ButtonText } from '@gluestack-ui/themed';
import { Pressable } from 'react-native';
import { useSharedValue, useAnimatedStyle, withSpring } from 'react-native-reanimated';
import Animated from 'react-native-reanimated';
import { mediumImpact } from '@/hooks/use-haptics';

type Props = {
  title: string;
  onPress?: () => void;
  className?: string;
  disabled?: boolean;
};

export function PrimaryButton({ title, onPress, className = '', disabled }: Props) {
  const scale = useSharedValue(1);

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
  }));

  const handlePressIn = () => {
    scale.value = withSpring(0.96, { damping: 15 });
    mediumImpact();
  };

  const handlePressOut = () => {
    scale.value = withSpring(1, { damping: 15 });
  };

  const handlePress = () => {
    onPress?.();
  };

  return (
    <Pressable
      onPress={handlePress}
      onPressIn={handlePressIn}
      onPressOut={handlePressOut}
      disabled={disabled}
    >
      <Animated.View
        style={[animatedStyle, { shadowColor: 'rgba(212,175,55,0.25)', shadowOffset: { width: 0, height: 4 }, shadowRadius: 14, elevation: 4 }]}
        className={`bg-[#D4AF37] rounded-xl py-4 shadow-lg ${className}`}
      >
        <ButtonText className="text-[#1A1A1A] font-label-md font-bold text-center">{title}</ButtonText>
      </Animated.View>
    </Pressable>
  );
}
