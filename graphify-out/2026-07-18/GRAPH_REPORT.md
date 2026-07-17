# Graph Report - .  (2026-07-17)

## Corpus Check
- Corpus is ~48,535 words - fits in a single context window. You may not need a graph.

## Summary
- 1529 nodes · 2388 edges · 128 communities (94 shown, 34 thin omitted)
- Extraction: 98% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 38 edges (avg confidence: 0.89)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- Billing & Checkout Flow
- Product & Inventory
- Auth & Signup
- Supabase Schema & RLS
- Reports & History
- Staff Management
- Category Feature
- Realtime Sync
- Dashboard & Navigation
- Core Utils & Config
- Scanner & Cart
- Shop & Settings
- 3-Tier Role System
- App Drawer & UI Shell
- Service Locator & DI
- Community 15
- Community 16
- Community 17
- Community 18
- Community 19
- Community 20
- Community 21
- Community 22
- Community 23
- Community 24
- Community 25
- Community 26
- Community 27
- Community 28
- Community 29
- Community 30
- Community 31
- Community 32
- Community 33
- Community 34
- Community 35
- Community 36
- Community 37
- Community 38
- Community 39
- Community 40
- Community 41
- Community 42
- Community 43
- Community 44
- Community 45
- Community 46
- Community 47
- Community 48
- Community 49
- Community 50
- Community 51
- Community 52
- Community 53
- Community 54
- Community 55
- Community 56
- Community 57
- Community 58
- Community 59
- Community 60
- Community 61
- Community 62
- Community 63
- Community 64
- Community 65
- Community 66
- Community 67
- Community 68
- Community 69
- Community 70
- Community 71
- Community 72
- Community 73
- Community 74
- Community 75
- Community 76
- Community 77
- Community 78
- Community 79
- Community 80
- Community 81
- Community 82
- Community 83
- Community 84
- Community 85
- Community 86
- Community 87
- Community 88
- Community 89
- Community 90
- Community 91
- Community 92
- Community 93
- Community 94
- Community 95
- Community 96
- Community 97
- Community 98
- Community 102
- Community 103
- Community 104
- Community 105
- Community 106
- Community 107
- Community 108
- Community 109
- Community 110
- Community 112
- Community 113
- Community 114
- Community 115
- Community 116
- Community 117
- Community 118
- Community 119
- Community 120
- Community 121
- Community 122
- Community 123
- Community 124
- Community 125
- Community 126
- Community 127

## God Nodes (most connected - your core abstractions)
1. `AuthBloc` - 55 edges
2. `ReportBloc` - 32 edges
3. `BillingBloc` - 28 edges
4. `UseCase` - 27 edges
5. `ProductBloc` - 24 edges
6. `CategoryBloc` - 23 edges
7. `ShopBloc` - 18 edges
8. `PrinterBloc` - 16 edges
9. `BillingEvent` - 15 edges
10. `iOS App Icon (1024x1024)` - 15 edges

## Surprising Connections (you probably didn't know these)
- `File Structure (README)` --semantically_similar_to--> `Project Structure`  [INFERRED] [semantically similar]
  README.md → architecture.md
- `Android Launcher Icon (hdpi)` --semantically_similar_to--> `iOS App Icon (1024x1024)`  [INFERRED] [semantically similar]
  android/app/src/main/res/mipmap-hdpi/ic_launcher.png → ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png
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
- **Android Launcher Icon Set** — android_app_src_main_res_mipmap_hdpi_ic_launcher, android_app_src_main_res_mipmap_mdpi_ic_launcher, android_app_src_main_res_mipmap_xhdpi_ic_launcher, android_app_src_main_res_mipmap_xxhdpi_ic_launcher, android_app_src_main_res_mipmap_xxxhdpi_ic_launcher [INFERRED 0.95]
- **App Branding Assets (all platforms)** — android_app_src_main_res_mipmap_hdpi_ic_launcher, ios_runner_assets_xcassets_appicon_appiconset_icon_app_1024x1024_1x, web_favicon, web_icons_icon_192 [INFERRED 0.85]
- **iOS App Icon Set** — ios_runner_assets_xcassets_appicon_appiconset_icon_app_1024x1024_1x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_20x20_1x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_20x20_2x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_20x20_3x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_29x29_1x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_29x29_2x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_29x29_3x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_40x40_1x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_40x40_2x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_40x40_3x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_60x60_2x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_60x60_3x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_76x76_1x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_76x76_2x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_83_5x83_5_2x [INFERRED 0.95]
- **iOS Launch Image Set** — ios_runner_assets_xcassets_launchimage_imageset_launchimage, ios_runner_assets_xcassets_launchimage_imageset_launchimage_2x, ios_runner_assets_xcassets_launchimage_imageset_launchimage_3x [INFERRED 0.95]
- **Web Icon Set** — web_favicon, web_icons_icon_192, web_icons_icon_512, web_icons_icon_maskable_192, web_icons_icon_maskable_512 [INFERRED 0.95]

