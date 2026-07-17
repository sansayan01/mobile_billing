# Graph Report - .  (2026-07-17)

## Corpus Check
- 22 files · ~46,547 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1526 nodes · 2399 edges · 112 communities (95 shown, 17 thin omitted)
- Extraction: 96% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 25 edges (avg confidence: 0.92)
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
- Community 100
- Community 101
- Community 102
- Community 103
- Community 105
- Community 106
- Community 107
- Community 108
- Community 109
- Community 110
- Community 111

## God Nodes (most connected - your core abstractions)
1. `AuthBloc` - 56 edges
2. `BillingBloc` - 28 edges
3. `ReportBloc` - 26 edges
4. `UseCase` - 24 edges
5. `ProductBloc` - 24 edges
6. `CategoryBloc` - 23 edges
7. `Flutter Billing App` - 23 edges
8. `ShopBloc` - 18 edges
9. `PrinterBloc` - 16 edges
10. `BillingEvent` - 15 edges

## Surprising Connections (you probably didn't know these)
- `Android Launcher Icon (hdpi)` --semantically_similar_to--> `iOS App Icon (1024x1024)`  [INFERRED] [semantically similar]
  android/app/src/main/res/mipmap-hdpi/ic_launcher.png → ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png
- `File Structure (README)` --semantically_similar_to--> `Project Structure`  [INFERRED] [semantically similar]
  README.md → architecture.md
- `Email Verification Gate (Dart-only)` ----> `Dart-Only Fix Preference (avoid SQL migrations)`  [0.88]
  memory.md → CLAUDE.md
- `Core Features (README)` --conceptually_related_to--> `Product Inventory Feature`  [INFERRED]
  README.md → RPD.md
- `Analysis Options Config` --conceptually_related_to--> `Flutter Web Entry HTML`  [INFERRED]
  analysis_options.yaml → web/index.html

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Next Phase Tasks (1-4 + execution + rollback)** — implementation_plan_task1, implementation_plan_task2, implementation_plan_task3, implementation_plan_task4, implementation_plan_execution_model, implementation_plan_rollback [EXTRACTED 1.00]
- **RPD Core Features** — rpd_categories, rpd_productinventory, rpd_billing, rpd_realtime, rpd_shelflocation, rpd_qrgenerator, rpd_reports [EXTRACTED 1.00]
- **Clean Architecture Layers** — architecture_presentation, architecture_domain, architecture_data [EXTRACTED 1.00]
- **Android Launcher Icon Set** — android_app_src_main_res_mipmap_hdpi_ic_launcher [INFERRED 0.95]
- **App Branding Assets (all platforms)** — android_app_src_main_res_mipmap_hdpi_ic_launcher, ios_runner_assets_xcassets_appicon_appiconset_icon_app_1024x1024_1x, web_favicon, web_icons_icon_192 [INFERRED 0.85]
- **iOS App Icon Set** — ios_runner_assets_xcassets_appicon_appiconset_icon_app_1024x1024_1x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_20x20_1x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_20x20_2x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_20x20_3x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_29x29_1x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_29x29_2x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_29x29_3x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_40x40_1x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_40x40_2x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_40x40_3x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_60x60_2x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_60x60_3x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_76x76_1x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_76x76_2x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_83_5x83_5_2x [INFERRED 0.95]
- **iOS Launch Image Set** — ios_runner_assets_xcassets_launchimage_imageset_launchimage, ios_runner_assets_xcassets_launchimage_imageset_launchimage_2x, ios_runner_assets_xcassets_launchimage_imageset_launchimage_3x [INFERRED 0.95]
- **Web Icon Set** — web_favicon, web_icons_icon_192, web_icons_icon_512, web_icons_icon_maskable_192, web_icons_icon_maskable_512 [INFERRED 0.95]

## Communities (112 total, 17 thin omitted)

