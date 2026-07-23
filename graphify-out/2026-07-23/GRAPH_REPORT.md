# Graph Report - flutter_billing_app-main  (2026-07-23)

## Corpus Check
- 146 files · ~1,423,649 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1916 nodes · 2939 edges · 151 communities (116 shown, 35 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 34 edges (avg confidence: 0.88)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `6d1fed2e`
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
- shop_details_page.dart
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
- Core Features
- Implementation
- RealtimeService
- input_label.dart
- Memory
- Run
- Android
- Android
- printer_bloc.dart
- Auto-Pilot-Mode
- Claude-Md
- Clean-Architecture
- Cloud-Supabase
- Dart-Only-Fix
- Flutter-Billing-App
- CategoryBloc
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
- category_model.dart

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
- `Owner-only Gating (3 Layers)` --rationale_for--> `Row Level Security (RLS) Policies`  [EXTRACTED]
  memory.md → RPD.md
- `3E Realtime (Supabase Realtime sync)` --conceptually_related_to--> `RealtimeService`  [INFERRED]
  IMPLEMENTATION_PLAN.md → memory.md

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

## Communities (151 total, 35 thin omitted)

### Community 0 - "Presentation"
Cohesion: 0.03
Nodes (61): address1, address2, barcode, billId, cartItems, copyWith, customPrice, discountIsPercentage (+53 more)

### Community 1 - "Utils"
Cohesion: 0.10
Nodes (20): categories, CategoryStatus, copyWith, description, id, message, name, status (+12 more)

### Community 2 - "Presentation"
Cohesion: 0.12
Nodes (15): copyWith, id, message, staff, StaffState, StaffStatus, status, authBloc (+7 more)

### Community 3 - "Presentation"
Cohesion: 0.06
Nodes (33): ../../../../core/realtime/realtime_service.dart, categoryId, changeType, copyWith, filteredProducts, id, message, payload (+25 more)

### Community 4 - "Presentation"
Cohesion: 0.06
Nodes (36): RecentTransactionsCard, SalesTrendCard, appBarTheme, buildActions, _buildDescriptionSnippet, buildLeading, _buildLoadingPlaceholder, buildResults (+28 more)

### Community 5 - "Presentation"
Cohesion: 0.06
Nodes (32): app_shell.dart, ../../features/auth/presentation/pages/email_verification_page.dart, ../../features/auth/presentation/pages/login_page.dart, ../../features/auth/presentation/pages/register_page.dart, ../../features/billing/domain/entities/cart_item.dart, ../../features/billing/presentation/pages/checkout_page.dart, ../../features/billing/presentation/pages/home_page.dart, ../../features/billing/presentation/pages/receipt_preview_page.dart (+24 more)

### Community 6 - "Presentation"
Cohesion: 0.07
Nodes (29): ../../features/auth/data/repositories/auth_repository_impl.dart, ../../features/auth/domain/usecases/get_current_user_usecase.dart, ../../features/auth/domain/usecases/login_usecase.dart, ../../features/auth/domain/usecases/login_with_google_usecase.dart, ../../features/auth/domain/usecases/logout_usecase.dart, ../../features/auth/domain/usecases/signup_usecase.dart, ../../features/category/data/repositories/category_repository_impl.dart, ../../features/category/domain/repositories/category_repository.dart (+21 more)

### Community 7 - "Domain"
Cohesion: 0.11
Nodes (23): class, ../entities/product.dart, UseCase, AddCategoryUseCase, call, DeleteCategoryUseCase, GetCategoriesUseCase, repository (+15 more)

### Community 8 - "Usecases"
Cohesion: 0.07
Nodes (34): CategoryState, ProductState, Equatable, SignUpParams, BillDetailParams, BillHistoryParams, billId, call (+26 more)

### Community 9 - "Presentation"
Cohesion: 0.08
Nodes (23): authRepository, _authSubscription, close, getCurrentUserUseCase, _isLoggingOut, loginUseCase, loginWithGoogleUseCase, logoutUseCase (+15 more)

### Community 10 - "Entities"
Cohesion: 0.05
Nodes (44): ../../../billing/presentation/bloc/billing_bloc.dart, ../../../../features/product/domain/entities/product.dart, ../../../../features/product/domain/repositories/product_repository.dart, ../../../../features/product/domain/usecases/product_usecases.dart, build, _buildBottomPanel, _buildCameraOffState, _buildCorner (+36 more)

### Community 11 - "Presentation"
Cohesion: 0.08
Nodes (26): dart:io, GlobalKey, address1, address2, billId, cartItems, createState, customerName (+18 more)

### Community 12 - "Models"
Cohesion: 0.08
Nodes (25): averageBill, billCount, changeType, copyWith, createdAt, customerName, customerPhone, date (+17 more)

### Community 13 - "Architecture"
Cohesion: 0.15
Nodes (13): core/theme/app_theme.dart, build, createState, dispose, initState, product, _qrDataController, QrGeneratorPage (+5 more)

### Community 14 - "Presentation"
Cohesion: 0.18
Nodes (11): add_edit_category_dialog.dart, build, CategoryListPage, _CategoryListPageState, _confirmDelete, createState, dispose, _openAddEditDialog (+3 more)

### Community 15 - "Presentation"
Cohesion: 0.09
Nodes (21): hashCode, operator, read, typeId, write, barcode, categoryId, createdAt (+13 more)

### Community 16 - "Presentation"
Cohesion: 0.05
Nodes (43): ../../../../core/utils/printer_helper.dart, alignCenter, alignLeft, alignRight, boldOff, boldOn, checkPermission, connect (+35 more)

### Community 17 - "Presentation"
Cohesion: 0.09
Nodes (21): 1. `lib/features/report/domain/entities/report_entities.dart`, 2. `lib/features/report/domain/usecases/report_usecases.dart`, 3. `lib/features/report/domain/repositories/report_repository.dart`, 4. `lib/features/report/data/repositories/report_repository_impl.dart`, 5. `lib/features/report/presentation/bloc/report_event.dart`, 6. `lib/features/report/presentation/bloc/report_bloc.dart`, 7. `lib/features/report/presentation/pages/bill_detail_page.dart`, Current State (+13 more)

### Community 18 - "Presentation"
Cohesion: 0.10
Nodes (21): Architecture — Clean Architecture + BLoC + Supabase, Data Layer, Dependency Injection (get_it), Domain Layer, Hive (Local Cache/Offline), Navigation (go_router), Offline Strategy, Presentation Layer (+13 more)

### Community 19 - "Presentation"
Cohesion: 0.15
Nodes (12): ../bloc/category_bloc.dart, ../../../../core/utils/app_validators.dart, AddEditCategoryDialog, build, category, createState, _descriptionController, dispose (+4 more)

### Community 20 - "Domain"
Cohesion: 0.08
Nodes (38): ../bloc/shop_bloc.dart, LoadShopEvent, message, ShopError, ShopEvent, ShopInitial, ShopLoaded, ShopLoading (+30 more)

### Community 21 - "Design"
Cohesion: 0.09
Nodes (21): authBloc, deleteBillUseCase, getBillDetailUseCase, getBillHistoryUseCase, getDailySalesUseCase, getLowStockProductsUseCase, getSalesRangeUseCase, getStockMovementsUseCase (+13 more)

### Community 22 - "User"
Cohesion: 0.09
Nodes (22): CustomPainter, _bottomPad, build, _buildPlaceholder, _buildStatChip, _buildStatsRow, dotFillColor, _formatCurrency (+14 more)

### Community 23 - "Presentation"
Cohesion: 0.11
Nodes (20): Design — Design System, Component Specs, DashboardActionCard + QuickActionTile, Dashboard Screen, Layout Considerations, Scanner Screen, Screens & Routes, StatCard Widget (+12 more)

### Community 24 - "Presentation"
Cohesion: 0.11
Nodes (17): copyWith, email, emailConfirmedAt, fromString, id, isEmailConfirmed, isOwner, isStaff (+9 more)

### Community 25 - "Presentation"
Cohesion: 0.09
Nodes (21): aiGradient, AppTheme, backgroundColor, _baseInputTheme, darkBackground, darkBorder, darkCard, darkGradient (+13 more)

### Community 26 - "Presentation"
Cohesion: 0.12
Nodes (16): ../../../auth/presentation/bloc/auth_bloc.dart, ../../../auth/presentation/bloc/auth_event.dart, ../../../auth/presentation/bloc/auth_state.dart, ../../../../core/widgets/input_label.dart, ../../../../core/widgets/primary_button.dart, build, createState, dispose (+8 more)

### Community 27 - "Presentation"
Cohesion: 0.19
Nodes (21): AddProductToCartEvent, BillingEvent, BillingState, ClearStockErrorsEvent, PrintReceiptEvent, _ProductStockUpdatedEvent, RemoveProductFromCartEvent, ScanBarcodeEvent (+13 more)

### Community 28 - "Domain"
Cohesion: 0.12
Nodes (15): config/routes/app_routes.dart, core/service_locator.dart, features/auth/domain/repositories/auth_repository.dart, features/auth/presentation/bloc/auth_event.dart, features/billing/presentation/bloc/billing_bloc.dart, features/category/presentation/bloc/category_bloc.dart, features/product/presentation/bloc/product_bloc.dart, features/report/presentation/bloc/report_bloc.dart (+7 more)

### Community 29 - "Widgets"
Cohesion: 0.12
Nodes (16): bill, build, _buildInfoCard, _confirmDelete, createState, _editInfoRow, _infoRow, initState (+8 more)

### Community 30 - "Presentation"
Cohesion: 0.12
Nodes (16): build, _buildEmptyState, _buildPaymentBadge, _buildTransactionItem, createdAt, _formatCurrency, grandTotal, id (+8 more)

### Community 31 - "App"
Cohesion: 0.43
Nodes (8): build, _buildQuickTiles, Route /categories, Route /products, Route /reports, Route /settings, Route /shop, Route /staff

### Community 32 - "Models"
Cohesion: 0.12
Nodes (15): ../../../category/domain/entities/category.dart, _barcodeController, build, _categoryId, _checkDuplicate, createState, _description, _formKey (+7 more)

### Community 33 - "Presentation"
Cohesion: 0.12
Nodes (16): hashCode, operator, read, typeId, write, int get, addressLine1, addressLine2 (+8 more)

### Community 34 - "Repositories"
Cohesion: 0.12
Nodes (17): currentRoute, _DrawerItem, icon, _initials, label, onTap, _ProfileHeader, route (+9 more)

### Community 35 - "Domain"
Cohesion: 0.11
Nodes (16): fromJson, fromProfileJson, fromSupabaseAuth, toJson, UserModel, User, StaffRepositoryImpl, deleteStaffMember (+8 more)

### Community 36 - "Presentation"
Cohesion: 0.13
Nodes (14): _barcode, build, _categoryId, createState, _description, _formKey, _imageUrl, initState (+6 more)

### Community 37 - "Presentation"
Cohesion: 0.12
Nodes (16): BillHistoryPage, _buildBillCard, createState, _datePickerButton, dispose, _formatDiscount, _fromDate, initState (+8 more)

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
Cohesion: 0.12
Nodes (18): ../bloc/printer_bloc.dart, ../bloc/printer_event.dart, ../bloc/printer_state.dart, core/theme/theme_cubit.dart, Cubit, ThemeCubit, build, _buildListGroup (+10 more)

### Community 42 - "Presentation"
Cohesion: 0.10
Nodes (21): LoadDailySales, LoadSalesRange, build, _buildBarChart, _buildDateNavigation, _buildStatCard, _buildStatCards, createState (+13 more)

### Community 43 - "Runnertests"
Cohesion: 0.46
Nodes (8): Migration 006_three_tier_roles.sql, Signup Default = Owner, UserRole Dart Enum, Phase 6 — SaaS-Ready Auth (Owner Signup + Shops), 3-Tier User Role System, handle_new_user DB Trigger, Owner Role, Super Admin Role

### Community 44 - "Usecases"
Cohesion: 0.11
Nodes (20): ../bloc/billing_bloc.dart, ClearCartEvent, UpdatePaymentMethodEvent, ../../domain/entities/cart_item.dart, build, _buildDataCell, _buildHeaderCell, CheckoutPage (+12 more)

### Community 45 - "Database"
Cohesion: 0.13
Nodes (16): SignUpRequested, _confirmPasswordController, createState, dispose, _emailController, _formKey, _isLoading, _nameController (+8 more)

### Community 46 - "Repositories"
Cohesion: 0.04
Nodes (44): Architecture, AUTO-PILOT MODE — No Questions, Just Execute 🤖⚡, Build Commands, CLAUDE.md — Flutter Billing App, CRITICAL — Dart-Only Fix Preference ⚡, CRITICAL — Next Time Auto-Recall ⚡, CRITICAL — Parallel Work Rule ⚡⚡, CRITICAL — Update Rule ⚡ (+36 more)

### Community 47 - "Domain"
Cohesion: 0.18
Nodes (10): BillItemModel, BillSummaryModel, fromJson, fromSupabaseRow, StockMovementModel, toJson, BillItem, BillSummary (+2 more)

### Community 48 - "Presentation"
Cohesion: 0.29
Nodes (13): PrinterBloc, ConnectPrinterEvent, DisconnectPrinterEvent, InitPrinterEvent, mac, name, PrinterEvent, props (+5 more)

### Community 49 - "Presentation"
Cohesion: 0.46
Nodes (8): Bloc, DeleteStaffMember, LoadStaff, StaffEvent, StaffBloc, _confirmDelete, initState, _StaffListPageState

### Community 50 - "Presentation"
Cohesion: 0.13
Nodes (14): _createProfile, _ensureProfileRole, _ensureShopForOwner, _extractErrorMessage, _fetchProfile, getCurrentUser, login, loginWithGoogle (+6 more)

### Community 51 - "printer_repository_impl.dart"
Cohesion: 0.11
Nodes (21): AuthRepositoryImpl, AuthRepository, call, GetCurrentUserUseCase, repository, call, email, LoginParams (+13 more)

### Community 52 - "Widgets"
Cohesion: 0.17
Nodes (11): call, email, emailRedirectTo, name, password, props, repository, role (+3 more)

### Community 53 - "Presentation"
Cohesion: 0.13
Nodes (14): barcode, categoryId, copyWith, createdAt, description, id, imageUrl, location (+6 more)

### Community 54 - "Models"
Cohesion: 0.13
Nodes (14): deleteBill, getBillDetail, getBillHistory, getDailySales, getLowStockProducts, getSalesRange, getStockMovements, _resolveShopId (+6 more)

### Community 55 - "Presentation"
Cohesion: 0.05
Nodes (41): Brightness, Color get, actionCardSubtitle, actionCardTitle, AdaptiveTextStyles, AppTextStyles, _brightness, greetingDate (+33 more)

### Community 56 - "Presentation"
Cohesion: 0.12
Nodes (16): build, _buildMovementCard, _changeTypes, _chipColor, createState, _filterApplied, _formatDate, _fromDate (+8 more)

### Community 57 - "Presentation"
Cohesion: 0.15
Nodes (10): Any, Bool, Flutter, FlutterAppDelegate, AppDelegate, RunnerTests, UIApplication, UIKit (+2 more)

### Community 58 - "printer_repository.dart"
Cohesion: 0.13
Nodes (14): ../bloc/product_bloc.dart, _buildDescriptionSnippet, createState, dispose, _dotSeparator, _filterChip, _getCategoryName, _metaText (+6 more)

### Community 59 - "Repositories"
Cohesion: 0.12
Nodes (15): ../../../category/presentation/bloc/category_bloc.dart, _ProductSearchDelegate, Product, _actionButton, build, _descriptionRow, _detailCard, _detailRow (+7 more)

### Community 60 - "App"
Cohesion: 0.18
Nodes (9): ../error/failure.dart, call, NoParams, addCategory, deleteCategory, getCategories, updateCategory, package:billing_app/features/category/domain/entities/category.dart (+1 more)

### Community 61 - "Repositories"
Cohesion: 0.14
Nodes (13): dart:ui, blur, borderOpacity, borderRadius, build, child, GlassCard, height (+5 more)

### Community 62 - "shop_details_page.dart"
Cohesion: 0.18
Nodes (10): build, color, DashboardActionCard, icon, label, onTap, QuickActionTile, subtitle (+2 more)

### Community 63 - "Web"
Cohesion: 0.14
Nodes (13): ../../features/product/data/models/product_model.dart, ../../features/shop/data/models/shop_model.dart, HiveDatabase, init, productBox, productBoxName, settingsBox, settingsBoxName (+5 more)

### Community 64 - "Domain"
Cohesion: 0.16
Nodes (15): AppDrawer, AuthEvent, email, GoogleLoginRequested, LogoutRequested, name, password, props (+7 more)

### Community 65 - "Implementation"
Cohesion: 0.28
Nodes (14): AuthBloc, Authenticated, AuthError, AuthInitial, AuthLoading, AuthState, email, EmailVerificationPending (+6 more)

### Community 66 - "Widgets"
Cohesion: 0.38
Nodes (6): CacheFailure, Failure, message, props, ServerFailure, package:equatable/equatable.dart

### Community 67 - "Domain"
Cohesion: 0.22
Nodes (9): build, build, build, build, build, build, Route /, Route /register (+1 more)

### Community 68 - "Repositories"
Cohesion: 0.13
Nodes (15): _applyThreshold, build, createState, dispose, _formatCurrency, initState, LowStockPage, _LowStockPageState (+7 more)

### Community 69 - "Presentation"
Cohesion: 0.40
Nodes (5): ReportBloc Global Provider Fix, Session: Reports & History Data+Domain, Session: Reports Presentation Layer, Phase 4 — Reports & History, Reports & History

### Community 70 - "Domain"
Cohesion: 0.16
Nodes (12): ../../../../core/error/failure.dart, ../../../../core/usecase/usecase.dart, ../../domain/entities/shop.dart, ../../domain/repositories/shop_repository.dart, ShopRepositoryImpl, getShop, ShopRepository, updateShop (+4 more)

### Community 71 - "Widgets"
Cohesion: 0.29
Nodes (8): Migration 005_add_staff_phone.sql, Owner-only Gating (3 Layers), Staff Feature (Clean Arch), Session: Staff Management Feature, Migration 003_saas_shops.sql, Phase 6.5 — Staff Management (Owner-only), Staff Role, Staff Management (Owner-only)

### Community 72 - "Repositories"
Cohesion: 0.18
Nodes (10): bool get, _channels, dispose, _isConnected, RealtimeService, subscribeToProducts, subscribeToTable, unsubscribe (+2 more)

### Community 73 - "Domain"
Cohesion: 0.14
Nodes (13): dart:async, ../../domain/repositories/product_repository.dart, addProduct, deleteProduct, _fromMap, getCurrentStockBulk, getProductByBarcode, getProducts (+5 more)

### Community 74 - "Memory"
Cohesion: 0.33
Nodes (7): Migration 004_shop_data_scoping.sql, Session: Multi-Tenant Shop Data Isolation FIX, shop_id Dart Threading, Phase 3 — Real-time & Multi-user, Real-time Sync, Row Level Security (RLS) Policies, Supabase Backend

### Community 75 - "Rpd"
Cohesion: 0.14
Nodes (13): EdgeInsetsGeometry, borderRadius, build, elevation, icon, isFullWidth, isLoading, label (+5 more)

### Community 76 - "report_state.dart"
Cohesion: 0.12
Nodes (15): billDetail, billHistory, copyWith, currentPage, dailySales, error, hasMorePages, lowStockProducts (+7 more)

### Community 77 - "printer_repository_impl.dart"
Cohesion: 0.29
Nodes (6): core/data/hive_database.dart, core/supabase/supabase_client.dart, getShop, shopKey, updateShop, ../models/shop_model.dart

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
Cohesion: 0.15
Nodes (12): build, _buildGlassContainer, color, count, InventoryHealthCard, label, lowStockCount, onViewDetails (+4 more)

### Community 81 - "printer_repository.dart"
Cohesion: 0.17
Nodes (11): double?, double get, CartItem, copyWith, customPrice, product, props, quantity (+3 more)

### Community 83 - "printer_repository_impl.dart"
Cohesion: 0.29
Nodes (7): handle_new_user() trigger (default staff, signup promotes owner), shops table (id, owner_id, name, created_at) + RLS, signup_usecase (create shop + owner role), Super admin portal (deferred), TASK 4 — Auth Flow Hardening (SaaS-ready), Session: Auth Feature Complete, Phase 1 — Database & Auth

### Community 84 - "Presentation"
Cohesion: 0.15
Nodes (12): build, GreetingHeader, _monthName, userName, build, color, icon, label (+4 more)

### Community 85 - "Presentation"
Cohesion: 0.18
Nodes (10): ReportRepositoryImpl, deleteBill, getBillDetail, getBillHistory, getDailySales, getLowStockProducts, getSalesRange, getStockMovements (+2 more)

### Community 86 - "printer_repository.dart"
Cohesion: 0.18
Nodes (10): addressLine1, addressLine2, copyWith, footerText, id, name, phoneNumber, props (+2 more)

### Community 87 - "shop_repository_impl.dart"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 88 - "Implementation"
Cohesion: 0.22
Nodes (8): ../../domain/entities/product.dart, addProduct, deleteProduct, getCurrentStockBulk, getProductByBarcode, getProducts, getProductsByCategory, updateProduct

### Community 89 - "Community 89"
Cohesion: 0.11
Nodes (30): initState, _LowStockBanner, ReportBloc, billId, changeType, date, DeleteBill, from (+22 more)

### Community 90 - "List"
Cohesion: 0.20
Nodes (9): authStateChanges, getCurrentUser, login, loginWithGoogle, logout, resendVerificationEmail, signUp, updateProfile (+1 more)

### Community 91 - "login_usecase.dart"
Cohesion: 0.18
Nodes (13): HomePage, _DashboardView, _DashboardViewState, AddProductPage, EditProductPage, ProductListPage, BillDetailPage, _BillDetailPageState (+5 more)

### Community 92 - "Community 92"
Cohesion: 0.15
Nodes (11): Color, IconData?, AppBackButton, icon, size, build, color, icon (+3 more)

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
Cohesion: 0.18
Nodes (12): FormState, LoginRequested, createState, dispose, _emailController, _formKey, _isLoading, LoginPage (+4 more)

### Community 99 - "App"
Cohesion: 0.67
Nodes (3): Role Assignment Flow, Shop Isolation Implementation, User Roles (3-Tier)

### Community 100 - "Launchimage"
Cohesion: 0.33
Nodes (7): @HiveType, ProductModelAdapter, ShopModelAdapter, ProductModel, ShopModel, Shop, TypeAdapter

### Community 101 - "Utils"
Cohesion: 0.25
Nodes (7): _anonKey, client, initialize, SupabaseConfig, _url, package:supabase_flutter/supabase_flutter.dart, static SupabaseClient get

### Community 102 - "Core Features"
Cohesion: 0.33
Nodes (7): build, build, Route /reports/bills, Route /reports/daily-sales, Route /reports/low-stock, Route /reports/stock-movements, Route /scan

### Community 104 - "RealtimeService"
Cohesion: 0.40
Nodes (4): _loadThemeMode, setThemeMode, toggleTheme, package:flutter_bloc/flutter_bloc.dart

### Community 105 - "input_label.dart"
Cohesion: 0.11
Nodes (16): ../../core/widgets/app_drawer.dart, AppShell, child, build, InputLabel, text, _buildCard, createState (+8 more)

### Community 106 - "Memory"
Cohesion: 0.29
Nodes (6): _, DeepLinkConfig, emailRedirectTo, host, scheme, static const String

### Community 107 - "Run"
Cohesion: 0.22
Nodes (9): TASK 3 — Core Feature Completion, 3A Scanner (barcode/QR → product lookup → cart), 3B Cart/Billing (cart state, qty, total, discount, bill), 3C Printer (ESC/POS receipt print), 3D UPI QR (dynamic UPI QR from amount), 3E Realtime (Supabase Realtime sync), Session: Supabase Realtime Sync, RealtimeService (+1 more)

### Community 110 - "Android"
Cohesion: 0.50
Nodes (5): Analysis Options Config, Web Favicon, Web Icon (192), Web Icon (512), Flutter Web Entry HTML

### Community 111 - "Android"
Cohesion: 0.40
Nodes (3): MainActivity, FlutterActivity, FlutterEngine

### Community 112 - "printer_bloc.dart"
Cohesion: 0.18
Nodes (10): ../../domain/repositories/printer_repository.dart, _onConnect, _onDisconnect, _onInit, _onRefresh, _onScan, _onTestPrint, repository (+2 more)

### Community 113 - "Auto-Pilot-Mode"
Cohesion: 0.67
Nodes (3): iOS Launch Image (@1x), iOS Launch Image (@2x), iOS Launch Image (@3x)

### Community 119 - "CategoryBloc"
Cohesion: 0.38
Nodes (11): AddCategory, CategoryEvent, DeleteCategory, LoadCategories, UpdateCategory, CategoryBloc, _AddEditCategoryDialogState, _onSave (+3 more)

### Community 152 - "category_model.dart"
Cohesion: 0.25
Nodes (7): ../../domain/entities/category.dart, CategoryModel, fromEntity, fromJson, toEntity, toJson, Category

## Knowledge Gaps
- **1129 isolated node(s):** `supabase`, `XCTest`, `_sub`, `rootNavigatorKey`, `dispose` (+1124 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **35 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `AuthBloc` connect `Implementation` to `Presentation`, `Utils`, `Presentation`, `Presentation`, `Presentation`, `Presentation`, `Entities`, `Design`, `Presentation`, `Presentation`, `Domain`, `Widgets`, `App`, `Repositories`, `Domain`, `Domain`, `Presentation`, `Database`, `Presentation`, `Domain`, `login_usecase.dart`, `package:billing_app/features/report/domain/entities/report_entities.dart`?**
  _High betweenness centrality (0.087) - this node is a cross-community bridge._
- **Why does `ReportBloc` connect `Community 89` to `Presentation`, `Presentation`, `Core Features`, `Repositories`, `Presentation`, `Presentation`, `report_state.dart`, `Presentation`, `Design`, `Presentation`, `login_usecase.dart`, `Domain`, `Widgets`?**
  _High betweenness centrality (0.029) - this node is a cross-community bridge._
- **Why does `Product` connect `Repositories` to `Presentation`, `Presentation`, `Launchimage`, `Presentation`, `Usecases`, `Architecture`, `printer_repository.dart`, `Presentation`?**
  _High betweenness centrality (0.014) - this node is a cross-community bridge._
- **What connects `supabase`, `XCTest`, `_sub` to the rest of the system?**
  _1129 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Presentation` be split into smaller, more focused modules?**
  _Cohesion score 0.03225806451612903 - nodes in this community are weakly interconnected._
- **Should `Utils` be split into smaller, more focused modules?**
  _Cohesion score 0.09523809523809523 - nodes in this community are weakly interconnected._
- **Should `Presentation` be split into smaller, more focused modules?**
  _Cohesion score 0.125 - nodes in this community are weakly interconnected._