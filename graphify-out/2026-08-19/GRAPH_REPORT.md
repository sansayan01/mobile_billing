# Graph Report - flutter_billing_app-main  (2026-08-19)

## Corpus Check
- 161 files · ~1,433,256 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 2096 nodes · 3227 edges · 156 communities (120 shown, 36 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 34 edges (avg confidence: 0.88)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `0d48e395`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- billing_bloc.dart
- dashboard_page.dart
- warranty_bloc.dart
- sales_trend_card.dart
- text_styles.dart
- app_routes.dart
- service_locator.dart
- product_bloc.dart
- report_usecases.dart
- package:billing_app/core/usecase/usecase.dart
- receipt_preview_page.dart
- add_product_page.dart
- report_entities.dart
- AGENTS.md — Flutter Billing App
- product_model.dart
- bill_detail_page.dart
- auth_bloc.dart
- email_verification_page.dart
- home_page.dart
- RPD — Requirements & Product Definition
- settings_page.dart
- shop_bloc.dart
- package:flutter_bloc/flutter_bloc.dart
- printer_helper.dart
- report_bloc.dart
- Files to Modify
- staff_bloc.dart
- checkout_page.dart
- Rules — Dev Rules
- category_bloc.dart
- bill_history_page.dart
- daily_sales_page.dart
- shop_repository_impl.dart
- Design — Design System
- product.dart
- scanner_page.dart
- add_edit_category_dialog.dart
- add_staff_page.dart
- product_list_page.dart
- UseCase
- CLAUDE.md — Flutter Billing App
- recent_transactions_card.dart
- user.dart
- auth_state.dart
- edit_product_page.dart
- low_stock_page.dart
- stock_movement_page.dart
- Core Features
- StaffBloc
- main.dart
- staff_list_page.dart
- qr_generator_page.dart
- shop_model.dart
- register_page.dart
- iOS App Icon (1024x1024)
- monthly_trend_card.dart
- auth_repository_impl.dart
- category_usecases.dart
- report_state.dart
- warranty_claim.dart
- product_detail_page.dart
- ../../../../core/error/failure.dart
- Route /
- package:supabase_flutter/supabase_flutter.dart
- AuthBloc
- Phase 2 — Core Features
- .application
- BillingBloc
- product_repository_impl.dart
- glass_card.dart
- primary_button.dart
- hive_database.dart
- Implementation Plan (Next Phase)
- staff_performance_card.dart
- report_repository_impl.dart
- login_usecase.dart
- login_page.dart
- package:billing_app/core/theme/app_theme.dart
- signup_usecase.dart
- package:billing_app/features/report/domain/entities/report_entities.dart
- TASK 4 — Auth Flow Hardening (SaaS-ready)
- printer_state.dart
- cart_item.dart
- dashboard_action_card.dart
- package:billing_app/core/error/failure.dart
- package:flutter/material.dart
- _
- Architecture — Clean Architecture + BLoC + Supabase
- realtime_service.dart
- ProductBloc
- StatefulWidget
- package:go_router/go_router.dart
- manifest.json
- product_repository.dart
- auth_repository.dart
- report_repository.dart
- CategoryRepository
- shop.dart
- README — Mobile POS & Billing App
- Data Layer
- staff_repository_impl.dart
- DailySales
- String?
- warranty_repository_impl.dart
- category_repository_impl.dart
- build
- ProductModel
- List
- user_model.dart
- package:fpdart/fpdart.dart
- Migration 003_saas_shops.sql
- 3-Tier User Role System
- Row Level Security (RLS) Policies
- Web Icon (192)
- MainActivity
- Phases — Roadmap
- iOS Launch Image (@1x)
- app_validators.dart
- _AuthNotifier
- Execution Model (Herder CLI parallel delegation)
- Rollback (migration file + git commit per task)
- iOS LaunchImage README
- ProductRepository
- .mcp.json
- Dart-Only Fix Preference
- Web Maskable Icon (192)
- @oksbi
- Auto-Pilot Mode (no questions)
- CLAUDE.md project instructions
- Clean Architecture (Presentation/Domain/Data)
- Supabase cloud DB (PostgreSQL + Realtime)
- Dart-Only Fix Preference (avoid SQL migrations)
- Flutter Billing App
- graphify knowledge graph
- Herder CLI live pane monitoring (w5:p8)
- Hive local cache (offline fallback)
- Session: 3-Tier Role System
- Session: Back Button + ReportBloc Fix
- Parallel Work Rule (use multiple subagents)
- Kotlin Gradle Plugin Warning
- print_bluetooth_thermal ESC/POS printer
- Equatable
- fpdart
- supabase_flutter
- QR Code Generator
- Shelf / Location Tracking
- mobile_scanner barcode + QR
- flutter_bloc state management
- Supabase Migration Rule (always make migration file)
- Flutter 3.x + Dart framework
- CRITICAL Update Rule (after every edit)

## God Nodes (most connected - your core abstractions)
1. `AuthBloc` - 62 edges
2. `ReportBloc` - 44 edges
3. `BillingBloc` - 31 edges
4. `ProductBloc` - 31 edges
5. `UseCase` - 29 edges
6. `CategoryBloc` - 27 edges
7. `ShopBloc` - 20 edges
8. `BillingEvent` - 19 edges
9. `PrinterBloc` - 16 edges
10. `WarrantyBloc` - 15 edges

## Surprising Connections (you probably didn't know these)
- `Android Launcher Icon (hdpi)` --semantically_similar_to--> `iOS App Icon (1024x1024)`  [INFERRED] [semantically similar]
  android/app/src/main/res/mipmap-hdpi/ic_launcher.png → ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png
- `File Structure (README)` --semantically_similar_to--> `Project Structure`  [INFERRED] [semantically similar]
  README.md → architecture.md
- `TASK 4 — Auth Flow Hardening (SaaS-ready)` --conceptually_related_to--> `Session: Auth Feature Complete`  [INFERRED]
  IMPLEMENTATION_PLAN.md → memory.md
- `3E Realtime (Supabase Realtime sync)` --conceptually_related_to--> `RealtimeService`  [INFERRED]
  IMPLEMENTATION_PLAN.md → architecture.md
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
- **Phase 2 Core Features (Categories/Products/Billing)** — phases_phase2, rpd_categories, rpd_inventory, rpd_billing, memory_scanner_cart [EXTRACTED 0.95]
- **App Branding Assets (all platforms)** — android_app_src_main_res_mipmap_hdpi_ic_launcher, ios_runner_assets_xcassets_appicon_appiconset_icon_app_1024x1024_1x, web_favicon, web_icons_icon_192 [INFERRED 0.85]
- **iOS App Icon Set** — ios_runner_assets_xcassets_appicon_appiconset_icon_app_1024x1024_1x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_20x20_1x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_20x20_2x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_20x20_3x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_29x29_1x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_29x29_2x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_29x29_3x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_40x40_1x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_40x40_2x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_40x40_3x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_60x60_2x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_60x60_3x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_76x76_1x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_76x76_2x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_83_5x83_5_2x [INFERRED 0.95]
- **iOS Launch Image Set** — ios_runner_assets_xcassets_launchimage_imageset_launchimage, ios_runner_assets_xcassets_launchimage_imageset_launchimage_2x, ios_runner_assets_xcassets_launchimage_imageset_launchimage_3x [INFERRED 0.95]
- **Web Icon Set** — web_favicon, web_icons_icon_192, web_icons_icon_512, web_icons_icon_maskable_192, web_icons_icon_maskable_512 [INFERRED 0.95]

## Communities (156 total, 36 thin omitted)

### Community 0 - "billing_bloc.dart"
Cohesion: 0.03
Nodes (61): address1, address2, barcode, billId, cartItems, copyWith, customPrice, discountIsPercentage (+53 more)

### Community 1 - "dashboard_page.dart"
Cohesion: 0.06
Nodes (48): appBarTheme, buildActions, _buildDescriptionSnippet, buildLeading, _buildLoadingPlaceholder, buildResults, _buildSearchResults, buildSuggestions (+40 more)

### Community 2 - "warranty_bloc.dart"
Cohesion: 0.05
Nodes (54): ../bloc/warranty_bloc.dart, billId, claimId, claimReason, claims, copyWith, CreateWarrantyClaim, customerName (+46 more)

### Community 3 - "sales_trend_card.dart"
Cohesion: 0.04
Nodes (44): CustomPainter, aiGradient, AppTheme, backgroundColor, _baseInputTheme, darkBackground, darkBorder, darkCard (+36 more)

### Community 4 - "text_styles.dart"
Cohesion: 0.05
Nodes (41): Brightness, Color get, actionCardSubtitle, actionCardTitle, AdaptiveTextStyles, AppTextStyles, _brightness, greetingDate (+33 more)

### Community 5 - "app_routes.dart"
Cohesion: 0.06
Nodes (33): app_shell.dart, ../../features/auth/presentation/pages/email_verification_page.dart, ../../features/auth/presentation/pages/login_page.dart, ../../features/auth/presentation/pages/register_page.dart, ../../features/billing/domain/entities/cart_item.dart, ../../features/billing/presentation/pages/checkout_page.dart, ../../features/billing/presentation/pages/home_page.dart, ../../features/billing/presentation/pages/receipt_preview_page.dart (+25 more)

### Community 6 - "service_locator.dart"
Cohesion: 0.06
Nodes (31): ../../features/auth/data/repositories/auth_repository_impl.dart, ../../features/auth/domain/usecases/get_current_user_usecase.dart, ../../features/auth/domain/usecases/login_usecase.dart, ../../features/auth/domain/usecases/login_with_google_usecase.dart, ../../features/auth/domain/usecases/logout_usecase.dart, ../../features/auth/domain/usecases/signup_usecase.dart, ../../features/category/data/repositories/category_repository_impl.dart, ../../features/category/domain/repositories/category_repository.dart (+23 more)

### Community 7 - "product_bloc.dart"
Cohesion: 0.06
Nodes (33): ../../../../core/realtime/realtime_service.dart, categoryId, changeType, copyWith, filteredProducts, id, message, payload (+25 more)

### Community 8 - "report_usecases.dart"
Cohesion: 0.08
Nodes (29): BillingState, CategoryState, ProductState, Equatable, BillDetailParams, BillHistoryParams, billId, call (+21 more)

### Community 9 - "package:billing_app/core/usecase/usecase.dart"
Cohesion: 0.16
Nodes (13): AuthRepositoryImpl, AuthRepository, call, GetCurrentUserUseCase, repository, call, LoginWithGoogleUseCase, repository (+5 more)

### Community 10 - "receipt_preview_page.dart"
Cohesion: 0.08
Nodes (26): dart:io, GlobalKey, address1, address2, billId, cartItems, createState, customerName (+18 more)

### Community 11 - "add_product_page.dart"
Cohesion: 0.11
Nodes (18): ../../../category/domain/entities/category.dart, _barcodeController, build, _categoryId, _checkDuplicate, createState, _description, _formKey (+10 more)

### Community 12 - "report_entities.dart"
Cohesion: 0.07
Nodes (29): averageBill, billCount, changeType, copyWith, createdAt, customerName, customerPhone, date (+21 more)

### Community 13 - "AGENTS.md — Flutter Billing App"
Cohesion: 0.13
Nodes (15): AGENTS.md — Flutter Billing App, Architecture, AUTO-PILOT MODE — No Questions, Just Execute 🤖⚡, Build Commands, CRITICAL — Dart-Only Fix Preference ⚡, CRITICAL — Next Time Auto-Recall ⚡, CRITICAL — Parallel Work Rule ⚡⚡, CRITICAL — Update Rule ⚡ (+7 more)

### Community 14 - "product_model.dart"
Cohesion: 0.08
Nodes (24): hashCode, operator, read, typeId, write, barcode, categoryId, createdAt (+16 more)

### Community 15 - "bill_detail_page.dart"
Cohesion: 0.06
Nodes (38): billId, changeType, date, DeleteBill, from, items, LoadBillDetail, page (+30 more)

### Community 16 - "auth_bloc.dart"
Cohesion: 0.08
Nodes (23): authRepository, _authSubscription, close, getCurrentUserUseCase, _isLoggingOut, loginUseCase, loginWithGoogleUseCase, logoutUseCase (+15 more)

### Community 17 - "email_verification_page.dart"
Cohesion: 0.18
Nodes (10): createState, dispose, email, EmailVerificationPage, _isChecking, _isResending, _onResend, _pollTimer (+2 more)

### Community 18 - "home_page.dart"
Cohesion: 0.08
Nodes (23): ../../../billing/presentation/bloc/billing_bloc.dart, ../../../../features/product/domain/entities/product.dart, ../../../../features/product/domain/repositories/product_repository.dart, ../../../../features/product/domain/usecases/product_usecases.dart, build, _buildBottomPanel, _buildCameraOffState, _buildCorner (+15 more)

### Community 19 - "RPD — Requirements & Product Definition"
Cohesion: 0.22
Nodes (9): Client Profile, Constraints, Product Overview, Role Assignment Flow, RPD — Requirements & Product Definition, Shop Isolation Implementation, Target Platforms, Tech Stack Changes (+1 more)

### Community 20 - "settings_page.dart"
Cohesion: 0.08
Nodes (40): ../bloc/printer_bloc.dart, ../bloc/printer_event.dart, ../bloc/printer_state.dart, core/theme/theme_cubit.dart, Cubit, ../../domain/repositories/printer_repository.dart, ThemeCubit, _onConnect (+32 more)

### Community 21 - "shop_bloc.dart"
Cohesion: 0.06
Nodes (48): ../bloc/shop_bloc.dart, ../../../../core/usecase/usecase.dart, LoadShopEvent, message, ShopError, ShopEvent, ShopInitial, ShopLoaded (+40 more)

### Community 22 - "package:flutter_bloc/flutter_bloc.dart"
Cohesion: 0.09
Nodes (21): _loadThemeMode, setThemeMode, toggleTheme, currentRoute, _DrawerItem, icon, _initials, label (+13 more)

### Community 23 - "printer_helper.dart"
Cohesion: 0.05
Nodes (43): ../../../../core/utils/printer_helper.dart, alignCenter, alignLeft, alignRight, boldOff, boldOn, checkPermission, connect (+35 more)

### Community 24 - "report_bloc.dart"
Cohesion: 0.09
Nodes (21): authBloc, deleteBillUseCase, getBillDetailUseCase, getBillHistoryUseCase, getDailySalesUseCase, getLowStockProductsUseCase, getSalesRangeUseCase, getStockMovementsUseCase (+13 more)

### Community 25 - "Files to Modify"
Cohesion: 0.09
Nodes (21): 1. `lib/features/report/domain/entities/report_entities.dart`, 2. `lib/features/report/domain/usecases/report_usecases.dart`, 3. `lib/features/report/domain/repositories/report_repository.dart`, 4. `lib/features/report/data/repositories/report_repository_impl.dart`, 5. `lib/features/report/presentation/bloc/report_event.dart`, 6. `lib/features/report/presentation/bloc/report_bloc.dart`, 7. `lib/features/report/presentation/pages/bill_detail_page.dart`, Current State (+13 more)

### Community 26 - "staff_bloc.dart"
Cohesion: 0.12
Nodes (16): copyWith, id, message, staff, StaffState, StaffStatus, status, authBloc (+8 more)

### Community 27 - "checkout_page.dart"
Cohesion: 0.11
Nodes (19): ../bloc/billing_bloc.dart, ClearCartEvent, UpdatePaymentMethodEvent, ../../domain/entities/cart_item.dart, build, _buildDataCell, _buildHeaderCell, _CheckoutPageState (+11 more)

### Community 28 - "Rules — Dev Rules"
Cohesion: 0.22
Nodes (9): Rules — Dev Rules, Code Quality Rules, Database Rules, Git Rules, Graphify Rules, Naming Conventions, Parallel Work Rule, State Management Rules (+1 more)

### Community 29 - "category_bloc.dart"
Cohesion: 0.09
Nodes (33): AddCategory, categories, CategoryEvent, CategoryStatus, copyWith, DeleteCategory, description, id (+25 more)

### Community 30 - "bill_history_page.dart"
Cohesion: 0.11
Nodes (19): LoadBillHistory, BillHistoryPage, _BillHistoryPageState, build, _buildBillCard, createState, _datePickerButton, dispose (+11 more)

### Community 31 - "daily_sales_page.dart"
Cohesion: 0.11
Nodes (20): LoadDailySales, LoadSalesRange, build, _buildBarChart, _buildDateNavigation, _buildStatCard, _buildStatCards, createState (+12 more)

### Community 32 - "shop_repository_impl.dart"
Cohesion: 0.29
Nodes (6): core/data/hive_database.dart, core/supabase/supabase_client.dart, getShop, shopKey, updateShop, ../models/shop_model.dart

### Community 33 - "Design — Design System"
Cohesion: 0.20
Nodes (11): Design — Design System, Component Specs, DashboardActionCard + QuickActionTile, Dashboard Screen, Layout Considerations, Scanner Screen, Screens & Routes, StatCard Widget (+3 more)

### Community 34 - "product.dart"
Cohesion: 0.10
Nodes (19): int?, barcode, categoryId, copyWith, createdAt, description, hasWarranty, id (+11 more)

### Community 35 - "scanner_page.dart"
Cohesion: 0.11
Nodes (19): build, _buildPermissionPrompt, _cameraStatus, _checkPermission, controller, _corner, createState, dispose (+11 more)

### Community 36 - "add_edit_category_dialog.dart"
Cohesion: 0.07
Nodes (27): add_edit_category_dialog.dart, ../bloc/category_bloc.dart, ../../../../core/utils/app_validators.dart, ../../domain/entities/category.dart, CategoryModel, fromEntity, fromJson, toEntity (+19 more)

### Community 37 - "add_staff_page.dart"
Cohesion: 0.11
Nodes (18): ../../../auth/presentation/bloc/auth_bloc.dart, ../../../auth/presentation/bloc/auth_event.dart, ../../../auth/presentation/bloc/auth_state.dart, ../../../../core/widgets/input_label.dart, ../../../../core/widgets/primary_button.dart, AddStaffPage, _AddStaffPageState, build (+10 more)

### Community 38 - "product_list_page.dart"
Cohesion: 0.13
Nodes (14): ../bloc/product_bloc.dart, _buildDescriptionSnippet, createState, dispose, _dotSeparator, _filterChip, _getCategoryName, _metaText (+6 more)

### Community 39 - "UseCase"
Cohesion: 0.12
Nodes (21): class, ../entities/product.dart, UseCase, AddProductUseCase, call, DeleteProductUseCase, GetCurrentStockBulkUseCase, GetProductByBarcodeUseCase (+13 more)

### Community 40 - "CLAUDE.md — Flutter Billing App"
Cohesion: 0.13
Nodes (15): Architecture, AUTO-PILOT MODE — No Questions, Just Execute 🤖⚡, Build Commands, CLAUDE.md — Flutter Billing App, CRITICAL — Dart-Only Fix Preference ⚡, CRITICAL — Next Time Auto-Recall ⚡, CRITICAL — Parallel Work Rule ⚡⚡, CRITICAL — Update Rule ⚡ (+7 more)

### Community 41 - "recent_transactions_card.dart"
Cohesion: 0.11
Nodes (17): build, _buildEmptyState, _buildPaymentBadge, _buildTransactionItem, createdAt, _formatCurrency, grandTotal, id (+9 more)

### Community 42 - "user.dart"
Cohesion: 0.11
Nodes (17): copyWith, email, emailConfirmedAt, fromString, id, isEmailConfirmed, isOwner, isStaff (+9 more)

### Community 43 - "auth_state.dart"
Cohesion: 0.23
Nodes (13): Authenticated, AuthError, AuthInitial, AuthLoading, AuthState, email, EmailVerificationPending, message (+5 more)

### Community 44 - "edit_product_page.dart"
Cohesion: 0.11
Nodes (17): _barcode, build, _categoryId, createState, _description, _formKey, _imageUrl, initState (+9 more)

### Community 45 - "low_stock_page.dart"
Cohesion: 0.12
Nodes (17): LoadLowStockProducts, _applyThreshold, build, createState, dispose, _formatCurrency, initState, _loadProducts (+9 more)

### Community 46 - "stock_movement_page.dart"
Cohesion: 0.12
Nodes (18): LoadStockMovements, build, _buildMovementCard, _changeTypes, _chipColor, createState, _filterApplied, _formatDate (+10 more)

### Community 47 - "Core Features"
Cohesion: 0.22
Nodes (9): 1. Categories (Dynamic), 2. Product Inventory, 3. Billing (Point of Sale), 4. Real-time Sync (Supabase), 5. Shelf / Location Tracking, 6. QR Code Generator, 7. Reports & History, 8. Staff Management (Owner-only) (+1 more)

### Community 48 - "StaffBloc"
Cohesion: 0.46
Nodes (8): Bloc, DeleteStaffMember, LoadStaff, StaffEvent, StaffBloc, _confirmDelete, initState, _StaffListPageState

### Community 49 - "main.dart"
Cohesion: 0.12
Nodes (15): config/routes/app_routes.dart, core/service_locator.dart, features/auth/domain/repositories/auth_repository.dart, features/auth/presentation/bloc/auth_event.dart, features/billing/presentation/bloc/billing_bloc.dart, features/category/presentation/bloc/category_bloc.dart, features/product/presentation/bloc/product_bloc.dart, features/report/presentation/bloc/report_bloc.dart (+7 more)

### Community 50 - "staff_list_page.dart"
Cohesion: 0.15
Nodes (12): ../bloc/staff_bloc.dart, ../../../../features/auth/domain/entities/user.dart, features/auth/presentation/bloc/auth_bloc.dart, ../../../../features/auth/presentation/bloc/auth_state.dart, build, createState, dispose, _initials (+4 more)

### Community 51 - "qr_generator_page.dart"
Cohesion: 0.15
Nodes (13): core/theme/app_theme.dart, build, createState, dispose, initState, product, _qrDataController, QrGeneratorPage (+5 more)

### Community 52 - "shop_model.dart"
Cohesion: 0.12
Nodes (16): hashCode, operator, read, typeId, write, int get, addressLine1, addressLine2 (+8 more)

### Community 53 - "register_page.dart"
Cohesion: 0.15
Nodes (13): _confirmPasswordController, createState, dispose, _emailController, _formKey, _isLoading, _nameController, _obscureConfirmPassword (+5 more)

### Community 54 - "iOS App Icon (1024x1024)"
Cohesion: 0.12
Nodes (16): Android Launcher Icon (hdpi), iOS App Icon (1024x1024), iOS App Icon (20x20 @1x), iOS App Icon (20x20 @2x), iOS App Icon (20x20 @3x), iOS App Icon (29x29 @1x), iOS App Icon (29x29 @2x), iOS App Icon (29x29 @3x) (+8 more)

### Community 55 - "monthly_trend_card.dart"
Cohesion: 0.12
Nodes (15): build, _buildEmptyState, _buildGlassContainer, _buildStatChip, _buildStatsRow, currencyPrefix, _formatShort, _gridInterval (+7 more)

### Community 56 - "auth_repository_impl.dart"
Cohesion: 0.13
Nodes (14): _createProfile, _ensureProfileRole, _ensureShopForOwner, _extractErrorMessage, _fetchProfile, getCurrentUser, login, loginWithGoogle (+6 more)

### Community 57 - "category_usecases.dart"
Cohesion: 0.25
Nodes (7): AddCategoryUseCase, call, DeleteCategoryUseCase, GetCategoriesUseCase, repository, UpdateCategoryUseCase, package:billing_app/features/category/domain/repositories/category_repository.dart

### Community 58 - "report_state.dart"
Cohesion: 0.12
Nodes (15): billDetail, billHistory, copyWith, currentPage, dailySales, error, hasMorePages, lowStockProducts (+7 more)

### Community 59 - "warranty_claim.dart"
Cohesion: 0.12
Nodes (15): billId, claimedByStaffId, claimReason, claimStatus, copyWith, createdAt, customerName, customerPhone (+7 more)

### Community 60 - "product_detail_page.dart"
Cohesion: 0.12
Nodes (15): ../../../category/presentation/bloc/category_bloc.dart, _ProductSearchDelegate, Product, _actionButton, build, _descriptionRow, _detailCard, _detailRow (+7 more)

### Community 61 - "../../../../core/error/failure.dart"
Cohesion: 0.29
Nodes (6): ../../../../core/error/failure.dart, WarrantyRepositoryImpl, createClaim, getClaims, updateClaimStatus, WarrantyRepository

### Community 62 - "Route /"
Cohesion: 0.25
Nodes (8): build, build, build, build, build, Route /, Route /register, Route /verify-email

### Community 63 - "package:supabase_flutter/supabase_flutter.dart"
Cohesion: 0.25
Nodes (7): _anonKey, client, initialize, SupabaseConfig, _url, package:supabase_flutter/supabase_flutter.dart, static SupabaseClient get

### Community 64 - "AuthBloc"
Cohesion: 0.14
Nodes (27): AppDrawer, AuthBloc, AuthEvent, CheckAuthStatus, email, GoogleLoginRequested, LoginRequested, LogoutRequested (+19 more)

### Community 65 - "Phase 2 — Core Features"
Cohesion: 0.29
Nodes (8): Session: Barcode/QR Scanner -> Cart, 2A — Categories ✅, 2B — Products (Inventory) ✅, 2C — Billing (Enhanced) ✅, Phase 2 — Core Features, Billing (Point of Sale), Dynamic Categories, Product Inventory

### Community 66 - ".application"
Cohesion: 0.15
Nodes (10): Any, Bool, Flutter, FlutterAppDelegate, AppDelegate, RunnerTests, UIApplication, UIKit (+2 more)

### Community 67 - "BillingBloc"
Cohesion: 0.21
Nodes (20): AddProductToCartEvent, BillingEvent, ClearStockErrorsEvent, PrintReceiptEvent, _ProductStockUpdatedEvent, RemoveProductFromCartEvent, ScanBarcodeEvent, SetDiscountTypeEvent (+12 more)

### Community 68 - "product_repository_impl.dart"
Cohesion: 0.14
Nodes (13): dart:async, ../../domain/repositories/product_repository.dart, addProduct, deleteProduct, _fromMap, getCurrentStockBulk, getProductByBarcode, getProducts (+5 more)

### Community 69 - "glass_card.dart"
Cohesion: 0.06
Nodes (32): Color, dart:ui, blur, borderOpacity, borderRadius, build, child, GlassCard (+24 more)

### Community 70 - "primary_button.dart"
Cohesion: 0.14
Nodes (13): EdgeInsetsGeometry, borderRadius, build, elevation, icon, isFullWidth, isLoading, label (+5 more)

### Community 71 - "hive_database.dart"
Cohesion: 0.14
Nodes (13): ../../features/product/data/models/product_model.dart, ../../features/shop/data/models/shop_model.dart, HiveDatabase, init, productBox, productBoxName, settingsBox, settingsBoxName (+5 more)

### Community 72 - "Implementation Plan (Next Phase)"
Cohesion: 0.18
Nodes (12): Implementation Plan (Next Phase), Plugins affected by KGP (app_settings, device_info_plus, mobile_scanner, print_bluetooth_thermal, share_plus), Kotlin Gradle Plugin warning (build stability), RLS fix (owner profile seeded), Hardcoded Supabase project (wwutchscfnhwijxyftlw), TASK 1 — Fix Kotlin Gradle Plugin Warning, TASK 2 — Verify RLS Fix End-to-End, TASK 3 — Core Feature Completion (+4 more)

### Community 73 - "staff_performance_card.dart"
Cohesion: 0.14
Nodes (13): _avatarColor, billCount, build, _buildGlassContainer, _initial, name, revenue, _short (+5 more)

### Community 74 - "report_repository_impl.dart"
Cohesion: 0.13
Nodes (14): deleteBill, getBillDetail, getBillHistory, getDailySales, getLowStockProducts, getSalesRange, getStockMovements, _resolveShopId (+6 more)

### Community 75 - "login_usecase.dart"
Cohesion: 0.25
Nodes (7): call, email, LoginParams, LoginUseCase, password, props, repository

### Community 76 - "login_page.dart"
Cohesion: 0.20
Nodes (10): FormState, createState, dispose, _emailController, _formKey, _isLoading, LoginPage, _LoginPageState (+2 more)

### Community 77 - "package:billing_app/core/theme/app_theme.dart"
Cohesion: 0.08
Nodes (24): build, GreetingHeader, _monthName, userName, build, color, icon, label (+16 more)

### Community 78 - "signup_usecase.dart"
Cohesion: 0.15
Nodes (12): call, email, emailRedirectTo, name, password, props, repository, role (+4 more)

### Community 79 - "package:billing_app/features/report/domain/entities/report_entities.dart"
Cohesion: 0.18
Nodes (10): BillItemModel, BillSummaryModel, fromJson, fromSupabaseRow, StockMovementModel, toJson, BillItem, BillSummary (+2 more)

### Community 80 - "TASK 4 — Auth Flow Hardening (SaaS-ready)"
Cohesion: 0.29
Nodes (7): handle_new_user() trigger (default staff, signup promotes owner), shops table (id, owner_id, name, created_at) + RLS, signup_usecase (create shop + owner role), Super admin portal (deferred), TASK 4 — Auth Flow Hardening (SaaS-ready), Session: Auth Feature Complete, Phase 1 — Database & Auth

### Community 81 - "printer_state.dart"
Cohesion: 0.17
Nodes (11): connecting,
  connected,
  connectionFailure,
  disconnected,, connectedMac, connectedName, copyWith, devices, errorMessage, PrinterState, PrinterStatus (+3 more)

### Community 82 - "cart_item.dart"
Cohesion: 0.17
Nodes (11): double?, double get, CartItem, copyWith, customPrice, product, props, quantity (+3 more)

### Community 83 - "dashboard_action_card.dart"
Cohesion: 0.18
Nodes (10): build, color, DashboardActionCard, icon, label, onTap, QuickActionTile, subtitle (+2 more)

### Community 84 - "package:billing_app/core/error/failure.dart"
Cohesion: 0.29
Nodes (6): addCategory, deleteCategory, getCategories, updateCategory, package:billing_app/core/error/failure.dart, package:billing_app/features/category/domain/entities/category.dart

### Community 85 - "package:flutter/material.dart"
Cohesion: 0.08
Nodes (22): IconData?, AppBackButton, icon, size, build, InputLabel, text, build (+14 more)

### Community 86 - "_"
Cohesion: 0.40
Nodes (6): _, DeepLinkConfig, emailRedirectTo, host, scheme, static const String

### Community 87 - "Architecture — Clean Architecture + BLoC + Supabase"
Cohesion: 0.25
Nodes (8): Architecture — Clean Architecture + BLoC + Supabase, Dependency Injection (get_it), Domain Layer, Navigation (go_router), Offline Strategy, Presentation Layer, State Flow, Supabase Tables

### Community 88 - "realtime_service.dart"
Cohesion: 0.18
Nodes (10): bool get, _channels, dispose, _isConnected, RealtimeService, subscribeToProducts, subscribeToTable, unsubscribe (+2 more)

### Community 90 - "ProductBloc"
Cohesion: 0.21
Nodes (18): AddProduct, DeleteProduct, FilterByCategory, GenerateQrCode, InitRealtime, LoadProducts, ProductEvent, ProductsRealtimeUpdated (+10 more)

### Community 91 - "StatefulWidget"
Cohesion: 0.22
Nodes (9): CheckoutPage, HomePage, AddEditCategoryDialog, CategoryListPage, AddProductPage, EditProductPage, ProductListPage, ShopDetailsPage (+1 more)

### Community 92 - "package:go_router/go_router.dart"
Cohesion: 0.18
Nodes (10): ../../core/widgets/app_drawer.dart, AppShell, build, child, _buildCard, createState, ReportsHomePage, _ReportsHomePageState (+2 more)

### Community 93 - "manifest.json"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 94 - "product_repository.dart"
Cohesion: 0.22
Nodes (8): ../../domain/entities/product.dart, addProduct, deleteProduct, getCurrentStockBulk, getProductByBarcode, getProducts, getProductsByCategory, updateProduct

### Community 95 - "auth_repository.dart"
Cohesion: 0.20
Nodes (9): authStateChanges, getCurrentUser, login, loginWithGoogle, logout, resendVerificationEmail, signUp, updateProfile (+1 more)

### Community 96 - "report_repository.dart"
Cohesion: 0.18
Nodes (10): ReportRepositoryImpl, deleteBill, getBillDetail, getBillHistory, getDailySales, getLowStockProducts, getSalesRange, getStockMovements (+2 more)

### Community 98 - "shop.dart"
Cohesion: 0.20
Nodes (9): addressLine1, addressLine2, copyWith, footerText, id, name, phoneNumber, props (+1 more)

### Community 99 - "README — Mobile POS & Billing App"
Cohesion: 0.22
Nodes (9): Project Structure, README — Mobile POS & Billing App, Contributing Guidelines, Core Features (README), File Structure (README), Getting Started, Project Scope, Tech Stack & Architecture (README) (+1 more)

### Community 100 - "Data Layer"
Cohesion: 0.20
Nodes (10): Data Layer, Hive (Local Cache/Offline), RealtimeService, Supabase (Primary Data Source), 3E Realtime (Supabase Realtime sync), Session: Supabase Realtime Sync, Stock Validation Before Bill, Phase 3 — Real-time & Multi-user (+2 more)

### Community 101 - "staff_repository_impl.dart"
Cohesion: 0.22
Nodes (8): ../../../auth/data/models/user_model.dart, ../../../auth/domain/entities/user.dart, ../../domain/repositories/staff_repository.dart, deleteStaffMember, getStaffMembers, _resolveShopId, _supabase, SupabaseClient get

### Community 103 - "String?"
Cohesion: 0.22
Nodes (8): DateTime, copyWith, createdAt, description, id, name, props, String?

### Community 104 - "warranty_repository_impl.dart"
Cohesion: 0.22
Nodes (8): ../../domain/entities/warranty_claim.dart, ../../domain/repositories/warranty_repository.dart, createClaim, _fromMap, getClaims, _resolveShopId, _supabase, updateClaimStatus

### Community 105 - "category_repository_impl.dart"
Cohesion: 0.22
Nodes (8): ../../domain/repositories/category_repository.dart, addCategory, deleteCategory, getCategories, _resolveShopId, _supabase, updateCategory, ../models/category_model.dart

### Community 106 - "build"
Cohesion: 0.17
Nodes (16): build, build, _buildQuickTiles, build, Route /categories, Route /products, Route /reports, Route /reports/bills (+8 more)

### Community 107 - "ProductModel"
Cohesion: 0.33
Nodes (7): @HiveType, ProductModelAdapter, ShopModelAdapter, ProductModel, ShopModel, Shop, TypeAdapter

### Community 110 - "List"
Cohesion: 0.32
Nodes (7): CacheFailure, Failure, message, props, ServerFailure, List, package:equatable/equatable.dart

### Community 111 - "user_model.dart"
Cohesion: 0.29
Nodes (6): fromJson, fromProfileJson, fromSupabaseAuth, toJson, UserModel, User

### Community 112 - "package:fpdart/fpdart.dart"
Cohesion: 0.13
Nodes (14): ../error/failure.dart, call, NoParams, StaffRepositoryImpl, deleteStaffMember, getStaffMembers, StaffRepository, call (+6 more)

### Community 113 - "Migration 003_saas_shops.sql"
Cohesion: 0.40
Nodes (6): Migration 005_add_staff_phone.sql, Session: Staff Management Feature, Migration 003_saas_shops.sql, Phase 6.5 — Staff Management (Owner-only), Staff Role, Staff Management (Owner-only)

### Community 114 - "3-Tier User Role System"
Cohesion: 0.46
Nodes (8): Migration 006_three_tier_roles.sql, Signup Default = Owner, UserRole Dart Enum, Phase 6 — SaaS-Ready Auth (Owner Signup + Shops), 3-Tier User Role System, handle_new_user DB Trigger, Owner Role, Super Admin Role

### Community 115 - "Row Level Security (RLS) Policies"
Cohesion: 0.40
Nodes (6): Migration 004_shop_data_scoping.sql, Session: Multi-Tenant Shop Data Isolation FIX, Owner-only Gating (3 Layers), shop_id Dart Threading, Staff Feature (Clean Arch), Row Level Security (RLS) Policies

### Community 117 - "Web Icon (192)"
Cohesion: 0.50
Nodes (5): Analysis Options Config, Web Favicon, Web Icon (192), Web Icon (512), Flutter Web Entry HTML

### Community 118 - "MainActivity"
Cohesion: 0.40
Nodes (3): MainActivity, FlutterActivity, FlutterEngine

### Community 120 - "Phases — Roadmap"
Cohesion: 0.17
Nodes (12): Session: Dashboard Homepage + Side Menu, ReportBloc Global Provider Fix, Session: Reports & History Data+Domain, Session: Reports Presentation Layer, Known Issues / TODO, Phase 4 — Reports & History, Phase 4.5 — Dashboard & Navigation UX, Phase 5 — Polish & Deploy (+4 more)

### Community 122 - "iOS Launch Image (@1x)"
Cohesion: 0.67
Nodes (3): iOS Launch Image (@1x), iOS Launch Image (@2x), iOS Launch Image (@3x)

## Knowledge Gaps
- **1249 isolated node(s):** `supabase`, `XCTest`, `_sub`, `rootNavigatorKey`, `dispose` (+1244 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **36 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `AuthBloc` connect `AuthBloc` to `billing_bloc.dart`, `dashboard_page.dart`, `warranty_bloc.dart`, `app_routes.dart`, `product_bloc.dart`, `bill_detail_page.dart`, `auth_bloc.dart`, `email_verification_page.dart`, `home_page.dart`, `package:flutter_bloc/flutter_bloc.dart`, `report_bloc.dart`, `staff_bloc.dart`, `category_bloc.dart`, `add_staff_page.dart`, `auth_state.dart`, `StaffBloc`, `main.dart`, `staff_list_page.dart`, `register_page.dart`, `BillingBloc`, `login_page.dart`, `build`?**
  _High betweenness centrality (0.072) - this node is a cross-community bridge._
- **Why does `ReportBloc` connect `dashboard_page.dart` to `build`, `low_stock_page.dart`, `stock_movement_page.dart`, `bill_detail_page.dart`, `StaffBloc`, `main.dart`, `report_bloc.dart`, `report_state.dart`, `bill_history_page.dart`, `daily_sales_page.dart`?**
  _High betweenness centrality (0.023) - this node is a cross-community bridge._
- **Why does `Product` connect `product_detail_page.dart` to `billing_bloc.dart`, `product.dart`, `product_bloc.dart`, `report_usecases.dart`, `ProductModel`, `edit_product_page.dart`, `cart_item.dart`, `qr_generator_page.dart`?**
  _High betweenness centrality (0.012) - this node is a cross-community bridge._
- **What connects `supabase`, `XCTest`, `_sub` to the rest of the system?**
  _1249 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `billing_bloc.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.03225806451612903 - nodes in this community are weakly interconnected._
- **Should `dashboard_page.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.05952380952380952 - nodes in this community are weakly interconnected._
- **Should `warranty_bloc.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.05075187969924812 - nodes in this community are weakly interconnected._