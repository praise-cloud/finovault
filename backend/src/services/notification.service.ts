import { getSupabase } from '../config/supabase';
import { NotFoundError } from '../utils/errors';
import { createContextLogger } from '../utils/logger';

const log = createContextLogger('NotificationService');

export interface NotificationPayload {
  user_id: string;
  title: string;
  body: string;
  type: 'alert' | 'insight' | 'coaching' | 'fraud' | 'milestone';
  data?: Record<string, unknown>;
}

export async function sendNotification(payload: NotificationPayload): Promise<void> {
  const supabase = getSupabase();

  const { error } = await supabase
    .from('notifications')
    .insert({
      user_id: payload.user_id,
      title: payload.title,
      body: payload.body,
      type: payload.type,
      data: payload.data || {},
    });

  if (error) {
    log.error('Failed to send notification', { userId: payload.user_id, error: error.message });
  }
}

export async function listNotifications(userId: string, limit = 50) {
  const supabase = getSupabase();

  const { data, error } = await supabase
    .from('notifications')
    .select('*')
    .eq('user_id', userId)
    .order('created_at', { ascending: false })
    .limit(limit);

  if (error) {
    log.error('List notifications failed', { userId, error: error.message });
    return [];
  }

  return data || [];
}

export async function markNotificationRead(userId: string, notificationId: string) {
  const supabase = getSupabase();

  const { data, error } = await supabase
    .from('notifications')
    .update({ read: true })
    .eq('id', notificationId)
    .eq('user_id', userId)
    .select()
    .single();

  if (error) {
    throw new NotFoundError('Notification');
  }

  return data;
}

export async function markAllNotificationsRead(userId: string) {
  const supabase = getSupabase();

  const { error } = await supabase
    .from('notifications')
    .update({ read: true })
    .eq('user_id', userId)
    .eq('read', false);

  if (error) {
    log.error('Mark all notifications read failed', { userId, error: error.message });
    throw new Error('Failed to mark notifications as read');
  }
}

export async function getUnreadCount(userId: string): Promise<number> {
  const supabase = getSupabase();

  const { count, error } = await supabase
    .from('notifications')
    .select('*', { count: 'exact', head: true })
    .eq('user_id', userId)
    .eq('read', false);

  if (error) {
    log.error('Get unread count failed', { userId, error: error.message });
    return 0;
  }

  return count || 0;
}

export async function checkSpendingAlert(userId: string, currentSpending: number, limit: number): Promise<void> {
  if (currentSpending > limit) {
    const overage = ((currentSpending - limit) / limit) * 100;

    await sendNotification({
      user_id: userId,
      title: 'Spending Alert',
      body: `Your spending has increased by ${overage.toFixed(0)}% this month. Would you like help reducing it?`,
      type: 'alert',
      data: { current_spending: currentSpending, limit, overage_percent: overage },
    });
  }
}
