import { apiClient } from '../client';
import { ENDPOINTS } from '../endpoints';

export interface Transaction {
  id: string;
  user_id: string;
  type: 'income' | 'expense' | 'transfer';
  amount: number;
  description: string;
  category: string | null;
  merchant: string | null;
  date: string;
  status: 'pending' | 'completed' | 'flagged';
  created_at: string;
  updated_at: string;
}

interface TransactionListResponse {
  data: Transaction[];
  total: number;
  page: number;
  limit: number;
  has_more: boolean;
}

interface CreateTransactionInput {
  type: 'income' | 'expense' | 'transfer';
  amount: number;
  description: string;
  category?: string;
  merchant?: string;
  date?: string;
}

interface UpdateTransactionInput {
  type?: 'income' | 'expense' | 'transfer';
  amount?: number;
  description?: string;
  category?: string;
  merchant?: string;
  status?: 'pending' | 'completed' | 'flagged';
}

export async function listTransactions(params?: {
  page?: number;
  limit?: number;
  type?: string;
  category?: string;
  start_date?: string;
  end_date?: string;
  status?: string;
}, options?: { signal?: AbortSignal }): Promise<TransactionListResponse> {
  const query = params ? '?' + new URLSearchParams(
    Object.fromEntries(Object.entries(params).filter(([_, v]) => v != null).map(([k, v]) => [k, String(v)]))
  ).toString() : '';
  return apiClient.get<TransactionListResponse>(`${ENDPOINTS.transactions.list}${query}`, options);
}

export async function getTransaction(id: string): Promise<Transaction> {
  return apiClient.get<Transaction>(ENDPOINTS.transactions.detail(id));
}

export async function createTransaction(input: CreateTransactionInput): Promise<Transaction> {
  return apiClient.post<Transaction>(ENDPOINTS.transactions.create, input);
}

export async function updateTransaction(id: string, input: UpdateTransactionInput): Promise<Transaction> {
  return apiClient.put<Transaction>(ENDPOINTS.transactions.update(id), input);
}

export async function deleteTransaction(id: string): Promise<void> {
  return apiClient.delete(ENDPOINTS.transactions.delete(id));
}