## Communities (128 total, 34 thin omitted)

### Community 0 - "Billing & Checkout Flow"
Cohesion: 0.06
Nodes (46): Bloc, ../bloc/shop_bloc.dart, LoadShopEvent, message, ShopError, ShopEvent, ShopInitial, ShopLoaded (+38 more)

### Community 1 - "Product & Inventory"
Cohesion: 0.07
Nodes (45): ../bloc/printer_bloc.dart, ../bloc/printer_event.dart, ../bloc/printer_state.dart, build, _buildScannerSection, _buildQuickTiles, _onConnect, _onDisconnect (+37 more)

### Community 2 - "Auth & Signup"
Cohesion: 0.04
Nodes (45): ../../../../core/utils/printer_helper.dart, ../../domain/repositories/printer_repository.dart, alignCenter, alignLeft, alignRight, boldOff, boldOn, checkPermission (+37 more)

### Community 3 - "Supabase Schema & RLS"
Cohesion: 0.05
Nodes (44): config/routes/app_routes.dart, core/service_locator.dart, ../../features/auth/data/repositories/auth_repository_impl.dart, features/auth/domain/repositories/auth_repository.dart, ../../features/auth/domain/usecases/get_current_user_usecase.dart, ../../features/auth/domain/usecases/login_usecase.dart, ../../features/auth/domain/usecases/login_with_google_usecase.dart, ../../features/auth/domain/usecases/logout_usecase.dart (+36 more)

### Community 4 - "Reports & History"
Cohesion: 0.04
Nodes (44): address1, address2, barcode, cartItems, copyWith, discountIsPercentage, error, footer (+36 more)

### Community 5 - "Staff Management"
Cohesion: 0.06
Nodes (34): categories, CategoryStatus, copyWith, description, id, message, name, status (+26 more)

### Community 6 - "Category Feature"
Cohesion: 0.06
Nodes (34): ../../../../core/realtime/realtime_service.dart, categoryId, changeType, copyWith, filteredProducts, id, message, payload (+26 more)

### Community 7 - "Realtime Sync"
Cohesion: 0.06
Nodes (31): Color, EdgeInsetsGeometry, IconData?, build, color, DashboardActionCard, icon, label (+23 more)

### Community 8 - "Dashboard & Navigation"
Cohesion: 0.07
Nodes (29): app_shell.dart, ../../features/auth/presentation/pages/email_verification_page.dart, ../../features/auth/presentation/pages/login_page.dart, ../../features/auth/presentation/pages/register_page.dart, ../../features/billing/presentation/pages/checkout_page.dart, ../../features/billing/presentation/pages/home_page.dart, ../../features/billing/presentation/pages/scanner_page.dart, ../../features/category/presentation/pages/category_list_page.dart (+21 more)

### Community 9 - "Core Utils & Config"
Cohesion: 0.15
Nodes (25): ReportBloc, billId, changeType, date, from, LoadBillDetail, LoadBillHistory, LoadDailySales (+17 more)

### Community 10 - "Scanner & Cart"
Cohesion: 0.10
Nodes (23): BillingState, CategoryState, ProductState, Equatable, BillDetailParams, BillHistoryParams, billId, call (+15 more)

### Community 11 - "Shop & Settings"
Cohesion: 0.08
Nodes (23): averageBill, billCount, changeType, copyWith, createdAt, date, discount, grandTotal (+15 more)

