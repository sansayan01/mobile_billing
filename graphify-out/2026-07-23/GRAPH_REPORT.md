# Graph Report - D:/Projects/flutter_billing_app-main  (2026-07-23)

## Corpus Check
- 68 files · ~1,419,463 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1878 nodes · 2835 edges · 152 communities (118 shown, 34 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 34 edges (avg confidence: 0.88)
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
- Community 102
- Community 103
- Community 104
- Community 105
- Community 106
- Community 107
- Community 108
- Community 109
- Community 110
- Community 111
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
- Community 126
- Community 127
- Community 128
- Community 129
- Community 130
- Community 131
- Community 132
- Community 133
- Community 134
- Community 136
- Community 137
- Community 138
- Community 139
- Community 140
- Community 141
- Community 142
- Community 143
- Community 144
- Community 145
- Community 146
- Community 147
- Community 148
- Community 149
- Community 150
- Community 151

## God Nodes (most connected - your core abstractions)
1. `AuthBloc` - 60 edges
2. `ReportBloc` - 40 edges
3. `ProductBloc` - 31 edges
4. `BillingBloc` - 30 edges
5. `UseCase` - 21 edges
6. `BillingEvent` - 18 edges
7. `CLAUDE.md — Flutter Billing App` - 15 edges
8. `iOS App Icon (1024x1024)` - 15 edges
9. `ReportEvent` - 12 edges
10. `build` - 11 edges

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

## Communities (152 total, 34 thin omitted)

### Community 0 - "Community 0"
Cohesion: 0.04
Nodes (54): address1, address2, barcode, cartItems, copyWith, customPrice, discountIsPercentage, error (+46 more)

### Community 1 - "Community 1"
Cohesion: 0.05
Nodes (47): ../bloc/category_bloc.dart, ../../../../core/utils/app_validators.dart, AddCategory, categories, CategoryEvent, CategoryState, CategoryStatus, copyWith (+39 more)

### Community 2 - "Community 2"
Cohesion: 0.07
Nodes (36): Bloc, ../bloc/staff_bloc.dart, copyWith, DeleteStaffMember, id, LoadStaff, message, staff (+28 more)

### Community 3 - "Community 3"
Cohesion: 0.05
Nodes (36): AddProductUseCase, ../../../../core/realtime/realtime_service.dart, categoryId, changeType, copyWith, filteredProducts, id, message (+28 more)

### Community 4 - "Community 4"
Cohesion: 0.07
Nodes (35): _DrawerItem, _ProfileHeader, InputLabel, appBarTheme, buildActions, _buildDescriptionSnippet, buildLeading, _buildLoadingPlaceholder (+27 more)

### Community 5 - "Community 5"
Cohesion: 0.06
Nodes (32): app_shell.dart, ../../features/auth/presentation/pages/email_verification_page.dart, ../../features/auth/presentation/pages/login_page.dart, ../../features/auth/presentation/pages/register_page.dart, ../../features/billing/domain/entities/cart_item.dart, ../../features/billing/presentation/pages/checkout_page.dart, ../../features/billing/presentation/pages/home_page.dart, ../../features/billing/presentation/pages/receipt_preview_page.dart (+24 more)

### Community 6 - "Community 6"
Cohesion: 0.06
Nodes (32): CategoryRepository, ../../features/auth/data/repositories/auth_repository_impl.dart, ../../features/auth/domain/usecases/get_current_user_usecase.dart, ../../features/auth/domain/usecases/login_usecase.dart, ../../features/auth/domain/usecases/login_with_google_usecase.dart, ../../features/auth/domain/usecases/logout_usecase.dart, ../../features/auth/domain/usecases/signup_usecase.dart, ../../features/category/data/repositories/category_repository_impl.dart (+24 more)

### Community 7 - "Community 7"
Cohesion: 0.08
Nodes (30): DeleteBillUseCase, GetBillDetailUseCase, GetBillHistoryUseCase, GetDailySalesUseCase, GetLowStockProductsUseCase, GetSalesRangeUseCase, GetStockMovementsUseCase, UpdateBillUseCase (+22 more)

### Community 8 - "Community 8"
Cohesion: 0.09
Nodes (28): BillingState, Equatable, BillDetailParams, BillHistoryParams, billId, call, changeType, DailySalesParams (+20 more)

### Community 9 - "Community 9"
Cohesion: 0.07
Nodes (28): GetCurrentUserUseCase, authRepository, _authSubscription, close, getCurrentUserUseCase, _isLoggingOut, loginUseCase, loginWithGoogleUseCase (+20 more)

### Community 10 - "Community 10"
Cohesion: 0.08
Nodes (25): ../../../billing/presentation/bloc/billing_bloc.dart, ../../features/product/domain/entities/product.dart, ../../features/product/domain/repositories/product_repository.dart, ../../features/product/domain/usecases/product_usecases.dart, build, _buildBottomPanel, _buildCameraOffState, _buildCorner (+17 more)

### Community 11 - "Community 11"
Cohesion: 0.08
Nodes (25): dart:io, GlobalKey, address1, address2, cartItems, createState, customerName, customerPhone (+17 more)

### Community 12 - "Community 12"
Cohesion: 0.08
Nodes (25): averageBill, billCount, changeType, copyWith, createdAt, customerName, customerPhone, date (+17 more)

### Community 13 - "Community 13"
Cohesion: 0.18
Nodes (23): initState, ReportBloc, DeleteBill, LoadBillDetail, LoadBillHistory, LoadDailySales, LoadLowStockProducts, LoadSalesRange (+15 more)

### Community 14 - "Community 14"
Cohesion: 0.13
Nodes (21): add_edit_category_dialog.dart, CategoryBloc, FilterByCategory, build, CategoryListPage, _CategoryListPageState, _confirmDelete, createState (+13 more)

### Community 15 - "Community 15"
Cohesion: 0.09
Nodes (21): hashCode, operator, read, typeId, write, barcode, categoryId, createdAt (+13 more)

### Community 16 - "Community 16"
Cohesion: 0.09
Nodes (21): alignCenter, alignLeft, alignRight, boldOff, boldOn, checkPermission, connect, disconnect (+13 more)

### Community 17 - "Community 17"
Cohesion: 0.09
Nodes (21): 1. `lib/features/report/domain/entities/report_entities.dart`, 2. `lib/features/report/domain/usecases/report_usecases.dart`, 3. `lib/features/report/domain/repositories/report_repository.dart`, 4. `lib/features/report/data/repositories/report_repository_impl.dart`, 5. `lib/features/report/presentation/bloc/report_event.dart`, 6. `lib/features/report/presentation/bloc/report_bloc.dart`, 7. `lib/features/report/presentation/pages/bill_detail_page.dart`, Current State (+13 more)

### Community 18 - "Community 18"
Cohesion: 0.10
Nodes (21): Architecture — Clean Architecture + BLoC + Supabase, Data Layer, Dependency Injection (get_it), Domain Layer, Hive (Local Cache/Offline), Navigation (go_router), Offline Strategy, Presentation Layer (+13 more)

### Community 19 - "Community 19"
Cohesion: 0.11
Nodes (21): Authenticated, AuthError, AuthEvent, AuthLoading, AuthState, CheckAuthStatus, EmailVerificationPending, GoogleLoginRequested (+13 more)

### Community 20 - "Community 20"
Cohesion: 0.17
Nodes (20): LoadShopEvent, message, ShopError, ShopEvent, ShopInitial, ShopLoaded, ShopLoading, ShopOperationSuccess (+12 more)

### Community 21 - "Community 21"
Cohesion: 0.11
Nodes (17): Color, IconData, AppBackButton, icon, size, build, color, icon (+9 more)

### Community 22 - "Community 22"
Cohesion: 0.10
Nodes (19): CustomPainter, _bottomPad, build, _buildPlaceholder, _buildStatChip, _buildStatsRow, _formatCurrency, _hasData (+11 more)

### Community 23 - "Community 23"
Cohesion: 0.11
Nodes (20): Design — Design System, Component Specs, DashboardActionCard + QuickActionTile, Dashboard Screen, Layout Considerations, Scanner Screen, Screens & Routes, StatCard Widget (+12 more)

### Community 24 - "Community 24"
Cohesion: 0.10
Nodes (19): UserModel, copyWith, email, emailConfirmedAt, fromString, id, isEmailConfirmed, isOwner (+11 more)

### Community 25 - "Community 25"
Cohesion: 0.11
Nodes (19): build, _buildPermissionPrompt, _cameraStatus, _checkPermission, controller, _corner, createState, dispose (+11 more)

### Community 26 - "Community 26"
Cohesion: 0.11
Nodes (18): ../../../auth/presentation/bloc/auth_bloc.dart, ../../../auth/presentation/bloc/auth_event.dart, ../../../auth/presentation/bloc/auth_state.dart, ../../../../core/widgets/input_label.dart, ../../../../core/widgets/primary_button.dart, AddStaffPage, _AddStaffPageState, build (+10 more)

### Community 27 - "Community 27"
Cohesion: 0.22
Nodes (19): AddProductToCartEvent, BillingEvent, ClearStockErrorsEvent, PrintReceiptEvent, RemoveProductFromCartEvent, ScanBarcodeEvent, SetDiscountTypeEvent, SubmitBillEvent (+11 more)

### Community 28 - "Community 28"
Cohesion: 0.11
Nodes (17): AuthRepository, config/routes/app_routes.dart, core/service_locator.dart, features/auth/domain/repositories/auth_repository.dart, features/auth/presentation/bloc/auth_event.dart, features/billing/presentation/bloc/billing_bloc.dart, features/category/presentation/bloc/category_bloc.dart, features/product/presentation/bloc/product_bloc.dart (+9 more)

### Community 29 - "Community 29"
Cohesion: 0.11
Nodes (17): GetProductsUseCase, bill, build, _buildInfoCard, _confirmDelete, createState, _editInfoRow, _infoRow (+9 more)

### Community 30 - "Community 30"
Cohesion: 0.11
Nodes (17): build, _buildEmptyState, _buildPaymentBadge, _buildTransactionItem, createdAt, _formatCurrency, grandTotal, id (+9 more)

### Community 31 - "Community 31"
Cohesion: 0.15
Nodes (16): ../bloc/printer_bloc.dart, ../bloc/printer_event.dart, ../bloc/printer_state.dart, core/theme/app_theme.dart, InitPrinterEvent, build, _buildListGroup, _buildListItem (+8 more)

### Community 32 - "Community 32"
Cohesion: 0.12
Nodes (16): ../../../category/domain/entities/category.dart, AddProductPage, _AddProductPageState, _barcodeController, build, _categoryId, createState, _description (+8 more)

### Community 33 - "Community 33"
Cohesion: 0.12
Nodes (16): hashCode, operator, read, typeId, write, int get, addressLine1, addressLine2 (+8 more)

### Community 34 - "Community 34"
Cohesion: 0.13
Nodes (15): currentRoute, icon, _initials, label, onTap, route, _SectionHeader, title (+7 more)

### Community 35 - "Community 35"
Cohesion: 0.13
Nodes (14): fromJson, fromProfileJson, fromSupabaseAuth, toJson, deleteStaffMember, getStaffMembers, StaffRepository, call (+6 more)

### Community 36 - "Community 36"
Cohesion: 0.12
Nodes (16): _barcode, build, _categoryId, createState, _description, EditProductPage, _EditProductPageState, _formKey (+8 more)

### Community 37 - "Community 37"
Cohesion: 0.12
Nodes (16): _buildBillCard, createState, _datePickerButton, dispose, _formatDiscount, _fromDate, initState, _loadBills (+8 more)

### Community 38 - "Community 38"
Cohesion: 0.16
Nodes (16): AddProduct, ProductState, DeleteProduct, GenerateQrCode, InitRealtime, _getAllProducts, ProductBloc, _checkDuplicate (+8 more)

### Community 39 - "Community 39"
Cohesion: 0.12
Nodes (16): Android Launcher Icon (hdpi), iOS App Icon (1024x1024), iOS App Icon (20x20 @1x), iOS App Icon (20x20 @2x), iOS App Icon (20x20 @3x), iOS App Icon (29x29 @1x), iOS App Icon (29x29 @2x), iOS App Icon (29x29 @3x) (+8 more)

### Community 40 - "Community 40"
Cohesion: 0.15
Nodes (15): dart:async, CheckAuthStatus, createState, dispose, email, EmailVerificationPage, _EmailVerificationPageState, initState (+7 more)

### Community 41 - "Community 41"
Cohesion: 0.14
Nodes (15): SignUpRequested, _confirmPasswordController, createState, dispose, _emailController, _formKey, _isLoading, _nameController (+7 more)

### Community 42 - "Community 42"
Cohesion: 0.12
Nodes (15): build, _buildBarChart, _buildDateNavigation, _buildStatCard, _buildStatCards, createState, _dayAbbr, _formatCurrency (+7 more)

### Community 43 - "Community 43"
Cohesion: 0.20
Nodes (16): Migration 004_shop_data_scoping.sql, Migration 006_three_tier_roles.sql, Session: Multi-Tenant Shop Data Isolation FIX, Owner-only Gating (3 Layers), shop_id Dart Threading, Signup Default = Owner, Staff Feature (Clean Arch), UserRole Dart Enum (+8 more)

### Community 44 - "Community 44"
Cohesion: 0.13
Nodes (14): ../bloc/billing_bloc.dart, ../../domain/entities/cart_item.dart, _buildDataCell, _buildHeaderCell, createState, _customerNameController, _customerPhoneController, dispose (+6 more)

### Community 45 - "Community 45"
Cohesion: 0.13
Nodes (14): ../bloc/shop_bloc.dart, _address1Controller, _address2Controller, _buildTextField, createState, dispose, _footerController, _formKey (+6 more)

### Community 46 - "Community 46"
Cohesion: 0.13
Nodes (15): Architecture, AUTO-PILOT MODE — No Questions, Just Execute 🤖⚡, Build Commands, CLAUDE.md — Flutter Billing App, CRITICAL — Dart-Only Fix Preference ⚡, CRITICAL — Next Time Auto-Recall ⚡, CRITICAL — Parallel Work Rule ⚡⚡, CRITICAL — Update Rule ⚡ (+7 more)

### Community 47 - "Community 47"
Cohesion: 0.13
Nodes (14): ../../core/widgets/app_drawer.dart, AppShell, build, child, build, build, build, build (+6 more)

### Community 48 - "Community 48"
Cohesion: 0.13
Nodes (14): double?, double get, CartItem, copyWith, customPrice, product, props, quantity (+6 more)

### Community 49 - "Community 49"
Cohesion: 0.15
Nodes (14): FormState, LoginRequested, build, createState, dispose, _emailController, _formKey, _isLoading (+6 more)

### Community 50 - "Community 50"
Cohesion: 0.13
Nodes (14): _createProfile, _ensureProfileRole, _ensureShopForOwner, _extractErrorMessage, _fetchProfile, getCurrentUser, login, loginWithGoogle (+6 more)

### Community 51 - "Community 51"
Cohesion: 0.17
Nodes (12): AuthRepository, call, GetCurrentUserUseCase, repository, call, LoginWithGoogleUseCase, repository, call (+4 more)

### Community 52 - "Community 52"
Cohesion: 0.14
Nodes (13): addCategory, CategoryRepository, deleteCategory, getCategories, updateCategory, AddCategoryUseCase, call, DeleteCategoryUseCase (+5 more)

### Community 53 - "Community 53"
Cohesion: 0.13
Nodes (14): barcode, categoryId, copyWith, createdAt, description, id, imageUrl, location (+6 more)

### Community 54 - "Community 54"
Cohesion: 0.13
Nodes (14): deleteBill, getBillDetail, getBillHistory, getDailySales, getLowStockProducts, getSalesRange, getStockMovements, _resolveShopId (+6 more)

### Community 55 - "Community 55"
Cohesion: 0.13
Nodes (14): billDetail, billHistory, copyWith, currentPage, dailySales, error, hasMorePages, lowStockProducts (+6 more)

### Community 56 - "Community 56"
Cohesion: 0.13
Nodes (14): build, _buildMovementCard, _changeTypes, _chipColor, createState, _filterApplied, _formatDate, _fromDate (+6 more)

### Community 57 - "Community 57"
Cohesion: 0.15
Nodes (10): Any, Bool, Flutter, FlutterAppDelegate, AppDelegate, RunnerTests, UIApplication, UIKit (+2 more)

### Community 58 - "Community 58"
Cohesion: 0.14
Nodes (13): ../bloc/product_bloc.dart, _buildDescriptionSnippet, createState, dispose, _dotSeparator, _filterChip, _metaText, _placeholderIcon (+5 more)

### Community 59 - "Community 59"
Cohesion: 0.14
Nodes (13): ../../../category/presentation/bloc/category_bloc.dart, _actionButton, build, _descriptionRow, _detailCard, _detailRow, _detailRow2, _formatDate (+5 more)

### Community 60 - "Community 60"
Cohesion: 0.21
Nodes (13): class, ../entities/product.dart, UseCase, AddProductUseCase, call, DeleteProductUseCase, GetCurrentStockBulkUseCase, GetProductByBarcodeUseCase (+5 more)

### Community 61 - "Community 61"
Cohesion: 0.14
Nodes (13): dart:ui, blur, borderOpacity, borderRadius, build, child, GlassCard, height (+5 more)

### Community 62 - "Community 62"
Cohesion: 0.14
Nodes (13): EdgeInsetsGeometry, borderRadius, build, elevation, icon, isFullWidth, isLoading, label (+5 more)

### Community 63 - "Community 63"
Cohesion: 0.14
Nodes (13): ../../features/product/data/models/product_model.dart, ../../features/shop/data/models/shop_model.dart, HiveDatabase, init, productBox, productBoxName, settingsBox, settingsBoxName (+5 more)

### Community 64 - "Community 64"
Cohesion: 0.19
Nodes (13): AppDrawer, AuthEvent, email, GoogleLoginRequested, LogoutRequested, name, password, props (+5 more)

### Community 65 - "Community 65"
Cohesion: 0.23
Nodes (13): Authenticated, AuthError, AuthInitial, AuthLoading, AuthState, email, EmailVerificationPending, message (+5 more)

### Community 66 - "Community 66"
Cohesion: 0.15
Nodes (13): build, createState, dispose, initState, product, _qrDataController, QrGeneratorPage, _QrGeneratorPageState (+5 more)

### Community 67 - "Community 67"
Cohesion: 0.14
Nodes (13): billId, changeType, date, from, items, page, paymentMethod, productId (+5 more)

### Community 68 - "Community 68"
Cohesion: 0.14
Nodes (13): _applyThreshold, build, createState, dispose, _formatCurrency, initState, _searchController, _searchQuery (+5 more)

### Community 69 - "Community 69"
Cohesion: 0.15
Nodes (10): ReportBloc Global Provider Fix, Session: Reports & History Data+Domain, Session: Reports Presentation Layer, Known Issues / TODO, Phase 4 — Reports & History, Phase 5 — Polish & Deploy, Phase 0 — Foundation ✅ (Complete), Phases — Roadmap (+2 more)

### Community 70 - "Community 70"
Cohesion: 0.18
Nodes (11): ../../../../core/error/failure.dart, ../../../../core/usecase/usecase.dart, ../../domain/entities/shop.dart, ../../domain/repositories/shop_repository.dart, getShop, ShopRepository, updateShop, call (+3 more)

### Community 71 - "Community 71"
Cohesion: 0.15
Nodes (12): ../../../../core/utils/printer_helper.dart, ../../domain/repositories/printer_repository.dart, PrinterHelper, clearPrinterData, connect, disconnect, getSavedPrinterMac, getSavedPrinterName (+4 more)

### Community 72 - "Community 72"
Cohesion: 0.22
Nodes (13): ClearCartEvent, UpdatePaymentMethodEvent, build, _CheckoutPageState, initState, _saveShop, _ShopDetailsPageState, MyApp (+5 more)

### Community 73 - "Community 73"
Cohesion: 0.15
Nodes (12): ../../domain/repositories/product_repository.dart, addProduct, deleteProduct, _fromMap, getCurrentStockBulk, getProductByBarcode, getProducts, getProductsByCategory (+4 more)

### Community 74 - "Community 74"
Cohesion: 0.15
Nodes (12): call, email, emailRedirectTo, name, password, props, repository, role (+4 more)

### Community 75 - "Community 75"
Cohesion: 0.18
Nodes (12): build, build, _buildCard, createState, ReportsHomePage, _ReportsHomePageState, package:billing_app/core/theme/app_theme.dart, Route /reports/bills (+4 more)

### Community 76 - "Community 76"
Cohesion: 0.15
Nodes (12): BillItemModel, BillSummaryModel, DailySalesModel, fromJson, fromSupabaseRow, StockMovementModel, toJson, BillItem (+4 more)

### Community 77 - "Community 77"
Cohesion: 0.31
Nodes (12): PrinterBloc, ConnectPrinterEvent, DisconnectPrinterEvent, InitPrinterEvent, mac, name, PrinterEvent, props (+4 more)

### Community 78 - "Community 78"
Cohesion: 0.17
Nodes (11): connecting,
  connected,
  connectionFailure,
  disconnected,, connectedMac, connectedName, copyWith, devices, errorMessage, PrinterState, PrinterStatus (+3 more)

### Community 79 - "Community 79"
Cohesion: 0.18
Nodes (12): Implementation Plan (Next Phase), Plugins affected by KGP (app_settings, device_info_plus, mobile_scanner, print_bluetooth_thermal, share_plus), Kotlin Gradle Plugin warning (build stability), RLS fix (owner profile seeded), Hardcoded Supabase project (wwutchscfnhwijxyftlw), TASK 1 — Fix Kotlin Gradle Plugin Warning, TASK 2 — Verify RLS Fix End-to-End, TASK 3 — Core Feature Completion (+4 more)

### Community 80 - "Community 80"
Cohesion: 0.17
Nodes (11): build, _buildGlassContainer, color, count, InventoryHealthCard, label, lowStockCount, onViewDetails (+3 more)

### Community 81 - "Community 81"
Cohesion: 0.17
Nodes (11): PrinterRepositoryImpl, clearPrinterData, connect, disconnect, getSavedPrinterMac, getSavedPrinterName, PrinterRepository, savePrinterData (+3 more)

### Community 82 - "Community 82"
Cohesion: 0.18
Nodes (10): bool get, _channels, dispose, _isConnected, RealtimeService, subscribeToProducts, subscribeToTable, unsubscribe (+2 more)

### Community 83 - "Community 83"
Cohesion: 0.20
Nodes (11): handle_new_user() trigger (default staff, signup promotes owner), shops table (id, owner_id, name, created_at) + RLS, signup_usecase (create shop + owner role), Super admin portal (deferred), TASK 4 — Auth Flow Hardening (SaaS-ready), Session: Auth Feature Complete, Migration 005_add_staff_phone.sql, Session: Staff Management Feature (+3 more)

### Community 84 - "Community 84"
Cohesion: 0.18
Nodes (10): build, color, DashboardActionCard, icon, label, onTap, QuickActionTile, subtitle (+2 more)

### Community 85 - "Community 85"
Cohesion: 0.18
Nodes (10): ReportRepositoryImpl, deleteBill, getBillDetail, getBillHistory, getDailySales, getLowStockProducts, getSalesRange, getStockMovements (+2 more)

### Community 86 - "Community 86"
Cohesion: 0.18
Nodes (10): addressLine1, addressLine2, copyWith, footerText, id, name, phoneNumber, props (+2 more)

### Community 87 - "Community 87"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 88 - "Community 88"
Cohesion: 0.20
Nodes (9): ../../domain/entities/product.dart, addProduct, deleteProduct, getCurrentStockBulk, getProductByBarcode, getProducts, getProductsByCategory, ProductRepository (+1 more)

### Community 89 - "Community 89"
Cohesion: 0.20
Nodes (9): AppTheme, backgroundColor, errorColor, primaryColor, secondaryColor, surfaceColor, textTheme, static const Color (+1 more)

### Community 90 - "Community 90"
Cohesion: 0.20
Nodes (9): authStateChanges, getCurrentUser, login, loginWithGoogle, logout, resendVerificationEmail, signUp, updateProfile (+1 more)

### Community 91 - "Community 91"
Cohesion: 0.20
Nodes (10): CheckoutPage, HomePage, AddEditCategoryDialog, BillDetailPage, BillHistoryPage, DailySalesPage, LowStockPage, StockMovementPage (+2 more)

### Community 92 - "Community 92"
Cohesion: 0.20
Nodes (9): _onConnect, _onDisconnect, _onInit, _onRefresh, _onScan, _onTestPrint, repository, printer_event.dart (+1 more)

### Community 93 - "Community 93"
Cohesion: 0.22
Nodes (10): Session: Dashboard Homepage + Side Menu, Session: Barcode/QR Scanner -> Cart, 2A — Categories ✅, 2B — Products (Inventory) ✅, 2C — Billing (Enhanced) ✅, Phase 2 — Core Features, Phase 4.5 — Dashboard & Navigation UX, Billing (Point of Sale) (+2 more)

### Community 94 - "Community 94"
Cohesion: 0.22
Nodes (8): ../../../auth/data/models/user_model.dart, ../../../auth/domain/entities/user.dart, ../../domain/repositories/staff_repository.dart, deleteStaffMember, getStaffMembers, _resolveShopId, _supabase, SupabaseClient get

### Community 95 - "Community 95"
Cohesion: 0.22
Nodes (9): AddProduct, DeleteProduct, FilterByCategory, GenerateQrCode, InitRealtime, LoadProducts, ProductEvent, ProductsRealtimeUpdated (+1 more)

### Community 96 - "Community 96"
Cohesion: 0.22
Nodes (8): DateTime, copyWith, createdAt, description, id, name, props, String?

### Community 97 - "Community 97"
Cohesion: 0.22
Nodes (8): ../../domain/repositories/category_repository.dart, addCategory, deleteCategory, getCategories, _resolveShopId, _supabase, updateCategory, ../models/category_model.dart

### Community 98 - "Community 98"
Cohesion: 0.22
Nodes (9): 1. Categories (Dynamic), 2. Product Inventory, 3. Billing (Point of Sale), 4. Real-time Sync (Supabase), 5. Shelf / Location Tracking, 6. QR Code Generator, 7. Reports & History, 8. Staff Management (Owner-only) (+1 more)

### Community 99 - "Community 99"
Cohesion: 0.22
Nodes (9): Client Profile, Constraints, Product Overview, Role Assignment Flow, RPD — Requirements & Product Definition, Shop Isolation Implementation, Target Platforms, Tech Stack Changes (+1 more)

### Community 100 - "Community 100"
Cohesion: 0.29
Nodes (8): @HiveType, ProductModelAdapter, ShopModelAdapter, ProductModel, Product, ShopModel, Shop, TypeAdapter

### Community 101 - "Community 101"
Cohesion: 0.25
Nodes (7): _anonKey, client, initialize, SupabaseConfig, _url, package:supabase_flutter/supabase_flutter.dart, static SupabaseClient get

### Community 102 - "Community 102"
Cohesion: 0.43
Nodes (8): build, _buildQuickTiles, Route /categories, Route /products, Route /reports, Route /settings, Route /shop, Route /staff

### Community 103 - "Community 103"
Cohesion: 0.25
Nodes (6): build, text, package:billing_app/main.dart, package:flutter/material.dart, package:flutter_test/flutter_test.dart, main

### Community 104 - "Community 104"
Cohesion: 0.25
Nodes (7): call, email, LoginParams, LoginUseCase, password, props, repository

### Community 105 - "Community 105"
Cohesion: 0.29
Nodes (6): core/data/hive_database.dart, core/supabase/supabase_client.dart, getShop, shopKey, updateShop, ../models/shop_model.dart

### Community 106 - "Community 106"
Cohesion: 0.29
Nodes (6): _, DeepLinkConfig, emailRedirectTo, host, scheme, static const String

### Community 107 - "Community 107"
Cohesion: 0.29
Nodes (7): 3E Realtime (Supabase Realtime sync), Session: Supabase Realtime Sync, RealtimeService, Stock Validation Before Bill, Phase 3 — Real-time & Multi-user, Real-time Sync, Supabase Backend

### Community 108 - "Community 108"
Cohesion: 0.38
Nodes (6): CacheFailure, Failure, message, props, ServerFailure, List

### Community 109 - "Community 109"
Cohesion: 0.33
Nodes (5): build, GreetingHeader, _monthName, userName, package:google_fonts/google_fonts.dart

### Community 110 - "Community 110"
Cohesion: 0.50
Nodes (5): Analysis Options Config, Web Favicon, Web Icon (192), Web Icon (512), Flutter Web Entry HTML

### Community 111 - "Community 111"
Cohesion: 0.40
Nodes (3): MainActivity, FlutterActivity, FlutterEngine

### Community 112 - "Community 112"
Cohesion: 0.40
Nodes (4): ../error/failure.dart, call, NoParams, package:fpdart/fpdart.dart

### Community 113 - "Community 113"
Cohesion: 0.67
Nodes (3): iOS Launch Image (@1x), iOS Launch Image (@2x), iOS Launch Image (@3x)

## Knowledge Gaps
- **1061 isolated node(s):** `supabase`, `XCTest`, `DeepLinkConfig`, `scheme`, `host` (+1056 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **34 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `AuthBloc` connect `Community 19` to `Community 0`, `Community 1`, `Community 2`, `Community 3`, `Community 4`, `Community 5`, `Community 7`, `Community 9`, `Community 10`, `Community 13`, `Community 26`, `Community 27`, `Community 28`, `Community 29`, `Community 34`, `Community 40`, `Community 41`, `Community 47`, `Community 49`, `Community 64`, `Community 72`, `Community 102`?**
  _High betweenness centrality (0.091) - this node is a cross-community bridge._
- **Why does `ReportBloc` connect `Community 13` to `Community 2`, `Community 4`, `Community 37`, `Community 68`, `Community 7`, `Community 8`, `Community 72`, `Community 42`, `Community 75`, `Community 56`, `Community 28`, `Community 29`?**
  _High betweenness centrality (0.022) - this node is a cross-community bridge._
- **Why does `ProductBloc` connect `Community 38` to `Community 32`, `Community 2`, `Community 3`, `Community 4`, `Community 36`, `Community 72`, `Community 14`, `Community 48`, `Community 58`, `Community 59`, `Community 28`?**
  _High betweenness centrality (0.018) - this node is a cross-community bridge._
- **What connects `supabase`, `XCTest`, `DeepLinkConfig` to the rest of the system?**
  _1061 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 0` be split into smaller, more focused modules?**
  _Cohesion score 0.03636363636363636 - nodes in this community are weakly interconnected._
- **Should `Community 1` be split into smaller, more focused modules?**
  _Cohesion score 0.053877551020408164 - nodes in this community are weakly interconnected._
- **Should `Community 2` be split into smaller, more focused modules?**
  _Cohesion score 0.07254623044096728 - nodes in this community are weakly interconnected._