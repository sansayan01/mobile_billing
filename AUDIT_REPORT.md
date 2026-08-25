# 🔍 FULL APP AUDIT REPORT — flutter_billing_app
**Date:** 2026-08-25 · **Method:** 6 parallel read-only audit agents + orchestrator verification
**Scope:** Navigation/DI, Feature wiring (all 16 features), Flutter correctness, Theme/UX, Platform/Data layer
**Raw findings:** ~315 → **~270 unique** (deduped, false positives removed)

---

## 📊 EXECUTIVE SUMMARY

| Severity | Count | Meaning |
|---|---|---|
| 🔴 CRITICAL | 6 | Money-corruption / crash-in-normal-use / release-build-dead |
| 🟠 HIGH | 38 | Feature broken or crashes in edge cases |
| 🟡 MEDIUM | ~95 | Degraded UX, leaks, perf, silent failures |
| ⚪ LOW | ~130 | Hygiene, dead code, polish |

**App compiles + analyzes 0 issues + core flows work** — ye structural/logic bugs hain jo specific paths pe trigger hote hain.

---

## 🔴 P0 — CRITICAL (pehle ye fix karo)

### C1. Percentage discount = financial data corruption
`billing_bloc.dart:390` — `discountIsPercentage=true` pe `discount=10` (sirf number) save hota hai, flag ke bina. Har consumer (report_repository_impl:510 `grandTotal = total - discount`, bill_history, dashboard) usko **₹10 samajhta hai**. 10% discount wale bills ke reports **galat revenue** dikhaate hain.

### C2. Staff add = OWNER KI SESSION HIJACK
`add_staff_page.dart:48-56` + `auth_repository_impl.dart:86-94` — staff add karne pe `SignUpRequested` shared AuthBloc pe chalta hai → `supabase.auth.signUp()` **owner ki session ko staff session se replace** kar deta hai. Owner silently staff ban jata hai, `/staff` guard use bahar phenk dega. Page ka listener ise "success" samajh ke pop karta hai.

### C3. Edit Product crash (category delete ke baad)
`edit_product_page.dart:291` — `cats.firstWhere((c) => c.id == _categoryId)` **bina orElse** — product ki category delete ho chuki ho to `StateError` crash. Normal flow: category delete → purana product edit.

### C4. Due Payments infinite reload loop
`due_payments_page.dart:204-212` + bloc — `successMessage`/`error` kabhi clear nahi hote (copyWith null = no-op). Listener har `isLoading` toggle pe non-null message dekh ke `LoadDuePayments` re-fire karta hai → **infinite query loop + repeating snackbars**.

### C5. Due search crash (uuid ilike)
`due_payments_repository_impl.dart:47-50` — search me `id.ilike.%$term%` — **uuid column pe ilike Postgres error** (`operator does not exist`) → koi bhi search poori list load fail kar deta hai.

### C6. Release APK me INTERNET permission nahi
`android/app/src/main/AndroidManifest.xml` — INTERNET sirf debug/profile manifests me hai. **Release build me Supabase kuch nahi karega.** (Debug me chalta hai isliye abhi tak pakda nahi gaya.)

### ⚠️ VERIFY (agent claims, mere tests se resolve)
- ~~Import paths CRITICAL~~ → **FALSE POSITIVE** (verified: analyze 0 issues, app runs — Dart resolver handle karta hai)
- `bills.item_count` kisi migration me nahi (001–018 me absent) lekin bills save ho rahe hain → **live DB manually patched** = **migration drift**: fresh DB rebuild pe billing tootega. Fix: migration file add karo.

---

## 🟠 P1 — HIGH (feature broken / edge-case crash)

### Money & Bills
1. `billing_bloc.dart:603-606` — Paid amount field clear karne pe purani value stick (copyWith null-gap) → **galat payment_status/due save**
2. `billing_bloc.dart:227-233` — Discount clear nahi hota (same null-gap)
3. `billing_bloc.dart:235-240` — Manual total override clear nahi hota — discount silently ignore
4. `billing_bloc.dart:385-447` — Bill save **non-atomic** (bills→items→stock→log loop, no transaction) — mid-failure = partial bill + galat stock
5. `checkout_page.dart:186-195` — Shop loaded na ho to bill save hota hai par receipt skip **silently**
6. `billing_bloc.dart:105-118` — Stale error har state change pe re-toast (copyWith null-gap)
7. `checkout_page.dart:186-195` — Customer "Clear" kaam nahi karta (null-gap) — cleared name/phone phir bhi save

### Auth/Staff
8. `auth_gate.dart:39-41` — Verification page har 3s splash-flash loop (timer kill/remount cycle)
9. `staff_repository_impl.dart:49-63` — Staff delete sirf profiles row — **auth user zinda** → deleted staff login kar sakta hai
10. `staff_list_page.dart:305-311` — Owner **khud ko delete** kar sakta hai (no self-guard)
11. `auth_repository_impl.dart:211-228` — Google OAuth 1s sleep + poll — race se working login bhi fail bolta hai (UI button anyway missing — dead path)
12. `auth_repository_impl.dart:222-228` + login pages — **Google login button kahin nahi** — poora OAuth path dead

