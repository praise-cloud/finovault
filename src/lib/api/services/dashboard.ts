import { supabase } from '@/lib/supabase';
import type {
  DashboardSummary,
  WealthGrowthData,
  SmartSavingsData,
  FraudProtectionData,
  SmeDashboardData,
  SmeAnalyticsData,
  FreelancerData,
  EntrepreneurData,
  ProfileData,
  Transaction,
  AISuggestion,
  AssetAllocation,
} from '@/lib/supabase-types';

export async function getDashboardSummary(userId: string): Promise<DashboardSummary> {
  const [transactions, allocations, suggestions] = await Promise.all([
    supabase.from('transactions').select('*').eq('user_id', userId).order('date', { ascending: false }).limit(10),
    supabase.from('asset_allocations').select('*').eq('user_id', userId),
    supabase.from('ai_suggestions').select('*').eq('user_id', userId).eq('status', 'active').limit(1).single(),
  ]);

  const txs = (transactions.data || []) as Transaction[];
  const assets = (allocations.data || []) as AssetAllocation[];
  const nextMove = suggestions.data as AISuggestion | null;

  const totalNetWorth = assets.reduce((sum, a) => sum + a.value, 0);
  const monthlySpending = txs
    .filter((t) => t.type === 'expense')
    .slice(0, 30)
    .reduce((sum, t) => sum + t.amount, 0);

  return {
    total_net_worth: totalNetWorth || 1284500.42,
    net_worth_change: 42000,
    net_worth_change_pct: 12.4,
    monthly_spending: monthlySpending || 8420,
    spending_limit: 7500,
    spending_trend: 'up',
    next_best_move: nextMove,
    recent_transactions: txs,
    asset_allocations: assets,
  };
}

export async function getWealthGrowthData(userId: string): Promise<WealthGrowthData> {
  const [allocations, insights] = await Promise.all([
    supabase.from('asset_allocations').select('*').eq('user_id', userId),
    supabase.from('market_insights').select('*').order('published_at', { ascending: false }).limit(5),
  ]);

  const assets = (allocations.data || []) as AssetAllocation[];

  return {
    total_wealth: assets.reduce((s, a) => s + a.value, 0) || 124502,
    performance_forecast: [40, 45, 42, 55, 65, 75, 82, 88, 95, 98, 105],
    allocations: assets.length > 0 ? assets : [
      { id: '1', user_id: userId, category: 'Equities', percentage: 55, value: 68476, color: '#000f22', icon: 'trending-up' },
      { id: '2', user_id: userId, category: 'Fixed Income', percentage: 25, value: 31125, color: '#006b5a', icon: 'account-balance' },
      { id: '3', user_id: userId, category: 'Digital Assets', percentage: 12, value: 14940, color: '#c3c0ff', icon: 'token' },
      { id: '4', user_id: userId, category: 'Cash', percentage: 8, value: 9961, color: '#e0e3e6', icon: 'money' },
    ],
    market_insights: (insights.data || []).map((i) => ({
      id: i.id,
      badge: i.badge,
      badge_bg: i.badge === 'Bullish' ? 'bg-secondary-container' : 'bg-surface-variant',
      badge_text: i.badge === 'Bullish' ? 'text-on-secondary-container' : 'text-on-surface-variant',
      title: i.title,
      description: i.description,
      time_label: i.time_label,
      category: i.category,
      published_at: i.published_at,
    })),
    risk_shield_progress: 78,
    risk_shield_message: 'Our AI detected a potential 4.2% drag from underperforming bond yields.',
    risk_shield_potential_savings: 5240,
  };
}

export async function getSmartSavingsData(userId: string): Promise<SmartSavingsData> {
  const [goals, roundUps, suggestions] = await Promise.all([
    supabase.from('savings_goals').select('*').eq('user_id', userId).eq('goal_type', 'rainy_day').single(),
    supabase.from('round_up_savings').select('*').eq('user_id', userId).order('date', { ascending: false }).limit(5),
    supabase.from('ai_suggestions').select('*').eq('user_id', userId).eq('type', 'savings').eq('status', 'active').limit(1).single(),
  ]);

  const rounds = (roundUps.data || []) as any[];
  const totalImpact = rounds.reduce((s, r) => s + r.saved_amount, 0);

  return {
    rainy_day_fund: (goals.data || {
      id: '1',
      user_id: userId,
      name: 'Rainy Day Fund',
      target_amount: 12000,
      current_amount: 8420.50,
      goal_type: 'rainy_day',
      status: 'active',
    }) as any,
    ai_suggestion: (suggestions.data || {
      id: '1',
      user_id: userId,
      title: 'Hidden saving potential',
      description: "Based on your spending patterns at 'Gourmet Coffee', setting a monthly cap could increase your savings by $1,020 annually.",
      type: 'savings',
      potential_savings: 1020,
      status: 'active',
      created_at: new Date().toISOString(),
    }) as AISuggestion,
    round_ups: rounds.length > 0 ? rounds : [
      { id: '1', user_id: userId, transaction_id: null, original_amount: 42.34, rounded_amount: 43, saved_amount: 0.66, merchant: 'Whole Foods Market', category: 'groceries', date: new Date().toISOString() },
      { id: '2', user_id: userId, transaction_id: null, original_amount: 55.10, rounded_amount: 56, saved_amount: 0.90, merchant: 'Shell Station', category: 'transport', date: new Date(Date.now() - 86400000).toISOString() },
      { id: '3', user_id: userId, transaction_id: null, original_amount: 4.15, rounded_amount: 5, saved_amount: 0.85, merchant: 'Gourmet Coffee', category: 'food', date: new Date(Date.now() - 86400000).toISOString() },
    ],
    total_savings_impact: totalImpact || 1248.12,
    savings_trend: 12,
    micro_budget_suggestion: "You're spending 15% more on entertainment than users with similar goals. Try a 'No-Spend' weekend?",
  };
}

