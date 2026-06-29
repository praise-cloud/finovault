import { getSupabase } from '../config/supabase';
import { NotFoundError } from '../utils/errors';
import { createContextLogger } from '../utils/logger';

const log = createContextLogger('SavingsService');

export async function listGoals(userId: string) {
  const supabase = getSupabase();
  const { data, error } = await supabase
    .from('savings_goals')
    .select('*')
    .eq('user_id', userId)
    .order('created_at', { ascending: false });

  if (error) {
    log.error('List goals failed', { userId, error: error.message });
    return [];
  }

  return data || [];
}

export async function createGoal(userId: string, input: { name: string; target_amount: number; current_amount?: number; goal_type?: string }) {
  const supabase = getSupabase();

  const { data, error } = await supabase
    .from('savings_goals')
    .insert({
      user_id: userId,
      name: input.name,
      target_amount: input.target_amount,
      current_amount: input.current_amount || 0,
      goal_type: input.goal_type || 'general',
      status: 'active',
    })
    .select()
    .single();

  if (error) {
    log.error('Create goal failed', { userId, error: error.message });
    throw new Error('Failed to create savings goal');
  }

  return data;
}

export async function updateGoal(userId: string, goalId: string, input: Record<string, any>) {
  const supabase = getSupabase();

  const { data, error } = await supabase
    .from('savings_goals')
    .update({ ...input, updated_at: new Date().toISOString() })
    .eq('id', goalId)
    .eq('user_id', userId)
    .select()
    .single();

  if (error) {
    throw new NotFoundError('Savings goal');
  }

  return data;
}

export async function deleteGoal(userId: string, goalId: string): Promise<void> {
  const supabase = getSupabase();

  const { error } = await supabase
    .from('savings_goals')
    .delete()
    .eq('id', goalId)
    .eq('user_id', userId);

  if (error) {
    throw new NotFoundError('Savings goal');
  }
}

export async function listRoundUps(userId: string) {
  const supabase = getSupabase();

  const { data, error } = await supabase
    .from('round_up_savings')
    .select('*')
    .eq('user_id', userId)
    .order('date', { ascending: false })
    .limit(50);

  if (error) {
    log.error('List round-ups failed', { userId, error: error.message });
    return [];
  }

  return data || [];
}