### Community 0 - "Community 0"
Cohesion: 0.05
Nodes (56): Bloc, ../bloc/shop_bloc.dart, core/data/hive_database.dart, ../../../../core/error/failure.dart, ../../../../core/usecase/usecase.dart, LoadShopEvent, message, ShopError (+48 more)

### Community 1 - "Community 1"
Cohesion: 0.05
Nodes (56): Auth Feature (Supabase + Google OAuth), Auto-Pilot Mode (no questions, just execute), Category Feature (CRUD), Clean Architecture (Presentation/Domain/Data), PrimaryButton Component, Dart-Only Fix Preference (avoid SQL migrations), Design — Design System, Design System (Material 3) (+48 more)

### Community 2 - "Community 2"
Cohesion: 0.04
Nodes (44): ../../../../core/utils/printer_helper.dart, alignCenter, alignLeft, alignRight, boldOff, boldOn, checkPermission, connect (+36 more)

### Community 3 - "Community 3"
Cohesion: 0.04
Nodes (44): address1, address2, barcode, cartItems, copyWith, discountIsPercentage, error, footer (+36 more)

### Community 4 - "Community 4"
Cohesion: 0.06
Nodes (34): Color, EdgeInsetsGeometry, IconData, AppBackButton, icon, size, build, color (+26 more)

### Community 5 - "Community 5"
Cohesion: 0.09
Nodes (34): ../bloc/printer_bloc.dart, ../bloc/printer_event.dart, ../bloc/printer_state.dart, ../../domain/repositories/printer_repository.dart, _onConnect, _onDisconnect, _onInit, _onRefresh (+26 more)

### Community 6 - "Community 6"
Cohesion: 0.06
Nodes (35): Architecture — Clean Architecture + BLoC + Supabase, Data Layer, Dependency Injection (get_it), Domain Layer, Hive (Local Cache/Offline), Navigation (go_router), Offline Strategy, Presentation Layer (+27 more)

### Community 7 - "Community 7"
Cohesion: 0.06
Nodes (34): CategoryRepository, ../../features/auth/data/repositories/auth_repository_impl.dart, ../../features/auth/domain/usecases/get_current_user_usecase.dart, ../../features/auth/domain/usecases/login_usecase.dart, ../../features/auth/domain/usecases/login_with_google_usecase.dart, ../../features/auth/domain/usecases/logout_usecase.dart, ../../features/auth/domain/usecases/signup_usecase.dart, ../../features/category/data/repositories/category_repository_impl.dart (+26 more)

### Community 8 - "Community 8"
Cohesion: 0.06
Nodes (34): ../../../../core/realtime/realtime_service.dart, categoryId, changeType, copyWith, filteredProducts, id, message, payload (+26 more)

### Community 9 - "Community 9"
Cohesion: 0.07
Nodes (29): app_shell.dart, ../../features/auth/presentation/pages/email_verification_page.dart, ../../features/auth/presentation/pages/login_page.dart, ../../features/auth/presentation/pages/register_page.dart, ../../features/billing/presentation/pages/checkout_page.dart, ../../features/billing/presentation/pages/home_page.dart, ../../features/billing/presentation/pages/scanner_page.dart, ../../features/category/presentation/pages/category_list_page.dart (+21 more)

### Community 10 - "Community 10"
Cohesion: 0.11
Nodes (28): Authenticated, AuthError, AuthLoading, AuthState, EmailVerificationPending, AuthBloc, AuthEvent, CheckAuthStatus (+20 more)

### Community 11 - "Community 11"
Cohesion: 0.08
Nodes (28): class, BillingState, CategoryState, ProductState, Equatable, BillDetailParams, BillHistoryParams, billId (+20 more)

### Community 12 - "Community 12"
Cohesion: 0.07
Nodes (26): GetCurrentUserUseCase, authRepository, _authSubscription, close, getCurrentUserUseCase, loginUseCase, loginWithGoogleUseCase, logoutUseCase (+18 more)