### Community 12 - "3-Tier Role System"
Cohesion: 0.15
Nodes (22): add_edit_category_dialog.dart, ../bloc/category_bloc.dart, AddCategory, CategoryEvent, DeleteCategory, LoadCategories, UpdateCategory, CategoryBloc (+14 more)

### Community 13 - "App Drawer & UI Shell"
Cohesion: 0.09
Nodes (22): authRepository, _authSubscription, close, getCurrentUserUseCase, loginUseCase, loginWithGoogleUseCase, logoutUseCase, _onCheckAuthStatus (+14 more)

### Community 14 - "Service Locator & DI"
Cohesion: 0.09
Nodes (21): hashCode, operator, read, typeId, write, barcode, categoryId, createdAt (+13 more)

### Community 15 - "Community 15"
Cohesion: 0.12
Nodes (20): CheckAuthStatus, authenticatedChild, AuthGate, build, _SplashScreen, createState, email, EmailVerificationPage (+12 more)

### Community 16 - "Community 16"
Cohesion: 0.10
Nodes (21): Architecture — Clean Architecture + BLoC + Supabase, Data Layer, Dependency Injection (get_it), Domain Layer, Hive (Local Cache/Offline), Navigation (go_router), Offline Strategy, Presentation Layer (+13 more)

### Community 17 - "Community 17"
Cohesion: 0.10
Nodes (20): Android Launcher Icon (hdpi), Android Launcher Icon (mdpi), Android Launcher Icon (xhdpi), Android Launcher Icon (xxhdpi), Android Launcher Icon (xxxhdpi), iOS App Icon (1024x1024), iOS App Icon (20x20 @1x), iOS App Icon (20x20 @2x) (+12 more)

### Community 18 - "Community 18"
Cohesion: 0.11
Nodes (19): ../../../auth/presentation/bloc/auth_bloc.dart, ../../../auth/presentation/bloc/auth_event.dart, ../../../auth/presentation/bloc/auth_state.dart, ../../../../core/widgets/app_back_button.dart, ../../../../core/widgets/input_label.dart, ../../../../core/widgets/primary_button.dart, AddStaffPage, _AddStaffPageState (+11 more)

### Community 19 - "Community 19"
Cohesion: 0.13
Nodes (19): class, ../entities/product.dart, UseCase, AddProductUseCase, call, DeleteProductUseCase, GetCurrentStockBulkUseCase, GetProductByBarcodeUseCase (+11 more)

### Community 20 - "Community 20"
Cohesion: 0.13
Nodes (17): core/data/hive_database.dart, ../../../../core/error/failure.dart, ../../../../core/usecase/usecase.dart, ../../domain/entities/shop.dart, ../../domain/repositories/shop_repository.dart, getShop, shopKey, ShopRepositoryImpl (+9 more)

### Community 21 - "Community 21"
Cohesion: 0.11
Nodes (16): ../../core/widgets/app_drawer.dart, AppShell, build, child, AppBackButton, icon, size, build (+8 more)

### Community 22 - "Community 22"
Cohesion: 0.11
Nodes (20): Design — Design System, Component Specs, DashboardActionCard + QuickActionTile, Dashboard Screen, Layout Considerations, Scanner Screen, Screens & Routes, StatCard Widget (+12 more)

### Community 23 - "Community 23"
Cohesion: 0.10
Nodes (19): UserModel, copyWith, email, emailConfirmedAt, fromString, id, isEmailConfirmed, isOwner (+11 more)

### Community 24 - "Community 24"
Cohesion: 0.13
Nodes (19): createState, DashboardPage, _DashboardView, _DashboardViewState, _formatCurrency, _Greeting, _greetingPrefix, initState (+11 more)

### Community 25 - "Community 25"
Cohesion: 0.11
Nodes (17): ../../../../core/utils/app_validators.dart, ../../domain/entities/category.dart, CategoryModel, fromEntity, fromJson, toEntity, toJson, Category (+9 more)

### Community 26 - "Community 26"
Cohesion: 0.21
Nodes (19): AddProductToCartEvent, BillingEvent, ClearCartEvent, ClearStockErrorsEvent, PrintReceiptEvent, RemoveProductFromCartEvent, ScanBarcodeEvent, SetDiscountTypeEvent (+11 more)

