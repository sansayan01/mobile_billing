# Memory — Session Log & Context

## Current Session: 2026-07-18 — Hamburger Menu on 5 AppBars ✅

### What Was Done
1. **Added `leading` hamburger menu IconButton to 5 pages** (missing from AppBar, calling `Scaffold.of(context).openDrawer()`):
   - `lib/features/dashboard/presentation/pages/dashboard_page.dart` — AppBar leading added (was: no leading, only actions with notifications icon)
   - `lib/features/billing/presentation/pages/scanner_page.dart` — AppBar leading added (was: no leading at all)
   - `lib/features/settings/presentation/pages/settings_page.dart` — AppBar leading added (was: no leading)
   - `lib/features/shop/presentation/pages/shop_details_page.dart` — AppBar leading added (was: no leading)
   - `lib/features/category/presentation/pages/category_list_page.dart` — AppBar leading added (was: no leading)
2. **Consistent pattern**: `Icons.menu` + `Theme.of(context).primaryColor` + `Scaffold.of(context).openDrawer()` + tooltip 'Open menu'

### flutter analyze
- All 5 files: 0 issues

### TODO
- [ ] Device pe verify: drawer opens from all 5 pages

---

## Current Session: 2026-07-17 — 3-Tier Role System (super_admin / owner / staff) ✅

### Context (user asked)
Pehle sirf 2 roles the (owner, staff). User ne 3-tier manga: (1) super_admin = SaaS product admin, (2) owner = shop owner, (3) staff. Naya signup hamesha **owner** banta hai apni shop ke saath. super_admin manual assign hota hai.

### What Was Done
1. **Migration `supabase/migrations/006_three_tier_roles.sql`** (APPLIED via MCP `apply_migration`):
   - `profiles.role` CHECK extended → `['super_admin','owner','staff']`
   - New helper `is_super_admin()` (SECURITY DEFINER)
   - **Rewrote `handle_new_user()` trigger**: har new signup → auto `owner` role + apni shop auto-create (`shops` insert) + `shop_id` link. super_admin never via self-signup.
   - **RLS**: `is_super_admin()` cross-shop bypass bolted onto ALL tables (profiles, shops, categories, products, bills, bill_items, inventory_log) — super admin sab dekh/sudhar sakta hai.
   - Verified: role_check = `role = ANY (ARRAY['super_admin','owner','staff'])`, is_super_admin() exists, trigger present.
2. **Dart UserRole enum** (`lib/features/auth/domain/entities/user.dart`):
   - `enum UserRole { superAdmin('super_admin'), owner('owner'), staff('staff') }` + `UserRole.fromString()`
   - `User` ko getters add: `userRole`, `isSuperAdmin`, `isOwner`, `isStaff`
3. **UserModel** (`user_model.dart`): fromJson / fromSupabaseAuth / fromProfileJson ab `UserRole.fromString().value` use karte hain (role normalize).
4. **Signup default = owner**:
   - `SignUpParams` default `role='owner'`; `SignUpRequested` default `'owner'`; `AuthRepository.signUp` default `'owner'`.
   - `auth_repository_impl.signUp` REWRITE: ab DB trigger ko owner+shop banane deta hai. Sirf staff-created-by-owner case me `_ensureProfileRole(role:'staff', shopId)` best-effort. Removed unused `_createShop` (trigger handles).
   - signUp ab `data: {name, shop_name}` bhejta hai taaki trigger shop name le sake.
5. **RPD.md** — "User Roles" section → 3-tier table + assignment flow.

### Key Decisions
| Decision | Why |
|----------|-----|
| DB trigger auto owner+shop | Self-signup hamesha owner — Dart side duplicate insert conflict avoid (idempotent try/catch) |
| super_admin manual only | Self-signup se security risk; admin manually promote karega |
| RLS super_admin bypass on ALL tables | Cross-shop SaaS admin view chahiye |
| Dart UserRole enum (not just string) | Type-safe role checks; backwards compatible (role string abhi bhi `'owner'` etc) |

### flutter analyze
- `lib/features/auth`: No issues found ✅

### TODO
- [ ] Device pe verify: naya signup → profile role='owner' + shop auto-bani + shop_id linked
- [ ] super_admin manually assign karke cross-shop access test (SQL ya admin screen)
- [ ] graphify --update (pending)
- [ ] CLAUDE.md auto-update rule: har edit ke baad memory + graphify + md update

---

## Current Session: 2026-07-17 — Staff Management Feature ✅

### What Was Done
1. **Migration `supabase/migrations/005_add_staff_phone.sql`** (APPLIED via MCP):
   - `ALTER TABLE profiles ADD COLUMN IF NOT EXISTS phone TEXT` (nullable)
   - Koi new RLS nahi — `003_saas_shops.sql` already owner/staff read + owner write scope karta hai profiles pe