### Community 13 - "Community 13"
Cohesion: 0.14
Nodes (26): ReportBloc, billId, changeType, date, from, LoadBillDetail, LoadBillHistory, LoadDailySales (+18 more)

### Community 14 - "Community 14"
Cohesion: 0.12
Nodes (23): _DrawerItem, _SectionHeader, InputLabel, createState, DashboardPage, _DashboardView, _DashboardViewState, _formatCurrency (+15 more)

### Community 15 - "Community 15"
Cohesion: 0.08
Nodes (23): averageBill, billCount, changeType, copyWith, createdAt, date, discount, grandTotal (+15 more)

### Community 16 - "Community 16"
Cohesion: 0.09
Nodes (21): hashCode, operator, read, typeId, write, barcode, categoryId, createdAt (+13 more)

### Community 17 - "Community 17"
Cohesion: 0.19
Nodes (21): AddProductToCartEvent, BillingEvent, ClearCartEvent, ClearStockErrorsEvent, PrintReceiptEvent, RemoveProductFromCartEvent, ScanBarcodeEvent, SetDiscountTypeEvent (+13 more)

### Community 18 - "Community 18"
Cohesion: 0.10
Nodes (20): categories, CategoryStatus, copyWith, description, id, message, name, status (+12 more)

### Community 19 - "Community 19"
Cohesion: 0.14
Nodes (19): ../entities/product.dart, UseCase, AddCategoryUseCase, call, DeleteCategoryUseCase, GetCategoriesUseCase, repository, UpdateCategoryUseCase (+11 more)

### Community 20 - "Community 20"
Cohesion: 0.10
Nodes (20): GetBillDetailUseCase, GetLowStockProductsUseCase, GetSalesRangeUseCase, authBloc, getBillDetailUseCase, getBillHistoryUseCase, getDailySalesUseCase, getLowStockProductsUseCase (+12 more)

### Community 21 - "Community 21"
Cohesion: 0.11
Nodes (18): ../../../auth/presentation/bloc/auth_bloc.dart, ../../../auth/presentation/bloc/auth_event.dart, ../../../auth/presentation/bloc/auth_state.dart, ../../../../core/widgets/app_back_button.dart, ../../../../core/widgets/input_label.dart, AddStaffPage, _AddStaffPageState, build (+10 more)

### Community 22 - "Community 22"
Cohesion: 0.11
Nodes (17): ../../../billing/presentation/bloc/billing_bloc.dart, ../../../../core/widgets/primary_button.dart, ../../domain/entities/cart_item.dart, build, _buildBottomPanel, _buildCameraOffState, _buildCorner, _buildEmptyCart (+9 more)

### Community 23 - "Community 23"
Cohesion: 0.12
Nodes (18): Implementation Plan (Next Phase), handle_new_user() trigger (default staff, signup promotes owner), Plugins affected by KGP (app_settings, device_info_plus, mobile_scanner, print_bluetooth_thermal, share_plus), Kotlin Gradle Plugin warning (build stability), RLS fix (owner profile seeded), shops table (id, owner_id, name, created_at) + RLS, signup_usecase (create shop + owner role), Hardcoded Supabase project (wwutchscfnhwijxyftlw) (+10 more)

### Community 24 - "Community 24"
Cohesion: 0.13
Nodes (16): authenticatedChild, _SplashScreen, createState, email, EmailVerificationPage, _EmailVerificationPageState, _isChecking, _isResending (+8 more)

### Community 25 - "Community 25"
Cohesion: 0.22
Nodes (17): AddProduct, DeleteProduct, FilterByCategory, GenerateQrCode, InitRealtime, LoadProducts, ProductEvent, ProductsRealtimeUpdated (+9 more)

### Community 26 - "Community 26"
Cohesion: 0.15
Nodes (14): AuthRepositoryImpl, AuthRepository, call, GetCurrentUserUseCase, repository, call, LoginWithGoogleUseCase, repository (+6 more)