export async function getFraudProtectionData(userId: string): Promise<FraudProtectionData> {
  const [metrics, events] = await Promise.all([
    supabase.from('security_metrics').select('*').eq('user_id', userId).single(),
    supabase.from('fraud_events').select('*').eq('user_id', userId).order('timestamp', { ascending: false }).limit(10),
  ]);

  return {
    security_score: (metrics.data as any)?.score || 98,
    metrics: (metrics.data || {
      id: '1',
      user_id: userId,
      score: 98,
      encryption_level: 'AES-256',
      identity_verified: true,
      last_login: new Date().toISOString(),
      active_devices: 3,
    }) as any,
    events: (events.data || [
      { id: '1', user_id: userId, event_type: 'Biometric Login Verified', description: 'Successful facial recognition login from known device: iPhone 15 Pro.', severity: 'info', timestamp: new Date(Date.now() - 120000).toISOString() },
      { id: '2', user_id: userId, event_type: 'Neural Pattern Sync', description: 'Transaction patterns synchronized with global fraud database. 0 anomalies detected.', severity: 'info', timestamp: new Date(Date.now() - 900000).toISOString() },
      { id: '3', user_id: userId, event_type: 'Location Update', description: 'Your location is verified as London, UK. International travel lock remains active.', severity: 'info', timestamp: new Date(Date.now() - 3600000).toISOString() },
    ]) as any[],
  };
}

export async function getSmeDashboardData(userId: string): Promise<SmeDashboardData> {
  const [transactions, payroll, vendors, fraudEvents] = await Promise.all([
    supabase.from('transactions').select('*').eq('user_id', userId).eq('type', 'income').limit(10),
    supabase.from('payroll_tasks').select('*').eq('user_id', userId),
    supabase.from('vendors').select('*').eq('user_id', userId),
    supabase.from('fraud_events').select('*').eq('user_id', userId).order('timestamp', { ascending: false }).limit(5),
  ]);

  const txs = (transactions.data || []) as any[];
  const incoming = txs.reduce((s, t) => s + t.amount, 0);

  return {
    cashflow: {
      incoming: incoming || 142500,
      outgoing: 98200,
      net_position: (incoming || 142500) - 98200,
      incoming_change: 12,
      outgoing_trend: 'Stable',
      forecast: [40, 55, 45, 70, 85, 95, 60, 75],
    },
    payroll_tasks: (payroll.data || [
      { id: '1', user_id: userId, title: 'Tax Filing Overdue', description: 'Quarterly payroll taxes due for 12 employees.', status: 'overdue', due_date: '2023-10-15' },
      { id: '2', user_id: userId, title: 'October Salaries', description: 'Scheduled for Oct 28th. Funding confirmed.', status: 'completed', due_date: '2023-10-28' },
      { id: '3', user_id: userId, title: 'New Onboarding', description: '2 contractors pending banking details.', status: 'pending', due_date: '2023-11-01' },
    ]) as any[],
    payroll_health_score: 75,
    vendors: (vendors.data || [
      { id: '1', user_id: userId, name: 'Azure Systems', description: 'Cloud Infrastructure', icon: 'cloud', health_score: 98, status: 'critical', monthly_spend: 12400, badge: 'CRITICAL VENDOR', badge_bg: 'bg-secondary-container', badge_text: 'text-on-secondary-container' },
      { id: '2', user_id: userId, name: 'Global Logistics Co.', description: 'Shipping & Freight', icon: 'local-shipping', health_score: 42, status: 'high_risk', monthly_spend: 45000, badge: 'HIGH RISK', badge_bg: 'bg-error-container', badge_text: 'text-on-error-container' },
      { id: '3', user_id: userId, name: 'Stellar Energy', description: 'Utilities', icon: 'bolt', health_score: 85, status: 'stable', monthly_spend: 3200, badge: 'STABLE', badge_bg: 'bg-surface-variant', badge_text: 'text-on-surface-variant' },
      { id: '4', user_id: userId, name: 'AdVantage Media', description: 'Marketing Services', icon: 'campaign', health_score: 76, status: 'stable', monthly_spend: 8200, badge: 'STABLE', badge_bg: 'bg-surface-variant', badge_text: 'text-on-surface-variant' },
    ]) as any[],
    growth_pulse: {
      market_share_growth: 4.2,
      customer_lifetime_value: 2840,
      burn_rate_efficiency: 'Optimal',
    },
    fraud_events: (fraudEvents.data || []).map((e) => ({
      id: e.id,
      user_id: e.user_id,
      event_type: e.event_type,
      description: e.description,
      severity: e.severity,
      timestamp: e.timestamp,
    })),
  };
}

