# 🛒 Mobile POS & Billing App

**The last billing app your phone shop will ever need.** Built for shop owners who want to run their entire business from one screen — inventory, sales, staff, and receipts — all syncing in real-time, even when the internet drops.

---

## 💼 Why Shop Owners Love This App

| Pain Point | How This App Solves It |
|---|---|
| "I don't know what's selling and what's gathering dust" | Real-time dashboards show your top products, daily sales trends, and revenue breakdown — at a glance |
| "My staff can't keep track of stock — we lose sales" | Real-time inventory sync across all devices. When one staff sells, everyone sees updated stock instantly |
| "Cash and UPI payments — keeping track is a mess" | Every bill tracked with payment method (Cash/UPI/Card/Credit), searchable history, and printable receipts |
| "I can't monitor my staff when I'm not there" | Owner-only dashboard with staff performance leaderboard — see who's driving revenue |
| "New products, new categories — adding them is slow" | Scan a barcode/QR → product added to inventory in seconds. Create categories on the fly |
| "My shop data is scattered across notes and spreadsheets" | Everything lives in Supabase cloud — accessible from any device, backed up always |
| "What if there's no internet?" | Offline-first with Hive local cache — app works fully without connectivity, syncs when back online |
| "Printing receipts is a hassle" | Bluetooth thermal printer support — one tap, instant physical receipt |

---

## 📸 Screenshot

