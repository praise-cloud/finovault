import { z } from 'zod';

export const askCoachSchema = z.object({
  question: z.string().min(1).max(2000),
  context: z.record(z.unknown()).optional(),
});

export const financialInterviewSchema = z.object({
  employment_status: z.enum(['employed', 'self-employed', 'business-owner', 'freelancer', 'unemployed']),
  income_range: z.string().optional(),
  pay_frequency: z.enum(['weekly', 'biweekly', 'monthly', 'irregular']).optional(),
  has_business: z.boolean().optional(),
  marital_status: z.enum(['single', 'married', 'divorced', 'widowed']).optional(),
  has_children: z.boolean().optional(),
  children_count: z.number().int().min(0).optional(),
  financial_goals: z.array(z.string()).optional(),
  money_fears: z.array(z.string()).optional(),
  saves_money: z.boolean().optional(),
  invests: z.boolean().optional(),
  has_loans: z.boolean().optional(),
  risk_tolerance: z.enum(['low', 'moderate', 'high']).optional(),
});
