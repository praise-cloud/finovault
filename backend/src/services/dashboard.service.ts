import { getSupabase } from '../config/supabase';
import { createContextLogger } from '../utils/logger';

const log = createContextLogger('DashboardService');

export async function getSummary(userId: string) {
  const supabase = getSupabase();

  const [txRes, allocRes, suggestRes] = await Promise.all([
    supabase.from('transactions').select('*').eq('user_id', userId).order('date', { ascending: false }).limit(10),
    supabase.from('asset_allocations').select('*').eq('user_id', userId),
    supabase.from('ai_suggestions').select('*').eq('user_id', userId).eq('status', 'active').limit(1).single(),
  ]);

  const transactions = txRes.data || [];
  const allocations = allocRes.data || [];
  const nextMove = suggestRes.data || null;
  const totalNetWorth = allocations.reduce((sum: number, a: any) => sum + Number(a.value), 0);
  const monthlySpending = transactions
    .filter((t: any) => t.type === 'expense')
    .slice(0, 30)
    .reduce((sum: number, t: any) => sum + Number(t.amount), 0);

  return {
    total_net_worth: totalNetWorth || 1284500.42,
    net_worth_change: 42000,
    net_worth_change_pct: 12.4,
    monthly_spending: monthlySpending || 8420,
    spending_limit: 7500,
    spending_trend: 'up',
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

  const allocations = allocRes.data || [];
  const totalWealth = allocations.reduce((s: number, a: any) => s + Number(a.value), 0);

  return {
    total_wealth: totalWealth || 124502,
    performance_forecast: [40, 45, 42, 55, 65, 75, 82, 88, 95, 98, 105],
    allocations: allocations.length > 0 ? allocations : [
      { category: 'Equities', percentage: 55, value: 68476, color: '#000f22', icon: 'trending-up' },
      { category: 'Fixed Income', percentage: 25, value: 31125, color: '#006b5a', icon: 'account-balance' },
      { category: 'Digital Assets', percentage: 12, value: 14940, color: '#c3c0ff', icon: 'token' },
      { category: 'Cash', percentage: 8, value: 9961, color: '#e0e3e6', icon: 'money' },
    ],
    market_insights: insightRes.data || [],
    risk_shield_progress: 78,
    risk_shield_message: 'Our AI detected a potential 4.2% drag from underperforming bond yields.',
    risk_shield_potential_savings: 5240,
  };
}

export async function getSmartSavings(userId: string) {
  const supabase = getSupabase();

  const [goalRes, roundRes, suggestRes] = await Promise.all([
    supabase.from('savings_goals').select('*').eq('user_id', userId).eq('goal_type', 'rainy_day').single(),
    supabase.from('round_up_savings').select('*').eq('user_id', userId).order('date', { ascending: false }).limit(5),
    supabase.from('ai_suggestions').select('*').eq('user_id', userId).eq('type', 'savings').eq('status', 'active').limit(1).single(),
  ]);

  const rounds = roundRes.data || [];
  const totalImpact = rounds.reduce((s: number, r: any) => s + Number(r.saved_amount), 0);

  return {
    rainy_day_fund: goalRes.data || {
      name: 'Rainy Day Fund',
      target_amount: 12000,
      current_amount: 8420.50,
      goal_type: 'rainy_day',
      status: 'active',
    },
    ai_suggestion: suggestRes.data || {
      title: 'Hidden saving potential',
      description: "Based on your spending patterns at 'Gourmet Coffee', setting a monthly cap could increase your savings by $1,020 annually.",
      type: 'savings',
      potential_savings: 1020,
      status: 'active',
    },
    round_ups: rounds.length > 0 ? rounds : [
      { original_amount: 42.34, rounded_amount: 43, saved_amount: 0.66, merchant: 'Whole Foods Market', category: 'groceries' },
      { original_amount: 55.10, rounded_amount: 56, saved_amount: 0.90, merchant: 'Shell Station', category: 'transport' },
      { original_amount: 4.15, rounded_amount: 5, saved_amount: 0.85, merchant: 'Gourmet Coffee', category: 'food' },
    ],
    total_savings_impact: totalImpact || 1248.12,
    savings_trend: 12,
    micro_budget_suggestion: "You're spending 15% more on entertainment than users with similar goals. Try a 'No-Spend' weekend?",
  };
}

export async function getFraudProtection(userId: string) {
  const supabase = getSupabase();

  const [metricRes, eventRes] = await Promise.all([
    supabase.from('security_metrics').select('*').eq('user_id', userId).single(),
    supabase.from('fraud_events').select('*').eq('user_id', userId).order('timestamp', { ascending: false }).limit(10),
  ]);

  return {
    security_score: metricRes.data?.score || 98,
    metrics: metricRes.data || {
      score: 98,
      encryption_level: 'AES-256',
      identity_verified: true,
      last_login: new Date().toISOString(),
      active_devices: 3,
    },
    events: eventRes.data || [
      { event_type: 'Biometric Login Verified', description: 'Successful facial recognition login from known device', severity: 'info' },
      { event_type: 'Neural Pattern Sync', description: 'Transaction patterns synchronized. 0 anomalies detected.', severity: 'info' },
      { event_type: 'Location Update', description: 'Your location is verified as London, UK.', severity: 'info' },
    ],
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

  const txs = txRes.data || [];
  const incoming = txs.reduce((s: number, t: any) => s + Number(t.amount), 0);

  return {
    cashflow: {
      incoming: incoming || 142500,
      outgoing: 98200,
      net_position: (incoming || 142500) - 98200,
      incoming_change: 12,
      outgoing_trend: 'Stable',
      forecast: [40, 55, 45, 70, 85, 95, 60, 75],
    },
    payroll_tasks: payrollRes.data || [],
    payroll_health_score: 75,
    vendors: vendorRes.data || [],
    growth_pulse: {
      market_share_growth: 4.2,
      customer_lifetime_value: 2840,
      burn_rate_efficiency: 'Optimal',
    },
    fraud_events: fraudRes.data || [],
  };
}

export async function getSmeAnalytics(userId: string) {
  const supabase = getSupabase();

  const vendorRes = await supabase.from('vendors').select('*').eq('user_id', userId);

  return {
    cashflow_forensics: {
      net_inflow: 142500,
      burn_rate: 89200,
      runway_months: 18.4,
      inflow_change: 12.4,
      chart_data: [40, 65, 55, 85, 70, 95, 60, 45],
    },
    benchmarks: {
      efficiency_ratio: 94,
      customer_retention: 82,
      digital_adoption: 98,
    },
    vendors: vendorRes.data || [],
    ai_recommendation: 'Our forensics detect a potential 12% saving opportunity by renegotiating supplier terms.',
  };
}

export async function getFreelancer(userId: string) {
  const supabase = getSupabase();

  const projectRes = await supabase.from('projects').select('*').eq('user_id', userId);
  const projects = projectRes.data || [];

  return {
    tax_liability: 14250,
    tax_withheld: 9262.50,
    tax_goal_pct: 65,
    income: {
      project_based: 42800,
      retainers: 12400,
    },
    unpaid_invoices: 8120,
    overdue_count: projects.filter((p: any) => p.status === 'Overdue').length || 3,
    projects: projects.length > 0 ? projects : [
      { name: 'AI Interface Design', client: 'Nebula Corp', amount: 4500, status: 'Invoiced' },
      { name: 'Brand System Evolution', client: 'Stellar.io', amount: 12000, status: 'In Progress' },
      { name: 'Mobile App Audit', client: 'FinTech Global', amount: 2800, status: 'Overdue' },
    ],
    tax_shield_message: 'You could save an additional $2,400 this quarter by reclassifying equipment purchases.',
    tax_shield_savings: 2400,
  };
}

export async function getEntrepreneur(userId: string) {
  const supabase = getSupabase();

  const contactRes = await supabase.from('network_contacts').select('*').eq('user_id', userId);

  return {
    mrr: 428500,
    mrr_growth: 12,
    burn_rate: '$12k/mo',
    cac: '$42.00',
    runway: '18 Months',
    grant: {
      title: 'Female Innovators Seed Fund 2024',
      description: 'Tailored for SaaS companies with >$100k ARR.',
      max_funding: '$250,000',
    },
    smart_savings: {
      label: 'Operational Reserve',
      apy: '4.2% APY Growth',
      amount: 124000,
    },
    network: contactRes.data || [],
    upcoming_roundtable: {
      title: 'Series B Fundraising Tactics',
      time: 'Tomorrow, 10:00 AM EST',
    },
    portfolio: {
      saas_focus_pct: 64,
      saas_value: 210000,
      marketing_value: 124500,
      human_capital_value: 94000,
    },
  };
}

export async function getProfileData(userId: string) {
  const supabase = getSupabase();

  const [profileRes, prefsRes, accountsRes, securityRes] = await Promise.all([
    supabase.from('profiles').select('*').eq('id', userId).single(),
    supabase.from('user_preferences').select('*').eq('user_id', userId).single(),
    supabase.from('linked_accounts').select('*').eq('user_id', userId),
    supabase.from('security_metrics').select('*').eq('user_id', userId).single(),
  ]);

  return {
    profile: profileRes.data || {
      id: userId, full_name: 'User', email: '',
      plan_type: 'individual_pro',
    },
    preferences: prefsRes.data || { role: 'individual', goals: ['wealth', 'savings'], ai_insights_enabled: true, security_alerts_enabled: true },
    linked_accounts: accountsRes.data || [],
    security: securityRes.data || { score: 98, encryption_level: 'AES-256', identity_verified: true, active_devices: 3 },
    plan: { name: 'Individual Pro', price: 29.99, billing: 'billed monthly' },
  };
}
