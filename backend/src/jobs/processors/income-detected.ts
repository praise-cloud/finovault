import { Job } from 'bull';
import { getSupabase } from '../../config/supabase';
import { sendNotification } from '../../services/notification.service';
import { generateCoachResponse } from '../../services/ai.service';
import { createContextLogger } from '../../utils/logger';

const log = createContextLogger('IncomeDetectedProcessor');

export async function processIncomeDetected(job: Job) {
  const { userId, transactionId, amount, merchant, description, category } = job.data;

  log.info(`Processing income event for user ${userId}`, { transactionId, amount });

  const supabase = getSupabase();

  const source = merchant || description || 'a transfer';
  await sendNotification({
    user_id: userId,
    title: 'Income Received',
    body: `You received $${Number(amount).toFixed(2)} from ${source}.`,
    type: 'milestone',
    data: { transaction_id: transactionId, amount, source },
  });

  const { data: transactions } = await supabase
    .from('transactions')
    .select('type, amount, category, merchant, date')
    .eq('user_id', userId)
    .order('date', { ascending: false })
    .limit(30);

  const { data: savingsGoals } = await supabase
    .from('savings_goals')
    .select('*')
    .eq('user_id', userId)
    .eq('status', 'active');

  const prompt = `I just received $${Number(amount).toFixed(2)} from ${source}. What should I do with this money? Give me one specific recommendation.`;
  const recommendation = generateCoachResponse(prompt, null, transactions || [], savingsGoals || []);

  const { error: sugErr } = await supabase
    .from('ai_suggestions')
    .insert({
      user_id: userId,
      title: `Income received: $${Number(amount).toFixed(2)}`,
      description: recommendation,
      type: 'income_event',
      potential_savings: Math.round(Number(amount) * 0.2 * 100) / 100,
      status: 'active',
    });

  if (sugErr) {
    log.error('Failed to persist income suggestion', { userId, error: sugErr.message });
  }

  log.info(`Income event processed for user ${userId}`);

  return {
    processed: true,
    notified: true,
    recommendation_generated: true,
  };
}
