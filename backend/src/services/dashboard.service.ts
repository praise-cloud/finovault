import { getSupabase } from '../config/supabase';
import { createContextLogger } from '../utils/logger';

const log = createContextLogger('DashboardService');

export async function getSummary(userId: string) {
  const supabase = getSupabase();

  const [txRes, allocRes, suggestRes] = await Promise.all([
    supabase.from('transactions').select('*').eq('user_id', userId).order('date', { ascending: false }).limit(10),
    supabase.from('asset_allocations').select('*').eq('user_id', userId),
    supabase.from('ai_suggestions').select('*').eq('user_id', userId).eq('status', 'active').limit(1).maybeSingle(),
  ]);

  if (txRes.error) log.error('getSummary tx error', { error: txRes.error.message });
  if (allocRes.error) log.error('getSummary alloc error', { error: allocRes.error.message });

  const transactions = txRes.data || [];
  const allocations = allocRes.data || [];
  const nextMove = suggestRes.data || null;
  const totalNetWorth = allocations.reduce((sum: number, a: any) => sum + Number(a.value), 0);
  const monthlySpending = transactions
    .filter((t: any) => t.type === 'expense')
    .slice(0, 30)
    .reduce((sum: number, t: any) => sum + Number(t.amount), 0);

  return {
    total_net_worth: totalNetWorth || 0,
    net_worth_change: 0,
    net_worth_change_pct: 0,
    monthly_spending: monthlySpending || 0,
    spending_limit: 0,
    spending_trend: null,
    next_best_move: nextMove,
    recent_transactions: transactions,
    asset_allocations: allocations,
  };
}

export async function getWealthGrowth(userId: string) {
  const supabase = getSupabase();

  const [allocRes, insightRes] = await Promise.all([
    supabase.from('asset_allocations').select('*').eq('user_id', userId),
    supabase.from('market_insights').select('*').order('published_at', { ascending: false }).limit(5),
  ]);

  if (allocRes.error) log.error('getWealthGrowth alloc error', { error: allocRes.error.message });

  const allocations = allocRes.data || [];
  const totalWealth = allocations.reduce((s: number, a: any) => s + Number(a.value), 0);

  return {
    total_wealth: totalWealth || 0,
    performance_forecast: [],
    allocations,
    market_insights: insightRes.data || [],
    risk_shield_progress: 0,
    risk_shield_message: null,
    risk_shield_potential_savings: 0,
  };
}

export async function getSmartSavings(userId: string) {
  const supabase = getSupabase();

  const [goalRes, roundRes, suggestRes] = await Promise.all([
    supabase.from('savings_goals').select('*').eq('user_id', userId).eq('goal_type', 'rainy_day').maybeSingle(),
    supabase.from('round_up_savings').select('*').eq('user_id', userId).order('date', { ascending: false }).limit(5),
    supabase.from('ai_suggestions').select('*').eq('user_id', userId).eq('type', 'savings').eq('status', 'active').limit(1).maybeSingle(),
  ]);

  if (goalRes.error) log.error('getSmartSavings goal error', { error: goalRes.error.message });

  const rounds = roundRes.data || [];
  const totalImpact = rounds.reduce((s: number, r: any) => s + Number(r.saved_amount), 0);

  return {
    rainy_day_fund: goalRes.data || null,
    ai_suggestion: suggestRes.data || null,
    round_ups: rounds,
    total_savings_impact: totalImpact || 0,
    savings_trend: 0,
    micro_budget_suggestion: null,
  };
}

export async function getFraudProtection(userId: string) {
  const supabase = getSupabase();

  const [metricRes, eventRes] = await Promise.all([
    supabase.from('security_metrics').select('*').eq('user_id', userId).maybeSingle(),
    supabase.from('fraud_events').select('*').eq('user_id', userId).order('timestamp', { ascending: false }).limit(10),
  ]);

  if (metricRes.error) log.error('getFraudProtection metric error', { error: metricRes.error.message });

  return {
    security_score: metricRes.data?.score || 0,
    metrics: metricRes.data || null,
    events: eventRes.data || [],
  };
}

export async function getSmeDashboard(userId: string) {
  const supabase = getSupabase();

  const [txRes, payrollRes, vendorRes, fraudRes] = await Promise.all([
    supabase.from('transactions').select('*').eq('user_id', userId).eq('type', 'income').limit(10),
    supabase.from('payroll_tasks').select('*').eq('user_id', userId),
    supabase.from('vendors').select('*').eq('user_id', userId),
    supabase.from('fraud_events').select('*').eq('user_id', userId).order('timestamp', { ascending: false }).limit(5),
  ]);

  if (txRes.error) log.error('getSmeDashboard tx error', { error: txRes.error.message });

  const txs = txRes.data || [];
  const incoming = txs.reduce((s: number, t: any) => s + Number(t.amount), 0);

  return {
    cashflow: {
      incoming,
      outgoing: 0,
      net_position: incoming,
      incoming_change: 0,
      outgoing_trend: null,
      forecast: [],
    },
    payroll_tasks: payrollRes.data || [],
    payroll_health_score: 0,
    vendors: vendorRes.data || [],
    growth_pulse: null,
    fraud_events: fraudRes.data || [],
  };
}

export async function getSmeAnalytics(userId: string) {
  const supabase = getSupabase();

  const vendorRes = await supabase.from('vendors').select('*').eq('user_id', userId);
  if (vendorRes.error) log.error('getSmeAnalytics error', { error: vendorRes.error.message });

  return {
    cashflow_forensics: null,
    benchmarks: null,
    vendors: vendorRes.data || [],
    ai_recommendation: null,
  };
}

export async function getFreelancer(userId: string) {
  const supabase = getSupabase();

  const projectRes = await supabase.from('projects').select('*').eq('user_id', userId);
  if (projectRes.error) log.error('getFreelancer error', { error: projectRes.error.message });

  const projects = projectRes.data || [];

  return {
    tax_liability: 0,
    tax_withheld: 0,
    tax_goal_pct: 0,
    income: {
      project_based: 0,
      retainers: 0,
    },
    unpaid_invoices: 0,
    overdue_count: projects.filter((p: any) => p.status === 'Overdue').length || 0,
    projects,
    tax_shield_message: null,
    tax_shield_savings: 0,
  };
}

export async function getEntrepreneur(userId: string) {
  const supabase = getSupabase();

  const contactRes = await supabase.from('network_contacts').select('*').eq('user_id', userId);
  if (contactRes.error) log.error('getEntrepreneur error', { error: contactRes.error.message });

  return {
    mrr: 0,
    mrr_growth: 0,
    burn_rate: '',
    cac: '',
    runway: '',
    grant: null,
    smart_savings: null,
    network: contactRes.data || [],
    upcoming_roundtable: null,
    portfolio: null,
  };
}

export async function getProfileData(userId: string) {
  const supabase = getSupabase();

  const [profileRes, prefsRes, accountsRes, securityRes] = await Promise.all([
    supabase.from('profiles').select('*').eq('id', userId).maybeSingle(),
    supabase.from('user_preferences').select('*').eq('user_id', userId).maybeSingle(),
    supabase.from('linked_accounts').select('*').eq('user_id', userId),
    supabase.from('security_metrics').select('*').eq('user_id', userId).maybeSingle(),
  ]);

  if (profileRes.error) log.error('getProfileData profile error', { error: profileRes.error.message });

  return {
    profile: profileRes.data || null,
    preferences: prefsRes.data || null,
    linked_accounts: accountsRes.data || [],
    security: securityRes.data || null,
    plan: null,
  };
}
