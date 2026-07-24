import { createContext, useContext, useState, useCallback, useRef, useEffect } from 'react';
import { View, Text, Pressable, Animated } from 'react-native';
import { MaterialIcons } from '@expo/vector-icons';

type ToastType = 'success' | 'error' | 'warning' | 'info';

type Toast = {
  id: number;
  type: ToastType;
  title?: string;
  message: string;
  duration?: number;
};

type ToastContextType = {
  showToast: (toast: Omit<Toast, 'id'>) => void;
};

const ToastContext = createContext<ToastContextType>({ showToast: () => {} });

const CONFIG = {
  success: { icon: 'check-circle' as const, bg: 'bg-secondary', iconColor: '#fff' },
  error: { icon: 'error' as const, bg: 'bg-error', iconColor: '#fff' },
  warning: { icon: 'warning' as const, bg: 'bg-[#ff9800]', iconColor: '#fff' },
  info: { icon: 'info' as const, bg: 'bg-primary', iconColor: '#fff' },
};

export function ToastProvider({ children }: { children: React.ReactNode }) {
  const [toasts, setToasts] = useState<Toast[]>([]);
  const idRef = useRef(0);

  const showToast = useCallback((t: Omit<Toast, 'id'>) => {
    const id = ++idRef.current;
    setToasts((prev) => [...prev, { ...t, id }]);
    setTimeout(() => {
      setToasts((prev) => prev.filter((item) => item.id !== id));
    }, t.duration || 3000);
  }, []);

  const removeToast = (id: number) => {
    setToasts((prev) => prev.filter((t) => t.id !== id));
  };

  return (
    <ToastContext.Provider value={{ showToast }}>
      {children}
      <View className="absolute top-14 left-4 right-4 z-[9999] gap-2" style={{ pointerEvents: 'box-none' }}>
        {toasts.map((toast) => {
          const c = CONFIG[toast.type];
          return (
            <View key={toast.id} className={`flex-row items-center gap-3 px-4 py-3.5 rounded-xl ${c.bg}`} style={{ boxShadow: '0 4px 12px rgba(0,0,0,0.15)', elevation: 8 }}>
              <MaterialIcons name={c.icon} size={20} color={c.iconColor} />
              <View className="flex-1">
                {toast.title && <Text className="font-label-md font-bold text-white">{toast.title}</Text>}
                <Text className="text-white/90 text-body-md text-sm">{toast.message}</Text>
              </View>
              <Pressable onPress={() => removeToast(toast.id)} className="p-1 active:scale-90">
                <MaterialIcons name="close" size={16} color="rgba(255,255,255,0.7)" />
              </Pressable>
            </View>
          );
        })}
      </View>
    </ToastContext.Provider>
  );
}

export function useToast() {
  return useContext(ToastContext);
}
