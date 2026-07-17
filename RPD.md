# RPD — Requirements & Product Definition

## Product Overview
Flutter-based **billing + inventory management** app for a phone shop (phones, headphones, chargers, cables, covers, accessories). Multi-user real-time sync via Supabase with QR/barcode scanning support.

## Client Profile
- **Shop Type**: Phone & accessories retail
- **Staff**: 4-5 employees
- **Sells**: Phones, headphones, chargers, data cables, covers, accessories
- **Each product can have different price**

---

## Core Features

### 1. Categories (Dynamic)
- [ ] Client can **create/edit/delete categories** (Phones, Chargers, Covers, Cables, etc.)
- [ ] Products are organized **category-wise**
- [ ] Category management screen

### 2. Product Inventory
- [ ] Add products via **QR code scan** or **barcode scan**
- [ ] QR code **generation** in-app (client can generate QR for any product)
- [ ] Product fields: name, category, price, stock quantity, location/shelf, description, barcode/qr data, image
- [ ] Edit/delete products
- [ ] Product search & filter (by name, category, barcode)

### 3. Billing (Point of Sale)
- [ ] **Multiple products** in one bill
- [ ] **Barcode/QR scan** to add to cart (fast billing)
- [ ] **Manual discount** — ₹ or % on bill
- [ ] **Manual grand total override** — edit final amount if needed
- [ ] Item quantity +/-
- [ ] Bill receipt print (thermal printer)
- [ ] UPI QR payment display

### 4. Real-time Sync (Supabase)
- [ ] **Supabase** as backend
- [ ] Real-time inventory updates — staff A sells → staff B sees updated stock instantly
- [ ] Multi-user support (4-5 staff + owner)
- [ ] Auth login (owner vs staff roles)

### 5. Shelf / Location Tracking
- [ ] Products assigned to **box/shelf/rack location**
- [ ] Location description (e.g. "Rack 3, Shelf B, Box 2")
- [ ] Helps staff find products quickly in the shop

### 6. QR Code Generator
- [ ] In-app QR code generator for products
- [ ] Product ID/data encoded in QR
- [ ] Print QR or save as image

### 7. Reports & History
- [x] Bill/invoice history (domain + data + UI)
- [x] Daily sales summary (domain + data + UI)
- [x] Low stock alerts (domain + data + UI)
- [x] Stock movement log (domain + data + UI)

### 8. Staff Management (Owner-only)
- [x] Owner can **create staff account** (Supabase Auth signUp + shop_id link) with name, email, phone, password
- [x] Staff **list view** (own shop only, scoped by RLS) — name, email, role badge, phone
- [x] **Delete staff** (profiles row removal via confirm dialog)
- [x] Staff hidden from non-owner (drawer + dashboard tile + add page guard)
- [ ] Staff edit (role/phone change) — deferred
- [ ] Active/Inactive toggle — deferred (delete-only model)

---

## User Roles (3-Tier)

| Role | Permissions |
|------|------------|
| **Super Admin** (`super_admin`) | SaaS product admin. Cross-shop access — dekh sakta hai sab shops ka data (products, bills, profiles). Manually assign hota hai (self-signup se nahi banta). |
| **Owner** (`owner`) | Shop owner — **default role on every new signup**. Auto-create apni shop milti hai. Full access: categories, products, billing, settings, reports, **staff mgmt (add/delete staff, scoped to own shop)** |
| **Staff** (`staff`) | Employee added by owner. Billing only (scan → sell → print), view products & stock; **no staff management access** |

### Role Assignment Flow
- **New signup → automatically `owner`** + apni shop auto-create (DB trigger `handle_new_user` karta hai).
- **Owner adds staff → `staff`** with owner's `shop_id` (via `SignUpRequested(role:'staff', shopId)`).
- **`super_admin` → manual only** (koi self-signup path nahi).

---

## Tech Stack Changes

| Component | Current | New |
|-----------|---------|-----|
| **Database** | Supabase (cloud) |
| **Auth** | Supabase Auth |
| **Real-time** | None | Supabase Realtime |
| **Scanner** | mobile_scanner (✅ already supports QR + barcode) | Same |
| **QR Gen** | pretty_qr_code (only for UPI) | pretty_qr_code (extend for products) |

---

## Target Platforms
- Android (primary)
- iOS (secondary)

## Constraints
- Supabase required for real-time multi-user
- Thermal printer via Bluetooth (ESC/POS)
- ₹ currency, Indian market
