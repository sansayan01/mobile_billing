# Graph Report - .  (2026-07-17)

## Corpus Check
- Corpus is ~43,995 words - fits in a single context window. You may not need a graph.

## Summary
- 1436 nodes · 2252 edges · 120 communities (100 shown, 20 thin omitted)
- Extraction: 96% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 29 edges (avg confidence: 0.93)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- Community 0
- Community 1
- Community 2
- Community 3
- Community 4
- Community 5
- Community 6
- Community 7
- Community 8
- Community 9
- Community 10
- Community 11
- Community 12
- Community 13
- Community 14
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
- Community 99
- Community 100
- Community 101
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

## God Nodes (most connected - your core abstractions)
1. `AuthBloc` - 46 edges
2. `ReportBloc` - 32 edges
3. `BillingBloc` - 28 edges
4. `UseCase` - 25 edges
5. `ProductBloc` - 24 edges
6. `CategoryBloc` - 23 edges
7. `Flutter Billing App` - 23 edges
8. `ShopBloc` - 18 edges
9. `PrinterBloc` - 16 edges
10. `BillingEvent` - 15 edges

## Surprising Connections (you probably didn't know these)
- `File Structure (README)` --semantically_similar_to--> `Project Structure`  [INFERRED] [semantically similar]
  README.md → architecture.md
- `Android Launcher Icon (hdpi)` --semantically_similar_to--> `iOS App Icon (1024x1024)`  [INFERRED] [semantically similar]
  android/app/src/main/res/mipmap-hdpi/ic_launcher.png → ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png
- `Email Verification Gate (Dart-only)` ----> `Dart-Only Fix Preference (avoid SQL migrations)`  [0.88]
  memory.md → CLAUDE.md
- `Auth Feature (Supabase + Google OAuth)` ----> `Flutter Billing App`  [0.9]
  memory.md → CLAUDE.md
- `Reports & History Feature` ----> `Flutter Billing App`  [0.9]
  memory.md → CLAUDE.md

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Next Phase Tasks (1-4 + execution + rollback)** — implementation_plan_task1, implementation_plan_task2, implementation_plan_task3, implementation_plan_task4, implementation_plan_execution_model, implementation_plan_rollback [EXTRACTED 1.00]
- **RPD Core Features** — rpd_categories, rpd_productinventory, rpd_billing, rpd_realtime, rpd_shelflocation, rpd_qrgenerator, rpd_reports [EXTRACTED 1.00]
- **Clean Architecture Layers** — architecture_presentation, architecture_domain, architecture_data [EXTRACTED 1.00]
- **Android Launcher Icon Set** — android_app_src_main_res_mipmap_hdpi_ic_launcher, android_app_src_main_res_mipmap_mdpi_ic_launcher, android_app_src_main_res_mipmap_xhdpi_ic_launcher, android_app_src_main_res_mipmap_xxhdpi_ic_launcher, android_app_src_main_res_mipmap_xxxhdpi_ic_launcher [INFERRED 0.95]
- **App Branding Assets (all platforms)** — android_app_src_main_res_mipmap_hdpi_ic_launcher, ios_runner_assets_xcassets_appicon_appiconset_icon_app_1024x1024_1x, web_favicon, web_icons_icon_192 [INFERRED 0.85]
- **iOS App Icon Set** — ios_runner_assets_xcassets_appicon_appiconset_icon_app_1024x1024_1x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_20x20_1x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_20x20_2x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_20x20_3x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_29x29_1x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_29x29_2x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_29x29_3x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_40x40_1x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_40x40_2x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_40x40_3x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_60x60_2x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_60x60_3x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_76x76_1x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_76x76_2x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_83_5x83_5_2x [INFERRED 0.95]
- **iOS Launch Image Set** — ios_runner_assets_xcassets_launchimage_imageset_launchimage, ios_runner_assets_xcassets_launchimage_imageset_launchimage_2x, ios_runner_assets_xcassets_launchimage_imageset_launchimage_3x [INFERRED 0.95]
- **Web Icon Set** — web_favicon, web_icons_icon_192, web_icons_icon_512, web_icons_icon_maskable_192, web_icons_icon_maskable_512 [INFERRED 0.95]