### Community 27 - "Community 27"
Cohesion: 0.12
Nodes (16): Android Launcher Icon (hdpi), iOS App Icon (1024x1024), iOS App Icon (20x20 @1x), iOS App Icon (20x20 @2x), iOS App Icon (20x20 @3x), iOS App Icon (29x29 @1x), iOS App Icon (29x29 @2x), iOS App Icon (29x29 @3x) (+8 more)

### Community 28 - "Community 28"
Cohesion: 0.12
Nodes (15): config/routes/app_routes.dart, core/service_locator.dart, features/auth/domain/repositories/auth_repository.dart, features/auth/presentation/bloc/auth_event.dart, features/billing/presentation/bloc/billing_bloc.dart, features/category/presentation/bloc/category_bloc.dart, features/product/presentation/bloc/product_bloc.dart, features/report/presentation/bloc/report_bloc.dart (+7 more)

### Community 29 - "Community 29"
Cohesion: 0.12
Nodes (15): hashCode, operator, read, typeId, write, int get, addressLine1, addressLine2 (+7 more)

### Community 30 - "Community 30"
Cohesion: 0.12
Nodes (15): copyWith, id, message, staff, StaffState, StaffStatus, status, authBloc (+7 more)

### Community 31 - "Community 31"
Cohesion: 0.12
Nodes (15): BillSummaryModel, BillSummary, billDetail, billHistory, copyWith, currentPage, dailySales, error (+7 more)

### Community 32 - "Community 32"
Cohesion: 0.12
Nodes (15): build, _buildBarChart, _buildDateNavigation, _buildStatCard, _buildStatCards, createState, _dayAbbr, _formatCurrency (+7 more)

### Community 33 - "Community 33"
Cohesion: 0.13
Nodes (15): build, _buildMovementCard, _changeTypes, _chipColor, createState, _filterApplied, _formatDate, _fromDate (+7 more)

### Community 34 - "Community 34"
Cohesion: 0.13
Nodes (14): ../bloc/product_bloc.dart, ../../../category/presentation/bloc/category_bloc.dart, build, _categoryId, createState, _description, _formKey, _imageUrl (+6 more)

### Community 35 - "Community 35"
Cohesion: 0.16
Nodes (14): AddCategory, UpdateCategory, AddEditCategoryDialog, _AddEditCategoryDialogState, build, category, createState, _descriptionController (+6 more)

### Community 36 - "Community 36"
Cohesion: 0.13
Nodes (14): dart:async, _createProfile, _createShop, _extractErrorMessage, _fetchProfile, getCurrentUser, login, loginWithGoogle (+6 more)

### Community 37 - "Community 37"
Cohesion: 0.13
Nodes (14): barcode, categoryId, copyWith, createdAt, description, id, imageUrl, location (+6 more)

### Community 38 - "Community 38"
Cohesion: 0.15
Nodes (10): Any, Bool, Flutter, FlutterAppDelegate, AppDelegate, RunnerTests, UIApplication, UIKit (+2 more)

### Community 39 - "Community 39"
Cohesion: 0.15
Nodes (13): core/theme/app_theme.dart, build, createState, dispose, initState, product, _qrDataController, QrGeneratorPage (+5 more)

### Community 40 - "Community 40"
Cohesion: 0.14
Nodes (13): ../../features/product/data/models/product_model.dart, ../../features/shop/data/models/shop_model.dart, HiveDatabase, init, productBox, productBoxName, settingsBox, settingsBoxName (+5 more)

### Community 41 - "Community 41"
Cohesion: 0.16
Nodes (12): SignUpUseCase, StaffRepositoryImpl, deleteStaffMember, getStaffMembers, StaffRepository, call, DeleteStaffMemberUseCase, GetStaffMembersUseCase (+4 more)

### Community 42 - "Community 42"
Cohesion: 0.23
Nodes (13): Authenticated, AuthError, AuthInitial, AuthLoading, AuthState, email, EmailVerificationPending, message (+5 more)

