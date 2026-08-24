-- ============================================================
-- 011_add_due_payments.sql
-- Flutter Billing App — Due Payments Management
-- Adds columns for tracking partial payments and due amounts
-- ============================================================

BEGIN;

-- Add due payment columns to bills table
ALTER TABLE bills 
  ADD COLUMN amount_paid DECIMAL(10,2) DEFAULT 0,
  ADD COLUMN due_amount DECIMAL(10,2) DEFAULT 0,
  ADD COLUMN payment_status TEXT DEFAULT 'paid' CHECK (payment_status IN ('paid', 'partial', 'due'));

-- Update existing bills to mark them as 'paid' (since they were fully paid before)
UPDATE bills SET payment_status = 'paid', amount_paid = grand_total, due_amount = 0;

-- Add index for due payments queries
CREATE INDEX idx_bills_payment_status ON bills(payment_status);

-- Create a view for due payments (pending dues)
CREATE OR REPLACE VIEW due_payments_view AS
SELECT 
  b.id as bill_id,
  b.shop_id,
  b.customer_name,
  b.customer_phone,
  b.grand_total,
  b.amount_paid,
  b.due_amount,
  b.payment_status,
  b.created_at as bill_date,
  p.name as staff_name
FROM bills b
LEFT JOIN profiles p ON b.staff_id = p.id
WHERE b.payment_status IN ('partial', 'due')
  AND b.due_amount > 0;

-- RLS policy for due_payments_view (inherits from bills table)
-- Staff can see due payments for bills they created
-- Owners can see all due payments in their shop

COMMIT;
