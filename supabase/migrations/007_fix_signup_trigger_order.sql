-- ============================================================
-- 007_fix_signup_trigger_order.sql
-- Flutter Billing App — fix signup 500 "Database error saving new user"
-- ============================================================
-- ROOT CAUSE (from auth logs):
--   006_three_tier_roles.sql inserted into `shops` (owner_id = NEW.id)
--   BEFORE inserting the `profiles` row. But `shops.owner_id` is a FK to
--   `profiles.id`, so the shops insert failed with:
--     "insert or update on table shops violates foreign key
--      constraint shops_owner_id_fkey"
-- FIX: create the PROFILES row first, then the SHOP that references it.
-- ============================================================

BEGIN;

CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = ''
AS $$
DECLARE
  new_profile_id UUID := NEW.id;
  new_shop_id    UUID;
  shop_name     TEXT;
BEGIN
  -- 1) Create the profile FIRST so profiles.id exists for the FK below.
  INSERT INTO public.profiles (id, email, name, role, shop_id)
  VALUES (
    new_profile_id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data ->> 'name', SPLIT_PART(NEW.email, '@', 1)),
    'owner',
    NULL
  );

  -- 2) Determine a sensible default shop name from signup metadata.
  shop_name := COALESCE(
    NEW.raw_user_meta_data ->> 'shop_name',
    NEW.raw_user_meta_data ->> 'name',
    SPLIT_PART(NEW.email, '@', 1) || '''s Shop'
  );

  -- 3) Now create the owner's shop (profiles.id already exists → FK satisfied).
  INSERT INTO public.shops (owner_id, name)
  VALUES (new_profile_id, shop_name)
  RETURNING id INTO new_shop_id;

  -- 4) Link the shop back onto the profile.
  UPDATE public.profiles
  SET shop_id = new_shop_id
  WHERE id = new_profile_id;

  RETURN NEW;
END;
$$;

-- Trigger already exists (on_auth_user_created) and points at handle_new_user;
-- recreate defensively so the new body is guaranteed in place.
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_user();

COMMIT;
