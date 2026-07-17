-- ============================================================
-- 006_three_tier_roles.sql
-- Flutter Billing App — 3-tier role system
--   1. super_admin  → SaaS product admin, cross-shop access
--   2. owner        → shop owner, auto-assigned on signup,
--                      gets their own shop auto-created
--   3. staff        → employee added by an owner
-- ============================================================

BEGIN;

-- ------------------------------------------------------------
-- 1. EXTEND role CHECK constraint → 3 tiers
-- ------------------------------------------------------------
ALTER TABLE profiles
  DROP CONSTRAINT IF EXISTS profiles_role_check;

ALTER TABLE profiles
  ADD CONSTRAINT profiles_role_check
  CHECK (role IN ('super_admin', 'owner', 'staff'));

-- ------------------------------------------------------------
-- 2. HELPER — is the current auth user a super admin?
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION is_super_admin()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER SET search_path = ''
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.profiles
    WHERE id = auth.uid()
      AND role = 'super_admin'
  );
$$;

-- ------------------------------------------------------------
-- 3. REWRITE signup trigger
--    New signups become an OWNER and get their own shop auto-created.
--    (super_admin is assigned manually by an existing admin — never
--     via self-signup.)
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = ''
AS $$
DECLARE
  new_shop_id UUID;
  shop_name   TEXT;
