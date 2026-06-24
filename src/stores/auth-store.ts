import { create } from 'zustand';
import { supabase } from '@/lib/supabase';
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
        const user = await AuthService.getCurrentUser();
        set({ user, session, isAuthenticated: true, isLoading: false });
      } else {
        set({ isLoading: false });
      }
    } catch {
      set({ isLoading: false });
    }

    supabase.auth.onAuthStateChange((_event, session) => {
      if (session) {
        set({ session, user: session.user, isAuthenticated: true });
      } else {
        set({ session: null, user: null, isAuthenticated: false });
      }
    });
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
    set({ user: result.user, session: result.session, isAuthenticated: true });
    return null;
  },

  signInWithGoogle: async () => {
    await AuthService.signInWithGoogle();
  },

  signOut: async () => {
    await AuthService.signOut();
    set({ user: null, session: null, isAuthenticated: false });
  },

  verifyOtp: async (email, token) => {
    const { pendingPassword, pendingUserData } = get();
    const result = await AuthService.verifyOtp(email, token);
    if (result.error) return result.error;
    set({ user: result.user, session: result.session, isAuthenticated: true });

    if (pendingPassword) {
      const pwError = await AuthService.updateUserPassword(pendingPassword);
      if (pwError) console.warn('Failed to set password:', pwError);
    }

    if (pendingUserData) {
      const mdError = await AuthService.updateUserMetadata(pendingUserData);
      if (mdError) console.warn('Failed to set user metadata:', mdError);
    }

    set({ pendingPassword: null, pendingUserData: null });

    return null;
  },

  resendOtp: async (email) => {
    return AuthService.resendOtp(email);
  },

  setSession: (session) => {
    set({ session, user: session?.user ?? null, isAuthenticated: !!session });
  },
}));
