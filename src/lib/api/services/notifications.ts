import { apiClient } from '../client';
import { ENDPOINTS } from '../endpoints';

export interface AppNotification {
  id: string;
  user_id: string;
  title: string;
  body: string;
  type: 'alert' | 'insight' | 'coaching' | 'fraud' | 'milestone';
  data: Record<string, unknown>;
  read: boolean;
  created_at: string;
}

export async function listNotifications(limit = 50): Promise<AppNotification[]> {
  const data = await apiClient.get<AppNotification[]>(ENDPOINTS.notifications.list, {
    params: { limit: String(limit) },
  });
  return data || [];
}

export async function getUnreadCount(): Promise<number> {
  const data = await apiClient.get<{ count: number }>(ENDPOINTS.notifications.unreadCount);
  return data?.count ?? 0;
}

export async function markRead(id: string): Promise<AppNotification> {
  return apiClient.put<AppNotification>(ENDPOINTS.notifications.markRead(id));
}

export async function markAllRead(): Promise<void> {
  await apiClient.put<void>(ENDPOINTS.notifications.markAllRead);
}
