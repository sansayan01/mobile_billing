# Graph Report - flutter_billing_app-main  (2026-07-21)

## Corpus Check
- 139 files · ~1,409,825 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1690 nodes · 2601 edges · 144 communities (111 shown, 33 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 34 edges (avg confidence: 0.88)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `e7c80296`
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
- Presentation
- Widgets
- Presentation
- Models
- Presentation
- Presentation
- Presentation
- Realtime
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
- shop_repository_impl.dart
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

## God Nodes (most connected - your core abstractions)
1. `AuthBloc` - 55 edges
2. `ReportBloc` - 32 edges
3. `ProductBloc` - 30 edges
4. `BillingBloc` - 28 edges
5. `UseCase` - 27 edges
6. `CategoryBloc` - 27 edges
7. `ShopBloc` - 20 edges
8. `BillingEvent` - 17 edges
9. `PrinterBloc` - 16 edges
10. `iOS App Icon (1024x1024)` - 15 edges

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

## Communities (144 total, 33 thin omitted)

### Community 0 - "Presentation"
Cohesion: 0.06
Nodes (51): ../bloc/printer_bloc.dart, ../bloc/printer_event.dart, ../bloc/printer_state.dart, ../../domain/repositories/printer_repository.dart, build, _buildScannerSection, build, _buildQuickTiles (+43 more)

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
Nodes (37): ../bloc/shop_bloc.dart, LoadShopEvent, message, ShopError, ShopEvent, ShopInitial, ShopLoaded, ShopLoading (+29 more)

### Community 5 - "Presentation"
Cohesion: 0.06
Nodes (33): ../../../../core/realtime/realtime_service.dart, categoryId, changeType, copyWith, filteredProducts, id, message, payload (+25 more)

### Community 6 - "Presentation"
Cohesion: 0.06
Nodes (31): app_shell.dart, ../../features/auth/presentation/pages/email_verification_page.dart, ../../features/auth/presentation/pages/login_page.dart, ../../features/auth/presentation/pages/register_page.dart, ../../features/billing/domain/entities/cart_item.dart, ../../features/billing/presentation/pages/checkout_page.dart, ../../features/billing/presentation/pages/home_page.dart, ../../features/billing/presentation/pages/receipt_preview_page.dart (+23 more)

### Community 7 - "Domain"
Cohesion: 0.05
Nodes (44): config/routes/app_routes.dart, core/service_locator.dart, ../../features/auth/data/repositories/auth_repository_impl.dart, features/auth/domain/repositories/auth_repository.dart, ../../features/auth/domain/usecases/get_current_user_usecase.dart, ../../features/auth/domain/usecases/login_usecase.dart, ../../features/auth/domain/usecases/login_with_google_usecase.dart, ../../features/auth/domain/usecases/logout_usecase.dart (+36 more)

### Community 8 - "Usecases"
Cohesion: 0.11
Nodes (17): class, billId, call, changeType, date, from, GetDailySalesUseCase, GetLowStockProductsUseCase (+9 more)

### Community 9 - "Presentation"
Cohesion: 0.17
Nodes (11): ../../../../core/utils/printer_helper.dart, PrinterHelper, clearPrinterData, connect, disconnect, getSavedPrinterMac, getSavedPrinterName, _printerHelper (+3 more)

### Community 10 - "Entities"
Cohesion: 0.08
Nodes (25): averageBill, billCount, changeType, copyWith, createdAt, customerName, customerPhone, date (+17 more)

### Community 11 - "Presentation"
Cohesion: 0.09
Nodes (22): authRepository, _authSubscription, close, getCurrentUserUseCase, loginUseCase, loginWithGoogleUseCase, logoutUseCase, _onCheckAuthStatus (+14 more)

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
Nodes (20): GetBillDetailUseCase, GetBillHistoryUseCase, GetStockMovementsUseCase, authBloc, getBillDetailUseCase, getBillHistoryUseCase, getDailySalesUseCase, getLowStockProductsUseCase (+12 more)

### Community 18 - "Presentation"
Cohesion: 0.11
Nodes (19): ../../../auth/presentation/bloc/auth_bloc.dart, ../../../auth/presentation/bloc/auth_event.dart, ../../../auth/presentation/bloc/auth_state.dart, ../../../../core/widgets/app_back_button.dart, ../../../../core/widgets/input_label.dart, ../../../../core/widgets/primary_button.dart, AddStaffPage, _AddStaffPageState (+11 more)

### Community 19 - "Presentation"
Cohesion: 0.16
Nodes (12): ../../../../core/error/failure.dart, ../../../../core/usecase/usecase.dart, ../../domain/entities/shop.dart, ../../domain/repositories/shop_repository.dart, ShopRepositoryImpl, getShop, ShopRepository, updateShop (+4 more)

### Community 20 - "Domain"
Cohesion: 0.15
Nodes (12): ../bloc/staff_bloc.dart, ../../../../features/auth/domain/entities/user.dart, features/auth/presentation/bloc/auth_bloc.dart, ../../../../features/auth/presentation/bloc/auth_state.dart, build, createState, dispose, _initials (+4 more)

### Community 21 - "Design"
Cohesion: 0.11
Nodes (20): Design — Design System, Component Specs, DashboardActionCard + QuickActionTile, Dashboard Screen, Layout Considerations, Scanner Screen, Screens & Routes, StatCard Widget (+12 more)

### Community 22 - "User"
Cohesion: 0.11
Nodes (17): copyWith, email, emailConfirmedAt, fromString, id, isEmailConfirmed, isOwner, isStaff (+9 more)

### Community 23 - "Presentation"
Cohesion: 0.04
Nodes (43): Architecture, AUTO-PILOT MODE — No Questions, Just Execute 🤖⚡, Build Commands, CLAUDE.md — Flutter Billing App, CRITICAL — Dart-Only Fix Preference ⚡, CRITICAL — Next Time Auto-Recall ⚡, CRITICAL — Parallel Work Rule ⚡⚡, CRITICAL — Update Rule ⚡ (+35 more)

### Community 24 - "Presentation"
Cohesion: 0.12
Nodes (15): ../../../category/presentation/bloc/category_bloc.dart, _ProductSearchDelegate, Product, _actionButton, _descriptionRow, _detailCard, _detailRow, _detailRow2 (+7 more)

### Community 25 - "Presentation"
Cohesion: 0.21
Nodes (18): AddProduct, DeleteProduct, FilterByCategory, GenerateQrCode, InitRealtime, LoadProducts, ProductEvent, ProductsRealtimeUpdated (+10 more)

### Community 26 - "Presentation"
Cohesion: 0.18
Nodes (12): FormState, LoginRequested, createState, dispose, _emailController, _formKey, _isLoading, LoginPage (+4 more)

### Community 27 - "Presentation"
Cohesion: 0.12
Nodes (17): authenticatedChild, _SplashScreen, createState, dispose, email, EmailVerificationPage, _isChecking, _isResending (+9 more)

### Community 28 - "Domain"
Cohesion: 0.18
Nodes (10): StaffRepositoryImpl, deleteStaffMember, getStaffMembers, StaffRepository, call, DeleteStaffMemberUseCase, GetStaffMembersUseCase, repository (+2 more)

### Community 29 - "Widgets"
Cohesion: 0.12
Nodes (17): currentRoute, _DrawerItem, icon, _initials, label, onTap, _ProfileHeader, route (+9 more)

### Community 30 - "Presentation"
Cohesion: 0.13
Nodes (16): SignUpRequested, _confirmPasswordController, createState, dispose, _emailController, _formKey, _isLoading, _nameController (+8 more)

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
Cohesion: 0.14
Nodes (13): dart:async, ../../domain/repositories/product_repository.dart, addProduct, deleteProduct, _fromMap, getCurrentStockBulk, getProductByBarcode, getProducts (+5 more)

### Community 35 - "Domain"
Cohesion: 0.16
Nodes (13): AuthRepositoryImpl, AuthRepository, call, GetCurrentUserUseCase, repository, call, LoginWithGoogleUseCase, repository (+5 more)

### Community 36 - "Presentation"
Cohesion: 0.12
Nodes (15): build, _buildBarChart, _buildDateNavigation, _buildStatCard, _buildStatCards, createState, _dayAbbr, _formatCurrency (+7 more)

### Community 37 - "Presentation"
Cohesion: 0.10
Nodes (18): build, GreetingHeader, _monthName, userName, build, _buildMovementCard, _changeTypes, _chipColor (+10 more)

### Community 38 - "Domain"
Cohesion: 0.14
Nodes (14): core/theme/app_theme.dart, build, createState, dispose, initState, product, _qrDataController, QrGeneratorPage (+6 more)

### Community 39 - "Dashboard"
Cohesion: 0.09
Nodes (23): appBarTheme, buildActions, _buildDescriptionSnippet, buildLeading, buildResults, _buildSearchResults, buildSuggestions, createState (+15 more)

### Community 40 - "Domain"
Cohesion: 0.13
Nodes (14): barcode, categoryId, copyWith, createdAt, description, id, imageUrl, location (+6 more)

### Community 41 - "Presentation"
Cohesion: 0.12
Nodes (15): DailySalesModel, DailySales, billDetail, billHistory, copyWith, currentPage, dailySales, error (+7 more)

### Community 42 - "Presentation"
Cohesion: 0.10
Nodes (20): ../bloc/billing_bloc.dart, ClearCartEvent, ../../domain/entities/cart_item.dart, build, _buildDataCell, _buildHeaderCell, CheckoutPage, _CheckoutPageState (+12 more)

### Community 43 - "Runnertests"
Cohesion: 0.15
Nodes (10): Any, Bool, Flutter, FlutterAppDelegate, AppDelegate, RunnerTests, UIApplication, UIKit (+2 more)

### Community 44 - "Usecases"
Cohesion: 0.23
Nodes (12): ../entities/product.dart, UseCase, AddProductUseCase, call, DeleteProductUseCase, GetCurrentStockBulkUseCase, GetProductByBarcodeUseCase, GetProductsByCategoryUseCase (+4 more)

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
Cohesion: 0.13
Nodes (14): _barcodeController, _categoryId, _checkDuplicate, createState, _description, _formKey, _imageUrl, _location (+6 more)

### Community 50 - "Presentation"
Cohesion: 0.14
Nodes (13): _applyThreshold, build, createState, dispose, _formatCurrency, initState, _searchController, _searchQuery (+5 more)

### Community 51 - "Presentation"
Cohesion: 0.13
Nodes (15): CategoryRepositoryImpl, addCategory, CategoryRepository, deleteCategory, getCategories, updateCategory, AddCategoryUseCase, call (+7 more)

### Community 52 - "Widgets"
Cohesion: 0.15
Nodes (12): EdgeInsetsGeometry, borderRadius, build, elevation, icon, isFullWidth, isLoading, label (+4 more)

### Community 53 - "Presentation"
Cohesion: 0.13
Nodes (14): ../../../category/domain/entities/category.dart, _barcode, _categoryId, createState, _description, _formKey, _imageUrl, initState (+6 more)

### Community 54 - "Models"
Cohesion: 0.18
Nodes (10): bool get, _channels, dispose, _isConnected, RealtimeService, subscribeToProducts, subscribeToTable, unsubscribe (+2 more)

### Community 55 - "Presentation"
Cohesion: 0.11
Nodes (18): ../../../../core/utils/app_validators.dart, ../../domain/entities/category.dart, CategoryModel, fromEntity, fromJson, toEntity, toJson, Category (+10 more)

### Community 56 - "Presentation"
Cohesion: 0.17
Nodes (11): connecting,
  connected,
  connectionFailure,
  disconnected,, connectedMac, connectedName, copyWith, devices, errorMessage, PrinterState, PrinterStatus (+3 more)

### Community 57 - "Presentation"
Cohesion: 0.46
Nodes (8): Bloc, DeleteStaffMember, LoadStaff, StaffEvent, StaffBloc, _confirmDelete, initState, _StaffListPageState

### Community 58 - "Realtime"
Cohesion: 0.18
Nodes (10): ../../core/widgets/app_drawer.dart, AppShell, build, child, _buildCard, createState, ReportsHomePage, _ReportsHomePageState (+2 more)

### Community 59 - "Repositories"
Cohesion: 0.22
Nodes (8): ../../domain/repositories/category_repository.dart, addCategory, deleteCategory, getCategories, _resolveShopId, _supabase, updateCategory, ../models/category_model.dart

### Community 60 - "App"
Cohesion: 0.20
Nodes (9): AppTheme, backgroundColor, errorColor, primaryColor, secondaryColor, surfaceColor, textTheme, static const Color (+1 more)

### Community 61 - "Repositories"
Cohesion: 0.17
Nodes (11): getBillDetail, getBillHistory, getDailySales, getLowStockProducts, getSalesRange, getStockMovements, _resolveShopId, _supabase (+3 more)

### Community 62 - "Presentation"
Cohesion: 0.18
Nodes (13): LoadBillHistory, BillHistoryPage, _BillHistoryPageState, build, _buildBillCard, createState, _datePickerButton, _fromDate (+5 more)

### Community 63 - "Web"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 64 - "Domain"
Cohesion: 0.18
Nodes (10): ../../domain/entities/product.dart, ProductRepositoryImpl, addProduct, deleteProduct, getCurrentStockBulk, getProductByBarcode, getProducts, getProductsByCategory (+2 more)

### Community 65 - "Implementation"
Cohesion: 0.25
Nodes (7): Color, build, color, icon, label, StatCard, value

### Community 66 - "Widgets"
Cohesion: 0.20
Nodes (9): build, color, DashboardActionCard, icon, label, onTap, QuickActionTile, subtitle (+1 more)

### Community 67 - "Domain"
Cohesion: 0.20
Nodes (9): authStateChanges, getCurrentUser, login, loginWithGoogle, logout, resendVerificationEmail, signUp, updateProfile (+1 more)

### Community 68 - "Repositories"
Cohesion: 0.07
Nodes (28): dart:io, dart:ui, GlobalKey, address1, address2, cartItems, createState, customerName (+20 more)

### Community 69 - "Presentation"
Cohesion: 0.18
Nodes (10): add_edit_category_dialog.dart, ../bloc/category_bloc.dart, build, CategoryListPage, _confirmDelete, createState, dispose, _openAddEditDialog (+2 more)

### Community 70 - "Domain"
Cohesion: 0.17
Nodes (11): double?, double get, CartItem, copyWith, customPrice, product, props, quantity (+3 more)

### Community 71 - "Widgets"
Cohesion: 0.22
Nodes (7): build, InputLabel, text, package:billing_app/main.dart, package:flutter/material.dart, package:flutter_test/flutter_test.dart, main

### Community 72 - "Repositories"
Cohesion: 0.22
Nodes (8): ReportRepositoryImpl, getBillDetail, getBillHistory, getDailySales, getLowStockProducts, getSalesRange, getStockMovements, ReportRepository

### Community 73 - "Domain"
Cohesion: 0.20
Nodes (9): addressLine1, addressLine2, copyWith, footerText, id, name, phoneNumber, props (+1 more)

### Community 74 - "Memory"
Cohesion: 0.33
Nodes (7): Session: Dashboard Homepage + Side Menu, Session: Barcode/QR Scanner -> Cart, Phase 2 — Core Features, Phase 4.5 — Dashboard & Navigation UX, Billing (Point of Sale), Dynamic Categories, Product Inventory

### Community 75 - "Rpd"
Cohesion: 0.46
Nodes (8): Migration 006_three_tier_roles.sql, Signup Default = Owner, UserRole Dart Enum, Phase 6 — SaaS-Ready Auth (Owner Signup + Shops), 3-Tier User Role System, handle_new_user DB Trigger, Owner Role, Super Admin Role

### Community 76 - "Models"
Cohesion: 0.33
Nodes (7): @HiveType, ProductModelAdapter, ShopModelAdapter, ProductModel, ShopModel, Shop, TypeAdapter

### Community 77 - "category_repository.dart"
Cohesion: 0.17
Nodes (11): PrinterRepositoryImpl, clearPrinterData, connect, disconnect, getSavedPrinterMac, getSavedPrinterName, PrinterRepository, savePrinterData (+3 more)

### Community 78 - "Widgets"
Cohesion: 0.22
Nodes (9): TASK 3 — Core Feature Completion, 3A Scanner (barcode/QR → product lookup → cart), 3B Cart/Billing (cart state, qty, total, discount, bill), 3C Printer (ESC/POS receipt print), 3D UPI QR (dynamic UPI QR from amount), 3E Realtime (Supabase Realtime sync), Session: Supabase Realtime Sync, RealtimeService (+1 more)

### Community 79 - "Domain"
Cohesion: 0.25
Nodes (7): DateTime, copyWith, createdAt, description, id, name, props

### Community 80 - "package:billing_app/features/report/domain/entities/report_entities.dart"
Cohesion: 0.33
Nodes (11): AppDrawer, AuthBloc, CheckAuthStatus, LogoutRequested, AuthGate, build, build, _EmailVerificationPageState (+3 more)

### Community 81 - "Equatable"
Cohesion: 0.32
Nodes (7): CacheFailure, Failure, message, props, ServerFailure, List, package:equatable/equatable.dart

### Community 82 - "Client"
Cohesion: 0.13
Nodes (15): BillingState, CategoryState, ProductState, Equatable, BillItemModel, StockMovementModel, BillItem, StockMovement (+7 more)

### Community 83 - "printer_repository_impl.dart"
Cohesion: 0.25
Nodes (7): ../../../auth/data/models/user_model.dart, ../../../auth/domain/entities/user.dart, ../../domain/repositories/staff_repository.dart, deleteStaffMember, getStaffMembers, _supabase, SupabaseClient get

### Community 84 - "Presentation"
Cohesion: 0.16
Nodes (23): ReportBloc, billId, changeType, date, from, LoadBillDetail, LoadDailySales, LoadLowStockProducts (+15 more)

### Community 85 - "Presentation"
Cohesion: 0.14
Nodes (13): BillSummaryModel, fromJson, fromSupabaseRow, toJson, BillSummary, bill, BillDetailPage, build (+5 more)

### Community 86 - "printer_repository.dart"
Cohesion: 0.25
Nodes (7): call, email, LoginParams, LoginUseCase, password, props, repository

### Community 87 - "Config"
Cohesion: 0.29
Nodes (6): _, DeepLinkConfig, emailRedirectTo, host, scheme, static const String

### Community 88 - "Implementation"
Cohesion: 0.33
Nodes (7): Implementation Plan (Next Phase), Plugins affected by KGP (app_settings, device_info_plus, mobile_scanner, print_bluetooth_thermal, share_plus), Kotlin Gradle Plugin warning (build stability), RLS fix (owner profile seeded), Hardcoded Supabase project (wwutchscfnhwijxyftlw), TASK 1 — Fix Kotlin Gradle Plugin Warning, TASK 2 — Verify RLS Fix End-to-End

### Community 89 - "Implementation"
Cohesion: 0.29
Nodes (7): handle_new_user() trigger (default staff, signup promotes owner), shops table (id, owner_id, name, created_at) + RLS, signup_usecase (create shop + owner role), Super admin portal (deferred), TASK 4 — Auth Flow Hardening (SaaS-ready), Session: Auth Feature Complete, Phase 1 — Database & Auth

### Community 90 - "category_list_page.dart"
Cohesion: 0.25
Nodes (7): build, color, icon, label, PremiumStatCard, value, package:google_fonts/google_fonts.dart

### Community 91 - "login_usecase.dart"
Cohesion: 0.33
Nodes (13): AddCategory, CategoryEvent, DeleteCategory, LoadCategories, UpdateCategory, CategoryBloc, _AddEditCategoryDialogState, _onSave (+5 more)

### Community 92 - "product_list_page.dart"
Cohesion: 0.13
Nodes (14): ../bloc/product_bloc.dart, _buildDescriptionSnippet, createState, dispose, _dotSeparator, _filterChip, _getCategoryName, _metaText (+6 more)

### Community 93 - "StatefulWidget"
Cohesion: 0.20
Nodes (10): build, build, build, build, build, build, build, Route / (+2 more)

### Community 94 - "Memory"
Cohesion: 0.33
Nodes (7): Migration 004_shop_data_scoping.sql, Session: Multi-Tenant Shop Data Isolation FIX, shop_id Dart Threading, Phase 3 — Real-time & Multi-user, Real-time Sync, Row Level Security (RLS) Policies, Supabase Backend

### Community 95 - "Memory"
Cohesion: 0.29
Nodes (8): Migration 005_add_staff_phone.sql, Owner-only Gating (3 Layers), Staff Feature (Clean Arch), Session: Staff Management Feature, Migration 003_saas_shops.sql, Phase 6.5 — Staff Management (Owner-only), Staff Role, Staff Management (Owner-only)

### Community 96 - "Web"
Cohesion: 0.50
Nodes (5): Analysis Options Config, Web Favicon, Web Icon (192), Web Icon (512), Flutter Web Entry HTML

### Community 97 - "shop_repository_impl.dart"
Cohesion: 0.29
Nodes (6): core/data/hive_database.dart, core/supabase/supabase_client.dart, getShop, shopKey, updateShop, ../models/shop_model.dart

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
Cohesion: 0.33
Nodes (5): IconData?, AppBackButton, build, icon, size

### Community 139 - "category_model.dart"
Cohesion: 0.29
Nodes (6): fromJson, fromProfileJson, fromSupabaseAuth, toJson, UserModel, User

### Community 140 - "supabase_client.dart"
Cohesion: 0.25
Nodes (7): _anonKey, client, initialize, SupabaseConfig, _url, package:supabase_flutter/supabase_flutter.dart, static SupabaseClient get

### Community 141 - "package:billing_app/core/theme/app_theme.dart"
Cohesion: 0.20
Nodes (10): HomePage, AddProductPage, EditProductPage, ProductListPage, DailySalesPage, LowStockPage, StockMovementPage, SettingsPage (+2 more)

### Community 142 - "package:fpdart/fpdart.dart"
Cohesion: 0.40
Nodes (4): ../error/failure.dart, call, NoParams, package:fpdart/fpdart.dart

### Community 143 - "User Roles (3-Tier)"
Cohesion: 0.67
Nodes (3): Role Assignment Flow, Shop Isolation Implementation, User Roles (3-Tier)

## Knowledge Gaps
- **953 isolated node(s):** `supabase`, `XCTest`, `rootNavigatorKey`, `child`, `build` (+948 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **33 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `AuthBloc` connect `package:billing_app/features/report/domain/entities/report_entities.dart` to `Presentation`, `Presentation`, `Presentation`, `Presentation`, `Domain`, `Presentation`, `Presentation`, `Presentation`, `Presentation`, `Presentation`, `Domain`, `Presentation`, `Presentation`, `Widgets`, `Presentation`, `Presentation`, `Dashboard`, `Presentation`, `Presentation`?**
  _High betweenness centrality (0.104) - this node is a cross-community bridge._
- **Why does `Product` connect `Presentation` to `Presentation`, `Presentation`, `Domain`, `Domain`, `Domain`, `Models`, `Client`, `Presentation`?**
  _High betweenness centrality (0.023) - this node is a cross-community bridge._
- **Why does `AuthRepository` connect `Domain` to `Domain`, `Domain`, `Presentation`, `Domain`, `printer_repository.dart`?**
  _High betweenness centrality (0.020) - this node is a cross-community bridge._
- **What connects `supabase`, `XCTest`, `rootNavigatorKey` to the rest of the system?**
  _953 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Presentation` be split into smaller, more focused modules?**
  _Cohesion score 0.05870020964360587 - nodes in this community are weakly interconnected._
- **Should `Utils` be split into smaller, more focused modules?**
  _Cohesion score 0.09090909090909091 - nodes in this community are weakly interconnected._
- **Should `Presentation` be split into smaller, more focused modules?**
  _Cohesion score 0.0392156862745098 - nodes in this community are weakly interconnected._