### Community 27 - "Community 27"
Cohesion: 0.12
Nodes (17): AddProduct, AddProductPage, _AddProductPageState, _barcode, build, _categoryId, createState, _description (+9 more)

### Community 28 - "Community 28"
Cohesion: 0.11
Nodes (17): authBloc, getBillDetailUseCase, getBillHistoryUseCase, getDailySalesUseCase, getLowStockProductsUseCase, getSalesRangeUseCase, getStockMovementsUseCase, _onLoadBillDetail (+9 more)

### Community 29 - "Community 29"
Cohesion: 0.12
Nodes (15): ../../../auth/data/models/user_model.dart, ../../../auth/domain/entities/user.dart, core/supabase/supabase_client.dart, ../../domain/repositories/category_repository.dart, ../../domain/repositories/staff_repository.dart, addCategory, deleteCategory, getCategories (+7 more)

### Community 30 - "Community 30"
Cohesion: 0.12
Nodes (16): ../../../billing/presentation/bloc/billing_bloc.dart, ../../domain/entities/cart_item.dart, build, _buildBottomPanel, _buildCameraOffState, _buildCorner, _buildEmptyCart, _buildOverlayButton (+8 more)

### Community 31 - "Community 31"
Cohesion: 0.15
Nodes (16): AppDrawer, AuthEvent, email, GoogleLoginRequested, LogoutRequested, name, password, props (+8 more)

### Community 32 - "Community 32"
Cohesion: 0.12
Nodes (14): fromJson, fromProfileJson, fromSupabaseAuth, toJson, StaffRepositoryImpl, deleteStaffMember, getStaffMembers, StaffRepository (+6 more)

### Community 33 - "Community 33"
Cohesion: 0.16
Nodes (14): AuthRepositoryImpl, AuthRepository, call, GetCurrentUserUseCase, repository, call, LoginWithGoogleUseCase, repository (+6 more)

### Community 34 - "Community 34"
Cohesion: 0.13
Nodes (16): SignUpRequested, _confirmPasswordController, createState, dispose, _emailController, _formKey, _isLoading, _nameController (+8 more)

### Community 35 - "Community 35"
Cohesion: 0.12
Nodes (16): build, _buildBarChart, _buildDateNavigation, _buildStatCard, _buildStatCards, createState, DailySalesPage, _dayAbbr (+8 more)

### Community 36 - "Community 36"
Cohesion: 0.12
Nodes (15): hashCode, operator, read, typeId, write, int get, addressLine1, addressLine2 (+7 more)

### Community 37 - "Community 37"
Cohesion: 0.12
Nodes (15): copyWith, id, message, staff, StaffState, StaffStatus, status, authBloc (+7 more)

### Community 38 - "Community 38"
Cohesion: 0.13
Nodes (15): build, _buildMovementCard, _changeTypes, _chipColor, createState, _filterApplied, _formatDate, _fromDate (+7 more)

### Community 39 - "Community 39"
Cohesion: 0.13
Nodes (14): dart:async, _createProfile, _ensureProfileRole, _extractErrorMessage, _fetchProfile, getCurrentUser, login, loginWithGoogle (+6 more)

### Community 40 - "Community 40"
Cohesion: 0.28
Nodes (14): AuthBloc, Authenticated, AuthError, AuthInitial, AuthLoading, AuthState, email, EmailVerificationPending (+6 more)

### Community 41 - "Community 41"
Cohesion: 0.13
Nodes (14): barcode, categoryId, copyWith, createdAt, description, id, imageUrl, location (+6 more)

### Community 42 - "Community 42"
Cohesion: 0.13
Nodes (14): billDetail, billHistory, copyWith, currentPage, dailySales, error, hasMorePages, lowStockProducts (+6 more)

### Community 43 - "Community 43"
Cohesion: 0.15
Nodes (10): Any, Bool, Flutter, FlutterAppDelegate, AppDelegate, RunnerTests, UIApplication, UIKit (+2 more)

### Community 44 - "Community 44"
Cohesion: 0.15
Nodes (13): core/theme/app_theme.dart, build, createState, dispose, initState, product, _qrDataController, QrGeneratorPage (+5 more)

