-- Revoke excessive anon permissions (bypasses RLS)
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM anon;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM anon;
REVOKE USAGE ON SCHEMA public FROM anon;

-- Restore minimal schema usage for anon (needed for Supabase client)
GRANT USAGE ON SCHEMA public TO anon;

-- Only market_insights is public data (no user_id column)
GRANT SELECT ON market_insights TO anon;
