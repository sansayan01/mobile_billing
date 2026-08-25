# Memory — Session Log & Context

## Current Session: 2026-08-25 — APK SIZE 77MB → 26.5MB ✅
User: APK 30MB ke andar chahiye. FIX: `flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/symbols` — fat APK (saare ABIs ek saath) se split ABIs: arm64-v8a **26.5MB** (modern phones — primary), armeabi-v7a 22.7MB (purane phones), x86_64 29.1MB (emulator). Obfuscation se Dart code minify + debug symbols `build/symbols/` me (crash decoding ke liye preserve). DWARF warning (--strip) minor, ignore. Play Store publish karna ho to `flutter build appbundle` (.aab) — Play khud per-device APK deta hai. BUILD COMMAND yaad rakho: ye wala full command hi use karna aage se.

## Previous Session: 2026-08-25 — RELEASE APK BUILD FIXED ✅
`flutter build apk --release` fail ho raha tha: **icon tree-shaking** — dynamic `IconData(cat.iconCodePoint, fontFamily: 'MaterialIcons')` release me allowed nahi (const chahiye). FIX: dialog ki `_categoryIcons` const list ko public `categoryIcons` banaya + category_list_page me `_categoryIcon(int codePoint)` helper (registry lookup + `Icons.category_rounded` const fallback) — 3 usages replace. Dialog preview me bhi `firstWhere` const lookup. LESSON: **DB-stored icon codepoints ke liye HAMESHA const registry lookup use karo** — `IconData(codePoint)` debug me chalta hai par release build fail karta hai (ya `--no-tree-shake-icons` flag, par APK badi). RESULT: ✓ `build\app\outputs\flutter-apk\app-release.apk` (77.1MB), fonts tree-shaken (MaterialIcons 1.6MB→33KB). Kotlin/Gradle plugin warnings ignore kiye (plugin-level, non-blocking).

## Previous Session: 2026-08-25 — CATEGORY PAGE REDESIGN (ui-ux-pro-max skill) ✅
Complete card redesign using skill principles, app ke existing dark+lime tokens ke saath consistent: (1) **Tap = primary action** — card tap ab Products ko category-filter ke saath kholta hai (pehle tap normal mode me DEAD tha — UX gap). (2) GestureDetector → Material+InkWell — proper press ripple + accessibility. (3) 2 always-visible icon buttons (edit/delete) → ek `PopupMenuButton` overflow (⋯) — row noise kam, delete swipe se bhi available. (4) Icon box: 56px gradient+glow → 48px flat tinted square (flat/clean direction). (5) Info layout: name + EK meta row (count pill + description inline, pehle 3 alag lines). (6) Empty state: 3 nested tweens → 1 subtle fade+rise (excessive-motion rule). (7) Stats card glow toned down (alpha 0.4→0.25, blur 20→14), radius 24→20 (consistent elevation scale). (8) Touch targets 40px→44px (overflow button). Skill note: design-system search generic output deta hai (serif fonts etc.) — app ki existing design language priority, sirf principles apply kiye. `dart analyze` → No issues.

## Previous Session: 2026-08-25 — CATEGORY PAGE UI POLISH ✅
User: "UI sahi nahi lag raha" (screenshot nahi diya). Code-audit se mila: Top Categories chips ka box `height: 42` + `easeOutBack` scale (~1.1x overshoot) → entrance pe chips clip hoti thin. FIX: height 48 + `Transform.scale(alignment: center)` taaki overshoot symmetric ho. NOTE: `alignment` Transform.scale ka param hai, TweenAnimationBuilder ka nahi (ek baar galat jagah lagaya, analyze pakad liya). Icon/color data safe hai — model fromJson null → defaults (0xe559 / 0xFF6750A4). User se exact issue screenshot ke saath poochna baaki hai — agar aur UI complaint aaye to screenshot maango.

## Previous Session: 2026-08-25 — CATEGORY PAGE AUDIT + FIXES ✅
Audit findings + fixes: (1) **Silent delete failure** — listener sirf success pe snackbar dikhata tha, error (jaise FK-restricted delete) pe kuch nahi → error feedback bhi add kiya. (2) **Bulk delete N-reloads/N-snackbars** — naya `DeleteCategoriesBulk(ids)` event: loop deletes, EK success message ('N categories deleted', partial-fail info ke saath), EK reload. Page ab single event dispatch karta hai. (3) **`resolvedShopId!` null crash** — deleteCategory repo me guard + friendly 'Shop not found' failure. (4) List bottom padding 120→144 (floating nav clearance, standard). Verified theek: Top Categories tap → FilterByCategory → /products (product_list initState LoadProducts dispatch NAHI karta, filter persist hota hai); dialog controllers disposed; Dismissible confirm-await pattern sahi hai. `dart analyze` (category) → No issues.

## Previous Session: 2026-08-25 — APP-WIDE TIMEZONE SWEEP ✅⚡
Daily sales fix ke baad poore app ka `toIso8601String()` grep audit — saare tz-less DB writes/reads fix kiye: (READS) audit_repo gte/lte, damaged_products_repo gte/lt → `.toUtc()`. (WRITES — ye sabse bada tha: DateTime.now() local tz-less string Postgres UTC maan leta tha → IST timestamps +5:30 shift store ho rahe the) billing_bloc bill `created_at`, report_repo delete/adjust `now` (2 jagah), damaged_products `created_at`, product_repo `updated_at`, stock_repo `created_at`, warranty_repo `created_at` + `updated_at`, auth_repo `updated_at`. Models ke toJson (Hive/local cache) untouched — symmetric round-trip, theek hai. FINAL STATE: `grep toIso8601String | grep -v toUtc` → sirf model files; `dart analyze lib` → **No issues**. RULE: DB me jaane wala HAR DateTime `.toUtc().toIso8601String()`, DB se aane wala HAR timestamp `DateTime.parse(x).toLocal()`.

## Previous Session: 2026-08-25 — DAILY SALES FINAL AUDIT (stats accuracy) ✅
2 more problems fixed: (1) **Stats sirf pehle 20 bills pe** — `LoadBillHistory` default `limit: 20`, daily_sales page bina limit call karta tha → payment split / best selling / heatmap 20+ bills wale din pe galat. FIX: page ab explicit `limit: 200` pass karta hai. (2) **Silent query failures** — full-screen error sirf `dailySales == null` pe dikhta tha; salesRange/billHistory fail hota to koi error nahi (₹0 bug isliye invisible tha). FIX: `hasPartialError` banner (error + dailySales != null) — inline red banner with Retry button, body ab Column [banner?, Expanded(RefreshIndicator)]. NOTE: edit karte waqt ek baar bracket mismatch hua, analyze se pakda aur fix — lesson: multi-nesting edits ke baad hamesha `dart analyze` turant chalao. `dart analyze` → No issues.

## Previous Session: 2026-08-25 — PERIOD REVENUE ₹0 ROOT CAUSE FOUND ✅⚡⚡
User: "Period Revenue / Total Bills 0 kyun aa raha hai" (salesRange empty jabki dailySales ₹66 theek). **REAL ROOT CAUSE**: `getSalesRange` me query chain `.gte().lt().order('created_at') as dynamic` ke BAAD `.eq('shop_id')` lag raha tha. Supabase rule: **transforms (order/limit/range) hamesha LAST** — `.order()` PostgrestTransformBuilder return karta hai jisme `.eq()` NAHI hota. `as dynamic` cast compile error chhupa raha tha → runtime NoSuchMethodError → try/catch swallow → `Left(failure)` → salesRange silently EMPTY. Isliye getDailySales (no order, filters only) kaam karta tha par getSalesRange nahi. FIX: `.eq('shop_id')` ko `.order()` se pehle move kiya, order ab await pe. AUDIT kiya — repo me baaki sab queries (getBillHistory range+order, lowStock order, stockMovements order, bill_items order) me eq-pehle-order-baad pattern already sahi tha. LESSON: **`as dynamic` on Supabase query chains is DANGEROUS** — ye compile-time safety ko kill karta hai; order: filters → eq/gte → order/limit/range → await. `dart analyze` → No issues.

## Previous Session: 2026-08-25 — REPORT TIMEZONE BUG FIX (IST) ✅⚡
User report: daily sales stats galat dikh rahe the (header ₹0/0 bills jabki today sales ₹66/2). ROOT CAUSE FAMILY = **TIMEZONE**: (1) Repo queries local dates ko bare ISO string (`...T00:00:00.000`, no tz) me bhejte the — Postgres use UTC maan leta hai → "aaj" ka window 5:30 shift (IST me 00:00–05:30 ke bills galat din me). FIX: `getDailySales`, `getSalesRange`, `getBillHistory` (+1 aur occurrence) sab me `.toUtc().toIso8601String()`. (2) `DateTime.parse(created_at)` UTC string parse karta hai — `getSalesRange` day-bucketing + BillSummaryModel/StockMovementModel (fromJson + fromSupabaseRow, 4 jagah) me `.toLocal()` add — ab heatmap time-blocks, day grouping, bar-chart today-highlight sab local IST correct. (3) UX: 3 sequential bloc events me salesRange aane tak header ₹0/0 dikhata tha — `rangeLoading` flag + header me '…' placeholder. LESSON: **Supabase timestamptz ke saath HAMESHA `.toUtc()` bhejo, `.toLocal()` parse karo** — ye pattern poore app ke baaki repos (bills insert, warranty, stock) me bhi audit hona chahiye. `dart analyze` (report/) → No issues.

## Previous Session: 2026-08-25 — DAILY SALES PAGE AUDIT + 4 LOGIC FIXES ✅
Full audit of daily_sales_page.dart. FIXES: (1) **This Week/This Month toggle was COSMETIC** — `_loadData` hamesha 7-din range load karta tha (`from-6d`), Month select karne pe bhi same week data. Ab switch: month → `DateTime(year, month, 1)` (month-to-date), week/custom → 6d. Export bhi ab range respect karta hai. (2) Next-day arrow future dates pe le jata tha — `_isToday` getter + arrow disabled on today. (3) Payment Split me unknown payment methods (non cash/upi/card) silently drop ho rahe the — `otherCount` bucket + 'Other' legend row (conditional) + 4th donut color add kiya. (4) Bar chart `isToday` year compare nahi karta tha + month view me 30 bars ke ₹ labels overflow hote — year check add, month view me value sirf today+top bar pe, day-number labels har 3rd bar pe (fixed-height SizedBox placeholders se layout stable). Bonus: 'vs Yesterday' label ab actual comparison date dikhata hai (`vs 24 Aug`). Scroll bottom padding 96→144 (nav overlap, pehle wala fix). `dart analyze` → No issues.

## Previous Session: 2026-08-25 — CHECKOUT BOTTOM BAR/NAV OVERLAP FIX ✅
User screenshot: checkout pe floating nav Save Bill button ke upar overlap. NOTE: /scan/checkout `_fullScreenRoutes` me hai (nav hide hona chahiye) — par screenshot me nav DIKH raha tha, matlab AppShell ka routerDelegate-based isFullScreen detection push-navigation me kabhi kabhi fail ho raha hai (REVISIT: reliable fix pending, maybe GoRouterState/listener approach). DART-ONLY DEFENSIVE FIX: checkout bottom bar (Cash/UPI + Grand Total + Save Bill) ko `SafeArea(top: false)` me wrap kiya — nav visible ho to extendBody-injected nav-height consume karke bar nav ke UPAR, nav hidden ho to sirf gesture inset (pehle ka `16 + viewPadding.bottom` manual padding → plain 16). Scroll content spacer 120 → 170 (taller bar ke peeche content na chhupe). `dart analyze` → No issues. PATTERN: koi bhi pinned bottom UI ho, SafeArea(top:false) hi universal fix hai — nav ho ya na ho dono handle.

## Previous Session: 2026-08-25 — UI POLISH BATCH (errors/images/radius/sync/glow) ✅
Scoped polish task, sab fixes done + `flutter analyze` (report/product/shop/premium_stat_card) → **No issues found**:
1. **Raw exception cleanup**: bill_detail_page print fail + products-load errors ab friendly generic messages (`$e` hata diya); add/edit_product pick-image error bhi clean ("Failed to pick image. Please try again."); qr_generator `_shareQr` ab async try/catch ("Could not open share options").
2. **auth_repository_impl**: `_extractErrorMessage` fallback ab `error.toString()` nahi — 'Something went wrong. Please try again.'; naya `_friendlyMessage()` known errors map karta hai (invalid credentials, email not confirmed, already registered, password length, rate limit, duplicate key, RLS).
3. **Image.network loadingBuilder** (subtle `surfaceContainerHighest` fill jab tak progress chal raha ho) added 6 jagah: qr_generator_page, product_list_page `_productImage`, product_detail_page hero image, damaged_products_page `_buildProductImage`, product_coverflow_view card, edit_product_page preview.
4. **checkout_page.dart**: saare `BorderRadius.circular(6)` → `circular(8)` (actual spots 6, task me ~11 bola tha par sirf itne hi the).
5. **shop_details_page.dart**: controller-overwrite bug fix — `_lastSyncedShop` snapshot; `_updateControllers` pehli ShopLoaded pe sab fill, baad me sirf changed fields sync (field-by-field compare) → user ke adhoore edits kabhi overwrite nahi honge.
6. **premium_stat_card.dart**: colored glow v3 flat spec — alpha .28→.12, blurRadius 24→12 (spread -2, offset same).
## Current Session: 2026-08-25 — WARRANTY CUSTOMER LINK WIRE + SUPABASE KEYS CENTRALIZED ✅
1. **Warranty claim customer_id wired end-to-end** (feature gap from audit): Claim sirf warranty_claims_page se banta hai (scan bill QR → getBillDetail → prefilled dialog). Wire path: BillSummary entity +`customerId` (nullable, ctor/copyWith/props) → BillSummaryModel (fromJson/toJson/fromSupabaseRow `customer_id`) → CreateWarrantyClaim event +customerId → WarrantyBloc `_onCreateClaim` usecase ko pass → page `customerId: bill.customerId`. Repo select already `'*, profiles(name)'` tha — column auto-fetch, koi select change nahi chahiye. Stale TODOs removed (page + repo impl). Ab bill-detail/customer_detail warranty history kaam karegi (bills.customer_id migration 017 me backfilled hai).
2. **Supabase keys centralized**: NEW `lib/core/config/app_config.dart` — `AppConfig.supabaseUrl/supabaseAnonKey` via `String.fromEnvironment('SUPABASE_URL'/'SUPABASE_ANON_KEY', defaultValue: current values)`. `supabase_client.dart` ab AppConfig use karta hai. Behavior same (defaults fallback), `--dart-define=SUPABASE_URL=...` override possible. Hardcoded keys sirf supabase_client.dart me the (main.dart sirf initialize() call karta hai).
3. `flutter analyze lib` → **No issues found!**

## Previous Session: 2026-08-25 — PRODUCT PAGE CART-BAR/NAV OVERLAP FIX ✅
User screenshot: products page pe "View Cart" card floating bottom-nav ke UPAR overlap kar raha tha. ROOT CAUSE: cart bar ka fixed `margin bottom: 74` — floating nav pill ki real height gesture-bar inset ke saath ~96-120px hoti hai (SafeArea + 6+62+4 + inset), isliye chhote/gesture phones pe overlap. FIX: standard app pattern (jaise add/edit_product Save bars) — cart Container ko `SafeArea(top: false)` me wrap kiya + margin `74 → 10`. extendBody nav-height ko bottom padding me inject karta hai, SafeArea use consume karke cart bar exactly nav ke UPAR baithta hai — kisi bhi device pe adapt. Purana "No SafeArea here" comment remove kiya (wo tab galat tha jab SafeArea + 74 margin dono the → double space). `dart analyze` → No issues.

## Previous Session: 2026-08-25 — PARALLEL AGENT FIX BATCH: PRODUCT/CATEGORY/STOCK/REALTIME ✅
Agent scope = product/**, category/**, stock/**, realtime_service.dart, billing_bloc.dart (sirf realtime channel section). `flutter analyze` (scoped) → **No issues found**.
1. **[CRITICAL] edit_product firstWhere crash FIXED**: category display ab `where().firstOrNull?.name` — deleted category pe crash nahi. Display controller `_categoryNameController` state field banaya (build ke andar wala leak fix), text postFrameCallback me sync hota hai.
2. Product.copyWith nullable-clear: `clearCategoryId/clearLocation/clearDescription/clearImageUrl` flags add kiye. edit_product _submit ab empty text pe clear flag pass karta hai (pehle null pass hone se clear kabhi nahi hota tha).
3. Mounted guards: add_product (_scanBarcode push ke baad, _pickImage ke teeno setState), edit_product (_pickImage), product_list (_bulkExport export ke baad setState + _scanQR).
4. Controller disposal: add/edit _showCategoryPicker searchController `.whenComplete(dispose)`; product_list _quickStock controller `.whenComplete(dispose)`; product_detail stock dialog quantity/note controllers `.then(dispose)`; edit category controller state field.
5. add_product duplicate-check: barcode TextFormField se `onChanged: _checkDuplicate` REMOVED — ab sirf scan + submit pe check.
6. CSV import reload storm FIXED: naya `AddProductsBulk` event (product_event.dart + product_bloc.dart `_onAddProductsBulk`) — batch insert ke baad EK LoadProducts; page loop hata ke single event bhejta hai.
7/16. Image upload fail: add+edit dono me uploadProductImage null return pe `AppFeedback.error('Image upload failed — saving without new image')` aur save continue (fallback = purana URL), save block NAHI hota.
8. Realtime: server-side filter `PostgresChangeFilter(eq, shop_id)`; DELETE payload me shop_id null ho to id-se-fetch verify (`_verifyDeleteShop`, unverifiable ho to forward — UUID globally unique); channelError/timedOut pe 5s retry timer (`_scheduleRetry`, dispose/unsubscribe pe cancel, `_disposed` flag). **billing_bloc ka alag 'products_changes' channel REMOVE** (+ `_subscription`/`_handleProductChange`/`_isProductInCart` + unused supabase_flutter import); `on<_ProductStockUpdatedEvent>` registration rakha (billing_event.dart untouched).
9. ProductBloc.close() ab `realtimeService.unsubscribe('products')` — shared singleton ko dispose() NAHI karta.
10. InitRealtime timing FIXED: `_subscribedShopId` tracking + `_ensureRealtimeSubscribed()` — InitRealtime auth-se-pehle chala to shopId null skip, phir pehle LoadProducts pe subscribe ho jata hai.
11. stock_repository_impl: getStockHistory + adjustStock lookup/update me shop_id filter; `as int` casts → `(as num?)?.toInt() ?? 0`.
12. product_repository_impl: _fromMap/fromJson defensive casts (barcode `?? ''`, stock/duration num→toInt); getCurrentStockBulk stock cast safe; updateProduct `.upsert({...})` → `.update({...}).eq('id')` (+shop_id eq scope, payload se shop_id/id hatae).
13. edit barcode change => qrData bhi new barcode se update in copyWith.
14. category_list Dismissible: confirmDismiss ab DeleteCategoryUseCase (di.sl) await karke result.isRight() pe hi true return karta hai; fail pe AppFeedback.error; onDismissed empty (reload confirmDismiss me hi); lint fix ke liye async gap ke baad `this.context`. Counts reactive: build me `context.watch<ProductBloc>()`, `_count(cat, products)` param-based.
15. coverflow: empty products pe `safeIndex = 0` guard (clamp(0,-1) ArgumentError).

## Current Session: 2026-08-25 — Realtime Service Compile Errors Fix ✅
`lib/core/realtime/realtime_service.dart`:
1. `filter` parameter in `onPostgresChanges` updated from string literal `'shop_id=eq.$shopId'` to `PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'shop_id', value: shopId)` matching Supabase client v2 API.
2. `VoidCallback` replaced with standard Dart `void Function()` in `_scheduleRetry` (undefined class fix).

## Current Session: 2026-08-25 — PARALLEL AGENT FIX BATCH: DUE/WARRANTY/DAMAGED/CUSTOMER FILES ✅
Agent scope = due_payments/**, warranty/**, damaged_products/**, customer/** (customer_list FAB dusre agent ka). `flutter analyze` (scoped 4 dirs) → **No issues found**.
1. **[CRITICAL] due_payments infinite loop FIXED**: bloc `_onLoadDuePayments`/`_onSearchDuePayments` ab load-start pe `clearError: true, clearSuccessMessage: true` (copyWith plain-null pass pe old value RAKHTA hai — yahi root cause tha). Page listener message consume karke naya `ClearDueMessages` event dispatch karta hai (LoadDuePayments dispatch hataya — collect success par bloc khud reload karta hai).
2. **[CRITICAL] due search uuid-ilike crash FIXED**: repo `.or()` se `id.ilike` REMOVED — ab sirf `customer_name.ilike + customer_phone.ilike`, term sanitize (`,()%*` strip).
3. due_payments_page `billId.substring(0,8)` → length>=8 guard. `RegExp(r'\\.$')` → `r'\.$'`.
4. due collectPayment race: comment-only (PostgREST me server-side increment nahi; RPC out-of-scope documented).
5. Warranty premature success FIXED: claim dialog ab BlocListener (bloc pre-captured) ke through sirf `submitSuccess` aane par pop+snackbar karta hai; fail pe dialog open rehta hai, error snackbar. Page builder full-error screen ab sirf `claims.isEmpty` (first-load) pe. Naya `ClearWarrantyFeedback` event stale flags sanitize karta hai (dialog open + consume ke baad). Submit button isSubmitting pe disabled + spinner.
6. warranty createClaim: repo/usecase/interface me optional `customerId` param added — insert map me sirf tab include hota hai jab non-null (PGRST204-safe). Caller skip + TODO kyunki BillSummary me customer_id field hi nahi (report feature dusre agent ka).
7. damaged successMessage repeat FIXED: load-start clear flags (due jaisa pattern). Undo double-tap race: IconButton `state.isMarking` pe disable + confirm-dialog ke baad `bloc.state.isMarking` re-check.
8. damaged N+1 FIXED: per-row `_resolveStaffName` queries hatao — sab created_by ids ek `.inFilter('id', staffIds)` profiles query me, map se resolve.
9. damaged defensive casts: `stock as int` ×2, `quantity_changed/previous_stock/new_stock as int?` → `(as num?)?.toInt() ?? 0`.
10. customer_detail FutureBuilders ×3: `snapshot.hasError` pe proper error message ('No records yet' nahi). customer_repo 23505 comment (unique index shop_id+phone dependency) + search `.or()` sanitize bhi.
11. Debounce 400ms: due_payments_page + customer_list_page search (`Timer` in State, dispose cancel). Controllers dispose: due amountController `.whenComplete`, warranty reasonController `.whenComplete` (+ `_claimDialogOpen=false`).

---

## STANDING RULE (2026-08-21, user-confirmed) — Use Graphify, Don't Full-Read Files ⚡
When investigating/understanding code (finding a symbol, tracing call paths, locating a
widget/method, understanding a feature's wiring), **DO NOT full-read files** — it wastes
tokens + time. Use graphify instead (fast, no LLM needed after build):
- `graphify explain "SymbolName"`  → node + neighbors plain explanation (e.g. `graphify explain "_buildProductTile"`)
- `graphify query "X"`             → BFS traversal around a symbol (add `--budget N` for more nodes)
- `graphify path "A" "B"`          → shortest call/data path between two nodes
- `graphify get_node <name>`       → specific symbol detail
Only read_file the EXACT small region once graphify tells you the file+line, then patch.
Graphify is already built/updated (graphify-out/). After each code change run `graphify update .`.

## STANDING RULE (2026-08-21, user-confirmed) — Post-change Hot Restart on Device ⚡
After ANY code change is complete:
1. `flutter analyze lib` → 0 errors FIRST.
2. **IMMEDIATELY hot restart the device** (before md/graphify): in same Herdr tab (w8:t8), the OTHER pane **w8:p9** is the user's phone running APK via **wireless debugging** (`flutter run` active, PID ~7139). Send capital `R` (Shift+R) via `herdr pane send-text w8:p9 \"R\"` to hot-restart. Do this right after analyze is clean so the USER can START TESTING immediately.
3. THEN update md files (memory.md etc) + `graphify update .` (background; user is testing meanwhile).
4. Logs check (w8:p9 read) allowed anytime for error/crash/error-handling investigation.

## Current Session: 2026-08-25 — Floating Nav Overlap Fixes (Stock Sheet + Checkout) ✅
1. **Stock adjust sheet clash FIXED** (product_list_page `_quickStock`): bottom sheet padding me `viewPadding.bottom + 84` add — ab sheet floating nav ke upar lift hoti hai.
2. **Checkout nav clash FIXED** (app_shell): `GoRouterState.of(context).matchedLocation` ShellRoute builder me `context.push()` (imperative match) ke saath stale ho sakta hai — isliye `GoRouter.of(context).routerDelegate.currentConfiguration.uri.path` use kiya. Ab `/scan/checkout` pe nav reliably hidden.
3. **Save Bill button** (checkout_page): bottom padding me `MediaQuery.viewPadding.bottom` add — gesture-bar safe.
`dart analyze` (3 files) → No issues.

## Current Session: 2026-08-25 — Product Page: View Cart Bar Height Fix ✅
product_list_page.dart bottomNavigationBar cart bar me `SafeArea(top:false)` wrapper REMOVED — wo system gesture-bar bottom inset card ki height me add kar raha tha (extra khaali lime space neeche). 74px bottom margin already floating nav clear karta hai, SafeArea redundant tha. `dart analyze` → No issues.

## Current Session: 2026-08-25 — PARALLEL AGENT FIX BATCH: AUTH/STAFF/CUSTOMER FILES ✅
Agent scope = main.dart, service_locator, routes, auth/**, staff/**, customer_list_page. `flutter analyze` (scoped) → **No issues found**.
1. **[CRITICAL] AuthBloc 3-instances bug FIXED**: service_locator me `registerFactory` → `registerLazySingleton`. Ab subscribeToAuthChanges (main()), BlocProvider, aur createRouter teeno ko EK hi AuthBloc milta hai.
2. **[CRITICAL] Router rebuild bug FIXED**: MyApp → StatefulWidget; `late final GoRouter _router = createRouter(di.sl<AuthBloc>())` state field pe. routerConfig ab `_router` (BlocBuilder sirf themeMode ke liye).
3. **[CRITICAL] Staff-add session hijack FIXED** (auth_bloc `_onSignUpRequested`): role=='staff' success par `_signOutAfterStaffSignup()` await hota hai → owner ki hijacked session sign-out → emit `Unauthenticated(kStaffAccountCreatedMessage)`. add_staff_page listener is message pe success snackbar + context.go('/login'). Known limitation comment documented (client-side admin API impossible). Race-guard bhi add: `_suppressStatusCheck` + `_statusToken` generation counter — concurrent CheckAuthStatus (SIGNED_IN se trigger) stale result se terminal state overwrite nahi kar sakta.
4. **/staff/add reachable**: staff_list_page me owner-only `FloatingActionButton.extended` (person_add_rounded) → `context.push('/staff/add')`.
5. **/customers/add reachable**: customer_list_page me FAB (AppColors.accent, person_add_rounded) → `context.push('/customers/add')`.
6. **Splash-flash loop FIXED**: auth_bloc `_onCheckAuthStatus` start ka `emit(AuthLoading())` REMOVED — sirf terminal states emit hote hain (silent refresh/poll se AuthGate splash flash band).
7. **Self-delete guard**: staff_list_page `_confirmDelete` current logged-in email match pe block + AppFeedback.error 'You cannot delete your own account'.
8. **Logout fold FIXED** (`_onLogoutRequested`): pehle logoutUseCase complete, phir fold — error→AuthError, success→Unauthenticated. `_isLoggingOut` re-entry guard.
9. **Mounted guards**: register/login/email_verification/add_staff listeners me `if (!mounted) return;` top pe.
10. **Phone param wired end-to-end**: SignUpRequested.phone → SignUpParams.phone → SignUpUseCase → AuthRepository(abstract+impl).signUp(phone:) → signUp metadata + `_ensureProfileRole` best-effort profiles update (RLS fail ho to silently ignore). Dart-only, koi migration nahi.

