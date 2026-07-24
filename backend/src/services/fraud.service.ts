import { getSupabase } from '../config/supabase';
import { createContextLogger } from '../utils/logger';
import { aiClient } from '../lib/ai-client';

const log = createContextLogger('FraudService');

export async function checkTransaction(
  userId: string,
  input: {
    amount: number; merchant?: string; category?: string;
    location?: string; device_id?: string; receiver?: string;
  },
  userToken?: string,
) {
  let risk_score = 0;
  let risk_level: 'low' | 'medium' | 'high' | 'critical' = 'low';
  let signals: string[] = [];
  let decision: 'allow' | 'freeze' | 'block' = 'allow';
  let message = 'Transaction looks normal.';

  if (userToken) {
    try {
      const aiResult = await aiClient.checkFraud(input, userToken, userId);
      risk_score = aiResult.risk_score;
      risk_level = aiResult.risk_level as typeof risk_level;
      signals = aiResult.signals;
      decision = aiResult.decision as typeof decision;
      message = aiResult.message;
    } catch (error: any) {
      log.warn(`AI fraud service unavailable, falling back to local rules: ${error.message}`);
    }
  }

  if (!userToken || risk_score === 0) {
    if (input.amount > 10000) {
      signals.push('High-value transaction');
      risk_score += 25;
    }
    if (input.amount > 50000) {
      signals.push('Very high-value transaction');
      risk_score += 25;
    }
    if (input.receiver) {
      signals.push(`Transaction to: ${input.receiver}`);
      risk_score += 5;
    }
    if (risk_score > 50) {
      risk_level = 'high';
      decision = 'freeze';
      message = 'This transaction requires verification due to high risk factors.';
    } else if (risk_score > 25) {
      risk_level = 'medium';
      message = 'We recommend verifying this transaction.';
    }
  }

  const result: { risk_score: number; risk_level: string; signals: string[]; decision: string; message: string } = { risk_score, risk_level, signals, decision, message };

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
