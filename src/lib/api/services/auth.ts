import { apiClient, getApiToken } from '../client';
import { ENDPOINTS } from '../endpoints';

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

export interface UserProfile {
  id: string;
  email?: string;
  full_name?: string;
  avatar_url?: string;
  [key: string]: unknown;
}

export interface AuthSession {
  access_token: string;
  user: UserProfile;
}

export interface AuthResult {
  user: UserProfile | null;
  session: AuthSession | null;
  error?: string;
}

export async function signUpWithEmail(params: SignUpParams): Promise<AuthResult> {
  try {
    const result = await apiClient.post<any>(ENDPOINTS.auth.signup, {
      email: params.email,
      password: params.password,
      full_name: params.fullName,
      phone: params.phone,
    });
    return { user: result.user, session: result.session };
  } catch (err: any) {
    return { user: null, session: null, error: err.message || 'Sign up failed' };
  }
}

export async function updateUserPassword(currentPassword: string, newPassword: string): Promise<string | null> {
  try {
    const result = await apiClient.put<{ message: string }>(ENDPOINTS.auth.changePassword, {
      current_password: currentPassword,
      password: newPassword,
    });
    return result.message || 'Password updated';
  } catch (e: any) {
    return e.message || 'Failed to update password';
  }
}

export async function updateUserMetadata(data: Record<string, unknown>): Promise<Record<string, unknown> | null> {
  try {
    return await apiClient.put<Record<string, unknown>>(ENDPOINTS.profile.update, data);
  } catch (e: unknown) {
    console.error('Failed to update user metadata', e);
    return null;
  }
}

export async function signInWithEmail(params: SignInParams): Promise<AuthResult> {
  try {
    const result = await apiClient.post<any>(ENDPOINTS.auth.login, params);
    return { user: result.user, session: result.session };
  } catch (err: any) {
    return { user: null, session: null, error: err.message || 'Login failed' };
  }
}

export async function signInWithGoogle(): Promise<{ url?: string } | null> {
  try {
    const result = await apiClient.post<{ url?: string }>(ENDPOINTS.auth.google, {});
    return result;
  } catch (err) {
    return null;
  }
}

export async function signOut(): Promise<void> {
  try {
    await apiClient.post(ENDPOINTS.auth.logout, {});
  } catch {
    console.error('Sign-out API call failed');
  }
}

export async function getCurrentSession(): Promise<AuthSession | null> {
  const token = getApiToken();
  if (!token) return null;

  try {
    const result = await apiClient.post<{ user: UserProfile }>(ENDPOINTS.auth.verify, { token });
    return { access_token: token, user: result.user };
  } catch {
    return null;
  }
}

export async function getCurrentUser(): Promise<UserProfile | null> {
  const session = await getCurrentSession();
  return session?.user || null;
}
