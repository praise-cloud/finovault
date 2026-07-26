import { getSupabase } from '../config/supabase';
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

export async function forgotPassword(email: string) {
  const supabase = getSupabase();

  const { error } = await supabase.auth.resetPasswordForEmail(email, {
    redirectTo: `${process.env.FRONTEND_URL || 'https://finovault.ai'}/reset-password`,
  });

  if (error) {
    log.error('Forgot password failed', { error: error.message });
    throw new InternalError('Failed to send reset email');
  }

  return { message: 'Password reset email sent' };
}

export async function resetPassword(token: string, newPassword: string) {
  const supabase = getSupabase();

  // Verify the token by exchanging it for a session
  const { error } = await supabase.auth.verifyOtp({
    type: 'recovery',
    token,
  });

  if (error) {
    throw new UnauthorizedError('Invalid or expired reset token');
  }

  // Update the password
  const { error: updateError } = await supabase.auth.updateUser({
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

  // Verify current password by attempting sign in with the user's email
  const { data: userData } = await supabase.auth.admin.getUserById(userId);
  if (!userData.user?.email) {
    throw new UnauthorizedError('User not found');
  }

  const { error: verifyError } = await supabase.auth.signInWithPassword({
    email: userData.user.email,
    password: currentPassword,
  });

  if (verifyError) {
    throw new UnauthorizedError('Current password is incorrect');
  }

  const { error: updateError } = await supabase.auth.updateUser({
    password: newPassword,
  });

  if (updateError) {
    log.error('Change password failed', { error: updateError.message });
    throw new InternalError('Failed to change password');
  }

  return { message: 'Password changed successfully' };
}
