import { create } from 'zustand';
import { setApiToken } from '@/lib/api/client';
import * as AuthService from '@/lib/api/services/auth';

interface AuthState {
  user: any | null;
  session: any | null;
  isLoading: boolean;
  isAuthenticated: boolean;
  pendingPassword: string | null;
  pendingUserData: { full_name: string; phone?: string } | null;

  initialize: () => Promise<void>;
  signUp: (params: AuthService.SignUpParams) => Promise<string | null>;
  signIn: (params: AuthService.SignInParams) => Promise<string | null>;
  signInWithGoogle: () => Promise<void>;
  signOut: () => Promise<void>;
  verifyOtp: (email: string, token: string) => Promise<string | null>;
  resendOtp: (email: string) => Promise<string | null>;
  setSession: (session: any) => void;
}

export const useAuthStore = create<AuthState>((set, get) => ({
  user: null,
  session: null,
  isLoading: true,
  isAuthenticated: false,
  pendingPassword: null,
  pendingUserData: null,

  initialize: async () => {
    try {
      const session = await AuthService.getCurrentSession();
      if (session) {
        setApiToken(session.access_token);
        set({ user: session.user, session, isAuthenticated: true, isLoading: false });
      } else {
        set({ isLoading: false });
      }
    } catch {
      set({ isLoading: false });
    }
  },

  signUp: async (params) => {
    const error = await AuthService.sendSignUpOtp(params);
    if (error) return error;
    set({
      user: { email: params.email, user_metadata: { full_name: params.fullName, phone: params.phone } },
      isAuthenticated: false,
      pendingPassword: params.password,
      pendingUserData: { full_name: params.fullName, phone: params.phone },
    });
    return null;
  },

  signIn: async (params) => {
    const result = await AuthService.signInWithEmail(params);
    if (result.error) return result.error;
    if (result.session) setApiToken(result.session.access_token);
    set({ user: result.user, session: result.session, isAuthenticated: true });
    return null;
  },

  signInWithGoogle: async () => {
    await AuthService.signInWithGoogle();
  },

  signOut: async () => {
    await AuthService.signOut();
    setApiToken(null);
    set({ user: null, session: null, isAuthenticated: false });
  },

  verifyOtp: async (email, token) => {
    const { pendingPassword, pendingUserData } = get();

    const result = await AuthService.verifyOtp(email, token, pendingPassword || undefined, pendingUserData || undefined);
    if (result.error) return result.error;
    if (result.session) setApiToken(result.session.access_token);
    set({ user: result.user, session: result.session, isAuthenticated: true, pendingPassword: null, pendingUserData: null });
    return null;
  },

  resendOtp: async (email) => {
    return AuthService.resendOtp(email);
  },

  setSession: (session) => {
    if (session) setApiToken(session.access_token);
    else setApiToken(null);
    set({ session, user: session?.user ?? null, isAuthenticated: !!session });
  },
}));