2. **User entity + model** (`features/auth/.../user.dart`, `user_model.dart`):
   - `phone?` field added to `User` + `UserModel` (ctor, fromJson, fromProfileJson, fromSupabaseAuth, toJson) + copyWith + props
3. **Auth signUp shopId threading** (Dart-only, no new schema beyond phone):
   - `AuthRepository.signUp` + `SignUpRequested` event + `SignUpParams` + `SignUpUseCase` ko `String? shopId` param add
   - `auth_repository_impl.signUp`: owner signup abhi shop create karta hai; staff signup by owner → `effectiveShopId = shopId` direct pass (`_createProfile` ko). One-call shop link.
4. **Staff Feature created** (mirrors Category feature clean-arch):
   - `lib/features/staff/domain/repositories/staff_repository.dart` — `getStaffMembers({shopId})`, `deleteStaffMember(id, {shopId})`
   - `lib/features/staff/domain/usecases/staff_usecases.dart` — `GetStaffMembersUseCase` (NoParams), `DeleteStaffMemberUseCase` (String)
   - `lib/features/staff/data/repositories/staff_repository_impl.dart` — `profiles.select().eq('shop_id', shopId).order('created_at', desc)` → `UserModel.fromProfileJson`; delete `.delete().eq('id', id)`
   - `lib/features/staff/presentation/bloc/` — staff_event/state/bloc (LoadStaff, DeleteStaffMember; _currentShopId from AuthBloc)
   - `lib/features/staff/presentation/pages/staff_list_page.dart` — list + search + white cards (avatar/name/email/phone/role badge) + delete AlertDialog + owner-only FAB → `/staff/add`
   - `lib/features/staff/presentation/pages/add_staff_page.dart` — form (name/email/phone/password) → `SignUpRequested(role:'staff', shopId: ownerShopId)`; owner-only BlocBuilder guard; pops on success
5. **Wiring**:
   - `app_routes.dart` — `GoRoute('/staff', StaffListPage, routes:[add])` inside ShellRoute
   - `app_drawer.dart` — owner-only `Staff` _DrawerItem (_SectionHeader)
   - `dashboard_page.dart` — owner-only `Staff` QuickActionTile
   - `service_locator.dart` — Staff DI block (usecases + repo + bloc with authBloc: sl())

### Key Decisions
| Decision | Why |
|----------|-----|
| Staff = `User` entity (no new Staff entity) | Staff already `profiles` rows hain; `UserModel.fromProfileJson` reuse |
| RLS se list free | `003` already owner ko apne shop ke profiles read karne deti hai |
| phone = migration (not Dart-only) | Genuinely new user column — CLAUDE.md Dart-only rule ka justified exception |
| Delete = profiles row only | Client-side `auth.users` delete needs service role (admin) — orphaned auth user limitation documented |
| Owner-only gating (3 layers) | Drawer/dashboard hide + add page BlocBuilder guard + RLS rejects foreign shopId |
| signUp shopId param (not post-update) | One-call shop link, `_createProfile` already forwards shopId |

### flutter analyze
- Full project: **No issues found!** ✅

### TODO
- [ ] Device pe verify: owner login → Staff list (own shop only) → add staff (gets shop_id) → delete removes row
- [ ] Staff login → no Staff drawer item; direct `/staff/add` blocked
- [ ] graphify --update (pending → run karna hai)
- [ ] Limitation note: delete ke baad `auth.users` orphaned reh sakta hai (service-role needed for full purge)

---

## Current Session: 2026-07-17 — Multi-Tenant Shop Data Isolation (CRITICAL FIX) ✅

### Problem (user flagged): "har shop mei ek hi data to nahi rahega na"
Cross-tenant data leak tha — products/categories/bills/inventory_log mein `shop_id` column hi nahi tha, aur koi query filter nahi karta tha. Shop A Shop B ka data dekh leta tha. RLS bhi user/role scope karti thi, shop nahi.

### What Was Done
1. **Migration `supabase/migrations/004_shop_data_scoping.sql`** (APPLIED via MCP):
   - `shop_id` UUID column + FK to shops added to `products`, `categories`, `bills`, `bill_items`, `inventory_log` (nullable, ON DELETE CASCADE)
   - Indexes: `idx_*_shop_id`
   - Helpers: `user_shop_id()`, `belongs_to_shop(target_shop_id)`
   - RLS rewritten: har table pe `belongs_to_shop(shop_id)` scoping (read/insert/update/delete). Purani open policies drop ki.
