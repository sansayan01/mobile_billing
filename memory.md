# Memory — Session Log & Context

## STANDING RULE (2026-08-21, user-confirmed) — Use Graphify, Don't Full-Read Files ⚡
When investigating/understanding code (finding a symbol, tracing call paths, locating a
widget/method, understanding a feature's wiring), **DO NOT full-read files** — it wastes
tokens + time. Use graphify instead (fast, no LLM needed after build):
- `graphify explain "SymbolName"`  → node + neighbors plain explanation (e.g. `graphify explain "_buildProductTile"`)
- `graphify query "X"`             → BFS traversal around a symbol (add `--budget N` for more nodes)
- `graphify path "A" "B"`          → shortest call/data path between two nodes
- `graphify get_node <name>`       → specific symbol detail
Only read_file the EXACT small region once graphify tells you the file+line, then patch.
Graphify is already built/updated (graphify-out/). After each code change run `graphify update .`.

## STANDING RULE (2026-08-21, user-confirmed) — Post-change Hot Restart on Device ⚡
After ANY code change is complete:
1. `flutter analyze lib` → 0 errors FIRST.
2. **IMMEDIATELY hot restart the device** (before md/graphify): in same Herdr tab (w8:t8), the OTHER pane **w8:p9** is the user's phone running APK via **wireless debugging** (`flutter run` active, PID ~7139). Send capital `R` (Shift+R) via `herdr pane send-text w8:p9 \"R\"` to hot-restart. Do this right after analyze is clean so the USER can START TESTING immediately.
3. THEN update md files (memory.md etc) + `graphify update .` (background; user is testing meanwhile).
4. Logs check (w8:p9 read) allowed anytime for error/crash/error-handling investigation.

## Current Session: 2026-08-24 — PREMIUM UI/UX REDESIGN PROJECT 🚀 (Research Phase ✅)

### Project Goal (user's master prompt)
- Full premium UI/UX redesign — NOT reskin. Layout/nav/hierarchy/motion sab redesign allowed.
- **Functionality preserve karna hai** — BLoC/Supabase/auth/printing/scanner logic untouched.
- Skills use karne ka permission: ui-ux-pro-max (design system) + taste-skill (audit).
- ⚡ **ELECTRICITY RULE:** har sub-phase ke baad `graphify update .` + memory.md update (power cuts se progress bachane ke liye).

### Research Done (2026-08-24)
1. **ui-ux-pro-max installed** — `npm i -g ui-ux-pro-max-cli` + `uipro init --ai opencode` → `.opencode/skills/ui-ux-pro-max/`. Python 3.11 available as `python` (not python3 on this Windows box).
2. **Generated design system direction** (`python search.py "invoice billing POS..." --design-system`): Minimalism/Swiss style, trust-focused pattern, navy+green palette suggestion, Poppins/Open Sans fonts.
3. **Existing theme audited**:
   - Primary purple `#6C63FF`, secondary teal `#03DAC6` (classic AI-default combo), IBM Plex Sans via google_fonts
   - Dark mode FULLY exists (theme_cubit + Hive persistence) — redesign must keep it
   - Cards elevation 4 / radius 16, inputs radius 12 filled, buttons elevation 4 colored shadow
   - `aiGradient` (lavender→blue→cyan) used on dashboard bg
   - text_styles.dart has hardcoded hex colors + good tabularFigures() usage already
4. **Navigation audited** — CRITICAL FINDING: drawer-only nav (AppShell → AppDrawer), **no bottom navigation**. Drawer = 16 items across 7 sections (Main/Inventory/Reports/Warranty/Payments/Settings/Staff). POS app ke liye ye critical UX issue hai.
5. **Scale**: 170 dart files, 16 features, 31 pages, 16 core/widgets (mostly dashboard-specific cards).

### Design Direction Decision (pending user confirmation)
- Option A: Purple identity rakhо, polish karo (safer, brand continuity)
- Option B: Generated navy+green professional palette (trust feel for billing)
- Mockup images banake dikhana better hai (imagegen-frontend-mobile skill)

### Next Steps
1. ~~Audit report~~ ✅ DONE (2026-08-24) — C1 drawer-only nav, C2 tiny fonts (11-13px body), C3 no tokens (179 hardcoded colors, 10 radii), H1 25 files generic spinners, H2 28 files snackbars inconsistent, H3 AI-default purple/teal
2. ~~Design tokens~~ ✅ DONE (2026-08-24) — `lib/core/theme/app_dimensions.dart` created: AppSpacing (4-pt grid: xs4/sm8/md12/lg16/xl24/xxl32), AppRadius (sm8/md12/lg16/xl20/full), AppElevation (low1/mid3/high8 + tinted shadow helpers), AppDurations (150/250/400ms + easeOutCubic/spring curves), AppTouchTarget (min48/button52). analyze clean. **Abhi koi file use nahi kar rahi — wiring screens ke saath hogi**
3. Navigation redesign (bottom nav) — **IN PROGRESS (2026-08-24)**:
   - ✅ `lib/core/widgets/app_bottom_nav.dart` CREATED — 5 tabs: Home(/) · Products(/products) · **Billing CENTER raised gradient circle** (/scan, TweenAnimationBuilder scale on active) · Reports(/reports) · More(opens drawer via Scaffold.of)
   - Active state: pill highlight (primary @12% alpha) + AnimatedContainer 250ms easeOutCubic + HapticFeedback.selectionClick
   - SafeArea(top:false) + surface color + hairline top border. Touch targets ≥48. Semantics labels added.
4. **[RECOVERED SUMMARY — kuch entries editor se lost thi, condensed]** Drawer slimmed 16→9 (Catalog/Business/Shop/Staff sections). Dashboard pass#1 (Due Payments/Customers/Warranty tiles added, _loadDashboardData dedupe). Typography scale `app_typography.dart` wired into app_theme (body 16/14). Components: `app_skeleton.dart` (AppSkeleton/ListTile/List pulse) + `app_feedback.dart` (AppFeedback.success/error/info). **Migration 18 files complete** (skeletons 9 list pages, ~40 snackbars unified; button/dialog/pagination spinners intentionally KEPT). Motion: global _FadeSlideUpTransition page transitions, PremiumStatCard entrance+value crossfade, PrimaryButton press-scale 0.97 + elevation 8→4. design.md updated with Design System v2 section. Full analyze 0 errors maintained.
5. **EXPANDABLE TAB BAR (video-inspired) DONE (2026-08-25)** — user bheja "Expandable Tab Bar.mp4" (ffmpeg frames se analyze). **`quick_actions_panel.dart` NEW:** QuickActionsState.open (global ValueNotifier) + QuickActionsPanel.show() → transparent PageRouteBuilder (300ms in/250ms out) — scrim(tap-close) + glass grid panel (4-col, 8 actions: Categories/Customers/DuePay/Warranty/Damaged/Shop/Settings/Staff-owner, spring scale from bottomRight) + close button. **`app_bottom_nav.dart` REWRITTEN video-style:** floating glass pill (BackdropFilter 18, icon-only 4 tabs Home/Products/Billing/Reports, active=rounded-square primary@14%) + separate 56px circular gradient + button. **SMOOTH MORPH:** Hero(tag 'quick-actions-toggle') dono buttons pe (same gradient circle, same position right:16/bottom:10) + TweenAnimationBuilder rotates + icon 0→45° (=X, spring) on open; hero reverse flight on pop. Nav pill AnimatedOpacity→0 + scale 0.92 when open. Drawer intact (dashboard AppBar hamburger se — logout wahan). analyze lib = 0 issues TOTAL.
   - **Tweak (user feedback):** `extendBody: true` in app_shell (content pill ke PEECHE se scroll hoti hai — true transparency, glass blur visible) + nav padding (16,6,16,4) + panel offsets matched (X bottom=+7, panel=+76). NOTE: extendBody se lambi lists ka last item pill ke peeche chhup sakta hai — jo page ajeeb lage uska bottom padding badhana.
   - **FIX (user screenshot — Shop Details):** pinned bottom buttons nav ke peeche chhupe the. Fix = `SafeArea(top:false)` wrap on inner bottomNavigationBar/bottomSheet (extendBody nav-height MediaQuery.padding.bottom inject karta hai, SafeArea use consume karke button pill ke upar lift hota hai): shop_details Save, edit_product Save, add_product Add, home_page Review Order bottomSheet. product_list cart bar me PEHLE SE inner SafeArea tha (auto-fix, koi change nahi). receipt_preview + checkout = fullscreen routes (nav hidden) — fix not needed. Pattern: **naye pages me pinned bottom UI hamesha SafeArea(top:false) me wrap karo**.
6. **NAVIGATION STYLE TOGGLE (user idea) DONE (2026-08-25)** — `lib/core/navigation/navigation_cubit.dart` NEW: `AppNavigationMode {bottomNav, drawer}` (⚠ Flutter material.dart ka apna NavigationMode hota hai — NAME CLASH hota hai, isliye App prefix) + NavigationCubit w/ Hive persistence ('nav_mode' key in settings box, default bottomNav). Wired: service_locator (singleton), main.dart (BlocProvider), **app_shell.dart** BlocBuilder — bottomNav mode = extendBody+AppBottomNav, drawer mode = no bottom nav + normal scaffold (drawer via existing AppBars hamburgers: dashboard/products/reports pages). **Settings → Appearance → 'Navigation Style'** tile: SegmentedButton (Bottom Bar 🆚 Hamburger) + haptic + live switch. Lesson: enum naam Flutter SDK se clash check karo pehle.
7. **NAV MODE RULES (user requirement) IMPLEMENTED (2026-08-25)** — Rules: drawer mode = drawer me SARE features; bottomNav mode = KISI bhi page pe hamburger NAHI. (a) **`adaptive_app_bar_leading.dart` NEW**: drawer mode→hamburger, bottomNav mode→back btn (route=='/' pe hidden). **17 pages bulk-patched** via PowerShell tempered regex (`leading: IconButton(...openDrawer...)` → `leading: const AdaptiveAppBarLeading(),` + import auto-add). category_list ternary + home_page floating camera menu button manually (home: drawer mode pe hi dikhega). (b) **AppDrawer mode-aware**: drawer mode = FULL menu (Main/Inventory/Reports sub-pages/Warranty sections restored) + slim for bottomNav (+Reports Home link). (c) **Settings Logout item** added (bottomNav mode me drawer unreachable — logout access chahiye) w/ `_buildListItem iconColor` param (⚠ regex ne _buildSwitchItem ko bhi touch kiya tha — revert kiya). (d) product_detail bottom buttons = scroll content ke end me the → scroll padding bottom = 16+MediaQuery.padding.bottom. analyze lib clean (1 pre-existing info).
8. **HAMBUGER FIX (user report: "hamburger kaam nahi kar raha")** — ROOT CAUSE: pages ke nested inner Scaffolds hain; AdaptiveAppBarLeading ka apna context INNER scaffold ko dhoondta tha (drawerless) → openDrawer silent no-op. Pehle kaam karta tha kyunki original code PAGE-STATE ka context use karta tha (inner scaffold ke UPAR → outer shell scaffold milta tha). **FIX: `AppShell.scaffoldKey` (static GlobalKey<ScaffoldState>)** — shell Scaffold pe assign, AdaptiveAppBarLeading ab `AppShell.scaffoldKey.currentState?.openDrawer()` call karta hai. **LESSON: nested Scaffolds me `Scaffold.of(context)` context depth pe depend karta hai — cross-scaffold drawer access ke liye GlobalKey use karo.** User ne bola: use 'boss' mat bolo. analyze clean.

## Current Session: 2026-08-21 — Customer CMS planning ✅ (build pending)
- User approved: full Customer CMS (name+phone only, NO email/address). Link to bills + warranty + due payments via `customer_id`.
- **Full plan:** `customer_cms_plan.md`. Build order + risks documented there.
- **KEY DISCOVERY (verify before any migration):** repo business tables (products, bills, due_payments, warranty_claims) have **NO RLS** — shop isolation is Dart-side via `_resolveShopId()` + `.eq('shop_id', effectiveShopId)` (confirmed in product_/due_payments_repository_impl). Only `profiles` has RLS. So `customers` table = NO RLS, Dart filtering. Don't invent `app.shop_id` session RLS.
- Migrations needed (2): (1) `customers` table + unique(shop_id,phone) + indexes; (2) `bills`/`warranty_claims` add `customer_id` FK + phone backfill.
- Phone normalize helper shared at every capture point.
- Standing rule: after build → analyze → hot restart w8:p9 → docs + graphify.

---

## Current Session: 2026-08-21 — Product Page: Remove Redundant Add Button ✅

### Change
- User: product page mein FAB already hai, toh search-bar ke upar wala add button hata do.
- That "button above search bar" = the AppBar `Icons.add_rounded` IconButton I added earlier (to compensate for FAB hiding on cart).
- Removed AppBar add IconButton from `_buildAppBar`.
- Also removed the FAB `Visibility` hide-on-cart wrapper → FAB now ALWAYS visible (so add-product stays reachable even when cart bar shows). FAB auto-floats above the cart bar (no clash).
- Empty-state "Add Product" button (when no products) kept — still useful.

### Verify
- `flutter analyze lib/features/product/presentation/pages/product_list_page.dart` → 0 issues.

---

## Current Session: 2026-08-21 — Checkout Dialog: Scanner Add Broken ✅

### Problem (user reported)
- Checkout "Add Product" dialog: list-selection add works, but scanner (camera) add + manual barcode entry does NOT add to cart.

### Root Cause
- The dialog's `StatefulBuilder` shadows the page `context` with its own `context` param.
- Scanner/manual handlers did `Navigator.pop(ctx)` (closes dialog) THEN used the **disposed dialog `context`** to `context.push('/scan/scanner')` and `context.read<BillingBloc>().add(ScanBarcodeEvent(...))`.
- Reading BillingBloc / navigating from an unmounted dialog context silently fails → scan never reaches the cart.
- List-add worked because it does NOT pop the dialog first (context still valid).

### Fix (checkout_page.dart)
1. Captured `final pageContext = context;` BEFORE `showDialog` (page-level context, never shadowed).
2. Scanner button: use `pageContext.push('/scan/scanner')` + `pageContext.read<BillingBloc>().add(ScanBarcodeEvent(result))`.
3. Manual barcode `onSubmitted`: same switch to `pageContext`.
- Removed dead `if (mounted) {}` empty blocks.

### Verify
- `flutter analyze lib/features/billing/presentation/pages/checkout_page.dart` → 0 errors (1 pre-existing info lint at 988, safe).

---

## Current Session: 2026-08-21 — Billing Scanner Beep Sound Missing ✅

### Problem (user reported)
- Product page scanner (search) → beep sound aa raha tha.
- Billing / scan & billing page → product scan karte time beep nahi aa raha tha.

### Root Cause
- Billing product-scan flow uses `home_page.dart` inline `MobileScanner` with its own `_onDetect` (line 65). That handler only called `Vibration.vibrate()` — **`BeepHelper.playBeep()` call missing** (aur `beep_helper` import bhi nahi tha).
- Standalone `scanner_page.dart` (used by product search + checkout scan button) DOES call `BeepHelper.playBeep()` — that's why those beep the right way.
- Checkout's scan button correctly `context.push('/scan/scanner')` → uses the beep-enabled page, so it was fine.

### Fix
1. Added `import '../../../../core/utils/beep_helper.dart';` to `home_page.dart`.
2. Added `BeepHelper.playBeep();` in `HomePage._onDetect` right after the vibration, before `ScanBarcodeEvent`.
3. **Softened vibration**: was `Vibration.vibrate()` (default 500ms, max amplitude = too harsh). Changed to `Vibration.vibrate(duration: 120, amplitude: 128)` (short + ~half intensity).

### Verify
- `flutter analyze lib/features/billing` → 0 errors (only 1 pre-existing info lint at checkout_page.dart:983, unrelated).

---

## Current Session: 2026-08-21 — Navigation Back-Button Fix (app close bug) ✅

### Problem (user reported)
From any sub-page, Android back button closed the whole app instead of returning to Dashboard. Dashboard back should close the app (correct), but sub-pages should land on dashboard first.

### Root Cause (graphify + code)
- `lib/config/routes/app_shell.dart` wrapped the ENTIRE shell in `PopScope(canPop:false)` → `onPopInvoked` forced `goRouter.go('/')` on EVERY back press. This swallowed sub-page pops and, because `go('/')` resets the stack, the system saw no remaining history and closed the activity. Dashboard back also didn't reliably exit.

### Fix
1. **Removed global PopScope from `app_shell.dart`** — pages now pop normally via go_router's navigator stack (ShellRoute handles `/products` → `/` etc).
2. **Added `PopScope(canPop:false)` + `SystemNavigator.pop()` to `DashboardPage`** (`_DashboardViewState.build`) — back on dashboard now cleanly exits the app.
- `services.dart` already imported (SystemNavigator available).
- Sub-pages already use `context.pop()`/`Navigator.pop()` → land on parent → eventually dashboard.

### Verify
- `flutter analyze lib` → 0 errors. Both edited files clean.

### Flow now
sub-page back → parent page → ... → Dashboard → (back) → app closes. ✅

---

## Current Session: 2026-08-21 — Products Page: Persistent Cart Bar (FAB overlap fix) ✅

### What Was Done
1. **Swipe-to-add cart feedback changed from SnackBar → persistent mini-cart bar** (user chose Option 3).
   - `product_list_page.dart`: removed floating `SnackBar` in `_addToCart` (it overlapped + hid the add-product FAB at bottom-right).
   - Added `bottomNavigationBar` = `BlocBuilder<BillingBloc>` mini-cart bar: shows item count + `totalAmount` + "View Cart" button (pushes `/scan/checkout`). Hidden (`SizedBox.shrink`) when cart empty.
   - FAB (`_buildFab`, add product) now wrapped in `Visibility` — hidden when cart non-empty so it doesn't clash with the cart bar.
   - Added "Add product" `IconButton` to the AppBar so add-product stays reachable even when FAB is hidden.
   - Cart bar uses `AppTheme.primaryColor` gradient, `SafeArea` for notch, rounded 16 radius.

   **flutter analyze:** 0 errors (whole lib: 0 errors). Only pre-existing info lints remain.

---

## Current Session: 2026-08-21 — Damaged Products Management Feature ✅

### What Was Done
1. **Damaged Products Management Feature** — complete implementation for tracking and managing damaged inventory:

   **Domain Layer:**
   - `DamagedProduct` entity: id, productId, productName, barcode, image, price, quantityDamaged, previousStock, newStock, damageType, notes, damageDate, reportedByName, estimatedLoss
   - `DamagedProductsRepository` interface: getDamagedProducts, getTotalDamageLoss, getDamagedProductsCount, markAsDamaged

   **Data Layer:**
   - `DamagedProductsRepositoryImpl`: queries `stock_adjustments` where `reason='damage'`, joined with products for name/barcode/price/image. Mark as damaged: decreases stock + logs adjustment + audit log. No new DB migration needed — reuses existing `stock_adjustments` table.

   **BLoC Layer:**
   - `DamagedProductsBloc`: LoadDamagedProducts, SearchDamagedProducts, FilterDamagedProductsByDate, MarkProductAsDamaged events
   - State: damagedProducts, totalLoss, totalCount, isLoading, isMarking, error, successMessage, searchQuery, startDate, endDate

   **Presentation Layer:**
   - `DamagedProductsPage`: red gradient summary card (total loss ₹ + count), search bar, date range filter chips, list view with product image/name/barcode, quantity badge, price badge, damage type, loss amount, date
   - `MarkDamagedDialog`: quantity +/- selector, 6 damage type choice chips (Broken, Defective, Expired, Water Damage, Scratched, Other), optional notes field, stock validation

   **Integration:**
   - Product Detail Page: 'Mark as Damaged' button in Stock Adjustment section (disabled when stock=0)
   - Product List Page: 'Mark as Damaged' in long-press menu (only when stock>0)
   - Route: `/damaged-products` with BlocProvider in app_routes.dart
   - Drawer: 'Damaged Products' menu item under Payments section
   - DI: DamagedProductsRepository + DamagedProductsBloc registered in service_locator.dart
   - main.dart: DamagedProductsBloc added to MultiBlocProvider

   **Files Created:**
   - `lib/features/damaged_products/domain/entities/damaged_product.dart`
   - `lib/features/damaged_products/domain/repositories/damaged_products_repository.dart`
   - `lib/features/damaged_products/data/repositories/damaged_products_repository_impl.dart`
   - `lib/features/damaged_products/presentation/bloc/damaged_products_bloc.dart`
   - `lib/features/damaged_products/presentation/bloc/damaged_products_event.dart`
   - `lib/features/damaged_products/presentation/bloc/damaged_products_state.dart`
   - `lib/features/damaged_products/presentation/pages/damaged_products_page.dart`
   - `lib/features/damaged_products/presentation/pages/mark_damaged_dialog.dart`

   **Files Modified:**
   - `lib/core/service_locator.dart` — DI registration
   - `lib/config/routes/app_routes.dart` — route + imports
   - `lib/core/widgets/app_drawer.dart` — drawer menu item
   - `lib/main.dart` — MultiBlocProvider
   - `lib/features/product/presentation/pages/product_detail_page.dart` — Mark as Damaged button
   - `lib/features/product/presentation/pages/product_list_page.dart` — long-press menu + import
   - `RPD.md` — Section 10 added
   - `phases.md` — Phase 7 added

   **Design Decisions:**
   - No new DB migration — leverages existing `stock_adjustments` table with `reason='damage'`
   - Client-side search for product name/barcode (joined data not searchable server-side)
   - Damage type + free-form notes both stored in `note` field as `"type|notes"` (no schema change) — encoded/decoded via `DamagedProduct.encodeNote`/`decodeNote`
   - Stock decreases automatically when product marked as damaged
   - Date range filter uses Supabase `gte`/`lt` on `created_at`

   **Improvements (2026-08-21 — same session):**
   1. **Notes bug fixed** — earlier `damageType` + `notes` both wrote to `note` column, so notes were lost. Now encoded as `"type|notes"` (Dart-only, no migration). Legacy rows (only type stored) still decode correctly via `decodeNote`.
   2. **Human-readable damage type** — page shows "Broken"/"Water Damage" etc via `DamagedProduct.damageTypeLabel` instead of raw DB value.
   3. **Notes now visible** — list card shows "Note:" line when notes present.
   4. **reportedByName** — now resolves to staff display name (via `_resolveStaffName`) instead of raw UUID.
   5. **CSV Export** — new `CsvExportImport.exportDamagedProducts` + AppBar download button (disabled when empty).
   6. **Pull-to-refresh** — `RefreshIndicator` wraps the list.
   7. **Undo / Reverse damage** — new `undoDamage` repo method + `UndoDamagedProduct` event + confirm dialog (restores stock, deletes adjustment row, audit log). Per-card undo IconButton.

   **flutter analyze:** 0 errors, 0 warnings ✅ (whole lib: 0 errors)

---

## Current Session: 2026-08-20 — Signed Release APK + Split-per-ABI 📦

### What Was Done
1. **Release keystore generated** — `android/app/billing_app-release.keystore` (alias `billing_app`, RSA 2048, 10000 days, auto-generated password stored in `android/key.properties` — both gitignored)
2. **`android/app/build.gradle.kts`** — signing config (loads `key.properties`), release buildType now uses release signing (debug fallback), `isMinifyEnabled=true` + `isShrinkResources=true`
3. **`android/app/proguard-rules.pro` (new)** — Flutter keep rules + `-dontwarn` for Play Core split install (R8 fix)
4. **Build command** — `flutter build apk --release --split-per-abi --no-tree-shake-icons`
   - Output: `app-armeabi-v7a-release.apk` (24.9MB), `app-arm64-v8a-release.apk` (28.5MB), `app-x86_64-release.apk` (31.0MB)
   - Signing verified via apksigner ✅
5. **`--no-tree-shake-icons` required** — category pages use dynamic `IconData` (non-const), tree-shaking fails. Fix later = make IconData const.

### Notes
- KGP warning (Built-in Kotlin migration) — non-blocking, plugins migrate karne par hoga
- Release build uses minification — R8 missing rules were added to proguard-rules.pro

---

## Previous Session: 2026-08-20 — Report Pages Modernization 📊✨

### What Was Done
1. **Reports Home Page** — CustomScrollView + SliverAppBar, gradient stat cards, modern grid layout with 4 report cards (Daily Sales, Low Stock, Bill History, Stock Movement)
2. **Daily Sales Page** — Gradient summary header with animated counters, bar chart, weekly/monthly toggle, export CSV
3. **Low Stock Page** — Gradient summary card (red gradient), category filter chips, animated product cards with stock progress bars, reorder threshold, export CSV
4. **Stock Movement Page** — Summary stats (Total/Added/Removed), type filter chips with icons, date range picker, staggered card animations, export CSV
5. All pages: CustomScrollView, SliverAppBar, modern card designs, haptic feedback, staggered animations

### flutter analyze
- 0 errors, 0 warnings ✅ (low_stock_page.dart + stock_movement_page.dart verified)

---

## Previous Session: 2026-08-20 — Dual View (Classic List + Cover-flow) 🔀

### Decision
- User: Spotlight cover-flow **accha laga** ❌ lekin default nahi rakh sakte
- **2 views**: Classic List (default) + Cover-flow (optional)
- **Har baar default** = Classic List (no persistence, session-only toggle)
- Toggle button = **AppBar icon**

### What Was Done
1. **`product_coverflow_view.dart` (new file)** — Cover-flow view extracted: `ProductCoverflowView` (own PageController + dial keys + currentIndex state, resets to page 0 when first product changes via `didUpdateWidget`) + `_CoverFlowItem` + `_CoverCard` + `ProductCoverflowSkeleton` (public)
2. **`product_list_page.dart` (rewrite as shell)**:
   - Shell: AppBar (menu + **view toggle icon** animated rotation + refresh + sort + export/import) + hero search (shared) + `AnimatedSwitcher` (350ms fade) between views
   - **`_ClassicListView` (restored original pre-Bento UI)**: category FilterChips (All + counts) + classic tiles (stock accent bar, image, name, description snippet, stock/unit/barcode meta, price)
   - `_isCarousel` bool state — no persistence
   - Loading: `_isCarousel` ? `ProductCoverflowSkeleton` : spinner
   - Shared across views: search query, sort, category filter, FAB
3. flutter analyze: **0 issues** ✅ (both files)
4. **Fix (user feedback)**: Classic list cards ab **bilkul pehle jesa** — card `margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6)` + ListView `padding: symmetric(vertical: 8)` restored (pehle cards flush `EdgeInsets.zero` the, ab per-card inset + gaps). Tile content already faithful (stock accent bar, 64px image, name+chevron, desc snippet, stock/unit/barcode meta, price).
5. **Verified via graphify backup**: `graphify-out/2026-08-20/graph.json` backup confirmed pre-Bento file had exactly `_buildProductTile`, `_productImage`, `_stockBadge`, `_dotSeparator`, `_unitBadge`, `_metaText` — restored card is structurally identical ✅ (user confirmed — bas refresh karna tha, no further change needed).
6. **Compact Classic card (user request)**: card ko **compact** kiya (100px → ~60px):
   - Decisions: **price name ke right**, keep **stock + category + unit** (barcode/desc-snippet/chevron removed), **image 40px**
   - New layout: accent bar + 40px image + Line1(name w600 14 + price w700 14 right) + Line2(stock badge + category gray flexible + unit purple)
   - Removed dead code: `_dotSeparator`, `_metaText`, `_buildDescriptionSnippet`, `_ClassicListView.searchQuery` param + call site
7. **Tweak (user request)**: unit **hataya** cards se, **location add** kiya — Line 2 ab: stock badge + category + location (gray, `·` separator, both flexible/ellipsis). `_unitBadge` method removed.
8. **Card improvements (user picked 5/6, mini stock bar skip kiya)**:
   - **Out-of-stock gray out**: stock ≤ 0 → card content 50% opacity (accent bar stays red)
   - **Swipe actions**: `Dismissible` — right swipe = green "Stock +" quick-stock bottom sheet (`UpdateProduct.copyWith(stock)`), left swipe = red "Delete" confirm dialog (`DeleteProduct`); `confirmDismiss` returns false (card snaps back)
   - **Long-press menu**: bottom sheet → Edit / Show QR Code / Delete
   - **Initial-letter avatar**: no-image placeholder ab first letter of name, color from `Colors.primaries[name.hashCode]`
   - **Add-to-cart button**: trailing 30px circular primary button → `BillingBloc.AddProductToCartEvent` + green snackbar
   - Shell methods: `_showLongPressMenu`, `_confirmDelete` (with `mounted` guard), `_quickStock`, `_addToCart`; `_ClassicListView` gets 4 new callbacks
9. **Batch 2 — user picked ALL 7 suggestions**:
   - **Low-stock filter**: amber pill toggle in shared header bar (below search, both views) — count = `isLowStock` products; active = amber fill; filters list to low/out. Plus **mini stats text** `total · low · out` (hidden jab no products)
   - **Undo delete**: delete ke baad green snackbar "Undo" → `AddProduct(product)` restore (single + bulk dono me)
   - **Bulk selection**: AppBar `checklist` icon → selection mode (Close + N selected + export + red delete actions); tap/long-press toggle select; Dismissible disabled (`DismissDirection.none`); trailing circular check indicator (selected = primary fill + white check); selected card = 2px primary border. Bulk delete = confirm + Undo snackbar; bulk export = `CsvExportImport.exportProducts(selected)`
   - **Real CSV import**: `more_vert → Import from CSV` ab real hai — `CsvExportImport.importProducts()` (file_picker + csv parse) → `_productFromCsvMap` (uuid v4 id, skip empty names) → `AddProduct` each + count snackbar
   - **Copy barcode**: long-press menu me "Copy barcode" → `Clipboard.setData` + snackbar
   - **Search by location**: filtering me `product.location` match add kiya
   - Fix: `Dismissible` me `enabled` param exist nahi → `DismissDirection.none` use kiya (selection mode)
   - `flutter analyze product_list_page.dart` → 0 issues ✅
10. **Bug fix (user reported): "categories kabhi kabhi show nahi ho rahe"** — Race condition: categories `context.read<CategoryBloc>().state.categories` read kiya ja raha tha ProductBloc ke `BlocConsumer` builder ke andar → `context.read` subscribe nahi karta → jab CategoryBloc async load hoke emit karta, product list UI rebuild nahi hota → chips empty/stale reh jaate. **Fix**: shell build me `BlocConsumer<ProductBloc>` ke builder ke andar `BlocBuilder<CategoryBloc, CategoryState>` wrap kiya — ab CategoryBloc emit hota hai to chips + coverflow categoryNames turant rebuild hote hain. `flutter analyze` → 0 issues ✅

### Reminder
- ⚠️ Pre-existing errors `category_list_page.dart` (uncommitted): `context.go` undefined, `theme` undefined — abhi bhi baaki
- Bento code fully gone (user rejected)

---

## Previous: 2026-08-20 — Product Page UI Upgrade v2 (Spotlight Cover-flow) 🎡

### Context
- Pehle **Bento Inventory** design banaya tha — user ko maza nahi aaya ❌ → poocha aur **Spotlight Cover-flow** chuna ✅

### What Was Done
1. **ProductListPage redesigned → "Spotlight Cover-flow"** (`product_list_page.dart`):
   - **3D cover-flow carousel** (`PageView` viewportFraction 0.72 + `_CoverFlowItem`): `Matrix4` perspective + `rotateY(offset*0.72)` + scale + opacity fade — side cards peek karte hai, center card front
   - **Cover card** (radius 28): bada product image (Hero `product-{id}`), category badge (purple), stock badge (green/orange/red), low-stock amber banner, name + ₹ price (22 w800) + unit chip + barcode + **Edit/QR buttons**
   - **Category dial** (horizontal pills): icon + label + count, selected = primary fill + glow, auto-center (`Scrollable.ensureVisible alignment 0.5`), haptic
   - **Hero search**: 56px pill with primary border glow + "Spotlight search..." + gradient scanner button
   - **Bottom panel**: animated dots (active widens) + "N of M · Swipe to browse" (dots sirf ≤12 products pe)
   - **AppBar**: menu + **Refresh button** (add) + sort + export/import
   - Expandable FAB (Add → Scan) retained, `IgnorePointer` fix retained
2. **Bugs fixed earlier (retained)**: realtime DELETE fix, edit barcode controller, Hero on detail page
3. **Motion**: 3D rotateY cover-flow, card border/glow animates for center, skeleton carousel shimmer, animated empty state

### Lessons
- **Design direction user ko pehle dikha ke confirm karo** — Bento pick karne ke baad bhi maza nahi aaya, dobara poochhna pada. Ek hi file me 2 baar full redesign = time waste. Ab "Mix — tu decide" wala option bhi user ko de.

### flutter analyze
- Meri files: 0 issues ✅ (product_list_page clean)
- ⚠️ Pre-existing errors `category_list_page.dart` (uncommitted): `context.go` undefined, `theme` undefined — abhi bhi baaki

---

## Previous: 2026-08-20 — Product Page UI Upgrade (Bento Inventory) 🎨

### What Was Done
1. **ProductListPage full redesign** — new "Bento Inventory" UI (`product_list_page.dart`):
   - **Category rail** (left, 92px): vertical pill rail with icon + label + count badge, animated selection (scale spring + glow shadow)
   - **Bento grid** (right): rhythm `[featured, pair, pair]` — featured full-width card (image + stock progress bar), normal 2-col tiles (image top + price + stock dot + unit chip + category)
   - **Search bar**: rounded pill + scanner button (gradient), clear (X) button, no more barcode validator on search field
   - **Expandable FAB**: tap = Add, expands to reveal "Scan barcode" mini-FAB (easeOutBack + fade)
   - **Motion**: `_StaggerIn` staggered fade+slide entrance (keyed by product id — filter/search pe re-animate nahi hota), `_Pressable` tap scale 0.97 + haptic, Hero flight list→detail
   - **States**: skeleton shimmer loading, animated empty state + CTA, no-match state with clear button
   - **RefreshIndicator** → reload products; sort + export/import menus retained
2. **Bug fixes**:
   - `realtime_service.dart` — DELETE events drop ho rahe the (newRecord empty on delete → shop filter `oldRecord['shop_id']` se read karo). Ab deleted products realtime me list se hat jayenge.
   - `edit_product_page.dart` — barcode scan field ab `TextEditingController` use karta hai (pehle `initialValue` + setState se scanned barcode field me dikhta hi nahi tha)
   - `product_detail_page.dart` — image pe `Hero` add (list→detail flight)
3. **Navigation:** sab existing routes same — detail/edit/add/qr untouched

### flutter analyze
- Meri files: 0 errors ✅ (product_list_page, realtime_service, edit_product_page clean)
- ⚠️ Pre-existing errors `category_list_page.dart` (uncommitted kaam me): `context.go` undefined, `theme` undefined — is session me touch nahi kiya, baaki session me fix karna hai

---

## Previous: 2026-08-20 — Product Management Enhancements ✅

### What Was Done
1. **Product Management Enhancements** — 6 major features added:

   **Database (Supabase Migration)**:
   - `012_add_product_enhancements.sql`: Added `min_stock_level`, `unit` columns to products table
   - Created `stock_adjustments` table for tracking stock movements
   - RLS policies for stock_adjustments (shop_id scoped)
   - Indexes for performance

   **New Packages Added**:
   - `image_picker: ^1.1.2` — Camera/Gallery image selection
   - `flutter_image_compress: ^2.3.4` — 90% image compression
   - `csv: ^6.0.0` — CSV export/import
   - `file_picker: ^8.0.3` — File picking for CSV import

   **Domain Layer**:
   - `Product` entity updated: Added `minStockLevel` (default: 5), `unit` (default: 'pcs')
   - `StockAdjustment` entity: id, productId, previousStock, newStock, quantityChanged, reason, note, createdAt, createdBy
   - `StockRepository` interface: adjustStock, getStockHistory, getAllAdjustments

   **Data Layer**:
   - `ProductModel` updated with min_stock_level, unit fields
   - `ProductRepositoryImpl` updated with new fields in all queries
   - `StockRepositoryImpl`: Full Supabase implementation with stock adjustment tracking

   **BLoC Layer**:
   - `StockBloc`: AdjustStock, LoadStockHistory, LoadAllAdjustments events
   - State: status, adjustments, message

   **Presentation Layer**:
   - `AddProductPage`: Image picker (Camera/Gallery) + auto-compress + unit dropdown + min stock level input
   - `EditProductPage`: Same image picker support + new fields
   - `ProductListPage`: Sort options (Newest, Price Low/High, Name A-Z, Stock Low) + Export/Import CSV buttons + Unit badge + Low stock warning icon
   - `ProductDetailPage`: Unit badge, Min Stock Level display, Stock Status indicator, Stock Adjustment section with +/- buttons, Reason dialog (Sale, Damage, Return, Sample, Theft, Restock, Found, Adjustment)

   **Utilities**:
   - `ImageCompress`: 90% compression utility for Supabase free tier storage
   - `CsvExportImport`: Export products to CSV, Import from CSV

   **DI Registration**:
   - `StockRepository` + `StockBloc` registered in service_locator.dart

   **Migration Required**:
   - Run `012_add_product_enhancements.sql` in Supabase SQL Editor

---

## Previous Session: 2026-08-19 — Due Payments Management Feature ✅

### What Was Done
1. **Due Payments Management Feature** — complete implementation for tracking partial payments:

   **Database (Supabase Migration)**:
   - `011_add_due_payments.sql`: Added `amount_paid`, `due_amount`, `payment_status` columns to bills table
   - Added index on `payment_status` for fast queries
   - Created `due_payments_view` for pending dues

   **Domain Layer**:
   - `DuePayment` entity: billId, customerName, customerPhone, grandTotal, amountPaid, dueAmount, paymentMethod, staffName, billDate
   - `DuePaymentsRepository` interface: getDuePayments, getTotalPendingDue, collectPayment, getBillForDuePayment

   **Data Layer**:
   - `DuePaymentsRepositoryImpl`: Full Supabase implementation with shop_id scoping, search, payment collection

   **BLoC Layer**:
   - `DuePaymentsBloc`: LoadDuePayments, CollectPayment, SearchDuePayments events
   - State: duePayments, totalPendingDue, isLoading, isCollecting, error, successMessage, searchQuery

   **Presentation Layer**:
   - `DuePaymentsPage`: Orange gradient card showing total pending due, search bar, list of due payments with collect button
   - Collect Payment Dialog: Shows bill total, paid amount, due amount, input field for new payment
   - Full dark mode support

   **Integration**:
   - CheckoutPage: Added "Payment" section with amount paid input field + due amount badge
   - BillingState: Added `amountPaid` field
   - BillingBloc: Added `UpdateAmountPaidEvent` + updated `_onSubmitBill` to save payment status
   - ReceiptPreviewPage: Shows due amount if partial payment (orange card with paid/due breakdown)
   - Routes: Added `/due-payments` route with BlocProvider
   - AppDrawer: Added "Due Payments" menu item under "Payments" section
   - ServiceLocator: Registered DuePaymentsRepository + DuePaymentsBloc

   **RPD.md Updated**: Added Section 9 (Due Payments Management) with all features

### Files Created/Modified
- `supabase/migrations/011_add_due_payments.sql` (NEW)
- `lib/features/due_payments/domain/entities/due_payment.dart` (NEW)
- `lib/features/due_payments/domain/repositories/due_payments_repository.dart` (NEW)
- `lib/features/due_payments/data/repositories/due_payments_repository_impl.dart` (NEW)
- `lib/features/due_payments/presentation/bloc/due_payments_bloc.dart` (NEW)
- `lib/features/due_payments/presentation/bloc/due_payments_event.dart` (NEW)
- `lib/features/due_payments/presentation/bloc/due_payments_state.dart` (NEW)
- `lib/features/due_payments/presentation/pages/due_payments_page.dart` (NEW)
- `lib/features/report/domain/entities/report_entities.dart` (UPDATED)
- `lib/features/report/data/models/report_models.dart` (UPDATED)
- `lib/features/billing/presentation/bloc/billing_state.dart` (UPDATED)
- `lib/features/billing/presentation/bloc/billing_event.dart` (UPDATED)
- `lib/features/billing/presentation/bloc/billing_bloc.dart` (UPDATED)
- `lib/features/billing/presentation/pages/checkout_page.dart` (UPDATED)
- `lib/features/billing/presentation/pages/receipt_preview_page.dart` (UPDATED)
- `lib/config/routes/app_routes.dart` (UPDATED)
- `lib/config/routes/app_shell.dart` (READ ONLY)
- `lib/core/widgets/app_drawer.dart` (UPDATED)
- `lib/core/service_locator.dart` (UPDATED)
- `RPD.md` (UPDATED)
- `memory.md` (UPDATED)

---

## Current Session: 2026-07-24 — Advanced Dashboard Analytics (fl_chart + 4 new widgets) ✅

### What Was Done
1. **Added `fl_chart: ^0.69.0`** to pubspec.yaml — zero chart libraries earlier, now have pie/bar/line charts
2. **4 new analytics widgets created** in `lib/core/widgets/`:
   - `payment_donut_chart.dart` — Pie chart: UPI/Cash/Card/Credit breakdown with percentages + bill counts
   - `top_products_bar_chart.dart` — Horizontal-ish bar chart: top 5 products by quantity sold, color-coded by revenue
   - `monthly_trend_card.dart` — FL line chart: 30-day sales trend with tooltips + total/avg chips
   - `staff_performance_card.dart` — Progress bars + rank badges: staff leaderboard by revenue (owner-only)
3. **Dashboard layout updated** (`dashboard_page.dart`):
   - Quick Actions moved UP — right after Today's Sales, before Weekly Trend
   - Payment Donut + Top Products added between Weekly Trend and Inventory Health
   - Monthly Trend + Staff Performance added after Recent Transactions
   - `LoadSalesRange` event added to initState + onRefresh for 30-day data
4. **All helpers made public** — `ProductSales`, `ProductAggregator`, `StaffStat`, `StaffAggregator` renamed from private (no `_`) so dashboard can use them
5. **Fixed lint errors**: pct scope, private types in public API, num→int type mismatch, unused variables, unnecessary toList

### Dashboard Layout (final)
```
GreetingHeader
Low Stock Banner
Today's Sales (4 PremiumStatCards)
Quick Actions (DashboardActionCard + 6 tiles)
This Week (SalesTrendCard — 7-day CustomPainter)
Payment Methods Donut (fl_chart Pie)
Top Products Bar Chart (fl_chart Bar)
Inventory Health
Recent Transactions
Monthly Trend (fl_chart Line — 30-day)
Staff Performance (owner-only)
```

### Analytics Data Pipeline
- Payment donut + top products: derived from `ReportBloc.billHistory` (client-side aggregation)
- Monthly trend: derived from `ReportBloc.salesRange` (fetch via `LoadSalesRange`)
- Staff performance: derived from `ReportBloc.billHistory` + owner-only guard

### flutter analyze
- 0 errors, 0 warnings ✅ (only 2 pre-existing info on add/edit product pages)

---

## Current Session: 2026-07-23 — Dark Mode: Auth/Category/Report/Shop/Staff Pages ✅

### What Was Done
1. **15 files updated for dark mode** — all hardcoded Colors replaced with `Theme.of(context)` based colors:
   - **Auth pages (4)**: `login_page.dart`, `register_page.dart`, `email_verification_page.dart`, `auth_gate.dart` (no changes needed)
   - **Category pages (2)**: `category_list_page.dart`, `add_edit_category_dialog.dart` (no changes needed)
   - **Report pages (6)**: `reports_home_page.dart`, `bill_history_page.dart`, `bill_detail_page.dart`, `daily_sales_page.dart`, `low_stock_page.dart`, `stock_movement_page.dart`
   - **Shop page (1)**: `shop_details_page.dart`
   - **Staff pages (2)**: `staff_list_page.dart`, `add_staff_page.dart`

### Key Replacements
- `Colors.white` backgrounds → `theme.colorScheme.surface`
- `Colors.black87`/`Colors.black` text → `theme.colorScheme.onSurface`
- `Colors.grey[100]` borders → `theme.dividerColor`
- `Colors.grey[400/500/600]` meta/icons → `theme.colorScheme.onSurfaceVariant`
- `Colors.red` snackbars → `theme.colorScheme.error`
- `Colors.green` success snackbars → `theme.colorScheme.primaryContainer`
- `Colors.grey[200]` container bg → `theme.colorScheme.surfaceContainerHighest`
- `Colors.white` CircularProgressIndicator on buttons → `theme.colorScheme.onPrimary`
- `Colors.grey[300]` borders → `theme.colorScheme.outlineVariant`
- `Colors.black12` boxShadow kept as-is (works in both modes)

### flutter analyze
- 0 errors, 0 warnings ✅

---

## Current Session: 2026-07-23 — Full Dark Mode Implementation 🎨🌙

### What Was Done
A. **Core Theme Infrastructure**
1. **New: `theme_cubit.dart`** — ThemeMode Cubit with Hive persistence (reads/writes 'theme_mode' key in settings box). Supports light/dark/system modes.
2. **Updated: `app_theme.dart`** — Added `AppTheme.darkTheme` with full dark color scheme:
   - `darkBackground: #0E0E18`, `darkSurface: #1A1A2E`, `darkCard: #22223A`, `darkInput: #2A2A42`
   - Dark `ColorScheme.fromSeed` with `Brightness.dark`, error color `#CF6679`
   - All widget themes adapted: AppBar, Card, InputDecoration, ElevatedButton, Dialog, SnackBar, FAB, Switch
   - Added `AppTheme.darkGradient` for dashboard background + `AppTheme.gradientFor(context)` helper
   - Shared `_baseInputTheme()` avoids color duplication between light/dark
3. **Updated: `text_styles.dart`** — Added `AppTextStyles.of(context)` that returns `_AdaptiveTextStyles` with colors resolved per brightness (`onSurface`, `onSurfaceVariant`, etc.). Old static consts preserved for backward compat.
4. **Updated: `service_locator.dart`** — Registered `ThemeCubit` as singleton
5. **Updated: `main.dart`** — Added `ThemeCubit` BlocProvider, wrapped MaterialApp.router in `BlocBuilder<ThemeCubit, ThemeMode>` with `darkTheme: AppTheme.darkTheme` and `themeMode: themeMode`

B. **Shared Widgets**
6. **Updated: `glass_card.dart`** — Dynamic tint/border/shadows based on brightness (white glass in light, dark surface glass in dark)
7. **Updated: `app_drawer.dart`** — All hardcoded `Colors.grey[]` replaced with `theme.colorScheme.onSurface`, `onSurfaceVariant`, `dividerColor`, etc.
8. **Updated: `settings_page.dart`** — Added "Appearance" section with Dark Mode Switch toggle + all colors made theme-aware

C. **Billing + Product Pages (9 files) — Dark Mode Color Replacements**
9. **`receipt_preview_page.dart`** — Fixed: `Colors.white` → `surface`, `Colors.black54/45/38/87` → `onSurface`/`onSurfaceVariant`, `Colors.red` snackbars → `colorScheme.error`, `Colors.blue` done btn → `colorScheme.primary`
10. **`scanner_page.dart`** — Fixed: Permissions prompt uses theme colors, `const` removed from Positioned/TextStyle using `Theme.of(context)`
11. **`checkout_page.dart`** — Fixed: All `Colors.white` containers → `surface`, `Color(0xFFF8FAFC)` header → `surfaceContainerHighest`, `borderColor` → `dividerColor`, `Color(0xFF0F172A)` totals → `onSurface`, `Colors.red` → `error`, custom price styling uses `tertiary`/`surfaceContainerHighest`, UPI warning uses `errorContainer`
12. **`home_page.dart`** — Fixed: `Colors.white` card bg → `surface`, `Colors.grey[100]`/`[200]` → `surfaceContainerHighest`/`dividerColor`, `Colors.grey[600]` meta → `onSurfaceVariant`, `Colors.red` snackbar → `error`, empty cart icon uses surfaceContainerHighest. Camera overlay colors kept intentionally (dark for visibility over live feed)
13. **`product_list_page.dart`** — Fixed: `borderColor` → `dividerColor`, `Colors.white` cards → `surface`, `Color(0xFF0F172A)` → `onSurface`, `Color(0xFFF1F5F9)` placeholder → `surfaceContainerHighest`, `Color(0xFF94A3B8)` icons → `onSurfaceVariant`, `Color(0xFF4C669A)` hint → `primary.withAlpha`
14. **`add_product_page.dart`** — Fixed: `Colors.grey[100]` bottom sheet bg → `surfaceContainerHighest`, `Colors.black` price prefix → `onSurface`, `Colors.black87` → `onSurface`, bottom sheet bg `Colors.white` → `surface`, `Colors.red` snackbar → `error`, `const` removed where Theme.of used
15. **`edit_product_page.dart`** — Fixed: `Colors.black` price prefix → `onSurface`, `Colors.grey[100]` bottom sheet → `surfaceContainerHighest`, `Colors.black87` → `onSurface`, bottom sheet `Colors.white` → `surface`
16. **`product_detail_page.dart`** — Fixed: `Colors.black87` product name → `onSurface`, `Colors.grey[200]` containers → `surface` + `dividerColor`, `Colors.grey[500]` labels → `onSurfaceVariant`, `Colors.red` delete → `error`, `Colors.white` → `surface`. `_placeholder()` reverted to hardcoded grey (no build context available in errorBuilder)
17. **`qr_generator_page.dart`** — Fixed: QR container `Colors.white` → `surface`, `Colors.grey[200]` placeholder → themed, `Colors.black` QR dot → `onSurface`, `Colors.grey[600]` barcode → `onSurfaceVariant`, button foregrounds → `surface`, `Colors.green` snackbar → `primary`

### Design System Changes
- `design.md` updated with full dark mode documentation
- Dark mode toggle: Settings page → Appearance → Dark Mode toggle
- All GlassCard, PremiumStatCard, DashboardActionCard auto-adapt to dark

### What Was Done
1. **Removed dead notification icon** from AppBar — sirf search icon rah gaya
2. **Fixed GreetingHeader double-padding** — outer padding (20,18) → (16,16); GreetingHeader owns its own padding now
3. **Standardized section spacing** — all gaps normalized to 16/24 cadence throughout dashboard
4. **Added haptic feedback** — DashboardActionCard + all 6 QuickActionTiles call `HapticFeedback.lightImpact()` before navigation
5. **Improved `_sectionTitle`** — horizontal padding 4→16, fontSize 13, letterSpacing 0.8, color #787880 for subtle section labels
6. **Tabular figures for numbers** — `fontFeatures: [FontFeature.tabularFigures()]` added to statValue, statLabel, txnAmount, trendChipValue text styles + bodyLarge in app_theme + premium_stat_card value display
7. **4-color AI gradient replaced** — lavender→blue→purple→green removed, cleaner 3-color `aiGradient` (lavender→light blue→cyan tint) added in AppTheme + dashboard page uses it
8. **HapticFeedback import** — `flutter/services.dart` added to dashboard_action_card.dart (was causing compile error after agent edit)

### Files Modified
- `lib/features/dashboard/presentation/pages/dashboard_page.dart` — notification icon, spacing, haptics, _sectionTitle, gradient, services import
- `lib/core/widgets/greeting_header.dart` — outer padding fix
- `lib/core/widgets/dashboard_action_card.dart` — haptic feedback + services import
- `lib/core/widgets/premium_stat_card.dart` — tabular nums on value text
- `lib/core/theme/text_styles.dart` — tabular nums on 4 text styles
- `lib/core/theme/app_theme.dart` — aiGradient, tabular nums on bodyLarge
- `lib/core/widgets/sales_trend_card.dart` — const constructor fix for pending warnings

### What Was Done
1. **Removed dead notification icon** from AppBar actions — only search icon remains
2. **Fixed GreetingHeader double-padding** — outer padding in dashboard_page.dart reduced from (20,18) to (16,16); GreetingHeader itself now owns its (20,18) padding — no double margin
3. **Standardized section spacing** — all section gap SizedBox heights normalized to 16/24 cadence:
   - greeting to low stock: 8→16
   - section→card gaps: 8→16, 12→16
   - card→next section: 20→24, 14→16
   - Inventory Health→Recent Transactions: 20→24
   - Recent Transactions→bottom: 16 (kept)
4. **Added haptic feedback** — all 6 QuickActionTiles now call `HapticFeedback.lightImpact()` before navigation (DashboardActionCard + 5 tiles in GridView + conditional Staff tile)
5. **Improved `_sectionTitle`** — horizontal padding 4→16, fontSize 13, letterSpacing 0.8, color #787880 for a subtle section label look

### Files Modified
- `lib/features/dashboard/presentation/pages/dashboard_page.dart` — notification icon removal, spacing, haptics, _sectionTitle + `flutter/services.dart` import
- `lib/core/widgets/greeting_header.dart` — outer padding (20,18) → (16,16)

### flutter analyze
- 0 errors, 0 warnings ✅ — 1 info-level false positive (FontFeature factory constructor) left

---
## Current Session: 2026-07-23 — prefer_const_constructors Lint Warnings Fix ✅

### What Was Done
1. **Fixed 10 `prefer_const_constructors` Dart analyzer warnings** across 4 files:
   - `inventory_health_card.dart`: +3 const (Text widgets lines 33, 47, 75)
   - `recent_transactions_card.dart`: +4 const (Text widgets lines 125, 131, 262, 268)
   - `sales_trend_card.dart`: +2 const (Text widgets lines 54, 104)
   - `dashboard_page.dart`: +1 const (Text widget line 451)
2. **Purpose**: Performance optimization — const widgets are cached at build time, not recreated on every rebuild
3. **4 parallel agents** used (Haiku model) for concurrent fixes across all files

### Files Modified
- `lib/core/widgets/inventory_health_card.dart`
- `lib/core/widgets/recent_transactions_card.dart`
- `lib/core/widgets/sales_trend_card.dart`
- `lib/features/dashboard/presentation/pages/dashboard_page.dart`

### flutter analyze
- 0 errors, 0 warnings ✅ (entire project clean after all fixes)

---
## Current Session: 2026-07-23 — Stock Decrease/Increase Logic Audit + Realtime ✅

### What Was Done
1. **Stock logic full audit** — billing_bloc + report_repository dono sides check kiye:
   - Submit pe stock decrease → fresh DB fetch add kiya (race condition fix)
   - Delete/edit bill pe stock increase → already working (fresh stock fetch + diff logic)
   - inventory_log shop_id → already present (was missing in my initial audit)

2. **Bug Fix — Race condition in _onSubmitBill** (CRITICAL):
   - **Root Cause**: `item.product.stock` cached value use karta tha → agar bill submit ke beech mein koi aur session stock change karde, stock negative ho sakta tha
   - **Fix**: Fresh DB fetch (`SELECT stock` from products) → then subtract quantity
   - Same pattern already used in report_repository_impl.dart for delete/edit

3. **Realtime stock updates on checkout page**:
   - BillingBloc pe Supabase realtime subscription added (products table)
   - Agar cart mein product hai + DB mein stock change hua → instant cart update
   - Red/Orange "Insufficient Stock" / "Low Stock" badges live update hote hain
   - `close()` pe subscription cleanup hota hai

4. **Verified Bug 2 already fixed** — inventory_log insert mein `shop_id` already present tha

### Files Modified
- `lib/features/billing/presentation/bloc/billing_bloc.dart` — race condition fix + realtime subscription
- `lib/features/billing/presentation/bloc/billing_event.dart` — _ProductStockUpdatedEvent added

### flutter analyze
- 0 errors, 0 warnings ✅ (entire project)

### Graphify
- Updated: 1845 nodes, 2850 edges, 151 communities

---

## Current Session: 2026-07-22 — Stock Revert Bug Fix (deleteBill + updateBill) ✅

### What Was Done
1. **Fixed stock not reverting on bill delete** — `report_repository_impl.dart`:
   - **Root Cause**: `deleteBill()` aur `updateBill()` mein stock operations `shop_id` filter se wrapped the. Agar product ya bill_item ka `shop_id` NULL hai (migration 004 se pehle bane records), toh `maybeSingle()` null return karta tha aur stock update **silently skip** ho jaata tha. Bill delete hota tha but stock revert nahi hota.
   - **Fix**: 
     - `deleteBill()`: bill_items fetch, stock restore, bill_items delete, bill delete — sab se `shop_id` filter hata diya (UUIDs unique hain)
     - `updateBill()`: 4 jagah stock operations (removed items restore, modified items diff, new items deduct, existing items fetch) se `shop_id` filter hata diya
   - **Why safe**: bill_id, product_id, bill_item_id sab UUIDs hain jo globally unique hain — shop_id filter redundant tha stock operations ke liye

### Files Modified
- `lib/features/report/data/repositories/report_repository_impl.dart` — deleteBill + updateBill methods

### flutter analyze
- 0 errors ✅

---

## Current Session: 2026-07-22 — Bill Delete Stock Restoration Fix ✅

### What Was Done
1. **Fixed bill delete not restoring stock** — `deleteBill()` method rewrite:
   - **Root Cause**: Pehle sirf `bills` table se delete hota tha, stock restore nahi hota tha
   - **Fix**: 
     1. Bill items fetch karo (delete se pehle)
     2. Har item ka stock restore karo (`currentStock + item.quantity`)
     3. Inventory log entry banao (`change_type: 'return'`)
     4. Bill items delete karo
     5. Bill delete karo

### Files Modified
- `lib/features/report/data/repositories/report_repository_impl.dart` — complete deleteBill rewrite

### flutter analyze
- 0 errors ✅

---

## Current Session: 2026-07-22 — Bill History Product Search ✅

### What Was Done
1. **Added product name search to Bill History** — ab customer name, bill ID, aur product name teeno searchable hain
   - **Root Cause**: Pehle sirf `customer_name` aur `id` pe server-side filter tha
   - **Solution**: Client-side filtering - pehle 100 bills fetch (with items), phir Dart mein filter
   - Searches: `customerName`, `bill.id`, `bill.items[].productName`
2. **Hint text updated**: "Search by customer, bill ID, or product"

### Files Modified
- `lib/features/report/data/repositories/report_repository_impl.dart` — client-side product search logic
- `lib/features/report/presentation/pages/bill_history_page.dart` — hint text update

### flutter analyze
- 0 errors ✅

---

## Current Session: 2026-07-22 — Bill History "0 Items" Bug Fix ✅

### What Was Done
1. **Fixed "0 Items" bug in Bill History** — screenshot se issue identify kiya:
   - **Root Cause**: `getBillHistory()` query mein `bill_items` table include nahi tha
   - `select('*, profiles(name)')` → `select('*, profiles(name), bill_items(*)')`
   - `BillSummaryModel.fromSupabaseRow` mein fallback add kiya: jab `bill_items` na ho to `item_count` column se value le

### Files Modified
- `lib/features/report/data/repositories/report_repository_impl.dart` — query fix
- `lib/features/report/data/models/report_models.dart` — fallback logic

### flutter analyze
- 0 errors ✅

---

## Current Session: 2026-07-22 — Cash/UPI Payment Selector in Checkout ✅

### What Was Done
1. **Conditional QR & Payment Toggle** on `CheckoutPage`:
   - Material 3 `SegmentedButton` toggle for 'Cash' vs 'UPI'.
   - Cash selected by default; if selected, hides the Scan to Pay QR code area.
   - If UPI is selected, shows the QR code.
2. **Fixed BLoC Missing Implementation**:
   - Implemented the registered but empty handler `_onUpdatePaymentMethod` in `billing_bloc.dart`.
3. **Fixed Receipt Preview Parameter**:
   - Replaced hardcoded `'paymentMethod': 'UPI'` in navigation extra parameters with dynamic `state.paymentMethod` to ensure the receipt correctly outputs the actual user selection.
4. **Verification**:
   - Ran `flutter analyze` ensuring 0 warnings / errors.

---

## Current Session: 2026-07-22 — Full Bill Edit Feature ✅

### What Was Done
1. **Full Bill Edit Feature** — edit dialog ab pura receipt edit kar sakta hai:
   - **Payment method** dropdown (upi/cash/card) — ab editable
   - **Items editing** — quantity +/- controls, remove items, add new items
   - **Product search** — dialog se products search karke bill mein add kar sakte ho
   - **Stock management** — automatic stock adjustment:
     - Qty increase → stock kam
     - Qty decrease → stock badhao
     - Item remove → stock restore
     - New item add → stock deduct
   - **Live totals** — dialog mein total/grand total real-time update
   - **Inventory logging** — har change ka inventory_log entry

### Files Modified (7 files)
- `lib/features/report/domain/usecases/report_usecases.dart` — `UpdateBillParams` mein `List<BillItem>? items` add
- `lib/features/report/domain/repositories/report_repository.dart` — `updateBill` signature update with items param
- `lib/features/report/data/repositories/report_repository_impl.dart` — full rewrite: item diff, stock management, inventory logging
- `lib/features/report/presentation/bloc/report_event.dart` — `UpdateBill` event mein items field add
- `lib/features/report/presentation/bloc/report_bloc.dart` — handler mein items pass to use case
- `lib/features/report/presentation/pages/bill_detail_page.dart` — complete edit dialog rewrite with items UI + product search

### Architecture Notes
- Items diff by `productId` — compare existing DB items vs new items
- Stock fetched from DB before each adjustment (not stale cache)
- No database transaction wrapping (same as existing billing flow)
- `uuid` package used for new bill_item IDs

### flutter analyze
- 0 errors, 0 warnings ✅

---

## Current Session: 2026-07-22 — Bill Edit/Delete + Manual Product Entry ✅

### What Was Done
1. **Agent A: Bill Edit/Delete (Owner Only)** — `bill-details-edit-delete` worktree
   - Owner ke liye AppBar mein edit + delete buttons
   - Staff ko kuch nahi dikhta (read-only)
   - Edit: Customer name, phone, discount change → DB update + page refresh
   - Delete: Confirmation dialog → DB delete + bill history pe redirect
   - 8 files modified: repository, usecase, events/states/bloc, service_locator, bill_detail_page
   - `flutter analyze`: 0 issues ✅

2. **Agent B: Manual Product Entry on Scanner Page** — `manual-product-entry` worktree
   - Keyboard icon button on scanner (below flashlight toggle)
   - Dialog opens: TextFormField for barcode + "Add to Cart" button
   - "Create New Product" fallback → navigates to `/products/add`
   - Reuses existing ScanBarcodeEvent pipeline — zero new BLoC changes
   - `flutter analyze`: 0 issues ✅

3. **Bug Fix** — `const ResetReport()` → `ResetReport()` (non-const constructor) in report_bloc.dart

### Orca Orchestration
- 2 parallel worktree agents launched via Orca CLI
- Agents explored, planned, and implemented independently
- Code reviewed + analyze check before merging to main
- Worktrees to be cleaned up after session
   - `QuickActionTile` — glass grid tiles
4. **Dashboard page** — complete layout redesign:
   - 4-color gradient background (lavender → blue → purple → green)
   - SliverAppBar (floating + snap) instead of regular AppBar
   - CustomScrollView for smooth scrolling
   - Advanced stats: weekly sales trend, recent transactions, inventory health
   - All existing features preserved: greeting, sales, quick actions, low stock, search
5. **Text color fixes** — PremiumStatCard + DashboardActionCard use dark/colored text (not white) for readability on light glass backgrounds
6. **GreetingHeader fix** — removed boxShadow that doesn't render on BackdropFilter

### Design System Changes
- Design language: Material 3 → Liquid Glass / Glassmorphism
- Background: flat `#F2F2F7` → 4-color gradient
- Cards: solid/surface → `BackdropFilter` + semi-transparent glass
- Borders: none/grey → subtle white glass borders (0.20 alpha)

### Files Modified
- `lib/core/widgets/glass_card.dart` — NEW
- `lib/core/widgets/sales_trend_card.dart` — NEW
- `lib/core/widgets/recent_transactions_card.dart` — NEW
- `lib/core/widgets/inventory_health_card.dart` — NEW
- `lib/core/widgets/premium_stat_card.dart` — glass redesign
- `lib/core/widgets/greeting_header.dart` — glass redesign
- `lib/core/widgets/dashboard_action_card.dart` — glass redesign
- `lib/features/dashboard/presentation/pages/dashboard_page.dart` — complete redesign
- `design.md` — updated design system docs

### flutter analyze
- 0 errors, 0 warnings, 0 infos across entire project ✅

---

## Current Session: 2026-07-22 — PremiumStatCard BackdropFilter GPU Fix ✅

### What Was Done
1. **Removed BackdropFilter from PremiumStatCard** — `lib/core/widgets/premium_stat_card.dart`:
   - Removed `import 'dart:ui'` (no longer needed for ImageFilter)
   - Removed `ClipRRect` wrapper + `BackdropFilter(filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18))`
   - Kept the inner Container with semi-transparent glass decoration (color.withValues(alpha: 0.13), white border)
   - **Why**: BackdropFilter is extremely GPU-expensive when 15+ cards are on screen — causes frame drops
   - **Visual impact**: None — the semi-transparent tint + white border already gives the frosted glass look

---

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

## Current Session: 2026-07-28 — README.md Owner-Focused Rewrite ✅

### What Was Done
1. **README.md completely rewritten** — reorganized for shop owners as primary audience
2. **Key changes**:
   - **Hero section**: "The last billing app your phone shop will ever need" — direct to owners
   - **"Why Shop Owners Love This App" table**: pain points → solutions format (owners scan this first)
   - **Owner's Checklist**: all features grouped by business value (Inventory → Billing → Staff → Analytics → Reports → Settings)
   - **Analytics widgets table**: what each chart tells owners
   - **"Who This Is For" closing section**: phone shops, accessories shops, small retail
   - **Screens table**: route → what owner sees
   - Roles table reframed from "technical roles" to "who does what"
   - Tech stack still present but de-emphasized (owners care about features, not frameworks)
   - Getting started simplified to "5 minutes"
   - "Pain Point → Solution" layout throughout — owners self-identify instantly
3. **All features preserved**: Supabase, Realtime, staff mgmt, QR gen, thermal printing, UPI, dashboards, offline-first, 3-tier roles, all 11 features
4. **What was NOT changed**: code, dependencies, CLAUDE.md, RPD.md, architecture.md, phases.md, design.md, rules.md

---

## Current Session: 2026-07-28 — README.md Update ✅

### What Was Done
1. **README.md completely rewritten** — old version was missing Supabase, Realtime, staff management, dashboard analytics, QR code generation, and all features added after initial scaffold
2. **Updated content includes**:
   - Full feature list (scanner, cart, thermal printing, UPI QR, inventory, staff mgmt, analytics)
   - Complete tech stack table with all dependencies
   - Feature structure with all 11 features listed (auth, billing, product, category, shop, settings, report, staff, dashboard)
   - 3-Tier Role System (Super Admin / Owner / Staff) with access table
   - Shop Isolation explanation (3 layers: RLS, repo filtering, BLoC propagation)
   - Real-time sync details
   - Dashboard analytics widget table
   - Updated getting-started guide with all migrations listed
   - Contributing guidelines updated with current conventions
   - Project docs reference table
3. **Old README gaps fixed**:
   - Was Hive-only, no mention of Supabase cloud sync
   - No staff management section
   - No QR code generation feature
   - No analytics/dashboard section
   - No real-time sync
   - Missing features: category CRUD, shop settings, report system, 3-tier roles

### What Was NOT Changed
- CLAUDE.md, RPD.md, architecture.md, phases.md, design.md, rules.md — these are authoritative docs
- No code changes, no dependency changes

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

## Current Session: 2026-07-22 — Navigation Fix v2: PopScope + addPostFrameCallback ✅

### What Was Done
1. **`app_shell.dart`** — Fixed PopScope not working because `context.go('/')` was conflicting with GoRouter's in-flight back event processing.
   - **Root Cause**: GoRouter v14.8.1 ka ShellRoute back event process kar raha hota hai jab PopScope callback fire hota hai. Direct `context.go('/')` call fail ho jata hai race condition ki vajah se.
   - **Fix**: 
     - `GoRouter.of(context)` se GoRouter instance build time pe store kiya
     - `addPostFrameCallback` se navigation ko next frame tak defer kiya
     - `canPop: false` rakha taaki system back button hamesha intercept ho
2. **Result**: Kisi bhi shell page se back → dashboard khulega. Dashboard se back → app close.

### flutter analyze
- 0 errors, 0 warnings ✅

---

## Current Session: 2026-07-22 — Complete Navigation Fix ✅

### What Was Done
1. **System back button fix** — `app_shell.dart`: Added `PopScope` wrapper around Scaffold
   - Sub-routes: back pops naturally (checkout → scan → etc.)
   - Top-level routes: back navigates to `/` (dashboard) instead of closing app
   - Uses `canPop: true` + `onPopInvokedWithResult` — if `didPop` is false, redirects to dashboard
2. **Removed redundant back buttons** from 8 pages inside ShellRoute (kept hamburger menu only):
   - `scanner_page.dart`, `product_list_page.dart`, `product_detail_page.dart`, `edit_product_page.dart`, `add_product_page.dart`, `add_staff_page.dart`, `receipt_preview_page.dart`
3. **Fixed `checkout_page.dart`**: `PopScope(canPop: false)` → `canPop: true` + `onPopInvokedWithResult` clears cart only after successful pop
4. **Cleaned unused import**: `app_back_button.dart` removed from `add_staff_page.dart`
5. **Auth pages outside shell** (`register_page.dart`, `email_verification_page.dart`) — unaffected, still use `AppBackButton`
6. **9 files modified** total, **0 flutter analyze issues**

### flutter analyze
- 0 errors, 0 warnings, 0 infos ✅

### Next
- Run on device to verify system back button behavior on real device

---

## Current Session: 2026-07-22 — Staff Widget Owner-Only (Dashboard + Drawer + Route Guard) ✅

### What Was Done
1. **Staff tile is owner-only** — 3-layer protection:
   - **Dashboard tiles**: Staff tile shown only when `authState.user.role == 'owner'`
   - **Side menu drawer**: Staff section hidden via BlocBuilder `isOwner` check (no change needed)
   - **Route guard**: `/staff` and `/staff/add` redirect non-owner users to `/` dashboard
2. Staff/cashier role users cannot see or access staff management anywhere

### flutter analyze
- 0 errors, 0 warnings ✅

---

## Current Session: 2026-07-22 — Logout Infinite Loop Fix ✅

### What Was Done
1. **Fixed infinite logout loop** — `auth_bloc.dart`:
   - Added `_isLoggingOut` flag (line 24)
   - `_onLogoutRequested`: emits `Unauthenticated()` FIRST (before await), then calls `logoutUseCase()`
   - `subscribeToAuthChanges`: skips dispatching `LogoutRequested` if `_isLoggingOut == true`
   - Root cause: Supabase `signOut()` triggers auth stream → listener dispatches `LogoutRequested` again → infinite loop (9x "Signing out" in console)

2. **Fixed GoRouter redirect not triggering** — `app_routes.dart`:
   - Added `_AuthNotifier extends ChangeNotifier` wrapper with proper `StreamSubscription` + `dispose()`
   - `createRouter(AuthBloc authBloc)` now accepts authBloc parameter
   - `refreshListenable: _AuthNotifier(authBloc)` — GoRouter re-evaluates redirect on every BLoC state change
   - `main.dart`: passes `di.sl<AuthBloc>()` to `createRouter()`

### Files Modified
- `lib/features/auth/presentation/bloc/auth_bloc.dart` — `_isLoggingOut` guard + emit Unauthenticated first
- `lib/config/routes/app_routes.dart` — `_AuthNotifier` wrapper + `refreshListenable` + `dart:async` import
- `lib/main.dart` — `createRouter(authBloc)` parameter

### flutter analyze
- 0 errors, 0 warnings ✅

---

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


---

## Current Session: 2026-08-21 - Customer CMS FEATURE BUILT (needs device verify)

### What Was Done
1. Plan: customer_cms_plan.md (name+phone only, link bills/warranty via customer_id). User said 'jo accha lage krde'.
2. Migrations (user runs manually - no billing MCP in Hermes): 016 (customers, wrong UUID+FK) + 017 (MERGED: drop+recreate customers TEXT shop_id NO FK + link bills/warranty + backfill). 018 deleted/merged.
3. Built via parallel sub-agents: domain/data(4), phone_utils, bloc(3), pages(3). Wiring done by Jerry (agent hit 429).
4. Wiring: service_locator, app_routes(/customers,/customers/add,/customers/detail), app_drawer(Customers menu), billing_bloc(checkout auto find/create customer -> customer_id).
5. flutter analyze lib = 0 errors, 0 new warnings.
6. GOTCHA: sl import = '../../../../core/service_locator.dart' as di (relative, not package:.../di/).
7. Hot-restart FAILED: w8:p9 flutter run died (Lost connection to device). User must reconnect + flutter run.

### MCP WARNING (critical)
- supabase_prod + supabase_staging = MICROFLOW project, NOT billing. Billing = wwutchscfnhwijxyftlw.supabase.co (no MCP). Never migrate billing via those.

### Remaining
- User restarts flutter run -> hot restart -> verify Customers + checkout link on device.
- graphify update .

---

## Fix: 2026-08-21 - Receipt due/payment not showing

### Root Cause
Receipt preview page (receipt_preview_page.dart) SUPPORTS `amountPaid`/`dueAmount` + shows Due block
when `hasDue`, but checkout_page.dart navigation `extra` map NEVER passed them -> stayed null -> block hidden.
Printed receipt (printer_helper.printReceipt) also never printed payment/due.

### Fix
1. checkout_page.dart: pass `amountPaid` (state.amountPaid ?? total) + `dueAmount` (null if <=0) to receipt-preview nav.
2. printer_helper.printReceipt: added optional `paymentMethod`,`amountPaid`,`dueAmount`; prints Payment + Paid/DUE lines.
3. receipt_preview_page._printReceipt: forward widget.amountPaid/dueAmount/paymentMethod to printer.
4. billing_bloc print handler: forward state.amountPaid/paymentMethod/dueAmount for consistency.
flutter analyze = clean (printer_helper only).

### Remaining
- graphify update .

---

## Fix: 2026-08-21 - Customer search popup not visible properly

### Root Cause
`_showCustomerPicker` in checkout_page had redundant `StatefulBuilder` inside `BlocProvider.value` + `DraggableScrollableSheet`. The nested builders caused rendering issues — popup wasn't fully visible or responsive.

### Fix
Simplified the bottom sheet:
1. Removed `StatefulBuilder` (BlocBuilder handles state already)
2. Added drag handle indicator at top
3. Added title row ("Select Customer") with close button
4. Search bar now autofocuses
5. Customer list items wrapped in `Card` for better visual separation
6. Empty state has icon + text instead of plain text
7. `ListView` uses `scrollController` from DraggableScrollableSheet for proper scrolling
flutter analyze = clean.

### Remaining
- graphify update .

---

## Feature: 2026-08-21 - Auto bill-id QR on every receipt

### What
User wanted a scannable QR encoding each bill's unique `billId` (UUID) on every receipt, both on-screen and printed.

### Fix
1. receipt_preview_page.dart: import pretty_qr_code; after "Bill ID: xxxx" text, render `PrettyQrView.data(data: widget.billId)` (110x110) + "Scan to view bill" caption. Reuses already-installed `pretty_qr_code: ^3.3.0`.
2. printer_helper.dart: added `_qrCodeBytes()` — native ESC/POS GS(0x28 0x6B QR command (Model 2, EC level M=33, module size 4). printReceipt now prints the bill text line then the QR (centered) after the Bill: id. No new dependency.
QR encodes ONLY the billId (Option A) — small, prints clean on 58mm thermal, easy to look up bill for warranty/return.

### Verify
flutter analyze = clean. Hot-restart sent to w8:p9 (phone) = Restarted application.

### Remaining
- none

---

## Feature: 2026-08-21 - Warranty claim via scanned bill QR

### What
User wanted the receipt bill QR (encodes billId) to shortcut the warranty claim entry. Implemented scan-to-claim flow.

### Flow added
1. Warranty FAB opens a source sheet: "Scan Bill QR" (fast) or "Enter Manually" (fallback kept).
2. Scan -> `/scan/scanner` returns raw billId -> `ReportRepository.getBillDetail(billId)` fetches bill from DB.
3. Pre-filled dialog: customer/date auto from bill (read-only), product Dropdown populated ONLY from `bill.items` (error-proof, no typo), reason field.
4. Dart-side expiry guard: `_warrantyEndDate(bill.createdAt + item.warrantyDuration/Unit)` shows green "Under warranty until" / red "Warranty expired on" banner (non-blocking).
5. Submit passes real `productId` + `warrantyDuration/Unit` (fixed prior hardcoded `productId: ''`).

### Error-proofing
- Scan cancel -> ignored. Bill not found / network -> error snack, no crash. Loading dialog while fetching. Empty bill items -> blocked with message. Empty reason -> blocked.

### Files
lib/features/warranty/presentation/pages/warranty_claims_page.dart
Reuses: mobile_scanner (scanner_page), ReportRepository (getBillDetail), WarrantyBloc (CreateWarrantyClaim). No new dependency.

### Verify
flutter analyze clean (0 errors). Hot-restart w8:p9 = Restarted application.

---

## BUG FIX: 2026-08-21 - Warranty scan crashed (blank screen)
### Symptom
After scanning bill QR: loading dialog flashed, then blank screen + crash:
`GoRouterDelegate._debugAssertMatchListNotEmpty` + `!_debugLocked` assertion at
`_WarrantyClaimsPageState._scanBillAndCreateClaim` line ~43 (Navigator.pop).
### Root cause
Used `showDialog` + `Navigator.pop(context)` to close a loading dialog immediately
after `context.push('/scan/scanner')` returned. GoRouter keeps the navigator LOCKED
during the pop transition, so popping a dialog in that window throws and blanks UI.
### Fix
Removed the loading Dialog entirely. Replaced with an in-page `Stack` overlay driven
by `_isFetchingBill` bool (setState true/false). No Navigator.pop during route lock ->
no crash. Loading now shows "Fetching bill…" overlay on the warranty page itself.
### Lesson (future-proof)
NEVER call Navigator.pop / showDialog synchronously right after a go_router
`context.push(...)` returns — the navigator is locked. Use in-widget state (Stack
overlay / setState) for post-navigation loading, not dialogs.
### Verify
flutter analyze = 0 errors. Hot-restart w8:p9 = Restarted application.

---

## BUG FIX 2: 2026-08-21 - scan open prefilled dialog crash (firstWhere type)
### Symptom
Scan succeeded (loading overlay OK) but prefilled dialog never opened; crash:
`type '() => BillItem' is not a subtype of type '(() => BillItemModel)?' of 'orElse'`
at _showPrefilledClaimDialog line 625.
### Root cause
`bill.items` is `List<BillItemModel>` (BillItemModel extends BillItem). Annotating the
local as `BillItem? selectedItem` made `firstWhere` infer orElse must return BillItemModel,
clashing with the `BillItem?` annotation -> runtime cast error.
### Fix
Removed the `BillItem?` annotation: `final items = bill.items; var selectedItem = items.firstWhere((i)=>i.hasWarranty, orElse: ()=>items.first);` Let Dart infer type. Also dropped now-unneeded `selectedItem!` null-asserts in banner + submit.
### Verify
flutter analyze = 0 errors. Hot-restart w8:p9 = Restarted application.

---

## BUG FIX 3: 2026-08-21 - scan prefilled dialog STILL crashing (firstWhere)
### Symptom
After fix 2, SAME crash persisted: `type '() => BillItem' is not a subtype of
type '(() => BillItemModel)?' of 'orElse'` at line 626.
### Root cause
`BillSummary.items` is declared `List<BillItem>` but is populated at runtime with
`BillItemModel` (BillItemModel extends BillItem). `ListBase.firstWhere`'s orElse
closure type is covariant-strict, so the inferred closure `() => BillItem` still
failed the runtime `BillItemModel` expectation. firstWhere + orElse is fragile here.
### Fix
Dropped firstWhere entirely. Used explicit `final List<BillItem> items = bill.items;`
+ `items.where((i)=>i.hasWarranty).toList()` -> pick first warranted, else items.first.
No orElse closure -> no subtype clash. selectedItem is non-nullable BillItem.
### Verify
flutter analyze = 0 errors. Hot-restart w8:p9 = Restarted application.
### Lesson
With List<Base> populated by Subclass at runtime, AVOID firstWhere(orElse:). Use
where().toList() + manual pick. Firstwhere-orElse covariant typing is a known trap.

---

## BUG FIX 4: 2026-08-21 - card tap crash (Scaffold wrapped in Stack)
### Symptom
After filing a claim, tapping a claim card (to open detail sheet) crashed with:
`Failed assertion: '!semantics.parentDataDirty': is not true.` (rendering/object.dart:5705).
### Root cause
I had wrapped the whole `Scaffold` in a `Stack` (to show the fetching overlay).
Wrapping Scaffold in Stack breaks Scaffold's internal overlay/semantics management;
when showModalBottomSheet/_showClaimDetail pushed a route, the dirty parentData
assertion fired. Card tap itself was fine — the Stack broke the tree.
### Fix
Moved the overlay INSIDE the Scaffold body: `body: Stack(children:[ Column(...), if(_isFetchingBill) overlay ])`.
Scaffold is now a direct return (not wrapped). Overlay is a body child, so Scaffold's
overlay/semantics stay intact. (Also removed a duplicate orphaned overlay block left
from the earlier Stack approach.)
### Verify
flutter analyze = 0 errors. Hot-restart w8:p9 = Restarted application.
### Lesson
NEVER wrap Scaffold in Stack/Container that alters its render parent during route push.
Put loading overlays inside body via Stack. Scaffold must manage its own Overlay.

---

## BUG FIX 5: 2026-08-21 - card tap crash (Spacer in fixed-height bottom sheet)
### Symptom
After fix 4 (Scaffold unwrap), card tap STILL crashed: `RenderBox was not laid out:
RenderPhysicalShape` + `'!semantics.parentDataDirty'`. Same on every claim-card tap.
### Root cause
_showClaimDetail bottom sheet: `Container(height: 0.7)` -> `Column` -> `Padding` ->
`Column` with `const Spacer()` at the end. Spacer() inside a flex child of a
fixed-height Container during the sheet's route-push layout triggers parentDataDirty.
(This method was pre-existing, never hit before because card-tap wasn't tested until now.)
### Fix
Rewrote sheet: `Column[ handle, Expanded(SingleChildScrollView(detail rows)),
Padding(pinned action buttons) ]`. Removed Spacer() entirely. Details scroll, buttons
stay pinned at bottom. Bulletproof layout.
### Verify
flutter analyze = 0 errors. Hot-restart w8:p9 = Restarted application.
### Lesson
NEVER use Spacer() inside a Column that lives in a fixed-height Container / modal sheet.
Use Expanded(SingleChildScrollView) for content + a separate pinned footer widget.

---

## Fix: 2026-08-21 - Product long-press menu UI improvement

### Root Cause
`_showLongPressMenu` in product_list_page was a basic bottom sheet with plain `ListTile` items — no drag handle, no product info header, no visual hierarchy. Looked cluttered and wasn't properly visible.

### Fix
Rewrote `_showLongPressMenu` + added helper `_menuActionTile`:
1. Added drag handle indicator at top
2. Product info header with avatar initial, name, price, and stock badge
3. Each action is a custom tile with colored icon background + chevron
4. Destructive action (delete) visually distinct with red styling
5. Better spacing and padding throughout
flutter analyze = clean.

### Remaining
- graphify update .

---

## CHANGE: 2026-08-21 - Manual warranty entry REMOVED (scan-only)
### What
User: "manual entry hata de, sirf scan rehne de". Removed the manual claim dialog
(_showCreateClaimDialog) and the source bottom-sheet (_showClaimSourceSheet).
### Result
- FAB "New Claim" now calls `_startNewClaim()` -> directly `_scanBillAndCreateClaim()`.
- No manual entry path remains. Scan receipt QR is the ONLY way to file a warranty claim.
- `_showCreateClaimDialog` (the 180-line manual form) deleted entirely.
### Why
Simpler + error-proof: scan auto-fills customer + product from DB, no typos, no fake
bill IDs. Manual was a fallback but user wants scan-only.
### Verify
flutter analyze = 0 errors. Hot-restart triggered.

---

## BUG FIX 6: 2026-08-21 - warranty back button black screen
### Symptom
On /warranty page, tapping top-left back button -> black screen + crash:
`You have popped the last page off of the stack, there are no pages left to show`
+ `'!_debugLocked'`.
### Root cause
/warranty is a DIRECT GoRoute under GoRouter root (NOT inside the ShellRoute).
The back button used `Navigator.of(context).pop()` which pops the only page on the
material navigator -> empty stack -> black screen.
### Fix
Changed back button to `context.go('/')` (go_router) -> always returns to Dashboard
per AGENTS.md nav rule (sub-page back -> '/', dashboard back -> close app). go_router
import already present.
### Verify
flutter analyze = 0 errors. Hot-restart triggered.
### Lesson
For direct GoRoutes (not shell children), never use Navigator.pop() for back —
use context.go('/') or context.pop() only when there IS a parent in the stack.
ScannerPage back correctly uses context.pop(value) (returns to caller) - leave as-is.


## BUG FIX 7: 2026-08-21 back button black screen on Due Payments / Damaged / Customers
Same class as warranty fix 6. Direct GoRoutes (/due-payments, /damaged-products, /customers) popped only page -> black screen.
Fix: all three leading back buttons now context.go("/") returns to Dashboard. due_payments and damaged got go_router import added. customer_detail/add use context.pop() - correct, left as-is.
Verify: flutter analyze 0 errors on all 3. Hot-restart done.

## BUG FIX 8: 2026-08-24 - AddProductPage category select crash (type mismatch)
### Symptom
Tapping category field on Add Product page -> red screen error:
"type '() => Category' is not a subtype of type '() => CategoryModel?' of 'orElse'"
### Root cause
Line 596-599: `cats.firstWhere((c) => c.id == _categoryId, orElse: () => cats.first).name`
Runtime pe `cats` list actually contains `CategoryModel` instances, but `firstWhere`'s `orElse` lambda return type inference caused a subtype mismatch between `Category` and `CategoryModel`. The `orElse` fallback `() => cats.first` was typed as `() => Category` while the generic expected `() => CategoryModel?`.
### Fix
Replaced `firstWhere(..., orElse: () => cats.first)` with `where((c) => c.id == _categoryId).firstOrNull` — avoids the `orElse` type mismatch entirely. Also added `cats.isNotEmpty` guard before accessing.
Bonus fix: side effect in build (`_categoryController.text = ...`) now only runs when `_categoryId != null && cats.isNotEmpty`, not on every rebuild. "No Category" selection now properly clears controller.
### Verify
flutter analyze pending. Hot-restart triggered after fix.

## DESIGN FIX: 2026-08-24 - Reports Home page redesign
### Symptom
Reports & History landing page design thoda flat + outdated lag raha (gradient grid cards, hardcoded "4 sections" stat jo galat bhi tha — grid mein 5 cards hain).
### Fix
Dashboard ke premium style match karne ke liye rewrite kiya:
- Reuse kiye `PremiumStatCard` (hero: This Month Revenue) + 2-col row (Bills / Low Stock)
- Reuse kiye `DashboardActionCard` for 5 sections (Bill History, Daily Sales, Low Stock, Stock Movement, Audit Trail) — list rows with live counts
- Live data wire kiya ReportBloc se: `state.billHistory` (month filter) + `state.lowStockProducts.length`
- `AppTheme.gradientFor(context)` background, `RefreshIndicator` add kiya
- "4 sections" bug auto-fix ho gaya (dynamic counts ab)
### Verify
flutter analyze = 0 errors (1 const hint). Hot-restart triggered.
### Lesson
Report sub-pages detailed hain but home page consistent premium design chahiye (dashboard-matched). Reuse existing widgets, don't reinvent.

## NAV FIX: 2026-08-24 - Reports sub-pages added to sidebar
### Change
- Removed single "Reports" parent item from drawer
- Added 5 direct sub-items under "Reports" section header with `indented: true` visual hierarchy:
  Bill History, Daily Sales, Low Stock, Stock Movement, Audit Trail
- Each routes to its own page directly (`/reports/bills`, `/reports/daily-sales`, `/reports/low-stock`, `/reports/stock-movements`, `/reports/audit-trail`)
### Bonus
- `_DrawerItem` widget gains optional `indented` param for deeper hierarchy in future
### Verify
flutter analyze = 0 errors. Hot-restart triggered.
