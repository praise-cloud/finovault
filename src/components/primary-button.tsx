import { Button, ButtonText } from '@gluestack-ui/themed';
import { PressableProps } from 'react-native';

type Props = {
  title: string;
  onPress?: () => void;
  className?: string;
  disabled?: boolean;
};

export function PrimaryButton({ title, onPress, className = '', disabled }: Props) {
  return (
    <Button
      onPress={onPress}
      disabled={disabled}
      className={`bg-gradient-to-r from-secondary to-[#005143] rounded-xl py-4 shadow-lg ${className}`}
      style={{ shadowColor: 'rgba(0,107,90,0.25)', shadowOffset: { width: 0, height: 4 }, shadowRadius: 14, elevation: 4 }}
    >
      <ButtonText className="text-on-primary font-label-md font-bold">{title}</ButtonText>
    </Button>
  );
}