## Communities (120 total, 20 thin omitted)

### Community 0 - "Community 0"
Cohesion: 0.06
Nodes (52): ../bloc/printer_bloc.dart, ../bloc/printer_event.dart, ../bloc/printer_state.dart, ../../domain/repositories/printer_repository.dart, build, _buildScannerSection, build, _buildQuickTiles (+44 more)

### Community 1 - "Community 1"
Cohesion: 0.04
Nodes (44): address1, address2, barcode, cartItems, copyWith, discountIsPercentage, error, footer (+36 more)

### Community 2 - "Community 2"
Cohesion: 0.05
Nodes (36): ../../../auth/presentation/bloc/auth_bloc.dart, ../../../auth/presentation/bloc/auth_state.dart, ../../../../core/realtime/realtime_service.dart, categoryId, changeType, copyWith, filteredProducts, id (+28 more)

### Community 3 - "Community 3"
Cohesion: 0.06
Nodes (35): Architecture — Clean Architecture + BLoC + Supabase, Data Layer, Dependency Injection (get_it), Domain Layer, Hive (Local Cache/Offline), Navigation (go_router), Offline Strategy, Presentation Layer (+27 more)

### Community 4 - "Community 4"
Cohesion: 0.07
Nodes (28): app_shell.dart, ../../features/auth/presentation/bloc/auth_state.dart, ../../features/auth/presentation/pages/email_verification_page.dart, ../../features/auth/presentation/pages/login_page.dart, ../../features/auth/presentation/pages/register_page.dart, ../../features/billing/presentation/pages/checkout_page.dart, ../../features/billing/presentation/pages/home_page.dart, ../../features/billing/presentation/pages/scanner_page.dart (+20 more)

### Community 5 - "Community 5"
Cohesion: 0.08
Nodes (25): ../../features/auth/data/repositories/auth_repository_impl.dart, ../../features/auth/domain/usecases/get_current_user_usecase.dart, ../../features/auth/domain/usecases/login_usecase.dart, ../../features/auth/domain/usecases/login_with_google_usecase.dart, ../../features/auth/domain/usecases/logout_usecase.dart, ../../features/auth/domain/usecases/signup_usecase.dart, ../../features/category/data/repositories/category_repository_impl.dart, ../../features/category/domain/repositories/category_repository.dart (+17 more)

### Community 6 - "Community 6"
Cohesion: 0.10
Nodes (23): BillingState, CategoryState, ProductState, Equatable, BillDetailParams, BillHistoryParams, billId, call (+15 more)

### Community 7 - "Community 7"
Cohesion: 0.08
Nodes (23): averageBill, billCount, changeType, copyWith, createdAt, date, discount, grandTotal (+15 more)

### Community 8 - "Community 8"
Cohesion: 0.09
Nodes (22): alignCenter, alignLeft, alignRight, boldOff, boldOn, checkPermission, connect, disconnect (+14 more)

### Community 9 - "Community 9"
Cohesion: 0.09
Nodes (22): authRepository, _authSubscription, close, getCurrentUserUseCase, loginUseCase, loginWithGoogleUseCase, logoutUseCase, _onCheckAuthStatus (+14 more)

### Community 10 - "Community 10"
Cohesion: 0.09
Nodes (21): hashCode, operator, read, typeId, write, barcode, categoryId, createdAt (+13 more)

### Community 11 - "Community 11"
Cohesion: 0.12
Nodes (20): CheckAuthStatus, authenticatedChild, AuthGate, build, _SplashScreen, createState, email, EmailVerificationPage (+12 more)

### Community 12 - "Community 12"
Cohesion: 0.16
Nodes (21): ReportBloc, billId, changeType, date, from, LoadBillDetail, LoadBillHistory, LoadLowStockProducts (+13 more)

### Community 13 - "Community 13"
Cohesion: 0.10
Nodes (20): categories, CategoryStatus, copyWith, description, id, message, name, status (+12 more)

### Community 14 - "Community 14"
Cohesion: 0.11
Nodes (20): LoadDailySales, LoadSalesRange, build, _buildBarChart, _buildDateNavigation, _buildStatCard, _buildStatCards, createState (+12 more)

