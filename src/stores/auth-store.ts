import { create } from 'zustand';
import { setApiToken, loadStoredToken, getApiToken } from '@/lib/api/client';
import * as AuthService from '@/lib/api/services/auth';

interface AuthState {
  user: any | null;
  session: any | null;
  isLoading: boolean;
  isAuthenticated: boolean;
  avatarUri: string | null;

  initialize: () => Promise<void>;
  signUp: (params: AuthService.SignUpParams) => Promise<string | null>;
  signIn: (params: AuthService.SignInParams) => Promise<string | null>;
  signInWithGoogle: () => Promise<void>;
  signOut: () => Promise<void>;
  setSession: (session: any) => void;
  setAvatarUri: (uri: string | null) => void;
}

export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  session: null,
  isLoading: true,
  isAuthenticated: false,
  avatarUri: null,

  initialize: async () => {
    try {
      const storedToken = await loadStoredToken();
      if (!storedToken || !getApiToken()) {
        set({ isLoading: false });
        return;
      }
      const session = await AuthService.getCurrentSession();
      if (session) {
        set({ user: session.user, session, isAuthenticated: true, isLoading: false });
      } else {
        await setApiToken(null);
        set({ isLoading: false });
      }
    } catch {
      await setApiToken(null);
      set({ isLoading: false });
    }
  },

  signUp: async (params) => {
    try {
      const result = await AuthService.signUpWithEmail(params);
      if (result.error) return result.error;
      if (result.session) setApiToken(result.session.access_token);
      set({ user: result.user, session: result.session, isAuthenticated: true });
      return null;
    } catch (e: any) {
      return e.message || 'Sign up failed';
    }
  },

  signIn: async (params) => {
    try {
      const result = await AuthService.signInWithEmail(params);
      if (result.error) return result.error;
      if (result.session) setApiToken(result.session.access_token);
      set({ user: result.user, session: result.session, isAuthenticated: true });
      return null;
    } catch (e: any) {
      return e.message || 'Sign in failed';
    }
  },

  signInWithGoogle: async () => {
    try {
      await AuthService.signInWithGoogle();
    } catch {}
  },

  signOut: async () => {
    await AuthService.signOut();
    setApiToken(null);
    set({ user: null, session: null, isAuthenticated: false });
  },

  setSession: (session) => {
    if (session) setApiToken(session.access_token);
    else setApiToken(null);
    set({ session, user: session?.user ?? null, isAuthenticated: !!session });
  },
  setAvatarUri: (uri) => set({ avatarUri: uri }),
}));
