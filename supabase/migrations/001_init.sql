-- Finovault AI - Database Schema
-- Idempotent - safe to re-run

-- Drop existing tables in reverse dependency order
DROP TABLE IF EXISTS ai_suggestions CASCADE;
DROP TABLE IF EXISTS security_metrics CASCADE;
DROP TABLE IF EXISTS fraud_events CASCADE;
DROP TABLE IF EXISTS linked_accounts CASCADE;
DROP TABLE IF EXISTS round_up_savings CASCADE;
DROP TABLE IF EXISTS transactions CASCADE;
DROP TABLE IF EXISTS savings_goals CASCADE;
DROP TABLE IF EXISTS asset_allocations CASCADE;
DROP TABLE IF EXISTS vendors CASCADE;
DROP TABLE IF EXISTS payroll_tasks CASCADE;
DROP TABLE IF EXISTS projects CASCADE;
DROP TABLE IF EXISTS network_contacts CASCADE;
DROP TABLE IF EXISTS market_insights CASCADE;
DROP TABLE IF EXISTS user_preferences CASCADE;
DROP TABLE IF EXISTS profiles CASCADE;

-- 1. Profiles (extends auth.users)
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT NOT NULL,
  email TEXT NOT NULL,
  phone TEXT,
  avatar_url TEXT,
  plan_type TEXT DEFAULT 'individual_pro',
  account_id TEXT UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. User Preferences (onboarding)
CREATE TABLE user_preferences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('individual', 'sme', 'entrepreneur', 'freelancer')),
  goals TEXT[] DEFAULT '{}',
  ai_insights_enabled BOOLEAN DEFAULT true,
  security_alerts_enabled BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id)
);

-- 3. Transactions
CREATE TABLE transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('income', 'expense', 'transfer')),
  amount DECIMAL(15,2) NOT NULL,
  description TEXT NOT NULL,
  category TEXT,
  merchant TEXT,
  date TIMESTAMPTZ DEFAULT NOW(),
  status TEXT DEFAULT 'completed' CHECK (status IN ('pending', 'completed', 'flagged'))
);

-- 4. Asset Allocations
CREATE TABLE asset_allocations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  category TEXT NOT NULL,
  percentage DECIMAL(5,2) NOT NULL,
  value DECIMAL(15,2) NOT NULL,
  color TEXT,
  icon TEXT
);

-- 5. Savings Goals
CREATE TABLE savings_goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  target_amount DECIMAL(15,2) NOT NULL,
  current_amount DECIMAL(15,2) DEFAULT 0,
  goal_type TEXT DEFAULT 'general' CHECK (goal_type IN ('rainy_day', 'general')),
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'completed', 'paused'))
);

-- 6. Round Up Savings
CREATE TABLE round_up_savings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  transaction_id UUID REFERENCES transactions(id),
  original_amount DECIMAL(10,2) NOT NULL,
  rounded_amount DECIMAL(10,2) NOT NULL,
  saved_amount DECIMAL(10,2) NOT NULL,
  merchant TEXT,
  category TEXT,
  date TIMESTAMPTZ DEFAULT NOW()
);

-- 7. Market Insights
CREATE TABLE market_insights (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  badge TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  badge_bg TEXT DEFAULT 'bg-surface-variant',
  badge_text TEXT DEFAULT 'text-on-surface-variant',
  time_label TEXT,
  category TEXT,
  published_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. Vendors (SME)
CREATE TABLE vendors (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  icon TEXT,
  health_score INTEGER DEFAULT 50,
  status TEXT DEFAULT 'stable',
  monthly_spend DECIMAL(12,2) DEFAULT 0,
  badge TEXT,
  badge_bg TEXT,
  badge_text TEXT
);

-- 9. Payroll Tasks (SME)
CREATE TABLE payroll_tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('overdue', 'completed', 'pending')),
  due_date DATE
);

-- 10. Projects (Freelancer)
CREATE TABLE projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  client TEXT,
  amount DECIMAL(12,2) DEFAULT 0,
  status TEXT DEFAULT 'In Progress'
);

-- 11. Network Contacts (Entrepreneur)
CREATE TABLE network_contacts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  role TEXT,
  avatar_url TEXT
);

-- 12. Fraud Events
CREATE TABLE fraud_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  event_type TEXT NOT NULL,
  description TEXT,
  severity TEXT DEFAULT 'info' CHECK (severity IN ('info', 'warning', 'critical')),
  timestamp TIMESTAMPTZ DEFAULT NOW()
);

-- 13. Linked Accounts
CREATE TABLE linked_accounts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  bank_name TEXT NOT NULL,
  account_type TEXT,
  account_number TEXT,
  balance DECIMAL(15,2) DEFAULT 0
);

-- 14. AI Suggestions
CREATE TABLE ai_suggestions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  type TEXT,
  potential_savings DECIMAL(12,2),
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'dismissed', 'executed')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 15. Security Metrics
CREATE TABLE security_metrics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  score INTEGER DEFAULT 98,
  encryption_level TEXT DEFAULT 'AES-256',
  identity_verified BOOLEAN DEFAULT true,
  last_login TIMESTAMPTZ DEFAULT NOW(),
  active_devices INTEGER DEFAULT 1,
  UNIQUE(user_id)
);

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE asset_allocations ENABLE ROW LEVEL SECURITY;
ALTER TABLE savings_goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE round_up_savings ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendors ENABLE ROW LEVEL SECURITY;
ALTER TABLE payroll_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE network_contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE fraud_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE linked_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_suggestions ENABLE ROW LEVEL SECURITY;
ALTER TABLE security_metrics ENABLE ROW LEVEL SECURITY;

-- RLS Policies - users can only access their own data
CREATE POLICY "Users can view own profile" ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can view own preferences" ON user_preferences FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own preferences" ON user_preferences FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can view own transactions" ON transactions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own transactions" ON transactions FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view own allocations" ON asset_allocations FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can view own savings" ON savings_goals FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can view own roundups" ON round_up_savings FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can view own vendors" ON vendors FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can view own payroll" ON payroll_tasks FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can view own projects" ON projects FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can view own contacts" ON network_contacts FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can view own fraud events" ON fraud_events FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can view own accounts" ON linked_accounts FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can view own AI suggestions" ON ai_suggestions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can view own security metrics" ON security_metrics FOR SELECT USING (auth.uid() = user_id);

-- Auto-create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, email, phone, account_id)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', 'User'),
    NEW.email,
    NEW.raw_user_meta_data->>'phone',
    'FV-' || upper(substr(md5(random()::text), 1, 6))
  );
  INSERT INTO public.security_metrics (id, user_id) VALUES (gen_random_uuid(), NEW.id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Seed data for market insights
INSERT INTO market_insights (badge, title, description, badge_bg, badge_text, time_label, category) VALUES
('Bullish', 'Renewable Energy Pivot', 'AI signals identify a 12% upside in European energy stocks over the next quarter due to policy shifts.', 'bg-secondary-container', 'text-on-secondary-container', '2 hours ago', 'stocks'),
('Neutral', 'Quarterly Tech Volatility', 'Expected sideways movement for major indices. Finovault recommends a hedging strategy on NASDAQ holdings.', 'bg-surface-variant', 'text-on-surface-variant', '5 hours ago', 'stocks');
