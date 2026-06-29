import { getSupabase } from '../config/supabase';
import { UnauthorizedError, ConflictError, InternalError } from '../utils/errors';
import { createContextLogger } from '../utils/logger';

const log = createContextLogger('AuthService');

export async function sendOtp(input: { email: string; full_name: string; phone?: string }) {
  const supabase = getSupabase();

  const { error } = await supabase.auth.signInWithOtp({
    email: input.email,
    options: {
      data: {
        full_name: input.full_name,
        phone: input.phone || null,
      },
      shouldCreateUser: true,
    },
  });

  if (error) {
    if (error.message.includes('already')) {
      throw new ConflictError('Email already registered');
    }
    log.error('Send OTP failed', { error: error.message });
    throw new InternalError('Failed to send verification code');
  }

  return { message: 'Verification code sent' };
}

export async function signup(input: { email: string; password: string; full_name: string; phone?: string }) {
  const supabase = getSupabase();

  const { data, error } = await supabase.auth.admin.createUser({
    email: input.email,
    password: input.password,
    email_confirm: true,
    user_metadata: {
      full_name: input.full_name,
      phone: input.phone || null,
    },
  });

  if (error) {
    if (error.message.includes('already registered')) {
      throw new ConflictError('Email already registered');
    }
    log.error('Signup failed', { error: error.message });
    throw new InternalError('Failed to create account');
  }

  const sessionRes = await supabase.auth.signInWithPassword({
    email: input.email,
    password: input.password,
  });

  return {
    user: sessionRes.data.user,
    session: sessionRes.data.session,
  };
}

export async function login(input: { email: string; password: string }) {
  const supabase = getSupabase();

  const { data, error } = await supabase.auth.signInWithPassword({
    email: input.email,
    password: input.password,
  });

  if (error) {
    throw new UnauthorizedError('Invalid email or password');
  }

  return {
    user: data.user,
    session: data.session,
  };
}

export async function verifyOtp(input: { email: string; token: string; password?: string; full_name?: string; phone?: string }) {
  const supabase = getSupabase();

  const { data, error } = await supabase.auth.verifyOtp({
    email: input.email,
    token: input.token,
    type: 'email',
  });

  if (error) {
    throw new UnauthorizedError('Invalid or expired OTP');
  }

  if (data.user) {
    const updates: Record<string, any> = {};

    if (input.password) {
      updates.password = input.password;
    }

    if (input.full_name || input.phone) {
      updates.user_metadata = {
        ...(input.full_name ? { full_name: input.full_name } : {}),
        ...(input.phone ? { phone: input.phone } : {}),
      };
    }

    if (Object.keys(updates).length > 0) {
      const { error: updateError } = await supabase.auth.admin.updateUserById(data.user.id, updates);
      if (updateError) {
        log.error('Failed to update user after OTP', { error: updateError.message });
      }
    }
  }

  return {
    user: data.user,
    session: data.session,
  };
}

export async function googleAuth(tokenData: { access_token?: string }) {
  const supabase = getSupabase();

  if (tokenData.access_token) {
    const { data, error } = await supabase.auth.signInWithIdToken({
      provider: 'google',
      token: tokenData.access_token,
    });

    if (error) {
      throw new UnauthorizedError('Google authentication failed');
    }

    return {
      user: data.user,
      session: data.session,
    };
  }

  const { data, error } = await supabase.auth.signInWithOAuth({
    provider: 'google',
  });

  if (error) {
    throw new UnauthorizedError('Failed to initiate Google auth');
  }

  return { url: data.url };
}

export async function verifySession(token: string) {
  const supabase = getSupabase();

  const { data, error } = await supabase.auth.getUser(token);

  if (error || !data.user) {
    throw new UnauthorizedError('Invalid or expired session');
  }

  return { user: data.user };
}

export async function logout(userId: string): Promise<void> {
  const supabase = getSupabase();
  const { error } = await supabase.auth.admin.signOut(userId);

  if (error) {
    log.error('Logout failed', { userId, error: error.message });
  }
}

export async function refreshSession(refreshToken: string) {
  const supabase = getSupabase();

  const { data, error } = await supabase.auth.refreshSession({ refresh_token: refreshToken });

  if (error) {
    throw new UnauthorizedError('Failed to refresh session');
  }

  return {
    user: data.user,
    session: data.session,
  };
}
