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

## Phase 5 — Polish & Deploy 🚀
- [ ] Google Drive backup
- [ ] Testing & bug fixes
- [ ] APK build
- [ ] Play Store release (optional)
