import { getSupabase } from '../config/supabase';
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
