-- ============================================================
-- 003_saas_shops.sql
-- Flutter Billing App — SaaS-ready shops + staff-shop association
-- (Super admin portal DEFERRED — no super admin logic added)
-- ============================================================

BEGIN;

-- ------------------------------------------------------------
-- 1. shops TABLE — har owner ki apni shop
-- ------------------------------------------------------------
CREATE TABLE shops (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_shops_owner_id ON shops(owner_id);

-- ------------------------------------------------------------
-- 2. profiles → shop_id (staff ko apni shop se link karein)
--    Nullable rakha hai taaki existing rows break na ho.
-- ------------------------------------------------------------
ALTER TABLE profiles
  ADD COLUMN shop_id UUID REFERENCES shops(id) ON DELETE SET NULL;

CREATE INDEX idx_profiles_shop_id ON profiles(shop_id);

-- ------------------------------------------------------------
-- 3. RLS — shops
-- ------------------------------------------------------------
ALTER TABLE shops ENABLE ROW LEVEL SECURITY;

-- Owner apni shop create kar sakta hai
CREATE POLICY "Owner can insert own shop"
  ON shops FOR INSERT
  WITH CHECK (auth.uid() = owner_id);

-- Owner apni shop padh sakta hai
CREATE POLICY "Owner can select own shop"
  ON shops FOR SELECT
  USING (auth.uid() = owner_id);

-- Owner apni shop update kar sakta hai
CREATE POLICY "Owner can update own shop"
  ON shops FOR UPDATE
  USING (auth.uid() = owner_id)
  WITH CHECK (auth.uid() = owner_id);

-- Owner apni shop delete kar sakta hai
CREATE POLICY "Owner can delete own shop"
  ON shops FOR DELETE
  USING (auth.uid() = owner_id);

-- ------------------------------------------------------------
-- 4. profiles RLS — shop context read
--    Pehle se "Anyone can read profiles" policy hai (001).
--    Usko replace karke shop-context read add karte hain taaki
--    staff sirf apni shop ke members dekh sakein (plus owner sab dekh sake).
-- ------------------------------------------------------------

-- Purani open-read policy hatao (001 se conflict avoid karne ke liye)
DROP POLICY IF EXISTS "Anyone can read profiles" ON profiles;

-- Naya shop-context read policy:
--   - owner sab profiles dekh sakta hai
--   - staff sirf un profiles ko dekh sakta hai jinki shop_id uski shop_id se match kare
CREATE POLICY "Users can read profiles in their shop context"
  ON profiles FOR SELECT
  USING (
    is_owner()
    OR
    (
      -- current user ki shop_id same ho dusre profile ki shop_id se
      shop_id IS NOT NULL
      AND shop_id = (SELECT p.shop_id FROM profiles p WHERE p.id = auth.uid())
    )
  );

COMMIT;
