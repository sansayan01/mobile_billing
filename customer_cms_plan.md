# Customer CMS — Final Implementation Plan (v1)

**Date:** 2026-08-21
**Owner decision:** Jerry (agent) picks all design calls; user reviews after.
**Scope locked:** name + phone ONLY (no email/address/notes). Full linkage to
bills, warranty claims, and due payments via `customer_id`.

---

## 1. Data Model (2 migrations — unavoidable, FK needed)

### Migration 1 — `customers` table
```sql
create table customers (
  id uuid primary key default gen_random_uuid(),
  shop_id uuid not null references shops(id) on delete cascade,
  name text not null,
  phone text not null,
  created_at timestamptz not null default now(),
  unique (shop_id, phone)
);
create index customers_shop_phone_idx on customers (shop_id, phone);
create index customers_shop_name_idx on customers (shop_id, name);
```
**NOTE — RLS decision:** Repo convention = business tables (products, bills,
due_payments, warranty_claims) have **NO RLS**; shop isolation is enforced in Dart
via `_resolveShopId()` + `.eq('shop_id', effectiveShopId)` (verified in
product_repository_impl / due_payments_repository_impl). Only `profiles` has RLS.
→ `customers` will follow the SAME convention: **no RLS**, Dart-side shop filtering.
This stays consistent and avoids breaking queries with a misconfigured policy.

### Migration 2 — link existing + future rows
```sql
alter table bills add column customer_id uuid references customers(id) on delete set null;
alter table warranty_claims add column customer_id uuid references customers(id) on delete set null;
-- Backfill: match old free-text phone to customers.phone within same shop
update bills b set customer_id = c.id
  from customers c
  where b.customer_phone = c.phone and b.shop_id = c.shop_id and b.customer_id is null;
update warranty_claims w set customer_id = c.id
  from customers c
  where w.customer_phone = c.phone and w.shop_id = c.shop_id and w.customer_id is null;
create index bills_customer_idx on bills (customer_id);
create index warranty_customer_idx on warranty_claims (customer_id);
```
**Why FK + backfill:** avoids duplicate-data drift; old bills/warranties now show in
customer history. `on delete set null` = safe (deleting a customer keeps the bill).

### Phone normalization (Dart helper, shared)
`normalizePhone()` strips spaces, converts `+91`/`0091` → leading `0`, keeps 10-digit.
Applied BOTH at customer-add and at billing/warranty capture so links always match.

---

## 2. Architecture (mirror `due_payments` — Clean Arch)
```
lib/features/customer/
  domain/
    entities/customer.dart
    repositories/customer_repository.dart
  data/
    models/customer_model.dart
    repositories/customer_repository_impl.dart
  presentation/
    bloc/  customer_bloc.dart / customer_event.dart / customer_state.dart
    pages/ customer_list_page.dart, add_customer_page.dart, customer_detail_page.dart
```

## 3. Features / Screens (v1)
1. **Customer List** — all customers (shop-scoped), search by name OR phone.
   Reuse existing search UX pattern (like product/dashboard).
2. **Add Customer** — name + phone form. Validates: non-empty name, valid 10-digit
   phone (after normalize), unique per shop (Dart check + DB unique constraint as guard).
3. **Customer Detail** — history tabs/sections:
   - **Bills** (purchase history, from `bills` where customer_id)
   - **Due balance** (from `due_payments` linked via bill→customer)
   - **Warranty claims** (from `warranty_claims` where customer_id)
4. **Billing checkout light-link** — when typing phone at checkout:
   - Look up `customers` by normalized phone (shop-scoped).
   - If match → show name autocomplete; selecting sets `customer_id`.
   - **If NO match → auto-create customer on bill save** (name + normalized phone from the
     checkout fields), then link its `id` as `customer_id`. So a customer never has to be
     pre-added in the Customers page; checkout creates them on the fly.
   - Falls back to free text only if name+phone both empty.

## 4. Explicitly OUT of scope (v1)
- Edit / Delete customer (added later; delete needs soft-delete + orphan policy)
- Email / address / notes / tags / avatar / loyalty / campaigns
- Separate WhatsApp field (phone = WhatsApp)
- Bulk import

## 5. Navigation & DI
- `get_it`: register `CustomerRepository` + `CustomerBloc`
- `go_router`: `/customers` (list) + `/customers/add` + `/customers/:id`
- Drawer: "Customers" item (all roles) + Dashboard quick-action tile

## 6. Build Order
1. Migration 1 (customers table + RLS + indexes) → apply
2. Migration 2 (bills/warranty customer_id + backfill) → apply
3. `normalizePhone()` helper (shared util)
4. `Customer` entity + `CustomerModel`
5. `CustomerRepository` + `CustomerRepositoryImpl` (Supabase, shop-scoped)
6. Bloc (LoadCustomers, SearchCustomers, AddCustomer, GetCustomerDetail)
7. Customer List page
8. Add Customer page
9. Customer Detail page (bills + dues + warranty queries)
10. DI + routes + drawer + dashboard tile
11. Billing checkout light-link (autocomplete by phone → set customer_id)
12. `flutter analyze` → 0 errors → hot restart w8:p9 → docs + graphify

## 7. Verify (device)
- Add customer → appears in list → search by name & phone works
- Open detail → bills/dues/warranty (empty OK for new) show
- Checkout: type existing phone → autocomplete → selects → bill saved with customer_id
- RLS: other shop's customers not visible

## 8. Risks & Prevention (locked in)
| Risk | Prevention |
|------|-----------|
| Duplicate customer (same phone) | `unique(shop_id,phone)` + Dart pre-check |
| Phone mismatch `+91` vs `0...` | `normalizePhone()` at every capture point |
| Delete orphans bills | FK `on delete set null` (no cascade) |
| Old bills not in history | Migration 2 backfill by phone |
| Slow search on many rows | Indexes on phone + name |
| Cross-shop leak | Dart-side `_resolveShopId()` + `.eq('shop_id')` (matches repo; no RLS on business tables) |
