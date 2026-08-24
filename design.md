# Design

> **⚠ v2 UPDATE (2026-08-24 — Premium UI/UX Redesign):** Neeche ke original sections
> valid hain, lekin ab inke upar ek formal design system layer hai. Naye kaam ke liye
> PEHLE ye use karo, purane hardcoded values ko migrate karte jao.

## Design System v2 — Tokens & Components (Source of Truth)

### Tokens (`lib/core/theme/app_dimensions.dart`)
- **Spacing (4-pt grid):** xs=4 · sm=8 · md=12 · lg=16 · xl=24 · xxl=32 · xxxl=48
  - Micro-gaps (2/6px icon-label pairing) intentional hain — tokens pe force mat karo
- **Radius:** sm=8 · md=12 · lg=16 · xl=20 · full=pill
- **Elevation:** low=1 · mid=3 · high=8 (+ `shadowLow/Mid` tinted-shadow helpers)
- **Durations:** fast=150ms · normal=250ms · slow=400ms; Curves: `AppDurations.ease` (easeOutCubic), `.spring` (easeOutBack)
- **Touch targets:** min=48dp, button/input height=52dp

### Typography Scale (`lib/core/theme/app_typography.dart`)
| Style | Size/Weight | Use |
|---|---|---|
| displayLarge | 32 w800 | Rare hero numbers |
| displaySmall | 28 w800 | Greeting name |
| headlineLarge | 24 w700 | Page heroes |
| headlineSmall | 20 w700 | Section heroes |
| titleLarge | 18 w700 | AppBar titles |
| titleMedium/Small | 16/14 w600 | Card titles |
| bodyLarge/Medium | 16/14 w400 | Content (MIN body = 14) |
| labelLarge/Medium/Small | 14/12/11 w600+ | Chips, captions, nav |

- Font: IBM Plex Sans — global `textTheme` ab is scale se banta hai
- **Naye Text kabhi hardcoded fontSize mat do** — textTheme ya AppTextStyles use karo

### Navigation Pattern
- **Bottom nav (5 tabs):** Home · Products · **Billing (center raised gradient)** · Reports · More(opens drawer)
- Drawer = sirf secondary features (Catalog/Business/Shop/Staff) — primary destinations drawer mein NAHI
- Scanner/Checkout/Receipt = fullscreen, nav auto-hide (`app_shell.dart` `_fullScreenRoutes`)

### Feedback System (`lib/core/widgets/app_feedback.dart`)
- `AppFeedback.success/error/info(context, msg)` — ek hi tarika, har jagah
- Loading lists → `AppSkeletonList` (`app_skeleton.dart`), spinners sirf buttons/dialogs/pagination mein

### Motion Rules
- Page transitions: fade + 3% slide-up, global (`AppTheme.pageTransitions`)
- Stat cards: entrance fade+slide, value crossfade on refresh
- Buttons: press-scale 0.97 (`PrimaryButton`)
- Motion purposeful ho — decoration animation mat daalo

---

## Theme — Liquid Glass + Dark Mode
- **Material 3** — Flutter Material Design 3
- **Design Language**: Liquid Glass / Glassmorphism
- **Theme Mode**: Light/Dark toggle in Settings (`ThemeCubit` + Hive persistence)
- **Primary Color**: `#6C63FF` (Purple-ish) — same in both modes
- **Secondary**: `#03DAC6` (Teal)
- **Light Background Gradient**: Lavender `#E8EAF6` → Light Blue `#E3F2FD` → Light Cyan `#E0F7FA`
- **Dark Background Gradient**: Dark Navy `#0E0E18` → Dark Blue `#1A1A2E` → Deep Blue `#16213E`
- **Light Surface**: Semi-transparent white glass (`Colors.white @ 0.45–0.55 alpha`)
- **Dark Surface**: Semi-transparent dark glass (`#1A1A2E @ 0.55 alpha`)
- **Light Error**: `#B00020` (Red)
- **Dark Error**: `#CF6679` (Pink-red for a11y on dark bg)
- **Dark Background**: `#0E0E18`
- **Dark Card**: `#22223A`
- **Dark Input**: `#2A2A42`
- **Glass Effect**: `ClipRRect` → `BackdropFilter(ImageFilter.blur(sigma: 18-20))` → semi-transparent container

## Typography
- **Font Family**: IBM Plex Sans (`google_fonts`)
- **Body Large**: 15px, w500
- **Headings**: Bold, various sizes
- **Monetary values**: w900 for ₹ amounts

## Component Specs

