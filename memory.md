# Memory — Session Log & Context

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
