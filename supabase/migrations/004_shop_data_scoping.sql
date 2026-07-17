-- ============================================================
-- 004_shop_data_scoping.sql
-- Flutter Billing App — Multi-tenant data isolation
-- Each shop's products/categories/bills/inventory are scoped by shop_id.
-- App-side: every query filters by shop_id = current user's profiles.shop_id.
-- DB-side: RLS rewritten to scope rows to the caller's shop.
-- ============================================================

BEGIN;

-- ------------------------------------------------------------
-- 1. ADD shop_id COLUMN (nullable FK to shops) to business tables
--    Nullable so existing rows don't break; app always writes it going forward.
-- ------------------------------------------------------------

ALTER TABLE products
  ADD COLUMN IF NOT EXISTS shop_id UUID REFERENCES shops(id) ON DELETE CASCADE;

ALTER TABLE categories
  ADD COLUMN IF NOT EXISTS shop_id UUID REFERENCES shops(id) ON DELETE CASCADE;

ALTER TABLE bills
  ADD COLUMN IF NOT EXISTS shop_id UUID REFERENCES shops(id) ON DELETE CASCADE;

ALTER TABLE bill_items
  ADD COLUMN IF NOT EXISTS shop_id UUID REFERENCES shops(id) ON DELETE CASCADE;

ALTER TABLE inventory_log
  ADD COLUMN IF NOT EXISTS shop_id UUID REFERENCES shops(id) ON DELETE CASCADE;

-- ------------------------------------------------------------
-- 2. INDEXES for tenant-scoped lookups
-- ------------------------------------------------------------

CREATE INDEX IF NOT EXISTS idx_products_shop_id ON products(shop_id);
CREATE INDEX IF NOT EXISTS idx_categories_shop_id ON categories(shop_id);
CREATE INDEX IF NOT EXISTS idx_bills_shop_id ON bills(shop_id);
CREATE INDEX IF NOT EXISTS idx_bill_items_shop_id ON bill_items(shop_id);
CREATE INDEX IF NOT EXISTS idx_inventory_log_shop_id ON inventory_log(shop_id);

-- ------------------------------------------------------------
-- 3. HELPER — does the current auth user belong to the given shop?
--    Reads the caller's own profile.shop_id and compares.
-- ------------------------------------------------------------

CREATE OR REPLACE FUNCTION user_shop_id()
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER SET search_path = ''
AS $$
  SELECT shop_id FROM public.profiles WHERE id = auth.uid();
$$;

CREATE OR REPLACE FUNCTION belongs_to_shop(target_shop_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER SET search_path = ''
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid()
      AND shop_id IS NOT NULL
      AND shop_id = target_shop_id
  );
$$;

-- ------------------------------------------------------------
-- 4. DROP old open/global RLS policies, replace with shop-scoped ones
-- ------------------------------------------------------------

-- 4.2 categories
DROP POLICY IF EXISTS "Authenticated users can read categories" ON categories;
DROP POLICY IF EXISTS "Only owner can insert categories" ON categories;
DROP POLICY IF EXISTS "Only owner can update categories" ON categories;
DROP POLICY IF EXISTS "Only owner can delete categories" ON categories;

CREATE POLICY "Shop members can read own shop categories"
  ON categories FOR SELECT
  USING (belongs_to_shop(shop_id));

CREATE POLICY "Shop owner can insert own shop categories"
  ON categories FOR INSERT
  WITH CHECK (belongs_to_shop(shop_id));

CREATE POLICY "Shop owner can update own shop categories"
  ON categories FOR UPDATE
  USING (belongs_to_shop(shop_id))
  WITH CHECK (belongs_to_shop(shop_id));

CREATE POLICY "Shop owner can delete own shop categories"
  ON categories FOR DELETE
  USING (belongs_to_shop(shop_id));

-- 4.3 products
DROP POLICY IF EXISTS "Authenticated users can read products" ON products;
DROP POLICY IF EXISTS "Only owner can insert products" ON products;
DROP POLICY IF EXISTS "Only owner can update products" ON products;
DROP POLICY IF EXISTS "Only owner can delete products" ON products;

CREATE POLICY "Shop members can read own shop products"
  ON products FOR SELECT
  USING (belongs_to_shop(shop_id));

CREATE POLICY "Shop owner can insert own shop products"
  ON products FOR INSERT
  WITH CHECK (belongs_to_shop(shop_id));

CREATE POLICY "Shop owner can update own shop products"
  ON products FOR UPDATE
  USING (belongs_to_shop(shop_id))
  WITH CHECK (belongs_to_shop(shop_id));

CREATE POLICY "Shop owner can delete own shop products"
  ON products FOR DELETE
  USING (belongs_to_shop(shop_id));

-- 4.5 bills
DROP POLICY IF EXISTS "Staff can read own bills" ON bills;
DROP POLICY IF EXISTS "Staff can insert bills" ON bills;
DROP POLICY IF EXISTS "Only owner can update bills" ON bills;
DROP POLICY IF EXISTS "Only owner can delete bills" ON bills;

CREATE POLICY "Shop members can read own shop bills"
  ON bills FOR SELECT
  USING (belongs_to_shop(shop_id));

CREATE POLICY "Shop staff can insert own shop bills"
  ON bills FOR INSERT
  WITH CHECK (belongs_to_shop(shop_id));

CREATE POLICY "Shop owner can update own shop bills"
  ON bills FOR UPDATE
  USING (belongs_to_shop(shop_id))
  WITH CHECK (belongs_to_shop(shop_id));

CREATE POLICY "Shop owner can delete own shop bills"
  ON bills FOR DELETE
  USING (belongs_to_shop(shop_id));

-- 4.6 bill_items — scope by the parent bill's shop_id
DROP POLICY IF EXISTS "Authenticated users can read bill_items" ON bill_items;
DROP POLICY IF EXISTS "Staff can insert bill_items" ON bill_items;
DROP POLICY IF EXISTS "Only owner can delete bill_items" ON bill_items;

CREATE POLICY "Shop members can read own shop bill_items"
  ON bill_items FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM bills
      WHERE bills.id = bill_items.bill_id
        AND belongs_to_shop(bills.shop_id)
    )
  );

CREATE POLICY "Shop staff can insert own shop bill_items"
  ON bill_items FOR INSERT
  WITH CHECK (belongs_to_shop(shop_id));

CREATE POLICY "Shop owner can delete own shop bill_items"
  ON bill_items FOR DELETE
  USING (belongs_to_shop(shop_id));

-- 4.7 inventory_log — scope by the product's shop_id
DROP POLICY IF EXISTS "Authenticated users can read inventory_log" ON inventory_log;
DROP POLICY IF EXISTS "Staff can insert inventory_log" ON inventory_log;
DROP POLICY IF EXISTS "Only owner can delete inventory_log" ON inventory_log;

CREATE POLICY "Shop members can read own shop inventory_log"
  ON inventory_log FOR SELECT
  USING (belongs_to_shop(shop_id));

CREATE POLICY "Shop staff can insert own shop inventory_log"
  ON inventory_log FOR INSERT
  WITH CHECK (belongs_to_shop(shop_id));

CREATE POLICY "Shop owner can delete own shop inventory_log"
  ON inventory_log FOR DELETE
  USING (belongs_to_shop(shop_id));

COMMIT;
