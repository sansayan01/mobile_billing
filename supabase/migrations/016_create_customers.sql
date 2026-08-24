-- ============================================================
-- 016_create_customers.sql
-- Flutter Billing App — Customer CMS (v1): name + phone only
-- Shop isolation is Dart-side (.eq('shop_id')) — matches repo
-- convention (products/bills have NO RLS; profiles has RLS).
-- ============================================================

BEGIN;

-- 1. customers TABLE — har shop ke apne customers
CREATE TABLE customers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  shop_id UUID NOT NULL REFERENCES shops(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (shop_id, phone)
);

CREATE INDEX idx_customers_shop_phone ON customers (shop_id, phone);
CREATE INDEX idx_customers_shop_name ON customers (shop_id, name);

COMMIT;
