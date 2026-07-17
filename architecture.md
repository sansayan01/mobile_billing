# Architecture

## High-Level Overview

```
┌─────────────────────────────────────────────────────────┐
│                      PRESENTATION                        │
│  Pages (UI)  ←→  Bloc (State)  ←→  Events/Actions      │
├─────────────────────────────────────────────────────────┤
│                       DOMAIN                             │
│  Entities  ←→  Use Cases  ←→  Repository Interfaces     │
├─────────────────────────────────────────────────────────┤
│                        DATA                              │
│  Repository Impl  ←→  Models  ←→  Supabase (Primary)    │
│                                    ↕ (sync)             │
│                               Hive (Local Cache/Offline) │
└─────────────────────────────────────────────────────────┘
```

## Architecture Pattern: **Clean Architecture + BLoC + Supabase**

### Layers

#### 1. Presentation Layer
- **Pages** — Flutter widgets/screens
- **Bloc** — State management (flutter_bloc)
- **Events** — User actions dispatched to Bloc
- **States** — Immutable state classes (equatable)

#### 2. Domain Layer
- **Entities** — Core business objects (Product, Category, Shop, CartItem, Bill)
- **Use Cases** — Business logic (getProductByBarcode, manageProducts, manageInventory)
- **Repository Interfaces** — Contracts for data layer

#### 3. Data Layer
- **Repository Implementations** — Data source logic
- **Models** — JSON-serializable DTOs
- **Services**:
  - **RealtimeService** — Supabase Realtime subscription management
- **Data Sources**:
  - **Supabase** (primary) — real-time cloud database
  - **Hive** (local cache) — offline fallback

## Database: Supabase (PostgreSQL)

### Tables
- `categories` — id, name, description, created_at
- `products` — id, name, category_id, price, stock, location, barcode, qr_data, image_url, description, created_at, updated_at
- `users` — id, email, role (owner/staff), name, created_at
- `bills` — id, staff_id, total_amount, discount, grand_total, created_at
- `bill_items` — id, bill_id, product_id, quantity, price, total
- `locations` — id, name (Rack/Shelf/Box), description, created_at
- `inventory_log` — id, product_id, change_type (add/sell/remove), quantity, staff_id, created_at

### Real-time Sync
- Supabase Realtime enabled on `products`, `bills`, `inventory_log` tables
- `RealtimeService` subscribes to Postgres changes via `onPostgresChanges()` API
- ProductBloc listens for INSERT/UPDATE → debounce reload, DELETE → remove from state
- Any staff sells → inventory updates instantly for all users
- Realtime init is non-blocking: app works without live updates if connection fails

## Offline Strategy
- Hive serves as local cache
- When online: Supabase = source of truth, Hive syncs
- When offline: Read from Hive, queue writes
- On reconnect: sync queued operations

## Dependency Injection
- **get_it** — Service locator pattern
- SupabaseClient registered as singleton

## Navigation
- **go_router** — Declarative routing with nested routes

## State Flow
```
User Action → Event → Bloc → Repository → Supabase (API)
                                         → Hive (Cache)
                          ← State ←
                          UI Rebuild

Supabase Realtime → RealtimeService → Event (ProductsRealtimeUpdated) → Bloc → State → UI
```

## Project Structure
```
lib/
├── config/
│   └── routes/              # go_router config
├── core/
│   ├── data/                # Hive init & helpers
│   ├── error/               # Failure class
│   ├── realtime/            # Supabase Realtime subscription service
│   ├── service_locator.dart # DI container
│   ├── supabase/            # Supabase client config
│   ├── theme/               # AppTheme
│   ├── usecase/             # Base UseCase
│   ├── utils/               # Validators, PrinterHelper
│   └── widgets/             # Shared widgets (PrimaryButton, InputLabel)
├── features/
│   ├── auth/                # Staff login/logout
│   ├── billing/             # Barcode scan, cart, checkout
│   ├── product/             # Product CRUD
│   ├── category/            # Category management
│   ├── inventory/           # Stock tracking, location
│   ├── report/              # Sales reports, history
│   ├── settings/            # Printer, shop settings
│   └── shop/                # Shop details config
└── main.dart
```
