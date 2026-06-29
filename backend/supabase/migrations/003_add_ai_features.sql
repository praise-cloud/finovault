-- Finovault AI - AI Features Schema
-- Add new tables for Steps 2-8 of the Finovault vision

-- 16. Financial Profiles (Step 2 - Interview answers)
CREATE TABLE IF NOT EXISTS financial_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  employment_status TEXT,
  income_range TEXT,
  pay_frequency TEXT,
  has_business BOOLEAN DEFAULT false,
  marital_status TEXT,
  has_children BOOLEAN DEFAULT false,
  children_count INTEGER DEFAULT 0,
  financial_goals TEXT[] DEFAULT '{}',
  money_fears TEXT[] DEFAULT '{}',
  saves_money BOOLEAN DEFAULT false,
  invests BOOLEAN DEFAULT false,
  has_loans BOOLEAN DEFAULT false,
  risk_tolerance TEXT DEFAULT 'moderate',
  financial_literacy_score INTEGER DEFAULT 50,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id)
);

-- 17. Behavior Patterns (Step 4 - Learned patterns)
CREATE TABLE IF NOT EXISTS behavior_patterns (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  pattern_type TEXT NOT NULL,
  pattern_name TEXT NOT NULL,
  description TEXT,
  category TEXT,
  frequency TEXT,
  confidence_score DECIMAL(5,2) DEFAULT 0,
  detected_at TIMESTAMPTZ DEFAULT NOW(),
  last_observed_at TIMESTAMPTZ DEFAULT NOW(),
  metadata JSONB DEFAULT '{}',
  UNIQUE(user_id, pattern_type, pattern_name)
);

-- 18. AI Conversations (Step 5 - Chat history)
CREATE TABLE IF NOT EXISTS ai_conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  session_id UUID NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('user', 'assistant')),
  content TEXT NOT NULL,
  context JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 19. Scam Database (Step 6 - Known fraud patterns)
CREATE TABLE IF NOT EXISTS scam_database (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pattern_type TEXT NOT NULL,
  pattern_signature TEXT NOT NULL,
  description TEXT,
  severity TEXT DEFAULT 'medium',
  source TEXT DEFAULT 'internal',
  reported_at TIMESTAMPTZ DEFAULT NOW(),
  active BOOLEAN DEFAULT true
);

-- 20. Business Health Snapshots (Step 7)
CREATE TABLE IF NOT EXISTS business_health_snapshots (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  snapshot_date DATE NOT NULL DEFAULT CURRENT_DATE,
  revenue DECIMAL(15,2) DEFAULT 0,
  expenses DECIMAL(15,2) DEFAULT 0,
  profit DECIMAL(15,2) DEFAULT 0,
  cashflow_forecast DECIMAL(15,2)[] DEFAULT '{}',
  health_score INTEGER DEFAULT 50,
  ai_insight TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, snapshot_date)
);

-- 21. Morning Briefings (Step 8)
CREATE TABLE IF NOT EXISTS morning_briefings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  briefing_date DATE NOT NULL DEFAULT CURRENT_DATE,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  action_items JSONB DEFAULT '[]',
  read BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, briefing_date)
);

-- 22. Notifications
CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('alert', 'insight', 'coaching', 'fraud', 'milestone')),
  data JSONB DEFAULT '{}',
  read BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS on new tables
ALTER TABLE financial_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE behavior_patterns ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE scam_database ENABLE ROW LEVEL SECURITY;
ALTER TABLE business_health_snapshots ENABLE ROW LEVEL SECURITY;
ALTER TABLE morning_briefings ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- RLS Policies for new tables
CREATE POLICY "Users can manage own financial profile" ON financial_profiles
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can view own behavior patterns" ON behavior_patterns
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can view own conversations" ON ai_conversations
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own conversations" ON ai_conversations
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view own business snapshots" ON business_health_snapshots
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can view own morning briefings" ON morning_briefings
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own morning briefings" ON morning_briefings
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own notifications" ON notifications
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own notifications" ON notifications
  FOR UPDATE USING (auth.uid() = user_id);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_financial_profiles_user ON financial_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_behavior_patterns_user ON behavior_patterns(user_id);
CREATE INDEX IF NOT EXISTS idx_ai_conversations_user_session ON ai_conversations(user_id, session_id);
CREATE INDEX IF NOT EXISTS idx_business_snapshots_user_date ON business_health_snapshots(user_id, snapshot_date);
CREATE INDEX IF NOT EXISTS idx_morning_briefings_user_date ON morning_briefings(user_id, briefing_date);
CREATE INDEX IF NOT EXISTS idx_notifications_user_read ON notifications(user_id, read);
