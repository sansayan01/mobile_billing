-- ============================================================
-- 017_customers_link_bills_warranty.sql
-- Flutter Billing App — Customer CMS (v1)
-- Merged: recreate customers with TEXT shop_id (no FK, matches
-- repo convention where shop_id is a String and business tables
-- have no FK/RLS enforcement) + link bills/warranty via customer_id.
-- NOTE: 016 already created customers with UUID shop_id + FK which
-- FAILED on 018 (text vs uuid). This migration drops + recreates
-- customers correctly, so 016's table is superseded here.
-- ============================================================

BEGIN;

-- 1. Drop the partially-created customers table from 016 (empty, safe)
DROP TABLE IF EXISTS customers;

-- 2. Recreate customers with TEXT shop_id (no FK to shops)
--    Repo treats shopId as String; existing bills/warranty use TEXT shop_id.
CREATE TABLE customers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  shop_id TEXT NOT NULL,
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (shop_id, phone)
);

CREATE INDEX idx_customers_shop_phone ON customers (shop_id, phone);
CREATE INDEX idx_customers_shop_name ON customers (shop_id, name);

-- 3. Link bills + warranty_claims via customer_id (nullable FK, safe)
ALTER TABLE bills
  ADD COLUMN IF NOT EXISTS customer_id UUID REFERENCES customers(id) ON DELETE SET NULL;

ALTER TABLE warranty_claims
  ADD COLUMN IF NOT EXISTS customer_id UUID REFERENCES customers(id) ON DELETE SET NULL;

-- 4. Backfill existing rows by normalized phone match within same shop
--    bills.shop_id is UUID, customers.shop_id is TEXT -> cast bills to TEXT
--    so the comparison type-matches (warranty_claims.shop_id is already TEXT).
UPDATE bills b
SET customer_id = c.id
FROM customers c
WHERE b.customer_phone = c.phone
  AND b.shop_id::TEXT = c.shop_id
  AND b.customer_id IS NULL;

UPDATE warranty_claims w
SET customer_id = c.id
FROM customers c
WHERE w.customer_phone = c.phone
  AND w.shop_id = c.shop_id
  AND w.customer_id IS NULL;

-- 5. Indexes for history lookups
CREATE INDEX IF NOT EXISTS idx_bills_customer_id ON bills (customer_id);
CREATE INDEX IF NOT EXISTS idx_warranty_customer_id ON warranty_claims (customer_id);

COMMIT;
