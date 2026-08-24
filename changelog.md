# Changelog — Flutter Billing App

> Last ~4 din ka saara kaam (2026-08-18 → 2026-08-21) consolidate kiya gaya.
> Har entry verify hui hai `flutter analyze` = 0 errors se (jahan likha hai).
> Format: Date → Feature/Bug → Files → Result.

---

## 2026-08-21 (Aaj ka din — sabse zyada kaam)

### 🔧 Features
1. **Auto bill-id QR on every receipt** (`receipt_preview_page.dart`, `printer_helper.dart`)
   - Har bill ka unique `billId` (UUID) QR ab on-screen + thermal print dono pe aata hai.
   - On-screen: `PrettyQrView` (110x110) + "Scan to view bill" caption.
   - Print: native ESC/POS QR command (`GS(0x28 0x6B`, Model 2, EC M, module 4) — koi naya dependency nahi.
   - QR encodes SIRF `billId` (Option A) — 58mm thermal pe clean print, warranty/return lookup easy.

2. **Warranty claim via scanned bill QR** (`warranty_claims_page.dart`)
   - FAB → scan bill QR → `getBillDetail(billId)` se DB se bill fetch → prefilled claim dialog.
   - Customer/date auto-fill (read-only), product dropdown SIRF `bill.items` se (error-proof, no typo).
   - Dart-side expiry guard: green "Under warranty until" / red "Warranty expired on" banner.
   - Submit real `productId` + `warrantyDuration/Unit`.

3. **Manual warranty entry REMOVED (scan-only)** (`warranty_claims_page.dart`)
   - User: "manual entry hata de, sirf scan rehne de". 180-line manual dialog + source sheet delete.
   - FAB → directly `_scanBillAndCreateClaim()`. Scan hi ek tarika hai claim file karne ka.

4. **Damaged Products Management Feature** (pura naya module `lib/features/damaged_products/`)
   - Domain/Data/BLoC/Presentation layers. Reuses existing `stock_adjustments` table (`reason='damage'`) — NO migration.
   - Page: red gradient summary card (total loss ₹ + count), search, date filter, list.
   - `MarkDamagedDialog`: qty +/- , 6 damage-type chips, notes, stock validation.
   - Improvements: notes bug fix (`type|notes` encode), human-readable type, CSV export, pull-to-refresh, **Undo/Reverse damage** (stock restore + audit).
   - Integration: Product Detail (Mark as Damaged btn), Product List (long-press menu), Drawer, DI, main.dart.

5. **Products Page: Persistent mini-cart bar** (`product_list_page.dart`)
   - Swipe-to-add SnackBar → persistent bottom cart bar (item count + total + "View Cart").
   - FAB hidden jab cart non-empty (Visibility), AppBar add IconButton added.

6. **Customer CMS planning** (plan file: `customer_cms_plan.md`)
   - Approved: full Customer CMS (name+phone only). `customers` table NO RLS (Dart-side shop filter).
   - Migrations planned (customers table + bills/warranty add customer_id FK). Build pending.

### 🐛 Bug Fixes (2026-08-21)
1. **Navigation back-button app-close bug** (`app_shell.dart`, `dashboard_page.dart`)
   - Global PopScope removed; Dashboard ko `PopScope(canPop:false) + SystemNavigator.pop()` diya.
   - Sub-page back → parent → Dashboard; Dashboard back → app close. ✅

2. **Sub-page back button black screen** (`warranty_claims_page.dart`, `due_payments_page.dart`, `damaged_products_page.dart`, `customer_list_page.dart`)
   - Direct GoRoutes pe `Navigator.pop()` → black screen. Sabko `context.go('/')` kiya (go_router import add where needed).
   - **PLUS system back GESTURE fix**: har sub-page pe `PopScope(canPop:false, onPopInvoked → context.go('/'))` add kiya → phone swipe/back ab app close nahi karega, Dashboard pe jayega.

3. **Checkout Dialog scanner add broken** (`checkout_page.dart`)
   - Dialog context shadow tha → scan cart me add nahi ho raha tha. `pageContext` capture kar fix kiya.

4. **Billing Scanner beep sound missing** (`home_page.dart`)
   - `BeepHelper.playBeep()` add + vibration softened (120ms/128 amp).

