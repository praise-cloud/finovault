import { createClient, SupabaseClient } from '@supabase/supabase-js';
import { env } from './env';

let _supabase: SupabaseClient | null = null;

export function getSupabase(): SupabaseClient {
  if (!_supabase) {
    _supabase = createClient(env.SUPABASE_URL, env.SUPABASE_SERVICE_KEY, {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
      },
    });
  }
  return _supabase;
}

export function createNewClient(url?: string, key?: string): SupabaseClient {
  return createClient(url || env.SUPABASE_URL, key || env.SUPABASE_SERVICE_KEY, {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
  });
}
