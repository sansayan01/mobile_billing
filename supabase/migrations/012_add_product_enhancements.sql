-- Migration 012: Add product management enhancements
-- Adds min_stock_level, unit columns to products table
-- Creates stock_adjustments table for tracking stock movements

-- 1. Add new columns to products table
ALTER TABLE products 
  ADD COLUMN IF NOT EXISTS min_stock_level INTEGER DEFAULT 5,
  ADD COLUMN IF NOT EXISTS unit TEXT DEFAULT 'pcs';

-- 2. Create stock_adjustments table
CREATE TABLE IF NOT EXISTS stock_adjustments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  previous_stock INTEGER NOT NULL,
  new_stock INTEGER NOT NULL,
  quantity_changed INTEGER NOT NULL,
  reason TEXT NOT NULL CHECK (reason IN ('sale', 'return_', 'damage', 'sample', 'found', 'theft', 'adjustment', 'restock')),
  note TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  created_by UUID REFERENCES profiles(id),
  shop_id UUID REFERENCES shops(id)
);

-- 3. Enable RLS on stock_adjustments
ALTER TABLE stock_adjustments ENABLE ROW LEVEL SECURITY;

-- 4. RLS policies for stock_adjustments (scoped by shop_id)
CREATE POLICY "Users can view stock adjustments for their shop"
  ON stock_adjustments FOR SELECT
  USING (
    shop_id IN (
      SELECT shop_id FROM profiles WHERE id = auth.uid()
    )
  );

CREATE POLICY "Users can insert stock adjustments for their shop"
  ON stock_adjustments FOR INSERT
  WITH CHECK (
    shop_id IN (
      SELECT shop_id FROM profiles WHERE id = auth.uid()
    )
  );

-- 5. Indexes for performance
CREATE INDEX IF NOT EXISTS idx_products_min_stock ON products(min_stock_level);
CREATE INDEX IF NOT EXISTS idx_products_unit ON products(unit);
CREATE INDEX IF NOT EXISTS idx_stock_adjustments_product ON stock_adjustments(product_id);
CREATE INDEX IF NOT EXISTS idx_stock_adjustments_shop ON stock_adjustments(shop_id);
CREATE INDEX IF NOT EXISTS idx_stock_adjustments_created ON stock_adjustments(created_at DESC);
