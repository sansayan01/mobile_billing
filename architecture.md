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
│  Repository Impl  ←→  Models  ←→  Hive (Local DB)      │
└─────────────────────────────────────────────────────────┘
```

## Architecture Pattern: **Clean Architecture + BLoC**

### Layers

#### 1. Presentation Layer
- **Pages** — Flutter widgets/screens
- **Bloc** — State management (flutter_bloc)
- **Events** — User actions dispatched to Bloc
- **States** — Immutable state classes (equatable)

#### 2. Domain Layer
- **Entities** — Core business objects (Product, Shop, CartItem)
- **Use Cases** — Business logic (getProductByBarcode, manageProducts)
- **Repository Interfaces** — Contracts for data layer

#### 3. Data Layer
- **Repository Implementations** — Data source logic
- **Models** — JSON-serializable DTOs with `json_serializable`
- **Data Sources** — Hive local database

## Dependency Injection
- **get_it** — Service locator pattern
- Registered in `lib/core/service_locator.dart`

## Navigation
- **go_router** — Declarative routing with nested routes

## State Flow
```
User Action → Event → Bloc (mapEventToState) → State → UI Rebuild
```

## Project Structure
```
lib/
├── config/
│   └── routes/              # go_router config
├── core/
│   ├── data/                # Hive init
│   ├── error/               # Failure class
│   ├── service_locator.dart # DI container
│   ├── theme/               # AppTheme
│   ├── usecase/             # Base UseCase
│   ├── utils/               # Validators, PrinterHelper
│   └── widgets/             # Shared widgets (PrimaryButton, InputLabel)
├── features/
│   ├── billing/             # Barcode scan, cart, checkout
│   ├── product/             # Product CRUD
│   ├── settings/            # Printer settings
│   └── shop/                # Shop details config
└── main.dart
```
