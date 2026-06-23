import { supabase } from '@/lib/supabase';

export interface SignUpParams {
  email: string;
  password: string;
  fullName: string;
  phone?: string;
}

export interface SignInParams {
  email: string;
  password: string;
}

export interface AuthResult {
  user: any;
  session: any;
  error?: string;
}

export async function sendSignUpOtp({ email, fullName, phone }: Omit<SignUpParams, 'password'>): Promise<string | null> {
  const { error } = await supabase.auth.signInWithOtp({
    email,
    options: {
      data: {
        full_name: fullName,
        phone: phone || null,
      },
      shouldCreateUser: true,
    },
  });

  return error ? error.message : null;
}

export async function updateUserPassword(password: string): Promise<string | null> {
  const { error } = await supabase.auth.updateUser({ password });
  return error ? error.message : null;
}

export async function signInWithEmail({ email, password }: SignInParams): Promise<AuthResult> {
  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password,
  });

  if (error) return { user: null, session: null, error: error.message };
  return { user: data.user, session: data.session };
}

export async function signInWithGoogle(): Promise<void> {
  await supabase.auth.signInWithOAuth({
    provider: 'google',
    options: {
      redirectTo: 'finovault://auth/callback',
    },
  });
}

export async function signOut(): Promise<void> {
  await supabase.auth.signOut();
}

export async function verifyOtp(email: string, token: string): Promise<AuthResult> {
  const { data, error } = await supabase.auth.verifyOtp({
    email,
    token,
    type: 'email',
  });

  if (error) return { user: null, session: null, error: error.message };
  return { user: data.user, session: data.session };
}

export async function resendOtp(email: string): Promise<string | null> {
  const { error } = await supabase.auth.signInWithOtp({ email });
  return error ? error.message : null;
}

export async function getCurrentSession() {
  const { data } = await supabase.auth.getSession();
  return data.session;
}

export async function getCurrentUser() {
  const { data } = await supabase.auth.getUser();
  return data.user;
}