### Community 15 - "Community 15"
Cohesion: 0.10
Nodes (20): Android Launcher Icon (hdpi), Android Launcher Icon (mdpi), Android Launcher Icon (xhdpi), Android Launcher Icon (xxhdpi), Android Launcher Icon (xxxhdpi), iOS App Icon (1024x1024), iOS App Icon (20x20 @1x), iOS App Icon (20x20 @2x) (+12 more)

### Community 16 - "Community 16"
Cohesion: 0.13
Nodes (19): class, ../entities/product.dart, UseCase, AddProductUseCase, call, DeleteProductUseCase, GetCurrentStockBulkUseCase, GetProductByBarcodeUseCase (+11 more)

### Community 17 - "Community 17"
Cohesion: 0.13
Nodes (17): core/data/hive_database.dart, ../../../../core/error/failure.dart, ../../../../core/usecase/usecase.dart, ../../domain/entities/shop.dart, ../../domain/repositories/shop_repository.dart, getShop, shopKey, ShopRepositoryImpl (+9 more)

### Community 18 - "Community 18"
Cohesion: 0.11
Nodes (17): ../../../billing/presentation/bloc/billing_bloc.dart, ../../../../core/widgets/primary_button.dart, ../../domain/entities/cart_item.dart, build, _buildBottomPanel, _buildCameraOffState, _buildCorner, _buildEmptyCart (+9 more)

### Community 19 - "Community 19"
Cohesion: 0.14
Nodes (17): message, ShopError, ShopInitial, ShopLoaded, ShopLoading, ShopOperationSuccess, ShopState, ../../domain/usecases/shop_usecases.dart (+9 more)

### Community 20 - "Community 20"
Cohesion: 0.12
Nodes (18): Implementation Plan (Next Phase), handle_new_user() trigger (default staff, signup promotes owner), Plugins affected by KGP (app_settings, device_info_plus, mobile_scanner, print_bluetooth_thermal, share_plus), Kotlin Gradle Plugin warning (build stability), RLS fix (owner profile seeded), shops table (id, owner_id, name, created_at) + RLS, signup_usecase (create shop + owner role), Hardcoded Supabase project (wwutchscfnhwijxyftlw) (+10 more)

### Community 21 - "Community 21"
Cohesion: 0.14
Nodes (17): createState, DashboardPage, _formatCurrency, _Greeting, _greetingPrefix, initState, _LowStockBanner, _lowStockThreshold (+9 more)

### Community 22 - "Community 22"
Cohesion: 0.11
Nodes (17): authBloc, getBillDetailUseCase, getBillHistoryUseCase, getDailySalesUseCase, getLowStockProductsUseCase, getSalesRangeUseCase, getStockMovementsUseCase, _onLoadBillDetail (+9 more)

### Community 23 - "Community 23"
Cohesion: 0.12
Nodes (16): config/routes/app_routes.dart, core/service_locator.dart, features/auth/domain/repositories/auth_repository.dart, features/auth/presentation/bloc/auth_bloc.dart, features/auth/presentation/bloc/auth_event.dart, features/billing/presentation/bloc/billing_bloc.dart, features/category/presentation/bloc/category_bloc.dart, features/product/presentation/bloc/product_bloc.dart (+8 more)

### Community 24 - "Community 24"
Cohesion: 0.24
Nodes (17): AddProductToCartEvent, BillingEvent, ClearStockErrorsEvent, PrintReceiptEvent, RemoveProductFromCartEvent, ScanBarcodeEvent, SetDiscountTypeEvent, SubmitBillEvent (+9 more)

### Community 25 - "Community 25"
Cohesion: 0.23
Nodes (17): AddProduct, DeleteProduct, FilterByCategory, GenerateQrCode, InitRealtime, LoadProducts, ProductEvent, ProductsRealtimeUpdated (+9 more)

### Community 26 - "Community 26"
Cohesion: 0.15
Nodes (16): AppDrawer, AuthEvent, email, GoogleLoginRequested, LogoutRequested, name, password, props (+8 more)