### Reports/Data
13. `dashboard_page.dart:58` + reports — **saara analytics sirf page:1 (20 bills)** — busy din ka revenue/trend/top-products **galat**
14. `bill_history_page.dart:396` — Load More search/filter **lose** kar deta hai — unfiltered bills filtered list me mix
15. `report_repository_impl.dart:507-520` — Bill edit pe amount_paid/due/status **recalculate nahi** — paid bill edit upar → customer invisibly owe
16. `shop_repository_impl.dart:64-74` — **Shop save sirf Hive me** — Supabase update kabhi nahi → staff phones ko owner ke edits kabhi nahi milte, uninstall = data gone
17. `shop_repository_impl.dart:40-51` — Cloud fallback hardcoded '' fields — reinstall pe shop details blank
18. `customer_detail_page.dart:62-73` + warranty repo — **customer_id kabhi claim me write nahi hota** → per-customer warranty history hamesha empty
19. `printer_bloc.dart:120-125` — **Test print fake success** (not connected pe bhi scanSuccess emit)
20. `bill_detail_page.dart:1169-1173` — **Void bill = TODO**, phir bhi "Bill voided" success dikhata hai
21. `realtime_service.dart:76-83` — DELETE events `oldRecord.shop_id` padhte hain, REPLICA IDENTITY FULL nahi → **cross-device delete sync dead**

### Crashes (edge)
22. `edit_product_page.dart:291` — (C3 dekho)
23. `receipt_preview_page.dart:137` — `_receiptKey.currentContext!` force unwrap — first-frame tap = crash
24. `due_payments_page.dart:415` — `billId.substring(0,8)` length guard nahi — RangeError
25. `product_bloc.dart:144-150` — realtime payload cast try-block ke bahar — uncaught zone exception
26. `main.dart:80` — `createRouter()` build ke andar — **theme toggle = poori navigation stack reset** + router leak
27. `main.dart:33,48,80` — **AuthBloc factory = 3 instances** (auth-stream orphan, UI bloc, router bloc alag-alag) — remote logout/role-change pe router refresh kabhi nahi

### Routes (dead features)
28. `/staff/add` route defined, **kahin se push nahi hota** — staff add button missing (staff_list me FAB hai? verify — agent bola AddStaffPage unreachable)
29. `/customers/add` — **unreachable** — customer creation feature dead

### Misc
30. `printer_helper.dart:282-285` — `codeUnits` se ESC/POS bytes — **₹ + Hindi names garbage print** hote hain
31. `csv_export_import.dart` — UTF-8 BOM missing → Excel mojibake; import me BOM strip nahi → **saare rows silently drop**
32. `printer_helper.dart:208-233` — 58mm hardcoded — 80mm printer pe receipt aadha
33. `add/edit_product_page.dart` + `product_list_page.dart:576` + `receipt_preview_page.dart:187` — **await ke baad setState/context bina mounted guard** (6+ spots) — navigation during async = crash
34. `home_page.dart:372` + `checkout_page.dart:1029` — `state as Authenticated?` unsafe cast (AuthLoading pe TypeError)
35. `printer_helper.dart:55-68` — ek bhi permission deny (location) → printer scan hamesha fail, recovery path nahi

---

## 🟡 P2 — MEDIUM (~95, grouped)

### Silent failures (24 empty catches)
- `_resolveShopId()` **saare 6 repos me** fail → query **bina shop filter** chalti hai (RLS hi bachata hai — defense-in-depth gayab exactly jab zaroorat ho)
- `_logAudit()` fail silent (audit trail gaps), image upload fail → product bina image + zero feedback, theme/nav cubit Hive fails, realtime errors swallowed

### UX bugs
- Checkout/home Add-Product dialogs: load fail pe **eternal spinner** (`isLoading=false` without setDialogState)
- 8 search fields **no debounce** (har keystroke = Supabase query/setState) — bill_history, due_payments, customers, category, staff, low_stock, product_list
- `edit_product_page.dart:294` — build ke andar `TextEditingController(text:)` — har rebuild naya controller (cursor reset + leak)
- 15+ dialog controllers **never disposed** (checkout, bill_detail, warranty, due_payments...)
- Warranty submit: dialog pop + success **result se pehle**; fail pe poori list error-screen replace
- Damaged: success snackbar 2-3× repeat; undo double-tap race
- `report_repository_impl.dart:76-108` — search pagination offset filter se PEHLE — page 2 misaligned
- `reports_home_page.dart:24-28` — "This Month Revenue" shared bloc ke leftover data pe depend — navigation history pe galat number
- `bill_detail_page.dart:77-87` — reprint me shop header/footer **blank hardcoded**
- Overpayment → negative due_amount persist
- `printer_bloc.dart:42-57` — auto-connect first paired device = **headphones printer ban sakte hain**
- `app_validators.dart:15-20` — 'Infinity'/'NaN' price validation pass → Postgres raw error

