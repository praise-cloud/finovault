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

export async function sendSignUpOtp(params: Omit<SignUpParams, 'password'>): Promise<string | null> {
  try {
    await apiClient.post(ENDPOINTS.auth.sendOtp, {
      email: params.email,
      full_name: params.fullName,
      phone: params.phone,
    });
    return null;
  } catch (err: any) {
    return err.message || 'Failed to send verification code';
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

export async function verifyOtp(email: string, token: string, password?: string, userData?: { full_name?: string; phone?: string }): Promise<AuthResult> {
  try {
    const result = await apiClient.post<any>(ENDPOINTS.auth.verifyOtp, {
      email,
      token,
      password,
      ...(userData || {}),
    });
    return { user: result.user, session: result.session };
  } catch (err: any) {
    return { user: null, session: null, error: err.message || 'Verification failed' };
  }
}

export async function resendOtp(email: string): Promise<string | null> {
  try {
    await apiClient.post(ENDPOINTS.auth.sendOtp, { email, full_name: '' });
    return null;
  } catch (err: any) {
    return err.message || 'Failed to resend code';
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
