import { create } from 'zustand';
import { getUnreadCount } from '@/src/lib/api/services/notifications';

interface NotificationState {
  count: number;
  visible: boolean;
  initialized: boolean;
  open: () => void;
  close: () => void;
  setCount: (count: number) => void;
  refreshCount: () => Promise<void>;
}

let pollTimer: ReturnType<typeof setInterval> | null = null;

export const useNotificationStore = create<NotificationState>((set) => ({
  count: 0,
  visible: false,
  initialized: false,
  open: () => set({ visible: true }),
  close: () => set({ visible: false }),
  setCount: (count) => set({ count }),
  refreshCount: async () => {
    try {
      const count = await getUnreadCount();
      set({ count });
    } catch {
      // silently fail on poll
    }
  },
}));

export function startNotificationPolling() {
  const state = useNotificationStore.getState();
  if (state.initialized) return;
  useNotificationStore.setState({ initialized: true });
  state.refreshCount();
  pollTimer = setInterval(() => {
    useNotificationStore.getState().refreshCount();
  }, 30000);
}

export function stopNotificationPolling() {
  if (pollTimer) {
    clearInterval(pollTimer);
    pollTimer = null;
  }
}
