-- Add warranty columns to products table
ALTER TABLE products ADD COLUMN IF NOT EXISTS warranty_type TEXT DEFAULT 'none';
ALTER TABLE products ADD COLUMN IF NOT EXISTS warranty_duration INTEGER;
ALTER TABLE products ADD COLUMN IF NOT EXISTS warranty_unit TEXT;

-- Add warranty columns to bill_items table
ALTER TABLE bill_items ADD COLUMN IF NOT EXISTS warranty_type TEXT DEFAULT 'none';
ALTER TABLE bill_items ADD COLUMN IF NOT EXISTS warranty_duration INTEGER;
ALTER TABLE bill_items ADD COLUMN IF NOT EXISTS warranty_unit TEXT;

-- Create warranty_claims table
CREATE TABLE IF NOT EXISTS warranty_claims (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  bill_id UUID REFERENCES bills(id) ON DELETE SET NULL,
  product_id UUID REFERENCES products(id) ON DELETE SET NULL,
  product_name TEXT,
  customer_name TEXT,
  customer_phone TEXT,
  claim_reason TEXT NOT NULL,
  claim_status TEXT DEFAULT 'pending',
  claim_type TEXT DEFAULT 'warranty',
  warranty_duration INTEGER,
  warranty_unit TEXT,
  claimed_by_staff_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
  staff_name TEXT,
  shop_id TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS on warranty_claims
ALTER TABLE warranty_claims ENABLE ROW LEVEL SECURITY;

-- Add RLS policies for warranty_claims
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Allow authenticated read warranty claims' AND tablename = 'warranty_claims') THEN
    CREATE POLICY "Allow authenticated read warranty claims" ON warranty_claims
      FOR SELECT TO authenticated USING (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Allow authenticated insert warranty claims' AND tablename = 'warranty_claims') THEN
    CREATE POLICY "Allow authenticated insert warranty claims" ON warranty_claims
      FOR INSERT TO authenticated WITH CHECK (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Allow authenticated update warranty claims' AND tablename = 'warranty_claims') THEN
    CREATE POLICY "Allow authenticated update warranty claims" ON warranty_claims
      FOR UPDATE TO authenticated USING (true);
  END IF;
END $$;