![App Screenshot](https://github.com/user-attachments/assets/f2d16454-5408-43b3-b207-cd843bbc2c9e)

---

## 🎯 What You Get — Owner's Checklist

### 📦 Inventory Management
- **Add products** by scanning barcode or QR — takes 2 seconds
- **Generate QR codes** for any product (bind SKU, price, product ID) — print them, stick them on shelves
- **Categories** — create, edit, delete categories (Phones, Chargers, Covers, Cables, etc.)
- **Stock tracking** — real-time quantity updates, low-stock alerts so you never run out of bestsellers
- **Location/shelf tracking** — assign products to racks, shelves, boxes. Find items fast
- **Product images** — snap a photo for every product

### 💰 Smart Billing & Checkout
- **Scan → Sell → Print** — barcode scan to add items, checkout immediately
- **Multiple payment methods** — Cash, UPI, Card, Credit — all tracked per bill
- **Manual discount** — ₹ or % on entire bill or per item
- **Grand total override** — edit final amount if needed
- **Generate UPI QR** on bill — customer scans and pays instantly
- **Print receipt** — Bluetooth thermal printer, one tap
- **Share receipt via WhatsApp** — `share_plus` integration

### 👥 Staff Management (Owner-Only)
- **Create staff accounts** — owner invites staff with email + password
- **Role-based access** — staff can only bill and view products; no settings access
- **Delete staff** — remove access anytime
- **Shop isolation** — each staff member only sees their own shop's data (enforced at database level)

### 📊 Real-Time Dashboard & Analytics
| Widget | What It Tells You |
|---|---|
| **Payment Methods Donut** | UPI vs Cash vs Card vs Credit breakdown — know your collection mix |
| **Top Products Bar Chart** | Top 5 sellers by quantity — see what flies off the shelves |
| **30-Day Sales Trend** | Line chart — spot growth or dips over time |
| **Staff Performance** | Owner-only leaderboard — who's closing the most bills |
| **Inventory Health** | In stock / Low stock / Out of stock — at a glance |

### 🔄 Real-Time Multi-User Sync
- Supabase Realtime keeps all devices in sync
- Staff A sells a phone → Staff B's screen updates instantly
- No manual refreshes, no stale data
- Works offline — syncs automatically when reconnected

### 🏪 Shop Settings
- **UPI ID** — for QR payments on bills
- **Shop name, address, phone** — printed on every receipt
- **Printer configuration** — connect your Bluetooth thermal printer from settings
- **Dark/Light mode** — switch theme from settings

### 📈 Reports & History
- **Bill history** — search by customer name, bill ID, or product name
- **Filter by payment method** — see all UPI bills, Cash bills, etc.
- **Discount shown** — per bill and per item
- **Bill detail** — full breakdown of items, totals, payment method
- **Edit bills** (owner-only) — change customer info, payment method, items
- **Daily sales summary** — how much you made today
- **Low stock alerts** — products running out
- **Stock movement log** — every add/sell/return tracked with timestamp and staff

---

## 🏗 How It's Built (Under the Hood)

The app follows **Clean Architecture** — meaning it's structured so that nothing breaks when you change one part. Your data stays safe, your UI stays fast, and your staff gets a smooth experience.

```
┌─────────────────────────────────────────────────────────┐
│                    PRESENTATION                          │
│  Pages (UI)  ←→  BLoC (State)  ←→  Events/Actions    │
├─────────────────────────────────────────────────────────┤
│                     DOMAIN                               │
│  Entities  ←→  Use Cases  ←→  Repository Interfaces  │
├─────────────────────────────────────────────────────────┤
│                      DATA                                │
│  Supabase (Cloud/Realtime)  ↔  Hive (Local/Offline)   │
└─────────────────────────────────────────────────────────┘
```

| Component | Technology |
|---|---|
| Framework | Flutter 3.x (Dart) |
| State Management | flutter_bloc (BLoC pattern) |
| Cloud Database | Supabase (PostgreSQL + Realtime) |
| Local Cache | Hive (offline-first) |
| Authentication | Supabase Auth (email + Google OAuth) |
| Scanner | mobile_scanner (barcode + QR decode) |
| QR Generation | pretty_qr_code |
| Bluetooth Printer | print_bluetooth_thermal (ESC/POS) |
| Charts & Analytics | fl_chart (pie, bar, line) |
| Sharing | share_plus (WhatsApp receipt) |
| Dependency Injection | get_it |
| Navigation | go_router |
| Error Handling | fpdart (Either<Failure, T> pattern) |
| UI Theme | Material 3 + Liquid Glass / Glassmorphism |

---

## 👥 Roles & Access

| Role | Who | What They Can Do |
|---|---|---|
| **Owner** | You — the shop owner (auto-assigned on signup) | **Everything**: manage products, categories, staff, billing, reports, printer settings, shop profile |
| **Staff** | Employees you add | **Billing only**: scan products → checkout → print receipt. No settings, no staff management, no reports |
| **Super Admin** | Manual assignment (for platform admins) | Cross-shop access — see all shops' data |

### 🔒 Shop Data Isolation
Every single record (product, bill, stock change, inventory log) is tagged with your shop's ID. This is enforced at **three layers** — database RLS (strongest), query filtering, and BLoC-level propagation. Your data stays yours. Period.

---

## 📱 Screens

| Screen | Route | What You See |
|---|---|---|
| **Dashboard** | `/` | Greeting, today's sales (4 key stats), quick actions, low-stock alerts, weekly trend chart, analytics |
| **Scanner & Billing** | `/scan` | Camera-based barcode/QR scanner with cart panel |
| **Checkout** | `/scan/checkout` | Order summary, payment method toggle (Cash/UPI), UPI QR, print button |
| **Products** | `/products` | Full inventory list with search, category filters |
| **Add Product** | `/products/add` | Form with barcode scan, QR generation, image pick, category dropdown |
| **Product Detail** | `/products/detail/:id` | Edit stock, view sales history, generate QR |
| **Categories** | `/categories` | Manage product categories (Phones, Chargers, Covers, etc.) |
| **Staff** | `/staff` | View staff list, add new staff (owner-only) |
| **Shop Settings** | `/shop` | Update UPI ID, shop name, address |
| **Reports** | `/reports` | Bill history (searchable/filterable), daily sales, low stock, stock movements |
| **Settings** | `/settings` | Printer connect, dark/light mode toggle |

---

## 🚀 Get Started in 5 Minutes

### Prerequisites
- Flutter SDK `^3.1.0`
- Android device (primary target) or emulator
- A Supabase account (free tier works great — [supabase.com](https://supabase.com))
- Optional: Bluetooth thermal printer (for physical receipts)

### 1. Clone & Install

```bash
git clone <repository_url>
cd billing_app
flutter pub get
```

### 2. Connect Supabase

1. Create a project at https://supabase.com
2. Run migrations in order (SQL files live in `supabase/migrations/`):

```
001 → Core tables (products, categories, bills, bill_items, etc.)
003 → Multi-shop support (shops table)
004 → Data scoping & RLS policies
005 → Staff phone column
006 → 3-tier roles (Super Admin / Owner / Staff)
007-009 → Bug fixes & enhancements
```

3. Add your Supabase URL and anon key in `lib/core/supabase/supabase_client.dart`

### 3. Generate Code & Run

```bash
dart run build_runner build --delete-conflicting-outputs
flutter run
```

That's it. You're in. Create your shop, add products, and start billing.

---

## 📦 Build APK (for Distribution)

```bash
flutter build apk --release --split-per-abi
```

Output goes to `build/app/outputs/flutter-apk/` — split per architecture for smaller APK size. Upload to gofile.io or direct install on your staff's phones.

---

## 📝 Contributing

This project prioritizes **shop owners first**. When making changes:

1. **Clean Architecture** — keep domain/data/presentation boundaries strict
2. **Immutable states** — use `equatable` for BLoC states
3. **Error handling** — use `fpdart`'s `Either<Failure, T>`, never raw exceptions in domain
4. **No `SELECT *`** — fetch per-column only
5. **Dart-first** — fix in Dart code before touching SQL migrations
6. **Run `flutter analyze`** before committing — zero warnings required

---

## 📂 Project Docs

| File | What's In It |
|---|---|
| `RPD.md` | Full requirements & product definition — every feature, every user story |
| `architecture.md` | System architecture, database tables, offline strategy, state flow |
| `design.md` | UI design system — theme, typography, component specs, animations |
| `phases.md` | Roadmap — what's done, what's in progress, what's next |
| `rules.md` | Dev conventions & coding rules |
| `CLAUDE.md` | Critical project rules — read first before any change |
| `memory.md` | Session log — key decisions, edits, todos |
| `supabase/migrations/` | SQL migration files in sequential order |

---

## 🎯 Who This Is For

This app was built for **phone shops, accessories shops, and small retail stores** that need a professional billing system without the complexity of enterprise software. One owner, multiple staff, one shared view of the business — all from their phones.

---

*Built with Flutter ❤️ by the team at [MicroFlow Pro](https://github.com/sansayan01/mobile_billing)*
