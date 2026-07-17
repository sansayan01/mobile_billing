# Phase 2 Plan

## 2A — Categories (New Feature)
Full CRUD, Clean Architecture.

Files to create: category entity, repo interface, use cases, model, repo impl, bloc (event+state), pages (list, add/edit)

## 2B — Product Expansion
- Entity: add category_id, location, description, image_url, qr_data fields
- Model: match entity + Hive fields
- Repository: update Supabase queries for new fields
- Add/Edit pages: category dropdown, location, description, stock
- QR generator page: generate QR for any product
- Location feature: shelf/rack CRUD

## 2C — Billing Enhanced
- Discount (₹ or %)
- Grand total override
- Save bill to Supabase (bills + bill_items tables)
- Billing bloc: new events/states
- Checkout UI: discount field, total override