2. **Dart — shop_id threading** (3 parallel agents):
   - `product_repository*`: `.eq('shop_id', shopId)` on reads + `shop_id` on insert/upsert. ProductBloc injected `authBloc`, passes `_currentShopId`.
   - `category_repository*`: same pattern. CategoryBloc injected `authBloc`.
   - `report_repository*`: `.eq('shop_id', shopId)` on bills/products/inventory_log queries. ReportBloc injected `authBloc`.
   - `billing_bloc.dart`: writes `shop_id` on bills/bill_items/inventory_log inserts. **Also fixed inventory_log schema drift** — ab `change_type` + `quantity` use karta hai (purana `change`/`type`/`bill_id` remove kiya jo schema mein nahi the).
   - `service_locator.dart`: ProductBloc/CategoryBloc/ReportBloc ko `authBloc: sl()` diya.
   - Pattern: `String? shopId` optional param end-to-end; null pe RLS hi scope karta hai.

### Key Decisions
| Decision | Why |
|----------|-----|
| Migration ZAROORI thi | Dart-only fix se nahi hota tha — column hi nahi tha (CLAUDE.md Dart-only rule ka exception) |
| RLS + app-side dono | Defense in depth — DB bhi scope kare, app bhi filter kare |
| `String? shopId` optional | Existing callers na toote; null pe RLS fallback |
| AuthBloc inject in blocs | Live user.shopId read karne ke liye (factory instances) |

### flutter analyze
- Full project: 0 issues ✅

### TODO
- [ ] Device/emulator pe verify: Shop A login → only Shop A products/bills dikhne chahiye
- [ ] Existing rows (null shop_id) ko backfill karne ka script agar purane users hain
- [ ] graphify --update (pending)

---

## Current Session: 2026-07-17 — Hamburger Icon Fix + Email Verification Hardening ✅

### What Was Done
1. **Hamburger icon added to 2 pages** (pehle custom back-chevron `leading` ne override kar diya tha):
   - `lib/features/product/presentation/pages/product_list_page.dart` — AppBar `leading` ab `Row` me `Icons.menu` (openDrawer) + back-chevron dono hai
   - `lib/features/billing/presentation/pages/checkout_page.dart` — same pattern (menu + back)
   - Dono pages AppShell ke under hain → drawer already attached tha, sirf button missing tha
2. **Email verification gate hardened (Dart-only, no migration):**
   - `lib/features/auth/presentation/bloc/auth_bloc.dart` — `_onLoginRequested` ab bhi `emailConfirmedAt != null` check karta hai (pehle direct `Authenticated`)
   - `_onGoogleLoginRequested` bhi same gate lagaya (consistency) — pehle direct `Authenticated` emit karta tha
   - Signup + CheckAuthStatus path pe pehle se gate tha
3. **CLAUDE.md** — added "CRITICAL — Dart-Only Fix Preference" section (avoid SQL migration files, fix Dart first)

### Key Decisions
| Decision | Why |
|----------|-----|
| Menu + back button dono rakhe | User ko drawer access + back dono chahiye |
| Login/Google path pe bhi verification gate | Unverified user app na ghoose login ke turant baad |
| Dart-only fix | CLAUDE.md instruction — avoid migrations unless schema must change |

### flutter analyze
- 3 changed files (product_list_page, checkout_page, auth_bloc): 0 issues

### TODO
- [ ] Device pe verify: product_list + checkout me hamburger drawer khole
- [ ] graphify --update (running)

---

## Current Session: 2026-07-17 — Dashboard Homepage + Improved Side Menu ✅

### What Was Done
1. **New Dashboard Homepage** — `/` route ab DashboardPage kholta hai (pehle scanner tha)
   - `lib/features/dashboard/presentation/pages/dashboard_page.dart` (new) — BlocProvider<ReportBloc> (LoadDailySales + LoadLowStockProducts(5)), RefreshIndicator
     - **Greeting**: time-based (Good morning/afternoon/evening) + user name (AuthBloc) + role badge
     - **Today's Sales**: 4 StatCards (Total Sales, Bills, Avg Bill, Discount) — ReportBloc.dailySales se, loading pe "…"
     - **Quick Actions**: bada primary "New Bill" card → `/scan`, + 3-col compact tiles (Products, Categories, Reports, Shop, Settings)
     - **Low Stock Banner**: error-tinted, count > 0 pe dikhta hai → `/reports/low-stock`

2. **Reusable Widgets** (new, `lib/core/widgets/`)
   - `stat_card.dart` — StatCard({label, value, color, icon?}) — white radius16, black12 shadow, value w900
   - `dashboard_action_card.dart` — DashboardActionCard (big solid-color card) + QuickActionTile (compact 3-col tile)

3. **AppDrawer Improved** — `lib/core/widgets/app_drawer.dart`
   - Profile header: CircleAvatar (initials from name) + name + email + role badge (AuthBloc), fallback jab !Authenticated
   - Working logout: `context.read<AuthBloc>().add(const LogoutRequested())` (pehle sirf navigate karta tha)
   - Sectioned menu (_SectionHeader): Main (Dashboard `/`, Scan & Billing `/scan`) / Inventory (Products, Categories) / Reports / Settings (Shop, Printer)

