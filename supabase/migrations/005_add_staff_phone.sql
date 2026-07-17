-- ============================================================
-- 005_add_staff_phone.sql
-- Flutter Billing App — add phone column to profiles
-- (Staff management needs a contact number per user)
-- ============================================================

BEGIN;

-- ------------------------------------------------------------
-- profiles → phone (nullable, no RLS change needed:
--   003_saas_shops.sql already scopes owner/staff reads
--   and owner writes on the profiles table.)
-- ------------------------------------------------------------
ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS phone TEXT;

COMMIT;
