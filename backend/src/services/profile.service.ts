import { getSupabase } from '../config/supabase';
import { NotFoundError } from '../utils/errors';
import { createContextLogger } from '../utils/logger';
import type { UpdateProfileInput, UpdatePreferencesInput } from '../models/user.schema';

const log = createContextLogger('ProfileService');

export async function getProfile(userId: string) {
  const supabase = getSupabase();

  const [profileRes, prefsRes, accountsRes, securityRes] = await Promise.all([
    supabase.from('profiles').select('*').eq('id', userId).single(),
    supabase.from('user_preferences').select('*').eq('user_id', userId).single(),
    supabase.from('linked_accounts').select('*').eq('user_id', userId),
    supabase.from('security_metrics').select('*').eq('user_id', userId).single(),
  ]);

  if (profileRes.error) {
    log.error('Profile fetch failed', { userId, error: profileRes.error.message });
    throw new NotFoundError('Profile');
  }

  return {
    profile: profileRes.data,
    preferences: prefsRes.data || null,
    linked_accounts: accountsRes.data || [],
    security: securityRes.data || null,
  };
}

export async function updateProfile(userId: string, input: UpdateProfileInput) {
  const supabase = getSupabase();

  const updates: Record<string, any> = { ...input, updated_at: new Date().toISOString() };

  const { data, error } = await supabase
    .from('profiles')
    .update(updates)
    .eq('id', userId)
    .select()
    .single();

  if (error) {
    log.error('Profile update failed', { userId, error: error.message });
    throw new NotFoundError('Profile');
  }

  return data;
}

export async function getPreferences(userId: string) {
  const supabase = getSupabase();

  const { data, error } = await supabase
    .from('user_preferences')
    .select('*')
    .eq('user_id', userId)
    .single();

  if (error && error.code !== 'PGRST116') {
    log.error('Preferences fetch failed', { userId, error: error.message });
  }

  return data || null;
}

export async function updatePreferences(userId: string, input: UpdatePreferencesInput) {
  const supabase = getSupabase();

  const existing = await supabase
    .from('user_preferences')
    .select('id')
    .eq('user_id', userId)
    .single();

  const updates = { ...input, updated_at: new Date().toISOString() };

  let result;
  if (existing.data) {
    result = await supabase
      .from('user_preferences')
      .update(updates)
      .eq('user_id', userId)
      .select()
      .single();
  } else {
    result = await supabase
      .from('user_preferences')
      .insert({ user_id: userId, ...updates })
      .select()
      .single();
  }

  if (result.error) {
    log.error('Preferences update failed', { userId, error: result.error.message });
    throw new Error('Failed to update preferences');
  }

  return result.data;
}

export async function linkAccount(userId: string, input: { bank_name: string; account_type: string; account_number: string; balance?: number }) {
  const supabase = getSupabase();

  const { data, error } = await supabase
    .from('linked_accounts')
    .insert({
      user_id: userId,
      bank_name: input.bank_name,
      account_type: input.account_type,
      account_number: input.account_number,
      balance: input.balance || 0,
    })
    .select()
    .single();

  if (error) {
    log.error('Link account failed', { userId, error: error.message });
    throw new Error('Failed to link account');
  }

  return data;
}

export async function getLinkedAccounts(userId: string) {
  const supabase = getSupabase();

  const { data, error } = await supabase
    .from('linked_accounts')
    .select('*')
    .eq('user_id', userId);

  if (error) {
    log.error('Linked accounts fetch failed', { userId, error: error.message });
    return [];
  }

  return data || [];
}
