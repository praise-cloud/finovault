-- Store hashed recovery codes per user
-- Only accessed via backend service role key (bypasses RLS), so no RLS needed
CREATE TABLE IF NOT EXISTS recovery_codes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  code_hash TEXT NOT NULL,
  used BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_recovery_codes_user_id ON recovery_codes(user_id);
CREATE INDEX IF NOT EXISTS idx_recovery_codes_lookup ON recovery_codes(user_id, code_hash);
