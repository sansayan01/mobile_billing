-- ============================================================
-- 009_add_customer_phone_to_bills.sql
-- Flutter Billing App — add customer_phone column to bills
-- ============================================================
-- Customer name already exists as customer_name (TEXT).
-- This adds customer_phone for marketing/contact purposes.
-- ============================================================

BEGIN;

ALTER TABLE public.bills
  ADD COLUMN IF NOT EXISTS customer_phone TEXT;

COMMIT;
