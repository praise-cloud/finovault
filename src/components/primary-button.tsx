import { ButtonText } from '@gluestack-ui/themed';
import { Pressable } from 'react-native';
import { useSharedValue, useAnimatedStyle, withSpring } from 'react-native-reanimated';
import Animated from 'react-native-reanimated';
import { mediumImpact } from '@/hooks/use-haptics';
import { playSound } from '@/lib/sounds';

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
    playSound('open');
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
        style={[animatedStyle, { shadowColor: 'rgba(0,107,90,0.25)', shadowOffset: { width: 0, height: 4 }, shadowRadius: 14, elevation: 4 }]}
        className={`bg-gradient-to-r from-secondary to-[#005143] rounded-xl py-4 shadow-lg ${className}`}
      >
        <ButtonText className="text-on-primary font-label-md font-bold text-center">{title}</ButtonText>
      </Animated.View>
    </Pressable>
  );
}
