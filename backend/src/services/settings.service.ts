import crypto from 'node:crypto';
import { getSupabase } from '../config/supabase';
import { createContextLogger } from '../utils/logger';

const log = createContextLogger('SettingsService');

function hashCode(code: string): string {
  return crypto.createHash('sha256').update(code).digest('hex');
}

function generateRecoveryCodes(): string[] {
  const codes: string[] = [];
  for (let i = 0; i < 8; i++) {
    const part1 = crypto.randomBytes(2).toString('hex').toUpperCase();
    const part2 = crypto.randomBytes(2).toString('hex').toUpperCase();
    codes.push(`${part1}-${part2}`);
  }
  return codes;
}

export async function getSecuritySettings(userId: string) {
  const supabase = getSupabase();

  const [settingsRes, auditRes] = await Promise.all([
    supabase.from('security_settings').select('*').eq('user_id', userId).maybeSingle(),
    supabase.from('audit_log').select('*').eq('user_id', userId).order('created_at', { ascending: false }).limit(10),
  ]);

  if (settingsRes.error && settingsRes.error.code !== 'PGRST116') {
    log.error('getSecuritySettings error', { error: settingsRes.error.message });
  }

  return {
    two_factor_enabled: settingsRes.data?.two_factor_enabled || false,
    two_factor_method: settingsRes.data?.two_factor_method || 'app',
    guardrails: settingsRes.data?.guardrails || [],
    privacy_toggles: settingsRes.data?.privacy_toggles || [],
    recovery_codes: [],
    recent_events: auditRes.data || [],
  };
}

export async function updateSecuritySettings(userId: string, updates: {
  two_factor_enabled?: boolean;
  two_factor_method?: string;
  guardrails?: any[];
  privacy_toggles?: any[];
}) {
  const supabase = getSupabase();

  const existing = await supabase.from('security_settings').select('id').eq('user_id', userId).maybeSingle();

  if (existing.data) {
    const { error } = await supabase.from('security_settings').update({ ...updates, updated_at: new Date().toISOString() }).eq('user_id', userId);
    if (error) {
      log.error('updateSecuritySettings error', { error: error.message });
      throw new Error('Failed to update security settings');
    }
  } else {
    const { error } = await supabase.from('security_settings').insert({ user_id: userId, ...updates });
    if (error) {
      log.error('insertSecuritySettings error', { error: error.message });
      throw new Error('Failed to create security settings');
    }
  }

  return { message: 'Security settings updated' };
}

export async function updateTwoFactor(userId: string, updates: { enabled: boolean; method?: string }) {
  const supabase = getSupabase();

  await supabase.from('security_settings').upsert(
    { user_id: userId, two_factor_enabled: updates.enabled, two_factor_method: updates.method || 'app', updated_at: new Date().toISOString() },
    { onConflict: 'user_id' }
  );

  return { message: 'Two-factor authentication updated' };
}

export async function enableTwoFactorWithCodes(userId: string, method?: string): Promise<{ message: string; recovery_codes: string[] }> {
  const supabase = getSupabase();

  await supabase.from('security_settings').upsert(
    { user_id: userId, two_factor_enabled: true, two_factor_method: method || 'app', updated_at: new Date().toISOString() },
    { onConflict: 'user_id' }
  );

  const codes = generateRecoveryCodes();
  const hashed = codes.map((code) => ({ user_id: userId, code_hash: hashCode(code) }));

  await supabase.from('recovery_codes').delete().eq('user_id', userId);
  const { error } = await supabase.from('recovery_codes').insert(hashed);
  if (error) {
    log.error('storeRecoveryCodes error', { error: error.message });
    throw new Error('Failed to store recovery codes');
  }

  return { message: 'Two-factor authentication enabled', recovery_codes: codes };
}

export async function verifyRecoveryCode(userId: string, code: string): Promise<boolean> {
  const supabase = getSupabase();

  const hashed = hashCode(code);
  const { data, error } = await supabase
    .from('recovery_codes')
    .select('id, used')
    .eq('user_id', userId)
    .eq('code_hash', hashed)
    .maybeSingle();

  if (error || !data || data.used) {
    return false;
  }

  await supabase.from('recovery_codes').update({ used: true }).eq('id', data.id);
  return true;
}

export async function getRecoveryCodesStatus(userId: string): Promise<{ total: number; remaining: number }> {
  const supabase = getSupabase();

  const { data, error } = await supabase
    .from('recovery_codes')
    .select('used')
    .eq('user_id', userId);

  if (error || !data) {
    return { total: 0, remaining: 0 };
  }

  return {
    total: data.length,
    remaining: data.filter((c) => !c.used).length,
  };
}

export async function updateGuardrails(userId: string, guardrails: any[]) {
  return updateSecuritySettings(userId, { guardrails });
}

export async function updatePrivacyToggles(userId: string, privacy_toggles: any[]) {
  return updateSecuritySettings(userId, { privacy_toggles });
}

export async function getLinkedAccounts(userId: string) {
  const supabase = getSupabase();

  const { data, error } = await supabase
    .from('linked_accounts')
    .select('*')
    .eq('user_id', userId)
    .order('created_at', { ascending: false });

  if (error) {
    log.error('getLinkedAccounts error', { error: error.message });
    return [];
  }

  return data || [];
}

export async function getLoginActivity(userId: string) {
  const supabase = getSupabase();

  const { data, error } = await supabase
    .from('audit_log')
    .select('*')
    .eq('user_id', userId)
    .order('created_at', { ascending: false })
    .limit(20);

  if (error) {
    log.error('getLoginActivity error', { error: error.message });
    return [];
  }

  return data || [];
}

export async function getAuditLog(userId: string) {
  const supabase = getSupabase();

  const { data, error } = await supabase
    .from('audit_log')
    .select('*')
    .eq('user_id', userId)
    .order('created_at', { ascending: false })
    .limit(50);

  if (error) {
    log.error('getAuditLog error', { error: error.message });
    return [];
  }

  return data || [];
}

export async function getDataPrivacy(userId: string) {
  const supabase = getSupabase();

  const { data, error } = await supabase
    .from('security_settings')
    .select('privacy_toggles')
    .eq('user_id', userId)
    .maybeSingle();

  if (error && error.code !== 'PGRST116') {
    log.error('getDataPrivacy error', { error: error.message });
  }

  return {
    privacy_toggles: data?.privacy_toggles || [
      { key: 'data_sharing', label: 'Data Sharing', enabled: true },
      { key: 'personalization', label: 'Personalized Insights', enabled: true },
      { key: 'third_party', label: 'Third-Party Sharing', enabled: false },
      { key: 'marketing', label: 'Marketing Communications', enabled: false },
      { key: 'analytics', label: 'Usage Analytics', enabled: true },
    ],
    last_updated: '2026-06-15',
  };
}