---

## Current Session: 2026-08-25 — PARALLEL AGENT FIX BATCH: BILLING FILES ✅
Agent scope = billing_bloc/state/event + checkout_page + home_page + receipt_preview_page (minimal-safe fixes, no refactor). `flutter analyze lib/features/billing` → **No issues found**.
1. **[CRITICAL] % discount corruption FIXED** (billing_bloc `_onSubmitBill`): DB `discount` column me ab ABSOLUTE amount save hota hai — `discountAmount = discountIsPercentage ? baseTotal * (discount/100) : discount`. Base = baseTotal (sum of item.total) — same base as totalAmount getter math + receipt preview calc. Pehle raw % value (e.g. 10) save ho raha tha = financial corruption.
2. **copyWith null-gap family completed**: state copyWith me `clearCustomerName`/`clearCustomerPhone` add (clearError/Discount/GrandTotalOverride/StockErrors/AmountPaid already the). Wiring: UpdateDiscountEvent(null)/UpdateGrandTotalOverrideEvent(null)/UpdateAmountPaidEvent(null) → clear; UpdateCustomerInfoEvent(dono null) → dono clear (checkout Clear button isse hi use karta hai); per-field typing safe (partial null = keep other field).
3. **Stale error clears**: interaction handlers (add/remove/qty/price/discount/type/override/payment/amountPaid/customerInfo/selectCustomer) ab `clearError: true` karte hain; `_onAddProductToCart` ka `error: null` (jo actually clear nahi karta tha — null-gap!) → `clearError: true`; submit success bhi error clear.
4. **checkout_page**: (a) qty steppers 26px → 44x44 SizedBox+Center touch targets; (b) shop not loaded pe receipt skip → AppFeedback.info 'Bill saved' fallback; (c) `(state as Authenticated?)` unsafe cast → `is Authenticated ? ... : null` pattern; (d) dialog controllers dispose via `.then()` (add-product search, edit-price, warranty duration) + customer picker searchCtl dispose after await; (e) random UUID on lastBillId null REMOVED — state.lastBillId direct pass (router `as String? ?? ''` handles null; QR auto-hides).
5. **home_page**: unsafe cast fix; searchController `.then(dispose)`; fetchProducts spinner-stuck fix (isLoading=false har path pe + dialogSetState callback capture — failure/shopId-null branches included); cart card price → `item.unitPrice` (custom-price edits ab reflect hote hain).
6. **receipt_preview_page**: `_receiptKey.currentContext!` force unwrap → null-check + 'Receipt not ready' graceful return; finally setState mounted-guarded; bottom bar SafeArea(top:false) wrap; print catch → clean message 'Print failed. Check printer connection.' (raw exception text removed); share catch → 'Failed to share receipt'; QR section billId empty pe already hidden (pre-existing guard).

---

## Current Session: 2026-08-25 — MASTER PROMPT: PREMIUM UI/UX TRANSFORMATION (Monex reference) 🚀

