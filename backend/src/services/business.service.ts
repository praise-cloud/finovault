import { getSupabase } from '../config/supabase';
import { createContextLogger } from '../utils/logger';

const log = createContextLogger('BusinessService');

export async function getHealth(userId: string) {
  const supabase = getSupabase();

  const [txRes, vendorRes] = await Promise.all([
    supabase.from('transactions').select('*').eq('user_id', userId).limit(50),
    supabase.from('vendors').select('*').eq('user_id', userId),
  ]);

  const transactions = txRes.data || [];
  const vendors = vendorRes.data || [];

  const totalRevenue = transactions
    .filter((t: any) => t.type === 'income')
    .reduce((s: number, t: any) => s + Number(t.amount), 0);

  const totalExpenses = transactions
    .filter((t: any) => t.type === 'expense')
    .reduce((s: number, t: any) => s + Number(t.amount), 0);

  const profit = totalRevenue - totalExpenses;
  const profitMargin = totalRevenue > 0 ? (profit / totalRevenue) * 100 : 0;

  const vendorHealth = vendors.length > 0
    ? vendors.reduce((s: number, v: any) => s + (v.health_score || 50), 0) / vendors.length
    : 0;

  return {
    revenue: totalRevenue || 0,
    expenses: totalExpenses || 0,
    profit: profit || 0,
    profit_margin: Math.round(profitMargin * 10) / 10,
    revenue_trend: 0,
    expense_trend: 0,
    vendor_count: vendors.length,
    vendor_health_average: Math.round(vendorHealth),
    overall_health_score: calculateHealthScore(profitMargin, vendorHealth),
  };
}

function calculateHealthScore(profitMargin: number, vendorHealth: number): number {
  const marginScore = Math.min(50, Math.max(0, (profitMargin / 20) * 50));
  const vendorScore = Math.min(50, vendorHealth / 2);
  return Math.round(marginScore + vendorScore);
}

export async function getForecast(userId: string) {
  const supabase = getSupabase();

  const { data } = await supabase
    .from('transactions')
    .select('*')
    .eq('user_id', userId)
    .order('date', { ascending: false })
    .limit(90);

  const transactions = data || [];
  const revenue = transactions.filter((t: any) => t.type === 'income');
  const expenses = transactions.filter((t: any) => t.type === 'expense');

  const avgRevenue = revenue.length > 0
    ? revenue.reduce((s: number, t: any) => s + Number(t.amount), 0) / revenue.length
    : 0;

  const avgExpenses = expenses.length > 0
    ? expenses.reduce((s: number, t: any) => s + Number(t.amount), 0) / expenses.length
    : 0;

  const netMonthly = avgRevenue - avgExpenses;
  const cashReserves = Math.max(0, netMonthly * 3);
  const runway = avgExpenses > 0 ? Math.round(cashReserves / avgExpenses) : 0;

  return {
    monthly_avg_revenue: Math.round(avgRevenue),
    monthly_avg_expenses: Math.round(avgExpenses),
    net_monthly: Math.round(netMonthly),
    cash_reserves: cashReserves,
    runway_months: runway,
    forecast: generateForecast(avgRevenue, avgExpenses),
    recommendation: runway < 6
      ? 'Your cash runway is less than 6 months. Consider reducing expenses or increasing revenue.'
      : 'Your business is in a healthy position with sufficient cash runway.',
  };
}

function generateForecast(avgRevenue: number, avgExpenses: number): number[] {
  const net = avgRevenue - avgExpenses;
  const forecast: number[] = [];
  let current = 0;

  for (let i = 0; i < 6; i++) {
    current += net;
    forecast.push(Math.round(current));
  }

  return forecast;
}

export async function listVendors(userId: string) {
  const supabase = getSupabase();

  const { data, error } = await supabase
    .from('vendors')
    .select('*')
    .eq('user_id', userId)
    .order('monthly_spend', { ascending: false });

  if (error) {
    log.error('List vendors failed', { userId, error: error.message });
    return [];
  }

  return { vendors: data || [] };
}

export async function addVendor(userId: string, input: { name: string; category?: string; monthly_spend?: number; health_score?: number }) {
  const supabase = getSupabase();

  const { data, error } = await supabase
    .from('vendors')
    .insert({
      user_id: userId,
      name: input.name,
      category: input.category || '',
      monthly_spend: input.monthly_spend || 0,
      health_score: input.health_score ?? 50,
    })
    .select()
    .single();

  if (error) {
    log.error('Add vendor failed', { userId, error: error.message });
    throw error;
  }

  return data;
}

