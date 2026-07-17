# Phases — Roadmap

## Phase 0 — Foundation ✅ (Complete)
- [x] Flutter project setup
- [x] Hive + get_it + go_router + theme
- [x] Clean Architecture folder structure
- [x] GitHub repo setup & push
- [x] Project docs (CLAUDE.md, RPD.md, architecture.md, rules.md, phases.md, memory.md, design.md)
- [x] Graphify installed
- [x] Supabase client config & package added

---

## Phase 1 — Database & Auth 🏗️ ✅
- [x] Supabase tables creation (categories, products, profiles, bills, bill_items, locations, inventory_log)
- [x] Row Level Security (RLS) policies
- [x] Supabase Auth — owner & staff login (email + Google OAuth)
- [x] Auth screens (login, register)
- [x] Role-based access (owner vs staff via profiles table)

---

## Phase 2 — Core Features 🔧 ✅

### 2A — Categories ✅
- [x] Category CRUD (create, read, update, delete) — full Clean Architecture feature
- [x] Category list screen with search/filter
- [x] Assign category to product (dropdown in add/edit product)

### 2B — Products (Inventory) ✅
- [x] ProductRepositoryImpl — Supabase primary, Hive cache (CRUD methods)
- [x] Product add via QR/barcode scan
- [x] QR code generator (in-app) — qr_generator_page.dart
- [x] Product list with search & filter + category chips
- [x] Shelf/location assignment
- [x] Stock tracking
- [x] Product entity expanded: categoryId, location, description, imageUrl, qrData, timestamps

### 2C — Billing (Enhanced) ✅
- [x] Multi-product billing
- [x] Manual discount (₹ or %) — BillingBloc UpdateDiscountEvent
- [x] Manual grand total override — BillingBloc UpdateGrandTotalOverrideEvent
- [x] Bill save to Supabase (bills + bill_items + inventory_log)
- [x] Thermal receipt with new format
- [x] UPI QR on bill
- [x] **Barcode/QR Scanner → Cart integration** — MobileScanner decodes → `ScanBarcodeEvent` → Supabase `products.barcode` lookup → cart add; not-found SnackBar (scanner_page.dart + home_page.dart overlay)

---

## Phase 3 — Real-time & Multi-user 🔄 ✅
- [x] Supabase Realtime subscriptions (products table via RealtimeService)
- [x] Live inventory sync across staff (ProductBloc auto-refresh on changes)
- [x] Multi-staff concurrent billing (stock validation before bill submit)

---

## Phase 4 — Reports & History 📊 ✅
- [x] Bill/invoice history (domain + data + UI)
- [x] Daily sales summary (domain + data + UI)
- [x] Low stock alerts (domain + data + UI)
- [x] Stock movement log (domain + data + UI)

---

## Phase 4.5 — Dashboard & Navigation UX ✅
- [x] Dashboard homepage at `/` (greeting, today's sales stats, quick actions, low-stock banner)
- [x] Scanner moved to `/scan` (`/scan/checkout`, `/scan/scanner` children)
- [x] Reusable widgets: StatCard, DashboardActionCard, QuickActionTile
- [x] Improved AppDrawer: profile header (AuthBloc), working logout (LogoutRequested), sectioned menu + Dashboard link

---

## Phase 5 — Polish & Deploy 🚀
- [ ] Google Drive backup
- [ ] Testing & bug fixes
- [ ] APK build (Kotlin Gradle Plugin warning fix pending — see below)
- [ ] Play Store release (optional)

---

## Phase 6 — SaaS-Ready Auth (Owner Signup + Shops) ✅
- [x] `shops` table + RLS (owner CRUD own shop) — migration `003_saas_shops.sql` (applied)
- [x] `profiles.shop_id` column (staff↔shop link) — migration applied
- [x] profiles RLS → shop-context read (owner sees all, staff sees own shop)
- [x] Owner signup flow: creates shop + assigns `role='owner'` + links `shop_id` (signup_usecase, auth_repository_impl)
- [x] User entity/model `shopId` field added
- [ ] **Super Admin portal — DEFERRED** (msayan9733@gmail.com = super admin, portal baad mein)
- [ ] Staff invite by owner (UI pending — schema ready)

## Known Issues / TODO
- [ ] **Kotlin Gradle Plugin warning** — `app_settings, device_info_plus, mobile_scanner, print_bluetooth_thermal, share_plus` apply KGP; future Flutter build break. `flutter pub upgrade` done (partial), full Built-in Kotlin migration pending rebuild verification.