### Community 45 - "Community 45"
Cohesion: 0.27
Nodes (14): DeleteProduct, FilterByCategory, GenerateQrCode, InitRealtime, LoadProducts, ProductEvent, ProductsRealtimeUpdated, UpdateProduct (+6 more)

### Community 46 - "Community 46"
Cohesion: 0.14
Nodes (13): ../../features/product/data/models/product_model.dart, ../../features/shop/data/models/shop_model.dart, HiveDatabase, init, productBox, productBoxName, settingsBox, settingsBoxName (+5 more)

### Community 47 - "Community 47"
Cohesion: 0.17
Nodes (12): ../bloc/billing_bloc.dart, build, controller, _corner, createState, dispose, _isScanned, ScannerPage (+4 more)

### Community 48 - "Community 48"
Cohesion: 0.15
Nodes (12): ../bloc/staff_bloc.dart, ../../../../features/auth/domain/entities/user.dart, features/auth/presentation/bloc/auth_bloc.dart, ../../../../features/auth/presentation/bloc/auth_state.dart, build, createState, dispose, _initials (+4 more)

### Community 49 - "Community 49"
Cohesion: 0.18
Nodes (12): FormState, LoginRequested, createState, dispose, _emailController, _formKey, _isLoading, LoginPage (+4 more)

### Community 50 - "Community 50"
Cohesion: 0.15
Nodes (12): call, email, emailRedirectTo, name, password, props, repository, role (+4 more)

### Community 51 - "Community 51"
Cohesion: 0.17
Nodes (12): build, build, _buildCard, createState, ReportsHomePage, _ReportsHomePageState, package:billing_app/core/theme/app_theme.dart, Route /reports/bills (+4 more)

### Community 52 - "Community 52"
Cohesion: 0.15
Nodes (12): build, _categoryId, createState, _description, _formKey, _imageUrl, initState, _location (+4 more)

### Community 53 - "Community 53"
Cohesion: 0.15
Nodes (12): BillItemModel, BillSummaryModel, DailySalesModel, fromJson, fromSupabaseRow, StockMovementModel, toJson, BillItem (+4 more)

### Community 54 - "Community 54"
Cohesion: 0.15
Nodes (12): _applyThreshold, build, createState, dispose, _formatCurrency, initState, _searchController, _searchQuery (+4 more)

### Community 55 - "Community 55"
Cohesion: 0.17
Nodes (11): connecting,
  connected,
  connectionFailure,
  disconnected,, connectedMac, connectedName, copyWith, devices, errorMessage, PrinterState, PrinterStatus (+3 more)

### Community 56 - "Community 56"
Cohesion: 0.17
Nodes (11): ../../domain/repositories/product_repository.dart, addProduct, deleteProduct, _fromMap, getCurrentStockBulk, getProductByBarcode, getProducts, getProductsByCategory (+3 more)

### Community 57 - "Community 57"
Cohesion: 0.18
Nodes (11): _buildDataCell, _buildHeaderCell, CheckoutPage, _CheckoutPageState, createState, dispose, _isEditingTotal, _showStockErrorsDialog (+3 more)

### Community 58 - "Community 58"
Cohesion: 0.18
Nodes (11): BillHistoryPage, _BillHistoryPageState, _buildBillCard, createState, _datePickerButton, _fromDate, initState, _selectDate (+3 more)

### Community 59 - "Community 59"
Cohesion: 0.18
Nodes (10): ../bloc/product_bloc.dart, ../../../category/presentation/bloc/category_bloc.dart, createState, dispose, _filterChip, _getCategoryName, _placeholderIcon, _scanQR (+2 more)

### Community 60 - "Community 60"
Cohesion: 0.18
Nodes (10): bool get, _channels, dispose, _isConnected, RealtimeService, subscribeToProducts, subscribeToTable, unsubscribe (+2 more)

### Community 61 - "Community 61"
Cohesion: 0.18
Nodes (10): ../../domain/entities/product.dart, ProductRepositoryImpl, addProduct, deleteProduct, getCurrentStockBulk, getProductByBarcode, getProducts, getProductsByCategory (+2 more)

### Community 62 - "Community 62"
Cohesion: 0.18
Nodes (10): AppTheme, backgroundColor, errorColor, primaryColor, secondaryColor, surfaceColor, textTheme, package:google_fonts/google_fonts.dart (+2 more)

