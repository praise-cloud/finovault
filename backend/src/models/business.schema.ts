import { z } from 'zod';

export const businessAdviceSchema = z.object({
  question: z.string().min(1).max(2000),
  business_data: z.record(z.unknown()).optional(),
});
