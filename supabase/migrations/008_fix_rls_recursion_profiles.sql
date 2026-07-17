-- ============================================================
-- 008_fix_rls_recursion_profiles.sql
-- Flutter Billing App — fix infinite recursion in profiles RLS
-- ============================================================
-- ROOT CAUSE:
-- The profiles SELECT policy had a self-referential subquery:
--   (SELECT p.shop_id FROM profiles p WHERE id = auth.uid())
-- This triggers RLS on profiles AGAIN while evaluating RLS on profiles
-- → infinite recursion → "infinite recursion detected in policy"
-- This cascaded into category/product inserts failing because:
--   - belongs_to_shop() reads profiles (triggers RLS → recursion → error)
--   - _resolveShopId in Flutter reads profiles (same problem)
-- FIX:
-- 1. Create get_my_shop_id() as SECURITY DEFINER — bypasses RLS
--    when called from within a policy context (same as is_owner/is_super_admin)
-- 2. Replace the self-referential subquery with get_my_shop_id()
-- ============================================================

BEGIN;

-- 1) Helper function: get current user's shop_id without RLS recursion
CREATE OR REPLACE FUNCTION get_my_shop_id()
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER SET search_path = ''
AS $$
  SELECT shop_id FROM public.profiles WHERE id = auth.uid();
$$;

-- 2) Fix the profiles SELECT policy — replace recursive subquery
DROP POLICY IF EXISTS "Users can read profiles in their shop context" ON profiles;

CREATE POLICY "Users can read profiles in their shop context"
  ON profiles FOR SELECT
  USING (
    is_super_admin()
    OR
    is_owner()
    OR
    (
      shop_id IS NOT NULL
      AND shop_id = get_my_shop_id()
    )
  );

COMMIT;
