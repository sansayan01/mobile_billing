-- ============================================================
-- 019_audit_fixes.sql
-- Flutter Billing App — Audit fixes
-- (a) bills.item_count column (denormalized line-item count)
-- (b) products REPLICA IDENTITY FULL (Realtime UPDATE/DELETE events
--     need full old-row payload for reliable multi-user sync)
-- (c) warranty_claims RLS: replace open `USING (true)` policies from
--     010 with shop-scoped ones (belongs_to_shop pattern from 004),
--     and add the missing DELETE policy.
-- ============================================================

BEGIN;

-- ------------------------------------------------------------
-- (a) bills.item_count — default 0 so existing rows stay valid
-- ------------------------------------------------------------
ALTER TABLE bills
  ADD COLUMN IF NOT EXISTS item_count integer DEFAULT 0;

-- ------------------------------------------------------------
-- (b) Realtime: publish full row image for products updates/deletes
-- ------------------------------------------------------------
ALTER TABLE products REPLICA IDENTITY FULL;

-- ------------------------------------------------------------
-- (c) warranty_claims RLS — shop-scoped policies
--     NOTE: warranty_claims.shop_id is TEXT (see 010); values mirror
--     profiles.shop_id (UUID). Regex guard before ::uuid cast keeps
--     malformed rows from erroring the policy instead of just denying.
-- ------------------------------------------------------------

DROP POLICY IF EXISTS "Allow authenticated read warranty claims" ON warranty_claims;
DROP POLICY IF EXISTS "Allow authenticated insert warranty claims" ON warranty_claims;
DROP POLICY IF EXISTS "Allow authenticated update warranty claims" ON warranty_claims;
DROP POLICY IF EXISTS "Shop members can read own shop warranty claims" ON warranty_claims;
DROP POLICY IF EXISTS "Shop staff can insert own shop warranty claims" ON warranty_claims;
DROP POLICY IF EXISTS "Shop members can update own shop warranty claims" ON warranty_claims;
DROP POLICY IF EXISTS "Shop members can delete own shop warranty claims" ON warranty_claims;

CREATE POLICY "Shop members can read own shop warranty claims"
  ON warranty_claims FOR SELECT
  TO authenticated
  USING (
    shop_id IS NOT NULL
    AND shop_id ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
    AND belongs_to_shop((shop_id)::uuid)
  );

CREATE POLICY "Shop staff can insert own shop warranty claims"
  ON warranty_claims FOR INSERT
  TO authenticated
  WITH CHECK (
    shop_id IS NOT NULL
    AND shop_id ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
    AND belongs_to_shop((shop_id)::uuid)
  );

CREATE POLICY "Shop members can update own shop warranty claims"
  ON warranty_claims FOR UPDATE
  TO authenticated
  USING (
    shop_id IS NOT NULL
    AND shop_id ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
    AND belongs_to_shop((shop_id)::uuid)
  )
  WITH CHECK (
    shop_id IS NOT NULL
    AND shop_id ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
    AND belongs_to_shop((shop_id)::uuid)
  );

CREATE POLICY "Shop members can delete own shop warranty claims"
  ON warranty_claims FOR DELETE
  TO authenticated
  USING (
    shop_id IS NOT NULL
    AND shop_id ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
    AND belongs_to_shop((shop_id)::uuid)
  );

COMMIT;
