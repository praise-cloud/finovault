import { z } from 'zod';

export const createTransactionSchema = z.object({
  type: z.enum(['income', 'expense', 'transfer']),
  amount: z.number().positive('Amount must be positive'),
  description: z.string().min(1).max(500),
  category: z.string().optional(),
  merchant: z.string().optional(),
  date: z.string().datetime().optional(),
});

export const updateTransactionSchema = z.object({
  type: z.enum(['income', 'expense', 'transfer']).optional(),
  amount: z.number().positive().optional(),
  description: z.string().min(1).max(500).optional(),
  category: z.string().optional(),
  merchant: z.string().optional(),
  status: z.enum(['pending', 'completed', 'flagged']).optional(),
});

export const transactionQuerySchema = z.object({
  page: z.coerce.number().int().positive().optional().default(1),
  limit: z.coerce.number().int().positive().max(100).optional().default(20),
  type: z.enum(['income', 'expense', 'transfer']).optional(),
  category: z.string().optional(),
  start_date: z.string().datetime().optional(),
  end_date: z.string().datetime().optional(),
  status: z.enum(['pending', 'completed', 'flagged']).optional(),
});

export type CreateTransactionInput = z.infer<typeof createTransactionSchema>;
export type UpdateTransactionInput = z.infer<typeof updateTransactionSchema>;
