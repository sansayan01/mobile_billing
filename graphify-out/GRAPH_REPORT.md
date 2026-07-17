# Graph Report - flutter_billing_app-main  (2026-07-18)

## Corpus Check
- 134 files · ~1,405,055 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1586 nodes · 2446 edges · 136 communities (101 shown, 35 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 34 edges (avg confidence: 0.88)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `83b04038`
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
- Presentation
- Widgets
- Domain
- Models
- Equatable
- Client
- Domain
- Presentation
- Presentation
- App
- Config
- Implementation
- Implementation
- Presentation
- Reports
- User
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

## God Nodes (most connected - your core abstractions)
1. `AuthBloc` - 56 edges
2. `ReportBloc` - 32 edges
3. `UseCase` - 27 edges
4. `BillingBloc` - 25 edges
5. `ProductBloc` - 24 edges
6. `CategoryBloc` - 23 edges
7. `ShopBloc` - 18 edges
8. `PrinterBloc` - 16 edges
9. `BillingEvent` - 15 edges
10. `iOS App Icon (1024x1024)` - 15 edges

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

## Communities (136 total, 35 thin omitted)

### Community 0 - "Presentation"
Cohesion: 0.07
Nodes (45): ../bloc/printer_bloc.dart, ../bloc/printer_event.dart, ../bloc/printer_state.dart, ../../domain/repositories/printer_repository.dart, build, _buildScannerSection, _buildQuickTiles, _onConnect (+37 more)

### Community 1 - "Utils"
Cohesion: 0.05
Nodes (43): ../../../../core/utils/printer_helper.dart, alignCenter, alignLeft, alignRight, boldOff, boldOn, checkPermission, connect (+35 more)

### Community 2 - "Presentation"
Cohesion: 0.04
Nodes (44): address1, address2, barcode, cartItems, copyWith, discountIsPercentage, error, footer (+36 more)

### Community 3 - "Presentation"
Cohesion: 0.22
Nodes (18): AddProductToCartEvent, BillingEvent, ClearCartEvent, ClearStockErrorsEvent, PrintReceiptEvent, RemoveProductFromCartEvent, ScanBarcodeEvent, SetDiscountTypeEvent (+10 more)

### Community 4 - "Presentation"
Cohesion: 0.08
Nodes (36): ../bloc/shop_bloc.dart, LoadShopEvent, message, ShopError, ShopEvent, ShopInitial, ShopLoaded, ShopLoading (+28 more)

### Community 5 - "Presentation"
Cohesion: 0.06
Nodes (33): ../../../../core/realtime/realtime_service.dart, categoryId, changeType, copyWith, filteredProducts, id, message, payload (+25 more)

### Community 6 - "Presentation"
Cohesion: 0.07
Nodes (29): app_shell.dart, ../../features/auth/presentation/pages/email_verification_page.dart, ../../features/auth/presentation/pages/login_page.dart, ../../features/auth/presentation/pages/register_page.dart, ../../features/billing/presentation/pages/checkout_page.dart, ../../features/billing/presentation/pages/home_page.dart, ../../features/billing/presentation/pages/scanner_page.dart, ../../features/category/presentation/pages/category_list_page.dart (+21 more)

### Community 7 - "Domain"
Cohesion: 0.07
Nodes (29): ../../features/auth/data/repositories/auth_repository_impl.dart, ../../features/auth/domain/usecases/get_current_user_usecase.dart, ../../features/auth/domain/usecases/login_usecase.dart, ../../features/auth/domain/usecases/login_with_google_usecase.dart, ../../features/auth/domain/usecases/logout_usecase.dart, ../../features/auth/domain/usecases/signup_usecase.dart, ../../features/category/data/repositories/category_repository_impl.dart, ../../features/category/domain/repositories/category_repository.dart (+21 more)

### Community 8 - "Usecases"
Cohesion: 0.11
Nodes (22): BillingState, ProductState, Equatable, BillDetailParams, BillHistoryParams, billId, call, changeType (+14 more)

### Community 9 - "Presentation"
Cohesion: 0.32
Nodes (12): ReportBloc, LoadBillDetail, LoadBillHistory, LoadLowStockProducts, LoadStockMovements, ReportEvent, ResetReport, _BillHistoryPageState (+4 more)

### Community 10 - "Entities"
Cohesion: 0.08
Nodes (23): averageBill, billCount, changeType, copyWith, createdAt, date, discount, grandTotal (+15 more)

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
Cohesion: 0.05
Nodes (40): ../../../billing/presentation/bloc/billing_bloc.dart, ../../domain/entities/cart_item.dart, build, _buildBottomPanel, _buildCameraOffState, _buildCorner, _buildEmptyCart, _buildOverlayButton (+32 more)

### Community 15 - "Presentation"
Cohesion: 0.06
Nodes (34): categories, CategoryStatus, copyWith, description, id, message, name, status (+26 more)

### Community 16 - "Presentation"
Cohesion: 0.19
Nodes (12): AuthEvent, email, GoogleLoginRequested, name, password, props, ResendVerificationEmailRequested, role (+4 more)

### Community 17 - "Presentation"
Cohesion: 0.11
Nodes (17): authBloc, getBillDetailUseCase, getBillHistoryUseCase, getDailySalesUseCase, getLowStockProductsUseCase, getSalesRangeUseCase, getStockMovementsUseCase, _onLoadBillDetail (+9 more)

### Community 18 - "Presentation"
Cohesion: 0.11
Nodes (19): ../../../auth/presentation/bloc/auth_bloc.dart, ../../../auth/presentation/bloc/auth_event.dart, ../../../auth/presentation/bloc/auth_state.dart, ../../../../core/widgets/app_back_button.dart, ../../../../core/widgets/input_label.dart, ../../../../core/widgets/primary_button.dart, AddStaffPage, _AddStaffPageState (+11 more)

### Community 19 - "Presentation"
Cohesion: 0.12
Nodes (15): config/routes/app_routes.dart, core/service_locator.dart, features/auth/domain/repositories/auth_repository.dart, features/auth/presentation/bloc/auth_event.dart, features/billing/presentation/bloc/billing_bloc.dart, features/category/presentation/bloc/category_bloc.dart, features/product/presentation/bloc/product_bloc.dart, features/report/presentation/bloc/report_bloc.dart (+7 more)

### Community 20 - "Domain"
Cohesion: 0.13
Nodes (17): core/data/hive_database.dart, ../../../../core/error/failure.dart, ../../../../core/usecase/usecase.dart, ../../domain/entities/shop.dart, ../../domain/repositories/shop_repository.dart, getShop, shopKey, ShopRepositoryImpl (+9 more)

### Community 21 - "Design"
Cohesion: 0.11
Nodes (20): Design — Design System, Component Specs, DashboardActionCard + QuickActionTile, Dashboard Screen, Layout Considerations, Scanner Screen, Screens & Routes, StatCard Widget (+12 more)

### Community 22 - "User"
Cohesion: 0.06
Nodes (29): bool get, _channels, dispose, _isConnected, RealtimeService, subscribeToProducts, subscribeToTable, unsubscribe (+21 more)

### Community 23 - "Presentation"
Cohesion: 0.04
Nodes (45): Architecture, AUTO-PILOT MODE — No Questions, Just Execute 🤖⚡, Build Commands, CLAUDE.md — Flutter Billing App, CRITICAL — Dart-Only Fix Preference ⚡, CRITICAL — Next Time Auto-Recall ⚡, CRITICAL — Parallel Work Rule ⚡⚡, CRITICAL — Update Rule ⚡ (+37 more)

### Community 24 - "Presentation"
Cohesion: 0.22
Nodes (15): AuthBloc, CheckAuthStatus, LoginRequested, SignUpRequested, AuthGate, build, initState, _onContinue (+7 more)

### Community 25 - "Presentation"
Cohesion: 0.20
Nodes (19): AddProduct, DeleteProduct, FilterByCategory, GenerateQrCode, InitRealtime, LoadProducts, ProductEvent, ProductsRealtimeUpdated (+11 more)

### Community 26 - "Presentation"
Cohesion: 0.14
Nodes (14): authenticatedChild, _SplashScreen, createState, dispose, _emailController, _formKey, _isLoading, _obscurePassword (+6 more)

### Community 27 - "Presentation"
Cohesion: 0.14
Nodes (15): dart:async, AppDrawer, LogoutRequested, build, createState, dispose, email, EmailVerificationPage (+7 more)

### Community 28 - "Domain"
Cohesion: 0.18
Nodes (10): StaffRepositoryImpl, deleteStaffMember, getStaffMembers, StaffRepository, call, DeleteStaffMemberUseCase, GetStaffMembersUseCase, repository (+2 more)

### Community 29 - "Widgets"
Cohesion: 0.20
Nodes (9): currentRoute, _DrawerItem, icon, _initials, label, onTap, _ProfileHeader, route (+1 more)

### Community 30 - "Presentation"
Cohesion: 0.15
Nodes (12): _confirmPasswordController, createState, dispose, _emailController, _formKey, _isLoading, _nameController, _obscureConfirmPassword (+4 more)

### Community 31 - "App"
Cohesion: 0.12
Nodes (16): Android Launcher Icon (hdpi), iOS App Icon (1024x1024), iOS App Icon (20x20 @1x), iOS App Icon (20x20 @2x), iOS App Icon (20x20 @3x), iOS App Icon (29x29 @1x), iOS App Icon (29x29 @2x), iOS App Icon (29x29 @3x) (+8 more)

### Community 32 - "Models"
Cohesion: 0.12
Nodes (15): hashCode, operator, read, typeId, write, int get, addressLine1, addressLine2 (+7 more)

### Community 33 - "Presentation"
Cohesion: 0.12
Nodes (15): copyWith, id, message, staff, StaffStatus, status, authBloc, deleteStaffMemberUseCase (+7 more)

### Community 34 - "Repositories"
Cohesion: 0.15
Nodes (12): ../../domain/repositories/product_repository.dart, addProduct, deleteProduct, _fromMap, getCurrentStockBulk, getProductByBarcode, getProducts, getProductsByCategory (+4 more)

### Community 35 - "Domain"
Cohesion: 0.16
Nodes (13): AuthRepositoryImpl, AuthRepository, call, GetCurrentUserUseCase, repository, call, LoginWithGoogleUseCase, repository (+5 more)

### Community 36 - "Presentation"
Cohesion: 0.11
Nodes (20): LoadDailySales, LoadSalesRange, build, _buildBarChart, _buildDateNavigation, _buildStatCard, _buildStatCards, createState (+12 more)

### Community 37 - "Presentation"
Cohesion: 0.13
Nodes (15): build, _buildMovementCard, _changeTypes, _chipColor, createState, _filterApplied, _formatDate, _fromDate (+7 more)

### Community 38 - "Domain"
Cohesion: 0.15
Nodes (13): core/theme/app_theme.dart, build, createState, dispose, initState, product, _qrDataController, QrGeneratorPage (+5 more)

### Community 39 - "Dashboard"
Cohesion: 0.12
Nodes (19): _SectionHeader, PrimaryButton, createState, DashboardPage, _DashboardView, _DashboardViewState, _formatCurrency, _Greeting (+11 more)

### Community 40 - "Domain"
Cohesion: 0.13
Nodes (14): barcode, categoryId, copyWith, createdAt, description, id, imageUrl, location (+6 more)

### Community 41 - "Presentation"
Cohesion: 0.13
Nodes (14): billDetail, billHistory, copyWith, currentPage, dailySales, error, hasMorePages, lowStockProducts (+6 more)

### Community 42 - "Presentation"
Cohesion: 0.17
Nodes (12): ../bloc/billing_bloc.dart, _buildDataCell, _buildHeaderCell, CheckoutPage, _CheckoutPageState, createState, dispose, _isEditingTotal (+4 more)

### Community 43 - "Runnertests"
Cohesion: 0.15
Nodes (10): Any, Bool, Flutter, FlutterAppDelegate, AppDelegate, RunnerTests, UIApplication, UIKit (+2 more)

### Community 44 - "Usecases"
Cohesion: 0.13
Nodes (19): class, ../entities/product.dart, UseCase, AddProductUseCase, call, DeleteProductUseCase, GetCurrentStockBulkUseCase, GetProductByBarcodeUseCase (+11 more)

### Community 45 - "Database"
Cohesion: 0.14
Nodes (13): ../../features/product/data/models/product_model.dart, ../../features/shop/data/models/shop_model.dart, HiveDatabase, init, productBox, productBoxName, settingsBox, settingsBoxName (+5 more)

### Community 46 - "Repositories"
Cohesion: 0.14
Nodes (13): _createProfile, _ensureProfileRole, _extractErrorMessage, _fetchProfile, getCurrentUser, login, loginWithGoogle, logout (+5 more)

### Community 47 - "Domain"
Cohesion: 0.15
Nodes (12): call, email, emailRedirectTo, name, password, props, repository, role (+4 more)

### Community 48 - "Presentation"
Cohesion: 0.23
Nodes (13): Authenticated, AuthError, AuthInitial, AuthLoading, AuthState, email, EmailVerificationPending, message (+5 more)

### Community 49 - "Presentation"
Cohesion: 0.14
Nodes (13): _barcode, build, _categoryId, createState, _description, _formKey, _imageUrl, _location (+5 more)

### Community 50 - "Presentation"
Cohesion: 0.15
Nodes (13): _applyThreshold, build, createState, dispose, _formatCurrency, initState, LowStockPage, _LowStockPageState (+5 more)

### Community 51 - "Presentation"
Cohesion: 0.15
Nodes (12): ../bloc/staff_bloc.dart, ../../../../features/auth/domain/entities/user.dart, features/auth/presentation/bloc/auth_bloc.dart, ../../../../features/auth/presentation/bloc/auth_state.dart, build, createState, dispose, _initials (+4 more)

### Community 52 - "Widgets"
Cohesion: 0.15
Nodes (12): EdgeInsetsGeometry, borderRadius, build, elevation, icon, isFullWidth, isLoading, label (+4 more)

### Community 53 - "Presentation"
Cohesion: 0.09
Nodes (23): ../bloc/product_bloc.dart, ../../../category/presentation/bloc/category_bloc.dart, ../../../../core/utils/app_validators.dart, build, _categoryId, createState, _description, _formKey (+15 more)

### Community 54 - "Models"
Cohesion: 0.15
Nodes (12): BillItemModel, BillSummaryModel, DailySalesModel, fromJson, fromSupabaseRow, StockMovementModel, toJson, BillItem (+4 more)

### Community 55 - "Presentation"
Cohesion: 0.08
Nodes (26): add_edit_category_dialog.dart, ../bloc/category_bloc.dart, ../../domain/entities/category.dart, FormState, CategoryModel, fromEntity, fromJson, toEntity (+18 more)

### Community 56 - "Presentation"
Cohesion: 0.17
Nodes (11): connecting,
  connected,
  connectionFailure,
  disconnected,, connectedMac, connectedName, copyWith, devices, errorMessage, PrinterState, PrinterStatus (+3 more)

### Community 57 - "Presentation"
Cohesion: 0.18
Nodes (10): DateTime, billId, changeType, date, from, page, productId, props (+2 more)

### Community 58 - "Realtime"
Cohesion: 0.40
Nodes (4): ../error/failure.dart, call, NoParams, package:fpdart/fpdart.dart

### Community 59 - "Repositories"
Cohesion: 0.22
Nodes (8): ../../domain/repositories/category_repository.dart, addCategory, deleteCategory, getCategories, _resolveShopId, _supabase, updateCategory, ../models/category_model.dart

### Community 60 - "App"
Cohesion: 0.18
Nodes (10): AppTheme, backgroundColor, errorColor, primaryColor, secondaryColor, surfaceColor, textTheme, package:google_fonts/google_fonts.dart (+2 more)

### Community 61 - "Repositories"
Cohesion: 0.18
Nodes (10): getBillDetail, getBillHistory, getDailySales, getLowStockProducts, getSalesRange, getStockMovements, _supabase, package:billing_app/core/supabase/supabase_client.dart (+2 more)

### Community 62 - "Presentation"
Cohesion: 0.17
Nodes (11): BillHistoryPage, _buildBillCard, createState, _datePickerButton, _fromDate, initState, _selectDate, _toDate (+3 more)

### Community 63 - "Web"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 64 - "Domain"
Cohesion: 0.22
Nodes (8): ../../domain/entities/product.dart, addProduct, deleteProduct, getCurrentStockBulk, getProductByBarcode, getProducts, getProductsByCategory, updateProduct

### Community 65 - "Implementation"
Cohesion: 0.29
Nodes (7): 3E Realtime (Supabase Realtime sync), Session: Supabase Realtime Sync, RealtimeService, Stock Validation Before Bill, Phase 3 — Real-time & Multi-user, Real-time Sync, Supabase Backend

### Community 66 - "Widgets"
Cohesion: 0.11
Nodes (17): Color, build, color, DashboardActionCard, icon, label, onTap, QuickActionTile (+9 more)

### Community 67 - "Domain"
Cohesion: 0.20
Nodes (9): authStateChanges, getCurrentUser, login, loginWithGoogle, logout, resendVerificationEmail, signUp, updateProfile (+1 more)

### Community 68 - "Repositories"
Cohesion: 0.22
Nodes (8): ../../../auth/data/models/user_model.dart, ../../../auth/domain/entities/user.dart, core/supabase/supabase_client.dart, ../../domain/repositories/staff_repository.dart, deleteStaffMember, getStaffMembers, _supabase, SupabaseClient get

### Community 69 - "Presentation"
Cohesion: 0.23
Nodes (16): Bloc, AddCategory, CategoryEvent, CategoryState, DeleteCategory, LoadCategories, UpdateCategory, CategoryBloc (+8 more)

### Community 70 - "Domain"
Cohesion: 0.22
Nodes (8): double get, CartItem, copyWith, product, props, quantity, total, package:billing_app/features/product/domain/entities/product.dart

### Community 71 - "Widgets"
Cohesion: 0.22
Nodes (7): build, InputLabel, text, package:billing_app/main.dart, package:flutter/material.dart, package:flutter_test/flutter_test.dart, main

### Community 72 - "Repositories"
Cohesion: 0.22
Nodes (8): ReportRepositoryImpl, getBillDetail, getBillHistory, getDailySales, getLowStockProducts, getSalesRange, getStockMovements, ReportRepository

### Community 73 - "Domain"
Cohesion: 0.22
Nodes (8): addressLine1, addressLine2, copyWith, footerText, name, phoneNumber, props, upiId

### Community 74 - "Memory"
Cohesion: 0.33
Nodes (7): Session: Dashboard Homepage + Side Menu, Session: Barcode/QR Scanner -> Cart, Phase 2 — Core Features, Phase 4.5 — Dashboard & Navigation UX, Billing (Point of Sale), Dynamic Categories, Product Inventory

### Community 75 - "Rpd"
Cohesion: 0.46
Nodes (8): Migration 006_three_tier_roles.sql, Signup Default = Owner, UserRole Dart Enum, Phase 6 — SaaS-Ready Auth (Owner Signup + Shops), 3-Tier User Role System, handle_new_user DB Trigger, Owner Role, Super Admin Role

### Community 76 - "Models"
Cohesion: 0.29
Nodes (8): @HiveType, ProductModelAdapter, ShopModelAdapter, ProductModel, Product, ShopModel, Shop, TypeAdapter

### Community 77 - "Presentation"
Cohesion: 0.46
Nodes (8): DeleteStaffMember, LoadStaff, StaffEvent, StaffState, StaffBloc, _confirmDelete, initState, _StaffListPageState

### Community 78 - "Widgets"
Cohesion: 0.40
Nodes (5): TASK 3 — Core Feature Completion, 3A Scanner (barcode/QR → product lookup → cart), 3B Cart/Billing (cart state, qty, total, discount, bill), 3C Printer (ESC/POS receipt print), 3D UPI QR (dynamic UPI QR from amount)

### Community 79 - "Domain"
Cohesion: 0.25
Nodes (7): copyWith, createdAt, description, id, name, props, package:equatable/equatable.dart

### Community 81 - "Equatable"
Cohesion: 0.38
Nodes (6): CacheFailure, Failure, message, props, ServerFailure, List

### Community 82 - "Client"
Cohesion: 0.25
Nodes (7): _anonKey, client, initialize, SupabaseConfig, _url, package:supabase_flutter/supabase_flutter.dart, static SupabaseClient get

### Community 83 - "Domain"
Cohesion: 0.25
Nodes (7): call, email, LoginParams, LoginUseCase, password, props, repository

### Community 84 - "Presentation"
Cohesion: 0.29
Nodes (7): HomePage, AddEditCategoryDialog, AddProductPage, EditProductPage, ShopDetailsPage, StaffListPage, StatefulWidget

### Community 85 - "Presentation"
Cohesion: 0.25
Nodes (7): bill, BillDetailPage, build, _buildInfoCard, _infoRow, package:billing_app/core/widgets/primary_button.dart, package:intl/intl.dart

### Community 86 - "App"
Cohesion: 0.29
Nodes (6): ../../core/widgets/app_drawer.dart, AppShell, build, child, package:go_router/go_router.dart, Widget

### Community 87 - "Config"
Cohesion: 0.29
Nodes (6): _, DeepLinkConfig, emailRedirectTo, host, scheme, static const String

### Community 88 - "Implementation"
Cohesion: 0.33
Nodes (7): Implementation Plan (Next Phase), Plugins affected by KGP (app_settings, device_info_plus, mobile_scanner, print_bluetooth_thermal, share_plus), Kotlin Gradle Plugin warning (build stability), RLS fix (owner profile seeded), Hardcoded Supabase project (wwutchscfnhwijxyftlw), TASK 1 — Fix Kotlin Gradle Plugin Warning, TASK 2 — Verify RLS Fix End-to-End

### Community 89 - "Implementation"
Cohesion: 0.29
Nodes (7): handle_new_user() trigger (default staff, signup promotes owner), shops table (id, owner_id, name, created_at) + RLS, signup_usecase (create shop + owner role), Super admin portal (deferred), TASK 4 — Auth Flow Hardening (SaaS-ready), Session: Auth Feature Complete, Phase 1 — Database & Auth

### Community 90 - "Presentation"
Cohesion: 0.17
Nodes (11): IconData?, AppBackButton, build, icon, size, build, build, build (+3 more)

### Community 91 - "Reports"
Cohesion: 0.17
Nodes (12): build, build, _buildCard, createState, ReportsHomePage, _ReportsHomePageState, package:billing_app/core/theme/app_theme.dart, Route /reports/bills (+4 more)

### Community 92 - "User"
Cohesion: 0.33
Nodes (5): fromJson, fromProfileJson, fromSupabaseAuth, toJson, package:billing_app/features/auth/domain/entities/user.dart

### Community 94 - "Memory"
Cohesion: 0.40
Nodes (6): Migration 004_shop_data_scoping.sql, Session: Multi-Tenant Shop Data Isolation FIX, Owner-only Gating (3 Layers), shop_id Dart Threading, Staff Feature (Clean Arch), Row Level Security (RLS) Policies

### Community 95 - "Memory"
Cohesion: 0.40
Nodes (6): Migration 005_add_staff_phone.sql, Session: Staff Management Feature, Migration 003_saas_shops.sql, Phase 6.5 — Staff Management (Owner-only), Staff Role, Staff Management (Owner-only)

### Community 96 - "Web"
Cohesion: 0.50
Nodes (5): Analysis Options Config, Web Favicon, Web Icon (192), Web Icon (512), Flutter Web Entry HTML

### Community 98 - "Memory"
Cohesion: 0.40
Nodes (5): ReportBloc Global Provider Fix, Session: Reports & History Data+Domain, Session: Reports Presentation Layer, Phase 4 — Reports & History, Reports & History

### Community 100 - "Launchimage"
Cohesion: 0.67
Nodes (3): iOS Launch Image (@1x), iOS Launch Image (@2x), iOS Launch Image (@3x)

## Knowledge Gaps
- **887 isolated node(s):** `supabase`, `XCTest`, `rootNavigatorKey`, `child`, `build` (+882 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **35 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `AuthBloc` connect `Presentation` to `Presentation`, `Presentation`, `Presentation`, `Presentation`, `Presentation`, `Presentation`, `Presentation`, `Presentation`, `Presentation`, `Presentation`, `Presentation`, `Presentation`, `Widgets`, `Presentation`, `Presentation`, `Dashboard`, `Presentation`, `Presentation`, `Presentation`, `Presentation`?**
  _High betweenness centrality (0.083) - this node is a cross-community bridge._
- **Why does `Product` connect `Models` to `Presentation`, `Presentation`, `Domain`, `Domain`, `Domain`, `Usecases`, `Presentation`?**
  _High betweenness centrality (0.020) - this node is a cross-community bridge._
- **Why does `AuthRepository` connect `Domain` to `Domain`, `Domain`, `Presentation`, `Domain`, `Domain`, `Presentation`?**
  _High betweenness centrality (0.019) - this node is a cross-community bridge._
- **What connects `supabase`, `XCTest`, `rootNavigatorKey` to the rest of the system?**
  _887 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Presentation` be split into smaller, more focused modules?**
  _Cohesion score 0.0700354609929078 - nodes in this community are weakly interconnected._
- **Should `Utils` be split into smaller, more focused modules?**
  _Cohesion score 0.04541062801932367 - nodes in this community are weakly interconnected._
- **Should `Presentation` be split into smaller, more focused modules?**
  _Cohesion score 0.044444444444444446 - nodes in this community are weakly interconnected._