### Cards (Glass Effect)
- Border radius: 20px
- Glass: `ClipRRect` → `BackdropFilter(blur: 20)` → semi-transparent white (0.55 alpha)
- Border: `Colors.white @ 0.20 alpha`, 1px width
- Shadow: dual — soft colored glow + ambient depth
- Reusable component: `GlassCard` (`lib/core/widgets/glass_card.dart`)

### Buttons (PrimaryButton)
- Background: Primary color (`#6C63FF`)
- Text: White, bold
- Border radius: 12px
- Elevation: 4 (shadow at 40% opacity)
- Padding: 16px vertical, 24px horizontal

### Input Fields
- Filled background: White
- Border radius: 12px
- Focused border: Primary color, 2px width
- Content padding: 16px horizontal, 16px vertical

### PremiumStatCard (`lib/core/widgets/premium_stat_card.dart`)
- `PremiumStatCard({label, value, color, icon?})`
- Glass effect: `ClipRRect` → `BackdropFilter(blur: 18)` → tinted glass (`color @ 0.13 alpha`)
- Border: white 0.20 alpha; radius 20
- Shadow: dual — colored glow (color @ 0.28, blur 24) + ambient depth
- Icon chip: `color @ 0.18 alpha` bg, icon uses `color` directly
- Label: 12px w600 `color @ 0.85`, letterSpacing 0.4
- Value: 28px `FontWeight.w800`, `color`, height 1.1
- Watermark icon: size 58, `color @ 0.06` (very subtle)

### GreetingHeader (`lib/core/widgets/greeting_header.dart`)
- `GreetingHeader({userName})`
- Glass container: `ClipRRect(24)` → `BackdropFilter(blur: 20)` → white @ 0.50 alpha
- Border: white 0.20, width 1.5
- Avatar: 52px gradient circle (primary → 60%), radius 18, shadow
- Initial: 24px w800 white; Greeting: 14px grey[500]; Name: 28px w800 black87
- Waving hand icon on right (decorative)
- Date: 12px grey[400], offset left 68px

### DashboardActionCard (`lib/core/widgets/dashboard_action_card.dart`)
- `DashboardActionCard({icon, title, subtitle?, color, onTap})`
- Glass: `ClipRRect(20)` → `BackdropFilter(blur: 20)` → white @ 0.50 alpha
- Border: `color @ 0.28 alpha`; shadow: colored glow + ambient
- Animated entry: `TweenAnimationBuilder` scale 0.98→1.0, 1200ms easeOutCubic
- Icon in `color @ 0.15` chip (radius 14); arrow in `color @ 0.15` circle
- Title: 18px w800 `color`; subtitle: 13px w500 grey[600]

### QuickActionTile (`lib/core/widgets/dashboard_action_card.dart`)
- `QuickActionTile({icon, label, color, onTap})`
- Glass: white @ 0.45 alpha, radius 20, border white 0.20
- Animated entry: `TweenAnimationBuilder` scale 0.85→1.0, 400ms easeOutBack
- Icon chip: `color @ 0.12%`, radius 14; icon size 26; label: 12px w700 black87
- Tap: splashColor = `color @ 15%`

### GlassCard (`lib/core/widgets/glass_card.dart`)
- `GlassCard({child, padding?, margin?, blur, tint, borderOpacity, borderRadius, width?, height?, onTap?})`
- Reusable glassmorphism container: `ClipRRect` → `BackdropFilter(blur: 20)` → semi-transparent white
- Default: tint white, border 0.20, radius 20, alpha 0.55

### SalesTrendCard (`lib/core/widgets/sales_trend_card.dart`)
- `SalesTrendCard({values: List<double>, labels: List<String>})`
- Glass card with mini CustomPainter line chart (7-day trend)
- Smooth bezier curve, gradient fill, data dots, max-value badge
- Stats row: Total + Avg/day in colored chips
- Empty state: "No data yet" placeholder

### RecentTransactionsCard (`lib/core/widgets/recent_transactions_card.dart`)
- `RecentTransactionsCard({transactions: List<RecentTransaction>})`
- `RecentTransaction` data class: id, staffName, grandTotal, paymentMethod, itemCount, createdAt
- Glass card with max 5 transaction rows
- Payment badges: UPI=green, Cash=orange, Card=blue, Credit=purple
- Time ago formatting (Just now, X min ago, etc.)
- "See All" link on right

### InventoryHealthCard (`lib/core/widgets/inventory_health_card.dart`)
- `InventoryHealthCard({totalProducts, lowStockCount, outOfStockCount, onViewDetails?})`
- Glass card with proportional health bar (green/orange/red segments)
- 3 stat items: In Stock, Low Stock, Out of Stock
- Health score: Good/Fair/Critical based on thresholds

