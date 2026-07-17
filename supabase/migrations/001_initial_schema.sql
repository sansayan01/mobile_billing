-- ============================================================
-- 001_initial_schema.sql
-- Flutter Billing App — Phone Accessories Shop
-- Initial schema: tables, indexes, triggers, RLS policies
-- ============================================================

BEGIN;

-- ------------------------------------------------------------
-- 1. TABLES
-- ------------------------------------------------------------

-- 1.1 profiles — extends Supabase auth.users
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  email TEXT,
  name TEXT,
  role TEXT NOT NULL DEFAULT 'staff' CHECK (role IN ('owner', 'staff')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 1.2 categories
CREATE TABLE categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 1.3 products
CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
  price DECIMAL(10,2) NOT NULL,
  stock INTEGER NOT NULL DEFAULT 0,
  location TEXT,
  barcode TEXT UNIQUE,
  qr_data TEXT,
  image_url TEXT,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 1.4 locations
CREATE TABLE locations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 1.5 bills
CREATE TABLE bills (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  staff_id UUID REFERENCES profiles(id),
  customer_name TEXT,
  total_amount DECIMAL(10,2) NOT NULL,
  discount DECIMAL(10,2) DEFAULT 0,
  grand_total DECIMAL(10,2) NOT NULL,
  payment_method TEXT DEFAULT 'cash' CHECK (payment_method IN ('cash', 'upi', 'card')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 1.6 bill_items
CREATE TABLE bill_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  bill_id UUID REFERENCES bills(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id),
  product_name TEXT,
  quantity INTEGER NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  total DECIMAL(10,2) NOT NULL
);

-- 1.7 inventory_log
CREATE TABLE inventory_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID REFERENCES products(id),
  change_type TEXT NOT NULL CHECK (change_type IN ('add', 'sell', 'remove', 'return')),
  quantity INTEGER NOT NULL,
  staff_id UUID REFERENCES profiles(id),
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ------------------------------------------------------------
-- 2. INDEXES
-- ------------------------------------------------------------

-- products
CREATE INDEX idx_products_barcode ON products(barcode);
CREATE INDEX idx_products_category_id ON products(category_id);

-- bills
CREATE INDEX idx_bills_staff_id ON bills(staff_id);
CREATE INDEX idx_bills_created_at ON bills(created_at);

-- bill_items
CREATE INDEX idx_bill_items_bill_id ON bill_items(bill_id);

-- inventory_log
CREATE INDEX idx_inventory_log_product_id ON inventory_log(product_id);
CREATE INDEX idx_inventory_log_created_at ON inventory_log(created_at);

-- ------------------------------------------------------------
-- 3. TRIGGER — auto-create profile on signup
-- ------------------------------------------------------------

CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = ''
AS $$
BEGIN
  INSERT INTO profiles (id, email, name, role)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data ->> 'name', SPLIT_PART(NEW.email, '@', 1)),
    'staff'
  );
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_user();

-- ------------------------------------------------------------
-- 4. RLS POLICIES
-- ------------------------------------------------------------

-- 4.0 Helper function
CREATE OR REPLACE FUNCTION is_owner()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER SET search_path = ''
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM profiles
    WHERE id = auth.uid()
      AND role = 'owner'
  );
$$;

-- ------------------------------------------------------------
-- 4.1 profiles
-- ------------------------------------------------------------
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read profiles"
  ON profiles FOR SELECT
  USING (true);

CREATE POLICY "Users can update their own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Only owner can update role field"
  ON profiles FOR UPDATE
  USING (is_owner())
  WITH CHECK (is_owner());

-- ------------------------------------------------------------
-- 4.2 categories
-- ------------------------------------------------------------
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can read categories"
  ON categories FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "Only owner can insert categories"
  ON categories FOR INSERT
  WITH CHECK (is_owner());

CREATE POLICY "Only owner can update categories"
  ON categories FOR UPDATE
  USING (is_owner())
  WITH CHECK (is_owner());

CREATE POLICY "Only owner can delete categories"
  ON categories FOR DELETE
  USING (is_owner());

-- ------------------------------------------------------------
-- 4.3 products
-- ------------------------------------------------------------
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can read products"
  ON products FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "Only owner can insert products"
  ON products FOR INSERT
  WITH CHECK (is_owner());

CREATE POLICY "Only owner can update products"
  ON products FOR UPDATE
  USING (is_owner())
  WITH CHECK (is_owner());

CREATE POLICY "Only owner can delete products"
  ON products FOR DELETE
  USING (is_owner());

-- ------------------------------------------------------------
-- 4.4 locations
-- ------------------------------------------------------------
ALTER TABLE locations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can read locations"
  ON locations FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "Only owner can insert locations"
  ON locations FOR INSERT
  WITH CHECK (is_owner());

CREATE POLICY "Only owner can update locations"
  ON locations FOR UPDATE
  USING (is_owner())
  WITH CHECK (is_owner());

CREATE POLICY "Only owner can delete locations"
  ON locations FOR DELETE
  USING (is_owner());

-- ------------------------------------------------------------
-- 4.5 bills
-- ------------------------------------------------------------
ALTER TABLE bills ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Staff can read own bills"
  ON bills FOR SELECT
  USING (
    auth.uid() = staff_id
    OR
    is_owner()
  );

CREATE POLICY "Staff can insert bills"
  ON bills FOR INSERT
  WITH CHECK (
    auth.uid() = staff_id
    OR
    is_owner()
  );

CREATE POLICY "Only owner can update bills"
  ON bills FOR UPDATE
  USING (is_owner())
  WITH CHECK (is_owner());

CREATE POLICY "Only owner can delete bills"
  ON bills FOR DELETE
  USING (is_owner());

-- ------------------------------------------------------------
-- 4.6 bill_items
-- ------------------------------------------------------------
ALTER TABLE bill_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can read bill_items"
  ON bill_items FOR SELECT
  USING (
    EXISTS (
      SELECT 1
      FROM bills
      WHERE bills.id = bill_items.bill_id
        AND (bills.staff_id = auth.uid() OR is_owner())
    )
  );

CREATE POLICY "Staff can insert bill_items"
  ON bill_items FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1
      FROM bills
      WHERE bills.id = bill_items.bill_id
        AND (bills.staff_id = auth.uid() OR is_owner())
    )
  );

CREATE POLICY "Only owner can delete bill_items"
  ON bill_items FOR DELETE
  USING (is_owner());

-- ------------------------------------------------------------
-- 4.7 inventory_log
-- ------------------------------------------------------------
ALTER TABLE inventory_log ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can read inventory_log"
  ON inventory_log FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "Staff can insert inventory_log"
  ON inventory_log FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Only owner can delete inventory_log"
  ON inventory_log FOR DELETE
  USING (is_owner());

COMMIT;
