import { supabase } from '@/lib/supabase';
import type { Profile, UserPreferences, LinkedAccount, SecurityMetrics } from '@/lib/supabase-types';

export async function getProfile(userId: string): Promise<Profile | null> {
  const { data } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', userId)
    .single();

  return data;
}

export async function updateProfile(userId: string, updates: Partial<Profile>) {
  const { data, error } = await supabase
    .from('profiles')
    .update({ ...updates, updated_at: new Date().toISOString() })
    .eq('id', userId)
    .select()
    .single();

  if (error) throw error;
  return data;
}

export async function savePreferences(userId: string, prefs: Omit<UserPreferences, 'id' | 'user_id' | 'created_at' | 'updated_at'>) {
  const existing = await supabase
    .from('user_preferences')
    .select('id')
    .eq('user_id', userId)
    .single();

  if (existing.data) {
    const { data, error } = await supabase
      .from('user_preferences')
      .update({ ...prefs, updated_at: new Date().toISOString() })
      .eq('user_id', userId)
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  const { data, error } = await supabase
    .from('user_preferences')
    .insert({ user_id: userId, ...prefs })
    .select()
    .single();

  if (error) throw error;
  return data;
}

export async function getPreferences(userId: string): Promise<UserPreferences | null> {
  const { data } = await supabase
    .from('user_preferences')
    .select('*')
    .eq('user_id', userId)
    .single();

  return data;
}

export async function getLinkedAccounts(userId: string): Promise<LinkedAccount[]> {
  const { data } = await supabase
    .from('linked_accounts')
    .select('*')
    .eq('user_id', userId);

  return data || [];
}

export async function getSecurityMetrics(userId: string): Promise<SecurityMetrics | null> {
  const { data } = await supabase
    .from('security_metrics')
    .select('*')
    .eq('user_id', userId)
    .single();

  return data;
}