### Community 27 - "Community 27"
Cohesion: 0.16
Nodes (14): AuthRepositoryImpl, AuthRepository, call, GetCurrentUserUseCase, repository, call, LoginWithGoogleUseCase, repository (+6 more)

### Community 28 - "Community 28"
Cohesion: 0.16
Nodes (16): Auto-Pilot Mode (no questions, just execute), Category Feature (CRUD), Clean Architecture (Presentation/Domain/Data), Flutter Billing App, flutter_bloc (BLoC), get_it (DI), go_router (Navigation), graphify knowledge graph (+8 more)

### Community 29 - "Community 29"
Cohesion: 0.12
Nodes (15): hashCode, operator, read, typeId, write, int get, addressLine1, addressLine2 (+7 more)

### Community 30 - "Community 30"
Cohesion: 0.13
Nodes (14): CategoryRepositoryImpl, addCategory, CategoryRepository, deleteCategory, getCategories, updateCategory, AddCategoryUseCase, call (+6 more)

### Community 31 - "Community 31"
Cohesion: 0.13
Nodes (15): build, _buildMovementCard, _changeTypes, _chipColor, createState, _filterApplied, _formatDate, _fromDate (+7 more)

### Community 32 - "Community 32"
Cohesion: 0.15
Nodes (14): ../bloc/billing_bloc.dart, ClearCartEvent, build, _buildDataCell, _buildHeaderCell, CheckoutPage, _CheckoutPageState, createState (+6 more)

### Community 33 - "Community 33"
Cohesion: 0.13
Nodes (14): ../bloc/shop_bloc.dart, _address1Controller, _address2Controller, _buildTextField, createState, dispose, _footerController, _formKey (+6 more)

### Community 34 - "Community 34"
Cohesion: 0.13
Nodes (14): dart:async, _createProfile, _createShop, _extractErrorMessage, _fetchProfile, getCurrentUser, login, loginWithGoogle (+6 more)

### Community 35 - "Community 35"
Cohesion: 0.28
Nodes (14): AuthBloc, Authenticated, AuthError, AuthInitial, AuthLoading, AuthState, email, EmailVerificationPending (+6 more)

### Community 36 - "Community 36"
Cohesion: 0.15
Nodes (14): SignUpRequested, _confirmPasswordController, createState, dispose, _emailController, _formKey, _isLoading, _nameController (+6 more)

### Community 37 - "Community 37"
Cohesion: 0.13
Nodes (14): barcode, categoryId, copyWith, createdAt, description, id, imageUrl, location (+6 more)

### Community 38 - "Community 38"
Cohesion: 0.14
Nodes (14): build, _categoryId, createState, _description, EditProductPage, _EditProductPageState, _formKey, _imageUrl (+6 more)

### Community 39 - "Community 39"
Cohesion: 0.13
Nodes (14): billDetail, billHistory, copyWith, currentPage, dailySales, error, hasMorePages, lowStockProducts (+6 more)

### Community 40 - "Community 40"
Cohesion: 0.14
Nodes (14): _applyThreshold, build, createState, dispose, _formatCurrency, initState, LowStockPage, _LowStockPageState (+6 more)

### Community 41 - "Community 41"
Cohesion: 0.15
Nodes (10): Any, Bool, Flutter, FlutterAppDelegate, AppDelegate, RunnerTests, UIApplication, UIKit (+2 more)

### Community 42 - "Community 42"
Cohesion: 0.15
Nodes (13): core/theme/app_theme.dart, build, createState, dispose, initState, product, _qrDataController, QrGeneratorPage (+5 more)

### Community 43 - "Community 43"
Cohesion: 0.14
Nodes (13): ../../domain/repositories/product_repository.dart, addProduct, deleteProduct, _fromMap, getCurrentStockBulk, getProductByBarcode, getProducts, getProductsByCategory (+5 more)

### Community 44 - "Community 44"
Cohesion: 0.14
Nodes (13): EdgeInsetsGeometry, borderRadius, build, elevation, icon, isFullWidth, isLoading, label (+5 more)

