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
- [x] **Bill History enhancements** — search by customer name/bill ID, payment method filter (Cash/UPI/Card), discount shown in cards
- [x] **Bill Detail page** — StatefulWidget with fresh data fetch, individual items list (qty badge + product name + price + total), Amount Summary, Print Receipt (Bluetooth thermal), View Receipt (ReceiptPreviewPage)
- [x] **Full Bill Edit** (owner-only) — edit dialog with payment method dropdown, item qty/remove/add (product search), stock auto-adjust, inventory logging, live totals

---

## Phase 4.5 — Dashboard & Navigation UX ✅
- [x] Dashboard homepage at `/` (greeting, today's sales stats, quick actions, low-stock banner)
- [x] Scanner moved to `/scan` (`/scan/checkout`, `/scan/scanner` children)
- [x] Reusable widgets: StatCard, DashboardActionCard, QuickActionTile
- [x] Improved AppDrawer: profile header (AuthBloc), working logout (LogoutRequested), sectioned menu + Dashboard link
- [x] **Advanced Visual Analytics** (fl_chart added):
  - [x] Payment Methods Donut Chart — UPI/Cash/Card/Credit breakdown with percentages
  - [x] Top Products Bar Chart — top 5 products by quantity sold, revenue-colored bars
  - [x] Monthly Trend Card — 30-day sales trend line chart with FL LineChart
  - [x] Staff Performance Card — owner-only leaderboard with rank badges + progress bars
  - [x] Quick Actions repositioned: moved up right after Today's Sales section
  - [x] `LoadSalesRange` event triggered on dashboard init + pull-to-refresh for 30-day data

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
- [x] ~~Staff invite by owner~~ → **Staff Management feature complete** (see Phase 6.5) — owner creates staff via Supabase Auth signUp + shop_id link

---

## Phase 6.5 — Staff Management (Owner-only) ✅
- [x] Migration `005_add_staff_phone.sql` (applied) — `profiles.phone` TEXT column
- [x] `User` entity + `UserModel` `phone?` field (fromJson/fromProfileJson/fromSupabaseAuth/toJson/copyWith)
- [x] Auth `signUp` threading: `String? shopId` param → owner-created staff linked to shop in one call
- [x] Staff feature (Clean Arch, mirrors Category):
  - `staff_repository` (getStaffMembers shop-scoped, deleteStaffMember)
  - `staff_usecases` (GetStaffMembers, DeleteStaffMember)
  - `staff_repository_impl` (profiles SELECT/DELETE via UserModel.fromProfileJson)
  - `staff_bloc`/event/state (LoadStaff, DeleteStaffMember, _currentShopId from AuthBloc)
  - `staff_list_page.dart` (list + search + cards + owner-only FAB + delete dialog)
  - `add_staff_page.dart` (owner-only form → SignUpRequested role:'staff', shopId: owner.shopId)
- [x] Wiring: `/staff` route (ShellRoute), owner-only Drawer item + Dashboard QuickActionTile, Staff DI block
- [ ] Device verify: owner add/delete staff; staff can't see Staff section
- [ ] NOTE: delete removes `profiles` row only; `auth.users` may stay orphaned (client-side needs service role)

## Phase 7 — Damaged Products Management ✅
- [x] Domain layer: `DamagedProduct` entity + `DamagedProductsRepository` interface
- [x] Data layer: `DamagedProductsRepositoryImpl` — queries `stock_adjustments` where `reason=damage`, joined with products for name/barcode/price
- [x] BLoC layer: `DamagedProductsBloc` — LoadDamagedProducts, SearchDamagedProducts, FilterDamagedProductsByDate, MarkProductAsDamaged
- [x] Presentation: `DamagedProductsPage` — summary card (total loss ₹ + count), search bar, date range filter, list with product info + loss amount
- [x] `MarkDamagedDialog` — quantity selector, 6 damage types (Broken/Defective/Expired/Water Damage/Scratched/Other), optional notes
- [x] Product detail page: 'Mark as Damaged' button in Stock Adjustment section (disabled when stock=0)
- [x] Product list: 'Mark as Damaged' in long-press menu (only when stock>0)
- [x] DI: `DamagedProductsRepository` + `DamagedProductsBloc` registered in service_locator.dart
- [x] Route: `/damaged-products` in app_routes.dart with BlocProvider
- [x] Drawer: 'Damaged Products' menu item under Payments section
- [x] No new DB migration — reuses existing `stock_adjustments` table with `reason=damage`
- [x] Auto stock decrease on damage + audit log entry
- [x] `flutter analyze`: 0 errors, 0 warnings

## Phase 8 — Customer CMS (Minimal) 📋 (PLANNED)
- [ ] **Goal:** unify customer identity (name+phone only) across bills/warranties/dues.
- [ ] Supabase `customers` table migration (id, shop_id, name, phone unique per shop, created_at) + RLS
- [ ] Domain: `Customer` entity + repository interface
- [ ] Data: `CustomerModel` + `CustomerRepositoryImpl` (Supabase, shop_id scoped)
- [ ] Bloc: LoadCustomers, SearchCustomers, AddCustomer
- [ ] UI: Customer List (search by name/phone), Add Customer (validate+unique phone), Customer Detail (history)
- [ ] DI + go_router `/customers` route
- [ ] Light link: billing checkout customer select-by-phone
- [ ] Full plan: `customer_cms_plan.md`
- [ ] Device verify: add → list → search → detail

## Phase 8.5 — Premium UX Polish ✅ (2026-09-05)
- [x] **CountUpMoney** widget — hero/count money 0→value count-up (dashboard hero card wired)
- [x] **AuroraGlow** widget — breathing drift lime glow, dashboard dark mode
- [x] **SuccessBurst** overlay — bill-save pe lime checkmark animation (checkout wired)
- [x] **Customer swipe actions** — Call (url_launcher tel:) + Edit (flutter_slidable)
- [x] **Customer edit flow end-to-end** — repo.updateCustomer → UpdateCustomer bloc event → AddCustomerPage edit mode → route extra parse (Dart-only, no migration)
- [x] **Collapsing large-title AppBar** — reports home (expandedHeight 96, no double-title)
- [x] **Chart polish** — trend entry fade, accent gradient fill, last-dot highlight
- [x] `dart analyze lib` → 0 issues · commits `722e4c0`, `944f311`
- [ ] Device verify: pull-to-refresh, count-up, burst on bill save, customer swipe call/edit
- Components documented in `design.md` → Premium Motion Components (v3.1)

## Known Issues / TODO
- [ ] **Kotlin Gradle Plugin warning** — `app_settings, device_info_plus, mobile_scanner, print_bluetooth_thermal, share_plus` apply KGP; future Flutter build break. `flutter pub upgrade` done (partial), full Built-in Kotlin migration pending rebuild verification.