4. **Routing** — `lib/config/routes/app_routes.dart`
   - `/` → DashboardPage
   - `/scan` (parent) → HomePage (scanner), children: `/scan/scanner` (ScannerPage), `/scan/checkout` (CheckoutPage)
   - Auth redirect logic unchanged

5. **Navigation Path Fixes** (routes move ki wajah se)
   - `home_page.dart`: checkout `/checkout` → `/scan/checkout`
   - `checkout_page.dart`: 3x `context.go('/')` → `/scan` (checkout ke baad wapas scanner, dashboard nahi)
   - `add_product_page.dart` + `product_list_page.dart`: `/scanner` → `/scan/scanner`

### Key Decisions
| Decision | Why |
|----------|-----|
| Scanner `/` se `/scan` pe move | Dashboard ko primary home banana; billing ab quick action |
| `/scan/checkout` child route | HomePage → checkout flow same hierarchy me rahe |
| Checkout return `/scan` (not `/`) | Billing loop me user ko wapas scanner chahiye, dashboard nahi |
| Big "New Bill" + compact tiles | Billing app hai — billing sabse prominent action |
| StatCard/ActionCard alag widgets | DRY — daily_sales + dashboard dono reuse kar sakein |
| ReportBloc factory reuse | Koi naya data layer/DI nahi — existing usecases hi kaafi |

### flutter analyze
- Changed files (7): 0 issues
- Full project: 0 issues

### TODO
- [ ] StatCard/ActionCard ko daily_sales_page + reports_home_page me migrate (optional DRY)
- [ ] Dashboard notification icon abhi placeholder (empty onPressed)
- [ ] Device pe end-to-end test (login → dashboard → new bill → checkout → wapas scan)

---

## Current Session: 2026-07-17 — Barcode/QR Scanner → Cart Integration ✅

### What Was Done
1. **ScannerPage wired into BillingBloc flow** — `lib/features/billing/presentation/pages/scanner_page.dart`
   - Ab `ScanBarcodeEvent(barcode)` dispatch karta hai (pehle sirf `context.pop(barcode)` karta tha)
   - `BlocListener<BillingBloc>` se not-found SnackBar dikhata (BillingState.error) aur scan ke baad `/scan` pe wapas pop karta hai
   - BillingBloc already present (root MultiBlocProvider) — `/scan/scanner` route me available
2. **HomePage entry point** — `lib/features/billing/presentation/pages/home_page.dart`
   - Overlay me `Icons.qr_code_scanner` button add kiya → `context.push('/scan/scanner')` (camera stop/start handle karta hai)
   - Scan → cart flow dono jagah kaam karega: inline HomePage scanner + dedicated ScannerPage

### Scan → Cart Flow (one-liner)
MobileScanner decodes barcode/QR → `ScanBarcodeEvent` → `GetProductByBarcodeUseCase` (Supabase `products.barcode`) → product mila to `AddProductToCartEvent`, nahi toa BillingState.error SnackBar ("Product not found").

### Key Decisions
| Decision | Why |
|----------|-----|
| ScannerPage BillingBloc use kare | Reuse existing scan→cart + not-found logic, no new BLoC needed |
| Scan ke baad auto-pop | Seamless wapas cart panel me; HomePage already shows cart |
| Inline + dedicated dono rakhe | HomePage pehle se scanning karta hai; extra dedicated screen optional entry |

### flutter analyze
- Changed files (scanner_page.dart, home_page.dart): 0 issues
- Full project: 0 issues

---

## Current Session: 2026-07-17 — Reports & History Data + Domain Layers ✅

### What Was Done
1. **Domain Layer** (3 files):
   - `lib/features/report/domain/entities/report_entities.dart` — BillItem, BillSummary, DailySales, StockMovement (all Equatable with copyWith)
   - `lib/features/report/domain/repositories/report_repository.dart` — Abstract repo: getBillHistory (paginated + date range), getBillDetail, getDailySales, getSalesRange, getLowStockProducts, getStockMovements (with filters)
   - `lib/features/report/domain/usecases/report_usecases.dart` — 6 param classes (BillHistoryParams, BillDetailParams, DailySalesParams, SalesRangeParams, LowStockParams, StockMovementParams) + 6 use cases implementing UseCase<Result, Params>

2. **Data Layer** (2 files):
   - `lib/features/report/data/models/report_models.dart` — BillItemModel, BillSummaryModel, DailySalesModel, StockMovementModel with fromJson/toJson/fromSupabaseRow
   - `lib/features/report/data/repositories/report_repository_impl.dart` — Full Supabase implementation with joins (profiles for staff name, products for product name), aggregations, date range filtering, pagination

3. **Service Locator** (`lib/core/service_locator.dart`) — Added `ReportRepositoryImpl` import and fixed Report feature registrations (already present)