### Community 45 - "Community 45"
Cohesion: 0.14
Nodes (13): ../../features/product/data/models/product_model.dart, ../../features/shop/data/models/shop_model.dart, HiveDatabase, init, productBox, productBoxName, settingsBox, settingsBoxName (+5 more)

### Community 46 - "Community 46"
Cohesion: 0.16
Nodes (13): HomePage, _DashboardView, _DashboardViewState, AddProductPage, ProductListPage, BillHistoryPage, _buildCard, createState (+5 more)

### Community 47 - "Community 47"
Cohesion: 0.14
Nodes (13): _barcode, build, _categoryId, createState, _description, _formKey, _imageUrl, _location (+5 more)

### Community 48 - "Community 48"
Cohesion: 0.19
Nodes (13): PrimaryButton Component, Design System (Material 3), Component Specs, DashboardActionCard + QuickActionTile, StatCard Widget, Flutter 3.x (Dart), Reports & History Feature, Checkout Screen (/scan/checkout) (+5 more)

### Community 49 - "Community 49"
Cohesion: 0.15
Nodes (12): DateTime, UserModel, copyWith, email, emailConfirmedAt, id, isEmailConfirmed, name (+4 more)

### Community 50 - "Community 50"
Cohesion: 0.18
Nodes (12): FormState, LoginRequested, createState, dispose, _emailController, _formKey, _isLoading, LoginPage (+4 more)

### Community 51 - "Community 51"
Cohesion: 0.15
Nodes (12): BillItemModel, BillSummaryModel, DailySalesModel, fromJson, fromSupabaseRow, StockMovementModel, toJson, BillItem (+4 more)

### Community 52 - "Community 52"
Cohesion: 0.18
Nodes (11): add_edit_category_dialog.dart, ../bloc/category_bloc.dart, build, CategoryListPage, _CategoryListPageState, _confirmDelete, createState, dispose (+3 more)

### Community 53 - "Community 53"
Cohesion: 0.17
Nodes (11): connecting,
  connected,
  connectionFailure,
  disconnected,, connectedMac, connectedName, copyWith, devices, errorMessage, PrinterState, PrinterStatus (+3 more)

### Community 54 - "Community 54"
Cohesion: 0.17
Nodes (11): ../../../../core/utils/app_validators.dart, AddEditCategoryDialog, build, category, createState, _descriptionController, dispose, _formKey (+3 more)

### Community 55 - "Community 55"
Cohesion: 0.17
Nodes (11): ../../../../core/utils/printer_helper.dart, PrinterHelper, clearPrinterData, connect, disconnect, getSavedPrinterMac, getSavedPrinterName, _printerHelper (+3 more)

### Community 56 - "Community 56"
Cohesion: 0.17
Nodes (11): call, email, emailRedirectTo, name, password, props, repository, role (+3 more)

### Community 57 - "Community 57"
Cohesion: 0.18
Nodes (11): build, controller, _corner, createState, dispose, _isScanned, ScannerPage, _ScannerPageState (+3 more)

### Community 58 - "Community 58"
Cohesion: 0.17
Nodes (11): PrinterRepositoryImpl, clearPrinterData, connect, disconnect, getSavedPrinterMac, getSavedPrinterName, PrinterRepository, savePrinterData (+3 more)

### Community 59 - "Community 59"
Cohesion: 0.18
Nodes (10): ../bloc/product_bloc.dart, ../../../category/presentation/bloc/category_bloc.dart, createState, dispose, _filterChip, _getCategoryName, _placeholderIcon, _scanQR (+2 more)

### Community 60 - "Community 60"
Cohesion: 0.18
Nodes (10): bool get, _channels, dispose, _isConnected, RealtimeService, subscribeToProducts, subscribeToTable, unsubscribe (+2 more)

### Community 61 - "Community 61"
Cohesion: 0.18
Nodes (10): AppTheme, backgroundColor, errorColor, primaryColor, secondaryColor, surfaceColor, textTheme, package:google_fonts/google_fonts.dart (+2 more)

### Community 62 - "Community 62"
Cohesion: 0.18
Nodes (10): currentRoute, _DrawerItem, icon, _initials, label, onTap, _ProfileHeader, route (+2 more)