### LowStockBanner (`inline in dashboard_page.dart`)
- Gradient bg (errorColor 12% → 6%), radius 16, border errorColor 35% width 1.2
- Icon in errorColor 15% bg chip (radius 10), icon size 20
- Text: 14px w600 errorColor; chevron: errorColor 70%, size 20

### Analytics Widgets (fl_chart based)
- **PaymentDonutChart** (`lib/core/widgets/payment_donut_chart.dart`): Pie/donut chart showing UPI/Cash/Card/Credit breakdown with percentage labels + legend with bill counts
- **TopProductsBarChart** (`lib/core/widgets/top_products_bar_chart.dart`): Vertical bar chart showing top 5 products by quantity sold, bars color-coded by revenue (purple→green gradient), tooltips on tap showing product name + units + revenue
- **MonthlyTrendCard** (`lib/core/widgets/monthly_tonthly_trend_card.dart`): FL LineChart showing 30-day sales trend with curved line, gradient fill below, interactive tooltips, total/avg stat chips
- **StaffPerformanceCard** (`lib/core/widgets/staff_performance_card.dart`): Owner-only card showing staff leaderboard with rank badges (#1 gold), avatar circles with initials, animated progress bars by revenue, bill count metadata

### Dashboard Screen — Liquid Glass Layout
- Background: 4-color gradient (lavender → blue → purple → green)
- `SliverAppBar` with transparent bg, floating + snap
- Greeting: `GreetingHeader` glass card (avatar + name + date)
- Low-stock alert: glass error banner (tappable → /reports/low-stock)
- Today's Sales: 4 `PremiumStatCard` glass cards in 2×2 grid
- Quick Actions: 1 `DashboardActionCard` glass ("New Bill") + 3-col `QuickActionTile` glass grid (6-7 tiles)
- Weekly Trend: `SalesTrendCard` glass card (7-day CustomPainter bezier chart from billHistory)
- Payment Methods: `PaymentDonutChart` glass card (pie chart from billHistory aggregation)
- Top Products: `TopProductsBarChart` glass card (bar chart from billHistory items aggregation)
- Monthly Trend: `MonthlyTrendCard` glass card (30-day FL line chart from salesRange)
- Recent Transactions: `RecentTransactionsCard` glass card (last 5 bills)
- Inventory Health: `InventoryHealthCard` glass card (product stats from ProductBloc)
- Staff Performance: `StaffPerformanceCard` glass card (owner-only, from billHistory staff aggregation)

### Analytics Data Sources
- Payment donut + top products + staff: derived from `ReportBloc.billHistory` (client-side aggregation in widget)
- Monthly trend: derived from `ReportBloc.salesRange` (fetched via `LoadSalesRange` event, 30-day window)
- All analytics widgets use the same glass container style as existing dashboard cards (consistent border radius 20, dual shadows, theme-aware colors)

### Animations
- DashboardActionCard: scale 0.98→1.0 on mount (1200ms)
- QuickActionTile: scale 0.85→1.0 stagger (400ms easeOutBack)
- All stat cards: glass effect renders instantly (no animation to avoid layout jitter)
- SalesTrendCard: CustomPainter renders smooth bezier curve on mount
- MonthlyTrendCard: FL LineChart with animated curve entrance
- TopProductsBarChart: FL BarChart with colored bars (revenue-based hue)
- PaymentDonutChart: FL PieChart with center hole (donut style)

### Scanner Screen
- Camera occupies top 40% of screen
- Bottom panel has 24px overlap (rounded top corners)
- Scanner overlay: 250×250 bounding box with green accent corners
- Floating overlay buttons: circular, black45 background

### Product Management Screen — Dual View (`lib/features/product/presentation/pages/product_list_page.dart` + `product_coverflow_view.dart`)
- **Style**: NOT glass — solid surface cards on app gradient bg. Distinct from dashboard.
- **Dual view system**: shell page + view switcher. **Default = Classic List** (har app open pe). Cover-flow optional. View toggle = AppBar icon (`Icons.view_carousel_rounded` ↔ `Icons.view_list_rounded`, animated rotation). No persistence — choice session-only.
- **Switching**: `AnimatedSwitcher` (350ms fade) between `_ClassicListView` (shell file) and `ProductCoverflowView` (own file). Search query + sort + category filter shared across both views.
- **View A — Classic List (default)**: category FilterChips (All + categories, counts) → `ListView.separated` of **compact cards** (~60px) wrapped in **`Dismissible`** (swipe right = green "Stock +" → quick stock sheet, swipe left = red "Delete" → confirm dialog; `confirmDismiss` returns false, card snaps back). Compact card: stock-color accent bar (left, 4px) + image (40px, radius 10) + **Line 1**: name (w600 14, 1 line) + price (w700 14 primary, right-aligned) + **Line 2**: stock badge (colored dot + count) + category (gray, flexible/ellipsis) + location (gray, flexible/ellipsis, `·` separator). Trailing **30px circular add-to-cart button** (primary, `add_shopping_cart` icon → `AddProductToCartEvent` + green snackbar). **Out-of-stock** (stock ≤ 0) cards rendered at 50% opacity (accent bar stays red). **Image placeholder** = initial-letter avatar (first letter of name, color from `Colors.primaries[name.hashCode]`). **Long-press** → bottom sheet: Edit / Show QR Code / **Copy barcode** / Delete. No chevron / description snippet / unit badge / barcode on card. Haptic + `FilterChip` selected = primary fill.
- **Header bar (shared, both views)**: below search — **Low-stock pill toggle** (amber `warning` icon + count of `isLowStock` products; active = amber fill, white text; filters list to low/out-of-stock) + **mini stats text** `total · low · out` (gray 11.5). Hidden when no products.
- **Search** matches name, barcode, description **and location**.
- **Selection mode (bulk)**: AppBar `checklist` icon → AppBar swaps to Close + `N selected` + export (`ios_share`) + delete (`delete`, red) actions. Cards tap/long-press toggle selection, `Dismissible` disabled (`DismissDirection.none`), trailing becomes a circular check indicator (selected = primary fill + white check, else outline), selected card gets 2px primary border. Bulk delete has confirm dialog + Undo snackbar; bulk export shares selected via `CsvExportImport`.
- **Delete** (single swipe, long-press menu, or detail) → confirm dialog → `DeleteProduct` + **Undo snackbar** (`AddProduct` restores).
- **Import from CSV** = real file picker (`CsvExportImport.importProducts`) → parses rows → `AddProduct` each; skips empty names; shows count snackbar. CSV columns: Name, Barcode, Price, Stock, Min Stock Level, Unit, Category ID, Location, Description, Warranty Type, Warranty Duration, Warranty Unit.
- **View B — Spotlight Cover-flow**: hero search (top) → category dial (horizontal pill carousel) → **3D cover-flow carousel** → bottom panel (dots + position)
- **Cover-flow**: `PageView` (viewportFraction 0.72) + `_CoverFlowItem` 3D transform — `Matrix4` perspective (`setEntry(3,2,0.0016)`) + `rotateY(angle = offset*0.72)` + `scaleByDouble(1 - offset*0.16)` + opacity fade for side cards.
- **Cover card**: big product image (Hero `product-{id}`) + category badge (purple) + stock badge (green/orange/red) + low-stock amber banner + name (17 w700) + price (22 w800 primary) + unit chip + barcode text + **Edit / QR Code** action buttons.
- **Category dial**: horizontal pill items (icon + label + count), selected = primary fill + glow shadow, auto-centered via `Scrollable.ensureVisible(alignment: 0.5)`, haptic on select.
- **Hero search**: 56px rounded pill (primary border glow) + "Spotlight search..." hint + gradient scanner button (56px, radius 18).
- **Bottom panel**: animated dot indicators (active pill widens 7→22px) + "N of M · Swipe to browse" + swipe icon. Dots shown only ≤12 products.
- **Expandable FAB**: Add (primary) → expand (easeOutBack + fade) → Scan mini-FAB (secondary/teal). `IgnorePointer` when collapsed.
- **Motion**: 3D cover-flow rotation on swipe, animated card border/glow for center card, skeleton carousel shimmer, animated empty state.
- **Navigation**: card tap → detail; Edit/QR buttons on card → edit/qr routes.

### Icons
- Settings gear (top right, scanner screen)
- Flash toggle
- Camera on/off toggle

## Navigation Pattern
- All AppShell pages have a hamburger `Icons.menu` button in AppBar `leading` calling `Scaffold.of(context).openDrawer()`
- Color: `Theme.of(context).primaryColor`; tooltip: 'Open menu'

## Screens

| Screen | Route | Purpose |
|--------|-------|---------|
| Dashboard | `/` | Greeting, today's sales, quick actions, low-stock alert |
| Scan & Billing | `/scan` | Barcode scanner + cart panel |
| Checkout | `/scan/checkout` | Order summary, QR, print |
| Products | `/products` | List all products |
| Add Product | `/products/add` | Add new product |
| Edit Product | `/products/edit/:id` | Edit existing product |
| Shop Details | `/shop` | Shop name, UPI ID, address, etc. |
| Settings | `/settings` | Printer config |

## Layout Considerations
- Portrait-first design
- Bottom sheets with rounded top corners
- Floating action buttons
- Empty states with illustrations/icons + helper text
