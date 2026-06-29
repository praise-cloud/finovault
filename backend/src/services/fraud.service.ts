import { getSupabase } from '../config/supabase';
import { createContextLogger } from '../utils/logger';
import { env } from '../config/env';

const log = createContextLogger('FraudService');

export async function checkTransaction(userId: string, input: {
  amount: number; merchant?: string; category?: string;
  location?: string; device_id?: string; receiver?: string;
}) {
  const result = {
    risk_score: 0,
    risk_level: 'low' as 'low' | 'medium' | 'high' | 'critical',
    signals: [] as string[],
    decision: 'allow' as 'allow' | 'freeze' | 'block',
    message: 'Transaction looks normal.',
  };

  const signals: string[] = [];

  if (input.amount > 10000) {
    signals.push('High-value transaction');
    result.risk_score += 25;
  }

  if (input.amount > 50000) {
    signals.push('Very high-value transaction');
    result.risk_score += 25;
  }

  if (input.receiver) {
    signals.push(`Transaction to: ${input.receiver}`);
    result.risk_score += 5;
  }

  if (result.risk_score > 50) {
    result.risk_level = 'high';
    result.decision = 'freeze';
    result.message = 'This transaction requires verification due to high risk factors.';
  } else if (result.risk_score > 25) {
    result.risk_level = 'medium';
    result.message = 'We recommend verifying this transaction.';
  }

  result.signals = signals;

  try {
    const supabase = getSupabase();
    await supabase.from('fraud_events').insert({
      user_id: userId,
      event_type: result.decision === 'allow' ? 'Transaction Checked' : 'Transaction Flagged',
      description: `Amount: $${input.amount}. Risk: ${result.risk_level}. Decision: ${result.decision}.`,
      severity: result.risk_level === 'critical' ? 'critical' : result.risk_level === 'high' ? 'warning' : 'info',
    });
  } catch (err) {
    log.error('Failed to log fraud check event', { error: (err as Error).message });
  }

  return result;
}

export async function listEvents(userId: string) {
  const supabase = getSupabase();

  const { data, error } = await supabase
    .from('fraud_events')
    .select('*')
    .eq('user_id', userId)
    .order('timestamp', { ascending: false })
    .limit(50);

  if (error) {
    log.error('List fraud events failed', { userId, error: error.message });
    return [];
  }

  return data || [];
}

export async function reportEvent(userId: string, input: { event_type: string; description: string; severity?: string; metadata?: any }) {
  const supabase = getSupabase();

  const { data, error } = await supabase
    .from('fraud_events')
    .insert({
      user_id: userId,
      event_type: input.event_type,
      description: input.description,
      severity: input.severity || 'info',
    })
    .select()
    .single();

  if (error) {
    log.error('Report fraud event failed', { userId, error: error.message });
    throw new Error('Failed to report event');
  }

  return data;
}

export async function resolveEvent(userId: string, eventId: string) {
  const supabase = getSupabase();

  const { data, error } = await supabase
    .from('fraud_events')
    .update({ severity: 'info' })
    .eq('id', eventId)
    .eq('user_id', userId)
    .select()
    .single();

  if (error) {
    log.error('Resolve event failed', { userId, eventId, error: error.message });
    throw new Error('Failed to resolve event');
  }

  return data;
}