### Reference Direction LOCKED (user sent Monex fintech image + master prompt)
- **Midnight/near-black backgrounds** (#0A0F1A range), dark elevated surfaces, high-contrast white text
- **Lime/electric-green accent** (#C8F031 range) — sparing use, buttons/active states/highlights only
- **Big mono-style numerals** for money (IBM Plex Mono pairs with existing IBM Plex Sans — no new dep)
- Rounded surfaces (16-24), generous spacing, minimal noise, subtle depth
- Master prompt rules: features LOCKED, UI fully open, one page at a time, design system FIRST, graphify update after every sub-phase

### PHASE 0 — CODEBASE DISCOVERY ✅ (2026-08-25)
- **0.1 Structure**: Clean arch — `lib/core/` (theme, widgets×22, utils, navigation), `lib/features/` ×16 (auth, dashboard, billing, product, category, report, due_payments, damaged_products, warranty, customer, staff, shop, settings, audit, stock), `lib/config/routes/`. BLoC + get_it + go_router + Hive + Supabase.
- **0.2 Features (LOCKED list)**: Auth (email+Google, roles owner/staff/super_admin), Dashboard analytics (8 cards + fl_chart), POS billing (scan/cart/discount/UPI QR/thermal print/partial payment), Products (CRUD+image+CSV import/export+QR gen+dual view+bulk ops), Categories, Reports (daily sales, low stock, bill history+detail+edit, stock movement, audit trail), Due Payments, Damaged Products, Warranty claims, Customers CMS, Staff mgmt, Shop details, Settings (printer, theme toggle, nav style toggle).
- **0.3 Screens**: 31 pages (glob *_page.dart) + dialogs/sheets.
- **0.4 Navigation**: AppShell (drawer scaffold w/ static scaffoldKey) + NavigationCubit → bottomNav mode (floating glass pill + raised + button + quick-actions panel w/ Hero morph) OR drawer mode. Fullscreen routes: /scan/scanner, /scan/checkout, /scan/receipt-preview. Staff routes owner-guarded.
- **0.5 Existing UI**: Primary #6C63FF purple + teal #03DAC6, IBM Plex Sans, glassmorphism (blur 18-20), light+dark themes (ThemeCubit+Hive), tokens EXIST: app_dimensions.dart (spacing/radius/elevation/durations/touch), app_typography.dart (13 styles), app_feedback.dart, app_skeleton.dart, motion (fade+3% slide transitions). Weaknesses: purple/teal = generic AI palette, 179 hardcoded colors scattered, glassmorphism heavy, light theme lavender gradient dated vs reference.

**Phase 0 verdict**: Foundation strong (tokens/nav/feedback exist) — redesign = new color identity (midnight+lime) + numeric typography + surface system + page-by-page migration. NO structural rewrite needed.

### PHASE 1+2 — Reference Analysis + Design System v3 "MIDNIGHT LIME" ✅ (2026-08-25)
- Full spec design.md me documented (7 philosophy sections + 12 system sections). Key tokens:
  - Dark: bg #0B0F1A · surface #151C2C · elevated #1C2436 · modal #1A2233 · text #F5F7FA/#A8B3C5/#6B7688 · border white@10% · divider white@5%
  - Accent lime #C8F031 (+light #E4FF6A, dark #9FC414) — onAccent = #0B0F1A (midnight text ON lime)
  - Light: bg #F4F6F4 · surface white · text #101828/#5A6472/#98A2B3 · accent-as-text #55700A (lime on light = contrast fail, kabhi lime text on white nahi)
  - Semantic: success #34D399 · warning #FBBF24 · error light #E11D48/dark #F4586F · info #5AB8F0
  - Typography: IBM Plex Sans (UI, unchanged scale) + **IBM Plex Mono for money** (`AppMoneyText` balance32/metric22/row16)
  - Radius: card 20 · button/input 14 · sheet top 24 · pill full. Elevation: dark = flat (depth via surface steps), light = subtle.

### PHASE 3 — DESIGN SYSTEM IMPLEMENTATION ✅ (2026-08-25) — analyze 0 errors
- **NEW `lib/core/theme/app_colors.dart`** — AppColors semantic tokens (dark+light palettes, brightness helpers `bg(b)/surface(b)/textPrimary(b)/accentText(b)`, v3 gradients `lightGradient/darkGradient/gradientFor`)
- **`app_theme.dart` REWIRED (public API preserved)** — primaryColor=lime, secondary=info, errorColor=#E11D48; ColorScheme fromSeed+copyWith (onPrimary=midnight!); buttons lime+midnight fg, elevation 0, r14; FAB lime circle; cards r20 + hairline border (dark: elevation 0); inputs r14 focus accent; chips pill surfaceElevated; snackbars surfaceElevated+textPrimary (dark) / #101828+white (light); switch selected = lime track + midnight thumb; progress=accent; checkbox/radio accent; dialog modal r20; gradients v3. **CRITICAL: onPrimary ab midnight hai — koi bha bhi `onPrimary`/`primary` use kare, contrast sahi**
- **`app_typography.dart`** — `AppMoneyText` class add (IBM Plex Mono, static final pre-computed: balance/metric/row/sized helper)
- **`text_styles.dart`** — `_primary` + txnSeeAll purple #6C63FF → accentTextOnLight #55700A (light) / lime (dark)
- **6 white-on-primary patches** → `AppTheme.onAccentColor`: category_list (FAB + empty-state btn), home_page (checkout btn), bill_detail (notes save), product_list (FAB), scanner_page (permission btn + AppTheme import add)
- Intentionally NOT touched (semantic bg keep white): warranty approve/reject/resolve (green/red/blue), error buttons, product_detail +/- (green/red), add_edit_category (_selectedColor dynamic)
- **Global effect**: 100+ `AppTheme.primaryColor` refs = poora app ek saath lime identity me shift — pages FUNCTIONAL, per-page premium redesign Phase 7 me
- ⚠️ Known v2 remnants (Phase 7 per-page migrate): glassmorphism widgets (white glass tints), PremiumStatCard purple-ish defaults, hardcoded Color(0xFF...) ~170 spots, text_styles light-mode hardcoded #1A1A2E etc.

**NEXT: Phase 4 validation → Phase 5 LOCK → Phase 6 queue → Phase 7 Page 1 = Dashboard**

### PHASE 4+5 — VALIDATION ✅ + DESIGN SYSTEM LOCKED 🔒 (2026-08-25)
- flutter analyze lib = 0 errors (1 pre-existing info). Contrast verified: lime+midnight ~11:1, #55700A on light ~5.5:1, lime-on-light text FORBIDDEN (use accentText helper).
- Purple/teal remnants CLEARED: sales_trend_card (_primaryColor const → `_chartColor(isDark)` brightness-aware accent), payment_donut_chart fallback → slate #94A3B8, staff avatar palette purple → lime #C8F031, teal chip #00C9A7 → AppColors.info.
- **🔒 LOCKED**: AppColors + AppTheme v3 + AppMoneyText = single source of truth. Ab koi naya component inke bahar nahi — naya color/radius/spacing sirf token ke through.

### PHASE 6 — PAGE INVENTORY & REDESIGN QUEUE (31 pages, 2026-08-25)
Order (traffic × impact priority):
1. Dashboard `/` (8 analytics cards + greeting + quick actions) ← IN PROGRESS
2. Billing Home `/scan` (cart + inline camera)
3. Checkout `/scan/checkout` (payment + UPI QR + print)
4. Receipt Preview (customer-facing print/WhatsApp)
5. Products List `/products` (dual view + bulk)
6. Product Detail · 7. Add/Edit Product · 8. QR Generator · 9. Scanner Page
10. Reports Home · 11. Daily Sales · 12. Bill History · 13. Bill Detail
14. Low Stock · 15. Stock Movement · 16. Audit Timeline
17. Due Payments · 18. Damaged Products · 19. Warranty
20. Customers (list/detail/add) · 23. Categories · 24. Staff (list/add)
26. Shop Details · 27. Settings · 28. Login · 29. Register · 30. Email Verification
### PHASE 7 — PAGE-BY-PAGE REDESIGN
#### ✅ Page 1: DASHBOARD (2026-08-25) — analyze 0 errors, ALL 16 features preserved
- **New composition**: Compact header (greeting+name, flat) → LowStock banner → **_HeroSalesCard** (surface card r24: "TODAY'S SALES" label + ₹ total in IBM Plex Mono 34 w700 + divider + 3 sub-stats Bills/Avg/Discount w/ vertical hairlines, tap→/reports/daily-sales, fade+slide entrance) → **_NewBillButton** (full-width lime pill h54 r16, qr_scan icon, THE accent) → Quick Actions (muted textSecondary tiles) → This Week → Recent Txns → Payment Donut → Top Products → 30-Day → Inventory → Staff
- **dashboard_action_card.dart REWRITTEN v3**: DashboardActionCard + QuickActionTile = solid surface + hairline border (glass alpha gone), icon chips color@14%, entrance fade+slide 250ms / spring scale 400ms, title onSurface
- Quick tiles: sab muted `textSecondary` (rainbow khatam) — accent sirf NewBill pe
- `_sectionTitle`: 13 w600 ls0.5 textTertiary, padding horizontal 4
- GreetingHeader + PremiumStatCard ab dashboard se unused (files intact — reports_home still uses PremiumStatCard/DashboardActionCard = auto-v3 benefit)
- **LESSON**: current jaate waqt edit adhura chhod sakta hai — analyze pehle run karo resume pe, syntax error (`),` vs `);`) mila tha line 453
- **NEXT: Page 2 = Billing Home `/scan` (home_page.dart)**

#### 🎬 DASHBOARD MICRO-INTERACTIONS + STAGGER (2026-08-25) — ui-ux-pro-max skill driven
- User ne Framer Motion (motion-framer skill) dekha, chaha "same micro-interactions Flutter mei". Clarify kiya: Framer = React-only, par **concepts Flutter-native implement ho sakte**.
- **3 reusable widgets banaye** (`lib/core/widgets/`):
  - `staggered_fade.dart` — **StaggeredFade** = Framer variants cascade. 45ms/index delay, FadeTransition+SlideTransition (0.04 offset), transform-only (no CLS). Dashboard ke 14 sections ko index 0-13 diya → premium entrance.
  - `press_scale.dart` — **PressScale** = Framer `whileTap`. Listener onPointerDown/Up (InkWell ripple steal nahi karta), AnimatedScale 0.96 pressed → spring back. reduced-motion respect (`MediaQuery.disableAnimations`).
  - `animated_switcher.dart` — **AnimatedSwap** = Framer `AnimatePresence`. Crossfade+slide on key change.
- **Apply**: Hero card + New Bill btn + 7 Quick tiles = PressScale wrap; poore content column = StaggeredFade wrap. `_buildQuickTiles` me 7 inline QuickActionTile → `_quickTile()` helper (DRY, PressScale+route param).
- **Alignment fix**: `_sectionTitle` `horizontal:4` (cards se misaligned) → `left:4, bottom:2`. Raw SizedBox → AppSpacing tokens (lg16/xl24/md12) = 8dp rhythm.
- **Lint**: `prefer_const_constructors: false` add in analysis_options.yaml (StaggeredFade children = BlocBuilder/sectionTitle, genuinely non-const — noise suppress, no restructure). `press_scale.dart` unused `gestures.dart` import hata.
- **RESULT**: `flutter analyze` = **0 issues** (full project). Design system (Monex v3), haptics, splash, existing springs — intact.
- **LESSON**: micro-interactions = reusable widgets banao (PressScale/StaggeredFade), har page pe reuse karo. Framer concepts ≠ Framer lib for Flutter.
- **NEXT: Page 4 = Receipt Preview, ya in 3 widgets ko dusre pages pe propagate karo**

#### ✅ Page 2: BILLING HOME `/scan` (2026-08-25) — 0 issues, ALL 12 features preserved
- Scanner corners greenAccent → **AppColors.accent** (brand lime)
- Camera-off state hardcoded slate (#1E293B/#334155) → v3 midnight tokens (darkBg/darkSurfaceElevated/darkText*)
- TOTAL PRICE → `AppMoneyText.sized(20, w700, accentText(b))` — lime-on-light contrast fix
- Search dialog price → accentText(b); cart item cards → v3 surface+hairline border r14, price money font, shadow removed
- Untouched (logic): scanner controller, beep/vibrate/cooldown, permission flow, flash, search dialog fetch/filter/add, qty +/- (remove@1), Review Order bottomSheet + camera stop/restart, error listener, drawer-mode hamburger
- **NEXT: Page 3 = Checkout `/scan/checkout` (checkout_page.dart ~1000 lines)**

#### ✅ Page 3: CHECKOUT `/scan/checkout` (2026-08-25) — 0 issues, ALL 14 features preserved
- **CRITICAL FIX**: Save Bill button `foregroundColor: colorScheme.surface` (lime pe white = invisible!) → `AppColors.onAccent` + disabled states (accent@40% + onAccent@70%), spinner color onAccent
- **AppColors EXPANDED (v3 addition)**: `successText/warningText/infoText(b)` — light-mode-safe darker variants (#047857/#B45309/#0369A1), dark mode = base semantic colors
- SegmentedButton selected → accentSubtle bg + accentText fg; 6 primaryColor icons → accentText(b); search dialog price → accentText + money font
- Semantic chips v3: linked customer (success border + successText), will-match (warning), discount chip (successText@12% bg), Due chip (warningText@12% bg), stock warnings (error/warningText), warranty blue → infoText
- **Grand total ₹ → AppMoneyText.sized(24, w700)** — hero money moment
- Untouched logic: customer picker/clear, warranty dialogs, qty/editable price, Add More (pageContext scanner fix), discount ₹/% toggle, partial payment, UPI QR deep link, total override, ValidateStockBeforeBill flow, ClearCart on pop
- **NEXT: Page 4 = Receipt Preview (receipt_preview_page.dart)**

#### ✅ Page 4: RECEIPT PREVIEW (2026-08-25) — 0 issues, print/WhatsApp/Due/QR all intact
- Print + Done buttons: primary/surface (lime+white FAIL) → accent + onAccent
- Due chip orange.shade* → warningText@10% bg + border@35%; Paid → successText; Thank you → accentText
- QR white bg + WhatsApp #25D366 brand green KEPT (functional/brand, not stylistic)
- **NEXT: Page 5 = Products List (product_list_page.dart ~1300 lines, dual view + bulk)**

#### ✅ Page 5: PRODUCTS LIST + COVERFLOW (2026-08-25) — 0 issues, ALL 16 features preserved
- **product_list_page.dart (~25 spots)**: long-press menu icon chips (QR purple→accentSubtle, copy blue→info, damaged orange→warning, delete→error), delete dialogs → error+white, 5 snackbars → success/warning bg + onAccent text, **cart bar lime gradient (accent→accentDark) + onAccent text + money font + ViewCart midnight-on-lime**, low-stock pill (warning + onAccent active), hero search (glow removed, hairline border, accentText icon), scanner btn accent gradient, FilterChips accent+onAccent, tile selected border accent + price accentText, Dismissible success+onAccent, selection indicator accent+onAccent, desc-highlight → warningText@12% (theme-aware), _stockColor(context) brightness-aware, empty state accentSubtle
- **product_coverflow_view.dart (~15 spots)**: category dial selected accent+onAccent (glow 30%), dots accent, category badge purple→info, low-stock banner warning+onAccent, price → AppMoneyText 22 accentText, unit chip purple→neutral onSurfaceVariant, Edit/QR action btns accentText/infoText, _stockColor(context) brightness-aware
- **LESSON**: SnackBar me `contentTextStyle` param nahi hai is Flutter version me — content Text ka style use karo; `BorderRadius.circular` const nahi hota (const BoxDecoration me nahi chal sakta)
- Untouched logic: dual-view toggle, search/filter/sort, bulk ops, swipe handlers, quick stock, CSV import/export, undo deletes, scanner
- **NEXT: Page 6 = Product Detail (product_detail_page.dart)**

#### ✅ Page 6: PRODUCT DETAIL (2026-08-25) — 0 errors, all features intact
- Edit icon → accentText; unit badge purple → neutral onSurfaceVariant; price → accentText; min-stock low → warningText
- Add/Remove Stock outline btns → successText/error; dialog icon chips + prefix icons brightness-aware; warranty blue → infoText
- Action btns: QR purple → infoText, Edit → accentText; detail row/card icon chips → accentSubtle + accentText; stock badges green → successText
- Snackbars: orange→warning, red→error, green→success + onAccent text; Confirm btn successText/error bg + white
- Untouched: Hero image, stock dialog logic (reason/note/AdjustStock), damaged dialog, delete confirm, all navigation
- **NEXT: Page 7 = Add Product (add_product_page.dart) + Page 8 = Edit Product (edit_product_page.dart)**

#### ✅ Pages 7+8: ADD/EDIT PRODUCT (2026-08-25) — 0 errors, forms intact
- add: duplicate-dialog orange → warning/warningText + onAccent btn, category picker → accentSubtle/accentText/check, image-compress snackbar → success+onAccent, barcode scan chip → accentSubtle+accentText, helper text accent
- edit: same category picker pattern, camera suffix icon accentText, compress snackbar success+onAccent
- Untouched: image picker+compress flow, barcode scan, validators, save/update logic
- **NEXT: Page 9 = QR Generator (qr_generator_page.dart)**

#### ✅ Page 9: QR GENERATOR (2026-08-25) — 0 errors
- Price → AppMoneyText 18 accentText; Save QR btn → accent+onAccent; Share btn teal → infoText+white; Print QR outline → accentText
- QR code itself (PrettyQr onSurface) untouched — scannability preserved
- **NEXT: Page 10 = Scanner Page (scanner_page.dart) → phir Reports suite (10-16)**

#### ✅ Pages 10-16: SCANNER + REPORTS SUITE (2026-08-25, subagent-assisted) — 0 errors
- scanner_page: already clean (Phase 3 fix). Camera overlay whites = functional, kept.
- **Subagent migrated 116 spots across 6 report pages** (reports_home 9+const-fix, daily_sales 24, bill_history 30, bill_detail 34, stock_movement 18, low_stock 1)
- Key patterns: header gradients → accent+accentDark+onAccent; status badges → token@12% + *Text(b); chart series [success, info, warning] (card=warning taaki 3 distinct dikhen); heatmap lerp divider→accent + onAccent hot cells; date-picker primary → accent; _changeColor → brightness-aware method
- Skipped (justified): WhatsApp green (brand), PdfColors (print), painter-internal whites (decorative), money-font swap (scope)
- **NEXT: Pages 17-19 = Due Payments, Damaged Products, Warranty → phir Customers/Categories/Staff/Shop/Settings/Auth**

#### ✅ Pages 17-27: REMAINING FEATURES (2026-08-25, parallel subagents ×2) — 0 errors
- **Subagent-2 (~69 spots)**: due_payments 24 (hero card solid warning+onAccent, collect btns accent), warranty 17 (_statusColor tokens, Approve/Reject/Resolve semantic solid+white), category_list 9 (stats gradient accent), add_edit_category_dialog 1 chrome (swatch list = DATA kept), settings 10 (avatar accent, CONNECTED success), customer_detail 3, add_customer 5
- **Parallel batch ×3 agents (simultaneous dispatch)**:
  - audit_timeline: 4 spots (mostly pre-clean), const lint bonus fix
  - inventory_health 9 + staff_performance 9 + recent_transactions 5 + dashboard 3-groups (low-stock banner error(b), search accentText, desc-highlight warning) — glass tints → SOLID surface+border (dashboard_action_card pattern)
  - payment_donut 9 (luminance-based _darkText!) + top_products 5 (bar lerp accent→success, tooltip onAccent) + monthly_trend 7 + app_bottom_nav 2 (FAB gradient purple→accent) + quick_actions_panel 2 + input_label 1; glass_card skipped (dark-neutral only)

### 🏆 PHASE 8 — GLOBAL CONSISTENCY: COLOR MIGRATION COMPLETE (2026-08-25)
- **Full lib analyze = 1 pre-existing info only** (product_detail:496)
- **~250+ hardcoded color spots migrated app-wide** across 25+ files; sab v3 tokens pe
- **Justified remaining (documented)**: category swatch data (16) + entity/model/event data, WhatsApp green ×2 (brand), staff avatar rotation palette (decorative), glass_card dark-neutral, painter whites (donut/dots), camera-overlay blacks
- Pages fully v3: Dashboard, Billing Home, Checkout, Receipt, Products (list+coverflow), Product Detail, Add/Edit, QR Gen, Scanner, Reports ×6, Due Payments, Warranty, Categories, Settings, Customer Detail/Add, Audit Timeline + saare core widgets (stat/health/staff/txn cards, charts, nav, panel)
- Theme-level v3 (auto-applies): auth pages, staff pages, shop details, damaged products, customer list — ye theme-driven hain, koi hardcoded color nahi
- **REMAINING (Phase 9-10)**: functionality audit + layout-level premium polish per-page (money font rollout on remaining ₹ amounts, spacing consistency)

### ✅ PHASE 9 — FINAL FUNCTIONALITY AUDIT (2026-08-25)
- **git status verified**: sirf 39 presentation/theme files modified + 1 new (app_colors.dart) — ZERO domain/data/BLoC/repository files touched, app_routes.dart untouched (saare 31 routes intact)
- flutter analyze lib = 0 errors (1 baseline info)
- flutter test: widget_test.dart FAILS but ye DEFAULT Flutter counter template test hai (kabhi update nahi kiya gaya, pre-existing failure — billing app se unrelated, mere changes se pehle bhi fail hota)
- Per-page feature checklists verified during migration (memory me documented): Dashboard 16, Billing 12, Checkout 14, Receipt, Products 16, Detail, Add/Edit, QR, Scanner, Reports ×6, DuePay, Warranty, Categories, Settings, Customers — SAB features preserved
- **VERDICT: WHAT the app does = 100% LOCKED ✅ | HOW it looks = fully transformed**

### PHASE 10 — FINAL POLISH ✅ COMPLETE (2026-08-25, parallel subagents ×4)
- **Agent 1 (money-font rollout)**: 37 ₹ sites → AppMoneyText across daily_sales(10), bill_history(6), bill_detail(14), due_payments(7); Text.rich pattern for mixed label+amount (labels sans, amounts mono); shared helpers ko `money:` flag; PDF/ESC-POS/painter texts skipped (own font systems)
- **Agent 2 (auth redesign)**: login (brand chip + "Welcome back" hero + lime CTA + accentText links, maxWidth 440), register (2-col name/shop, maxWidth 480), email_verification (v3 card + mail chip + resend secondary) — saara Supabase/BLoC logic verbatim
- **Agent 3 (staff+shop)**: staff_list (initial chips + role badges success/info@12%), add_staff (sectioned card), shop_details (3 section cards Shop Info/UPI/Receipt Footer, Save SafeArea preserved)
- **Agent 4 (damaged+customers)**: damaged summary = solid error card white content, loss amounts money-font error(b), damage chips error@12% selected; customer rows = initial chips + tertiary meta
- **FINAL: `flutter analyze lib` = "No issues found!" — ZERO issues (baseline info bhi fixed)**
- **PROJECT STATUS: Phases 0-10 ALL COMPLETE 🏆 — premium transformation done, features 100% intact**

### ✅ DASHBOARD HERO + QUICK ACTIONS REDESIGN v3.1 (2026-08-25, ui-ux-pro-max skill)
- **Skill workflow**: --design-system (dark OLED + mono data numerals + Enterprise Gateway pattern validate) → chart domain (KPI = number + trend context; "<4 data points = stat card") → flutter stack (RepaintBoundary, const) → **KEY RULE: "no back.out overshoot on informational UI"**
- **HERO upgrade**: 7-day sparkline (44px, smooth quad-bezier + accentSubtle gradient fill, RepaintBoundary, billHistory se — no extra fetch) + **_DeltaPill** (▲/▼ % vs 6-day avg — icon+text+tint, hue-never-alone; prevAvg==0 pe hidden) + chevron affordance sub-stats row me; **buildWhen me billHistory add kiya** (warna sparkline stale rehta — subtle bug pakda)
- **QUICK ACTIONS upgrade**: spring overshoot → **stagger fade+slide** (per-tile 60ms delay, Interval-based, easeOutCubic) + **semantic wayfinding colors** (Due=warning, Customers=info, Categories=success, Warranty=accentText, Shop/Settings/Staff=muted) + RepaintBoundary per tile; PressScale wrapper (agent-added) retained
- `QuickActionTile` me `staggerDelay` param add (dashboard-only widget, safe)
- analyze: dashboard + action_card = 0 issues
- **LESSON**: BlocBuilder buildWhen me SAARE consumed streams daalo — naya data source add karo to buildWhen update karna mat bhoolo

## 🔍 FULL APP AUDIT DONE (2026-08-25) — AUDIT_REPORT.md padho!
- 6 parallel read-only agents → ~270 unique findings (6 CRITICAL verified, 38 HIGH, ~95 MEDIUM, ~130 LOW) — **full details AUDIT_REPORT.md me**
- **FALSE POSITIVE lesson**: Agent ne service_locator `../../` imports ko CRITICAL bola — empirically FALSE (analyze 0 + app chalta hai; Dart resolver handle karta hai). Agent claims pe hamesha verify karo
- **item_count migration drift**: bills.item_count kisi migration file me nahi (live DB manually patched hoga) — fresh rebuild pe billing tootega
- Top P0: (1) main AndroidManifest INTERNET permission missing — RELEASE APK DEAD, (2) staff-add session hijack (signUp owner session replace), (3) % discount absolute save = financial corruption, (4) edit_product firstWhere crash, (5) due_payments infinite loop + uuid-ilike crash, (6) AuthBloc factory ×3 + createRouter-in-build
- Big feature bugs: shop save sirf Hive (cloud sync void), warranty customer_id kabhi write nahi, analytics sirf 20 bills (page:1), Load More filters lose, printer ₹/Hindi mojibake, CSV BOM missing, test-print fake success, void-bill fake success
- copyWith null-gap family = systemic pattern bug (discount/amountPaid/override/customer/Product fields clear nahi ho sakte)
- User ko report de diya — fix order AUDIT_REPORT.md me hai
- **v3.2 (user feedback)**: Quick actions ab **4-per-row** (crossAxisCount 4, aspect 0.85, spacing 10) + tiles compact (chip 9/20px icon r11, padding v12, label 10.5, r16)
- **v3.3 (dashboard audit)**: greeting me date line add ("Good morning · Tue, 25 Aug"); hero pe `Semantics(button, label)` wrap (InkWell me semanticsLabel param NAHI hota — Semantics widget use karo). Audit suggestions user ko report kiye: This Week redundancy, analytics overload, first-run empty state, lazy slivers

## 🔧 MASS FIX WAVE (2026-08-25) — 6 parallel agents, audit ke ~100 issue-groups fixed
- **Agent 1 (billing)**: % discount ab absolute amount save hota hai (C1 ✅), copyWith clear-flags family (amountPaid/discount/override/customer ✅), checkout qty steppers 44dp, shop-not-loaded feedback, unsafe casts, dialog controller disposals, random-UUID QR fix, receipt SafeArea + clean error messages
- **Agent 2 (auth/staff/DI)**: AuthBloc registerLazySingleton (3-instances bug ✅), router memoized (theme-toggle nav reset ✅), **staff-add hijack fix** = signup ke baad signOut + login screen message (admin-API limitation documented), /staff/add + /customers/add FABs wired (dead routes zinda), splash-flash loop fix (CheckAuthStatus ab AuthLoading emit nahi karta), self-delete guard, logout fold, staff phone param end-to-end
- **Agent 3 (reports)**: LoadBillHistory limit param (dashboard 200 — analytics cap ✅), Load More filters preserve, updateBill due/status recalc, This-Month-Revenue salesRange se, search pagination fix, reprint real shop fields, void button disabled (fake success gone), billDeleted flag, audit CSV try/catch + sanitize
- **Agent 4 (product/realtime)**: firstWhere orElse (C3 ✅), Product.copyWith clear-flags, mounted guards, disposals, duplicate-check submit-only, CSV bulk event (reload storm fix), realtime server-side shop filter + DELETE id-fetch fallback + 5s resubscribe, billing duplicate channel REMOVED, ProductBloc close-safe, stock shop_id filters, defensive casts, barcode→qrData sync, category reactive counts
- **Agent 5 (due/warranty/damaged/customer)**: due infinite loop fix (clear flags + ClearDueMessages event) (C4 ✅), uuid-ilike crash fix (C5 ✅), substring/RegExp guards, warranty submitSuccess-gated dialog (premature success gone), damaged msg-repeat + undo race + N+1 fix, FutureBuilder error states, 400ms debounces, disposals
- **Agent 6 (theme/platform)**: **INTERNET + VIBRATION permissions manifest me (C6 ✅)**, BT perms maxSdkVersion-30 gated, drawer header + 2 FAB whites → onAccent, dark-mode light-fill contrasts ×4, audit spinners accentText, text_styles 17 hexes → tokens, glass_card v2 navy → darkSurface, printer ₹→Rs. + ASCII sanitize, CSV BOM + timestamped names, **test print real success/fail**, settings me Scan/Connect/Test/Disconnect printer UI wired, NaN/Infinity validator, auto-connect heuristic
- **`supabase/migrations/019_audit_fixes.sql` CREATED** (item_count column + REPLICA IDENTITY FULL + warranty RLS shop-scoped + DELETE policy) — **⚠️ APPLY USER KO KARNA HAI apne Supabase SQL editor me (MCP project alag hai — bills table nahi milti wahan)**
- **FINAL: flutter analyze lib = "No issues found!" — 0 issues**
- **Remaining (documented, non-blocking)**: P3 LOWs (~130: dead code, spacing oddballs, fontSize bypasses), warranty customer_id needs BillSummary.customer_id field, collectPayment atomic increment needs RPC, staff-delete auth-user cleanup needs server-side, supabase keys → --dart-define, analytics tabs/empty-state/lazy-slivers (UX suggestions pending user decision)

## 🧹 FINAL CLEARANCE WAVE (2026-08-25) — 4 parallel agents, "pura kaam clear"
- **Dashboard UX**: "This Week" section REMOVED (redundant — hero sparkline + 30-day cover karte hain), **first-run empty state** (_FirstRunCard: 0 bills pe analytics hide + 'Chalo shuru karein' onboarding, Inventory Health dikhta rehta hai), **SliverChildBuilderDelegate** (lazy sections)
- **Dead code cleanup**: auth_gate.dart deleted, Google OAuth poora path removed (event+handler+usecase+repo+DI), GetProductsByCategoryUseCase, GenerateQrCode+qrCodeData, audit LoadEntityAuditLogs/LogAuditAction/entityLogs, due getTotalPendingDue/getBillForDuePayment, damaged getTotalDamageLoss/getCount, json_annotation+json_serializable pubspec se removed (build_runner KEEP — Hive), **AppRouter holder class** = router+notifier dispose fix
- **UX polish**: 8 raw-exception spots → clean messages (auth me _friendlyMessage map), 6 Image.network loadingBuilder, checkout radius 6→8 (6 spots), shop_details controllers field-compare sync (edits overwrite fix), premium_stat_card glow tamed
- **Feature gap + config**: **warranty customer_id END-TO-END wired** (BillSummary.customerId add — column DB me tha, model me map nahi hota tha; bill-detail claim se pass) — customer warranty history AB KAAM KAREGI; **AppConfig.dart** (String.fromEnvironment + defaults) — --dart-define override possible
- **FINAL: flutter analyze lib = "No issues found!"** — poora backlog clear
- **Sirf 2 cheezein user pe**: (1) migration 019 apne Supabase SQL editor me run karo, (2) device test + release build
- Known accepted limitations (server-side needed): staff auth-user cleanup (RPC), collectPayment atomic increment (RPC)

---

## Current Session: 2026-08-24 — PREMIUM UI/UX REDESIGN PROJECT 🚀 (Research Phase ✅)

### Project Goal (user's master prompt)
- Full premium UI/UX redesign — NOT reskin. Layout/nav/hierarchy/motion sab redesign allowed.
- **Functionality preserve karna hai** — BLoC/Supabase/auth/printing/scanner logic untouched.
- Skills use karne ka permission: ui-ux-pro-max (design system) + taste-skill (audit).
- ⚡ **ELECTRICITY RULE:** har sub-phase ke baad `graphify update .` + memory.md update (power cuts se progress bachane ke liye).

### Research Done (2026-08-24)
1. **ui-ux-pro-max installed** — `npm i -g ui-ux-pro-max-cli` + `uipro init --ai opencode` → `.opencode/skills/ui-ux-pro-max/`. Python 3.11 available as `python` (not python3 on this Windows box).
2. **Generated design system direction** (`python search.py "invoice billing POS..." --design-system`): Minimalism/Swiss style, trust-focused pattern, navy+green palette suggestion, Poppins/Open Sans fonts.
3. **Existing theme audited**:
   - Primary purple `#6C63FF`, secondary teal `#03DAC6` (classic AI-default combo), IBM Plex Sans via google_fonts
   - Dark mode FULLY exists (theme_cubit + Hive persistence) — redesign must keep it
   - Cards elevation 4 / radius 16, inputs radius 12 filled, buttons elevation 4 colored shadow
   - `aiGradient` (lavender→blue→cyan) used on dashboard bg
   - text_styles.dart has hardcoded hex colors + good tabularFigures() usage already
4. **Navigation audited** — CRITICAL FINDING: drawer-only nav (AppShell → AppDrawer), **no bottom navigation**. Drawer = 16 items across 7 sections (Main/Inventory/Reports/Warranty/Payments/Settings/Staff). POS app ke liye ye critical UX issue hai.
5. **Scale**: 170 dart files, 16 features, 31 pages, 16 core/widgets (mostly dashboard-specific cards).

### Design Direction Decision (pending user confirmation)
- Option A: Purple identity rakhо, polish karo (safer, brand continuity)
- Option B: Generated navy+green professional palette (trust feel for billing)
- Mockup images banake dikhana better hai (imagegen-frontend-mobile skill)

### Next Steps
1. ~~Audit report~~ ✅ DONE (2026-08-24) — C1 drawer-only nav, C2 tiny fonts (11-13px body), C3 no tokens (179 hardcoded colors, 10 radii), H1 25 files generic spinners, H2 28 files snackbars inconsistent, H3 AI-default purple/teal
2. ~~Design tokens~~ ✅ DONE (2026-08-24) — `lib/core/theme/app_dimensions.dart` created: AppSpacing (4-pt grid: xs4/sm8/md12/lg16/xl24/xxl32), AppRadius (sm8/md12/lg16/xl20/full), AppElevation (low1/mid3/high8 + tinted shadow helpers), AppDurations (150/250/400ms + easeOutCubic/spring curves), AppTouchTarget (min48/button52). analyze clean. **Abhi koi file use nahi kar rahi — wiring screens ke saath hogi**
3. Navigation redesign (bottom nav) — **IN PROGRESS (2026-08-24)**:
   - ✅ `lib/core/widgets/app_bottom_nav.dart` CREATED — 5 tabs: Home(/) · Products(/products) · **Billing CENTER raised gradient circle** (/scan, TweenAnimationBuilder scale on active) · Reports(/reports) · More(opens drawer via Scaffold.of)
   - Active state: pill highlight (primary @12% alpha) + AnimatedContainer 250ms easeOutCubic + HapticFeedback.selectionClick
   - SafeArea(top:false) + surface color + hairline top border. Touch targets ≥48. Semantics labels added.
4. **[RECOVERED SUMMARY — kuch entries editor se lost thi, condensed]** Drawer slimmed 16→9 (Catalog/Business/Shop/Staff sections). Dashboard pass#1 (Due Payments/Customers/Warranty tiles added, _loadDashboardData dedupe). Typography scale `app_typography.dart` wired into app_theme (body 16/14). Components: `app_skeleton.dart` (AppSkeleton/ListTile/List pulse) + `app_feedback.dart` (AppFeedback.success/error/info). **Migration 18 files complete** (skeletons 9 list pages, ~40 snackbars unified; button/dialog/pagination spinners intentionally KEPT). Motion: global _FadeSlideUpTransition page transitions, PremiumStatCard entrance+value crossfade, PrimaryButton press-scale 0.97 + elevation 8→4. design.md updated with Design System v2 section. Full analyze 0 errors maintained.
5. **EXPANDABLE TAB BAR (video-inspired) DONE (2026-08-25)** — user bheja "Expandable Tab Bar.mp4" (ffmpeg frames se analyze). **`quick_actions_panel.dart` NEW:** QuickActionsState.open (global ValueNotifier) + QuickActionsPanel.show() → transparent PageRouteBuilder (300ms in/250ms out) — scrim(tap-close) + glass grid panel (4-col, 8 actions: Categories/Customers/DuePay/Warranty/Damaged/Shop/Settings/Staff-owner, spring scale from bottomRight) + close button. **`app_bottom_nav.dart` REWRITTEN video-style:** floating glass pill (BackdropFilter 18, icon-only 4 tabs Home/Products/Billing/Reports, active=rounded-square primary@14%) + separate 56px circular gradient + button. **SMOOTH MORPH:** Hero(tag 'quick-actions-toggle') dono buttons pe (same gradient circle, same position right:16/bottom:10) + TweenAnimationBuilder rotates + icon 0→45° (=X, spring) on open; hero reverse flight on pop. Nav pill AnimatedOpacity→0 + scale 0.92 when open. Drawer intact (dashboard AppBar hamburger se — logout wahan). analyze lib = 0 issues TOTAL.
   - **Tweak (user feedback):** `extendBody: true` in app_shell (content pill ke PEECHE se scroll hoti hai — true transparency, glass blur visible) + nav padding (16,6,16,4) + panel offsets matched (X bottom=+7, panel=+76). NOTE: extendBody se lambi lists ka last item pill ke peeche chhup sakta hai — jo page ajeeb lage uska bottom padding badhana.
   - **FIX (user screenshot — Shop Details):** pinned bottom buttons nav ke peeche chhupe the. Fix = `SafeArea(top:false)` wrap on inner bottomNavigationBar/bottomSheet (extendBody nav-height MediaQuery.padding.bottom inject karta hai, SafeArea use consume karke button pill ke upar lift hota hai): shop_details Save, edit_product Save, add_product Add, home_page Review Order bottomSheet. product_list cart bar me PEHLE SE inner SafeArea tha (auto-fix, koi change nahi). receipt_preview + checkout = fullscreen routes (nav hidden) — fix not needed. Pattern: **naye pages me pinned bottom UI hamesha SafeArea(top:false) me wrap karo**.
6. **NAVIGATION STYLE TOGGLE (user idea) DONE (2026-08-25)** — `lib/core/navigation/navigation_cubit.dart` NEW: `AppNavigationMode {bottomNav, drawer}` (⚠ Flutter material.dart ka apna NavigationMode hota hai — NAME CLASH hota hai, isliye App prefix) + NavigationCubit w/ Hive persistence ('nav_mode' key in settings box, default bottomNav). Wired: service_locator (singleton), main.dart (BlocProvider), **app_shell.dart** BlocBuilder — bottomNav mode = extendBody+AppBottomNav, drawer mode = no bottom nav + normal scaffold (drawer via existing AppBars hamburgers: dashboard/products/reports pages). **Settings → Appearance → 'Navigation Style'** tile: SegmentedButton (Bottom Bar 🆚 Hamburger) + haptic + live switch. Lesson: enum naam Flutter SDK se clash check karo pehle.
7. **NAV MODE RULES (user requirement) IMPLEMENTED (2026-08-25)** — Rules: drawer mode = drawer me SARE features; bottomNav mode = KISI bhi page pe hamburger NAHI. (a) **`adaptive_app_bar_leading.dart` NEW**: drawer mode→hamburger, bottomNav mode→back btn (route=='/' pe hidden). **17 pages bulk-patched** via PowerShell tempered regex (`leading: IconButton(...openDrawer...)` → `leading: const AdaptiveAppBarLeading(),` + import auto-add). category_list ternary + home_page floating camera menu button manually (home: drawer mode pe hi dikhega). (b) **AppDrawer mode-aware**: drawer mode = FULL menu (Main/Inventory/Reports sub-pages/Warranty sections restored) + slim for bottomNav (+Reports Home link). (c) **Settings Logout item** added (bottomNav mode me drawer unreachable — logout access chahiye) w/ `_buildListItem iconColor` param (⚠ regex ne _buildSwitchItem ko bhi touch kiya tha — revert kiya). (d) product_detail bottom buttons = scroll content ke end me the → scroll padding bottom = 16+MediaQuery.padding.bottom. analyze lib clean (1 pre-existing info).
8. **HAMBUGER FIX (user report: "hamburger kaam nahi kar raha")** — ROOT CAUSE: pages ke nested inner Scaffolds hain; AdaptiveAppBarLeading ka apna context INNER scaffold ko dhoondta tha (drawerless) → openDrawer silent no-op. Pehle kaam karta tha kyunki original code PAGE-STATE ka context use karta tha (inner scaffold ke UPAR → outer shell scaffold milta tha). **FIX: `AppShell.scaffoldKey` (static GlobalKey<ScaffoldState>)** — shell Scaffold pe assign, AdaptiveAppBarLeading ab `AppShell.scaffoldKey.currentState?.openDrawer()` call karta hai. **LESSON: nested Scaffolds me `Scaffold.of(context)` context depth pe depend karta hai — cross-scaffold drawer access ke liye GlobalKey use karo.** User ne bola: use 'boss' mat bolo. analyze clean.

## Current Session: 2026-08-21 — Customer CMS planning ✅ (build pending)
- User approved: full Customer CMS (name+phone only, NO email/address). Link to bills + warranty + due payments via `customer_id`.
- **Full plan:** `customer_cms_plan.md`. Build order + risks documented there.
- **KEY DISCOVERY (verify before any migration):** repo business tables (products, bills, due_payments, warranty_claims) have **NO RLS** — shop isolation is Dart-side via `_resolveShopId()` + `.eq('shop_id', effectiveShopId)` (confirmed in product_/due_payments_repository_impl). Only `profiles` has RLS. So `customers` table = NO RLS, Dart filtering. Don't invent `app.shop_id` session RLS.
- Migrations needed (2): (1) `customers` table + unique(shop_id,phone) + indexes; (2) `bills`/`warranty_claims` add `customer_id` FK + phone backfill.
- Phone normalize helper shared at every capture point.
- Standing rule: after build → analyze → hot restart w8:p9 → docs + graphify.

---

## Current Session: 2026-08-21 — Product Page: Remove Redundant Add Button ✅

### Change
- User: product page mein FAB already hai, toh search-bar ke upar wala add button hata do.
- That "button above search bar" = the AppBar `Icons.add_rounded` IconButton I added earlier (to compensate for FAB hiding on cart).
- Removed AppBar add IconButton from `_buildAppBar`.
- Also removed the FAB `Visibility` hide-on-cart wrapper → FAB now ALWAYS visible (so add-product stays reachable even when cart bar shows). FAB auto-floats above the cart bar (no clash).
- Empty-state "Add Product" button (when no products) kept — still useful.

### Verify
- `flutter analyze lib/features/product/presentation/pages/product_list_page.dart` → 0 issues.

---

## Current Session: 2026-08-21 — Checkout Dialog: Scanner Add Broken ✅

### Problem (user reported)
- Checkout "Add Product" dialog: list-selection add works, but scanner (camera) add + manual barcode entry does NOT add to cart.

### Root Cause
- The dialog's `StatefulBuilder` shadows the page `context` with its own `context` param.
- Scanner/manual handlers did `Navigator.pop(ctx)` (closes dialog) THEN used the **disposed dialog `context`** to `context.push('/scan/scanner')` and `context.read<BillingBloc>().add(ScanBarcodeEvent(...))`.
- Reading BillingBloc / navigating from an unmounted dialog context silently fails → scan never reaches the cart.
- List-add worked because it does NOT pop the dialog first (context still valid).

### Fix (checkout_page.dart)
1. Captured `final pageContext = context;` BEFORE `showDialog` (page-level context, never shadowed).
2. Scanner button: use `pageContext.push('/scan/scanner')` + `pageContext.read<BillingBloc>().add(ScanBarcodeEvent(result))`.
3. Manual barcode `onSubmitted`: same switch to `pageContext`.
- Removed dead `if (mounted) {}` empty blocks.

### Verify
- `flutter analyze lib/features/billing/presentation/pages/checkout_page.dart` → 0 errors (1 pre-existing info lint at 988, safe).

---

## Current Session: 2026-08-21 — Billing Scanner Beep Sound Missing ✅

### Problem (user reported)
- Product page scanner (search) → beep sound aa raha tha.
- Billing / scan & billing page → product scan karte time beep nahi aa raha tha.

### Root Cause
- Billing product-scan flow uses `home_page.dart` inline `MobileScanner` with its own `_onDetect` (line 65). That handler only called `Vibration.vibrate()` — **`BeepHelper.playBeep()` call missing** (aur `beep_helper` import bhi nahi tha).
- Standalone `scanner_page.dart` (used by product search + checkout scan button) DOES call `BeepHelper.playBeep()` — that's why those beep the right way.
- Checkout's scan button correctly `context.push('/scan/scanner')` → uses the beep-enabled page, so it was fine.

### Fix
1. Added `import '../../../../core/utils/beep_helper.dart';` to `home_page.dart`.
2. Added `BeepHelper.playBeep();` in `HomePage._onDetect` right after the vibration, before `ScanBarcodeEvent`.
3. **Softened vibration**: was `Vibration.vibrate()` (default 500ms, max amplitude = too harsh). Changed to `Vibration.vibrate(duration: 120, amplitude: 128)` (short + ~half intensity).

### Verify
- `flutter analyze lib/features/billing` → 0 errors (only 1 pre-existing info lint at checkout_page.dart:983, unrelated).

---

## Current Session: 2026-08-21 — Navigation Back-Button Fix (app close bug) ✅

### Problem (user reported)
From any sub-page, Android back button closed the whole app instead of returning to Dashboard. Dashboard back should close the app (correct), but sub-pages should land on dashboard first.

### Root Cause (graphify + code)
- `lib/config/routes/app_shell.dart` wrapped the ENTIRE shell in `PopScope(canPop:false)` → `onPopInvoked` forced `goRouter.go('/')` on EVERY back press. This swallowed sub-page pops and, because `go('/')` resets the stack, the system saw no remaining history and closed the activity. Dashboard back also didn't reliably exit.

### Fix
1. **Removed global PopScope from `app_shell.dart`** — pages now pop normally via go_router's navigator stack (ShellRoute handles `/products` → `/` etc).
2. **Added `PopScope(canPop:false)` + `SystemNavigator.pop()` to `DashboardPage`** (`_DashboardViewState.build`) — back on dashboard now cleanly exits the app.
- `services.dart` already imported (SystemNavigator available).
- Sub-pages already use `context.pop()`/`Navigator.pop()` → land on parent → eventually dashboard.

### Verify
- `flutter analyze lib` → 0 errors. Both edited files clean.

### Flow now
sub-page back → parent page → ... → Dashboard → (back) → app closes. ✅

---

## Current Session: 2026-08-21 — Products Page: Persistent Cart Bar (FAB overlap fix) ✅

### What Was Done
1. **Swipe-to-add cart feedback changed from SnackBar → persistent mini-cart bar** (user chose Option 3).
   - `product_list_page.dart`: removed floating `SnackBar` in `_addToCart` (it overlapped + hid the add-product FAB at bottom-right).
   - Added `bottomNavigationBar` = `BlocBuilder<BillingBloc>` mini-cart bar: shows item count + `totalAmount` + "View Cart" button (pushes `/scan/checkout`). Hidden (`SizedBox.shrink`) when cart empty.
   - FAB (`_buildFab`, add product) now wrapped in `Visibility` — hidden when cart non-empty so it doesn't clash with the cart bar.
   - Added "Add product" `IconButton` to the AppBar so add-product stays reachable even when FAB is hidden.
   - Cart bar uses `AppTheme.primaryColor` gradient, `SafeArea` for notch, rounded 16 radius.

   **flutter analyze:** 0 errors (whole lib: 0 errors). Only pre-existing info lints remain.

---

## Current Session: 2026-08-21 — Damaged Products Management Feature ✅

### What Was Done
1. **Damaged Products Management Feature** — complete implementation for tracking and managing damaged inventory:

   **Domain Layer:**
   - `DamagedProduct` entity: id, productId, productName, barcode, image, price, quantityDamaged, previousStock, newStock, damageType, notes, damageDate, reportedByName, estimatedLoss
   - `DamagedProductsRepository` interface: getDamagedProducts, getTotalDamageLoss, getDamagedProductsCount, markAsDamaged

   **Data Layer:**
   - `DamagedProductsRepositoryImpl`: queries `stock_adjustments` where `reason='damage'`, joined with products for name/barcode/price/image. Mark as damaged: decreases stock + logs adjustment + audit log. No new DB migration needed — reuses existing `stock_adjustments` table.

   **BLoC Layer:**
   - `DamagedProductsBloc`: LoadDamagedProducts, SearchDamagedProducts, FilterDamagedProductsByDate, MarkProductAsDamaged events
   - State: damagedProducts, totalLoss, totalCount, isLoading, isMarking, error, successMessage, searchQuery, startDate, endDate

   **Presentation Layer:**
   - `DamagedProductsPage`: red gradient summary card (total loss ₹ + count), search bar, date range filter chips, list view with product image/name/barcode, quantity badge, price badge, damage type, loss amount, date
   - `MarkDamagedDialog`: quantity +/- selector, 6 damage type choice chips (Broken, Defective, Expired, Water Damage, Scratched, Other), optional notes field, stock validation

   **Integration:**
   - Product Detail Page: 'Mark as Damaged' button in Stock Adjustment section (disabled when stock=0)
   - Product List Page: 'Mark as Damaged' in long-press menu (only when stock>0)
   - Route: `/damaged-products` with BlocProvider in app_routes.dart
   - Drawer: 'Damaged Products' menu item under Payments section
   - DI: DamagedProductsRepository + DamagedProductsBloc registered in service_locator.dart
   - main.dart: DamagedProductsBloc added to MultiBlocProvider

   **Files Created:**
   - `lib/features/damaged_products/domain/entities/damaged_product.dart`
   - `lib/features/damaged_products/domain/repositories/damaged_products_repository.dart`
   - `lib/features/damaged_products/data/repositories/damaged_products_repository_impl.dart`
   - `lib/features/damaged_products/presentation/bloc/damaged_products_bloc.dart`
   - `lib/features/damaged_products/presentation/bloc/damaged_products_event.dart`
   - `lib/features/damaged_products/presentation/bloc/damaged_products_state.dart`
   - `lib/features/damaged_products/presentation/pages/damaged_products_page.dart`
   - `lib/features/damaged_products/presentation/pages/mark_damaged_dialog.dart`

   **Files Modified:**
   - `lib/core/service_locator.dart` — DI registration
   - `lib/config/routes/app_routes.dart` — route + imports
   - `lib/core/widgets/app_drawer.dart` — drawer menu item
   - `lib/main.dart` — MultiBlocProvider
   - `lib/features/product/presentation/pages/product_detail_page.dart` — Mark as Damaged button
   - `lib/features/product/presentation/pages/product_list_page.dart` — long-press menu + import
   - `RPD.md` — Section 10 added
   - `phases.md` — Phase 7 added

   **Design Decisions:**
   - No new DB migration — leverages existing `stock_adjustments` table with `reason='damage'`
   - Client-side search for product name/barcode (joined data not searchable server-side)
   - Damage type + free-form notes both stored in `note` field as `"type|notes"` (no schema change) — encoded/decoded via `DamagedProduct.encodeNote`/`decodeNote`
   - Stock decreases automatically when product marked as damaged
   - Date range filter uses Supabase `gte`/`lt` on `created_at`

   **Improvements (2026-08-21 — same session):**
   1. **Notes bug fixed** — earlier `damageType` + `notes` both wrote to `note` column, so notes were lost. Now encoded as `"type|notes"` (Dart-only, no migration). Legacy rows (only type stored) still decode correctly via `decodeNote`.
   2. **Human-readable damage type** — page shows "Broken"/"Water Damage" etc via `DamagedProduct.damageTypeLabel` instead of raw DB value.
   3. **Notes now visible** — list card shows "Note:" line when notes present.
   4. **reportedByName** — now resolves to staff display name (via `_resolveStaffName`) instead of raw UUID.
   5. **CSV Export** — new `CsvExportImport.exportDamagedProducts` + AppBar download button (disabled when empty).
   6. **Pull-to-refresh** — `RefreshIndicator` wraps the list.
   7. **Undo / Reverse damage** — new `undoDamage` repo method + `UndoDamagedProduct` event + confirm dialog (restores stock, deletes adjustment row, audit log). Per-card undo IconButton.

   **flutter analyze:** 0 errors, 0 warnings ✅ (whole lib: 0 errors)

---

## Current Session: 2026-08-20 — Signed Release APK + Split-per-ABI 📦

### What Was Done
1. **Release keystore generated** — `android/app/billing_app-release.keystore` (alias `billing_app`, RSA 2048, 10000 days, auto-generated password stored in `android/key.properties` — both gitignored)
2. **`android/app/build.gradle.kts`** — signing config (loads `key.properties`), release buildType now uses release signing (debug fallback), `isMinifyEnabled=true` + `isShrinkResources=true`
3. **`android/app/proguard-rules.pro` (new)** — Flutter keep rules + `-dontwarn` for Play Core split install (R8 fix)
4. **Build command** — `flutter build apk --release --split-per-abi --no-tree-shake-icons`
   - Output: `app-armeabi-v7a-release.apk` (24.9MB), `app-arm64-v8a-release.apk` (28.5MB), `app-x86_64-release.apk` (31.0MB)
   - Signing verified via apksigner ✅
5. **`--no-tree-shake-icons` required** — category pages use dynamic `IconData` (non-const), tree-shaking fails. Fix later = make IconData const.

### Notes
- KGP warning (Built-in Kotlin migration) — non-blocking, plugins migrate karne par hoga
- Release build uses minification — R8 missing rules were added to proguard-rules.pro

---

## Previous Session: 2026-08-20 — Report Pages Modernization 📊✨

### What Was Done
1. **Reports Home Page** — CustomScrollView + SliverAppBar, gradient stat cards, modern grid layout with 4 report cards (Daily Sales, Low Stock, Bill History, Stock Movement)
2. **Daily Sales Page** — Gradient summary header with animated counters, bar chart, weekly/monthly toggle, export CSV
3. **Low Stock Page** — Gradient summary card (red gradient), category filter chips, animated product cards with stock progress bars, reorder threshold, export CSV
4. **Stock Movement Page** — Summary stats (Total/Added/Removed), type filter chips with icons, date range picker, staggered card animations, export CSV
5. All pages: CustomScrollView, SliverAppBar, modern card designs, haptic feedback, staggered animations

### flutter analyze
- 0 errors, 0 warnings ✅ (low_stock_page.dart + stock_movement_page.dart verified)

---

## Previous Session: 2026-08-20 — Dual View (Classic List + Cover-flow) 🔀

### Decision
- User: Spotlight cover-flow **accha laga** ❌ lekin default nahi rakh sakte
- **2 views**: Classic List (default) + Cover-flow (optional)
- **Har baar default** = Classic List (no persistence, session-only toggle)
- Toggle button = **AppBar icon**

### What Was Done
1. **`product_coverflow_view.dart` (new file)** — Cover-flow view extracted: `ProductCoverflowView` (own PageController + dial keys + currentIndex state, resets to page 0 when first product changes via `didUpdateWidget`) + `_CoverFlowItem` + `_CoverCard` + `ProductCoverflowSkeleton` (public)
2. **`product_list_page.dart` (rewrite as shell)**:
   - Shell: AppBar (menu + **view toggle icon** animated rotation + refresh + sort + export/import) + hero search (shared) + `AnimatedSwitcher` (350ms fade) between views
   - **`_ClassicListView` (restored original pre-Bento UI)**: category FilterChips (All + counts) + classic tiles (stock accent bar, image, name, description snippet, stock/unit/barcode meta, price)
   - `_isCarousel` bool state — no persistence
   - Loading: `_isCarousel` ? `ProductCoverflowSkeleton` : spinner
   - Shared across views: search query, sort, category filter, FAB
3. flutter analyze: **0 issues** ✅ (both files)
4. **Fix (user feedback)**: Classic list cards ab **bilkul pehle jesa** — card `margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6)` + ListView `padding: symmetric(vertical: 8)` restored (pehle cards flush `EdgeInsets.zero` the, ab per-card inset + gaps). Tile content already faithful (stock accent bar, 64px image, name+chevron, desc snippet, stock/unit/barcode meta, price).
5. **Verified via graphify backup**: `graphify-out/2026-08-20/graph.json` backup confirmed pre-Bento file had exactly `_buildProductTile`, `_productImage`, `_stockBadge`, `_dotSeparator`, `_unitBadge`, `_metaText` — restored card is structurally identical ✅ (user confirmed — bas refresh karna tha, no further change needed).
6. **Compact Classic card (user request)**: card ko **compact** kiya (100px → ~60px):
   - Decisions: **price name ke right**, keep **stock + category + unit** (barcode/desc-snippet/chevron removed), **image 40px**
   - New layout: accent bar + 40px image + Line1(name w600 14 + price w700 14 right) + Line2(stock badge + category gray flexible + unit purple)
   - Removed dead code: `_dotSeparator`, `_metaText`, `_buildDescriptionSnippet`, `_ClassicListView.searchQuery` param + call site
7. **Tweak (user request)**: unit **hataya** cards se, **location add** kiya — Line 2 ab: stock badge + category + location (gray, `·` separator, both flexible/ellipsis). `_unitBadge` method removed.
8. **Card improvements (user picked 5/6, mini stock bar skip kiya)**:
   - **Out-of-stock gray out**: stock ≤ 0 → card content 50% opacity (accent bar stays red)
   - **Swipe actions**: `Dismissible` — right swipe = green "Stock +" quick-stock bottom sheet (`UpdateProduct.copyWith(stock)`), left swipe = red "Delete" confirm dialog (`DeleteProduct`); `confirmDismiss` returns false (card snaps back)
   - **Long-press menu**: bottom sheet → Edit / Show QR Code / Delete
   - **Initial-letter avatar**: no-image placeholder ab first letter of name, color from `Colors.primaries[name.hashCode]`
   - **Add-to-cart button**: trailing 30px circular primary button → `BillingBloc.AddProductToCartEvent` + green snackbar
   - Shell methods: `_showLongPressMenu`, `_confirmDelete` (with `mounted` guard), `_quickStock`, `_addToCart`; `_ClassicListView` gets 4 new callbacks
9. **Batch 2 — user picked ALL 7 suggestions**:
   - **Low-stock filter**: amber pill toggle in shared header bar (below search, both views) — count = `isLowStock` products; active = amber fill; filters list to low/out. Plus **mini stats text** `total · low · out` (hidden jab no products)
   - **Undo delete**: delete ke baad green snackbar "Undo" → `AddProduct(product)` restore (single + bulk dono me)
   - **Bulk selection**: AppBar `checklist` icon → selection mode (Close + N selected + export + red delete actions); tap/long-press toggle select; Dismissible disabled (`DismissDirection.none`); trailing circular check indicator (selected = primary fill + white check); selected card = 2px primary border. Bulk delete = confirm + Undo snackbar; bulk export = `CsvExportImport.exportProducts(selected)`
   - **Real CSV import**: `more_vert → Import from CSV` ab real hai — `CsvExportImport.importProducts()` (file_picker + csv parse) → `_productFromCsvMap` (uuid v4 id, skip empty names) → `AddProduct` each + count snackbar
   - **Copy barcode**: long-press menu me "Copy barcode" → `Clipboard.setData` + snackbar
   - **Search by location**: filtering me `product.location` match add kiya
   - Fix: `Dismissible` me `enabled` param exist nahi → `DismissDirection.none` use kiya (selection mode)
   - `flutter analyze product_list_page.dart` → 0 issues ✅
10. **Bug fix (user reported): "categories kabhi kabhi show nahi ho rahe"** — Race condition: categories `context.read<CategoryBloc>().state.categories` read kiya ja raha tha ProductBloc ke `BlocConsumer` builder ke andar → `context.read` subscribe nahi karta → jab CategoryBloc async load hoke emit karta, product list UI rebuild nahi hota → chips empty/stale reh jaate. **Fix**: shell build me `BlocConsumer<ProductBloc>` ke builder ke andar `BlocBuilder<CategoryBloc, CategoryState>` wrap kiya — ab CategoryBloc emit hota hai to chips + coverflow categoryNames turant rebuild hote hain. `flutter analyze` → 0 issues ✅

### Reminder
- ⚠️ Pre-existing errors `category_list_page.dart` (uncommitted): `context.go` undefined, `theme` undefined — abhi bhi baaki
- Bento code fully gone (user rejected)

---

## Previous: 2026-08-20 — Product Page UI Upgrade v2 (Spotlight Cover-flow) 🎡

### Context
- Pehle **Bento Inventory** design banaya tha — user ko maza nahi aaya ❌ → poocha aur **Spotlight Cover-flow** chuna ✅

### What Was Done
1. **ProductListPage redesigned → "Spotlight Cover-flow"** (`product_list_page.dart`):
   - **3D cover-flow carousel** (`PageView` viewportFraction 0.72 + `_CoverFlowItem`): `Matrix4` perspective + `rotateY(offset*0.72)` + scale + opacity fade — side cards peek karte hai, center card front
   - **Cover card** (radius 28): bada product image (Hero `product-{id}`), category badge (purple), stock badge (green/orange/red), low-stock amber banner, name + ₹ price (22 w800) + unit chip + barcode + **Edit/QR buttons**
   - **Category dial** (horizontal pills): icon + label + count, selected = primary fill + glow, auto-center (`Scrollable.ensureVisible alignment 0.5`), haptic
   - **Hero search**: 56px pill with primary border glow + "Spotlight search..." + gradient scanner button
   - **Bottom panel**: animated dots (active widens) + "N of M · Swipe to browse" (dots sirf ≤12 products pe)
   - **AppBar**: menu + **Refresh button** (add) + sort + export/import
   - Expandable FAB (Add → Scan) retained, `IgnorePointer` fix retained
2. **Bugs fixed earlier (retained)**: realtime DELETE fix, edit barcode controller, Hero on detail page
3. **Motion**: 3D rotateY cover-flow, card border/glow animates for center, skeleton carousel shimmer, animated empty state

### Lessons
- **Design direction user ko pehle dikha ke confirm karo** — Bento pick karne ke baad bhi maza nahi aaya, dobara poochhna pada. Ek hi file me 2 baar full redesign = time waste. Ab "Mix — tu decide" wala option bhi user ko de.

### flutter analyze
- Meri files: 0 issues ✅ (product_list_page clean)
- ⚠️ Pre-existing errors `category_list_page.dart` (uncommitted): `context.go` undefined, `theme` undefined — abhi bhi baaki

---

## Previous: 2026-08-20 — Product Page UI Upgrade (Bento Inventory) 🎨

### What Was Done
1. **ProductListPage full redesign** — new "Bento Inventory" UI (`product_list_page.dart`):
   - **Category rail** (left, 92px): vertical pill rail with icon + label + count badge, animated selection (scale spring + glow shadow)
   - **Bento grid** (right): rhythm `[featured, pair, pair]` — featured full-width card (image + stock progress bar), normal 2-col tiles (image top + price + stock dot + unit chip + category)
   - **Search bar**: rounded pill + scanner button (gradient), clear (X) button, no more barcode validator on search field
   - **Expandable FAB**: tap = Add, expands to reveal "Scan barcode" mini-FAB (easeOutBack + fade)
   - **Motion**: `_StaggerIn` staggered fade+slide entrance (keyed by product id — filter/search pe re-animate nahi hota), `_Pressable` tap scale 0.97 + haptic, Hero flight list→detail
   - **States**: skeleton shimmer loading, animated empty state + CTA, no-match state with clear button
   - **RefreshIndicator** → reload products; sort + export/import menus retained
2. **Bug fixes**:
   - `realtime_service.dart` — DELETE events drop ho rahe the (newRecord empty on delete → shop filter `oldRecord['shop_id']` se read karo). Ab deleted products realtime me list se hat jayenge.
   - `edit_product_page.dart` — barcode scan field ab `TextEditingController` use karta hai (pehle `initialValue` + setState se scanned barcode field me dikhta hi nahi tha)
   - `product_detail_page.dart` — image pe `Hero` add (list→detail flight)
3. **Navigation:** sab existing routes same — detail/edit/add/qr untouched

### flutter analyze
- Meri files: 0 errors ✅ (product_list_page, realtime_service, edit_product_page clean)
- ⚠️ Pre-existing errors `category_list_page.dart` (uncommitted kaam me): `context.go` undefined, `theme` undefined — is session me touch nahi kiya, baaki session me fix karna hai

---

## Previous: 2026-08-20 — Product Management Enhancements ✅

### What Was Done
1. **Product Management Enhancements** — 6 major features added:

   **Database (Supabase Migration)**:
   - `012_add_product_enhancements.sql`: Added `min_stock_level`, `unit` columns to products table
   - Created `stock_adjustments` table for tracking stock movements
   - RLS policies for stock_adjustments (shop_id scoped)
   - Indexes for performance

   **New Packages Added**:
   - `image_picker: ^1.1.2` — Camera/Gallery image selection
   - `flutter_image_compress: ^2.3.4` — 90% image compression
   - `csv: ^6.0.0` — CSV export/import
   - `file_picker: ^8.0.3` — File picking for CSV import

   **Domain Layer**:
   - `Product` entity updated: Added `minStockLevel` (default: 5), `unit` (default: 'pcs')
   - `StockAdjustment` entity: id, productId, previousStock, newStock, quantityChanged, reason, note, createdAt, createdBy
   - `StockRepository` interface: adjustStock, getStockHistory, getAllAdjustments

   **Data Layer**:
   - `ProductModel` updated with min_stock_level, unit fields
   - `ProductRepositoryImpl` updated with new fields in all queries
   - `StockRepositoryImpl`: Full Supabase implementation with stock adjustment tracking

   **BLoC Layer**:
   - `StockBloc`: AdjustStock, LoadStockHistory, LoadAllAdjustments events
   - State: status, adjustments, message

   **Presentation Layer**:
   - `AddProductPage`: Image picker (Camera/Gallery) + auto-compress + unit dropdown + min stock level input
   - `EditProductPage`: Same image picker support + new fields
   - `ProductListPage`: Sort options (Newest, Price Low/High, Name A-Z, Stock Low) + Export/Import CSV buttons + Unit badge + Low stock warning icon
   - `ProductDetailPage`: Unit badge, Min Stock Level display, Stock Status indicator, Stock Adjustment section with +/- buttons, Reason dialog (Sale, Damage, Return, Sample, Theft, Restock, Found, Adjustment)

   **Utilities**:
   - `ImageCompress`: 90% compression utility for Supabase free tier storage
   - `CsvExportImport`: Export products to CSV, Import from CSV

   **DI Registration**:
   - `StockRepository` + `StockBloc` registered in service_locator.dart

   **Migration Required**:
   - Run `012_add_product_enhancements.sql` in Supabase SQL Editor

---

## Previous Session: 2026-08-19 — Due Payments Management Feature ✅

### What Was Done
1. **Due Payments Management Feature** — complete implementation for tracking partial payments:

   **Database (Supabase Migration)**:
   - `011_add_due_payments.sql`: Added `amount_paid`, `due_amount`, `payment_status` columns to bills table
   - Added index on `payment_status` for fast queries
   - Created `due_payments_view` for pending dues

   **Domain Layer**:
   - `DuePayment` entity: billId, customerName, customerPhone, grandTotal, amountPaid, dueAmount, paymentMethod, staffName, billDate
   - `DuePaymentsRepository` interface: getDuePayments, getTotalPendingDue, collectPayment, getBillForDuePayment

   **Data Layer**:
   - `DuePaymentsRepositoryImpl`: Full Supabase implementation with shop_id scoping, search, payment collection

   **BLoC Layer**:
   - `DuePaymentsBloc`: LoadDuePayments, CollectPayment, SearchDuePayments events
   - State: duePayments, totalPendingDue, isLoading, isCollecting, error, successMessage, searchQuery

   **Presentation Layer**:
   - `DuePaymentsPage`: Orange gradient card showing total pending due, search bar, list of due payments with collect button
   - Collect Payment Dialog: Shows bill total, paid amount, due amount, input field for new payment
   - Full dark mode support

   **Integration**:
   - CheckoutPage: Added "Payment" section with amount paid input field + due amount badge
   - BillingState: Added `amountPaid` field
   - BillingBloc: Added `UpdateAmountPaidEvent` + updated `_onSubmitBill` to save payment status
   - ReceiptPreviewPage: Shows due amount if partial payment (orange card with paid/due breakdown)
   - Routes: Added `/due-payments` route with BlocProvider
   - AppDrawer: Added "Due Payments" menu item under "Payments" section
   - ServiceLocator: Registered DuePaymentsRepository + DuePaymentsBloc

   **RPD.md Updated**: Added Section 9 (Due Payments Management) with all features

### Files Created/Modified
- `supabase/migrations/011_add_due_payments.sql` (NEW)
- `lib/features/due_payments/domain/entities/due_payment.dart` (NEW)
- `lib/features/due_payments/domain/repositories/due_payments_repository.dart` (NEW)
- `lib/features/due_payments/data/repositories/due_payments_repository_impl.dart` (NEW)
- `lib/features/due_payments/presentation/bloc/due_payments_bloc.dart` (NEW)
- `lib/features/due_payments/presentation/bloc/due_payments_event.dart` (NEW)
- `lib/features/due_payments/presentation/bloc/due_payments_state.dart` (NEW)
- `lib/features/due_payments/presentation/pages/due_payments_page.dart` (NEW)
- `lib/features/report/domain/entities/report_entities.dart` (UPDATED)
- `lib/features/report/data/models/report_models.dart` (UPDATED)
- `lib/features/billing/presentation/bloc/billing_state.dart` (UPDATED)
- `lib/features/billing/presentation/bloc/billing_event.dart` (UPDATED)
- `lib/features/billing/presentation/bloc/billing_bloc.dart` (UPDATED)
- `lib/features/billing/presentation/pages/checkout_page.dart` (UPDATED)
- `lib/features/billing/presentation/pages/receipt_preview_page.dart` (UPDATED)
- `lib/config/routes/app_routes.dart` (UPDATED)
- `lib/config/routes/app_shell.dart` (READ ONLY)
- `lib/core/widgets/app_drawer.dart` (UPDATED)
- `lib/core/service_locator.dart` (UPDATED)
- `RPD.md` (UPDATED)
- `memory.md` (UPDATED)

---

## Current Session: 2026-07-24 — Advanced Dashboard Analytics (fl_chart + 4 new widgets) ✅

### What Was Done
1. **Added `fl_chart: ^0.69.0`** to pubspec.yaml — zero chart libraries earlier, now have pie/bar/line charts
2. **4 new analytics widgets created** in `lib/core/widgets/`:
   - `payment_donut_chart.dart` — Pie chart: UPI/Cash/Card/Credit breakdown with percentages + bill counts
   - `top_products_bar_chart.dart` — Horizontal-ish bar chart: top 5 products by quantity sold, color-coded by revenue
   - `monthly_trend_card.dart` — FL line chart: 30-day sales trend with tooltips + total/avg chips
   - `staff_performance_card.dart` — Progress bars + rank badges: staff leaderboard by revenue (owner-only)
3. **Dashboard layout updated** (`dashboard_page.dart`):
   - Quick Actions moved UP — right after Today's Sales, before Weekly Trend
   - Payment Donut + Top Products added between Weekly Trend and Inventory Health
   - Monthly Trend + Staff Performance added after Recent Transactions
   - `LoadSalesRange` event added to initState + onRefresh for 30-day data
4. **All helpers made public** — `ProductSales`, `ProductAggregator`, `StaffStat`, `StaffAggregator` renamed from private (no `_`) so dashboard can use them
5. **Fixed lint errors**: pct scope, private types in public API, num→int type mismatch, unused variables, unnecessary toList

### Dashboard Layout (final)
```
GreetingHeader
Low Stock Banner
Today's Sales (4 PremiumStatCards)
Quick Actions (DashboardActionCard + 6 tiles)
This Week (SalesTrendCard — 7-day CustomPainter)
Payment Methods Donut (fl_chart Pie)
Top Products Bar Chart (fl_chart Bar)
Inventory Health
Recent Transactions
Monthly Trend (fl_chart Line — 30-day)
Staff Performance (owner-only)
```

### Analytics Data Pipeline
- Payment donut + top products: derived from `ReportBloc.billHistory` (client-side aggregation)
- Monthly trend: derived from `ReportBloc.salesRange` (fetch via `LoadSalesRange`)
- Staff performance: derived from `ReportBloc.billHistory` + owner-only guard

### flutter analyze
- 0 errors, 0 warnings ✅ (only 2 pre-existing info on add/edit product pages)

---

## Current Session: 2026-07-23 — Dark Mode: Auth/Category/Report/Shop/Staff Pages ✅

### What Was Done
1. **15 files updated for dark mode** — all hardcoded Colors replaced with `Theme.of(context)` based colors:
   - **Auth pages (4)**: `login_page.dart`, `register_page.dart`, `email_verification_page.dart`, `auth_gate.dart` (no changes needed)
   - **Category pages (2)**: `category_list_page.dart`, `add_edit_category_dialog.dart` (no changes needed)
   - **Report pages (6)**: `reports_home_page.dart`, `bill_history_page.dart`, `bill_detail_page.dart`, `daily_sales_page.dart`, `low_stock_page.dart`, `stock_movement_page.dart`
   - **Shop page (1)**: `shop_details_page.dart`
   - **Staff pages (2)**: `staff_list_page.dart`, `add_staff_page.dart`

### Key Replacements
- `Colors.white` backgrounds → `theme.colorScheme.surface`
- `Colors.black87`/`Colors.black` text → `theme.colorScheme.onSurface`
- `Colors.grey[100]` borders → `theme.dividerColor`
- `Colors.grey[400/500/600]` meta/icons → `theme.colorScheme.onSurfaceVariant`
- `Colors.red` snackbars → `theme.colorScheme.error`
- `Colors.green` success snackbars → `theme.colorScheme.primaryContainer`
- `Colors.grey[200]` container bg → `theme.colorScheme.surfaceContainerHighest`
- `Colors.white` CircularProgressIndicator on buttons → `theme.colorScheme.onPrimary`
- `Colors.grey[300]` borders → `theme.colorScheme.outlineVariant`
- `Colors.black12` boxShadow kept as-is (works in both modes)

### flutter analyze
- 0 errors, 0 warnings ✅

---

## Current Session: 2026-07-23 — Full Dark Mode Implementation 🎨🌙

### What Was Done
A. **Core Theme Infrastructure**
1. **New: `theme_cubit.dart`** — ThemeMode Cubit with Hive persistence (reads/writes 'theme_mode' key in settings box). Supports light/dark/system modes.
2. **Updated: `app_theme.dart`** — Added `AppTheme.darkTheme` with full dark color scheme:
   - `darkBackground: #0E0E18`, `darkSurface: #1A1A2E`, `darkCard: #22223A`, `darkInput: #2A2A42`
   - Dark `ColorScheme.fromSeed` with `Brightness.dark`, error color `#CF6679`
   - All widget themes adapted: AppBar, Card, InputDecoration, ElevatedButton, Dialog, SnackBar, FAB, Switch
   - Added `AppTheme.darkGradient` for dashboard background + `AppTheme.gradientFor(context)` helper
   - Shared `_baseInputTheme()` avoids color duplication between light/dark
3. **Updated: `text_styles.dart`** — Added `AppTextStyles.of(context)` that returns `_AdaptiveTextStyles` with colors resolved per brightness (`onSurface`, `onSurfaceVariant`, etc.). Old static consts preserved for backward compat.
4. **Updated: `service_locator.dart`** — Registered `ThemeCubit` as singleton
5. **Updated: `main.dart`** — Added `ThemeCubit` BlocProvider, wrapped MaterialApp.router in `BlocBuilder<ThemeCubit, ThemeMode>` with `darkTheme: AppTheme.darkTheme` and `themeMode: themeMode`

B. **Shared Widgets**
6. **Updated: `glass_card.dart`** — Dynamic tint/border/shadows based on brightness (white glass in light, dark surface glass in dark)
7. **Updated: `app_drawer.dart`** — All hardcoded `Colors.grey[]` replaced with `theme.colorScheme.onSurface`, `onSurfaceVariant`, `dividerColor`, etc.
8. **Updated: `settings_page.dart`** — Added "Appearance" section with Dark Mode Switch toggle + all colors made theme-aware

C. **Billing + Product Pages (9 files) — Dark Mode Color Replacements**
9. **`receipt_preview_page.dart`** — Fixed: `Colors.white` → `surface`, `Colors.black54/45/38/87` → `onSurface`/`onSurfaceVariant`, `Colors.red` snackbars → `colorScheme.error`, `Colors.blue` done btn → `colorScheme.primary`
10. **`scanner_page.dart`** — Fixed: Permissions prompt uses theme colors, `const` removed from Positioned/TextStyle using `Theme.of(context)`
11. **`checkout_page.dart`** — Fixed: All `Colors.white` containers → `surface`, `Color(0xFFF8FAFC)` header → `surfaceContainerHighest`, `borderColor` → `dividerColor`, `Color(0xFF0F172A)` totals → `onSurface`, `Colors.red` → `error`, custom price styling uses `tertiary`/`surfaceContainerHighest`, UPI warning uses `errorContainer`
12. **`home_page.dart`** — Fixed: `Colors.white` card bg → `surface`, `Colors.grey[100]`/`[200]` → `surfaceContainerHighest`/`dividerColor`, `Colors.grey[600]` meta → `onSurfaceVariant`, `Colors.red` snackbar → `error`, empty cart icon uses surfaceContainerHighest. Camera overlay colors kept intentionally (dark for visibility over live feed)
13. **`product_list_page.dart`** — Fixed: `borderColor` → `dividerColor`, `Colors.white` cards → `surface`, `Color(0xFF0F172A)` → `onSurface`, `Color(0xFFF1F5F9)` placeholder → `surfaceContainerHighest`, `Color(0xFF94A3B8)` icons → `onSurfaceVariant`, `Color(0xFF4C669A)` hint → `primary.withAlpha`
14. **`add_product_page.dart`** — Fixed: `Colors.grey[100]` bottom sheet bg → `surfaceContainerHighest`, `Colors.black` price prefix → `onSurface`, `Colors.black87` → `onSurface`, bottom sheet bg `Colors.white` → `surface`, `Colors.red` snackbar → `error`, `const` removed where Theme.of used
15. **`edit_product_page.dart`** — Fixed: `Colors.black` price prefix → `onSurface`, `Colors.grey[100]` bottom sheet → `surfaceContainerHighest`, `Colors.black87` → `onSurface`, bottom sheet `Colors.white` → `surface`
16. **`product_detail_page.dart`** — Fixed: `Colors.black87` product name → `onSurface`, `Colors.grey[200]` containers → `surface` + `dividerColor`, `Colors.grey[500]` labels → `onSurfaceVariant`, `Colors.red` delete → `error`, `Colors.white` → `surface`. `_placeholder()` reverted to hardcoded grey (no build context available in errorBuilder)
17. **`qr_generator_page.dart`** — Fixed: QR container `Colors.white` → `surface`, `Colors.grey[200]` placeholder → themed, `Colors.black` QR dot → `onSurface`, `Colors.grey[600]` barcode → `onSurfaceVariant`, button foregrounds → `surface`, `Colors.green` snackbar → `primary`

### Design System Changes
- `design.md` updated with full dark mode documentation
- Dark mode toggle: Settings page → Appearance → Dark Mode toggle
- All GlassCard, PremiumStatCard, DashboardActionCard auto-adapt to dark

### What Was Done
1. **Removed dead notification icon** from AppBar — sirf search icon rah gaya
2. **Fixed GreetingHeader double-padding** — outer padding (20,18) → (16,16); GreetingHeader owns its own padding now
3. **Standardized section spacing** — all gaps normalized to 16/24 cadence throughout dashboard
4. **Added haptic feedback** — DashboardActionCard + all 6 QuickActionTiles call `HapticFeedback.lightImpact()` before navigation
5. **Improved `_sectionTitle`** — horizontal padding 4→16, fontSize 13, letterSpacing 0.8, color #787880 for subtle section labels
6. **Tabular figures for numbers** — `fontFeatures: [FontFeature.tabularFigures()]` added to statValue, statLabel, txnAmount, trendChipValue text styles + bodyLarge in app_theme + premium_stat_card value display
7. **4-color AI gradient replaced** — lavender→blue→purple→green removed, cleaner 3-color `aiGradient` (lavender→light blue→cyan tint) added in AppTheme + dashboard page uses it
8. **HapticFeedback import** — `flutter/services.dart` added to dashboard_action_card.dart (was causing compile error after agent edit)

### Files Modified
- `lib/features/dashboard/presentation/pages/dashboard_page.dart` — notification icon, spacing, haptics, _sectionTitle, gradient, services import
- `lib/core/widgets/greeting_header.dart` — outer padding fix
- `lib/core/widgets/dashboard_action_card.dart` — haptic feedback + services import
- `lib/core/widgets/premium_stat_card.dart` — tabular nums on value text
- `lib/core/theme/text_styles.dart` — tabular nums on 4 text styles
- `lib/core/theme/app_theme.dart` — aiGradient, tabular nums on bodyLarge
- `lib/core/widgets/sales_trend_card.dart` — const constructor fix for pending warnings

### What Was Done
1. **Removed dead notification icon** from AppBar actions — only search icon remains
2. **Fixed GreetingHeader double-padding** — outer padding in dashboard_page.dart reduced from (20,18) to (16,16); GreetingHeader itself now owns its (20,18) padding — no double margin
3. **Standardized section spacing** — all section gap SizedBox heights normalized to 16/24 cadence:
   - greeting to low stock: 8→16
   - section→card gaps: 8→16, 12→16
   - card→next section: 20→24, 14→16
   - Inventory Health→Recent Transactions: 20→24
   - Recent Transactions→bottom: 16 (kept)
4. **Added haptic feedback** — all 6 QuickActionTiles now call `HapticFeedback.lightImpact()` before navigation (DashboardActionCard + 5 tiles in GridView + conditional Staff tile)
5. **Improved `_sectionTitle`** — horizontal padding 4→16, fontSize 13, letterSpacing 0.8, color #787880 for a subtle section label look

### Files Modified
- `lib/features/dashboard/presentation/pages/dashboard_page.dart` — notification icon removal, spacing, haptics, _sectionTitle + `flutter/services.dart` import
- `lib/core/widgets/greeting_header.dart` — outer padding (20,18) → (16,16)

### flutter analyze
- 0 errors, 0 warnings ✅ — 1 info-level false positive (FontFeature factory constructor) left

---
## Current Session: 2026-07-23 — prefer_const_constructors Lint Warnings Fix ✅

### What Was Done
1. **Fixed 10 `prefer_const_constructors` Dart analyzer warnings** across 4 files:
   - `inventory_health_card.dart`: +3 const (Text widgets lines 33, 47, 75)
   - `recent_transactions_card.dart`: +4 const (Text widgets lines 125, 131, 262, 268)
   - `sales_trend_card.dart`: +2 const (Text widgets lines 54, 104)
   - `dashboard_page.dart`: +1 const (Text widget line 451)
2. **Purpose**: Performance optimization — const widgets are cached at build time, not recreated on every rebuild
3. **4 parallel agents** used (Haiku model) for concurrent fixes across all files

### Files Modified
- `lib/core/widgets/inventory_health_card.dart`
- `lib/core/widgets/recent_transactions_card.dart`
- `lib/core/widgets/sales_trend_card.dart`
- `lib/features/dashboard/presentation/pages/dashboard_page.dart`

### flutter analyze
- 0 errors, 0 warnings ✅ (entire project clean after all fixes)

---
## Current Session: 2026-07-23 — Stock Decrease/Increase Logic Audit + Realtime ✅

### What Was Done
1. **Stock logic full audit** — billing_bloc + report_repository dono sides check kiye:
   - Submit pe stock decrease → fresh DB fetch add kiya (race condition fix)
   - Delete/edit bill pe stock increase → already working (fresh stock fetch + diff logic)
   - inventory_log shop_id → already present (was missing in my initial audit)

2. **Bug Fix — Race condition in _onSubmitBill** (CRITICAL):
   - **Root Cause**: `item.product.stock` cached value use karta tha → agar bill submit ke beech mein koi aur session stock change karde, stock negative ho sakta tha
   - **Fix**: Fresh DB fetch (`SELECT stock` from products) → then subtract quantity
   - Same pattern already used in report_repository_impl.dart for delete/edit

3. **Realtime stock updates on checkout page**:
   - BillingBloc pe Supabase realtime subscription added (products table)
   - Agar cart mein product hai + DB mein stock change hua → instant cart update
   - Red/Orange "Insufficient Stock" / "Low Stock" badges live update hote hain
   - `close()` pe subscription cleanup hota hai

4. **Verified Bug 2 already fixed** — inventory_log insert mein `shop_id` already present tha

### Files Modified
- `lib/features/billing/presentation/bloc/billing_bloc.dart` — race condition fix + realtime subscription
- `lib/features/billing/presentation/bloc/billing_event.dart` — _ProductStockUpdatedEvent added

### flutter analyze
- 0 errors, 0 warnings ✅ (entire project)

### Graphify
- Updated: 1845 nodes, 2850 edges, 151 communities

---

## Current Session: 2026-07-22 — Stock Revert Bug Fix (deleteBill + updateBill) ✅

### What Was Done
1. **Fixed stock not reverting on bill delete** — `report_repository_impl.dart`:
   - **Root Cause**: `deleteBill()` aur `updateBill()` mein stock operations `shop_id` filter se wrapped the. Agar product ya bill_item ka `shop_id` NULL hai (migration 004 se pehle bane records), toh `maybeSingle()` null return karta tha aur stock update **silently skip** ho jaata tha. Bill delete hota tha but stock revert nahi hota.
   - **Fix**: 
     - `deleteBill()`: bill_items fetch, stock restore, bill_items delete, bill delete — sab se `shop_id` filter hata diya (UUIDs unique hain)
     - `updateBill()`: 4 jagah stock operations (removed items restore, modified items diff, new items deduct, existing items fetch) se `shop_id` filter hata diya
   - **Why safe**: bill_id, product_id, bill_item_id sab UUIDs hain jo globally unique hain — shop_id filter redundant tha stock operations ke liye

### Files Modified
- `lib/features/report/data/repositories/report_repository_impl.dart` — deleteBill + updateBill methods

### flutter analyze
- 0 errors ✅

---

## Current Session: 2026-07-22 — Bill Delete Stock Restoration Fix ✅

### What Was Done
1. **Fixed bill delete not restoring stock** — `deleteBill()` method rewrite:
   - **Root Cause**: Pehle sirf `bills` table se delete hota tha, stock restore nahi hota tha
   - **Fix**: 
     1. Bill items fetch karo (delete se pehle)
     2. Har item ka stock restore karo (`currentStock + item.quantity`)
     3. Inventory log entry banao (`change_type: 'return'`)
     4. Bill items delete karo
     5. Bill delete karo

### Files Modified
- `lib/features/report/data/repositories/report_repository_impl.dart` — complete deleteBill rewrite

### flutter analyze
- 0 errors ✅

---

## Current Session: 2026-07-22 — Bill History Product Search ✅

### What Was Done
1. **Added product name search to Bill History** — ab customer name, bill ID, aur product name teeno searchable hain
   - **Root Cause**: Pehle sirf `customer_name` aur `id` pe server-side filter tha
   - **Solution**: Client-side filtering - pehle 100 bills fetch (with items), phir Dart mein filter
   - Searches: `customerName`, `bill.id`, `bill.items[].productName`
2. **Hint text updated**: "Search by customer, bill ID, or product"

### Files Modified
- `lib/features/report/data/repositories/report_repository_impl.dart` — client-side product search logic
- `lib/features/report/presentation/pages/bill_history_page.dart` — hint text update

### flutter analyze
- 0 errors ✅

---

## Current Session: 2026-07-22 — Bill History "0 Items" Bug Fix ✅

### What Was Done
1. **Fixed "0 Items" bug in Bill History** — screenshot se issue identify kiya:
   - **Root Cause**: `getBillHistory()` query mein `bill_items` table include nahi tha
   - `select('*, profiles(name)')` → `select('*, profiles(name), bill_items(*)')`
   - `BillSummaryModel.fromSupabaseRow` mein fallback add kiya: jab `bill_items` na ho to `item_count` column se value le

### Files Modified
- `lib/features/report/data/repositories/report_repository_impl.dart` — query fix
- `lib/features/report/data/models/report_models.dart` — fallback logic

### flutter analyze
- 0 errors ✅

---

## Current Session: 2026-07-22 — Cash/UPI Payment Selector in Checkout ✅

### What Was Done
1. **Conditional QR & Payment Toggle** on `CheckoutPage`:
   - Material 3 `SegmentedButton` toggle for 'Cash' vs 'UPI'.
   - Cash selected by default; if selected, hides the Scan to Pay QR code area.
   - If UPI is selected, shows the QR code.
2. **Fixed BLoC Missing Implementation**:
   - Implemented the registered but empty handler `_onUpdatePaymentMethod` in `billing_bloc.dart`.
3. **Fixed Receipt Preview Parameter**:
   - Replaced hardcoded `'paymentMethod': 'UPI'` in navigation extra parameters with dynamic `state.paymentMethod` to ensure the receipt correctly outputs the actual user selection.
4. **Verification**:
   - Ran `flutter analyze` ensuring 0 warnings / errors.

---

## Current Session: 2026-07-22 — Full Bill Edit Feature ✅

### What Was Done
1. **Full Bill Edit Feature** — edit dialog ab pura receipt edit kar sakta hai:
   - **Payment method** dropdown (upi/cash/card) — ab editable
   - **Items editing** — quantity +/- controls, remove items, add new items
   - **Product search** — dialog se products search karke bill mein add kar sakte ho
   - **Stock management** — automatic stock adjustment:
     - Qty increase → stock kam
     - Qty decrease → stock badhao
     - Item remove → stock restore
     - New item add → stock deduct
   - **Live totals** — dialog mein total/grand total real-time update
   - **Inventory logging** — har change ka inventory_log entry

### Files Modified (7 files)
- `lib/features/report/domain/usecases/report_usecases.dart` — `UpdateBillParams` mein `List<BillItem>? items` add
- `lib/features/report/domain/repositories/report_repository.dart` — `updateBill` signature update with items param
- `lib/features/report/data/repositories/report_repository_impl.dart` — full rewrite: item diff, stock management, inventory logging
- `lib/features/report/presentation/bloc/report_event.dart` — `UpdateBill` event mein items field add
- `lib/features/report/presentation/bloc/report_bloc.dart` — handler mein items pass to use case
- `lib/features/report/presentation/pages/bill_detail_page.dart` — complete edit dialog rewrite with items UI + product search

### Architecture Notes
- Items diff by `productId` — compare existing DB items vs new items
- Stock fetched from DB before each adjustment (not stale cache)
- No database transaction wrapping (same as existing billing flow)
- `uuid` package used for new bill_item IDs

### flutter analyze
- 0 errors, 0 warnings ✅

---

## Current Session: 2026-07-22 — Bill Edit/Delete + Manual Product Entry ✅

### What Was Done
1. **Agent A: Bill Edit/Delete (Owner Only)** — `bill-details-edit-delete` worktree
   - Owner ke liye AppBar mein edit + delete buttons
   - Staff ko kuch nahi dikhta (read-only)
   - Edit: Customer name, phone, discount change → DB update + page refresh
   - Delete: Confirmation dialog → DB delete + bill history pe redirect
   - 8 files modified: repository, usecase, events/states/bloc, service_locator, bill_detail_page
   - `flutter analyze`: 0 issues ✅

2. **Agent B: Manual Product Entry on Scanner Page** — `manual-product-entry` worktree
   - Keyboard icon button on scanner (below flashlight toggle)
   - Dialog opens: TextFormField for barcode + "Add to Cart" button
   - "Create New Product" fallback → navigates to `/products/add`
   - Reuses existing ScanBarcodeEvent pipeline — zero new BLoC changes
   - `flutter analyze`: 0 issues ✅

3. **Bug Fix** — `const ResetReport()` → `ResetReport()` (non-const constructor) in report_bloc.dart

### Orca Orchestration
- 2 parallel worktree agents launched via Orca CLI
- Agents explored, planned, and implemented independently
- Code reviewed + analyze check before merging to main
- Worktrees to be cleaned up after session
   - `QuickActionTile` — glass grid tiles
4. **Dashboard page** — complete layout redesign:
   - 4-color gradient background (lavender → blue → purple → green)
   - SliverAppBar (floating + snap) instead of regular AppBar
   - CustomScrollView for smooth scrolling
   - Advanced stats: weekly sales trend, recent transactions, inventory health
   - All existing features preserved: greeting, sales, quick actions, low stock, search
5. **Text color fixes** — PremiumStatCard + DashboardActionCard use dark/colored text (not white) for readability on light glass backgrounds
6. **GreetingHeader fix** — removed boxShadow that doesn't render on BackdropFilter

### Design System Changes
- Design language: Material 3 → Liquid Glass / Glassmorphism
- Background: flat `#F2F2F7` → 4-color gradient
- Cards: solid/surface → `BackdropFilter` + semi-transparent glass
- Borders: none/grey → subtle white glass borders (0.20 alpha)

### Files Modified
- `lib/core/widgets/glass_card.dart` — NEW
- `lib/core/widgets/sales_trend_card.dart` — NEW
- `lib/core/widgets/recent_transactions_card.dart` — NEW
- `lib/core/widgets/inventory_health_card.dart` — NEW
- `lib/core/widgets/premium_stat_card.dart` — glass redesign
- `lib/core/widgets/greeting_header.dart` — glass redesign
- `lib/core/widgets/dashboard_action_card.dart` — glass redesign
- `lib/features/dashboard/presentation/pages/dashboard_page.dart` — complete redesign
- `design.md` — updated design system docs

### flutter analyze
- 0 errors, 0 warnings, 0 infos across entire project ✅

---

## Current Session: 2026-07-22 — PremiumStatCard BackdropFilter GPU Fix ✅

### What Was Done
1. **Removed BackdropFilter from PremiumStatCard** — `lib/core/widgets/premium_stat_card.dart`:
   - Removed `import 'dart:ui'` (no longer needed for ImageFilter)
   - Removed `ClipRRect` wrapper + `BackdropFilter(filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18))`
   - Kept the inner Container with semi-transparent glass decoration (color.withValues(alpha: 0.13), white border)
   - **Why**: BackdropFilter is extremely GPU-expensive when 15+ cards are on screen — causes frame drops
   - **Visual impact**: None — the semi-transparent tint + white border already gives the frosted glass look

---

## Current Session: 2026-07-21 — Billing History Section Audit + Warnings Fix ✅

### What Was Done
1. **Deep audit of bill history section** — traced full data flow across report feature (entities → models → repos → BLoCs → pages)
2. **Found issues**: BillDetailPage didn't render individual items, no search/filter on history, no print/receipt buttons, warnings in repo
3. **Fixed warnings**:
   - `report_repository_impl.dart`: Removed 4 unnecessary `!` operators (searchQuery, paymentMethod)
   - `bill_detail_page.dart`: Added `// ignore_for_file: prefer_const_constructors` (TextStyle with runtime constant can't be const)
4. **Graphify updated** — code graph rebuilt: 1709 nodes, 2633 edges, 147 communities

### flutter analyze
- 0 errors, 0 warnings, 0 infos ✅

---

## Current Session: 2026-07-21 — Shop Isolation Audit & Fix ✅

### What Was Done
1. **Comprehensive shop isolation audit** — traced shop_id flow across DB, auth, repos, BLoCs, realtime, Hive
2. **Found 8 gaps** (4 critical, 2 high, 2 medium) where data could leak between shops
3. **Fixed all 8 gaps**:

| # | Severity | Fix | File |
|---|----------|-----|------|
| 1 | Critical | `CategoryRepositoryImpl.getCategories()` — added `_resolveShopId()` fallback so it never returns all shops' categories when shopId is null | `category_repository_impl.dart` |
| 2 | Critical | `ReportRepositoryImpl.getBillDetail()` — added shop_id filter to bill_items query (was missing entirely) | `report_repository_impl.dart` |
| 3 | Critical | `BillingBloc._onSubmitBill()` — added shop_id guard to stock update query | `billing_bloc.dart` |
| 4 | Critical | `RealtimeService.subscribeToProducts()` — added optional `shopId` param, filters events by shop_id before forwarding to BLoC | `realtime_service.dart` |
| 5 | High | `loginWithGoogle()` — added `_ensureShopForOwner()` so Google OAuth users get a shop created automatically | `auth_repository_impl.dart` |
| 6 | High | `Shop` entity — added `id` field so shop can be identified by shop_id in app | `shop.dart`, `shop_model.dart`, `shop_model.g.dart` |
| 7 | Medium | `StaffRepositoryImpl.deleteStaffMember()` — added shop_id filter for defense-in-depth | `staff_repository_impl.dart` |
| 8 | Medium | `ReportRepositoryImpl` — added `_resolveShopId()` to all 6 methods (bill history, bill detail, daily sales, sales range, low stock, stock movements) | `report_repository_impl.dart` |

### Architecture
- **3-layer isolation**: DB RLS (strongest) → App-side query filtering (medium) → BLoC-level shopId propagation (medium)
- **Consistent pattern**: ProductRepo, CategoryRepo, StaffRepo, ReportRepo now all use `_resolveShopId()` fallback
- **Realtime**: ProductBloc passes `shopId` to `subscribeToProducts()` so only own shop's events trigger reloads

### flutter analyze
- 0 errors, 0 warnings ✅

---
## Current Session: 2026-07-21 — Shop Persistence Fix + Final Cleanup ✅

### What Was Done
1. **Shop persistence bug fixed** — `shop_model.g.dart`, `shop_repository_impl.dart`, `shop_details_page.dart`:
   - Root cause: adding `id` field to `Shop` entity corrupted Hive field mapping (old 6-field data vs new 7-field adapter)
   - Fix: Hive adapter now backward-compatible — detects old 6-field data and maps correctly
   - Fix: `ShopRepositoryImpl.getShop()` now falls back to Supabase `shops` table if Hive data missing/corrupt
   - Fix: `_updateControllers` in ShopDetailsPage always syncs (removed empty check that prevented reload)
2. **BillingBloc warning fixed** — `billing_bloc.dart`:
   - Removed unnecessary null check on `shopId` (already guarded by early return on line 244)

### flutter analyze
- 0 errors, 0 warnings ✅

---

### What Was Done
1. **Single-line meta row** — `product_list_page.dart`:
   - Line 1: Product Name
   - Line 2: ₹Price · Stock: N · 📂Category · 📍Location — sab ek hi row mein, dot separators (`·`) se
   - Line 3: Description snippet (only when search matches)
2. **More compact**: vertical padding reduced from 12px to 10px
3. Added `_dotSeparator()` helper for clean visual separation

### flutter analyze
- 0 errors, 0 warnings ✅

---

## Current Session: 2026-07-21 — Fixed Category "All" Selection Not Clearing ✅

### What Was Done
1. **Fixed "All" category selection bug** — `product_bloc.dart` + `product_state.dart`:
   - `ProductState.copyWith()` ki bug fix ki: `null ?? this.selectedCategoryId` old value preserve kar raha tha.
   - Added `clearSelectedCategory: true` param in bloc.
2. **Result**: Ab "All" chip par click karne par "hi" category ka highlight instantly clear ho jata hai!

### flutter analyze
- 0 errors, 0 warnings ✅

---

## Current Session: 2026-07-21 — Fixed Category Chip Highlight State Sync ✅

### What Was Done
1. **Fixed Category Chip Selection Sync** — `product_list_page.dart`:
   - Removed nested `BlocBuilder<CategoryBloc>` wrapper around `BlocBuilder<ProductBloc>` that was causing a state rebuild race.
   - Now directly listens to `ProductBloc` state so `selectedCategoryId == null` ("All" tab) highlights instantly and reliably when clicked.

### flutter analyze
- 0 errors, 0 warnings ✅

---

## Current Session: 2026-07-28 — README.md Owner-Focused Rewrite ✅

### What Was Done
1. **README.md completely rewritten** — reorganized for shop owners as primary audience
2. **Key changes**:
   - **Hero section**: "The last billing app your phone shop will ever need" — direct to owners
   - **"Why Shop Owners Love This App" table**: pain points → solutions format (owners scan this first)
   - **Owner's Checklist**: all features grouped by business value (Inventory → Billing → Staff → Analytics → Reports → Settings)
   - **Analytics widgets table**: what each chart tells owners
   - **"Who This Is For" closing section**: phone shops, accessories shops, small retail
   - **Screens table**: route → what owner sees
   - Roles table reframed from "technical roles" to "who does what"
   - Tech stack still present but de-emphasized (owners care about features, not frameworks)
   - Getting started simplified to "5 minutes"
   - "Pain Point → Solution" layout throughout — owners self-identify instantly
3. **All features preserved**: Supabase, Realtime, staff mgmt, QR gen, thermal printing, UPI, dashboards, offline-first, 3-tier roles, all 11 features
4. **What was NOT changed**: code, dependencies, CLAUDE.md, RPD.md, architecture.md, phases.md, design.md, rules.md

---

## Current Session: 2026-07-28 — README.md Update ✅

### What Was Done
1. **README.md completely rewritten** — old version was missing Supabase, Realtime, staff management, dashboard analytics, QR code generation, and all features added after initial scaffold
2. **Updated content includes**:
   - Full feature list (scanner, cart, thermal printing, UPI QR, inventory, staff mgmt, analytics)
   - Complete tech stack table with all dependencies
   - Feature structure with all 11 features listed (auth, billing, product, category, shop, settings, report, staff, dashboard)
   - 3-Tier Role System (Super Admin / Owner / Staff) with access table
   - Shop Isolation explanation (3 layers: RLS, repo filtering, BLoC propagation)
   - Real-time sync details
   - Dashboard analytics widget table
   - Updated getting-started guide with all migrations listed
   - Contributing guidelines updated with current conventions
   - Project docs reference table
3. **Old README gaps fixed**:
   - Was Hive-only, no mention of Supabase cloud sync
   - No staff management section
   - No QR code generation feature
   - No analytics/dashboard section
   - No real-time sync
   - Missing features: category CRUD, shop settings, report system, 3-tier roles

### What Was NOT Changed
- CLAUDE.md, RPD.md, architecture.md, phases.md, design.md, rules.md — these are authoritative docs
- No code changes, no dependency changes

---

## Current Session: 2026-07-21 — Fixed Category Switch Animation Glitch ✅

### What Was Done
1. **Fixed Category Transition Animation Glitch** — `product_list_page.dart`:
   - Removed `TweenAnimationBuilder` entry slide animation that triggered on every category chip selection change.
   - Now switching between categories (e.g. Grocery → hi → All) updates instantly and smoothly without items animating in from bottom.

### flutter analyze
- 0 errors, 0 warnings ✅

---

## Current Session: 2026-07-21 — Cleaned up Flutter Analyzer Linter Suggestions ✅

### What Was Done
1. **Resolved 10 Linter Hints across project**:
   - `product_list_page.dart`: Removed unused `services.dart` import + added `const` constructors to widgets (BorderRadius, TextStyle, Icon, FilterByCategory).
   - `checkout_page.dart`: Added `const` to `TextInputType.numberWithOptions` & Padding widgets.
2. **Result**: `flutter analyze` runs completely clean with **0 errors, 0 warnings, 0 infos** ✅

---

## Current Session: 2026-07-21 — Description Match Snippet Highlight on Homepage Search ✅

### What Was Done
1. **Homepage Search Description Highlight** — `dashboard_page.dart` (`_ProductSearchDelegate`):
   - Updated search hint: `'Search product name, barcode or description'`
   - When search query matches `product.description`, an amber description snippet badge (`🔍 ...snippet...`) renders under the barcode row in search results list tile.
   - Consistent visual feedback with Product Management page search!

### flutter analyze
- 0 errors, 0 warnings ✅

---

## Current Session: 2026-07-21 — Description Match Snippet Highlight on Search ✅

### What Was Done
1. **Description Match Snippet Highlight** — `product_list_page.dart`:
   - When user searches and the `_searchQuery` matches `product.description`, a subtle amber badge tag (`_buildDescriptionSnippet`) appears on the card.
   - Shows extracted text snippet (with `...` prefix/suffix) surrounding the matched keyword.
   - Highlights with `Icons.saved_search_rounded` icon & Amber badge so user immediately sees *why* that product matched their search query.
2. **Visual Hierarchy Retained**:
   - Only displays description snippet when search query actually matches description (card remains ultra-compact during normal browsing).

### flutter analyze
- 0 errors, 0 warnings ✅

---

## Current Session: 2026-07-21 — Description Search on Product Management Page ✅

### What Was Done
1. **Added Description Search** — `product_list_page.dart`:
   - Updated product filtering to search against `product.description` (null-safe case-insensitive match):
     `(product.description?.toLowerCase().contains(_searchQuery) ?? false)`
   - Now searches 3 fields: Name, Barcode, **Description** (matches Dashboard search behavior)
   - Updated search input `hintText`: `'Search product name, barcode or description'`

### flutter analyze
- 0 errors, 0 warnings ✅

---

## Current Session: 2026-07-21 — Ultra-Compact Product Cards + Alignment Fix ✅

### What Was Done
1. **Compact & Balanced Layout** — `product_list_page.dart`:
   - Image/placeholder reduced: 52px → 44px (consistent vertical alignment)
   - Left accent bar: fills card height automatically (no hardcoded height)
   - Compact vertical padding: 12px (was 14px)
   - Font scale: Title 14px w700, Price 13px w600, Meta text 11px
   - Single-line meta row: Category + Location side-by-side with icon & spacing
   - Stock badge: compact padding, 11px font
   - Chevron: 18px slate-300
2. **Visual Hierarchy**:
   - Level 1 (Primary): Product Name (14px slate-900)
   - Level 2 (Secondary): Price (13px primaryColor) + Stock badge
   - Level 3 (Tertiary): Category & Location (11px slate-500, side-by-side)
3. **Clean Code**: Removed unused `_metaChip` method

### flutter analyze
- 0 errors, 0 warnings ✅

---

## Current Session: 2026-07-18 — Dashboard Premium Redesign ✅

### What Was Done
1. **Premium stat cards** — `lib/core/widgets/premium_stat_card.dart`:
   - `PremiumStatCard({label, value, color, icon?})`
   - Gradient background (color → 72% alpha), radius 20, colored shadow (blur 16, offset 0,6)
   - Icon chip: white 25% bg, radius 10; label: 12px w600 white 90%, letterSpacing 0.4
   - Value: 26px w800 white; removed Stack/watermark to avoid overflow
2. **Greeting header** — `lib/core/widgets/greeting_header.dart`:
   - `GreetingHeader({userName})` — avatar 48px gradient circle (primary → 70%), radius 16
   - Time-based greeting + date display + user initial avatar
3. **Dashboard action card** — `lib/core/widgets/dashboard_action_card.dart`:
   - `DashboardActionCard` → gradient bg (color → 82%), radius 20, animated entry scale 0.98→1.0 (1200ms)
   - `QuickActionTile` → radius 20, animated scale 0.85→1.0 (400ms easeOutBack), soft dual shadow
4. **Dashboard page** — `lib/features/dashboard/presentation/pages/dashboard_page.dart`:
   - Replaced `_Greeting` → `GreetingHeader(userName: 'San Mondal')`
   - Replaced `_TodaysSales` → 4 `PremiumStatCard`s (Total Sales green, Bills primary, Avg Bill orange, Discount pink)
   - Updated `_LowStockBanner` → gradient error banner with icon chip
   - Removed `_sectionTitle` helper, inline styling
   - Removed unused `stat_card.dart` import
   - Fixed `_ProductSearchDelegate.buildResults/buildSuggestions` return type `List<Widget>` → `Widget`
5. **Design docs** — `design.md`: updated component specs for all premium widgets + animation notes

### flutter analyze
- 0 errors, 0 warnings across all changed files ✅

### TODO
- [ ] Device pe verify: gradient cards + tiles render correctly
- [ ] Stagger animation verify: tiles load sequentially

---

## Current Session: 2026-07-18 — Product Card Tap + Description Copy + Extra Fields ✅

### What Was Done
1. **Product list card now tapable** — `product_list_page.dart`:
   - Entire card wrapped in `GestureDetector` → tap opens `/products/detail/:id`
   - Action buttons (QR, Edit, Delete) still work independently with `HapticFeedback.lightImpact()`
2. **Description copy button** — `product_detail_page.dart`:
   - Description row mein copy icon (clipboard) added
   - One-tap copy with SnackBar confirmation "Description copied!"
3. **Extra fields on detail page**:
   - Created date (`product.createdAt`) — formatted as dd/mm/yyyy
   - Updated date (`product.updatedAt`)
   - QR Data field
4. **Removed unused imports** — `dart:ui` removed from detail page

### flutter analyze
- Both files: 0 issues, 0 warnings ✅

---

## Current Session: 2026-07-18 — Product Detail Page + Dashboard Search Navigation ✅

### What Was Done
1. **Added product detail page** — `lib/features/product/presentation/pages/product_detail_page.dart`
   - Shows: image, name, barcode, price, stock, category, location, description, created/updated dates, QR data
   - Actions: Generate QR, Edit, Delete
2. **Route**: `/products/detail/:id`
3. **Dashboard search** → detail page navigation

---

## Current Session: 2026-07-18 — Dashboard Product Search ✅

### What Was Done
1. **Added product search to dashboard** — search icon in AppBar, SearchDelegate filtering by name/barcode
2. **Results show**: name, price, barcode → tap navigates to detail page

### flutter analyze
- 0 errors throughout ✅

---

## Current Session: 2026-07-21 — Product Detail Page 2-Column Grouped Layout ✅

### What Was Done
1. **Grouped detail rows** — `product_detail_page.dart`:
   - Price + Stock side-by-side in one row (Row of 2 cards)
   - Category + Location side-by-side
   - Created + Last Updated side-by-side
   - Barcode and QR Data remain full-width
2. New `_detailRow2()` + `_detailCard()` widgets: 32px icon, 14px font, 10px gap between cards
3. Null-safe: shows `—` placeholder when value is missing
4. Lint fix: replaced closure `card` with proper `_detailCard` method declaration

---
## Current Session: 2026-07-21 — Edit Page Barcode Editable + Scanner Back Button ✅

### What Was Done
1. **Barcode now editable** — `edit_product_page.dart`:
   - Removed read-only barcode display block
   - Added editable `TextFormField` for barcode with suffix scan button (camera icon → `/scanner` route)
   - `_barcode` added to state + `copyWith` in submit
2. **AppBar fix**: Added hamburger + back chevron Row leading
3. **Scanner page AppBar fix** — `scanner_page.dart`: Added back chevron button
4. **Removed unused import**: `app_theme.dart` re-added for scan button color
5. **Scanner camera fix**: Kotlin incremental cache error resolved via `flutter clean` + fresh build (`mobile_scanner` plugin)
6. **Route fix**: changed `/scanner` → `/scan/scanner` (actual registered route)
7. **Searchable category dropdown** — `edit_product_page.dart`:
   - Replaced `DropdownButtonFormField` with `showModalBottomSheet` picker
   - Features: search bar at top, "No Category" option, selected highlight + checkmark, scrollable list
   - Uses `Category` entity import

8. **Live search fix**: removed `final query` local var that reset on rebuild; now `searchController.text` read directly for live filtering
9. **Stock + Location same row** — `edit_product_page.dart`: side-by-side layout for better visual hierarchy
10. **Add product page updated** — `add_product_page.dart`:
    - Searchable category dropdown (same bottom sheet picker)
    - Stock + Location side-by-side row
    - AppBar: hamburger + back chevron
11. **Instant duplicate check** — `add_product_page.dart`:
    - Barcode scan pe turant duplicate detect + orange floating SnackBar + info icon + auto-close
    - Manual barcode input pe live duplicate check on each keystroke
    - Warning style (amber #E8850C) instead of error red for better UX
12. **Duplicate product popup** — `add_product_page.dart`:
    - Changed SnackBar → AlertDialog popup with product details card
    - Shows existing product name, price, stock
    - Actions: "Go Back" or "View Product" navigation
    - Fixed AlertDialog `leading` → `title` row pattern

### flutter analyze
- 0 errors, 0 warnings, 0 infos ✅

---

---
## Current Session: 2026-07-21 — Edit Page Barcode Editable + AppBar Fix ✅

### What Was Done
1. **Barcode now editable** — `edit_product_page.dart`:
   - Removed read-only barcode display block
   - Added editable `TextFormField` for barcode with validator
   - `_barcode` added to state + `copyWith` in submit
2. **AppBar fix**: Added hamburger + back chevron Row leading (was missing back button)
3. **Removed unused import**: `app_theme.dart` no longer needed

### flutter analyze
- 0 errors, 0 warnings ✅

---

### flutter analyze
- 0 errors, 0 warnings ✅

---

## Current Session: 2026-07-21 — Customer Info on Checkout Page ✅

### What Was Done
1. **Customer Name + Phone fields on CheckoutPage** (`checkout_page.dart`):
   - Inline card at top of scrollable area (above discount section)
   - Two TextFields side-by-side: name + phone (optional, 2+ chars / 10+ digits validation if filled)
   - Clear button resets both fields + BLoC state
   - `_customerNameController` + `_customerPhoneController` with dispose cleanup
2. **BillingState** (`billing_state.dart`): Added `customerName` + `customerPhone` nullable fields with copyWith + props
3. **BillingEvent** (`billing_event.dart`): Added `UpdateCustomerInfoEvent(customerName, customerPhone)`
4. **BillingBloc** (`billing_bloc.dart`):
   - Registered `_onUpdateCustomerInfo` handler
   - `_onSubmitBill` now writes `customer_name` + `customer_phone` to bills insert (was NULL before)
5. **Receipt printing** (`printer_helper.dart`): Customer name + phone printed between date and items separator (only if provided)
6. **PrintReceiptEvent**: Extended with `customerName` + `customerPhone` params
7. **Report entities**: `BillSummary` + `BillSummaryModel` now include `customerName` + `customerPhone` fields
8. **Bill history page**: Shows customer name + phone row on each bill card (when available)
9. **Bill detail page**: Shows customer name + phone in Bill Info card

### DB Migration
- `009_add_customer_phone_to_bills.sql`: Added `customer_phone TEXT` column to bills table (applied via Supabase MCP)
- `customer_name` column already existed but was never populated — now fixed

### flutter analyze
- 0 errors, 0 warnings ✅

---

## Current Session: 2026-07-21 — Receipt Preview + WhatsApp Share ✅

### What Was Done
1. **Receipt Preview Page** (`receipt_preview_page.dart`):
   - Visual receipt render with RepaintBoundary (capturable as PNG)
   - Shop header (name, address, phone, date)
   - Customer info section (name + phone)
   - Items table with Qty, Price, Total columns
   - Subtotal, Discount, Grand Total
   - Payment method + footer
   - Share button in AppBar → captures as PNG via `RenderRepaintBoundary.toImage()` → shares via `share_plus` or `whatsapp_share`
2. **WhatsApp Share**: Customer phone se auto-detect country code (91 prefix for 10-digit Indian numbers), directly send PNG to WhatsApp contact via `WhatsappShare.shareFile()`
3. **CheckoutPage buttons** — ab 2 rows hain:
   - Row 1: **Preview** (blueGrey) + **Print** (primary)
   - Row 2: **WhatsApp** (green #25D366, disabled if no customer phone) + **Save Bill** (green)
4. **Route added**: `/scan/receipt-preview` with extra data (shop, items, totals, customer info)
5. **New deps**: `whatsapp_share: ^2.0.1`, `path_provider: ^2.1.2`

### flutter analyze
- 0 errors ✅

---

## Current Session: 2026-07-22 — Navigation Fix v2: PopScope + addPostFrameCallback ✅

### What Was Done
1. **`app_shell.dart`** — Fixed PopScope not working because `context.go('/')` was conflicting with GoRouter's in-flight back event processing.
   - **Root Cause**: GoRouter v14.8.1 ka ShellRoute back event process kar raha hota hai jab PopScope callback fire hota hai. Direct `context.go('/')` call fail ho jata hai race condition ki vajah se.
   - **Fix**: 
     - `GoRouter.of(context)` se GoRouter instance build time pe store kiya
     - `addPostFrameCallback` se navigation ko next frame tak defer kiya
     - `canPop: false` rakha taaki system back button hamesha intercept ho
2. **Result**: Kisi bhi shell page se back → dashboard khulega. Dashboard se back → app close.

### flutter analyze
- 0 errors, 0 warnings ✅

---

## Current Session: 2026-07-22 — Complete Navigation Fix ✅

### What Was Done
1. **System back button fix** — `app_shell.dart`: Added `PopScope` wrapper around Scaffold
   - Sub-routes: back pops naturally (checkout → scan → etc.)
   - Top-level routes: back navigates to `/` (dashboard) instead of closing app
   - Uses `canPop: true` + `onPopInvokedWithResult` — if `didPop` is false, redirects to dashboard
2. **Removed redundant back buttons** from 8 pages inside ShellRoute (kept hamburger menu only):
   - `scanner_page.dart`, `product_list_page.dart`, `product_detail_page.dart`, `edit_product_page.dart`, `add_product_page.dart`, `add_staff_page.dart`, `receipt_preview_page.dart`
3. **Fixed `checkout_page.dart`**: `PopScope(canPop: false)` → `canPop: true` + `onPopInvokedWithResult` clears cart only after successful pop
4. **Cleaned unused import**: `app_back_button.dart` removed from `add_staff_page.dart`
5. **Auth pages outside shell** (`register_page.dart`, `email_verification_page.dart`) — unaffected, still use `AppBackButton`
6. **9 files modified** total, **0 flutter analyze issues**

### flutter analyze
- 0 errors, 0 warnings, 0 infos ✅

### Next
- Run on device to verify system back button behavior on real device

---

## Current Session: 2026-07-22 — Staff Widget Owner-Only (Dashboard + Drawer + Route Guard) ✅

### What Was Done
1. **Staff tile is owner-only** — 3-layer protection:
   - **Dashboard tiles**: Staff tile shown only when `authState.user.role == 'owner'`
   - **Side menu drawer**: Staff section hidden via BlocBuilder `isOwner` check (no change needed)
   - **Route guard**: `/staff` and `/staff/add` redirect non-owner users to `/` dashboard
2. Staff/cashier role users cannot see or access staff management anywhere

### flutter analyze
- 0 errors, 0 warnings ✅

---

## Current Session: 2026-07-22 — Logout Infinite Loop Fix ✅

### What Was Done
1. **Fixed infinite logout loop** — `auth_bloc.dart`:
   - Added `_isLoggingOut` flag (line 24)
   - `_onLogoutRequested`: emits `Unauthenticated()` FIRST (before await), then calls `logoutUseCase()`
   - `subscribeToAuthChanges`: skips dispatching `LogoutRequested` if `_isLoggingOut == true`
   - Root cause: Supabase `signOut()` triggers auth stream → listener dispatches `LogoutRequested` again → infinite loop (9x "Signing out" in console)

2. **Fixed GoRouter redirect not triggering** — `app_routes.dart`:
   - Added `_AuthNotifier extends ChangeNotifier` wrapper with proper `StreamSubscription` + `dispose()`
   - `createRouter(AuthBloc authBloc)` now accepts authBloc parameter
   - `refreshListenable: _AuthNotifier(authBloc)` — GoRouter re-evaluates redirect on every BLoC state change
   - `main.dart`: passes `di.sl<AuthBloc>()` to `createRouter()`

### Files Modified
- `lib/features/auth/presentation/bloc/auth_bloc.dart` — `_isLoggingOut` guard + emit Unauthenticated first
- `lib/config/routes/app_routes.dart` — `_AuthNotifier` wrapper + `refreshListenable` + `dart:async` import
- `lib/main.dart` — `createRouter(authBloc)` parameter

### flutter analyze
- 0 errors, 0 warnings ✅

---

### What Was Done
1. **CheckoutPage simplified** — sirf **Save Bill** button (full width, green)
   - Pehle Preview/Print/WhatsApp/Save sab buttons remove kar diye
   - Save Bill click → stock validation → bill save → navigate to receipt preview
2. **Receipt Preview Page** — 3 buttons bottom bar:
   - **Print** (primary color) → thermal printer se print
   - **WhatsApp** (#25D366 green) → customer phone pe direct PNG challan (auto country code 91)
   - **Done** (blue) → dashboard pe navigate
3. **WhatsApp direct send**: Custom MethodChannel (`com.example.billing_app/whatsapp_share`) via `MainActivity.kt`
   - `whatsapp_share` package broken hai, apna native Kotlin code add kiya
   - PNG cache dir se copy → FileProvider → WhatsApp intent with `jid` (phone@s.whatsapp.net)
   - Customer ka chat direct khulega, PNG attached, no contact selection needed
   - `provider_paths.xml` + AndroidManifest provider + `MainActivity.kt` MethodChannel
4. **Removed old flow**: CheckoutPage se preview/print/WhatsApp buttons hata diye

### flutter analyze
- 0 errors, 0 warnings ✅

---

## Current Session: 2026-07-21 — Layout + Routing Fixes ✅

### What Was Done
1. **Receipt Preview layout** — Print + WhatsApp ek row 50-50, Done full width neeche
2. **Done button redirect** → `/` (Dashboard) instead of `/scan`
3. **Checkout Save Bill button** → full width (`SizedBox(width: double.infinity)`)
4. **Bottom padding** → 32px for receipt preview

### flutter analyze
- 0 errors ✅


---

## Current Session: 2026-08-21 - Customer CMS FEATURE BUILT (needs device verify)

### What Was Done
1. Plan: customer_cms_plan.md (name+phone only, link bills/warranty via customer_id). User said 'jo accha lage krde'.
2. Migrations (user runs manually - no billing MCP in Hermes): 016 (customers, wrong UUID+FK) + 017 (MERGED: drop+recreate customers TEXT shop_id NO FK + link bills/warranty + backfill). 018 deleted/merged.
3. Built via parallel sub-agents: domain/data(4), phone_utils, bloc(3), pages(3). Wiring done by Jerry (agent hit 429).
4. Wiring: service_locator, app_routes(/customers,/customers/add,/customers/detail), app_drawer(Customers menu), billing_bloc(checkout auto find/create customer -> customer_id).
5. flutter analyze lib = 0 errors, 0 new warnings.
6. GOTCHA: sl import = '../../../../core/service_locator.dart' as di (relative, not package:.../di/).
7. Hot-restart FAILED: w8:p9 flutter run died (Lost connection to device). User must reconnect + flutter run.

### MCP WARNING (critical)
- supabase_prod + supabase_staging = MICROFLOW project, NOT billing. Billing = wwutchscfnhwijxyftlw.supabase.co (no MCP). Never migrate billing via those.

### Remaining
- User restarts flutter run -> hot restart -> verify Customers + checkout link on device.
- graphify update .

---

## Fix: 2026-08-21 - Receipt due/payment not showing

### Root Cause
Receipt preview page (receipt_preview_page.dart) SUPPORTS `amountPaid`/`dueAmount` + shows Due block
when `hasDue`, but checkout_page.dart navigation `extra` map NEVER passed them -> stayed null -> block hidden.
Printed receipt (printer_helper.printReceipt) also never printed payment/due.

### Fix
1. checkout_page.dart: pass `amountPaid` (state.amountPaid ?? total) + `dueAmount` (null if <=0) to receipt-preview nav.
2. printer_helper.printReceipt: added optional `paymentMethod`,`amountPaid`,`dueAmount`; prints Payment + Paid/DUE lines.
3. receipt_preview_page._printReceipt: forward widget.amountPaid/dueAmount/paymentMethod to printer.
4. billing_bloc print handler: forward state.amountPaid/paymentMethod/dueAmount for consistency.
flutter analyze = clean (printer_helper only).

### Remaining
- graphify update .

---

## Fix: 2026-08-21 - Customer search popup not visible properly

### Root Cause
`_showCustomerPicker` in checkout_page had redundant `StatefulBuilder` inside `BlocProvider.value` + `DraggableScrollableSheet`. The nested builders caused rendering issues — popup wasn't fully visible or responsive.

### Fix
Simplified the bottom sheet:
1. Removed `StatefulBuilder` (BlocBuilder handles state already)
2. Added drag handle indicator at top
3. Added title row ("Select Customer") with close button
4. Search bar now autofocuses
5. Customer list items wrapped in `Card` for better visual separation
6. Empty state has icon + text instead of plain text
7. `ListView` uses `scrollController` from DraggableScrollableSheet for proper scrolling
flutter analyze = clean.

### Remaining
- graphify update .

---

## Feature: 2026-08-21 - Auto bill-id QR on every receipt

### What
User wanted a scannable QR encoding each bill's unique `billId` (UUID) on every receipt, both on-screen and printed.

### Fix
1. receipt_preview_page.dart: import pretty_qr_code; after "Bill ID: xxxx" text, render `PrettyQrView.data(data: widget.billId)` (110x110) + "Scan to view bill" caption. Reuses already-installed `pretty_qr_code: ^3.3.0`.
2. printer_helper.dart: added `_qrCodeBytes()` — native ESC/POS GS(0x28 0x6B QR command (Model 2, EC level M=33, module size 4). printReceipt now prints the bill text line then the QR (centered) after the Bill: id. No new dependency.
QR encodes ONLY the billId (Option A) — small, prints clean on 58mm thermal, easy to look up bill for warranty/return.

### Verify
flutter analyze = clean. Hot-restart sent to w8:p9 (phone) = Restarted application.

### Remaining
- none

---

## Feature: 2026-08-21 - Warranty claim via scanned bill QR

### What
User wanted the receipt bill QR (encodes billId) to shortcut the warranty claim entry. Implemented scan-to-claim flow.

### Flow added
1. Warranty FAB opens a source sheet: "Scan Bill QR" (fast) or "Enter Manually" (fallback kept).
2. Scan -> `/scan/scanner` returns raw billId -> `ReportRepository.getBillDetail(billId)` fetches bill from DB.
3. Pre-filled dialog: customer/date auto from bill (read-only), product Dropdown populated ONLY from `bill.items` (error-proof, no typo), reason field.
4. Dart-side expiry guard: `_warrantyEndDate(bill.createdAt + item.warrantyDuration/Unit)` shows green "Under warranty until" / red "Warranty expired on" banner (non-blocking).
5. Submit passes real `productId` + `warrantyDuration/Unit` (fixed prior hardcoded `productId: ''`).

### Error-proofing
- Scan cancel -> ignored. Bill not found / network -> error snack, no crash. Loading dialog while fetching. Empty bill items -> blocked with message. Empty reason -> blocked.

### Files
lib/features/warranty/presentation/pages/warranty_claims_page.dart
Reuses: mobile_scanner (scanner_page), ReportRepository (getBillDetail), WarrantyBloc (CreateWarrantyClaim). No new dependency.

### Verify
flutter analyze clean (0 errors). Hot-restart w8:p9 = Restarted application.

---

## BUG FIX: 2026-08-21 - Warranty scan crashed (blank screen)
### Symptom
After scanning bill QR: loading dialog flashed, then blank screen + crash:
`GoRouterDelegate._debugAssertMatchListNotEmpty` + `!_debugLocked` assertion at
`_WarrantyClaimsPageState._scanBillAndCreateClaim` line ~43 (Navigator.pop).
### Root cause
Used `showDialog` + `Navigator.pop(context)` to close a loading dialog immediately
after `context.push('/scan/scanner')` returned. GoRouter keeps the navigator LOCKED
during the pop transition, so popping a dialog in that window throws and blanks UI.
### Fix
Removed the loading Dialog entirely. Replaced with an in-page `Stack` overlay driven
by `_isFetchingBill` bool (setState true/false). No Navigator.pop during route lock ->
no crash. Loading now shows "Fetching bill…" overlay on the warranty page itself.
### Lesson (future-proof)
NEVER call Navigator.pop / showDialog synchronously right after a go_router
`context.push(...)` returns — the navigator is locked. Use in-widget state (Stack
overlay / setState) for post-navigation loading, not dialogs.
### Verify
flutter analyze = 0 errors. Hot-restart w8:p9 = Restarted application.

---

## BUG FIX 2: 2026-08-21 - scan open prefilled dialog crash (firstWhere type)
### Symptom
Scan succeeded (loading overlay OK) but prefilled dialog never opened; crash:
`type '() => BillItem' is not a subtype of type '(() => BillItemModel)?' of 'orElse'`
at _showPrefilledClaimDialog line 625.
### Root cause
`bill.items` is `List<BillItemModel>` (BillItemModel extends BillItem). Annotating the
local as `BillItem? selectedItem` made `firstWhere` infer orElse must return BillItemModel,
clashing with the `BillItem?` annotation -> runtime cast error.
### Fix
Removed the `BillItem?` annotation: `final items = bill.items; var selectedItem = items.firstWhere((i)=>i.hasWarranty, orElse: ()=>items.first);` Let Dart infer type. Also dropped now-unneeded `selectedItem!` null-asserts in banner + submit.
### Verify
flutter analyze = 0 errors. Hot-restart w8:p9 = Restarted application.

---

## BUG FIX 3: 2026-08-21 - scan prefilled dialog STILL crashing (firstWhere)
### Symptom
After fix 2, SAME crash persisted: `type '() => BillItem' is not a subtype of
type '(() => BillItemModel)?' of 'orElse'` at line 626.
### Root cause
`BillSummary.items` is declared `List<BillItem>` but is populated at runtime with
`BillItemModel` (BillItemModel extends BillItem). `ListBase.firstWhere`'s orElse
closure type is covariant-strict, so the inferred closure `() => BillItem` still
failed the runtime `BillItemModel` expectation. firstWhere + orElse is fragile here.
### Fix
Dropped firstWhere entirely. Used explicit `final List<BillItem> items = bill.items;`
+ `items.where((i)=>i.hasWarranty).toList()` -> pick first warranted, else items.first.
No orElse closure -> no subtype clash. selectedItem is non-nullable BillItem.
### Verify
flutter analyze = 0 errors. Hot-restart w8:p9 = Restarted application.
### Lesson
With List<Base> populated by Subclass at runtime, AVOID firstWhere(orElse:). Use
where().toList() + manual pick. Firstwhere-orElse covariant typing is a known trap.

---

## BUG FIX 4: 2026-08-21 - card tap crash (Scaffold wrapped in Stack)
### Symptom
After filing a claim, tapping a claim card (to open detail sheet) crashed with:
`Failed assertion: '!semantics.parentDataDirty': is not true.` (rendering/object.dart:5705).
### Root cause
I had wrapped the whole `Scaffold` in a `Stack` (to show the fetching overlay).
Wrapping Scaffold in Stack breaks Scaffold's internal overlay/semantics management;
when showModalBottomSheet/_showClaimDetail pushed a route, the dirty parentData
assertion fired. Card tap itself was fine — the Stack broke the tree.
### Fix
Moved the overlay INSIDE the Scaffold body: `body: Stack(children:[ Column(...), if(_isFetchingBill) overlay ])`.
Scaffold is now a direct return (not wrapped). Overlay is a body child, so Scaffold's
overlay/semantics stay intact. (Also removed a duplicate orphaned overlay block left
from the earlier Stack approach.)
### Verify
flutter analyze = 0 errors. Hot-restart w8:p9 = Restarted application.
### Lesson
NEVER wrap Scaffold in Stack/Container that alters its render parent during route push.
Put loading overlays inside body via Stack. Scaffold must manage its own Overlay.

---

## BUG FIX 5: 2026-08-21 - card tap crash (Spacer in fixed-height bottom sheet)
### Symptom
After fix 4 (Scaffold unwrap), card tap STILL crashed: `RenderBox was not laid out:
RenderPhysicalShape` + `'!semantics.parentDataDirty'`. Same on every claim-card tap.
### Root cause
_showClaimDetail bottom sheet: `Container(height: 0.7)` -> `Column` -> `Padding` ->
`Column` with `const Spacer()` at the end. Spacer() inside a flex child of a
fixed-height Container during the sheet's route-push layout triggers parentDataDirty.
(This method was pre-existing, never hit before because card-tap wasn't tested until now.)
### Fix
Rewrote sheet: `Column[ handle, Expanded(SingleChildScrollView(detail rows)),
Padding(pinned action buttons) ]`. Removed Spacer() entirely. Details scroll, buttons
stay pinned at bottom. Bulletproof layout.
### Verify
flutter analyze = 0 errors. Hot-restart w8:p9 = Restarted application.
### Lesson
NEVER use Spacer() inside a Column that lives in a fixed-height Container / modal sheet.
Use Expanded(SingleChildScrollView) for content + a separate pinned footer widget.

---

## Fix: 2026-08-21 - Product long-press menu UI improvement

### Root Cause
`_showLongPressMenu` in product_list_page was a basic bottom sheet with plain `ListTile` items — no drag handle, no product info header, no visual hierarchy. Looked cluttered and wasn't properly visible.

### Fix
Rewrote `_showLongPressMenu` + added helper `_menuActionTile`:
1. Added drag handle indicator at top
2. Product info header with avatar initial, name, price, and stock badge
3. Each action is a custom tile with colored icon background + chevron
4. Destructive action (delete) visually distinct with red styling
5. Better spacing and padding throughout
flutter analyze = clean.

### Remaining
- graphify update .

---

## CHANGE: 2026-08-21 - Manual warranty entry REMOVED (scan-only)
### What
User: "manual entry hata de, sirf scan rehne de". Removed the manual claim dialog
(_showCreateClaimDialog) and the source bottom-sheet (_showClaimSourceSheet).
### Result
- FAB "New Claim" now calls `_startNewClaim()` -> directly `_scanBillAndCreateClaim()`.
- No manual entry path remains. Scan receipt QR is the ONLY way to file a warranty claim.
- `_showCreateClaimDialog` (the 180-line manual form) deleted entirely.
### Why
Simpler + error-proof: scan auto-fills customer + product from DB, no typos, no fake
bill IDs. Manual was a fallback but user wants scan-only.
### Verify
flutter analyze = 0 errors. Hot-restart triggered.

---

## BUG FIX 6: 2026-08-21 - warranty back button black screen
### Symptom
On /warranty page, tapping top-left back button -> black screen + crash:
`You have popped the last page off of the stack, there are no pages left to show`
+ `'!_debugLocked'`.
### Root cause
/warranty is a DIRECT GoRoute under GoRouter root (NOT inside the ShellRoute).
The back button used `Navigator.of(context).pop()` which pops the only page on the
material navigator -> empty stack -> black screen.
### Fix
Changed back button to `context.go('/')` (go_router) -> always returns to Dashboard
per AGENTS.md nav rule (sub-page back -> '/', dashboard back -> close app). go_router
import already present.
### Verify
flutter analyze = 0 errors. Hot-restart triggered.
### Lesson
For direct GoRoutes (not shell children), never use Navigator.pop() for back —
use context.go('/') or context.pop() only when there IS a parent in the stack.
ScannerPage back correctly uses context.pop(value) (returns to caller) - leave as-is.


## BUG FIX 7: 2026-08-21 back button black screen on Due Payments / Damaged / Customers
Same class as warranty fix 6. Direct GoRoutes (/due-payments, /damaged-products, /customers) popped only page -> black screen.
Fix: all three leading back buttons now context.go("/") returns to Dashboard. due_payments and damaged got go_router import added. customer_detail/add use context.pop() - correct, left as-is.
Verify: flutter analyze 0 errors on all 3. Hot-restart done.

## BUG FIX 8: 2026-08-24 - AddProductPage category select crash (type mismatch)
### Symptom
Tapping category field on Add Product page -> red screen error:
"type '() => Category' is not a subtype of type '() => CategoryModel?' of 'orElse'"
### Root cause
Line 596-599: `cats.firstWhere((c) => c.id == _categoryId, orElse: () => cats.first).name`
Runtime pe `cats` list actually contains `CategoryModel` instances, but `firstWhere`'s `orElse` lambda return type inference caused a subtype mismatch between `Category` and `CategoryModel`. The `orElse` fallback `() => cats.first` was typed as `() => Category` while the generic expected `() => CategoryModel?`.
### Fix
Replaced `firstWhere(..., orElse: () => cats.first)` with `where((c) => c.id == _categoryId).firstOrNull` — avoids the `orElse` type mismatch entirely. Also added `cats.isNotEmpty` guard before accessing.
Bonus fix: side effect in build (`_categoryController.text = ...`) now only runs when `_categoryId != null && cats.isNotEmpty`, not on every rebuild. "No Category" selection now properly clears controller.
### Verify
flutter analyze pending. Hot-restart triggered after fix.

## DESIGN FIX: 2026-08-24 - Reports Home page redesign
### Symptom
Reports & History landing page design thoda flat + outdated lag raha (gradient grid cards, hardcoded "4 sections" stat jo galat bhi tha — grid mein 5 cards hain).
### Fix
Dashboard ke premium style match karne ke liye rewrite kiya:
- Reuse kiye `PremiumStatCard` (hero: This Month Revenue) + 2-col row (Bills / Low Stock)
- Reuse kiye `DashboardActionCard` for 5 sections (Bill History, Daily Sales, Low Stock, Stock Movement, Audit Trail) — list rows with live counts
- Live data wire kiya ReportBloc se: `state.billHistory` (month filter) + `state.lowStockProducts.length`
- `AppTheme.gradientFor(context)` background, `RefreshIndicator` add kiya
- "4 sections" bug auto-fix ho gaya (dynamic counts ab)
### Verify
flutter analyze = 0 errors (1 const hint). Hot-restart triggered.
### Lesson
Report sub-pages detailed hain but home page consistent premium design chahiye (dashboard-matched). Reuse existing widgets, don't reinvent.

## NAV FIX: 2026-08-24 - Reports sub-pages added to sidebar
### Change
- Removed single "Reports" parent item from drawer
- Added 5 direct sub-items under "Reports" section header with `indented: true` visual hierarchy:
  Bill History, Daily Sales, Low Stock, Stock Movement, Audit Trail
- Each routes to its own page directly (`/reports/bills`, `/reports/daily-sales`, `/reports/low-stock`, `/reports/stock-movements`, `/reports/audit-trail`)
### Bonus
- `_DrawerItem` widget gains optional `indented` param for deeper hierarchy in future
### Verify
flutter analyze = 0 errors. Hot-restart triggered.

## Session — v3 color token migration (7 pages) [2026-08-25]
- Migrated hardcoded colors -> AppColors tokens in: due_payments_page (orange hero card -> solid warning + onAccent content; dialog/card amounts -> successText/warningText; primary buttons -> accent+onAccent), warranty_claims_page (_statusColor(b) tokens; FAB/chips -> accentSubtle/accentText; purple guarantee badge -> neutral onSurfaceVariant@10%; approve/reject/resolve solid semantic btns keep white fg), category_list_page (stats gradient -> accent/accentDark + onAccent content; FAB/empty-state CTA -> accent; fire chip -> accentSubtle), add_edit_category_dialog (save btn only -> accent+onAccent; 16-color swatch list KEPT as user data), settings_page (avatar/nav chips -> accent/accentSubtle; teal CONNECTED -> success trio), customer_detail_page (due balance orange -> warningText), add_customer_page (SnackBars: red->colorScheme.error+white, green->success+onAccent w600; save btn accent). Skipped data-layer files + cat.colorValue dynamic colors + white-on-error swipe bg.

## Session - v3 color token migration (7 core widgets) [2026-08-25]
- Migrated: payment_donut_chart (_methodColor(b): upi=info/cash=success/card=warning/credit=accentText(b)/bank=error(b)/default=textTertiary(b); _darkText -> luminance>0.55; header+empty icon -> accentText(b)), top_products_bar_chart (lerp gradient accent->success; total -> successText(b); empty icon -> accentText(b); gridline -> divider(b); tooltip text white/lavender -> onAccent/onAccent@75%), monthly_trend_card (header/line/dots/chips -> accentText(b); Avg chip teal -> successText(b); fill gradient -> accentSubtle fade; tooltip onAccent; gridline divider), app_bottom_nav + quick_actions_panel (FAB/close-btn gradient purple 0xFF554EE0 -> [accent, accentDark]; shadow -> accent@35%; BackdropFilter blur untouched), input_label (0xFF4C669A -> infoText(b)).
- glass_card.dart: NO change - 0xFF1A1A2E is dark-neutral tint (keep per spec); whites/blacks are glass neutrals.
- flutter analyze (7 files) = No issues found.

## Session - v3 layout redesign: Auth pages (3) [2026-08-25]
- login_page: brand mark row (lime chip r16 + qr_code_scanner_rounded onAccent + 'Billing App' w700 textPrimary), hero 'Welcome back' w800 + tertiary subtext, maxWidth 440 centered, CTA h54 themed lime, footer link accentText(b), TweenAnimationBuilder entrance (250ms easeOutCubic fade+slide 12px), password toggle tooltip added. Google button NOT added (feature doesn't exist in page; logic locked).
- register_page: same system, compact 40px chip, Name+ShopName in 2-col Row (12 gap, hints shortened), maxWidth 480, AppBar+AppBackButton kept.
- email_verification_page: content moved into v3 card (surface(b)+border(b), r24, p28), mail icon chip 64 accentSubtle/accentText(b), email bodyLarge w600 textPrimary, resend OutlinedButton restyled secondary (surface fg textPrimary + border(b) side r14), back-link accentText(b). Timer/BLoC/handlers untouched.
- Zero logic changes: all BlocListeners, events (LoginRequested/SignUpRequested/CheckAuthStatus/ResendVerificationEmailRequested/LogoutRequested), validators, navigation, snackbars preserved verbatim.
- flutter analyze lib/features/auth = No issues found. graphify updated.

## Session � v3 layout polish: staff + shop pages [2026-08-25]
- staff_list_page.dart: cards -> solid surface(b) + hairline border(b), radius 16, shadow removed; leading 44px circle initials chip (accentSubtle bg + accentText(b)); role badge moved next to name (owner=success@12%+successText(b), staff=info@12%+infoText(b), w600 10.5); email/phone rows w/ textTertiary icons; delete chip -> error(b)@12%; empty/error states -> textTertiary/textSecondary; FAB -> theme defaults (accent+onAccent). CRUD/bloc/delete-confirm/owner-guard untouched.
- add_staff_page.dart: form wrapped in sectioned card (surface+border, r20); 40px accentSubtle header chip + "New Staff Member" title; note -> info icon + textTertiary; password suffix icon tinted textTertiary; guard screen recolored. SignUpRequested flow, validators, BlocListener, owner check untouched.
- shop_details_page.dart: single flat form -> 3 sectioned cards (Shop Info / UPI & Payment / Receipt Footer) via _sectionCard helper (surface(b)+border(b), r20, 32px accentSubtle icon chips + accentText(b)); raw lime "General Information" label removed (contrast fix); Max-chars hint -> textTertiary; pinned Save kept in SafeArea(top:false). Load/save/BlocConsumer/buildWhen/maxLength untouched.
- Verify: flutter analyze lib/features/staff lib/features/shop = No issues found.

## Session - v3 layout polish: damaged-products + customer pages [2026-08-25]
- damaged_products_page.dart: summary card gradient+glow -> SOLID AppColors.error(b) surface, white content (icon chip white@18%, title white@85 w600 13, amount 30 w800 tabular, count white@75), r20; list cards -> solid surface(b)+hairline border(b), r16 (error-tint border removed); leading chip 48->40px r12 (error@12% + error(b) initial); units badge error(b), price/unit badge neutral textSecondary@10%; reason italic removed -> plain textTertiary; loss amount -> AppMoneyText.sized(15, w700, error(b)); undo btn colorScheme.primary -> textTertiary(b) (tooltip kept); empty state -> 72px accentSubtle chip + accentText(b) icon, title w700 textPrimary, sub textTertiary; undo-confirm dialog CTA -> accent+onAccent r10.
- mark_damaged_dialog.dart: dialog r20; title icon in error@12% chip; section labels textSecondary, product meta textTertiary; damage-type ChoiceChips -> selected = error@12% bg + error(b) label/icon + error side border (showCheckmark:false), unselected = transparent + border(b); qty +/- buttons surfaceElevated+border r10 with textPrimary icons; stock-exceed msg error(b) w500; Mark Damaged CTA kept semantic red (error(b)+white) r10. onConfirm/dispose/validators untouched.
- customer_list_page.dart: back arrow primaryColor -> textPrimary(b); tiles -> surface(b)+border(b) r16, shadow removed, margin 10, contentPadding h12; CircleAvatar(primary tint) -> 40px r12 chip (onSurfaceVariant@10% + textSecondary initial w700); name w600 14 textPrimary ellipsis, phone 12 textTertiary, chevron 20 textTertiary; empty state -> accentSubtle/accentText chip system. Search/onTap/FAB/BLoC untouched.
- Verify: flutter analyze lib/features/damaged_products lib/features/customer = No issues found.

## 2026-08-25 — Money font rollout (report + due_payments)
- AppMoneyText.sized() applied to all ₹ amount Texts in daily_sales (10), bill_history (6 sites), bill_detail (14), due_payments (7). reports_home_page: 0 inline ₹ Texts (values render via shared PremiumStatCard). stock_movement_page: no ₹ amounts exist — untouched.
- Mixed strings handled via Text.rich (label sans + amount mono): 'Due:', 'bills · ₹X', '₹Y vs ₹Z', '₹P each', '₹Q • Stock'. Helper widgets (_miniStat/_statCard/_customerStat/_editInfoRow) got optional money flag / valueStyle reuse. flutter analyze lib/features/report lib/features/due_payments = 0 issues. PDF/painter code skipped by rule.

## 2026-08-25 — App-wide navbar/FAB overlap audit + fix ⚡
- **ROOT CAUSE**: `app_shell.dart` `extendBody: true` floats bottom-nav (glass pill + 56px circular FAB) OVER page body. Pages only reserved system-inset space → last items hid under nav / page-level FABs collided with floating nav.
- **AUDIT**: 3 parallel code-reviewer agents on all 31 pages → ~19 files needed fixes.
- **FIXES (bottom clearance ~90-96px to every scrollable/list)**:
  - dashboard_page (SliverPadding bottom 32→96), home_page (SafeArea bottom 88), product_detail (96+inset), qr_generator (96), add_product/edit_product (SafeArea bottom 88), product_list (page FAB removed; cart bar margin→96), daily_sales (96), bill_detail (96), settings (96), customer_detail (96).
  - customer_list (page FAB removed + ListView 96), category_list (page FAB removed; had 120), staff_list (page FAB removed + imports cleaned; ListView had 100), shop_details (**page bottomNavigationBar (Save) moved INTO body Column** + removed conflict), warranty_claims (page FAB removed → New Claim now AppBar `actions` icon button calling `_scanBillAndCreateClaim`; ListView→96), due_payments (ListView→96), damaged_products (ListView→96), add_staff (SingleChildScrollView→96).
- **Cleanup**: removed orphan `_startNewClaim()` (FAB-only wrapper → folded into AppBar action), removed now-unused go_router/AuthBloc/AuthState imports in staff_list.
- **VERIFY**: `flutter analyze` = **No issues found** (0). Device test pending (user `flutter run`).
- LESSON: bottom-nav pages must reserve ~90px bottom clearance; never add page-level FABs in bottomNav mode — use AppBar actions instead.

## 2026-08-25 — Deep navbar overlap re-audit (FAB + buttons + pinned CTAs) ⚡
- User follow-up: "sirf FAB nahi, jo jo element navbar k sath overlap kr raha hai sab fix kar" — audit ALL bottom-anchored elements, not just FABs.
- **KEY INSIGHT**: `extendBody: true` means a page's OWN `bottomNavigationBar` (mini-cart, Save, Review Order bars) also renders at the exact screen bottom where the floating AppBottomNav floats → direct overlap. Same for `bottomSheet`.
- **3 parallel agents re-audited all pages.** Results: billing/scan group CLEAN (checkout/scanner/receipt-preview are fullscreen routes → nav hidden; home_page bottomSheet already `bottom:88`); reports/bills/audit group CLEAN (all ≥90px clearance); product/customer/staff group found 1 real bug + 1 consistency item.
- **BUG FIX**: `product_list_page.dart` `_ClassicListView` `ListView.separated` had `padding: symmetric(vertical:8)` (NO bottom clearance) → last item hid behind nav when cart empty. Fixed → `EdgeInsets.only(top:8, bottom:104)` (104 covers 96 cart bar + margin). Carousel branch (`product_coverflow_view.dart`) checked — only horizontal dial list, no conflict.
- **CONSISTENCY**: `add_product_page` + `edit_product_page` Save `bottomNavigationBar` `padding: bottom:88` → `96` (standardize to rest of app).
- **VERIFY**: `flutter analyze` = **No issues found** (0).
- FINAL STATE: Every bottom-anchored element (FABs, mini-cart, Save/Review/Pay bars, sticky CTAs, list tails) now clears the ~80px floating nav. 3 fullscreen scan routes exempt by design.

## 2026-08-25 - Report/audit/dashboard fix batch (10 fixes)
1. report_event.dart LoadBillHistory: optional limit (default 20); bloc passes to BillHistoryParams + hasMorePages uses event.limit; dashboard LoadBillHistory limit 200.
2. bill_history_page Load More ab searchQuery + paymentMethod bhi pass karta hai (filter loss fixed).
3. report_repository_impl.updateBill step d): amount_paid fetch karke due_amount + payment_status recalc (paid/partial/due, collectPayment jaisa) - update map me add.
4. reports_home_page -> StatefulWidget; initState me LoadSalesRange(month start..now) + LoadLowStockProducts(5); 'This Month Revenue' salesRange se compute (billHistory cap/navigation-independent).
5. getBillHistory search mode: fetch 0..499 (no offset), client-filter, phir page slice via skip/take - offset misalignment fixed. Non-search path unchanged server-side pagination.
6. bill_detail _printReceipt: ShopBloc se shopName/address1/address2/phone (ShopLoaded check, fallback blanks).
7. Void button disabled (_actionBtn onTap nullable + Opacity 0.45) + Tooltip 'Coming soon'; _showVoidDialog + fake 'Bill voided' snackbar removed.
8. ReportState me illDeleted flag add (copyWith/props); bloc delete success pe true; bill_detail BlocListener string-compare hata ke flag pe pop.
9. audit_timeline_page: _loadLogs query sanitize (',' aur '%' -> space); _exportCsv try/catch + error feedback + share text 'N loaded entries'.
10. Mounted guards: daily_sales _pickDate + stock_movement _pickFromDate/_pickToDate (picked != null && mounted).
- Verify: flutter analyze lib/features/report lib/features/audit lib/features/dashboard = No issues found.

### [Audit-Fix Agent] 2026-08-25 — 14-fix audit batch
- Manifest: INTERNET+VIBRATION added, legacy BT maxSdk=30
- Drawer header/FAB: white -> AppColors.onAccent (lime bg)
- Dark-mode light fills (success/info): fg conditional onAccent (warranty/qr/product_detail); error fills pe white rakha (theek hai)
- audit_timeline + text_styles + glass_card: v3 AppColors tokens pe migrate
- printer_helper: ASCII-safe _textToBytes (Rs. map), printText->Future<bool>; repo testPrint->bool; bloc test-print try/catch+result check; auto-connect heuristic printer/pos/thermal only
- csv_export_import: BOM prepend x2, import BOM strip, timestamped filenames
- app_validators: NaN/Infinity reject; beep_helper dispose no-op (app-lifetime singleton)
- settings_page: Scan sheet (tap-to-connect) + Test Print + Disconnect wired
- NEW migration supabase/migrations/019_audit_fixes.sql (bills.item_count, products REPLICA IDENTITY FULL, warranty_claims shop-scoped RLS+DELETE) — MAIN apply karega
- warranty page duplicate BlocListener line remove ki (agent merge artifact)
- flutter analyze: mere files 0 errors; realtime_service.dart me 2 errors (dusre agent ka file)

## 2026-08-25 — Dashboard v3.4 fix batch (This Week remove + first-run card + lazy slivers)
- **Task 1 DONE**: "This Week" section removed from dashboard — _WeeklyTrend class deleted, sales_trend_card.dart import removed (file NOT deleted, still exists in core/widgets), StaggeredFade indexes re-numbered sequential.
- **Task 2 DONE**: First-run empty state added via `_FirstRunCard` + `_buildInsightsSection()` — jab ReportStatus.loaded && billHistory.isEmpty → onboarding card (surface r24, receipt icon chip accentSubtle, 'Chalo shuru karein', lime 'Create First Bill' → /scan) replaces Recent Txns/Donut/Top Products/Monthly Trend/Staff Perf. Inventory Health DONO branches me dikhta hai (products bills-se independent). BlocBuilder buildWhen: status + billHistory dono.
- **Task 3 DONE**: SliverChildListDelegate → SliverChildBuilderDelegate (childCount: sections.length); children `_buildSections(context)` method me move; RepaintBoundary per-section wrap (builder ke andar) — lazy mount + repaint isolation dono milta hai. Hero sparkline (_SparklinePainter) untouched.
- **VERIFY**: `flutter analyze lib/features/dashboard` = No issues found! 
- DECISION: const lists in insights Columns (prefer_const_literals_to_create_immutables fired on mixed lists; made fully const).

## 2026-08-25 — Dead Code Cleanup (11-item audit batch)
- **REMOVED**: auth_gate.dart file delete (koi import nahi tha); Google auth poora path — GoogleLoginRequested event, _onGoogleLoginRequested handler, login_with_google_usecase.dart (file deleted), AuthRepository.loginWithGoogle() interface+impl, _ensureShopForOwner helper (sirf Google use karta tha), DI import+registration+ctor param; GetProductsByCategoryUseCase class + DI registration (ProductBloc ctor me tha hi nahi); ProductBloc GenerateQrCode event + handler + qrCodeData state field; AuditBloc LoadEntityAuditLogs + LogAuditAction events/handlers + entityLogs state field + ab-unused _staffName getter (audit repo ke getEntityAuditLogs/logAction methods JAAN BOOJH KE rakhe — task scope me nahi the, ab wo orphan hain, future cleanup candidate); DuePayments repo getTotalPendingDue + getBillForDuePayment (interface+impl); DamagedProducts repo getTotalDamageLoss + getDamagedProductsCount (interface+impl); pubspec.json_annotation + json_serializable removed (verified: koi @JsonSerializable nahi, saare fromJson hand-written, .g.dart files = Hive TypeAdapters) — build_runner + hive_generator KEEP.
- **SKIPPED (in-use)**: warranty submitSuccess/updateSuccess — warranty_claims_page.dart:646 actively gates dialog on it; Unauthenticated.message — add_staff_page.dart:82 staff-created message check karta hai.
- **FIXED**: _AuthNotifier dispose leak (app_routes.dart) — naya AppRouter holder class (router + refreshListenable), createRouter ab AppRouter return karta hai, _MyAppState.dispose() me _appRouter.dispose() (go_router 14.8.1 apne refreshListenable ko dispose NAHI karta — verified in package source information_provider.dart:282).
- **VERIFY**: flutter pub get OK (json_serializable dropped, json_annotation ab transitive only); flutter analyze lib = No issues found! Removed symbols ka koi dangling reference nahi (grep-verified).