### Security/DB
- `supabase_client.dart` — **anon key + URL hardcoded** source me (--dart-define hona chahiye)
- `010_add_warranty_fields.sql` — warranty_claims RLS `USING(true)` — **cross-shop read/write** (Dart filter hi bachata hai), DELETE policy missing
- `018_customers_rls_policies.sql` — `shop_id::UUID` cast TEXT column pe — bad value = SELECT break
- `016 vs 017` migrations contradictory (customers do baar different shape)
- realtime: server-side filter param missing (har shop ke events device aate hain), reconnect handling nahi, `InitRealtime` login se pehle shopId=null capture

### Theme/UX (v3 violations)
- **Drawer profile header: white text on LIME** (~1.35:1!) — `app_drawer.dart:328-388` → onAccent chahiye
- **Quick-action FABs (2 jagah): white icon on lime gradient** — `app_bottom_nav.dart:116`, `quick_actions_panel.dart:250` → onAccent
- White fg on success/info/errorDark solid buttons dark mode me 1.6-3:1 (10 spots: warranty, product_detail, qr_gen, mark_damaged, product_list, bill_detail, category, low_stock)
- `audit_timeline` RefreshIndicator + spinner raw lime on light
- Checkout qty steppers **26×26dp** (billing core flow!) — 48dp chahiye; category swatches 36dp
- `receipt_preview_page.dart:503` — bottom bar me SafeArea(top:false) missing
- `text_styles.dart` — 17 styles v2-era hardcoded greys (single-source tokens se alag)
- `glass_card.dart:40` — v2 navy `#1A1A2E` tint (v3 `#151C2C` hona chahiye)
- 57 off-scale radii (checkout me 11), ~520 raw fontSize bypasses (23 files >5)
- `darkTextTertiary #6B7688` on elevated ≈3.4:1 — small meta text me risky

### Perf
- CSV import N products = N× full `LoadProducts()` reload storm
- `_checkDuplicate` har keystroke pe — duplicate dialog spam
- damaged list: N+1 profiles queries per load
- `product_bloc.close()` shared RealtimeService singleton **dispose** kar deta hai
- Double realtime channels products pe (billing_bloc + RealtimeService)
- `ValidateStock` + submit dono jagah validation (double network)

---

## ⚪ P3 — LOW (~130, brief)
- Dead code: Google OAuth UI-path, `auth_gate.dart` unreferenced, `GetProductsByCategoryUseCase`, `GenerateQrCode` event, warranty `submitSuccess/updateSuccess`, audit `LoadEntityAuditLogs/LogAuditAction`, due `getTotalPendingDue`, damaged `getTotalDamageLoss`, `Unauthenticated.message`
- Unreachable routes: `/staff/add`, `/customers/add` (P1 #28-29)
- json_serializable + json_annotation unused deps; sdk lower bound loose
- Image.network: loadingBuilder kahin nahi (6 spots)
- Raw exception text users ko (`Failed to save bill: $e` etc. — 8 spots)
- `edit_product` barcode edit → qrData stale; `lastBillId` null → random UUID QR
- Legacy BLUETOOTH permissions maxSdkVersion-gated nahi; deprecated iOS bluetooth key
- Fixed CSV filenames (overwrite), email regex lax, `return_` enum ugly-but-works
- 30 minor spacing oddballs (1px/3px/5px/7px/9px), 14 shadows >20 blur
- super_admin `/staff` guard contradiction (RPD intent verify)
- shop_details: doosre page ke LoadShop se adhoore edits udd jaate hain

---

## ✅ JO SAHI HAI (verified clean)
- Checkout extras ↔ ReceiptPreview ↔ router unpack — exact match
- Billing ke saare 19 events handled; category CRUD full loop; stock adjust → audit → refresh
- Model↔column mapping 10 tables verified (snake_case sab sahi)
- Saare repo interfaces ke impls match
- print/debugPrint zero; ListView unbounded zero; listener leaks zero
- Supabase init before runApp ✓; keystore gitignored ✓; iOS camera/BT descriptions ✓
- Migration cross-check: products/warranty/stock/customers/audit columns match (sirf item_count drift)

---

## 🎯 RECOMMENDED FIX ORDER
1. **C6** INTERNET permission (1 line — release build dead iske bina)
2. **C2** Staff session hijack (service-role RPC ya signOut/signIn dance — architecture decision)
3. **C1** % discount persistence (discount_type column ya amount pre-compute)
4. **C3+C4+C5** crashes/loops (firstWhere orElse, due bloc clear flags, uuid cast hatao)
5. **#27+26** AuthBloc singleton + router memoize (2 line fixes, bade bugs)
6. **#13-15** analytics correctness (page size ya server-side aggregation)
7. **#16-18** shop cloud sync + warranty customer_id write
8. copyWith null-gap family (#1-3, #7, Product.copyWith) — ek saath pattern fix
9. mounted guards + controller disposals (batch)
10. Theme P2: drawer header + FAB whites (5 min), phir baaki