export async function getSmeAnalyticsData(userId: string): Promise<SmeAnalyticsData> {
  const vendors = await supabase.from('vendors').select('*').eq('user_id', userId);

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
    vendors: (vendors.data || []).map((v) => ({
      id: v.id,
      user_id: v.user_id,
      name: v.name,
      description: v.description,
      icon: v.icon,
      health_score: v.health_score,
      status: v.status,
      monthly_spend: v.monthly_spend,
      badge: v.badge,
      badge_bg: v.badge_bg,
      badge_text: v.badge_text,
    })),
    ai_recommendation: 'Our forensics detect a potential 12% saving opportunity by renegotiating terms with Metro Logistics or switching to a Tier-2 provider with better liquidity scores in the Northeast region.',
  };
}

export async function getFreelancerData(userId: string): Promise<FreelancerData> {
  const projects = await supabase.from('projects').select('*').eq('user_id', userId);

  const projs = (projects.data || []) as any[];
  const totalIncome = projs.reduce((s, p) => s + p.amount, 0);
  const unpaidCount = projs.filter((p) => p.status === 'Overdue' || p.status === 'Invoiced').length;

  return {
    tax_liability: 14250,
    tax_withheld: 9262.50,
    tax_goal_pct: 65,
    income: {
      project_based: 42800,
      retainers: 12400,
    },
    unpaid_invoices: 8120,
    overdue_count: unpaidCount || 3,
    projects: projs.length > 0 ? projs : [
      { id: '1', user_id: userId, name: 'AI Interface Design', client: 'Nebula Corp', amount: 4500, status: 'Invoiced' },
      { id: '2', user_id: userId, name: 'Brand System Evolution', client: 'Stellar.io', amount: 12000, status: 'In Progress' },
      { id: '3', user_id: userId, name: 'Mobile App Audit', client: 'FinTech Global', amount: 2800, status: 'Overdue' },
    ],
    tax_shield_message: 'Our AI analyzed your recent project expenses. You could save an additional $2,400 this quarter by reclassifying equipment purchases.',
    tax_shield_savings: 2400,
  };
}

export async function getEntrepreneurData(userId: string): Promise<EntrepreneurData> {
  const contacts = await supabase.from('network_contacts').select('*').eq('user_id', userId);

  return {
    mrr: 428500,
    mrr_growth: 12,
    burn_rate: '$12k/mo',
    cac: '$42.00',
    runway: '18 Months',
    grant: {
      title: 'Female Innovators Seed Fund 2024',
      description: 'Tailored for SaaS companies with >$100k ARR. Up to $250,000 non-dilutive capital.',
      max_funding: '$250,000',
    },
    smart_savings: {
      label: 'Operational Reserve',
      apy: '4.2% APY Growth',
      amount: 124000,
    },
    network: (contacts.data || [
      { id: '1', user_id: userId, name: 'Sarah Wang', role: 'Partner at Sequoia Growth', avatar_url: null },
      { id: '2', user_id: userId, name: 'Elena Torres', role: 'CEO, Torres Logistics', avatar_url: null },
    ]) as any[],
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

export async function getProfileData(userId: string): Promise<ProfileData> {
  const [profile, preferences, accounts, security] = await Promise.all([
    supabase.from('profiles').select('*').eq('id', userId).single(),
    supabase.from('user_preferences').select('*').eq('user_id', userId).single(),
    supabase.from('linked_accounts').select('*').eq('user_id', userId),
    supabase.from('security_metrics').select('*').eq('user_id', userId).single(),
  ]);

  return {
    profile: (profile.data || {
      id: userId, full_name: 'Alex Morgan', email: 'a.morgan@finovault.ai', phone: '+1 (555) 012-3456',
      avatar_url: null, plan_type: 'individual_pro', account_id: 'FV-8892',
      created_at: new Date().toISOString(), updated_at: new Date().toISOString(),
    }) as any,
    preferences: (preferences.data || { role: 'individual', goals: ['wealth', 'savings'], ai_insights_enabled: true, security_alerts_enabled: true }) as any,
    linked_accounts: (accounts.data || [
      { id: '1', user_id: userId, bank_name: 'Chase Sapphire Banking', account_type: 'Checking', account_number: '•••• 9921', balance: 45200 },
      { id: '2', user_id: userId, bank_name: 'Goldman Sachs Marcus', account_type: 'High Yield Savings', account_number: '•••• 4402', balance: 124000 },
    ]) as any,
    security: (security.data || { score: 98, encryption_level: 'AES-256', identity_verified: true, last_login: new Date().toISOString(), active_devices: 3 }) as any,
    plan: { name: 'Individual Pro', price: 29.99, billing: 'billed monthly' },
  };
}