### Community 43 - "Community 43"
Cohesion: 0.14
Nodes (13): _barcode, build, _categoryId, createState, _description, _formKey, _imageUrl, _location (+5 more)

### Community 44 - "Community 44"
Cohesion: 0.15
Nodes (13): _applyThreshold, build, createState, dispose, _formatCurrency, initState, LowStockPage, _LowStockPageState (+5 more)

### Community 45 - "Community 45"
Cohesion: 0.15
Nodes (12): ../bloc/staff_bloc.dart, ../../../../features/auth/domain/entities/user.dart, features/auth/presentation/bloc/auth_bloc.dart, ../../features/auth/presentation/bloc/auth_state.dart, build, createState, dispose, _initials (+4 more)

### Community 46 - "Community 46"
Cohesion: 0.15
Nodes (11): ../error/failure.dart, call, NoParams, CategoryRepositoryImpl, addCategory, CategoryRepository, deleteCategory, getCategories (+3 more)

### Community 47 - "Community 47"
Cohesion: 0.18
Nodes (12): FormState, LoginRequested, createState, dispose, _emailController, _formKey, _isLoading, LoginPage (+4 more)

### Community 48 - "Community 48"
Cohesion: 0.15
Nodes (12): AppDrawer, currentRoute, icon, _initials, label, onTap, _ProfileHeader, route (+4 more)

### Community 49 - "Community 49"
Cohesion: 0.17
Nodes (12): _confirmPasswordController, createState, dispose, _emailController, _formKey, _isLoading, _nameController, _obscureConfirmPassword (+4 more)

### Community 50 - "Community 50"
Cohesion: 0.17
Nodes (11): ../bloc/billing_bloc.dart, _buildDataCell, _buildHeaderCell, createState, dispose, _isEditingTotal, _showStockErrorsDialog, _stockErrorsHandled (+3 more)

### Community 51 - "Community 51"
Cohesion: 0.17
Nodes (11): connecting,
  connected,
  connectionFailure,
  disconnected,, connectedMac, connectedName, copyWith, devices, errorMessage, PrinterState, PrinterStatus (+3 more)

### Community 52 - "Community 52"
Cohesion: 0.17
Nodes (11): ../../domain/repositories/product_repository.dart, addProduct, deleteProduct, _fromMap, getCurrentStockBulk, getProductByBarcode, getProducts, getProductsByCategory (+3 more)

### Community 53 - "Community 53"
Cohesion: 0.17
Nodes (11): call, email, emailRedirectTo, name, password, props, repository, role (+3 more)

### Community 54 - "Community 54"
Cohesion: 0.18
Nodes (10): add_edit_category_dialog.dart, ../bloc/category_bloc.dart, build, CategoryListPage, _confirmDelete, createState, dispose, _openAddEditDialog (+2 more)

### Community 55 - "Community 55"
Cohesion: 0.18
Nodes (10): bool get, _channels, dispose, _isConnected, RealtimeService, subscribeToProducts, subscribeToTable, unsubscribe (+2 more)

### Community 56 - "Community 56"
Cohesion: 0.18
Nodes (10): ../../../../core/utils/app_validators.dart, createState, dispose, _filterChip, _getCategoryName, _placeholderIcon, ProductListPage, _scanQR (+2 more)

### Community 57 - "Community 57"
Cohesion: 0.18
Nodes (10): ../../domain/entities/product.dart, ProductRepositoryImpl, addProduct, deleteProduct, getCurrentStockBulk, getProductByBarcode, getProducts, getProductsByCategory (+2 more)

### Community 58 - "Community 58"
Cohesion: 0.18
Nodes (10): AppTheme, backgroundColor, errorColor, primaryColor, secondaryColor, surfaceColor, textTheme, package:google_fonts/google_fonts.dart (+2 more)

### Community 59 - "Community 59"
Cohesion: 0.33
Nodes (11): build, _buildScannerSection, _buildQuickTiles, build, Route /categories, Route /products, Route /reports, Route /scan/scanner (+3 more)

