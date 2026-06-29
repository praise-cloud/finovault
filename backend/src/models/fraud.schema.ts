import { z } from 'zod';

export const fraudCheckSchema = z.object({
  amount: z.number().positive(),
  merchant: z.string().optional(),
  category: z.string().optional(),
  location: z.string().optional(),
  device_id: z.string().optional(),
  receiver: z.string().optional(),
  receiver_account: z.string().optional(),
});

export const reportFraudSchema = z.object({
  event_type: z.string().min(1),
  description: z.string().min(1).max(1000),
  severity: z.enum(['info', 'warning', 'critical']).optional().default('info'),
  metadata: z.record(z.unknown()).optional(),
});
