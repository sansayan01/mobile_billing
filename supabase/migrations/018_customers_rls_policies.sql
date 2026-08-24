-- ============================================================
-- 018_customers_rls_policies.sql
-- Flutter Billing App — Customer CMS (v1)
-- The customers table currently has RLS ENABLED on the live DB
-- (it blocks every insert/select with code 42501) but NO policy
-- was ever created for it (016/017 only built the table + indexes,
-- not RLS). This migration adds shop-scoped RLS policies so the
-- app can read/write customers again.
--
-- customers.shop_id is TEXT while belongs_to_shop() expects UUID,
-- so we cast (shop_id::UUID) at the policy boundary.
-- ============================================================

BEGIN;

-- 1. Make sure RLS is on (idempotent)
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;

-- 2. Drop any accidental/old policies so this migration is re-runnable
DROP POLICY IF EXISTS "Customers: owner can select" ON customers;
DROP POLICY IF EXISTS "Customers: owner can insert" ON customers;
DROP POLICY IF EXISTS "Customers: owner can update" ON customers;
DROP POLICY IF EXISTS "Customers: owner can delete" ON customers;

-- 3. SELECT — any authenticated user belonging to the customer's shop
--    (super admin can see everything).
CREATE POLICY "Customers: owner can select"
  ON customers
  FOR SELECT
  TO authenticated
  USING (
    is_super_admin()
    OR belongs_to_shop(shop_id::UUID)
  );

-- 4. INSERT — must belong to the shop you are inserting into
--    (super admin can insert anywhere).
CREATE POLICY "Customers: owner can insert"
  ON customers
  FOR INSERT
  TO authenticated
  WITH CHECK (
    is_super_admin()
    OR belongs_to_shop(shop_id::UUID)
  );

-- 5. UPDATE — only for your own shop
CREATE POLICY "Customers: owner can update"
  ON customers
  FOR UPDATE
  TO authenticated
  USING (
    is_super_admin()
    OR belongs_to_shop(shop_id::UUID)
  )
  WITH CHECK (
    is_super_admin()
    OR belongs_to_shop(shop_id::UUID)
  );

-- 6. DELETE — only for your own shop
CREATE POLICY "Customers: owner can delete"
  ON customers
  FOR DELETE
  TO authenticated
  USING (
    is_super_admin()
    OR belongs_to_shop(shop_id::UUID)
  );

COMMIT;