4. **Bloc Fixes** (`lib/features/report/presentation/bloc/report_bloc.dart`) — Fixed 3 use case calls to pass proper param objects (BillDetailParams, DailySalesParams, LowStockParams) instead of raw values

### Supabase Queries Detail
| Method | Table | Joins | Filters |
|--------|-------|-------|---------|
| getBillHistory | bills | profiles(name) | date range, pagination (range/page/limit) |
| getBillDetail | bills + bill_items | profiles(name) | billId, bill_id FK |
| getDailySales | bills | — | date range, computes SUM/COUNT/AVG in Dart |
| getSalesRange | bills | — | date range, groups by calendar day |
| getLowStockProducts | products | — | stock <= threshold, ordered asc |
| getStockMovements | inventory_log | products(name), profiles(name) | productId, date range, changeType |

### Key Decisions
| Decision | Why |
|----------|-----|
| Supabase join syntax `*, profiles(name)` | Resolves FK relationships; staff name fetched in same query |
| Sales aggregation in Dart (not RPC) | Avoids creating Supabase RPC functions; keeps logic in app |
| Separate param classes for all use cases | Consistent with UseCase<Result, Params> pattern |
| BillItem as separate entity | Reusable for bill detail view |
| BillSummary.items defaults to empty list | Supports both list (no items) and detail (with items) scenarios |
| StockMovement.fromSupabaseRow handles nested joins | Parses `products: {name}` and `profiles: {name}` automatically |

### flutter analyze
- All new code passes (5 files, ~350 lines total)
- ReportBloc now uses correct param objects (no type mismatch)

