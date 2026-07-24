import { Button } from '@/components/ui/button';

type Props = {
  title: string;
  onPress?: () => void;
  className?: string;
  disabled?: boolean;
};

export function PrimaryButton({ title, onPress, disabled }: Props) {
  return (
    <Button
      title={title}
      onPress={() => onPress?.()}
      variant="primary"
      disabled={disabled}
    />
  );
}
