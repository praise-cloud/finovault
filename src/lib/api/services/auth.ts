import { apiClient } from '../client';
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

export interface AuthResult {
  user: any;
  session: any;
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

export async function updateUserPassword(_password: string): Promise<string | null> {
  return null;
}

export async function updateUserMetadata(_data: Record<string, any>): Promise<string | null> {
  return null;
}

export async function signInWithEmail(params: SignInParams): Promise<AuthResult> {
  try {
    const result = await apiClient.post<any>(ENDPOINTS.auth.login, params);
    return { user: result.user, session: result.session };
  } catch (err: any) {
    return { user: null, session: null, error: err.message || 'Login failed' };
  }
}

export async function signInWithGoogle(): Promise<void> {
  try {
    const result = await apiClient.post<{ url?: string }>(ENDPOINTS.auth.google, {});
    if (result.url) {
      window.location.href = result.url;
    }
  } catch (err) {
    console.error('Google auth failed', err);
  }
}

export async function signOut(): Promise<void> {
  try {
    await apiClient.post(ENDPOINTS.auth.logout, {});
  } catch {
    // ignore
  }
}

export async function getCurrentSession(): Promise<any> {
  const { getApiToken } = await import('../client');
  const token = getApiToken();
  if (!token) return null;

  try {
    const result = await apiClient.post<{ user: any }>(ENDPOINTS.auth.verify, { token });
    return { access_token: token, user: result.user };
  } catch {
    return null;
  }
}

export async function getCurrentUser(): Promise<any> {
  const session = await getCurrentSession();
  return session?.user || null;
}
