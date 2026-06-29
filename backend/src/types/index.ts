export type UserRole = 'individual' | 'sme' | 'entrepreneur' | 'freelancer';

export type TransactionType = 'income' | 'expense' | 'transfer';
export type TransactionStatus = 'pending' | 'completed' | 'flagged';

export type Severity = 'info' | 'warning' | 'critical';

export type SavingsGoalType = 'rainy_day' | 'general';
export type SavingsGoalStatus = 'active' | 'completed' | 'paused';

export type AISuggestionStatus = 'active' | 'dismissed' | 'executed';

export interface PaginationQuery {
  page?: number;
  limit?: number;
  offset?: number;
}

export interface PaginatedResponse<T> {
  data: T[];
  total: number;
  page: number;
  limit: number;
  has_more: boolean;
}

export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: {
    code: string;
    message: string;
  };
  meta?: {
    timestamp: string;
    version: string;
  };
}
