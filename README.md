# 🛒 Mobile POS & Billing App

A feature-rich, offline-first billing and POS application built with Flutter + Supabase. Designed for phone shops and accessories retail — supporting multi-staff real-time sync, barcode/QR scanning, Bluetooth thermal receipt printing, UPI payments, and visual sales analytics.

## Screenshot

![App Screenshot](https://github.com/user-attachments/assets/f2d16454-5408-43b3-b207-cd843bbc2c9e)

## 🎯 What It Does

Complete offline-first POS system for small to medium retail shops (phone & accessories). Handles checkout, inventory, staff management, and real-time multi-user sync — all on-device with optional Supabase cloud backup.

### Core Features at a Glance

- **Barcode & QR Scanner** — camera-based scanning to add products to cart instantly
- **Smart Cart & Checkout** — multi-product billing with ₹/%, manual discount, grand total override
- **Bluetooth Thermal Receipt Printing** — instant ESC/POS receipts with shop branding
- **UPI QR Payment** — generate UPI QR on bill for instant collection
- **Product Management** — full CRUD with categories, shelf/location, stock tracking, QR generation
- **3-Tier Role System** — Super Admin / Owner / Staff with automatic shop isolation (RLS)
- **Real-time Multi-User Sync** — Supabase Realtime keeps inventory & bills in sync across all staff
- **Dashboard & Analytics** — donut charts, bar charts, 30-day trends, staff leaderboard
- **Reports & History** — bill search/filter, daily sales, low-stock alerts, stock movement log, full bill edit
- **Offline-First** — Hive local DB works without internet; auto-syncs on reconnect

## 🛠 Tech Stack

| Layer | Technology |
|-------|-----------|
| **Framework** | Flutter 3.x (Dart) |
| **State Management** | `flutter_bloc` (BLoC pattern) |
| **Cloud DB** | Supabase (PostgreSQL + Realtime) |
| **Local Cache** | Hive (offline fallback) |
| **Auth** | Supabase Auth (email/password + Google OAuth) |
| **Dependency Injection** | `get_it` |
| **Navigation** | `go_router` |
| **Code Gen** | `json_serializable` + `build_runner` |
| **FP** | `fpdart` (Either<Failure, T> pattern) |
| **Scanner** | `mobile_scanner` (barcode + QR decode) |
| **QR Gen** | `pretty_qr_code` |
| **Printer** | `print_bluetooth_thermal` (ESC/POS) |
| **Charts** | `fl_chart` (pie, bar, line) |
| **UI** | Material 3 + Liquid Glass / Glassmorphism |
| **Sharing** | `share_plus` (WhatsApp receipt share) |
| **Config** | `app_settings` (open app settings) |

## 📁 Feature Structure (Clean Architecture)

```text
lib/
├── config/routes/               # go_router — AppShell + nested routes
├── core/
│   ├── data/                    # Hive DB init & helpers
│   ├── error/                   # Failure/Exception models (fpdart)
│   ├── realtime/                # Supabase Realtime subscription manager
│   ├── supabase/                # Supabase client setup
│   ├── theme/                   # AppTheme + TextStyles + ThemeCubit
│   ├── usecase/                 # Base UseCase contract
│   ├── utils/                   # PrinterHelper, AppValidators
│   ├── config/                  # Deep link config
│   └── widgets/                 # Shared: GlassCard, PrimaryButton, StatCard,
│                                 # DashboardActionCard, Chart widgets, etc.
│   └── service_locator.dart     # get_it DI registration
│
└── features/
    ├── auth/                    # Login, Register, Email Verification
    │                             # Roles: owner (default on signup) / staff (owner-created)
    ├── billing/                 # Scanner, Cart, Checkout, Receipt Preview
    ├── product/                 # Product CRUD, QR code generation
    ├── category/                # Category management (CRUD)
    ├── shop/                    # Shop details UPI ID, address, name
    ├── settings/                # Printer connection, app settings
    ├── report/                  # Bill history, daily sales, low stock,
    │                             # stock movements, analytics (fl_chart)
    ├── staff/                   # Staff management (owner-only: add/delete)
    └── dashboard/               # Homepage — greeting, stats, quick actions,
                                 # analytics cards (donut, bar, line, leaderboard)
```

*Each feature follows Clean Architecture: data (repo impl + models) → domain (entities + interfaces + use cases) → presentation (BLoC + UI pages).*

## 👥 Roles & Access

| Role | Description | Permissions |
|------|------------|-------------|
| **Super Admin** | SaaS-level admin (manual assignment) | Cross-shop data access — sees all shops |
| **Owner** | Default role on signup — auto-created with shop | Full access: products, categories, billing, reports, staff mgmt, settings |
| **Staff** | Added by owner via invite | Billing (scan → sell → print), view products & stock. No staff/settings access |

### Shop Isolation
Every record is scoped to a shop via `shop_id`. Enforcement at 3 layers:
1. **Database RLS** — strongest guard, `belongs_to_shop(shop_id)` on all business tables
2. **Repository queries** — `_resolveShopId()` auto-filters every Supabase call
3. **BLoC propagation** — `_currentShopId` from AuthBloc passed to all use cases

## 📡 Real-time Sync
- Supabase Realtime on `products`, `bills`, `inventory_log`
- ProductBloc auto-refreshes on INSERT/UPDATE/DELETE from any device
- Stock validation before bill submit (prevents overselling)
- Graceful fallback — app works without Realtime connection

## 📊 Dashboard Analytics

| Widget | Chart Type | Data Source |
|--------|-----------|-------------|
| Payment Methods | Donut (pie) | Bill aggregation — UPI/Cash/Card/Credit % |
| Top Products | Bar chart | Top 5 by quantity sold, revenue-colored |
| Monthly Trend | Line chart (30 days) | `LoadSalesRange` event, FL LineChart |
| Staff Performance | Leaderboard | Owner-only, rank badges + progress bars |
| Inventory Health | Progress bar | In stock / low stock / out of stock |

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `^3.1.0`
- Dart `>=3.1.0`
- Android Studio / Xcode (for emulators and building)
- A Supabase project (create at https://supabase.com)
- Optional: Bluetooth thermal printer for testing receipts

### 1. Clone & Setup

```bash
git clone <repository_url>
cd billing_app
```

### 2. Supabase Configuration

1. Create a Supabase project at https://supabase.com
2. Run the migrations (applied in order):
   - `supabase/migrations/001_initial_schema.sql` — core tables
   - `supabase/migrations/003_saas_shops.sql` — multi-shop support
   - `supabase/migrations/004_shop_data_scoping.sql` — RLS scopes
   - `supabase/migrations/005_add_staff_phone.sql` — staff phone column
   - `supabase/migrations/006_three_tier_roles.sql` — Super Admin/Owner/Staff roles
   - `supabase/migrations/007_fix_signup_trigger_order.sql`
   - `supabase/migrations/008_fix_rls_recursion_profiles.sql`
   - `supabase/migrations/009_add_customer_phone_to_bills.sql`
3. Add your Supabase URL and anon key to the app config (see `lib/core/supabase/supabase_client.dart`)

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Run Code Generation

Required for Hive adapters and JSON serialization:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 5. Run the App

```bash
flutter run
```

## 🧪 Test

```bash
flutter test
```

## 📦 Build APK (Release)

```bash
flutter build apk --release --split-per-abi
```

Output split per architecture goes to `build/app/outputs/flutter-apk/`.

## 🤝 Contributing

Follow these conventions:

1. **Clean Architecture** — keep domain/data/presentation boundaries strict
2. **Immutable States** — BLoC states must use `equatable`
3. **Error Handling** — use `fpdart`'s `Either<Failure, Type>`, never throw raw exceptions in domain layer
4. **No `SELECT *`** or FK joins in queries — fetch per-column
5. **Realtime** — normalizeLinkedMap() before `.fromJson()` for newRecord/oldRecord
6. **Dates** — use `.gte()` with `YYYY-MM-DD` format
7. **Dart-first** — fix in Dart code before touching SQL migrations
8. **Graphify** — run `graphify update .` after every code change

## 📁 Project Docs

| File | Purpose |
|------|---------|
| `RPD.md` | Requirements & Product Definition — features, user stories, scope |
| `architecture.md` | Detailed architecture, DB tables, offline strategy, state flow |
| `design.md` | UI design system — theme, typography, component specs, animations |
| `phases.md` | Roadmap — all phases with status (✅ done / 🔧 in progress) |
| `rules.md` | Dev rules & conventions |
| `CLAUDE.md` | Project-specific rules & critical update reminders |
| `memory.md` | Session log — key decisions, edits, todos |
| `supabase/migrations/` | SQL migration files in sequential order |