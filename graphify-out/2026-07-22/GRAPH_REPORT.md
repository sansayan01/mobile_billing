# Graph Report - flutter_billing_app-main  (2026-07-22)

## Corpus Check
- 139 files · ~1,411,454 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1714 nodes · 2637 edges · 144 communities (110 shown, 34 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 34 edges (avg confidence: 0.88)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `37b6d31a`
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
- Models
- category_repository.dart
- Widgets
- Domain
- package:billing_app/features/report/domain/entities/report_entities.dart
- Equatable
- Client
- printer_repository_impl.dart
- Presentation
- Presentation
- printer_repository.dart
- Config
- Implementation
- Implementation
- category_list_page.dart
- login_usecase.dart
- product_list_page.dart
- StatefulWidget
- Memory
- Memory
- Web
- Memory
- App
- Launchimage
- Utils
- Implementation
- Implementation
- Ios
- Mcp
- Memory
- Run
- Web
- Annotation
- Auto-Pilot-Mode
- Claude-Md
- Clean-Architecture
- Cloud-Supabase
- Dart-Only-Fix
- Flutter-Billing-App
- Graphify-Skill
- Herder-Monitoring
- Local-Hive
- Memory
- Memory
- Parallel-Work-Rule
- Phases
- Printer-Thermal
- Pubspec
- Pubspec
- Pubspec
- Rpd
- Rpd
- Scanner-Mobile
- State-Flutter-Bloc
- Supabase-Migration-Rule
- Tech-Stack-Flutter
- Update-Rule
- app_back_button.dart
- category_model.dart
- supabase_client.dart
- package:billing_app/core/theme/app_theme.dart
- package:fpdart/fpdart.dart
- User Roles (3-Tier)
- RPD — Requirements & Product Definition

## God Nodes (most connected - your core abstractions)
1. `AuthBloc` - 53 edges
2. `ReportBloc` - 34 edges
3. `ProductBloc` - 30 edges
4. `BillingBloc` - 28 edges
5. `UseCase` - 27 edges
6. `CategoryBloc` - 27 edges
7. `ShopBloc` - 20 edges
8. `BillingEvent` - 17 edges
9. `PrinterBloc` - 16 edges
10. `CLAUDE.md — Flutter Billing App` - 15 edges

## Surprising Connections (you probably didn't know these)
- `Android Launcher Icon (hdpi)` --semantically_similar_to--> `iOS App Icon (1024x1024)`  [INFERRED] [semantically similar]
  android/app/src/main/res/mipmap-hdpi/ic_launcher.png → ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png
- `File Structure (README)` --semantically_similar_to--> `Project Structure`  [INFERRED] [semantically similar]
  README.md → architecture.md
- `TASK 4 — Auth Flow Hardening (SaaS-ready)` --conceptually_related_to--> `Session: Auth Feature Complete`  [INFERRED]
  IMPLEMENTATION_PLAN.md → memory.md
- `Staff Role` --implements--> `Phase 6.5 — Staff Management (Owner-only)`  [INFERRED]
  RPD.md → phases.md
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

## Communities (144 total, 34 thin omitted)

### Community 0 - "Presentation"
Cohesion: 0.09
Nodes (34): ../bloc/printer_bloc.dart, ../bloc/printer_event.dart, ../bloc/printer_state.dart, _onConnect, _onDisconnect, _onInit, _onRefresh, _onScan (+26 more)

### Community 1 - "Utils"
Cohesion: 0.09
Nodes (21): alignCenter, alignLeft, alignRight, boldOff, boldOn, checkPermission, connect, disconnect (+13 more)

### Community 2 - "Presentation"
Cohesion: 0.04
Nodes (50): address1, address2, barcode, cartItems, copyWith, customPrice, discountIsPercentage, error (+42 more)

### Community 3 - "Presentation"
Cohesion: 0.22
Nodes (18): AddProductToCartEvent, BillingEvent, ClearStockErrorsEvent, PrintReceiptEvent, RemoveProductFromCartEvent, ScanBarcodeEvent, SetDiscountTypeEvent, SubmitBillEvent (+10 more)

### Community 4 - "Presentation"
Cohesion: 0.08
Nodes (39): ../bloc/shop_bloc.dart, LoadShopEvent, message, ShopError, ShopEvent, ShopInitial, ShopLoaded, ShopLoading (+31 more)

### Community 5 - "Presentation"
Cohesion: 0.06
Nodes (33): ../../../../core/realtime/realtime_service.dart, categoryId, changeType, copyWith, filteredProducts, id, message, payload (+25 more)

### Community 6 - "Presentation"
Cohesion: 0.06
Nodes (33): app_shell.dart, ../../features/auth/presentation/pages/email_verification_page.dart, ../../features/auth/presentation/pages/login_page.dart, ../../features/auth/presentation/pages/register_page.dart, ../../features/billing/domain/entities/cart_item.dart, ../../features/billing/presentation/pages/checkout_page.dart, ../../features/billing/presentation/pages/home_page.dart, ../../features/billing/presentation/pages/receipt_preview_page.dart (+25 more)

### Community 7 - "Domain"
Cohesion: 0.07
Nodes (29): ../../features/auth/data/repositories/auth_repository_impl.dart, ../../features/auth/domain/usecases/get_current_user_usecase.dart, ../../features/auth/domain/usecases/login_usecase.dart, ../../features/auth/domain/usecases/login_with_google_usecase.dart, ../../features/auth/domain/usecases/logout_usecase.dart, ../../features/auth/domain/usecases/signup_usecase.dart, ../../features/category/data/repositories/category_repository_impl.dart, ../../features/category/domain/repositories/category_repository.dart (+21 more)

### Community 8 - "Usecases"
Cohesion: 0.09
Nodes (26): class, BillingState, Equatable, BillDetailParams, BillHistoryParams, billId, call, changeType (+18 more)

### Community 9 - "Presentation"
Cohesion: 0.22
Nodes (15): AuthBloc, CheckAuthStatus, LoginRequested, SignUpRequested, AuthGate, build, initState, _onContinue (+7 more)

### Community 10 - "Entities"
Cohesion: 0.08
Nodes (25): averageBill, billCount, changeType, copyWith, createdAt, customerName, customerPhone, date (+17 more)

### Community 11 - "Presentation"
Cohesion: 0.08
Nodes (23): authRepository, _authSubscription, close, getCurrentUserUseCase, _isLoggingOut, loginUseCase, loginWithGoogleUseCase, logoutUseCase (+15 more)

### Community 12 - "Models"
Cohesion: 0.09
Nodes (21): hashCode, operator, read, typeId, write, barcode, categoryId, createdAt (+13 more)

### Community 13 - "Architecture"
Cohesion: 0.10
Nodes (21): Architecture — Clean Architecture + BLoC + Supabase, Data Layer, Dependency Injection (get_it), Domain Layer, Hive (Local Cache/Offline), Navigation (go_router), Offline Strategy, Presentation Layer (+13 more)

### Community 14 - "Presentation"
Cohesion: 0.06
Nodes (38): ../../../billing/presentation/bloc/billing_bloc.dart, build, _buildBottomPanel, _buildCameraOffState, _buildCorner, _buildEmptyCart, _buildOverlayButton, _cameraStatus (+30 more)

### Community 15 - "Presentation"
Cohesion: 0.10
Nodes (20): categories, CategoryStatus, copyWith, description, id, message, name, status (+12 more)

### Community 16 - "Presentation"
Cohesion: 0.19
Nodes (12): AuthEvent, email, GoogleLoginRequested, name, password, props, ResendVerificationEmailRequested, role (+4 more)

### Community 17 - "Presentation"
Cohesion: 0.10
Nodes (20): GetBillDetailUseCase, GetDailySalesUseCase, GetStockMovementsUseCase, authBloc, getBillDetailUseCase, getBillHistoryUseCase, getDailySalesUseCase, getLowStockProductsUseCase (+12 more)

### Community 18 - "Presentation"
Cohesion: 0.11
Nodes (18): ../../../auth/presentation/bloc/auth_bloc.dart, ../../../auth/presentation/bloc/auth_event.dart, ../../../auth/presentation/bloc/auth_state.dart, ../../../../core/widgets/input_label.dart, ../../../../core/widgets/primary_button.dart, AddStaffPage, _AddStaffPageState, build (+10 more)

### Community 19 - "Presentation"
Cohesion: 0.12
Nodes (18): core/data/hive_database.dart, ../../../../core/error/failure.dart, core/supabase/supabase_client.dart, ../../../../core/usecase/usecase.dart, ../../domain/entities/shop.dart, ../../domain/repositories/shop_repository.dart, getShop, shopKey (+10 more)

### Community 20 - "Domain"
Cohesion: 0.14
Nodes (13): ../bloc/staff_bloc.dart, core/theme/app_theme.dart, ../../../../features/auth/domain/entities/user.dart, features/auth/presentation/bloc/auth_bloc.dart, ../../../../features/auth/presentation/bloc/auth_state.dart, build, createState, dispose (+5 more)

### Community 21 - "Design"
Cohesion: 0.11
Nodes (20): Design — Design System, Component Specs, DashboardActionCard + QuickActionTile, Dashboard Screen, Layout Considerations, Scanner Screen, Screens & Routes, StatCard Widget (+12 more)

### Community 22 - "User"
Cohesion: 0.11
Nodes (17): copyWith, email, emailConfirmedAt, fromString, id, isEmailConfirmed, isOwner, isStaff (+9 more)

### Community 23 - "Presentation"
Cohesion: 0.06
Nodes (29): Architecture, AUTO-PILOT MODE — No Questions, Just Execute 🤖⚡, Build Commands, CLAUDE.md — Flutter Billing App, CRITICAL — Dart-Only Fix Preference ⚡, CRITICAL — Next Time Auto-Recall ⚡, CRITICAL — Parallel Work Rule ⚡⚡, CRITICAL — Update Rule ⚡ (+21 more)

### Community 24 - "Presentation"
Cohesion: 0.12
Nodes (16): ../../../category/presentation/bloc/category_bloc.dart, _ProductSearchDelegate, Product, _actionButton, build, _descriptionRow, _detailCard, _detailRow (+8 more)

### Community 25 - "Presentation"
Cohesion: 0.19
Nodes (19): AddProduct, DeleteProduct, FilterByCategory, GenerateQrCode, InitRealtime, LoadProducts, ProductEvent, ProductsRealtimeUpdated (+11 more)

### Community 26 - "Presentation"
Cohesion: 0.20
Nodes (9): build, GreetingHeader, _monthName, userName, _buildCard, createState, ReportsHomePage, _ReportsHomePageState (+1 more)

### Community 27 - "Presentation"
Cohesion: 0.13
Nodes (15): FormState, authenticatedChild, SplashScreen, createState, dispose, _emailController, _formKey, _isLoading (+7 more)

### Community 28 - "Domain"
Cohesion: 0.18
Nodes (10): StaffRepositoryImpl, deleteStaffMember, getStaffMembers, StaffRepository, call, DeleteStaffMemberUseCase, GetStaffMembersUseCase, repository (+2 more)

### Community 29 - "Widgets"
Cohesion: 0.13
Nodes (16): currentRoute, _DrawerItem, icon, _initials, label, onTap, _ProfileHeader, route (+8 more)

### Community 30 - "Presentation"
Cohesion: 0.13
Nodes (14): build, _confirmPasswordController, createState, dispose, _emailController, _formKey, _isLoading, _nameController (+6 more)

### Community 31 - "App"
Cohesion: 0.12
Nodes (16): Android Launcher Icon (hdpi), iOS App Icon (1024x1024), iOS App Icon (20x20 @1x), iOS App Icon (20x20 @2x), iOS App Icon (20x20 @3x), iOS App Icon (29x29 @1x), iOS App Icon (29x29 @2x), iOS App Icon (29x29 @3x) (+8 more)

### Community 32 - "Models"
Cohesion: 0.12
Nodes (16): hashCode, operator, read, typeId, write, int get, addressLine1, addressLine2 (+8 more)

### Community 33 - "Presentation"
Cohesion: 0.12
Nodes (15): copyWith, id, message, staff, StaffState, StaffStatus, status, authBloc (+7 more)

### Community 34 - "Repositories"
Cohesion: 0.15
Nodes (12): ../../domain/repositories/product_repository.dart, addProduct, deleteProduct, _fromMap, getCurrentStockBulk, getProductByBarcode, getProducts, getProductsByCategory (+4 more)

### Community 35 - "Domain"
Cohesion: 0.16
Nodes (13): AuthRepositoryImpl, AuthRepository, call, GetCurrentUserUseCase, repository, call, LoginWithGoogleUseCase, repository (+5 more)

### Community 36 - "Presentation"
Cohesion: 0.12
Nodes (15): build, _buildBarChart, _buildDateNavigation, _buildStatCard, _buildStatCards, createState, _dayAbbr, _formatCurrency (+7 more)

### Community 37 - "Presentation"
Cohesion: 0.12
Nodes (18): LoadStockMovements, build, _buildMovementCard, _changeTypes, _chipColor, createState, _filterApplied, _formatDate (+10 more)

### Community 38 - "Domain"
Cohesion: 0.14
Nodes (14): _buildDescriptionSnippet, createState, dispose, _dotSeparator, _filterChip, _metaText, _placeholderIcon, ProductListPage (+6 more)

### Community 39 - "Dashboard"
Cohesion: 0.09
Nodes (21): appBarTheme, buildActions, _buildDescriptionSnippet, buildLeading, buildResults, _buildSearchResults, buildSuggestions, createState (+13 more)

### Community 40 - "Domain"
Cohesion: 0.13
Nodes (14): barcode, categoryId, copyWith, createdAt, description, id, imageUrl, location (+6 more)

### Community 41 - "Presentation"
Cohesion: 0.12
Nodes (15): config/routes/app_routes.dart, core/service_locator.dart, features/auth/domain/repositories/auth_repository.dart, features/auth/presentation/bloc/auth_event.dart, features/billing/presentation/bloc/billing_bloc.dart, features/category/presentation/bloc/category_bloc.dart, features/product/presentation/bloc/product_bloc.dart, features/report/presentation/bloc/report_bloc.dart (+7 more)

### Community 42 - "Presentation"
Cohesion: 0.11
Nodes (19): ../bloc/billing_bloc.dart, ClearCartEvent, ../../domain/entities/cart_item.dart, build, _buildDataCell, _buildHeaderCell, CheckoutPage, _CheckoutPageState (+11 more)

### Community 43 - "Runnertests"
Cohesion: 0.15
Nodes (10): Any, Bool, Flutter, FlutterAppDelegate, AppDelegate, RunnerTests, UIApplication, UIKit (+2 more)

### Community 44 - "Usecases"
Cohesion: 0.21
Nodes (13): ../entities/product.dart, UseCase, AddProductUseCase, call, DeleteProductUseCase, GetCurrentStockBulkUseCase, GetProductByBarcodeUseCase, GetProductsByCategoryUseCase (+5 more)

### Community 45 - "Database"
Cohesion: 0.14
Nodes (13): ../../features/product/data/models/product_model.dart, ../../features/shop/data/models/shop_model.dart, HiveDatabase, init, productBox, productBoxName, settingsBox, settingsBoxName (+5 more)

### Community 46 - "Repositories"
Cohesion: 0.13
Nodes (14): _createProfile, _ensureProfileRole, _ensureShopForOwner, _extractErrorMessage, _fetchProfile, getCurrentUser, login, loginWithGoogle (+6 more)

### Community 47 - "Domain"
Cohesion: 0.15
Nodes (12): call, email, emailRedirectTo, name, password, props, repository, role (+4 more)

### Community 48 - "Presentation"
Cohesion: 0.23
Nodes (13): Authenticated, AuthError, AuthInitial, AuthLoading, AuthState, email, EmailVerificationPending, message (+5 more)

### Community 49 - "Presentation"
Cohesion: 0.12
Nodes (16): ../../../category/domain/entities/category.dart, _barcodeController, build, _categoryId, _checkDuplicate, createState, _description, _formKey (+8 more)

### Community 50 - "Presentation"
Cohesion: 0.14
Nodes (13): _applyThreshold, build, createState, dispose, _formatCurrency, initState, _searchController, _searchQuery (+5 more)

### Community 51 - "printer_repository_impl.dart"
Cohesion: 0.15
Nodes (12): ../../../../core/utils/printer_helper.dart, ../../domain/repositories/printer_repository.dart, PrinterHelper, clearPrinterData, connect, disconnect, getSavedPrinterMac, getSavedPrinterName (+4 more)

### Community 52 - "Widgets"
Cohesion: 0.15
Nodes (12): EdgeInsetsGeometry, borderRadius, build, elevation, icon, isFullWidth, isLoading, label (+4 more)

### Community 53 - "Presentation"
Cohesion: 0.12
Nodes (15): ../bloc/product_bloc.dart, _barcode, build, _categoryId, createState, _description, _formKey, _imageUrl (+7 more)

### Community 54 - "Models"
Cohesion: 0.18
Nodes (10): bool get, _channels, dispose, _isConnected, RealtimeService, subscribeToProducts, subscribeToTable, unsubscribe (+2 more)

### Community 55 - "Presentation"
Cohesion: 0.11
Nodes (17): ../../../../core/utils/app_validators.dart, ../../domain/entities/category.dart, CategoryModel, fromEntity, fromJson, toEntity, toJson, Category (+9 more)

### Community 56 - "Presentation"
Cohesion: 0.17
Nodes (11): connecting,
  connected,
  connectionFailure,
  disconnected,, connectedMac, connectedName, copyWith, devices, errorMessage, PrinterState, PrinterStatus (+3 more)

### Community 57 - "Presentation"
Cohesion: 0.46
Nodes (8): Bloc, DeleteStaffMember, LoadStaff, StaffEvent, StaffBloc, _confirmDelete, initState, _StaffListPageState

### Community 58 - "printer_repository.dart"
Cohesion: 0.17
Nodes (11): PrinterRepositoryImpl, clearPrinterData, connect, disconnect, getSavedPrinterMac, getSavedPrinterName, PrinterRepository, savePrinterData (+3 more)

### Community 59 - "Repositories"
Cohesion: 0.18
Nodes (10): ../../domain/repositories/category_repository.dart, addCategory, CategoryRepositoryImpl, deleteCategory, getCategories, _resolveShopId, _supabase, updateCategory (+2 more)

### Community 60 - "App"
Cohesion: 0.20
Nodes (9): AppTheme, backgroundColor, errorColor, primaryColor, secondaryColor, surfaceColor, textTheme, static const Color (+1 more)

### Community 61 - "Repositories"
Cohesion: 0.17
Nodes (11): getBillDetail, getBillHistory, getDailySales, getLowStockProducts, getSalesRange, getStockMovements, _resolveShopId, _supabase (+3 more)

### Community 62 - "Presentation"
Cohesion: 0.12
Nodes (15): _buildBillCard, createState, _datePickerButton, dispose, _formatDiscount, _fromDate, initState, _loadBills (+7 more)

### Community 63 - "Web"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 64 - "Domain"
Cohesion: 0.18
Nodes (10): ../../domain/entities/product.dart, ProductRepositoryImpl, addProduct, deleteProduct, getCurrentStockBulk, getProductByBarcode, getProducts, getProductsByCategory (+2 more)

### Community 65 - "Implementation"
Cohesion: 0.12
Nodes (14): Color, build, color, icon, label, PremiumStatCard, value, build (+6 more)

### Community 66 - "Widgets"
Cohesion: 0.18
Nodes (10): build, color, DashboardActionCard, icon, label, onTap, QuickActionTile, subtitle (+2 more)

### Community 67 - "Domain"
Cohesion: 0.20
Nodes (9): authStateChanges, getCurrentUser, login, loginWithGoogle, logout, resendVerificationEmail, signUp, updateProfile (+1 more)

### Community 68 - "Repositories"
Cohesion: 0.05
Nodes (39): dart:io, dart:ui, GlobalKey, address1, address2, cartItems, createState, customerName (+31 more)

### Community 69 - "Presentation"
Cohesion: 0.18
Nodes (11): add_edit_category_dialog.dart, ../bloc/category_bloc.dart, build, CategoryListPage, _CategoryListPageState, createState, dispose, _openAddEditDialog (+3 more)

### Community 70 - "Domain"
Cohesion: 0.17
Nodes (11): double?, double get, CartItem, copyWith, customPrice, product, props, quantity (+3 more)

### Community 71 - "Widgets"
Cohesion: 0.22
Nodes (7): build, InputLabel, text, package:billing_app/main.dart, package:flutter/material.dart, package:flutter_test/flutter_test.dart, main

### Community 72 - "Repositories"
Cohesion: 0.25
Nodes (14): AddCategory, CategoryEvent, CategoryState, DeleteCategory, LoadCategories, UpdateCategory, CategoryBloc, AddEditCategoryDialog (+6 more)

### Community 73 - "Domain"
Cohesion: 0.20
Nodes (9): addressLine1, addressLine2, copyWith, footerText, id, name, phoneNumber, props (+1 more)

### Community 74 - "Memory"
Cohesion: 0.25
Nodes (9): Session: Dashboard Homepage + Side Menu, Session: Supabase Realtime Sync, Session: Barcode/QR Scanner -> Cart, Stock Validation Before Bill, Phase 2 — Core Features, Phase 4.5 — Dashboard & Navigation UX, Billing (Point of Sale), Dynamic Categories (+1 more)

### Community 75 - "Rpd"
Cohesion: 0.46
Nodes (8): Migration 006_three_tier_roles.sql, Signup Default = Owner, UserRole Dart Enum, Phase 6 — SaaS-Ready Auth (Owner Signup + Shops), 3-Tier User Role System, handle_new_user DB Trigger, Owner Role, Super Admin Role

### Community 76 - "Models"
Cohesion: 0.33
Nodes (7): @HiveType, ProductModelAdapter, ShopModelAdapter, ProductModel, ShopModel, Shop, TypeAdapter

### Community 77 - "category_repository.dart"
Cohesion: 0.22
Nodes (8): ReportRepositoryImpl, getBillDetail, getBillHistory, getDailySales, getLowStockProducts, getSalesRange, getStockMovements, ReportRepository

### Community 78 - "Widgets"
Cohesion: 0.20
Nodes (10): TASK 3 — Core Feature Completion, 3A Scanner (barcode/QR → product lookup → cart), 3B Cart/Billing (cart state, qty, total, discount, bill), 3C Printer (ESC/POS receipt print), 3D UPI QR (dynamic UPI QR from amount), 3E Realtime (Supabase Realtime sync), RealtimeService, Phase 3 — Real-time & Multi-user (+2 more)

### Community 79 - "Domain"
Cohesion: 0.25
Nodes (7): DateTime, copyWith, createdAt, description, id, name, props

### Community 80 - "package:billing_app/features/report/domain/entities/report_entities.dart"
Cohesion: 0.14
Nodes (15): dart:async, AppDrawer, LogoutRequested, build, createState, dispose, email, EmailVerificationPage (+7 more)

### Community 81 - "Equatable"
Cohesion: 0.32
Nodes (7): CacheFailure, Failure, message, props, ServerFailure, List, package:equatable/equatable.dart

### Community 82 - "Client"
Cohesion: 0.13
Nodes (14): billDetail, billHistory, copyWith, currentPage, dailySales, error, hasMorePages, lowStockProducts (+6 more)

### Community 83 - "printer_repository_impl.dart"
Cohesion: 0.22
Nodes (8): ../../../auth/data/models/user_model.dart, ../../../auth/domain/entities/user.dart, ../../domain/repositories/staff_repository.dart, deleteStaffMember, getStaffMembers, _resolveShopId, _supabase, SupabaseClient get

### Community 84 - "Presentation"
Cohesion: 0.24
Nodes (18): _DashboardViewState, ReportBloc, LoadBillDetail, LoadBillHistory, LoadDailySales, LoadLowStockProducts, LoadSalesRange, ReportEvent (+10 more)

### Community 85 - "Presentation"
Cohesion: 0.15
Nodes (12): bill, build, _buildInfoCard, createState, _infoRow, initState, _isPrinting, _printReceipt (+4 more)

### Community 86 - "printer_repository.dart"
Cohesion: 0.25
Nodes (7): call, email, LoginParams, LoginUseCase, password, props, repository

### Community 87 - "Config"
Cohesion: 0.15
Nodes (12): BillItemModel, BillSummaryModel, DailySalesModel, fromJson, fromSupabaseRow, StockMovementModel, toJson, BillItem (+4 more)

### Community 88 - "Implementation"
Cohesion: 0.33
Nodes (7): Implementation Plan (Next Phase), Plugins affected by KGP (app_settings, device_info_plus, mobile_scanner, print_bluetooth_thermal, share_plus), Kotlin Gradle Plugin warning (build stability), RLS fix (owner profile seeded), Hardcoded Supabase project (wwutchscfnhwijxyftlw), TASK 1 — Fix Kotlin Gradle Plugin Warning, TASK 2 — Verify RLS Fix End-to-End

### Community 89 - "Implementation"
Cohesion: 0.20
Nodes (11): handle_new_user() trigger (default staff, signup promotes owner), shops table (id, owner_id, name, created_at) + RLS, signup_usecase (create shop + owner role), Super admin portal (deferred), TASK 4 — Auth Flow Hardening (SaaS-ready), Session: Auth Feature Complete, Migration 005_add_staff_phone.sql, Session: Staff Management Feature (+3 more)

### Community 90 - "category_list_page.dart"
Cohesion: 0.17
Nodes (11): billId, changeType, date, from, page, paymentMethod, productId, props (+3 more)

### Community 91 - "login_usecase.dart"
Cohesion: 0.22
Nodes (9): 1. Categories (Dynamic), 2. Product Inventory, 3. Billing (Point of Sale), 4. Real-time Sync (Supabase), 5. Shelf / Location Tracking, 6. QR Code Generator, 7. Reports & History, 8. Staff Management (Owner-only) (+1 more)

### Community 92 - "product_list_page.dart"
Cohesion: 0.29
Nodes (6): addCategory, deleteCategory, getCategories, updateCategory, package:billing_app/core/error/failure.dart, package:billing_app/features/category/domain/entities/category.dart

### Community 93 - "StatefulWidget"
Cohesion: 0.12
Nodes (16): ../../core/widgets/app_drawer.dart, IconData?, AppShell, build, child, AppBackButton, build, icon (+8 more)

### Community 94 - "Memory"
Cohesion: 0.29
Nodes (8): Migration 004_shop_data_scoping.sql, Session: Multi-Tenant Shop Data Isolation FIX, Owner-only Gating (3 Layers), shop_id Dart Threading, Staff Feature (Clean Arch), Row Level Security (RLS) Policies, Staff Role, Staff Management (Owner-only)

### Community 96 - "Web"
Cohesion: 0.50
Nodes (5): Analysis Options Config, Web Favicon, Web Icon (192), Web Icon (512), Flutter Web Entry HTML

### Community 98 - "Memory"
Cohesion: 0.40
Nodes (5): ReportBloc Global Provider Fix, Session: Reports & History Data+Domain, Session: Reports Presentation Layer, Phase 4 — Reports & History, Reports & History

### Community 99 - "App"
Cohesion: 0.40
Nodes (3): MainActivity, FlutterActivity, FlutterEngine

### Community 100 - "Launchimage"
Cohesion: 0.67
Nodes (3): iOS Launch Image (@1x), iOS Launch Image (@2x), iOS Launch Image (@3x)

### Community 138 - "app_back_button.dart"
Cohesion: 0.17
Nodes (17): build, _buildScannerSection, build, _buildQuickTiles, build, Route /categories, Route /products, Route /reports (+9 more)

### Community 139 - "category_model.dart"
Cohesion: 0.29
Nodes (6): fromJson, fromProfileJson, fromSupabaseAuth, toJson, UserModel, User

### Community 140 - "supabase_client.dart"
Cohesion: 0.13
Nodes (13): _, DeepLinkConfig, emailRedirectTo, host, scheme, _anonKey, client, initialize (+5 more)

### Community 141 - "package:billing_app/core/theme/app_theme.dart"
Cohesion: 0.22
Nodes (9): HomePage, _DashboardView, AddProductPage, EditProductPage, BillDetailPage, BillHistoryPage, DailySalesPage, LowStockPage (+1 more)

### Community 142 - "package:fpdart/fpdart.dart"
Cohesion: 0.25
Nodes (7): AddCategoryUseCase, call, DeleteCategoryUseCase, GetCategoriesUseCase, repository, UpdateCategoryUseCase, package:billing_app/features/category/domain/repositories/category_repository.dart

### Community 143 - "User Roles (3-Tier)"
Cohesion: 0.40
Nodes (4): ../error/failure.dart, call, NoParams, package:fpdart/fpdart.dart

### Community 144 - "RPD — Requirements & Product Definition"
Cohesion: 0.22
Nodes (9): Client Profile, Constraints, Product Overview, Role Assignment Flow, RPD — Requirements & Product Definition, Shop Isolation Implementation, Target Platforms, Tech Stack Changes (+1 more)

## Knowledge Gaps
- **977 isolated node(s):** `supabase`, `XCTest`, `_sub`, `rootNavigatorKey`, `dispose` (+972 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **34 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `AuthBloc` connect `Presentation` to `Presentation`, `Presentation`, `Presentation`, `app_back_button.dart`, `Presentation`, `Presentation`, `Presentation`, `Presentation`, `Presentation`, `Domain`, `Presentation`, `Widgets`, `Presentation`, `Presentation`, `Presentation`, `Presentation`, `Presentation`, `package:billing_app/features/report/domain/entities/report_entities.dart`, `Presentation`?**
  _High betweenness centrality (0.088) - this node is a cross-community bridge._
- **Why does `Product` connect `Presentation` to `Presentation`, `Repositories`, `Presentation`, `Domain`, `Domain`, `Usecases`, `Models`, `Presentation`?**
  _High betweenness centrality (0.024) - this node is a cross-community bridge._
- **Why does `ReportBloc` connect `Presentation` to `Presentation`, `Presentation`, `Dashboard`, `Presentation`, `app_back_button.dart`, `Presentation`, `Client`, `Presentation`, `Presentation`, `Presentation`, `Widgets`, `Presentation`?**
  _High betweenness centrality (0.022) - this node is a cross-community bridge._
- **What connects `supabase`, `XCTest`, `_sub` to the rest of the system?**
  _977 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Presentation` be split into smaller, more focused modules?**
  _Cohesion score 0.09009009009009009 - nodes in this community are weakly interconnected._
- **Should `Utils` be split into smaller, more focused modules?**
  _Cohesion score 0.09090909090909091 - nodes in this community are weakly interconnected._
- **Should `Presentation` be split into smaller, more focused modules?**
  _Cohesion score 0.0392156862745098 - nodes in this community are weakly interconnected._