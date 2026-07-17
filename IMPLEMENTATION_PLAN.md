# Implementation Plan — Flutter Billing App (Next Phase)

> Date: 2026-07-17 | Status: DRAFT

## Context
App currently runs on device (RMX3762) with hardcoded Supabase (`wwutchscfnhwijxyftlw`).
RLS was just fixed (owner profile seeded). Kotlin Gradle Plugin warning present (future build break).
Goal: solidify core features + prepare SaaS-ready auth (super admin portal deferred).

---

## TASK 1 — Fix Kotlin Gradle Plugin Warning (BUILD STABILITY) [CRITICAL]
**Why:** Every build warns KGP will cause failures in future Flutter. Plugins affected:
`app_settings, device_info_plus, mobile_scanner, print_bluetooth_thermal, share_plus`
**What:**
- Run `flutter pub upgrade` to get latest plugin versions (most now support Built-in Kotlin)
- If still failing: migrate `android/app/build.gradle.kts` to Built-in Kotlin (remove `kotlin-gradle-plugin` apply, use `org.jetbrains.kotlin.android` only if needed or drop entirely)
- Verify clean build: `flutter build apk` with no KGP warning
**Verify:** `flutter run` shows no KGP warning.

## TASK 2 — Verify RLS Fix End-to-End (MANUAL + CODE)
**Why:** Owner seeded, but app flow never tested post-fix.
**What:**
- In app: add a category → confirm no `42501` error
- Add a product → confirm insert works
- Check `category` + `product` BLoC error handling surfaces friendly message
**Verify:** Category + product create successfully on device.

## TASK 3 — Core Feature Completion (per RPD.md)
Priority sub-tasks (delegate to Hermes in parallel):
- **3A Scanner:** `mobile_scanner` barcode/QR → product lookup → add to cart
- **3B Cart/Billing:** cart state, qty, total, discount, generate bill
- **3C Printer:** `print_bluetooth_thermal` ESC/POS receipt print from bill
- **3D UPI QR:** `pretty_qr_code` dynamic UPI QR from amount
- **3E Realtime:** Supabase Realtime sync across users (products/categories/bills)
**Verify:** Full flow: scan → cart → bill → print → UPI, syncs live.

## TASK 4 — Auth Flow Hardening (SaaS-ready, no super-admin portal yet)
**Why:** Prepare for shop-owner signup + staff invite (super admin deferred).
**What:**
- `signup_usecase` → on signup, create shop + assign `owner` role (not default `staff`)
- Update `handle_new_user()` trigger: default new users to `staff`, but signup flow promotes to `owner` + creates shop row
- Add `shops` table (id, owner_id, name, created_at) + RLS
- Staff invite: owner can insert staff profiles for their shop
**Verify:** Owner signs up → owns a shop → can invite staff.

## Execution Model
- Task 1 + Task 2: main agent (blocking, needs device + build)
- Task 3 (3A-3E) + Task 4: delegate to **Hermes agent** via Herder CLI for parallel speed
- Each delegated task → own pane → reports back

## Rollback
- All Supabase schema changes → migration file in `supabase/migrations/`
- Git commit per task
