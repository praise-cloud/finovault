export interface Profile {
  id: string;
  full_name: string;
  email: string;
  phone: string | null;
  avatar_url: string | null;
  plan_type: string;
  account_id: string;
  created_at: string;
  updated_at: string;
}

export interface UserPreferences {
  id: string;
  user_id: string;
  role: 'individual' | 'sme' | 'entrepreneur' | 'freelancer';
  goals: string[];
  ai_insights_enabled: boolean;
  security_alerts_enabled: boolean;
  created_at: string;
  updated_at: string;
}

export interface Transaction {
  id: string;
  user_id: string;
  type: 'income' | 'expense' | 'transfer';
  amount: number;
  description: string;
  category: string;
  date: string;
  status: 'pending' | 'completed' | 'flagged';
  merchant: string | null;
}

export interface AssetAllocation {
  id: string;
  user_id: string;
  category: string;
  percentage: number;
  value: number;
  color: string;
  icon: string;
}

export interface SavingsGoal {
  id: string;
  user_id: string;
  name: string;
  target_amount: number;
  current_amount: number;
  goal_type: 'rainy_day' | 'general';
  status: 'active' | 'completed' | 'paused';
}

export interface RoundUpSavings {
  id: string;
  user_id: string;
  transaction_id: string | null;
  original_amount: number;
  rounded_amount: number;
  saved_amount: number;
  merchant: string;
  category: string;
  date: string;
}

export interface MarketInsight {
  id: string;
  badge: string;
  badge_bg: string;
  badge_text: string;
  title: string;
  description: string;
  time_label: string;
  category: string;
  published_at: string;
}

export interface Vendor {
  id: string;
  user_id: string;
  name: string;
  description: string;
  icon: string;
  health_score: number;
  status: string;
  monthly_spend: number;
  badge: string;
  badge_bg: string;
  badge_text: string;
}

export interface PayrollTask {
  id: string;
  user_id: string;
  title: string;
  description: string;
  status: 'overdue' | 'completed' | 'pending';
  due_date: string;
}

export interface Project {
  id: string;
  user_id: string;
  name: string;
  client: string;
  amount: number;
  status: string;
}

export interface NetworkContact {
  id: string;
  user_id: string;
  name: string;
  role: string;
  avatar_url: string | null;
}

export interface FraudEvent {
  id: string;
  user_id: string;
  event_type: string;
  description: string;
  severity: 'info' | 'warning' | 'critical';
  timestamp: string;
}

export interface LinkedAccount {
  id: string;
  user_id: string;
  bank_name: string;
  account_type: string;
  account_number: string;
  balance: number;
}

export interface AISuggestion {
  id: string;
  user_id: string;
  title: string;
  description: string;
  type: string;
  potential_savings: number | null;
  status: 'active' | 'dismissed' | 'executed';
  created_at: string;
}

export interface SecurityMetrics {
  id: string;
  user_id: string;
  score: number;
  encryption_level: string;
  identity_verified: boolean;
  last_login: string;
  active_devices: number;
}

export interface IncomeSummary {
  project_based: number;
  retainers: number;
}

export interface DashboardSummary {
  total_net_worth: number;
  net_worth_change: number;
  net_worth_change_pct: number;
  monthly_spending: number;
  spending_limit: number;
  spending_trend: 'up' | 'down' | 'flat';
  next_best_move: AISuggestion | null;
  recent_transactions: Transaction[];
  asset_allocations: AssetAllocation[];
}

export interface WealthGrowthData {
  total_wealth: number;
  performance_forecast: number[];
  allocations: AssetAllocation[];
  market_insights: MarketInsight[];
  risk_shield_progress: number;
  risk_shield_message: string;
  risk_shield_potential_savings: number;
}

export interface SmartSavingsData {
  rainy_day_fund: SavingsGoal;
  ai_suggestion: AISuggestion;
  round_ups: RoundUpSavings[];
  total_savings_impact: number;
  savings_trend: number;
  micro_budget_suggestion: string;
}

export interface FraudProtectionData {
  security_score: number;
  metrics: SecurityMetrics;
  events: FraudEvent[];
}

export interface SmeDashboardData {
  cashflow: {
    incoming: number;
    outgoing: number;
    net_position: number;
    incoming_change: number;
    outgoing_trend: string;
    forecast: number[];
  };
  payroll_tasks: PayrollTask[];
  payroll_health_score: number;
  vendors: Vendor[];
  growth_pulse: {
    market_share_growth: number;
    customer_lifetime_value: number;
    burn_rate_efficiency: string;
  };
  fraud_events: FraudEvent[];
}

export interface SmeAnalyticsData {
  cashflow_forensics: {
    net_inflow: number;
    burn_rate: number;
    runway_months: number;
    inflow_change: number;
    chart_data: number[];
  };
  benchmarks: {
    efficiency_ratio: number;
    customer_retention: number;
    digital_adoption: number;
  };
  vendors: Vendor[];
  ai_recommendation: string;
}

export interface FreelancerData {
  tax_liability: number;
  tax_withheld: number;
  tax_goal_pct: number;
  income: IncomeSummary;
  unpaid_invoices: number;
  overdue_count: number;
  projects: Project[];
  tax_shield_message: string;
  tax_shield_savings: number;
}

export interface EntrepreneurData {
  mrr: number;
  mrr_growth: number;
  burn_rate: string;
  cac: string;
  runway: string;
  grant: {
    title: string;
    description: string;
    max_funding: string;
  };
  smart_savings: {
    label: string;
    apy: string;
    amount: number;
  };
  network: NetworkContact[];
  upcoming_roundtable: {
    title: string;
    time: string;
  };
  portfolio: {
    saas_focus_pct: number;
    saas_value: number;
    marketing_value: number;
    human_capital_value: number;
  };
}

export interface ProfileData {
  profile: Profile;
  preferences: UserPreferences;
  linked_accounts: LinkedAccount[];
  security: SecurityMetrics;
  plan: {
    name: string;
    price: number;
    billing: string;
  };
}