BEGIN
  -- Determine a sensible default shop name from signup metadata.
  shop_name := COALESCE(
    NEW.raw_user_meta_data ->> 'shop_name',
    NEW.raw_user_meta_data ->> 'name',
    SPLIT_PART(NEW.email, '@', 1) || '''s Shop'
  );

  -- Auto-create the owner's shop.
  INSERT INTO public.shops (owner_id, name)
  VALUES (NEW.id, shop_name)
  RETURNING id INTO new_shop_id;

  -- Create the profile as OWNER, linked to the new shop.
  INSERT INTO public.profiles (id, email, name, role, shop_id)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data ->> 'name', SPLIT_PART(NEW.email, '@', 1)),
    'owner',
    new_shop_id
  );

  RETURN NEW;
END;
$$;

-- (Trigger on_auth_user_created already exists from 001 and now
--  points at the rewritten function — no recreate needed, but ensure
--  it is present in case it was dropped.)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_user();

-- ------------------------------------------------------------
-- 4. RLS — super_admin cross-shop access
--    We bolt a super_admin bypass onto every business table policy.
--    is_super_admin() short-circuits the per-shop scoping.
-- ------------------------------------------------------------

-- 4.1 profiles — super_admin can read/update ALL profiles
DROP POLICY IF EXISTS "Users can read profiles in their shop context" ON profiles;
CREATE POLICY "Users can read profiles in their shop context"
  ON profiles FOR SELECT
  USING (
    is_super_admin()
    OR is_owner()
    OR (
      shop_id IS NOT NULL
      AND shop_id = (SELECT p.shop_id FROM profiles p WHERE p.id = auth.uid())
    )
  );

-- Super admin may update any profile (incl. promoting/demoting roles).
DROP POLICY IF EXISTS "Only owner can update role field" ON profiles;
CREATE POLICY "Owners and super admin can update profiles"
  ON profiles FOR UPDATE
  USING (is_super_admin() OR is_owner() OR auth.uid() = id)
  WITH CHECK (is_super_admin() OR is_owner() OR auth.uid() = id);

-- 4.2 shops — super_admin sees/manages all shops
DROP POLICY IF EXISTS "Owner can select own shop" ON shops;
CREATE POLICY "Owner or super admin can select shops"
  ON shops FOR SELECT
  USING (is_super_admin() OR auth.uid() = owner_id);

DROP POLICY IF EXISTS "Owner can update own shop" ON shops;
CREATE POLICY "Owner or super admin can update shops"
  ON shops FOR UPDATE
  USING (is_super_admin() OR auth.uid() = owner_id)
  WITH CHECK (is_super_admin() OR auth.uid() = owner_id);

DROP POLICY IF EXISTS "Owner can delete own shop" ON shops;
CREATE POLICY "Owner or super admin can delete shops"
  ON shops FOR DELETE
  USING (is_super_admin() OR auth.uid() = owner_id);

-- 4.3 categories — super_admin full access (cross-shop)
DROP POLICY IF EXISTS "Shop members can read own shop categories" ON categories;
CREATE POLICY "Shop members or super admin can read categories"
  ON categories FOR SELECT
  USING (is_super_admin() OR belongs_to_shop(shop_id));

DROP POLICY IF EXISTS "Shop owner can insert own shop categories" ON categories;
CREATE POLICY "Shop owner or super admin can insert categories"
  ON categories FOR INSERT
  WITH CHECK (is_super_admin() OR belongs_to_shop(shop_id));

DROP POLICY IF EXISTS "Shop owner can update own shop categories" ON categories;
CREATE POLICY "Shop owner or super admin can update categories"
  ON categories FOR UPDATE
  USING (is_super_admin() OR belongs_to_shop(shop_id))
  WITH CHECK (is_super_admin() OR belongs_to_shop(shop_id));

DROP POLICY IF EXISTS "Shop owner can delete own shop categories" ON categories;
CREATE POLICY "Shop owner or super admin can delete categories"
  ON categories FOR DELETE
  USING (is_super_admin() OR belongs_to_shop(shop_id));

-- 4.4 products
DROP POLICY IF EXISTS "Shop members can read own shop products" ON products;
CREATE POLICY "Shop members or super admin can read products"
  ON products FOR SELECT
  USING (is_super_admin() OR belongs_to_shop(shop_id));

DROP POLICY IF EXISTS "Shop owner can insert own shop products" ON products;
CREATE POLICY "Shop owner or super admin can insert products"
  ON products FOR INSERT
  WITH CHECK (is_super_admin() OR belongs_to_shop(shop_id));

DROP POLICY IF EXISTS "Shop owner can update own shop products" ON products;
CREATE POLICY "Shop owner or super admin can update products"
  ON products FOR UPDATE
  USING (is_super_admin() OR belongs_to_shop(shop_id))
  WITH CHECK (is_super_admin() OR belongs_to_shop(shop_id));

DROP POLICY IF EXISTS "Shop owner can delete own shop products" ON products;
CREATE POLICY "Shop owner or super admin can delete products"
  ON products FOR DELETE
  USING (is_super_admin() OR belongs_to_shop(shop_id));

-- 4.5 bills
DROP POLICY IF EXISTS "Shop members can read own shop bills" ON bills;
CREATE POLICY "Shop members or super admin can read bills"
  ON bills FOR SELECT
  USING (is_super_admin() OR belongs_to_shop(shop_id));

DROP POLICY IF EXISTS "Shop staff can insert own shop bills" ON bills;
CREATE POLICY "Shop staff or super admin can insert bills"
  ON bills FOR INSERT
  WITH CHECK (is_super_admin() OR belongs_to_shop(shop_id));

DROP POLICY IF EXISTS "Shop owner can update own shop bills" ON bills;
CREATE POLICY "Shop owner or super admin can update bills"
  ON bills FOR UPDATE
  USING (is_super_admin() OR belongs_to_shop(shop_id))
  WITH CHECK (is_super_admin() OR belongs_to_shop(shop_id));

DROP POLICY IF EXISTS "Shop owner can delete own shop bills" ON bills;
CREATE POLICY "Shop owner or super admin can delete bills"
  ON bills FOR DELETE
  USING (is_super_admin() OR belongs_to_shop(shop_id));

-- 4.6 bill_items
DROP POLICY IF EXISTS "Shop members can read own shop bill_items" ON bill_items;
CREATE POLICY "Shop members or super admin can read bill_items"
  ON bill_items FOR SELECT
  USING (
    is_super_admin()
    OR EXISTS (
      SELECT 1 FROM bills
      WHERE bills.id = bill_items.bill_id
        AND belongs_to_shop(bills.shop_id)
    )
  );

DROP POLICY IF EXISTS "Shop staff can insert own shop bill_items" ON bill_items;
CREATE POLICY "Shop staff or super admin can insert bill_items"
  ON bill_items FOR INSERT
  WITH CHECK (is_super_admin() OR belongs_to_shop(shop_id));

DROP POLICY IF EXISTS "Shop owner can delete own shop bill_items" ON bill_items;
CREATE POLICY "Shop owner or super admin can delete bill_items"
  ON bill_items FOR DELETE
  USING (is_super_admin() OR belongs_to_shop(shop_id));

-- 4.7 inventory_log
DROP POLICY IF EXISTS "Shop members can read own shop inventory_log" ON inventory_log;
CREATE POLICY "Shop members or super admin can read inventory_log"
  ON inventory_log FOR SELECT
  USING (is_super_admin() OR belongs_to_shop(shop_id));

DROP POLICY IF EXISTS "Shop staff can insert own shop inventory_log" ON inventory_log;
CREATE POLICY "Shop staff or super admin can insert inventory_log"
  ON inventory_log FOR INSERT
  WITH CHECK (is_super_admin() OR belongs_to_shop(shop_id));

DROP POLICY IF EXISTS "Shop owner can delete own shop inventory_log" ON inventory_log;
CREATE POLICY "Shop owner or super admin can delete inventory_log"
  ON inventory_log FOR DELETE
  USING (is_super_admin() OR belongs_to_shop(shop_id));

COMMIT;
