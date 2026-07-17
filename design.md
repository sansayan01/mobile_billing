# Design

## Theme
- **Material 3** — Flutter Material Design 3
- **Primary Color**: `#6C63FF` (Purple-ish)
- **Secondary**: `#03DAC6` (Teal)
- **Background**: `#F2F2F7` (Light gray)
- **Surface**: White
- **Error**: `#B00020` (Red)

## Typography
- **Font Family**: IBM Plex Sans (`google_fonts`)
- **Body Large**: 15px, w500
- **Headings**: Bold, various sizes
- **Monetary values**: w900 for ₹ amounts

## Component Specs

### Cards
- Border radius: 16px
- Elevation: 4
- Shadow: black 10% (custom `withValues`)

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
- Gradient background (color → 72% alpha), radius 20, colored shadow (blur 16, offset 0,6)
- Icon chip: white 25% bg, radius 10; label: 12px w600 white 90%, letterSpacing 0.4
- Value: 28px `FontWeight.w800`, white, height 1.1
- Faint watermark icon (size 56, alpha 0.1) bottom-right via Stack

### GreetingHeader (`lib/core/widgets/greeting_header.dart`)
- `GreetingHeader({userName})`
- Avatar: 48px gradient circle (primary → 70%), radius 16, colored shadow (blur 12)
- Initial: 22px w800 white; Greeting: 13px grey[500]; Name: 26px w800 black87
- Date: 12px grey[400], offset left 62px (aligned under name)

### DashboardActionCard (`lib/core/widgets/dashboard_action_card.dart`)
- `DashboardActionCard({icon, title, subtitle?, color, onTap})`
- Gradient bg (color → 82%), radius 20, dual shadow (colored + subtle black)
- Animated entry: `TweenAnimationBuilder` scale 0.98→1.0, 1200ms easeOutCubic
- Icon in white 22% bg chip (radius 14); arrow in white 18% bg circle
- Title: 18px w800 white letterSpacing -0.2; subtitle: 13px w500 white 85%

### QuickActionTile (`lib/core/widgets/dashboard_action_card.dart`)
- `QuickActionTile({icon, label, color, onTap})`
- White surface, radius 20, border grey[200] 1px, dual soft shadow
- Animated entry: `TweenAnimationBuilder` scale 0.85→1.0, 400ms easeOutBack
- Icon chip: color @12%, radius 14; icon size 26; label: 12px w700 black87
- Tap: splashColor = color @15%

### LowStockBanner (`inline in dashboard_page.dart`)
- Gradient bg (errorColor 12% → 6%), radius 16, border errorColor 35% width 1.2
- Icon in errorColor 15% bg chip (radius 10), icon size 20
- Text: 14px w600 errorColor; chevron: errorColor 70%, size 20

### Dashboard Screen
- Greeting: `GreetingHeader` widget (avatar + name + date)
- Today's Sales: 4 PremiumStatCards in 2×2 grid (Total Sales green, Bills primary, Avg Bill orange, Discount pink)
- Quick Actions: 1 animated `DashboardActionCard` ("New Bill") + 3-col animated `QuickActionTile` grid (6-7 tiles)
- Low-stock alert: gradient error banner (tappable → /reports/low-stock)

### Animations
- DashboardActionCard: scale 0.98→1.0 on mount (1200ms)
- QuickActionTile: scale 0.85→1.0 stagger (400ms easeOutBack)
- All stat cards instant render (no animation to avoid layout jitter)

### Scanner Screen
- Camera occupies top 40% of screen
- Bottom panel has 24px overlap (rounded top corners)
- Scanner overlay: 250×250 bounding box with green accent corners
- Floating overlay buttons: circular, black45 background

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
