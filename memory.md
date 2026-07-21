# Memory — Session Log & Context

## Current Session: 2026-07-21 — Billing History Section Audit + Warnings Fix ✅

### What Was Done
1. **Deep audit of bill history section** — traced full data flow across report feature (entities → models → repos → BLoCs → pages)
2. **Found issues**: BillDetailPage didn't render individual items, no search/filter on history, no print/receipt buttons, warnings in repo
3. **Fixed warnings**:
   - `report_repository_impl.dart`: Removed 4 unnecessary `!` operators (searchQuery, paymentMethod)
   - `bill_detail_page.dart`: Added `// ignore_for_file: prefer_const_constructors` (TextStyle with runtime constant can't be const)
4. **Graphify updated** — code graph rebuilt: 1709 nodes, 2633 edges, 147 communities

### flutter analyze
- 0 errors, 0 warnings, 0 infos ✅

---

## Current Session: 2026-07-21 — Shop Isolation Audit & Fix ✅

### What Was Done
1. **Comprehensive shop isolation audit** — traced shop_id flow across DB, auth, repos, BLoCs, realtime, Hive
2. **Found 8 gaps** (4 critical, 2 high, 2 medium) where data could leak between shops
3. **Fixed all 8 gaps**:

| # | Severity | Fix | File |
|---|----------|-----|------|
| 1 | Critical | `CategoryRepositoryImpl.getCategories()` — added `_resolveShopId()` fallback so it never returns all shops' categories when shopId is null | `category_repository_impl.dart` |
| 2 | Critical | `ReportRepositoryImpl.getBillDetail()` — added shop_id filter to bill_items query (was missing entirely) | `report_repository_impl.dart` |
| 3 | Critical | `BillingBloc._onSubmitBill()` — added shop_id guard to stock update query | `billing_bloc.dart` |
| 4 | Critical | `RealtimeService.subscribeToProducts()` — added optional `shopId` param, filters events by shop_id before forwarding to BLoC | `realtime_service.dart` |
| 5 | High | `loginWithGoogle()` — added `_ensureShopForOwner()` so Google OAuth users get a shop created automatically | `auth_repository_impl.dart` |
| 6 | High | `Shop` entity — added `id` field so shop can be identified by shop_id in app | `shop.dart`, `shop_model.dart`, `shop_model.g.dart` |
| 7 | Medium | `StaffRepositoryImpl.deleteStaffMember()` — added shop_id filter for defense-in-depth | `staff_repository_impl.dart` |
| 8 | Medium | `ReportRepositoryImpl` — added `_resolveShopId()` to all 6 methods (bill history, bill detail, daily sales, sales range, low stock, stock movements) | `report_repository_impl.dart` |

### Architecture
- **3-layer isolation**: DB RLS (strongest) → App-side query filtering (medium) → BLoC-level shopId propagation (medium)
- **Consistent pattern**: ProductRepo, CategoryRepo, StaffRepo, ReportRepo now all use `_resolveShopId()` fallback
- **Realtime**: ProductBloc passes `shopId` to `subscribeToProducts()` so only own shop's events trigger reloads

### flutter analyze
- 0 errors, 0 warnings ✅

---
## Current Session: 2026-07-21 — Shop Persistence Fix + Final Cleanup ✅

### What Was Done
1. **Shop persistence bug fixed** — `shop_model.g.dart`, `shop_repository_impl.dart`, `shop_details_page.dart`:
   - Root cause: adding `id` field to `Shop` entity corrupted Hive field mapping (old 6-field data vs new 7-field adapter)
   - Fix: Hive adapter now backward-compatible — detects old 6-field data and maps correctly
   - Fix: `ShopRepositoryImpl.getShop()` now falls back to Supabase `shops` table if Hive data missing/corrupt
   - Fix: `_updateControllers` in ShopDetailsPage always syncs (removed empty check that prevented reload)
2. **BillingBloc warning fixed** — `billing_bloc.dart`:
   - Removed unnecessary null check on `shopId` (already guarded by early return on line 244)

### flutter analyze
- 0 errors, 0 warnings ✅

---

### What Was Done
1. **Single-line meta row** — `product_list_page.dart`:
   - Line 1: Product Name
   - Line 2: ₹Price · Stock: N · 📂Category · 📍Location — sab ek hi row mein, dot separators (`·`) se
   - Line 3: Description snippet (only when search matches)
2. **More compact**: vertical padding reduced from 12px to 10px
3. Added `_dotSeparator()` helper for clean visual separation

### flutter analyze
- 0 errors, 0 warnings ✅

---

## Current Session: 2026-07-21 — Fixed Category "All" Selection Not Clearing ✅

### What Was Done
1. **Fixed "All" category selection bug** — `product_bloc.dart` + `product_state.dart`:
   - `ProductState.copyWith()` ki bug fix ki: `null ?? this.selectedCategoryId` old value preserve kar raha tha.
   - Added `clearSelectedCategory: true` param in bloc.
2. **Result**: Ab "All" chip par click karne par "hi" category ka highlight instantly clear ho jata hai!

### flutter analyze
- 0 errors, 0 warnings ✅

---

## Current Session: 2026-07-21 — Fixed Category Chip Highlight State Sync ✅

### What Was Done
1. **Fixed Category Chip Selection Sync** — `product_list_page.dart`:
   - Removed nested `BlocBuilder<CategoryBloc>` wrapper around `BlocBuilder<ProductBloc>` that was causing a state rebuild race.
   - Now directly listens to `ProductBloc` state so `selectedCategoryId == null` ("All" tab) highlights instantly and reliably when clicked.

### flutter analyze
- 0 errors, 0 warnings ✅

---

## Current Session: 2026-07-21 — Fixed Category Switch Animation Glitch ✅

### What Was Done
1. **Fixed Category Transition Animation Glitch** — `product_list_page.dart`:
   - Removed `TweenAnimationBuilder` entry slide animation that triggered on every category chip selection change.
   - Now switching between categories (e.g. Grocery → hi → All) updates instantly and smoothly without items animating in from bottom.

### flutter analyze
- 0 errors, 0 warnings ✅

---

## Current Session: 2026-07-21 — Cleaned up Flutter Analyzer Linter Suggestions ✅

### What Was Done
1. **Resolved 10 Linter Hints across project**:
   - `product_list_page.dart`: Removed unused `services.dart` import + added `const` constructors to widgets (BorderRadius, TextStyle, Icon, FilterByCategory).
   - `checkout_page.dart`: Added `const` to `TextInputType.numberWithOptions` & Padding widgets.
2. **Result**: `flutter analyze` runs completely clean with **0 errors, 0 warnings, 0 infos** ✅

---

## Current Session: 2026-07-21 — Description Match Snippet Highlight on Homepage Search ✅

### What Was Done
1. **Homepage Search Description Highlight** — `dashboard_page.dart` (`_ProductSearchDelegate`):
   - Updated search hint: `'Search product name, barcode or description'`
   - When search query matches `product.description`, an amber description snippet badge (`🔍 ...snippet...`) renders under the barcode row in search results list tile.
   - Consistent visual feedback with Product Management page search!

### flutter analyze
- 0 errors, 0 warnings ✅

---

## Current Session: 2026-07-21 — Description Match Snippet Highlight on Search ✅

### What Was Done
1. **Description Match Snippet Highlight** — `product_list_page.dart`:
   - When user searches and the `_searchQuery` matches `product.description`, a subtle amber badge tag (`_buildDescriptionSnippet`) appears on the card.
   - Shows extracted text snippet (with `...` prefix/suffix) surrounding the matched keyword.
   - Highlights with `Icons.saved_search_rounded` icon & Amber badge so user immediately sees *why* that product matched their search query.
2. **Visual Hierarchy Retained**:
   - Only displays description snippet when search query actually matches description (card remains ultra-compact during normal browsing).

### flutter analyze
- 0 errors, 0 warnings ✅

---

## Current Session: 2026-07-21 — Description Search on Product Management Page ✅

### What Was Done
1. **Added Description Search** — `product_list_page.dart`:
   - Updated product filtering to search against `product.description` (null-safe case-insensitive match):
     `(product.description?.toLowerCase().contains(_searchQuery) ?? false)`
   - Now searches 3 fields: Name, Barcode, **Description** (matches Dashboard search behavior)
   - Updated search input `hintText`: `'Search product name, barcode or description'`

### flutter analyze
- 0 errors, 0 warnings ✅

---

## Current Session: 2026-07-21 — Ultra-Compact Product Cards + Alignment Fix ✅

### What Was Done
1. **Compact & Balanced Layout** — `product_list_page.dart`:
   - Image/placeholder reduced: 52px → 44px (consistent vertical alignment)
   - Left accent bar: fills card height automatically (no hardcoded height)
   - Compact vertical padding: 12px (was 14px)
   - Font scale: Title 14px w700, Price 13px w600, Meta text 11px
   - Single-line meta row: Category + Location side-by-side with icon & spacing
   - Stock badge: compact padding, 11px font
   - Chevron: 18px slate-300
2. **Visual Hierarchy**:
   - Level 1 (Primary): Product Name (14px slate-900)
   - Level 2 (Secondary): Price (13px primaryColor) + Stock badge
   - Level 3 (Tertiary): Category & Location (11px slate-500, side-by-side)
3. **Clean Code**: Removed unused `_metaChip` method

### flutter analyze
- 0 errors, 0 warnings ✅

---

## Current Session: 2026-07-18 — Dashboard Premium Redesign ✅

### What Was Done
1. **Premium stat cards** — `lib/core/widgets/premium_stat_card.dart`:
   - `PremiumStatCard({label, value, color, icon?})`
   - Gradient background (color → 72% alpha), radius 20, colored shadow (blur 16, offset 0,6)
   - Icon chip: white 25% bg, radius 10; label: 12px w600 white 90%, letterSpacing 0.4
   - Value: 26px w800 white; removed Stack/watermark to avoid overflow
2. **Greeting header** — `lib/core/widgets/greeting_header.dart`:
   - `GreetingHeader({userName})` — avatar 48px gradient circle (primary → 70%), radius 16
   - Time-based greeting + date display + user initial avatar
3. **Dashboard action card** — `lib/core/widgets/dashboard_action_card.dart`:
   - `DashboardActionCard` → gradient bg (color → 82%), radius 20, animated entry scale 0.98→1.0 (1200ms)
   - `QuickActionTile` → radius 20, animated scale 0.85→1.0 (400ms easeOutBack), soft dual shadow
4. **Dashboard page** — `lib/features/dashboard/presentation/pages/dashboard_page.dart`:
   - Replaced `_Greeting` → `GreetingHeader(userName: 'San Mondal')`
   - Replaced `_TodaysSales` → 4 `PremiumStatCard`s (Total Sales green, Bills primary, Avg Bill orange, Discount pink)
   - Updated `_LowStockBanner` → gradient error banner with icon chip
   - Removed `_sectionTitle` helper, inline styling
   - Removed unused `stat_card.dart` import
   - Fixed `_ProductSearchDelegate.buildResults/buildSuggestions` return type `List<Widget>` → `Widget`
5. **Design docs** — `design.md`: updated component specs for all premium widgets + animation notes

### flutter analyze
- 0 errors, 0 warnings across all changed files ✅

### TODO
- [ ] Device pe verify: gradient cards + tiles render correctly
- [ ] Stagger animation verify: tiles load sequentially

---

## Current Session: 2026-07-18 — Product Card Tap + Description Copy + Extra Fields ✅

### What Was Done
1. **Product list card now tapable** — `product_list_page.dart`:
   - Entire card wrapped in `GestureDetector` → tap opens `/products/detail/:id`
   - Action buttons (QR, Edit, Delete) still work independently with `HapticFeedback.lightImpact()`
2. **Description copy button** — `product_detail_page.dart`:
   - Description row mein copy icon (clipboard) added
   - One-tap copy with SnackBar confirmation "Description copied!"
3. **Extra fields on detail page**:
   - Created date (`product.createdAt`) — formatted as dd/mm/yyyy
   - Updated date (`product.updatedAt`)
   - QR Data field
4. **Removed unused imports** — `dart:ui` removed from detail page

### flutter analyze
- Both files: 0 issues, 0 warnings ✅

---

## Current Session: 2026-07-18 — Product Detail Page + Dashboard Search Navigation ✅

### What Was Done
1. **Added product detail page** — `lib/features/product/presentation/pages/product_detail_page.dart`
   - Shows: image, name, barcode, price, stock, category, location, description, created/updated dates, QR data
   - Actions: Generate QR, Edit, Delete
2. **Route**: `/products/detail/:id`
3. **Dashboard search** → detail page navigation

---

## Current Session: 2026-07-18 — Dashboard Product Search ✅

### What Was Done
1. **Added product search to dashboard** — search icon in AppBar, SearchDelegate filtering by name/barcode
2. **Results show**: name, price, barcode → tap navigates to detail page

### flutter analyze
- 0 errors throughout ✅

---

## Current Session: 2026-07-21 — Product Detail Page 2-Column Grouped Layout ✅

### What Was Done
1. **Grouped detail rows** — `product_detail_page.dart`:
   - Price + Stock side-by-side in one row (Row of 2 cards)
   - Category + Location side-by-side
   - Created + Last Updated side-by-side
   - Barcode and QR Data remain full-width
2. New `_detailRow2()` + `_detailCard()` widgets: 32px icon, 14px font, 10px gap between cards
3. Null-safe: shows `—` placeholder when value is missing
4. Lint fix: replaced closure `card` with proper `_detailCard` method declaration

---
## Current Session: 2026-07-21 — Edit Page Barcode Editable + Scanner Back Button ✅

### What Was Done
1. **Barcode now editable** — `edit_product_page.dart`:
   - Removed read-only barcode display block
   - Added editable `TextFormField` for barcode with suffix scan button (camera icon → `/scanner` route)
   - `_barcode` added to state + `copyWith` in submit
2. **AppBar fix**: Added hamburger + back chevron Row leading
3. **Scanner page AppBar fix** — `scanner_page.dart`: Added back chevron button
4. **Removed unused import**: `app_theme.dart` re-added for scan button color
5. **Scanner camera fix**: Kotlin incremental cache error resolved via `flutter clean` + fresh build (`mobile_scanner` plugin)
6. **Route fix**: changed `/scanner` → `/scan/scanner` (actual registered route)
7. **Searchable category dropdown** — `edit_product_page.dart`:
   - Replaced `DropdownButtonFormField` with `showModalBottomSheet` picker
   - Features: search bar at top, "No Category" option, selected highlight + checkmark, scrollable list
   - Uses `Category` entity import

8. **Live search fix**: removed `final query` local var that reset on rebuild; now `searchController.text` read directly for live filtering
9. **Stock + Location same row** — `edit_product_page.dart`: side-by-side layout for better visual hierarchy
10. **Add product page updated** — `add_product_page.dart`:
    - Searchable category dropdown (same bottom sheet picker)
    - Stock + Location side-by-side row
    - AppBar: hamburger + back chevron
11. **Instant duplicate check** — `add_product_page.dart`:
    - Barcode scan pe turant duplicate detect + orange floating SnackBar + info icon + auto-close
    - Manual barcode input pe live duplicate check on each keystroke
    - Warning style (amber #E8850C) instead of error red for better UX
12. **Duplicate product popup** — `add_product_page.dart`:
    - Changed SnackBar → AlertDialog popup with product details card
    - Shows existing product name, price, stock
    - Actions: "Go Back" or "View Product" navigation
    - Fixed AlertDialog `leading` → `title` row pattern

### flutter analyze
- 0 errors, 0 warnings, 0 infos ✅

---

---
## Current Session: 2026-07-21 — Edit Page Barcode Editable + AppBar Fix ✅

### What Was Done
1. **Barcode now editable** — `edit_product_page.dart`:
   - Removed read-only barcode display block
   - Added editable `TextFormField` for barcode with validator
   - `_barcode` added to state + `copyWith` in submit
2. **AppBar fix**: Added hamburger + back chevron Row leading (was missing back button)
3. **Removed unused import**: `app_theme.dart` no longer needed

### flutter analyze
- 0 errors, 0 warnings ✅

---

### flutter analyze
- 0 errors, 0 warnings ✅

---

## Current Session: 2026-07-21 — Customer Info on Checkout Page ✅

### What Was Done
1. **Customer Name + Phone fields on CheckoutPage** (`checkout_page.dart`):
   - Inline card at top of scrollable area (above discount section)
   - Two TextFields side-by-side: name + phone (optional, 2+ chars / 10+ digits validation if filled)
   - Clear button resets both fields + BLoC state
   - `_customerNameController` + `_customerPhoneController` with dispose cleanup
2. **BillingState** (`billing_state.dart`): Added `customerName` + `customerPhone` nullable fields with copyWith + props
3. **BillingEvent** (`billing_event.dart`): Added `UpdateCustomerInfoEvent(customerName, customerPhone)`
4. **BillingBloc** (`billing_bloc.dart`):
   - Registered `_onUpdateCustomerInfo` handler
   - `_onSubmitBill` now writes `customer_name` + `customer_phone` to bills insert (was NULL before)
5. **Receipt printing** (`printer_helper.dart`): Customer name + phone printed between date and items separator (only if provided)
6. **PrintReceiptEvent**: Extended with `customerName` + `customerPhone` params
7. **Report entities**: `BillSummary` + `BillSummaryModel` now include `customerName` + `customerPhone` fields
8. **Bill history page**: Shows customer name + phone row on each bill card (when available)
9. **Bill detail page**: Shows customer name + phone in Bill Info card

### DB Migration
- `009_add_customer_phone_to_bills.sql`: Added `customer_phone TEXT` column to bills table (applied via Supabase MCP)
- `customer_name` column already existed but was never populated — now fixed

### flutter analyze
- 0 errors, 0 warnings ✅

---

## Current Session: 2026-07-21 — Receipt Preview + WhatsApp Share ✅

### What Was Done
1. **Receipt Preview Page** (`receipt_preview_page.dart`):
   - Visual receipt render with RepaintBoundary (capturable as PNG)
   - Shop header (name, address, phone, date)
   - Customer info section (name + phone)
   - Items table with Qty, Price, Total columns
   - Subtotal, Discount, Grand Total
   - Payment method + footer
   - Share button in AppBar → captures as PNG via `RenderRepaintBoundary.toImage()` → shares via `share_plus` or `whatsapp_share`
2. **WhatsApp Share**: Customer phone se auto-detect country code (91 prefix for 10-digit Indian numbers), directly send PNG to WhatsApp contact via `WhatsappShare.shareFile()`
3. **CheckoutPage buttons** — ab 2 rows hain:
   - Row 1: **Preview** (blueGrey) + **Print** (primary)
   - Row 2: **WhatsApp** (green #25D366, disabled if no customer phone) + **Save Bill** (green)
4. **Route added**: `/scan/receipt-preview` with extra data (shop, items, totals, customer info)
5. **New deps**: `whatsapp_share: ^2.0.1`, `path_provider: ^2.1.2`

### flutter analyze
- 0 errors ✅

---

## Current Session: 2026-07-21 — Simplified Billing: Save Bill → Preview with 3 Actions ✅

### What Was Done
1. **CheckoutPage simplified** — sirf **Save Bill** button (full width, green)
   - Pehle Preview/Print/WhatsApp/Save sab buttons remove kar diye
   - Save Bill click → stock validation → bill save → navigate to receipt preview
2. **Receipt Preview Page** — 3 buttons bottom bar:
   - **Print** (primary color) → thermal printer se print
   - **WhatsApp** (#25D366 green) → customer phone pe direct PNG challan (auto country code 91)
   - **Done** (blue) → dashboard pe navigate
3. **WhatsApp direct send**: Custom MethodChannel (`com.example.billing_app/whatsapp_share`) via `MainActivity.kt`
   - `whatsapp_share` package broken hai, apna native Kotlin code add kiya
   - PNG cache dir se copy → FileProvider → WhatsApp intent with `jid` (phone@s.whatsapp.net)
   - Customer ka chat direct khulega, PNG attached, no contact selection needed
   - `provider_paths.xml` + AndroidManifest provider + `MainActivity.kt` MethodChannel
4. **Removed old flow**: CheckoutPage se preview/print/WhatsApp buttons hata diye

### flutter analyze
- 0 errors, 0 warnings ✅

---

## Current Session: 2026-07-21 — Layout + Routing Fixes ✅

### What Was Done
1. **Receipt Preview layout** — Print + WhatsApp ek row 50-50, Done full width neeche
2. **Done button redirect** → `/` (Dashboard) instead of `/scan`
3. **Checkout Save Bill button** → full width (`SizedBox(width: double.infinity)`)
4. **Bottom padding** → 32px for receipt preview

### flutter analyze
- 0 errors ✅