### Community 60 - "Community 60"
Cohesion: 0.18
Nodes (10): copyWith, email, emailConfirmedAt, id, isEmailConfirmed, name, phone, props (+2 more)

### Community 61 - "Community 61"
Cohesion: 0.18
Nodes (10): build, controller, _corner, createState, dispose, _isScanned, MobileScannerController, package:flutter_bloc/flutter_bloc.dart (+2 more)

### Community 62 - "Community 62"
Cohesion: 0.18
Nodes (10): BillItemModel, DailySalesModel, fromJson, fromSupabaseRow, StockMovementModel, toJson, BillItem, DailySales (+2 more)

### Community 63 - "Community 63"
Cohesion: 0.18
Nodes (10): getBillDetail, getBillHistory, getDailySales, getLowStockProducts, getSalesRange, getStockMovements, _supabase, package:billing_app/core/supabase/supabase_client.dart (+2 more)

### Community 64 - "Community 64"
Cohesion: 0.18
Nodes (10): _buildBillCard, createState, _datePickerButton, _fromDate, initState, _selectDate, _toDate, package:billing_app/features/report/presentation/bloc/report_bloc.dart (+2 more)

### Community 65 - "Community 65"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 66 - "Community 66"
Cohesion: 0.20
Nodes (9): authStateChanges, getCurrentUser, login, loginWithGoogle, logout, resendVerificationEmail, signUp, updateProfile (+1 more)

### Community 67 - "Community 67"
Cohesion: 0.20
Nodes (9): addressLine1, addressLine2, copyWith, footerText, name, phoneNumber, props, upiId (+1 more)

### Community 68 - "Community 68"
Cohesion: 0.42
Nodes (9): CategoryEvent, DeleteCategory, LoadCategories, CategoryBloc, _CategoryListPageState, initState, initState, _ProductListPageState (+1 more)

### Community 69 - "Community 69"
Cohesion: 0.22
Nodes (8): DateTime, copyWith, createdAt, description, id, name, props, String?

### Community 70 - "Community 70"
Cohesion: 0.22
Nodes (8): ../../domain/repositories/category_repository.dart, addCategory, deleteCategory, getCategories, _supabase, updateCategory, ../models/category_model.dart, SupabaseClient get

### Community 71 - "Community 71"
Cohesion: 0.22
Nodes (8): double get, CartItem, copyWith, product, props, quantity, total, package:billing_app/features/product/domain/entities/product.dart

### Community 72 - "Community 72"
Cohesion: 0.22
Nodes (8): ReportRepositoryImpl, getBillDetail, getBillHistory, getDailySales, getLowStockProducts, getSalesRange, getStockMovements, ReportRepository

### Community 73 - "Community 73"
Cohesion: 0.29
Nodes (8): @HiveType, ProductModelAdapter, ShopModelAdapter, ProductModel, Product, ShopModel, Shop, TypeAdapter

### Community 74 - "Community 74"
Cohesion: 0.25
Nodes (7): ../../../auth/data/models/user_model.dart, ../../../auth/domain/entities/user.dart, core/supabase/supabase_client.dart, ../../domain/repositories/staff_repository.dart, deleteStaffMember, getStaffMembers, _supabase

### Community 75 - "Community 75"
Cohesion: 0.25
Nodes (7): ../../domain/entities/category.dart, CategoryModel, fromEntity, fromJson, toEntity, toJson, Category

### Community 76 - "Community 76"
Cohesion: 0.25
Nodes (7): _anonKey, client, initialize, SupabaseConfig, _url, package:supabase_flutter/supabase_flutter.dart, static SupabaseClient get

### Community 77 - "Community 77"
Cohesion: 0.25
Nodes (6): build, text, package:billing_app/main.dart, package:flutter/material.dart, package:flutter_test/flutter_test.dart, main

### Community 78 - "Community 78"
Cohesion: 0.25
Nodes (7): call, email, LoginParams, LoginUseCase, password, props, repository

