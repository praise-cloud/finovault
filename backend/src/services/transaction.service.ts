import { getSupabase } from '../config/supabase';
import { NotFoundError } from '../utils/errors';
import { createContextLogger } from '../utils/logger';

const log = createContextLogger('TransactionService');

export async function listTransactions(userId: string, options: {
  page: number; limit: number; offset: number;
  type?: string; category?: string; status?: string;
  start_date?: string; end_date?: string;
}) {
  const supabase = getSupabase();

  let query = supabase
    .from('transactions')
    .select('*', { count: 'exact' })
    .eq('user_id', userId)
    .order('date', { ascending: false });

  if (options.type) query = query.eq('type', options.type);
  if (options.category) query = query.eq('category', options.category);
  if (options.status) query = query.eq('status', options.status);
  if (options.start_date) query = query.gte('date', options.start_date);
  if (options.end_date) query = query.lte('date', options.end_date);

  const { data, error, count } = await query
    .range(options.offset, options.offset + options.limit - 1);

  if (error) {
    log.error('List transactions failed', { userId, error: error.message });
    return { data: [], total: 0, page: options.page, limit: options.limit, has_more: false };
  }

  return {
    data: data || [],
    total: count || 0,
    page: options.page,
    limit: options.limit,
    has_more: (count || 0) > options.offset + options.limit,
  };
}

export async function getTransaction(userId: string, transactionId: string) {
  const supabase = getSupabase();

  const { data, error } = await supabase
    .from('transactions')
    .select('*')
    .eq('id', transactionId)
    .eq('user_id', userId)
    .single();

  if (error || !data) {
    throw new NotFoundError('Transaction');
  }

  return data;
}

export async function createTransaction(userId: string, input: {
  type: string; amount: number; description: string;
  category?: string; merchant?: string; date?: string;
}) {
  const supabase = getSupabase();

  const { data, error } = await supabase
    .from('transactions')
    .insert({
      user_id: userId,
      type: input.type,
      amount: input.amount,
      description: input.description,
      category: input.category || null,
      merchant: input.merchant || null,
      date: input.date || new Date().toISOString(),
      status: 'completed',
    })
    .select()
    .single();

  if (error) {
    log.error('Create transaction failed', { userId, error: error.message });
    throw new Error('Failed to create transaction');
  }

  return data;
}

export async function updateTransaction(userId: string, transactionId: string, input: Record<string, any>) {
  const supabase = getSupabase();

  const { data, error } = await supabase
    .from('transactions')
    .update({ ...input, updated_at: new Date().toISOString() })
    .eq('id', transactionId)
    .eq('user_id', userId)
    .select()
    .single();

  if (error) {
    throw new NotFoundError('Transaction');
  }

  return data;
}

export async function deleteTransaction(userId: string, transactionId: string): Promise<void> {
  const supabase = getSupabase();

  const { error } = await supabase
    .from('transactions')
    .delete()
    .eq('id', transactionId)
    .eq('user_id', userId);

  if (error) {
    throw new NotFoundError('Transaction');
  }
}
