import { create } from 'zustand';
import { setApiToken, loadStoredToken, getApiToken } from '@/src/lib/api/client';
import * as AuthService from '@/src/lib/api/services/auth';

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
    set({ isLoading: true });
    try {
      const result = await AuthService.signUpWithEmail(params);
      if (result.error) { set({ isLoading: false }); return result.error; }
      if (result.session) setApiToken(result.session.access_token);
      set({ user: result.user, session: result.session, isAuthenticated: true, isLoading: false });
      return null;
    } catch (e: any) {
      set({ isLoading: false });
      return e.message || 'Sign up failed';
    }
  },

  signIn: async (params) => {
    set({ isLoading: true });
    try {
      const result = await AuthService.signInWithEmail(params);
      if (result.error) { set({ isLoading: false }); return result.error; }
      if (result.session) setApiToken(result.session.access_token);
      set({ user: result.user, session: result.session, isAuthenticated: true, isLoading: false });
      return null;
    } catch (e: any) {
      set({ isLoading: false });
      return e.message || 'Sign in failed';
    }
  },

  signInWithGoogle: async () => {
    set({ isLoading: true });
    try {
      const result = await AuthService.signInWithGoogle();
      if (result?.url) {
        const { Linking } = require('react-native');
        await Linking.openURL(result.url);
      }
    } catch (e) {
      console.warn('Google sign-in failed', e);
    }
    set({ isLoading: false });
  },

  signOut: async () => {
    set({ isLoading: true });
    try {
      await AuthService.signOut();
    } catch (e) {
      console.warn('Sign-out API call failed', e);
    }
    setApiToken(null);
    set({ user: null, session: null, isAuthenticated: false, isLoading: false });
  },

  setSession: (session) => {
    if (session) setApiToken(session.access_token);
    else setApiToken(null);
    set({ session, user: session?.user ?? null, isAuthenticated: !!session });
  },
  setAvatarUri: (uri) => set({ avatarUri: uri }),
}));