### Community 79 - "Community 79"
Cohesion: 0.25
Nodes (7): bill, BillDetailPage, build, _buildInfoCard, _infoRow, package:billing_app/core/widgets/primary_button.dart, package:intl/intl.dart

### Community 80 - "Community 80"
Cohesion: 0.29
Nodes (6): _, DeepLinkConfig, emailRedirectTo, host, scheme, static const String

### Community 81 - "Community 81"
Cohesion: 0.57
Nodes (7): DeleteStaffMember, LoadStaff, StaffEvent, StaffBloc, _confirmDelete, initState, _StaffListPageState

### Community 82 - "Community 82"
Cohesion: 0.38
Nodes (6): CacheFailure, Failure, message, props, ServerFailure, package:equatable/equatable.dart

### Community 83 - "Community 83"
Cohesion: 0.29
Nodes (7): build, build, build, build, Route /, Route /register, Route /verify-email

### Community 84 - "Community 84"
Cohesion: 0.29
Nodes (6): fromJson, fromProfileJson, fromSupabaseAuth, toJson, UserModel, User

### Community 85 - "Community 85"
Cohesion: 0.29
Nodes (7): CheckoutPage, HomePage, ScannerPage, AddProductPage, EditProductPage, BillHistoryPage, StatefulWidget

### Community 86 - "Community 86"
Cohesion: 0.29
Nodes (7): build, build, Route /reports/bills, Route /reports/daily-sales, Route /reports/low-stock, Route /reports/stock-movements, Route /scan

### Community 87 - "Community 87"
Cohesion: 0.33
Nodes (5): ../../core/widgets/app_drawer.dart, AppShell, build, child, package:go_router/go_router.dart

### Community 88 - "Community 88"
Cohesion: 0.40
Nodes (5): _buildCard, createState, ReportsHomePage, _ReportsHomePageState, package:billing_app/core/theme/app_theme.dart

### Community 89 - "Community 89"
Cohesion: 0.50
Nodes (5): Analysis Options Config, Web Favicon, Web Icon (192), Web Icon (512), Flutter Web Entry HTML

### Community 91 - "Community 91"
Cohesion: 0.67
Nodes (3): iOS Launch Image (@1x), iOS Launch Image (@2x), iOS Launch Image (@3x)

## Knowledge Gaps
- **827 isolated node(s):** `supabase`, `XCTest`, `child`, `build`, `DeepLinkConfig` (+822 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **17 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `AuthBloc` connect `Community 10` to `Community 0`, `Community 3`, `Community 8`, `Community 9`, `Community 12`, `Community 45`, `Community 14`, `Community 47`, `Community 48`, `Community 49`, `Community 18`, `Community 81`, `Community 20`, `Community 21`, `Community 24`, `Community 59`, `Community 28`, `Community 30`?**
  _High betweenness centrality (0.120) - this node is a cross-community bridge._
- **Why does `AuthRepository` connect `Community 26` to `Community 66`, `Community 7`, `Community 12`, `Community 78`, `Community 53`, `Community 28`?**
  _High betweenness centrality (0.023) - this node is a cross-community bridge._
- **Why does `Product` connect `Community 73` to `Community 34`, `Community 3`, `Community 37`, `Community 71`, `Community 8`, `Community 39`, `Community 11`?**
  _High betweenness centrality (0.019) - this node is a cross-community bridge._
- **What connects `supabase`, `XCTest`, `child` to the rest of the system?**
  _827 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 0` be split into smaller, more focused modules?**
  _Cohesion score 0.05027322404371585 - nodes in this community are weakly interconnected._
- **Should `Community 1` be split into smaller, more focused modules?**
  _Cohesion score 0.052597402597402594 - nodes in this community are weakly interconnected._
- **Should `Community 2` be split into smaller, more focused modules?**
  _Cohesion score 0.04440333024976873 - nodes in this community are weakly interconnected._