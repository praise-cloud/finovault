import { getSupabase } from '../config/supabase';
import { createContextLogger } from '../utils/logger';

const log = createContextLogger('AIService');

export async function getInsights(userId: string) {
  const supabase = getSupabase();

  const { data, error } = await supabase
    .from('ai_suggestions')
    .select('*')
    .eq('user_id', userId)
    .eq('status', 'active')
    .order('created_at', { ascending: false })
    .limit(5);

  if (error) {
    log.error('Get insights failed', { userId, error: error.message });
    return [];
  }

  return data || [];
}

export async function askCoach(userId: string, question: string, context?: Record<string, unknown>) {
  const supabase = getSupabase();

  const [profileRes, txRes, savingsRes] = await Promise.all([
    supabase.from('profiles').select('*').eq('id', userId).single(),
    supabase.from('transactions').select('*').eq('user_id', userId).order('date', { ascending: false }).limit(30),
    supabase.from('savings_goals').select('*').eq('user_id', userId),
  ]);

  const profile = profileRes.data;
  const transactions = txRes.data || [];
  const savingsGoals = savingsRes.data || [];

  await supabase.from('ai_conversations').insert({
    user_id: userId,
    session_id: crypto.randomUUID ? crypto.randomUUID() : userId + Date.now().toString(),
    role: 'user',
    content: question,
    context: { ...context, transaction_count: transactions.length },
  });

  const response = generateCoachResponse(question, profile, transactions, savingsGoals);

  return {
    answer: response,
    context: {
      recent_transactions: transactions.slice(0, 5),
      total_savings_goals: savingsGoals.length,
    },
  };
}

function generateCoachResponse(question: string, _profile: any, transactions: any[], savingsGoals: any[]): string {
  const q = question.toLowerCase();

  if (q.includes('save') || q.includes('saving')) {
    const totalSavings = savingsGoals.reduce((s: number, g: any) => s + Number(g.current_amount), 0);
    return `Great question! Based on your activity, you've saved $${totalSavings.toLocaleString()} so far. ` +
      `I recommend setting aside 20% of your income each month. Even small amounts add up over time. ` +
      `Would you like me to suggest a personalized savings plan?`;
  }

  if (q.includes('spend') || q.includes('spending')) {
    const totalSpent = transactions
      .filter((t: any) => t.type === 'expense')
      .reduce((s: number, t: any) => s + Number(t.amount), 0);
    return `Your recent spending totals $${totalSpent.toLocaleString()}. ` +
      `I've noticed some patterns that might help you optimize. The key areas are typically food, transport, and subscriptions. ` +
      `Would you like a detailed breakdown?`;
  }

  if (q.includes('invest') || q.includes('investment')) {
    return `Investing is a powerful way to build wealth. Based on your profile, a diversified portfolio with ` +
      `a mix of equities (60%), fixed income (25%), and alternative assets (15%) could be a good starting point. ` +
      `Would you like me to help you set up an investment plan?`;
  }

  if (q.includes('budget') || q.includes('budgeting')) {
    return `Budgeting is the foundation of financial health. I recommend the 50/30/20 rule: ` +
      `50% for needs, 30% for wants, and 20% for savings and investments. ` +
      `Would you like me to help you create a custom budget based on your income and expenses?`;
  }

  if (q.includes('debt') || q.includes('loan')) {
    return `Managing debt is important for financial health. Consider the avalanche method (paying highest interest first) ` +
      `or the snowball method (paying smallest balances first). ` +
      `Would you like me to help you create a debt repayment strategy?`;
  }

  return `That's a great question about "${question}". Based on your financial profile and recent activity, ` +
    `I'd recommend tracking your expenses regularly and setting clear financial goals. ` +
    `Is there a specific area of your finances you'd like to focus on?`;
}

export async function getMorningBriefing(userId: string) {
  const supabase = getSupabase();

  const today = new Date().toISOString().split('T')[0];

  const { data } = await supabase
    .from('morning_briefings')
    .select('*')
    .eq('user_id', userId)
    .eq('briefing_date', today)
    .single();

  if (data) {
    return data;
  }

  return {
    briefing_date: today,
    title: 'Good morning!',
    content: 'Here is your daily financial overview. Your accounts are secure and all transactions are processing normally.',
    action_items: [],
    read: false,
  };
}

export async function getSuggestions(userId: string) {
  const supabase = getSupabase();

  const { data, error } = await supabase
    .from('ai_suggestions')
    .select('*')
    .eq('user_id', userId)
    .order('created_at', { ascending: false })
    .limit(20);

  if (error) {
    log.error('Get suggestions failed', { userId, error: error.message });
    return [];
  }

  return data || [];
}

export async function updateSuggestion(userId: string, suggestionId: string, input: { status?: string }) {
  const supabase = getSupabase();

  const { data, error } = await supabase
    .from('ai_suggestions')
    .update({ status: input.status || 'dismissed' })
    .eq('id', suggestionId)
    .eq('user_id', userId)
    .select()
    .single();

  if (error) {
    log.error('Update suggestion failed', { userId, suggestionId, error: error.message });
    throw new Error('Failed to update suggestion');
  }

  return data;
}
