import { z } from 'zod';

export const uuidSchema = z.string().uuid();

export const paginationSchema = z.object({
  page: z.coerce.number().int().positive().optional().default(1),
  limit: z.coerce.number().int().positive().max(100).optional().default(20),
});

export const timestampSchema = z.string().datetime();

export const idParamSchema = z.object({
  id: z.string().uuid(),
});
