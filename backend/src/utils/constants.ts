export const ROLES = ['individual', 'sme', 'entrepreneur', 'freelancer'] as const;

export const TRANSACTION_TYPES = ['income', 'expense', 'transfer'] as const;

export const TRANSACTION_CATEGORIES = [
  'food',
  'transport',
  'housing',
  'utilities',
  'entertainment',
  'shopping',
  'health',
  'education',
  'salary',
  'investment',
  'transfer',
  'business',
  'other',
] as const;

export const SEVERITIES = ['info', 'warning', 'critical'] as const;

export const GOAL_TYPES = ['rainy_day', 'general'] as const;

export const AI_SUGGESTION_STATUSES = ['active', 'dismissed', 'executed'] as const;

export const PLAN_TYPES = ['individual_starter', 'individual_pro', 'sme_starter', 'sme_pro'] as const;

export const PAGINATION = {
  DEFAULT_PAGE: 1,
  DEFAULT_LIMIT: 20,
  MAX_LIMIT: 100,
} as const;

export const API_PREFIX = '/api/v1';
