-- ═══════════════════════════════════════════════════════════
-- AUDIT LOGS — Activity Timeline / Trail
-- ═══════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  action TEXT NOT NULL,                    -- 'stock.added', 'bill.created', 'product.edited'
  entity_type TEXT NOT NULL,               -- 'stock', 'bill', 'product', 'category', 'auth', 'settings'
  entity_id TEXT,                          -- UUID of the affected entity
  entity_name TEXT,                        -- Human-readable name: 'iPhone Case', 'Bill #abc123'
  description TEXT NOT NULL,               -- 'Added 50 units (Restock)'
  old_value JSONB,                         -- Previous state (for edits)
  new_value JSONB,                         -- New state (for edits/creates)
  performed_by UUID, -- Who did it (auth user id)
  staff_name TEXT,                         -- Staff name (denormalized for fast display)
  shop_id UUID REFERENCES shops(id),       -- Multi-tenant isolation
  metadata JSONB,                          -- Extra data (ip, device, etc.)
  created_at TIMESTAMPTZ DEFAULT now()
);

-- RLS
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view audit logs for their shop"
  ON audit_logs FOR SELECT
  USING (shop_id IN (SELECT shop_id FROM profiles WHERE id = auth.uid()));

CREATE POLICY "Users can insert audit logs for their shop"
  ON audit_logs FOR INSERT
  WITH CHECK (shop_id IN (SELECT shop_id FROM profiles WHERE id = auth.uid()));

-- Indexes for fast queries
CREATE INDEX IF NOT EXISTS idx_audit_logs_shop ON audit_logs(shop_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_created ON audit_logs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_logs_entity_type ON audit_logs(entity_type);
CREATE INDEX IF NOT EXISTS idx_audit_logs_action ON audit_logs(action);
CREATE INDEX IF NOT EXISTS idx_audit_logs_performed_by ON audit_logs(performed_by);
CREATE INDEX IF NOT EXISTS idx_audit_logs_entity_id ON audit_logs(entity_id);