export async function updateVendor(userId: string, vendorId: string, input: Record<string, any>) {
  const supabase = getSupabase();

  const { data, error } = await supabase
    .from('vendors')
    .update(input)
    .eq('id', vendorId)
    .eq('user_id', userId)
    .select()
    .single();

  if (error) {
    log.error('Update vendor failed', { userId, vendorId, error: error.message });
    throw error;
  }

  return data;
}

export async function deleteVendor(userId: string, vendorId: string) {
  const supabase = getSupabase();

  const { error } = await supabase
    .from('vendors')
    .delete()
    .eq('id', vendorId)
    .eq('user_id', userId);

  if (error) {
    log.error('Delete vendor failed', { userId, vendorId, error: error.message });
    throw error;
  }
}

export async function getAiAdvice(userId: string, question: string, _businessData?: Record<string, unknown>) {
  const supabase = getSupabase();

  const [txRes, vendorRes] = await Promise.all([
    supabase.from('transactions').select('*').eq('user_id', userId).limit(50),
    supabase.from('vendors').select('*').eq('user_id', userId),
  ]);

  const revenue = (txRes.data || [])
    .filter((t: any) => t.type === 'income')
    .reduce((s: number, t: any) => s + Number(t.amount), 0);

  const expenses = (txRes.data || [])
    .filter((t: any) => t.type === 'expense')
    .reduce((s: number, t: any) => s + Number(t.amount), 0);

  const vendors = vendorRes.data || [];

  const q = question.toLowerCase();
  let answer: string;

  if (q.includes('profit') || q.includes('revenue') || q.includes('growth')) {
    const margin = revenue > 0 ? ((revenue - expenses) / revenue * 100).toFixed(1) : '0';
    answer = `Your current revenue is $${revenue.toLocaleString()} with expenses of $${expenses.toLocaleString()}. ` +
      `Your profit margin is ${margin}%. ` +
      (parseFloat(margin) < 20 ? 'Consider optimizing vendor costs or adjusting pricing.' : 'Your margins look healthy.');
  } else if (q.includes('vendor') || q.includes('supplier')) {
    answer = `You have ${vendors.length} vendors. ` +
      (vendors.length > 0
        ? `Your top vendor is ${vendors[0].name} with monthly spend of $${Number(vendors[0].monthly_spend).toLocaleString()}.`
        : 'Consider diversifying your supplier base.');
  } else if (q.includes('cash') || q.includes('runway')) {
    const monthlyAvg = expenses / 3;
    const runway = monthlyAvg > 0 ? Math.round((100000) / monthlyAvg) : 12;
    answer = `Your estimated cash runway is approximately ${runway} months based on current spending patterns.`;
  } else {
    answer = `Based on your business data, revenue is $${revenue.toLocaleString()} and you have ${vendors.length} active vendors. ` +
      `Your expense-to-revenue ratio is ${revenue > 0 ? ((expenses / revenue) * 100).toFixed(1) : 'N/A'}%.`;
  }

  return {
    question,
    answer,
    context: {
      revenue,
      expenses,
      vendor_count: vendors.length,
    },
  };
}

export async function getExistingAdvice(userId: string) {
  const supabase = getSupabase();

  const [txRes, vendorRes] = await Promise.all([
    supabase.from('transactions').select('*').eq('user_id', userId).limit(50),
    supabase.from('vendors').select('*').eq('user_id', userId),
  ]);

  const revenue = (txRes.data || [])
    .filter((t: any) => t.type === 'income')
    .reduce((s: number, t: any) => s + Number(t.amount), 0);

  const expenses = (txRes.data || [])
    .filter((t: any) => t.type === 'expense')
    .reduce((s: number, t: any) => s + Number(t.amount), 0);

  const vendors = vendorRes.data || [];

  return {
    summary: `Your business has $${revenue.toLocaleString()} in revenue and $${expenses.toLocaleString()} in expenses with ${vendors.length} active vendors.`,
    recommendations: [
      { title: 'Optimize Expenses', description: `Your expense ratio is ${revenue > 0 ? ((expenses / revenue) * 100).toFixed(1) : 'N/A'}%. Consider reviewing vendor contracts.` },
      { title: 'Revenue Growth', description: revenue > 10000 ? 'Your revenue is strong. Consider expanding to new markets.' : 'Focus on increasing revenue streams.' },
      { title: 'Vendor Health', description: vendors.length > 3 ? 'You have a diverse vendor base. Monitor performance regularly.' : 'Consider diversifying your suppliers.' },
    ],
    action_items: [
      'Review monthly vendor spend',
      'Set up automated expense tracking',
      'Schedule quarterly financial review',
    ],
  };
}