### TODO
- [ ] Add ReportBloc tests
- [ ] Wire presentation pages to bloc (already done - pages exist)
- [ ] Add route for /reports/* pages

---

## Current Session: 2026-07-17 — Supabase Realtime Sync for Products ✅

### What Was Done
1. **`lib/core/realtime/realtime_service.dart`** (new) — `RealtimeService` class:
   - `subscribeToTable()`: Generic method subscribing to INSERT/UPDATE/DELETE on any table via `onPostgresChanges` with separate callbacks
   - `subscribeToProducts()`: Convenience method for products table; single callback receives complete payload with `event_type`, `new`, `old`
   - Tracks all active `RealtimeChannel` subscriptions in a Map
   - `unsubscribe(table)`: Removes a single subscription
   - `dispose()`: Cleans up all subscriptions via `SupabaseConfig.client.removeChannel()`
   - `isConnected` getter reflecting subscription status

2. **`lib/features/product/presentation/bloc/product_event.dart`** — Added:
   - `InitRealtime`: Dispatched to start listening for real-time product changes
   - `ProductsRealtimeUpdated(changeType, payload)`: Fired when a real-time event arrives

3. **`lib/features/product/presentation/bloc/product_bloc.dart`** — Updated:
   - Added `RealtimeService realtimeService` dependency + `Timer _realtimeDebounce`
   - `_onInitRealtime`: Calls `realtimeService.subscribeToProducts()` with callback dispatching `ProductsRealtimeUpdated`
   - `_onProductsRealtimeUpdated`: 
     - `DELETE` events: removes product from state directly using `payload['old']['id']`
     - `INSERT`/`UPDATE` events: 300ms debounce then reload via `LoadProducts`
   - `close()` override: cancels debounce timer + disposes realtime service

4. **`lib/core/service_locator.dart`** — Registered:
   - `RealtimeService` as lazy singleton
   - Updated `ProductBloc` factory to inject `realtimeService`

5. **`lib/main.dart`** — Updated `BlocProvider<ProductBloc>` to dispatch `InitRealtime()` after `LoadProducts()`

### Key Decisions
| Decision | Why |
|----------|-----|
| `subscribeToProducts` combines INSERT/UPDATE/DELETE in one callback | Single subscription avoids multiple channels; callback receives event_type to decide action |
| DELETE handled directly in state (not reload) | More efficient than full reload; prevents flash and filter reset |
| 300ms debounce on INSERT/UPDATE reload | Batches rapid changes (including echo from own mutations) into a single reload |
| Realtime errors silently caught | App works without live updates if Supabase Realtime fails |
| Channel name: `public:products` | Follows Supabase convention: `public:<table>` |
| Supabase `onPostgresChanges()` API | Correct API for realtime_client 2.x (not the deprecated `.on()` method) |

### flutter analyze
- New code passes cleanly (0 issues)
- 1 pre-existing error in `product_repository_impl.dart:182` (`.in_()` not on `PostgrestFilterBuilder`)

### TODO
- [ ] Test realtime sync end-to-end on device/emulator
- [ ] Consider adding realtime support for other modules (categories, billing)

---

### What Was Done
1. **ProductRepository** — Added `getCurrentStockBulk(List<String> productIds)` method returning `Map<String, int>`
2. **ProductRepositoryImpl** — Implemented with Supabase query using `.in_('id', productIds)` selecting `id, name, stock`
3. **GetCurrentStockBulkUseCase** — New use case wrapping `repository.getCurrentStockBulk`
4. **ServiceLocator** — Registered `GetCurrentStockBulkUseCase` and updated `BillingBloc` factory to include it
5. **BillingEvent** — Added `ValidateStockBeforeBill` and `ClearStockErrorsEvent` events
6. **BillingState** — Added `stockErrors` (List\<String\>?) and `isValidatingStock` (bool) fields with copyWith/props
7. **BillingBloc** — 
   - Injected `GetCurrentStockBulkUseCase`
   - Added `_onValidateStockBeforeBill` handler: queries stock, if errors sets stockErrors, if ok dispatches SubmitBillEvent
   - Updated `_onSubmitBill`: validates stock first, stops if insufficient
   - Added `_validateStock()` private method shared by both handlers
   - Added `_onClearStockErrors` handler
8. **CheckoutPage** — 
   - "Save Bill" button now dispatches `ValidateStockBeforeBill` (not SubmitBillEvent directly)
   - Shows "Checking Stock..." when validating
   - Listens for `stockErrors` and shows AlertDialog with error details
   - Each cart item shows "Insufficient Stock" (red badge) or "Low Stock" (orange badge)

### Key Decisions
| Decision | Why |
|----------|-----|
| ValidateStockBeforeBill dispatches SubmitBillEvent after passing | Clean separation: validation event handles UI flow, submit event handles submission |
| SubmitBillEvent also validates | Defense-in-depth — even if called directly, stock is checked |
| ClearStockErrorsEvent to clear errors | Prevents dialog from re-showing on state changes after dismissal |
| stock check uses current stock from Supabase (not cached) | Real-time source of truth, prevents race conditions |
| Print receipt NOT blocked by stock check | Print-only flow doesn't need inventory validation |
| Low stock warning at 80%+ of available stock | Gives user advance notice before hitting insufficient stock |

### flutter analyze
- Billing feature: 0 issues
- Full project: 0 errors (only pre-existing info-level lints unrelated to this change)
- Fixed: `.in_()` replaced with `.filter('id', 'in', productIds)` for postgrest-dart 2.x compatibility

### TODO
- [ ] (none remaining for this feature)

---

## Current Session: 2026-07-17 — Auth Feature Complete (15 files) ✅

### What Was Done
1. **Auth Feature Created** (15 files, Clean Architecture)
   - **Domain Layer** (7 files):
     - `lib/features/auth/domain/entities/user.dart` — User entity with id, email, name, role
     - `lib/features/auth/domain/repositories/auth_repository.dart` — Abstract repo with login, signUp, loginWithGoogle, logout, getCurrentUser, updateProfile, authStateChanges
     - `lib/features/auth/domain/usecases/login_usecase.dart` — LoginUseCase + LoginParams
     - `lib/features/auth/domain/usecases/signup_usecase.dart` — SignUpUseCase + SignUpParams
     - `lib/features/auth/domain/usecases/login_with_google_usecase.dart`
     - `lib/features/auth/domain/usecases/logout_usecase.dart`
     - `lib/features/auth/domain/usecases/get_current_user_usecase.dart`
   - **Data Layer** (2 files):
     - `lib/features/auth/data/models/user_model.dart` — fromJson, toJson, fromSupabaseAuth, fromProfileJson
     - `lib/features/auth/data/repositories/auth_repository_impl.dart` — Full Supabase implementation with profiles table
   - **Presentation Layer** (6 files):
     - `lib/features/auth/presentation/bloc/auth_event.dart` — 6 events
     - `lib/features/auth/presentation/bloc/auth_state.dart` — 5 states (equatable)
     - `lib/features/auth/presentation/bloc/auth_bloc.dart` — Handles all events via use cases
     - `lib/features/auth/presentation/pages/login_page.dart` — Email + password + Google OAuth
     - `lib/features/auth/presentation/pages/register_page.dart` — Name + email + password + confirm
     - `lib/features/auth/presentation/pages/auth_gate.dart` — AuthGate wrapper widget
2. **Core Updated**:
   - `lib/core/error/failure.dart` — ServerFailure added
   - `lib/core/service_locator.dart` — Auth DI registrations (auto-updated)
   - `lib/config/routes/app_routes.dart` — Login/register routes + redirect guard (auto-updated)
   - `lib/main.dart` — AuthBloc in MultiBlocProvider (auto-updated)
3. **Bugs Fixed**:
   - `onAuthStateChanged` → `onAuthStateChange` (gotrue 2.x API)
   - Duplicate `ServerFailure` class removed
   - Google icon changed from broken asset to styled "G" text
   - AuthBloc `_getRepoForUpdate` replaced with proper `authRepository` injection
   - Unnecessary cast removed from _fetchProfile

### Google Login Support
- `loginWithGoogleUseCase` → `signInWithOAuth(OAuthProvider.google)`
- Android manifest + iOS URL scheme setup required (documented in code comments)
- Supabase Dashboard me redirect URL add karna hoga: `io.supabase.flutter://callback`

### Key Decisions
| Decision | Why |
|----------|-----|
| GoRouter redirect guard (not AuthGate widget) | Simpler, works at route level |
| AuthBloc DI: authRepository injected directly | Needed for profile update without extra use case |
| Google OAuth via Supabase (no google_sign_in package) | Less deps, Supabase handles everything |
| `hide User` on supabase import in repo impl | Avoids naming conflict with domain User entity |
| Styled "G" text for Google button instead of asset | No asset file needed, no network dependency |

### Graphify
- Graph built: 558 nodes, 816 edges, 35 communities
- HTML graph in `graphify-out/graph.html`

### Category UI Created

**2 new files:**
1. `lib/features/category/presentation/pages/category_list_page.dart` — List page with search, BlocConsumer, white rounded cards, edit/delete buttons, FAB, empty/error/loading states
2. `lib/features/category/presentation/pages/add_edit_category_dialog.dart` — Dialog for add/edit with name (required) and description (optional) fields, dispatches AddCategory/UpdateCategory to CategoryBloc

Styling matches product_list_page.dart (same card style, border, shadow, search bar pattern).

### Category Data Layer Added

**2 new files:**
1. `lib/features/category/data/models/category_model.dart` — CategoryModel extends Category, fromJson/toJson/fromEntity/toEntity
2. `lib/features/category/data/repositories/category_repository_impl.dart` — CategoryRepositoryImpl with Supabase CRUD (categories table), ServerFailure on error

### TODO
**Phase 2**
- [x] ~~Category CRUD with Supabase~~ (domain + data + UI done)
- [x] ~~CategoryBloc~~ (created + registered in service_locator)
- [ ] Product CRUD screens
- [ ] Billing with discount + total override

### Category Feature Complete (2026-07-17) ✅

**All 10 files created + registered in DI:**

Domain Layer:
- `lib/features/category/domain/entities/category.dart` — Category entity (id, name, description?, createdAt?)
- `lib/features/category/domain/repositories/category_repository.dart` — Abstract repo: getCategories, addCategory, updateCategory, deleteCategory
- `lib/features/category/domain/usecases/category_usecases.dart` — 4 use cases

Data Layer:
- `lib/features/category/data/models/category_model.dart` — CategoryModel with fromJson/toJson/fromEntity/toEntity
- `lib/features/category/data/repositories/category_repository_impl.dart` — Supabase CRUD on 'categories' table, ordered by created_at desc

Presentation Layer:
- `lib/features/category/presentation/bloc/category_event.dart` — LoadCategories, AddCategory(name, desc), UpdateCategory(id, name, desc), DeleteCategory(id)
- `lib/features/category/presentation/bloc/category_state.dart` — CategoryStatus enum + CategoryState
- `lib/features/category/presentation/bloc/category_bloc.dart` — Handles all events via use cases
- `lib/features/category/presentation/pages/category_list_page.dart` — List page with search, cards, FAB, edit/delete
- `lib/features/category/presentation/pages/add_edit_category_dialog.dart` — Add/edit dialog

DI: Registered in `lib/core/service_locator.dart` (CategoryBloc + 4 use cases + CategoryRepositoryImpl)

---

## Current Session: 2026-07-17 — Reports & History Feature (Presentation Layer + Domain/Data) ✅

### What Was Done

**Domain Layer (3 new/modified files):**
1. `lib/features/report/domain/entities/report_entities.dart` — Added BillSummary, BillItem, DailySales, StockMovement entities (all Equatable, with copyWith)
2. `lib/features/report/domain/repositories/report_repository.dart` — Abstract repo: getBillHistory, getBillDetail, getDailySales, getSalesRange, getLowStockProducts, getStockMovements
3. `lib/features/report/domain/usecases/report_usecases.dart` — 6 use cases with typed Params classes (BillHistoryParams, BillDetailParams, DailySalesParams, SalesRangeParams, LowStockParams, StockMovementParams)

**Data Layer (2 files already existed):**
1. `lib/features/report/data/models/report_models.dart` — BillSummaryModel, BillItemModel, DailySalesModel, StockMovementModel
2. `lib/features/report/data/repositories/report_repository_impl.dart` — Full Supabase implementation with join queries (profiles, products, bill_items)

**Presentation Layer (9 new files):**

Bloc:
1. `lib/features/report/presentation/bloc/report_event.dart` — 7 events: LoadBillHistory, LoadBillDetail, LoadDailySales, LoadSalesRange, LoadLowStockProducts, LoadStockMovements, ResetReport
2. `lib/features/report/presentation/bloc/report_state.dart` — ReportStatus enum (initial/loading/loaded/error) + ReportState with 10 fields + copyWith
3. `lib/features/report/presentation/bloc/report_bloc.dart` — Bloc taking all 6 use cases, handles all events with loading→loaded/error pattern, pagination support

Pages:
4. `lib/features/report/presentation/pages/reports_home_page.dart` — Dashboard with 4 large cards (Bill History, Daily Sales, Low Stock, Stock Movement) in 2x2 grid
5. `lib/features/report/presentation/pages/bill_history_page.dart` — Paginated bill list with date range filters, pull-to-refresh, load more
6. `lib/features/report/presentation/pages/bill_detail_page.dart` — Full bill detail with info cards, amount summary, print button placeholder
7. `lib/features/report/presentation/pages/daily_sales_page.dart` — Date navigation, 2x2 stat cards (Total Sales, Bill Count, Average Bill, Total Discount), 7-day bar chart
8. `lib/features/report/presentation/pages/low_stock_page.dart` — Threshold input, search, color-coded stock levels, empty state
9. `lib/features/report/presentation/pages/stock_movement_page.dart` — Type dropdown filter, date range, color-coded change types, notes

**Integration Updates:**
- `lib/core/service_locator.dart` — Registered ReportRepositoryImpl, all 6 use cases, ReportBloc factory
- `lib/config/routes/app_routes.dart` — Added /reports route with nested routes: /reports/bills, /reports/bills/:id, /reports/daily-sales, /reports/low-stock, /reports/stock-movements

### Key Decisions
| Decision | Why |
|----------|-----|
| Separate event/state/bloc files (not part files) | Matches project style used by auth, product, category features |
| Named params for events with multiple optional fields | Cleaner API, matches existing patterns |
| LoadSalesRange uses named params | Consistent with LoadStockMovements and LoadBillHistory |
| Bill detail page uses constructor injection (not Bloc) | Simpler - data already available from navigation extra, no async needed |
| Pagination via "Load more" button (not auto-scroll) | Simpler UX, user controls when to load more data |
| Low stock list uses local filter for search | Avoids extra API calls, threshold already defines the server query |

---

## Session: 2026-07-17 (Part 2) — Back Button + ReportBloc Fix 🔧

### What Was Done
1. **Shared Back Button Widget** — `lib/core/widgets/app_back_button.dart` (new)
   - `AppBackButton` → `context.pop()` with `context.go('/')` fallback (canPop check)
   - Added to EVERY page's AppBar `leading` (top-left): dashboard, category, reports_home, bill_history, bill_detail, daily_sales, low_stock, stock_movement, shop_details, product(add/edit/qr), settings, register, scanner
   - `home_page` (`/scan` full-screen scanner) → overlay back button top-left (Positioned, black45 bg)
   - checkout_page: left as-is (custom ClearCart + go('/scan') behavior)

2. **ReportBloc Red Screen FIX** — root cause: `ReportBloc` sirf Dashboard ke andar provide tha, `main.dart` MultiBlocProvider mei nahi → saare `/reports/*` pages crash (ProviderNotFoundException)
   - `lib/main.dart` → added `BlocProvider<ReportBloc>` to MultiBlocProvider
   - `dashboard_page.dart` → removed duplicate local BlocProvider, moved initial LoadDailySales/LoadLowStockProducts to `_DashboardViewState.initState()`
   - `dart analyze` → No issues

3. **Android Manifest** — `android/app/src/main/AndroidManifest.xml` → added `android:enableOnBackInvokedCallback="true"` (clears predictive-back warning for PopScope)

### Key Decisions
| Decision | Why |
|----------|-----|
| Shared AppBackButton widget | Avoids copy-paste, single point of control, consistent canPop fallback |
| ReportBloc global in main.dart | Reports pages need it but aren't under Dashboard's widget tree |
| Horizontal pane (right split) not vertical (down) | User preference — avoid vertical splits |

### ⚡ AUTO-UPDATE RULES (NEVER ASK, JUST DO)
- **Har file edit ke baad**: memory.md update + `/graphify --update` run + relevant RPD/phases/architecture/design md update
- **Pane rule**: Vertical split (down) MAT Kholna — horizontal (right) ya existing pane use karo
- **Device**: Wireless ADB baar-baar id change karta hai (RMX3762) → fresh `adb devices` read karke current id use karo, ya USB cable lagao for stability
- **Hot restart**: stop mat karo, `R` bhejo (herdr pane: `herdr pane send-keys <id> R Enter`)

### Todo
- [ ] USB cable lagake stable connection confirm karo
- [ ] Reports pages abhi device pe verify karo (red screen gone?)
- [ ] graphify --update run karo (pending)
