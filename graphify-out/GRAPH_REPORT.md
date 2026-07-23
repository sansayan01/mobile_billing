# Graph Report - flutter_billing_app-main  (2026-07-23)

## Corpus Check
- 145 files · ~1,421,257 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1883 nodes · 2889 edges · 148 communities (114 shown, 34 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 34 edges (avg confidence: 0.88)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `d4d40f34`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Presentation
- Utils
- Presentation
- Presentation
- Presentation
- Presentation
- Presentation
- Domain
- Usecases
- Presentation
- Entities
- Presentation
- Models
- Architecture
- Presentation
- Presentation
- Presentation
- Presentation
- Presentation
- Presentation
- Domain
- Design
- User
- Presentation
- Presentation
- Presentation
- Presentation
- Presentation
- Domain
- Widgets
- Presentation
- App
- Models
- Presentation
- Repositories
- Domain
- Presentation
- Presentation
- Domain
- Dashboard
- Domain
- Presentation
- Presentation
- Runnertests
- Usecases
- Database
- Repositories
- Domain
- Presentation
- Presentation
- Presentation
- printer_repository_impl.dart
- Widgets
- Presentation
- Models
- Presentation
- Presentation
- Presentation
- printer_repository.dart
- Repositories
- App
- Repositories
- Presentation
- Web
- Domain
- Implementation
- Widgets
- Domain
- Repositories
- Presentation
- Domain
- Widgets
- Repositories
- Domain
- Memory
- Rpd
- report_state.dart
- printer_repository_impl.dart
- Widgets
- Domain
- package:billing_app/features/report/domain/entities/report_entities.dart
- printer_repository.dart
- Client
- printer_repository_impl.dart
- Presentation
- Presentation
- printer_repository.dart
- shop_repository_impl.dart
- Implementation
- Community 89
- List
- login_usecase.dart
- Community 92
- Core Features
- Memory
- Memory
- Web
- premium_stat_card.dart
- package:billing_app/features/report/domain/entities/report_entities.dart
- App
- Launchimage
- Utils
- ProductRepository
- Implementation
- Memory
- Run
- Android
- Android
- Android
- Auto-Pilot-Mode
- Claude-Md
- Clean-Architecture
- Cloud-Supabase
- Dart-Only-Fix
- Flutter-Billing-App
- Herder-Monitoring
- Runner
- Local-Hive
- Phases
- Printer-Thermal
- Pubspec
- Pubspec
- Pubspec
- Rpd
- Rpd
- Scanner-Mobile
- State-Flutter-Bloc
- Tech-Stack-Flutter
- Update-Rule
- Phases — Roadmap
- product_repository.dart
- category_repository_impl.dart
- package:billing_app/core/theme/app_theme.dart
- category_usecases.dart
- shop_repository_impl.dart
- RPD — Requirements & Product Definition
- deep_link_config.dart
- package:billing_app/core/theme/app_theme.dart
- Migration 003_saas_shops.sql
- TASK 3 — Core Feature Completion
- Phase 2 — Core Features 🔧 ✅
- CLAUDE.md
- DailySales

## God Nodes (most connected - your core abstractions)
1. `AuthBloc` - 60 edges
2. `ReportBloc` - 40 edges
3. `BillingBloc` - 31 edges
4. `ProductBloc` - 31 edges
5. `UseCase` - 29 edges
6. `CategoryBloc` - 27 edges
7. `ShopBloc` - 20 edges
8. `BillingEvent` - 19 edges
9. `PrinterBloc` - 16 edges
10. `CLAUDE.md — Flutter Billing App` - 15 edges

## Surprising Connections (you probably didn't know these)
- `Android Launcher Icon (hdpi)` --semantically_similar_to--> `iOS App Icon (1024x1024)`  [INFERRED] [semantically similar]
  android/app/src/main/res/mipmap-hdpi/ic_launcher.png → ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png
- `File Structure (README)` --semantically_similar_to--> `Project Structure`  [INFERRED] [semantically similar]
  README.md → architecture.md
- `TASK 4 — Auth Flow Hardening (SaaS-ready)` --conceptually_related_to--> `Session: Auth Feature Complete`  [INFERRED]
  IMPLEMENTATION_PLAN.md → memory.md
- `3E Realtime (Supabase Realtime sync)` --conceptually_related_to--> `RealtimeService`  [INFERRED]
  IMPLEMENTATION_PLAN.md → memory.md
- `UserRole Dart Enum` --implements--> `3-Tier User Role System`  [EXTRACTED]
  memory.md → RPD.md

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Next Phase Tasks (1-4 + execution + rollback)** — implementation_plan_task1, implementation_plan_task2, implementation_plan_task3, implementation_plan_task4, implementation_plan_execution_model, implementation_plan_rollback [EXTRACTED 1.00]
- **Clean Architecture Layers** — architecture_presentation, architecture_domain, architecture_data [EXTRACTED 1.00]
- **3-Tier Role System Implementation** — rpd_3tierroles, memory_migration_006, memory_userrole_enum, memory_signup_default_owner, phases_phase6 [EXTRACTED 0.95]
- **Staff Management Implementation** — rpd_staffmgmt, memory_staff_feature, memory_migration_005, memory_owneronly_gating, phases_phase65 [EXTRACTED 0.95]
- **Multi-Tenant Data Isolation Fix** — memory_migration_004, memory_shopid_threading, memory_multitenant, rpd_rls [EXTRACTED 0.95]
- **Reports & History Implementation** — rpd_reports, memory_reports_data, memory_reports_pres, memory_reportbloc_fix, phases_phase4 [EXTRACTED 0.95]
- **Realtime & Multi-user Implementation** — rpd_realtime, memory_realtime, memory_realtime_service, memory_stock_validation, phases_phase3 [EXTRACTED 0.95]
- **Phase 2 Core Features (Categories/Products/Billing)** — phases_phase2, rpd_categories, rpd_inventory, rpd_billing, memory_scanner_cart [EXTRACTED 0.95]
- **App Branding Assets (all platforms)** — android_app_src_main_res_mipmap_hdpi_ic_launcher, ios_runner_assets_xcassets_appicon_appiconset_icon_app_1024x1024_1x, web_favicon, web_icons_icon_192 [INFERRED 0.85]
- **iOS App Icon Set** — ios_runner_assets_xcassets_appicon_appiconset_icon_app_1024x1024_1x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_20x20_1x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_20x20_2x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_20x20_3x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_29x29_1x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_29x29_2x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_29x29_3x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_40x40_1x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_40x40_2x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_40x40_3x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_60x60_2x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_60x60_3x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_76x76_1x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_76x76_2x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_83_5x83_5_2x [INFERRED 0.95]
- **iOS Launch Image Set** — ios_runner_assets_xcassets_launchimage_imageset_launchimage, ios_runner_assets_xcassets_launchimage_imageset_launchimage_2x, ios_runner_assets_xcassets_launchimage_imageset_launchimage_3x [INFERRED 0.95]
- **Web Icon Set** — web_favicon, web_icons_icon_192, web_icons_icon_512, web_icons_icon_maskable_192, web_icons_icon_maskable_512 [INFERRED 0.95]

## Communities (148 total, 34 thin omitted)

### Community 0 - "Presentation"
Cohesion: 0.03
Nodes (61): address1, address2, barcode, billId, cartItems, copyWith, customPrice, discountIsPercentage (+53 more)

### Community 1 - "Utils"
Cohesion: 0.10
Nodes (20): categories, CategoryStatus, copyWith, description, id, message, name, status (+12 more)

### Community 2 - "Presentation"
Cohesion: 0.12
Nodes (16): copyWith, id, message, staff, StaffState, StaffStatus, status, authBloc (+8 more)

### Community 3 - "Presentation"
Cohesion: 0.06
Nodes (33): ../../../../core/realtime/realtime_service.dart, categoryId, changeType, copyWith, filteredProducts, id, message, payload (+25 more)

### Community 4 - "Presentation"
Cohesion: 0.06
Nodes (38): RecentTransactionsCard, appBarTheme, buildActions, _buildDescriptionSnippet, buildLeading, _buildLoadingPlaceholder, buildResults, _buildSearchResults (+30 more)

### Community 5 - "Presentation"
Cohesion: 0.06
Nodes (32): app_shell.dart, ../../features/auth/presentation/pages/email_verification_page.dart, ../../features/auth/presentation/pages/login_page.dart, ../../features/auth/presentation/pages/register_page.dart, ../../features/billing/domain/entities/cart_item.dart, ../../features/billing/presentation/pages/checkout_page.dart, ../../features/billing/presentation/pages/home_page.dart, ../../features/billing/presentation/pages/receipt_preview_page.dart (+24 more)

### Community 6 - "Presentation"
Cohesion: 0.07
Nodes (29): ../../features/auth/data/repositories/auth_repository_impl.dart, ../../features/auth/domain/usecases/get_current_user_usecase.dart, ../../features/auth/domain/usecases/login_usecase.dart, ../../features/auth/domain/usecases/login_with_google_usecase.dart, ../../features/auth/domain/usecases/logout_usecase.dart, ../../features/auth/domain/usecases/signup_usecase.dart, ../../features/category/data/repositories/category_repository_impl.dart, ../../features/category/domain/repositories/category_repository.dart (+21 more)

### Community 7 - "Domain"
Cohesion: 0.06
Nodes (42): class, ../entities/product.dart, UseCase, AddProductUseCase, call, DeleteProductUseCase, GetCurrentStockBulkUseCase, GetProductByBarcodeUseCase (+34 more)

### Community 8 - "Usecases"
Cohesion: 0.09
Nodes (28): BillingState, ProductState, Equatable, BillDetailParams, BillHistoryParams, billId, call, changeType (+20 more)

### Community 9 - "Presentation"
Cohesion: 0.08
Nodes (23): authRepository, _authSubscription, close, getCurrentUserUseCase, _isLoggingOut, loginUseCase, loginWithGoogleUseCase, logoutUseCase (+15 more)

### Community 10 - "Entities"
Cohesion: 0.08
Nodes (25): ../../../billing/presentation/bloc/billing_bloc.dart, ../../../../features/product/domain/entities/product.dart, ../../../../features/product/domain/repositories/product_repository.dart, ../../../../features/product/domain/usecases/product_usecases.dart, build, _buildBottomPanel, _buildCameraOffState, _buildCorner (+17 more)

### Community 11 - "Presentation"
Cohesion: 0.08
Nodes (26): dart:io, GlobalKey, address1, address2, billId, cartItems, createState, customerName (+18 more)

### Community 12 - "Models"
Cohesion: 0.07
Nodes (29): BillItemModel, StockMovementModel, averageBill, billCount, BillItem, changeType, copyWith, createdAt (+21 more)

### Community 13 - "Architecture"
Cohesion: 0.15
Nodes (13): core/theme/app_theme.dart, build, createState, dispose, initState, product, _qrDataController, QrGeneratorPage (+5 more)

### Community 14 - "Presentation"
Cohesion: 0.18
Nodes (11): add_edit_category_dialog.dart, ../bloc/category_bloc.dart, build, CategoryListPage, _CategoryListPageState, createState, dispose, _openAddEditDialog (+3 more)

### Community 15 - "Presentation"
Cohesion: 0.09
Nodes (21): hashCode, operator, read, typeId, write, barcode, categoryId, createdAt (+13 more)

### Community 16 - "Presentation"
Cohesion: 0.04
Nodes (44): ../../../../core/utils/printer_helper.dart, ../../domain/repositories/printer_repository.dart, alignCenter, alignLeft, alignRight, boldOff, boldOn, checkPermission (+36 more)

### Community 17 - "Presentation"
Cohesion: 0.09
Nodes (21): 1. `lib/features/report/domain/entities/report_entities.dart`, 2. `lib/features/report/domain/usecases/report_usecases.dart`, 3. `lib/features/report/domain/repositories/report_repository.dart`, 4. `lib/features/report/data/repositories/report_repository_impl.dart`, 5. `lib/features/report/presentation/bloc/report_event.dart`, 6. `lib/features/report/presentation/bloc/report_bloc.dart`, 7. `lib/features/report/presentation/pages/bill_detail_page.dart`, Current State (+13 more)

### Community 18 - "Presentation"
Cohesion: 0.10
Nodes (21): Architecture — Clean Architecture + BLoC + Supabase, Data Layer, Dependency Injection (get_it), Domain Layer, Hive (Local Cache/Offline), Navigation (go_router), Offline Strategy, Presentation Layer (+13 more)

### Community 19 - "Presentation"
Cohesion: 0.15
Nodes (15): ../../../../core/utils/app_validators.dart, AddCategory, UpdateCategory, AddEditCategoryDialog, _AddEditCategoryDialogState, build, category, createState (+7 more)

### Community 20 - "Domain"
Cohesion: 0.08
Nodes (36): ../bloc/shop_bloc.dart, LoadShopEvent, message, ShopError, ShopEvent, ShopInitial, ShopLoaded, ShopLoading (+28 more)

### Community 21 - "Design"
Cohesion: 0.25
Nodes (7): Color, build, color, icon, label, StatCard, value

### Community 22 - "User"
Cohesion: 0.04
Nodes (43): bool get, CustomPainter, _channels, dispose, _isConnected, RealtimeService, subscribeToProducts, subscribeToTable (+35 more)

### Community 23 - "Presentation"
Cohesion: 0.11
Nodes (20): Design — Design System, Component Specs, DashboardActionCard + QuickActionTile, Dashboard Screen, Layout Considerations, Scanner Screen, Screens & Routes, StatCard Widget (+12 more)

### Community 24 - "Presentation"
Cohesion: 0.10
Nodes (19): UserModel, copyWith, email, emailConfirmedAt, fromString, id, isEmailConfirmed, isOwner (+11 more)

### Community 25 - "Presentation"
Cohesion: 0.11
Nodes (19): build, _buildPermissionPrompt, _cameraStatus, _checkPermission, controller, _corner, createState, dispose (+11 more)

### Community 26 - "Presentation"
Cohesion: 0.11
Nodes (18): ../../../auth/presentation/bloc/auth_bloc.dart, ../../../auth/presentation/bloc/auth_event.dart, ../../../auth/presentation/bloc/auth_state.dart, ../../../../core/widgets/input_label.dart, ../../../../core/widgets/primary_button.dart, AddStaffPage, _AddStaffPageState, build (+10 more)

### Community 27 - "Presentation"
Cohesion: 0.21
Nodes (20): AddProductToCartEvent, BillingEvent, ClearStockErrorsEvent, PrintReceiptEvent, _ProductStockUpdatedEvent, RemoveProductFromCartEvent, ScanBarcodeEvent, SetDiscountTypeEvent (+12 more)

### Community 28 - "Domain"
Cohesion: 0.12
Nodes (15): config/routes/app_routes.dart, core/service_locator.dart, features/auth/domain/repositories/auth_repository.dart, features/auth/presentation/bloc/auth_event.dart, features/billing/presentation/bloc/billing_bloc.dart, features/category/presentation/bloc/category_bloc.dart, features/product/presentation/bloc/product_bloc.dart, features/report/presentation/bloc/report_bloc.dart (+7 more)

### Community 29 - "Widgets"
Cohesion: 0.09
Nodes (22): BillSummaryModel, fromJson, fromSupabaseRow, toJson, BillSummary, bill, build, _buildInfoCard (+14 more)

### Community 30 - "Presentation"
Cohesion: 0.12
Nodes (16): build, _buildEmptyState, _buildPaymentBadge, _buildTransactionItem, createdAt, _formatCurrency, grandTotal, id (+8 more)

### Community 31 - "App"
Cohesion: 0.06
Nodes (49): ../bloc/printer_bloc.dart, ../bloc/printer_event.dart, ../bloc/printer_state.dart, build, build, _buildQuickTiles, build, _onConnect (+41 more)

### Community 32 - "Models"
Cohesion: 0.12
Nodes (16): ../bloc/product_bloc.dart, _barcodeController, build, _categoryId, _checkDuplicate, createState, _description, _formKey (+8 more)

### Community 33 - "Presentation"
Cohesion: 0.12
Nodes (16): hashCode, operator, read, typeId, write, int get, addressLine1, addressLine2 (+8 more)

### Community 34 - "Repositories"
Cohesion: 0.12
Nodes (18): currentRoute, _DrawerItem, icon, _initials, label, onTap, _ProfileHeader, route (+10 more)

### Community 35 - "Domain"
Cohesion: 0.12
Nodes (14): fromJson, fromProfileJson, fromSupabaseAuth, toJson, StaffRepositoryImpl, deleteStaffMember, getStaffMembers, StaffRepository (+6 more)

### Community 36 - "Presentation"
Cohesion: 0.12
Nodes (15): ../../../category/domain/entities/category.dart, _barcode, build, _categoryId, createState, _description, _formKey, _imageUrl (+7 more)

### Community 37 - "Presentation"
Cohesion: 0.12
Nodes (16): _buildBillCard, createState, _datePickerButton, dispose, _formatDiscount, _fromDate, initState, _loadBills (+8 more)

### Community 38 - "Domain"
Cohesion: 0.15
Nodes (12): ../bloc/staff_bloc.dart, ../../../../features/auth/domain/entities/user.dart, features/auth/presentation/bloc/auth_bloc.dart, ../../../../features/auth/presentation/bloc/auth_state.dart, build, createState, dispose, _initials (+4 more)

### Community 39 - "Dashboard"
Cohesion: 0.12
Nodes (16): Android Launcher Icon (hdpi), iOS App Icon (1024x1024), iOS App Icon (20x20 @1x), iOS App Icon (20x20 @2x), iOS App Icon (20x20 @3x), iOS App Icon (29x29 @1x), iOS App Icon (29x29 @2x), iOS App Icon (29x29 @3x) (+8 more)

### Community 40 - "Domain"
Cohesion: 0.14
Nodes (16): CheckAuthStatus, AuthGate, build, createState, dispose, email, EmailVerificationPage, _EmailVerificationPageState (+8 more)

### Community 41 - "Presentation"
Cohesion: 0.13
Nodes (16): SignUpRequested, _confirmPasswordController, createState, dispose, _emailController, _formKey, _isLoading, _nameController (+8 more)

### Community 42 - "Presentation"
Cohesion: 0.12
Nodes (15): build, _buildBarChart, _buildDateNavigation, _buildStatCard, _buildStatCards, createState, _dayAbbr, _formatCurrency (+7 more)

### Community 43 - "Runnertests"
Cohesion: 0.46
Nodes (8): Migration 006_three_tier_roles.sql, Signup Default = Owner, UserRole Dart Enum, Phase 6 — SaaS-Ready Auth (Owner Signup + Shops), 3-Tier User Role System, handle_new_user DB Trigger, Owner Role, Super Admin Role

### Community 44 - "Usecases"
Cohesion: 0.11
Nodes (20): ../bloc/billing_bloc.dart, ClearCartEvent, UpdatePaymentMethodEvent, ../../domain/entities/cart_item.dart, build, _buildDataCell, _buildHeaderCell, CheckoutPage (+12 more)

### Community 45 - "Database"
Cohesion: 0.18
Nodes (12): FormState, LoginRequested, createState, dispose, _emailController, _formKey, _isLoading, LoginPage (+4 more)

### Community 46 - "Repositories"
Cohesion: 0.13
Nodes (15): Architecture, AUTO-PILOT MODE — No Questions, Just Execute 🤖⚡, Build Commands, CLAUDE.md — Flutter Billing App, CRITICAL — Dart-Only Fix Preference ⚡, CRITICAL — Next Time Auto-Recall ⚡, CRITICAL — Parallel Work Rule ⚡⚡, CRITICAL — Update Rule ⚡ (+7 more)

### Community 47 - "Domain"
Cohesion: 0.18
Nodes (9): ../../core/widgets/app_drawer.dart, IconData?, AppShell, child, AppBackButton, icon, size, package:go_router/go_router.dart (+1 more)

### Community 48 - "Presentation"
Cohesion: 0.13
Nodes (14): double?, double get, CartItem, copyWith, customPrice, product, props, quantity (+6 more)

### Community 49 - "Presentation"
Cohesion: 0.46
Nodes (8): Bloc, DeleteStaffMember, LoadStaff, StaffEvent, StaffBloc, _confirmDelete, initState, _StaffListPageState

### Community 50 - "Presentation"
Cohesion: 0.12
Nodes (15): _createProfile, _ensureProfileRole, _ensureShopForOwner, _extractErrorMessage, _fetchProfile, getCurrentUser, login, loginWithGoogle (+7 more)

### Community 51 - "printer_repository_impl.dart"
Cohesion: 0.09
Nodes (24): ../error/failure.dart, call, NoParams, AuthRepositoryImpl, AuthRepository, call, GetCurrentUserUseCase, repository (+16 more)

### Community 52 - "Widgets"
Cohesion: 0.15
Nodes (12): call, email, emailRedirectTo, name, password, props, repository, role (+4 more)

### Community 53 - "Presentation"
Cohesion: 0.13
Nodes (14): barcode, categoryId, copyWith, createdAt, description, id, imageUrl, location (+6 more)

### Community 54 - "Models"
Cohesion: 0.14
Nodes (13): deleteBill, getBillDetail, getBillHistory, getDailySales, getLowStockProducts, getSalesRange, getStockMovements, _resolveShopId (+5 more)

### Community 55 - "Presentation"
Cohesion: 0.07
Nodes (28): actionCardSubtitle, actionCardTitle, AppTextStyles, greetingDate, greetingName, greetingSubtitle, healthLabel, inventoryEmpty (+20 more)

### Community 56 - "Presentation"
Cohesion: 0.13
Nodes (14): build, _buildMovementCard, _changeTypes, _chipColor, createState, _filterApplied, _formatDate, _fromDate (+6 more)

### Community 57 - "Presentation"
Cohesion: 0.15
Nodes (10): Any, Bool, Flutter, FlutterAppDelegate, AppDelegate, RunnerTests, UIApplication, UIKit (+2 more)

### Community 58 - "printer_repository.dart"
Cohesion: 0.14
Nodes (14): _buildDescriptionSnippet, createState, dispose, _dotSeparator, _filterChip, _metaText, _placeholderIcon, ProductListPage (+6 more)

### Community 59 - "Repositories"
Cohesion: 0.14
Nodes (13): ../../../category/presentation/bloc/category_bloc.dart, _actionButton, build, _descriptionRow, _detailCard, _detailRow, _detailRow2, _formatDate (+5 more)

### Community 60 - "App"
Cohesion: 0.14
Nodes (13): addCategory, deleteCategory, getCategories, updateCategory, AddCategoryUseCase, call, DeleteCategoryUseCase, GetCategoriesUseCase (+5 more)

### Community 61 - "Repositories"
Cohesion: 0.14
Nodes (13): dart:ui, blur, borderOpacity, borderRadius, build, child, GlassCard, height (+5 more)

### Community 62 - "Presentation"
Cohesion: 0.14
Nodes (13): EdgeInsetsGeometry, borderRadius, build, elevation, icon, isFullWidth, isLoading, label (+5 more)

### Community 63 - "Web"
Cohesion: 0.14
Nodes (13): ../../features/product/data/models/product_model.dart, ../../features/shop/data/models/shop_model.dart, HiveDatabase, init, productBox, productBoxName, settingsBox, settingsBoxName (+5 more)

### Community 64 - "Domain"
Cohesion: 0.19
Nodes (13): AppDrawer, AuthEvent, email, GoogleLoginRequested, LogoutRequested, name, password, props (+5 more)

### Community 65 - "Implementation"
Cohesion: 0.28
Nodes (14): AuthBloc, Authenticated, AuthError, AuthInitial, AuthLoading, AuthState, email, EmailVerificationPending (+6 more)

### Community 66 - "Widgets"
Cohesion: 0.14
Nodes (13): billId, changeType, date, from, items, page, paymentMethod, productId (+5 more)

### Community 67 - "Domain"
Cohesion: 0.18
Nodes (11): build, build, build, build, build, build, build, Route / (+3 more)

### Community 68 - "Repositories"
Cohesion: 0.14
Nodes (13): _applyThreshold, build, createState, dispose, _formatCurrency, initState, _searchController, _searchQuery (+5 more)

### Community 69 - "Presentation"
Cohesion: 0.40
Nodes (5): ReportBloc Global Provider Fix, Session: Reports & History Data+Domain, Session: Reports Presentation Layer, Phase 4 — Reports & History, Reports & History

### Community 70 - "Domain"
Cohesion: 0.12
Nodes (18): core/data/hive_database.dart, ../../../../core/error/failure.dart, core/supabase/supabase_client.dart, ../../../../core/usecase/usecase.dart, ../../domain/entities/shop.dart, ../../domain/repositories/shop_repository.dart, getShop, shopKey (+10 more)

### Community 71 - "Widgets"
Cohesion: 0.40
Nodes (6): Migration 005_add_staff_phone.sql, Session: Staff Management Feature, Migration 003_saas_shops.sql, Phase 6.5 — Staff Management (Owner-only), Staff Role, Staff Management (Owner-only)

### Community 72 - "Repositories"
Cohesion: 0.20
Nodes (10): Known Issues / TODO, Phase 0 — Foundation ✅ (Complete), Phase 1 — Database & Auth 🏗️ ✅, Phase 3 — Real-time & Multi-user 🔄 ✅, Phase 4.5 — Dashboard & Navigation UX ✅, Phase 4 — Reports & History 📊 ✅, Phase 5 — Polish & Deploy 🚀, Phase 6.5 — Staff Management (Owner-only) ✅ (+2 more)

### Community 73 - "Domain"
Cohesion: 0.14
Nodes (13): dart:async, ../../domain/repositories/product_repository.dart, addProduct, deleteProduct, _fromMap, getCurrentStockBulk, getProductByBarcode, getProducts (+5 more)

### Community 74 - "Memory"
Cohesion: 0.40
Nodes (6): Migration 004_shop_data_scoping.sql, Session: Multi-Tenant Shop Data Isolation FIX, Owner-only Gating (3 Layers), shop_id Dart Threading, Staff Feature (Clean Arch), Row Level Security (RLS) Policies

### Community 75 - "Rpd"
Cohesion: 0.33
Nodes (9): CategoryEvent, CategoryState, DeleteCategory, LoadCategories, CategoryBloc, _confirmDelete, initState, _getCategoryName (+1 more)

### Community 76 - "report_state.dart"
Cohesion: 0.11
Nodes (17): DailySalesModel, DailySales, billDetail, billHistory, copyWith, currentPage, dailySales, error (+9 more)

### Community 77 - "printer_repository_impl.dart"
Cohesion: 0.22
Nodes (9): 1. Categories (Dynamic), 2. Product Inventory, 3. Billing (Point of Sale), 4. Real-time Sync (Supabase), 5. Shelf / Location Tracking, 6. QR Code Generator, 7. Reports & History, 8. Staff Management (Owner-only) (+1 more)

### Community 78 - "Widgets"
Cohesion: 0.17
Nodes (11): connecting,
  connected,
  connectionFailure,
  disconnected,, connectedMac, connectedName, copyWith, devices, errorMessage, PrinterState, PrinterStatus (+3 more)

### Community 79 - "Domain"
Cohesion: 0.33
Nodes (7): Implementation Plan (Next Phase), Plugins affected by KGP (app_settings, device_info_plus, mobile_scanner, print_bluetooth_thermal, share_plus), Kotlin Gradle Plugin warning (build stability), RLS fix (owner profile seeded), Hardcoded Supabase project (wwutchscfnhwijxyftlw), TASK 1 — Fix Kotlin Gradle Plugin Warning, TASK 2 — Verify RLS Fix End-to-End

### Community 80 - "package:billing_app/features/report/domain/entities/report_entities.dart"
Cohesion: 0.17
Nodes (11): build, _buildGlassContainer, color, count, InventoryHealthCard, label, lowStockCount, onViewDetails (+3 more)

### Community 81 - "printer_repository.dart"
Cohesion: 0.25
Nodes (7): ../../domain/entities/category.dart, CategoryModel, fromEntity, fromJson, toEntity, toJson, Category

### Community 83 - "printer_repository_impl.dart"
Cohesion: 0.29
Nodes (7): handle_new_user() trigger (default staff, signup promotes owner), shops table (id, owner_id, name, created_at) + RLS, signup_usecase (create shop + owner role), Super admin portal (deferred), TASK 4 — Auth Flow Hardening (SaaS-ready), Session: Auth Feature Complete, Phase 1 — Database & Auth

### Community 84 - "Presentation"
Cohesion: 0.18
Nodes (10): build, color, DashboardActionCard, icon, label, onTap, QuickActionTile, subtitle (+2 more)

### Community 85 - "Presentation"
Cohesion: 0.18
Nodes (10): ReportRepositoryImpl, deleteBill, getBillDetail, getBillHistory, getDailySales, getLowStockProducts, getSalesRange, getStockMovements (+2 more)

### Community 86 - "printer_repository.dart"
Cohesion: 0.13
Nodes (16): CacheFailure, Failure, message, props, ServerFailure, addressLine1, addressLine2, copyWith (+8 more)

### Community 87 - "shop_repository_impl.dart"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 88 - "Implementation"
Cohesion: 0.22
Nodes (8): ../../domain/entities/product.dart, addProduct, deleteProduct, getCurrentStockBulk, getProductByBarcode, getProducts, getProductsByCategory, updateProduct

### Community 89 - "Community 89"
Cohesion: 0.18
Nodes (24): _DashboardViewState, ReportBloc, DeleteBill, LoadBillDetail, LoadBillHistory, LoadDailySales, LoadLowStockProducts, LoadSalesRange (+16 more)

### Community 90 - "List"
Cohesion: 0.20
Nodes (9): authStateChanges, getCurrentUser, login, loginWithGoogle, logout, resendVerificationEmail, signUp, updateProfile (+1 more)

### Community 91 - "login_usecase.dart"
Cohesion: 0.18
Nodes (11): HomePage, _DashboardView, AddProductPage, EditProductPage, BillDetailPage, BillHistoryPage, DailySalesPage, LowStockPage (+3 more)

### Community 92 - "Community 92"
Cohesion: 0.20
Nodes (9): build, GreetingHeader, _monthName, userName, _buildCard, createState, ReportsHomePage, _ReportsHomePageState (+1 more)

### Community 93 - "Core Features"
Cohesion: 0.33
Nodes (7): Session: Dashboard Homepage + Side Menu, Session: Barcode/QR Scanner -> Cart, Phase 2 — Core Features, Phase 4.5 — Dashboard & Navigation UX, Billing (Point of Sale), Dynamic Categories, Product Inventory

### Community 94 - "Memory"
Cohesion: 0.22
Nodes (8): ../../../auth/data/models/user_model.dart, ../../../auth/domain/entities/user.dart, ../../domain/repositories/staff_repository.dart, deleteStaffMember, getStaffMembers, _resolveShopId, _supabase, SupabaseClient get

### Community 95 - "Memory"
Cohesion: 0.21
Nodes (18): AddProduct, DeleteProduct, FilterByCategory, GenerateQrCode, InitRealtime, LoadProducts, ProductEvent, ProductsRealtimeUpdated (+10 more)

### Community 96 - "Web"
Cohesion: 0.22
Nodes (8): DateTime, copyWith, createdAt, description, id, name, props, String?

### Community 97 - "premium_stat_card.dart"
Cohesion: 0.22
Nodes (8): ../../domain/repositories/category_repository.dart, addCategory, deleteCategory, getCategories, _resolveShopId, _supabase, updateCategory, ../models/category_model.dart

### Community 98 - "package:billing_app/features/report/domain/entities/report_entities.dart"
Cohesion: 0.29
Nodes (7): 3E Realtime (Supabase Realtime sync), Session: Supabase Realtime Sync, RealtimeService, Stock Validation Before Bill, Phase 3 — Real-time & Multi-user, Real-time Sync, Supabase Backend

### Community 99 - "App"
Cohesion: 0.22
Nodes (9): Client Profile, Constraints, Product Overview, Role Assignment Flow, RPD — Requirements & Product Definition, Shop Isolation Implementation, Target Platforms, Tech Stack Changes (+1 more)

### Community 100 - "Launchimage"
Cohesion: 0.33
Nodes (7): @HiveType, ProductModelAdapter, ShopModelAdapter, ProductModel, ShopModel, Shop, TypeAdapter

### Community 101 - "Utils"
Cohesion: 0.25
Nodes (7): _anonKey, client, initialize, SupabaseConfig, _url, package:supabase_flutter/supabase_flutter.dart, static SupabaseClient get

### Community 102 - "ProductRepository"
Cohesion: 0.50
Nodes (4): 2A — Categories ✅, 2B — Products (Inventory) ✅, 2C — Billing (Enhanced) ✅, Phase 2 — Core Features 🔧 ✅

### Community 103 - "Implementation"
Cohesion: 0.22
Nodes (7): build, InputLabel, text, package:billing_app/main.dart, package:flutter/material.dart, package:flutter_test/flutter_test.dart, main

### Community 106 - "Memory"
Cohesion: 0.29
Nodes (6): _, DeepLinkConfig, emailRedirectTo, host, scheme, static const String

### Community 107 - "Run"
Cohesion: 0.40
Nodes (5): TASK 3 — Core Feature Completion, 3A Scanner (barcode/QR → product lookup → cart), 3B Cart/Billing (cart state, qty, total, discount, bill), 3C Printer (ESC/POS receipt print), 3D UPI QR (dynamic UPI QR from amount)

### Community 109 - "Android"
Cohesion: 0.25
Nodes (7): build, color, icon, label, PremiumStatCard, value, package:billing_app/core/theme/text_styles.dart

### Community 110 - "Android"
Cohesion: 0.50
Nodes (5): Analysis Options Config, Web Favicon, Web Icon (192), Web Icon (512), Flutter Web Entry HTML

### Community 111 - "Android"
Cohesion: 0.40
Nodes (3): MainActivity, FlutterActivity, FlutterEngine

### Community 113 - "Auto-Pilot-Mode"
Cohesion: 0.67
Nodes (3): iOS Launch Image (@1x), iOS Launch Image (@2x), iOS Launch Image (@3x)

## Knowledge Gaps
- **1105 isolated node(s):** `supabase`, `XCTest`, `_sub`, `rootNavigatorKey`, `dispose` (+1100 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **34 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `AuthBloc` connect `Implementation` to `Presentation`, `Utils`, `Presentation`, `Presentation`, `Presentation`, `Presentation`, `Domain`, `Presentation`, `Entities`, `Presentation`, `Presentation`, `Domain`, `Widgets`, `App`, `Repositories`, `Domain`, `Domain`, `Presentation`, `Database`, `Presentation`, `Domain`, `Domain`, `Community 89`?**
  _High betweenness centrality (0.072) - this node is a cross-community bridge._
- **Why does `Product` connect `Presentation` to `Presentation`, `Presentation`, `Launchimage`, `Presentation`, `Usecases`, `Architecture`, `Presentation`, `Repositories`?**
  _High betweenness centrality (0.022) - this node is a cross-community bridge._
- **Why does `ProductModel` connect `Launchimage` to `Presentation`, `Presentation`, `Web`?**
  _High betweenness centrality (0.019) - this node is a cross-community bridge._
- **What connects `supabase`, `XCTest`, `_sub` to the rest of the system?**
  _1105 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Presentation` be split into smaller, more focused modules?**
  _Cohesion score 0.03225806451612903 - nodes in this community are weakly interconnected._
- **Should `Utils` be split into smaller, more focused modules?**
  _Cohesion score 0.09523809523809523 - nodes in this community are weakly interconnected._
- **Should `Presentation` be split into smaller, more focused modules?**
  _Cohesion score 0.11764705882352941 - nodes in this community are weakly interconnected._