### Community 63 - "Community 63"
Cohesion: 0.18
Nodes (10): currentRoute, _DrawerItem, icon, _initials, label, onTap, _ProfileHeader, route (+2 more)

### Community 64 - "Community 64"
Cohesion: 0.18
Nodes (10): getBillDetail, getBillHistory, getDailySales, getLowStockProducts, getSalesRange, getStockMovements, _supabase, package:billing_app/core/supabase/supabase_client.dart (+2 more)

### Community 65 - "Community 65"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 66 - "Community 66"
Cohesion: 0.20
Nodes (10): TASK 3 — Core Feature Completion, 3A Scanner (barcode/QR → product lookup → cart), 3B Cart/Billing (cart state, qty, total, discount, bill), 3C Printer (ESC/POS receipt print), 3D UPI QR (dynamic UPI QR from amount), 3E Realtime (Supabase Realtime sync), RealtimeService, Phase 3 — Real-time & Multi-user (+2 more)

### Community 67 - "Community 67"
Cohesion: 0.20
Nodes (9): authStateChanges, getCurrentUser, login, loginWithGoogle, logout, resendVerificationEmail, signUp, updateProfile (+1 more)

### Community 68 - "Community 68"
Cohesion: 0.22
Nodes (8): double get, CartItem, copyWith, product, props, quantity, total, package:billing_app/features/product/domain/entities/product.dart

### Community 69 - "Community 69"
Cohesion: 0.22
Nodes (8): ReportRepositoryImpl, getBillDetail, getBillHistory, getDailySales, getLowStockProducts, getSalesRange, getStockMovements, ReportRepository

### Community 70 - "Community 70"
Cohesion: 0.22
Nodes (8): addressLine1, addressLine2, copyWith, footerText, name, phoneNumber, props, upiId

### Community 71 - "Community 71"
Cohesion: 0.25
Nodes (9): Session: Dashboard Homepage + Side Menu, Session: Supabase Realtime Sync, Session: Barcode/QR Scanner -> Cart, Stock Validation Before Bill, Phase 2 — Core Features, Phase 4.5 — Dashboard & Navigation UX, Billing (Point of Sale), Dynamic Categories (+1 more)

### Community 72 - "Community 72"
Cohesion: 0.39
Nodes (9): Migration 006_three_tier_roles.sql, Signup Default = Owner, UserRole Dart Enum, Phase 6 — SaaS-Ready Auth (Owner Signup + Shops), 3-Tier User Role System, handle_new_user DB Trigger, Owner Role, Role Assignment Flow (+1 more)

### Community 73 - "Community 73"
Cohesion: 0.29
Nodes (8): @HiveType, ProductModelAdapter, ShopModelAdapter, ProductModel, Product, ShopModel, Shop, TypeAdapter

### Community 74 - "Community 74"
Cohesion: 0.25
Nodes (7): DateTime, copyWith, createdAt, description, id, name, props

### Community 75 - "Community 75"
Cohesion: 0.32
Nodes (7): CacheFailure, Failure, message, props, ServerFailure, List, package:equatable/equatable.dart

### Community 76 - "Community 76"
Cohesion: 0.25
Nodes (7): _anonKey, client, initialize, SupabaseConfig, _url, package:supabase_flutter/supabase_flutter.dart, static SupabaseClient get

### Community 77 - "Community 77"
Cohesion: 0.25
Nodes (7): call, email, LoginParams, LoginUseCase, password, props, repository

### Community 78 - "Community 78"
Cohesion: 0.25
Nodes (7): bill, BillDetailPage, build, _buildInfoCard, _infoRow, package:billing_app/core/widgets/primary_button.dart, package:intl/intl.dart

### Community 79 - "Community 79"
Cohesion: 0.29
Nodes (6): _, DeepLinkConfig, emailRedirectTo, host, scheme, static const String

### Community 80 - "Community 80"
Cohesion: 0.57
Nodes (7): DeleteStaffMember, LoadStaff, StaffEvent, StaffBloc, _confirmDelete, initState, _StaffListPageState

