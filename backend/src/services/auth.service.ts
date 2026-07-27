import { env } from '../config/env';
import { getSupabase, getAuthClient } from '../config/supabase';
import { UnauthorizedError, ConflictError, InternalError } from '../utils/errors';
import { createContextLogger } from '../utils/logger';

const log = createContextLogger('AuthService');

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

  const auth = getAuthClient();
  const sessionRes = await auth.auth.signInWithPassword({
    email: input.email,
    password: input.password,
  });

  return {
    user: sessionRes.data.user,
    session: sessionRes.data.session,
  };
}

export async function login(input: { email: string; password: string }) {
  const auth = getAuthClient();

  const { data, error } = await auth.auth.signInWithPassword({
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

export async function googleAuth(tokenData: { access_token?: string }) {
  const auth = getAuthClient();

  if (tokenData.access_token) {
    const { data, error } = await auth.auth.signInWithIdToken({
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

  const { data, error } = await auth.auth.signInWithOAuth({
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
  const auth = getAuthClient();

  const { data, error } = await auth.auth.refreshSession({ refresh_token: refreshToken });

  if (error) {
    throw new UnauthorizedError('Failed to refresh session');
  }

  return {
    user: data.user,
    session: data.session,
  };
}

export async function forgotPassword(email: string) {
  const auth = getAuthClient();

  const { error } = await auth.auth.resetPasswordForEmail(email, {
    redirectTo: `${env.FRONTEND_URL}/reset-password`,
  });

  if (error) {
    log.error('Forgot password failed', { error: error.message });
    throw new InternalError('Failed to send reset email');
  }

  return { message: 'Password reset email sent' };
}

export async function resetPassword(token: string, newPassword: string, email?: string) {
  const auth = getAuthClient();

  const { error } = await auth.auth.verifyOtp({
    type: 'recovery',
    token,
    email: email || '',
  });

  if (error) {
    throw new UnauthorizedError('Invalid or expired reset token');
  }

  const { error: updateError } = await auth.auth.updateUser({
    password: newPassword,
  });

  if (updateError) {
    log.error('Reset password failed', { error: updateError.message });
    throw new InternalError('Failed to reset password');
  }

  return { message: 'Password reset successfully' };
}

export async function changePassword(userId: string, currentPassword: string, newPassword: string) {
  const supabase = getSupabase();
  const auth = getAuthClient();

  const userResult = await supabase.auth.admin.getUserById(userId);
  const userEmail = userResult.data?.user?.email;
  if (!userEmail) {
    throw new UnauthorizedError('User not found');
  }

  const { error: signInError } = await auth.auth.signInWithPassword({
    email: userEmail,
    password: currentPassword,
  });

  if (signInError) {
    throw new UnauthorizedError('Current password is incorrect');
  }

  const { error: updateError } = await supabase.auth.admin.updateUserById(userId, {
    password: newPassword,
  });

  if (updateError) {
    log.error('Change password failed', { error: updateError.message });
    throw new InternalError('Failed to change password');
  }

  await supabase.auth.admin.signOut(userId);

  return { message: 'Password changed successfully' };
}