### Community 63 - "Community 63"
Cohesion: 0.18
Nodes (10): build, color, DashboardActionCard, icon, label, onTap, QuickActionTile, subtitle (+2 more)

### Community 64 - "Community 64"
Cohesion: 0.18
Nodes (10): getBillDetail, getBillHistory, getDailySales, getLowStockProducts, getSalesRange, getStockMovements, _supabase, package:billing_app/core/supabase/supabase_client.dart (+2 more)

### Community 65 - "Community 65"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 66 - "Community 66"
Cohesion: 0.20
Nodes (9): core/supabase/supabase_client.dart, ../../domain/repositories/category_repository.dart, addCategory, deleteCategory, getCategories, _supabase, updateCategory, ../models/category_model.dart (+1 more)

### Community 67 - "Community 67"
Cohesion: 0.42
Nodes (10): AddCategory, CategoryEvent, DeleteCategory, LoadCategories, UpdateCategory, CategoryBloc, _AddEditCategoryDialogState, _onSave (+2 more)

### Community 68 - "Community 68"
Cohesion: 0.20
Nodes (9): authStateChanges, getCurrentUser, login, loginWithGoogle, logout, resendVerificationEmail, signUp, updateProfile (+1 more)

### Community 69 - "Community 69"
Cohesion: 0.20
Nodes (9): _buildBillCard, createState, _datePickerButton, _fromDate, initState, _selectDate, _toDate, package:billing_app/features/report/presentation/bloc/report_bloc.dart (+1 more)

### Community 70 - "Community 70"
Cohesion: 0.22
Nodes (8): ../../domain/entities/product.dart, addProduct, deleteProduct, getCurrentStockBulk, getProductByBarcode, getProducts, getProductsByCategory, updateProduct

### Community 71 - "Community 71"
Cohesion: 0.22
Nodes (8): double get, CartItem, copyWith, product, props, quantity, total, package:billing_app/features/product/domain/entities/product.dart

### Community 72 - "Community 72"
Cohesion: 0.22
Nodes (7): build, InputLabel, text, package:billing_app/main.dart, package:flutter/material.dart, package:flutter_test/flutter_test.dart, main

### Community 73 - "Community 73"
Cohesion: 0.22
Nodes (8): ReportRepositoryImpl, getBillDetail, getBillHistory, getDailySales, getLowStockProducts, getSalesRange, getStockMovements, ReportRepository

### Community 74 - "Community 74"
Cohesion: 0.22
Nodes (8): addressLine1, addressLine2, copyWith, footerText, name, phoneNumber, props, upiId

### Community 75 - "Community 75"
Cohesion: 0.22
Nodes (9): Rules — Dev Rules, Code Quality Rules, Database Rules, Git Rules, Graphify Rules, Naming Conventions, Parallel Work Rule, State Management Rules (+1 more)

### Community 76 - "Community 76"
Cohesion: 0.29
Nodes (8): @HiveType, ProductModelAdapter, ShopModelAdapter, ProductModel, Product, ShopModel, Shop, TypeAdapter

### Community 77 - "Community 77"
Cohesion: 0.46
Nodes (8): Bloc, LoadShopEvent, ShopEvent, UpdateShopEvent, ShopBloc, initState, _saveShop, _ShopDetailsPageState

### Community 78 - "Community 78"
Cohesion: 0.25
Nodes (7): Color, build, color, icon, label, StatCard, value

### Community 79 - "Community 79"
Cohesion: 0.36
Nodes (8): Dart-Only Fix Preference (avoid SQL migrations), Migration 004_shop_data_scoping.sql, Multi-Tenant Shop Data Isolation, RLS belongs_to_shop() scoping, shop_id column (UUID FK to shops), Stock Validation Before Bill, Supabase (PostgreSQL + Realtime), Supabase Migration Rule (always make migration file)

### Community 80 - "Community 80"
Cohesion: 0.29
Nodes (8): Design — Design System, Dashboard Screen, Layout Considerations, Scanner Screen, Screens & Routes, Theme (Material 3), Typography (IBM Plex Sans), Project Rules

### Community 81 - "Community 81"
Cohesion: 0.25
Nodes (7): ../../domain/entities/category.dart, CategoryModel, fromEntity, fromJson, toEntity, toJson, Category

