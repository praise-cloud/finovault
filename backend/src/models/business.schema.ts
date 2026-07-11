import { z } from 'zod';

export const businessAdviceSchema = z.object({
  question: z.string().min(1).max(2000),
  business_data: z.record(z.unknown()).optional(),
});

export const createVendorSchema = z.object({
  name: z.string().min(1).max(200),
  category: z.string().max(100).optional().default(''),
  monthly_spend: z.number().min(0).optional().default(0),
  health_score: z.number().min(0).max(100).optional().default(50),
});

export const updateVendorSchema = z.object({
  name: z.string().min(1).max(200).optional(),
  category: z.string().max(100).optional(),
  monthly_spend: z.number().min(0).optional(),
  health_score: z.number().min(0).max(100).optional(),
});
