jest.mock('../../src/config/env', () => ({
  env: {
    SUPABASE_URL: 'https://test.supabase.co',
    SUPABASE_SERVICE_KEY: 'test-service-key',
    SUPABASE_JWT_SECRET: 'test-secret',
    AI_SERVICE_KEY: 'test-ai-key',
    PYTHON_AI_URL: 'http://test-ai:8000',
    FRONTEND_URL: 'http://localhost:8081',
  },
}));

jest.mock('../../src/config/supabase', () => {
  const mockAdmin = {
    createUser: jest.fn(),
    getUserById: jest.fn(),
    updateUserById: jest.fn(),
    signOut: jest.fn(),
  };
  const mockSupabase = {
    auth: {
      admin: mockAdmin,
      getUser: jest.fn(),
      signInWithPassword: jest.fn(),
      signInWithIdToken: jest.fn(),
      signInWithOAuth: jest.fn(),
      refreshSession: jest.fn(),
      resetPasswordForEmail: jest.fn(),
      verifyOtp: jest.fn(),
      updateUser: jest.fn(),
    },
  };
  const mockAuthClient = {
    auth: {
      signInWithPassword: jest.fn(),
      signInWithIdToken: jest.fn(),
      signInWithOAuth: jest.fn(),
      refreshSession: jest.fn(),
      resetPasswordForEmail: jest.fn(),
      verifyOtp: jest.fn(),
      updateUser: jest.fn(),
    },
  };
  return {
    getSupabase: jest.fn(() => mockSupabase),
    getAuthClient: jest.fn(() => mockAuthClient),
    __mockAdmin: mockAdmin,
    __mockSupabase: mockSupabase,
    __mockAuthClient: mockAuthClient,
  };
});

import * as authService from '../../src/services/auth.service';
import * as supabaseModule from '../../src/config/supabase';

const { __mockAdmin, __mockSupabase, __mockAuthClient } = supabaseModule as any;

describe('AuthService', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('signup', () => {
    it('creates user via admin API and signs in', async () => {
      __mockAdmin.createUser.mockResolvedValueOnce({ data: { user: { id: 'u1' } }, error: null });
      __mockAuthClient.auth.signInWithPassword.mockResolvedValueOnce({
        data: { user: { id: 'u1' }, session: { access_token: 'tok' } },
        error: null,
      });

      const result = await authService.signup({
        email: 'test@test.com',
        password: 'pass123',
        full_name: 'Test User',
      });

      expect(__mockAdmin.createUser).toHaveBeenCalledWith(
        expect.objectContaining({ email: 'test@test.com' }),
      );
      expect(__mockAuthClient.auth.signInWithPassword).toHaveBeenCalledWith({
        email: 'test@test.com',
        password: 'pass123',
      });
      expect(result.session!.access_token).toBe('tok');
    });

    it('throws ConflictError on duplicate email', async () => {
      __mockAdmin.createUser.mockResolvedValueOnce({
        data: null,
        error: { message: 'already registered' },
      });

      await expect(authService.signup({ email: 'dup@test.com', password: 'p', full_name: 'Dup' }))
        .rejects.toThrow('Email already registered');
    });
  });

  describe('login', () => {
    it('returns user and session on success', async () => {
      __mockAuthClient.auth.signInWithPassword.mockResolvedValueOnce({
        data: { user: { id: 'u1' }, session: { access_token: 'tok' } },
        error: null,
      });

      const result = await authService.login({ email: 'a@b.com', password: 'p' });
      expect(result.user.id).toBe('u1');
      expect(result.session.access_token).toBe('tok');
    });

    it('throws UnauthorizedError on wrong credentials', async () => {
      __mockAuthClient.auth.signInWithPassword.mockResolvedValueOnce({
        data: { user: null, session: null },
        error: { message: 'Invalid credentials' },
      });

      await expect(authService.login({ email: 'a@b.com', password: 'wrong' }))
        .rejects.toThrow('Invalid email or password');
    });
  });

  describe('changePassword', () => {
    it('verifies current password, updates, then signs out', async () => {
      __mockAdmin.getUserById.mockResolvedValueOnce({
        data: { user: { id: 'u1', email: 'user@test.com' } },
        error: null,
      });
      __mockAuthClient.auth.signInWithPassword.mockResolvedValueOnce({
        data: { user: { id: 'u1' } },
        error: null,
      });
      __mockAdmin.updateUserById.mockResolvedValueOnce({ data: { user: { id: 'u1' } }, error: null });
      __mockAdmin.signOut.mockResolvedValueOnce({ error: null });

      const result = await authService.changePassword('u1', 'oldPass', 'newPass');
      expect(result.message).toBe('Password changed successfully');
      expect(__mockAdmin.signOut).toHaveBeenCalledWith('u1');
    });

    it('throws if current password is wrong', async () => {
      __mockAdmin.getUserById.mockResolvedValueOnce({
        data: { user: { id: 'u1', email: 'user@test.com' } },
        error: null,
      });
      __mockAuthClient.auth.signInWithPassword.mockResolvedValueOnce({
        data: { user: null },
        error: { message: 'Invalid credentials' },
      });

      await expect(authService.changePassword('u1', 'wrong', 'newPass'))
        .rejects.toThrow('Current password is incorrect');
    });

    it('throws UnauthorizedError when user not found', async () => {
      __mockAdmin.getUserById.mockResolvedValueOnce({
        data: { user: null },
        error: { message: 'Not found' },
      });

      await expect(authService.changePassword('u-missing', 'old', 'new'))
        .rejects.toThrow('User not found');
    });
  });

  describe('verifySession', () => {
    it('returns user for valid token', async () => {
      __mockSupabase.auth.getUser.mockResolvedValueOnce({
        data: { user: { id: 'u1' } },
        error: null,
      });

      const result = await authService.verifySession('valid-token');
      expect(result.user.id).toBe('u1');
    });

    it('throws on invalid token', async () => {
      __mockSupabase.auth.getUser.mockResolvedValueOnce({
        data: { user: null },
        error: { message: 'Invalid token' },
      });

      await expect(authService.verifySession('bad-token')).rejects.toThrow('Invalid or expired session');
    });
  });

  describe('logout', () => {
    it('signs out user via admin API', async () => {
      __mockAdmin.signOut.mockResolvedValueOnce({ error: null });
      await authService.logout('u1');
      expect(__mockAdmin.signOut).toHaveBeenCalledWith('u1');
    });
  });

  describe('forgotPassword', () => {
    it('sends reset email with redirect URL', async () => {
      __mockAuthClient.auth.resetPasswordForEmail.mockResolvedValueOnce({ error: null });
      const result = await authService.forgotPassword('test@test.com');
      expect(result.message).toBe('Password reset email sent');
      expect(__mockAuthClient.auth.resetPasswordForEmail).toHaveBeenCalledWith(
        'test@test.com',
        expect.objectContaining({ redirectTo: 'http://localhost:8081/reset-password' }),
      );
    });
  });
});
