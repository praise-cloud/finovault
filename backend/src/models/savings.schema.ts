import { z } from 'zod';

export const createSavingsGoalSchema = z.object({
  name: z.string().min(1).max(200),
  target_amount: z.number().positive(),
  current_amount: z.number().min(0).optional().default(0),
  goal_type: z.enum(['rainy_day', 'general']).optional().default('general'),
});

export const updateSavingsGoalSchema = z.object({
  name: z.string().min(1).max(200).optional(),
  target_amount: z.number().positive().optional(),
  current_amount: z.number().min(0).optional(),
  status: z.enum(['active', 'completed', 'paused']).optional(),
});