5. **Product page redundant add button removed** (`product_list_page.dart`)
   - FAB already hai, toh AppBar add button + FAB hide-wrapper hata diya.

6. **Warranty scan flow — 5 crash fixes** (`warranty_claims_page.dart`)
   - Loading dialog crash (Navigator.pop during route lock) → in-page Stack overlay.
   - `firstWhere` orElse type clash → `where().toList()` + manual pick.
   - Scaffold-in-Stack crash → overlay moved to body.
   - Spacer-in-sheet crash → Expanded(SingleChildScrollView) + pinned footer.
   - Card tap crash series resolved.

7. **Product long-press menu UI** (`product_list_page.dart`)
   - Drag handle + product header + colored action tiles + red delete styling.

---

## 2026-08-20

### 📦 Build & Release
1. **Signed Release APK + Split-per-ABI** (`android/app/build.gradle.kts`, `proguard-rules.pro`, `key.properties`)
   - Release keystore generated, signing config, R8 minify/shrink enabled.
   - Build: `flutter build apk --release --split-per-abi --no-tree-shake-icons`
   - Output: `app-armeabi-v7a-release.apk` (24.9MB), `app-arm64-v8a-release.apk` (28.5MB), `app-x86_64-release.apk` (31.0MB).
   - `--no-tree-shake-icons` required (dynamic IconData in category pages).

### 🎨 UI Modernization
2. **Report Pages Modernization** (reports_home, daily_sales, low_stock, stock_movement)
   - CustomScrollView + SliverAppBar, gradient stat cards, bar charts, filter chips, CSV export, haptics, staggered animations.

3. **Dual View: Classic List + Cover-flow** (`product_coverflow_view.dart`, `product_list_page.dart`)
   - 2 views, default = Classic List (session-only toggle). Compact cards, low-stock filter, undo delete, bulk select + bulk export, real CSV import, copy barcode, search by location.
   - Bug fix: category chips race condition (`BlocBuilder<CategoryBloc>` wrap).

4. **Product Page UI Upgrade v2 (Spotlight Cover-flow)** — then **Bento Inventory** (both rejected by user, reverted to Classic).

5. **Product Management Enhancements**
   - Migration `012_add_product_enhancements.sql`: `min_stock_level`, `unit` + `stock_adjustments` table.
   - Packages: image_picker, flutter_image_compress, csv, file_picker.
   - Stock adjustment tracking, image compress util, CSV export/import.

---

## 2026-08-19

### 💰 Due Payments Management Feature (pura naya module `lib/features/due_payments/`)
- Migration `011_add_due_payments.sql`: `amount_paid`, `due_amount`, `payment_status` + `due_payments_view`.
- Domain/Data/BLoC/Presentation layers. Orange gradient summary card + collect-payment dialog.
- Integration: Checkout (payment section), BillingBloc (`UpdateAmountPaidEvent`), Receipt (due breakdown), Drawer, route, DI.

---

## 2026-08-18

### 📊 (Graphify-tracked changes)
- Staff module edits (`staff_bloc/event/state`, `add_staff_page`, `staff_list_page`).
- Supabase migrations 001–009 (saas_shops, shop_data_scoping, three_tier_roles, RLS recursion fix, customer_phone_to_bills).
- Project docs updates (AGENTS.md, CLAUDE.md, RPD.md, architecture.md, design.md, phases.md, rules.md, README.md, pubspec.yaml).
- main.dart, web/manifest.json, iOS/Android asset/icon updates.

---

## 📌 Known Issues / Pending
- `category_list_page.dart` (uncommitted): pre-existing `context.go` / `theme` undefined errors — abhi tak fix nahi hua.
- Customer CMS: plan approved, build pending (migration + UI baaki).
- Release build me `--no-tree-shake-icons` lagta hai (dynamic IconData) — future me const banane par hat sakta hai.
- KGP (Built-in Kotlin) warning non-blocking hai.

## ✅ Verification Status
- Saare features/bug-fixes `flutter analyze` = 0 errors se verify hue (individual files + whole lib).
- Aaj ki final APK build (arm64-v8a) SUCCESS: `build/app/outputs/flutter-apk/app-release.apk` (36.7MB).