### Community 82 - "Community 82"
Cohesion: 0.25
Nodes (7): _anonKey, client, initialize, SupabaseConfig, _url, package:supabase_flutter/supabase_flutter.dart, static SupabaseClient get

### Community 83 - "Community 83"
Cohesion: 0.25
Nodes (7): call, email, LoginParams, LoginUseCase, password, props, repository

### Community 84 - "Community 84"
Cohesion: 0.25
Nodes (7): copyWith, createdAt, description, id, name, props, package:equatable/equatable.dart

### Community 85 - "Community 85"
Cohesion: 0.25
Nodes (7): bill, BillDetailPage, build, _buildInfoCard, _infoRow, package:billing_app/core/widgets/primary_button.dart, package:intl/intl.dart

### Community 86 - "Community 86"
Cohesion: 0.29
Nodes (6): ../../core/widgets/app_drawer.dart, AppShell, build, child, package:go_router/go_router.dart, Widget

### Community 87 - "Community 87"
Cohesion: 0.29
Nodes (6): _, DeepLinkConfig, emailRedirectTo, host, scheme, static const String

### Community 88 - "Community 88"
Cohesion: 0.38
Nodes (6): CacheFailure, Failure, message, props, ServerFailure, List

### Community 89 - "Community 89"
Cohesion: 0.29
Nodes (7): build, build, build, build, Route /, Route /register, Route /verify-email

### Community 90 - "Community 90"
Cohesion: 0.33
Nodes (5): fromJson, fromProfileJson, fromSupabaseAuth, toJson, package:billing_app/features/auth/domain/entities/user.dart

### Community 91 - "Community 91"
Cohesion: 0.50
Nodes (5): Analysis Options Config, Web Favicon, Web Icon (192), Web Icon (512), Flutter Web Entry HTML

### Community 92 - "Community 92"
Cohesion: 0.40
Nodes (4): ../error/failure.dart, call, NoParams, package:fpdart/fpdart.dart

### Community 93 - "Community 93"
Cohesion: 0.40
Nodes (4): IconData?, AppBackButton, icon, size

### Community 94 - "Community 94"
Cohesion: 0.50
Nodes (4): Auth Feature (Supabase + Google OAuth), Email Verification Gate (Dart-only), shop_id Dart threading (repositories/blocs), Supabase Auth

### Community 96 - "Community 96"
Cohesion: 0.67
Nodes (3): iOS Launch Image (@1x), iOS Launch Image (@2x), iOS Launch Image (@3x)

## Knowledge Gaps
- **797 isolated node(s):** `supabase`, `XCTest`, `rootNavigatorKey`, `child`, `build` (+792 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **20 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `AuthBloc` connect `Community 35` to `Community 0`, `Community 1`, `Community 2`, `Community 4`, `Community 36`, `Community 9`, `Community 11`, `Community 77`, `Community 13`, `Community 50`, `Community 21`, `Community 22`, `Community 23`, `Community 26`, `Community 62`?**
  _High betweenness centrality (0.060) - this node is a cross-community bridge._
- **Why does `Product` connect `Community 76` to `Community 1`, `Community 2`, `Community 37`, `Community 6`, `Community 71`, `Community 38`, `Community 42`?**
  _High betweenness centrality (0.027) - this node is a cross-community bridge._
- **Why does `AuthRepository` connect `Community 27` to `Community 68`, `Community 5`, `Community 9`, `Community 83`, `Community 23`, `Community 56`?**
  _High betweenness centrality (0.021) - this node is a cross-community bridge._
- **What connects `supabase`, `XCTest`, `rootNavigatorKey` to the rest of the system?**
  _797 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 0` be split into smaller, more focused modules?**
  _Cohesion score 0.05723905723905724 - nodes in this community are weakly interconnected._
- **Should `Community 1` be split into smaller, more focused modules?**
  _Cohesion score 0.044444444444444446 - nodes in this community are weakly interconnected._
- **Should `Community 2` be split into smaller, more focused modules?**
  _Cohesion score 0.05405405405405406 - nodes in this community are weakly interconnected._