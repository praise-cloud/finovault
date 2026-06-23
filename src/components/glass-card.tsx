import { PropsWithChildren } from 'react';
import { View, ViewProps } from 'react-native';

type Props = PropsWithChildren<ViewProps & { className?: string }>;

export function GlassCard({ children, className = '', ...props }: Props) {
  return (
    <View
      className={`bg-white/70 rounded-xl border border-outline-variant/50 ${className}`}
      style={{
        backgroundColor: 'rgba(255,255,255,0.7)',
        borderWidth: 0,
      }}
      {...props}
    >
      {children}
    </View>
  );
}
