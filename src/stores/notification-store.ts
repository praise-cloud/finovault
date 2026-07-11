import { create } from 'zustand';

interface NotificationState {
  count: number;
  visible: boolean;
  open: () => void;
  close: () => void;
  setCount: (count: number) => void;
}

export const useNotificationStore = create<NotificationState>((set) => ({
  count: 3,
  visible: false,
  open: () => set({ visible: true }),
  close: () => set({ visible: false }),
  setCount: (count) => set({ count }),
}));
