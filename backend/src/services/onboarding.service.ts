import { getSupabase } from '../config/supabase';
import { NotFoundError } from '../utils/errors';
import { createContextLogger } from '../utils/logger';

const log = createContextLogger('OnboardingService');

export async function submitInterview(userId: string, input: Record<string, any>) {
  const supabase = getSupabase();

  const { data, error } = await supabase
    .from('financial_profiles')
    .upsert({
      user_id: userId,
      ...input,
      updated_at: new Date().toISOString(),
    })
    .select()
    .single();

  if (error) {
    log.error('Submit interview failed', { userId, error: error.message });
    throw new Error('Failed to save financial profile');
  }

  return data;
}

export async function getFinancialProfile(userId: string) {
  const supabase = getSupabase();

  const { data, error } = await supabase
    .from('financial_profiles')
    .select('*')
    .eq('user_id', userId)
    .single();

  if (error) {
    if (error.code === 'PGRST116') {
      return null;
    }
    log.error('Get financial profile failed', { userId, error: error.message });
    throw new NotFoundError('Financial profile');
  }

  return data;
}

export async function updateFinancialProfile(userId: string, input: Record<string, any>) {
  const supabase = getSupabase();

  const { data, error } = await supabase
    .from('financial_profiles')
    .update({ ...input, updated_at: new Date().toISOString() })
    .eq('user_id', userId)
    .select()
    .single();

  if (error) {
    log.error('Update financial profile failed', { userId, error: error.message });
    throw new NotFoundError('Financial profile');
  }

  return data;
}