### Community 81 - "Community 81"
Cohesion: 0.33
Nodes (7): Implementation Plan (Next Phase), Plugins affected by KGP (app_settings, device_info_plus, mobile_scanner, print_bluetooth_thermal, share_plus), Kotlin Gradle Plugin warning (build stability), RLS fix (owner profile seeded), Hardcoded Supabase project (wwutchscfnhwijxyftlw), TASK 1 — Fix Kotlin Gradle Plugin Warning, TASK 2 — Verify RLS Fix End-to-End

### Community 82 - "Community 82"
Cohesion: 0.29
Nodes (7): handle_new_user() trigger (default staff, signup promotes owner), shops table (id, owner_id, name, created_at) + RLS, signup_usecase (create shop + owner role), Super admin portal (deferred), TASK 4 — Auth Flow Hardening (SaaS-ready), Session: Auth Feature Complete, Phase 1 — Database & Auth

### Community 83 - "Community 83"
Cohesion: 0.29
Nodes (7): HomePage, AddEditCategoryDialog, CategoryListPage, EditProductPage, ProductListPage, LowStockPage, StatefulWidget

### Community 84 - "Community 84"
Cohesion: 0.40
Nodes (6): Migration 004_shop_data_scoping.sql, Session: Multi-Tenant Shop Data Isolation FIX, Owner-only Gating (3 Layers), shop_id Dart Threading, Staff Feature (Clean Arch), Row Level Security (RLS) Policies

### Community 85 - "Community 85"
Cohesion: 0.40
Nodes (6): Migration 005_add_staff_phone.sql, Session: Staff Management Feature, Migration 003_saas_shops.sql, Phase 6.5 — Staff Management (Owner-only), Staff Role, Staff Management (Owner-only)

### Community 86 - "Community 86"
Cohesion: 0.50
Nodes (5): Analysis Options Config, Web Favicon, Web Icon (192), Web Icon (512), Flutter Web Entry HTML

### Community 87 - "Community 87"
Cohesion: 0.40
Nodes (4): ../error/failure.dart, call, NoParams, package:fpdart/fpdart.dart

### Community 88 - "Community 88"
Cohesion: 0.40
Nodes (5): ReportBloc Global Provider Fix, Session: Reports & History Data+Domain, Session: Reports Presentation Layer, Phase 4 — Reports & History, Reports & History

### Community 90 - "Community 90"
Cohesion: 0.67
Nodes (3): iOS Launch Image (@1x), iOS Launch Image (@2x), iOS Launch Image (@3x)

## Knowledge Gaps
- **839 isolated node(s):** `supabase`, `XCTest`, `rootNavigatorKey`, `child`, `build` (+834 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **34 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `AuthBloc` connect `Community 40` to `Billing & Checkout Flow`, `Product & Inventory`, `Supabase Schema & RLS`, `Reports & History`, `Staff Management`, `Category Feature`, `Dashboard & Navigation`, `App Drawer & UI Shell`, `Community 15`, `Community 18`, `Community 24`, `Community 28`, `Community 31`, `Community 34`, `Community 37`, `Community 48`, `Community 49`, `Community 63`, `Community 80`?**
  _High betweenness centrality (0.103) - this node is a cross-community bridge._
- **Why does `AuthRepository` connect `Community 33` to `Community 67`, `Supabase Schema & RLS`, `App Drawer & UI Shell`, `Community 77`, `Community 50`?**
  _High betweenness centrality (0.021) - this node is a cross-community bridge._
- **Why does `BillingBloc` connect `Community 26` to `Billing & Checkout Flow`, `Supabase Schema & RLS`, `Reports & History`, `Scanner & Cart`, `Community 47`, `Community 24`, `Community 57`, `Community 30`?**
  _High betweenness centrality (0.017) - this node is a cross-community bridge._
- **What connects `supabase`, `XCTest`, `rootNavigatorKey` to the rest of the system?**
  _839 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Billing & Checkout Flow` be split into smaller, more focused modules?**
  _Cohesion score 0.06205673758865248 - nodes in this community are weakly interconnected._
- **Should `Product & Inventory` be split into smaller, more focused modules?**
  _Cohesion score 0.0700354609929078 - nodes in this community are weakly interconnected._
- **Should `Auth & Signup` be split into smaller, more focused modules?**
  _Cohesion score 0.04343971631205674 - nodes in this community are weakly interconnected._