import { z } from 'zod';
import { ROLES } from '../utils/constants';

export const signupSchema = z.object({
  email: z.string().email('Invalid email address'),
  password: z.string().min(8, 'Password must be at least 8 characters'),
  full_name: z.string().min(1, 'Full name is required').max(100),
  phone: z.string().optional(),
});

export const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(1, 'Password is required'),
});

export const updateProfileSchema = z.object({
  full_name: z.string().min(1).max(100).optional(),
  phone: z.string().optional(),
  avatar_url: z.string().url().optional(),
});

export const updatePreferencesSchema = z.object({
  role: z.enum(ROLES).optional(),
  goals: z.array(z.string()).optional(),
  ai_insights_enabled: z.boolean().optional(),
  security_alerts_enabled: z.boolean().optional(),
});

export type SignupInput = z.infer<typeof signupSchema>;
export type LoginInput = z.infer<typeof loginSchema>;
export type UpdateProfileInput = z.infer<typeof updateProfileSchema>;
export type UpdatePreferencesInput = z.infer<typeof updatePreferencesSchema>;
