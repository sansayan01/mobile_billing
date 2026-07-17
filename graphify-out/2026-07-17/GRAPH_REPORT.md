# Graph Report - .  (2026-07-17)

## Corpus Check
- cluster-only mode — file stats not available

## Summary
- 1315 nodes · 2013 edges · 96 communities (90 shown, 6 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 22 edges (avg confidence: 0.86)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `88df83ef`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Flutter Billing App
- service_locator.dart
- billing_bloc.dart
- shop_bloc.dart
- printer_bloc.dart
- product_bloc.dart
- app_routes.dart
- report_entities.dart
- ReportBloc
- printer_helper.dart
- UseCase
- product_model.dart
- auth_bloc.dart
- category_bloc.dart
- report_usecases.dart
- ProductBloc
- home_page.dart
- package:flutter_bloc/flutter_bloc.dart
- package:billing_app/core/error/failure.dart
- report_bloc.dart
- checkout_page.dart
- shop_model.dart
- daily_sales_page.dart
- Architecture
- primary_button.dart
- auth_repository.dart
- register_page.dart
- product.dart
- add_product_page.dart
- bill_history_page.dart
- report_state.dart
- .application
- shop_repository_impl.dart
- BillingBloc
- Equatable
- hive_database.dart
- stock_movement_page.dart
- Current Session: 2026-07-17 — Auth Feature Complete (15 files) ✅
- category_list_page.dart
- qr_generator_page.dart
- printer_repository_impl.dart
- package:fpdart/fpdart.dart
- login_page.dart
- scanner_page.dart
- edit_product_page.dart
- low_stock_page.dart
- printer_state.dart
- auth_repository_impl.dart
- product_repository_impl.dart
- AuthBloc
- package:go_router/go_router.dart
- printer_repository.dart
- 🛒 Mobile POS & Billing App
- Development Rules
- product_list_page.dart
- realtime_service.dart
- add_edit_category_dialog.dart
- Component Specs
- app_theme.dart
- auth_event.dart
- package:billing_app/features/report/domain/entities/report_entities.dart
- report_repository_impl.dart
- manifest.json
- CLAUDE.md — Flutter Billing App
- category_repository_impl.dart
- CategoryBloc
- product_repository.dart
- cart_item.dart
- signup_usecase.dart
- report_repository.dart
- shop.dart
- Product
- BillingBloc
- category.dart
- category_model.dart
- supabase_client.dart
- package:flutter/material.dart
- package:equatable/equatable.dart
- login_usecase.dart
- shop_usecases.dart
- List
- StatefulWidget
- bill_detail_page.dart
- build
- _buildScannerSection
- MainActivity
- app_validators.dart
- README.md
- @oksbi
- Equatable
- fpdart

## God Nodes (most connected - your core abstractions)
1. `AuthBloc` - 27 edges
2. `ProductBloc` - 24 edges
3. `ReportBloc` - 24 edges
4. `CategoryBloc` - 21 edges
5. `UseCase` - 19 edges
6. `BillingBloc` - 18 edges
7. `ShopBloc` - 17 edges
8. `PrinterBloc` - 16 edges
9. `BillingEvent` - 15 edges
10. `Flutter Billing App` - 14 edges

## Surprising Connections (you probably didn't know these)
- `Auth Feature Implementation` --implements--> `Product Overview`  [INFERRED]
  memory.md → RPD.md
- `supabase_flutter` --implements--> `Supabase`  [INFERRED]
  pubspec.yaml → CLAUDE.md
- `print_bluetooth_thermal` --conceptually_related_to--> `Billing Feature`  [INFERRED]
  CLAUDE.md → RPD.md
- `Stock Validation Feature` --implements--> `Billing Feature`  [INFERRED]
  memory.md → RPD.md
- `Auth Feature Implementation` --implements--> `Phase 1 Database and Auth`  [INFERRED]
  memory.md → phases.md

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Clean Architecture Implementation** — claude_clean_architecture, claude_flutter_bloc, claude_supabase, claude_hive, claude_get_it [INFERRED 0.85]
- **Core Retail Features** — rpd_categories, rpd_product_inventory, rpd_billing, rpd_shelf_location [EXTRACTED 1.00]
- **Development Workflow Rules** — claude_update_rule, claude_autopilot_mode, claude_parallel_work_rule [EXTRACTED 1.00]

## Communities (96 total, 6 thin omitted)

### Community 0 - "Flutter Billing App"
Cohesion: 0.05
Nodes (53): Auto-Pilot Mode, Clean Architecture, Flutter 3.x, Flutter Billing App, flutter_bloc, get_it, go_router, Hive (+45 more)

### Community 1 - "service_locator.dart"
Cohesion: 0.04
Nodes (47): AuthRepository, CategoryRepository, config/routes/app_routes.dart, core/service_locator.dart, ../../features/auth/data/repositories/auth_repository_impl.dart, ../../features/auth/domain/repositories/auth_repository.dart, ../../features/auth/domain/usecases/get_current_user_usecase.dart, ../../features/auth/domain/usecases/login_usecase.dart (+39 more)

### Community 2 - "billing_bloc.dart"
Cohesion: 0.04
Nodes (44): address1, address2, barcode, cartItems, copyWith, discountIsPercentage, error, footer (+36 more)

### Community 3 - "shop_bloc.dart"
Cohesion: 0.07
Nodes (40): Bloc, ../bloc/shop_bloc.dart, LoadShopEvent, message, ShopError, ShopEvent, ShopInitial, ShopLoaded (+32 more)

### Community 4 - "printer_bloc.dart"
Cohesion: 0.08
Nodes (36): ../bloc/printer_bloc.dart, ../bloc/printer_event.dart, ../bloc/printer_state.dart, _onConnect, _onDisconnect, _onInit, _onRefresh, _onScan (+28 more)

### Community 5 - "product_bloc.dart"
Cohesion: 0.06
Nodes (33): ../../../../core/realtime/realtime_service.dart, categoryId, changeType, copyWith, filteredProducts, id, message, payload (+25 more)

### Community 6 - "app_routes.dart"
Cohesion: 0.08
Nodes (26): AuthBloc, ../../features/auth/presentation/bloc/auth_state.dart, ../../features/auth/presentation/pages/login_page.dart, ../../features/auth/presentation/pages/register_page.dart, ../../features/billing/presentation/pages/checkout_page.dart, ../../features/billing/presentation/pages/home_page.dart, ../../features/billing/presentation/pages/scanner_page.dart, ../../features/category/presentation/pages/category_list_page.dart (+18 more)

### Community 7 - "report_entities.dart"
Cohesion: 0.08
Nodes (23): averageBill, billCount, changeType, copyWith, createdAt, date, discount, grandTotal (+15 more)

### Community 8 - "ReportBloc"
Cohesion: 0.16
Nodes (23): ReportBloc, billId, changeType, date, from, LoadBillDetail, LoadDailySales, LoadLowStockProducts (+15 more)

### Community 9 - "printer_helper.dart"
Cohesion: 0.09
Nodes (22): alignCenter, alignLeft, alignRight, boldOff, boldOn, checkPermission, connect, disconnect (+14 more)

### Community 10 - "UseCase"
Cohesion: 0.13
Nodes (20): class, ../entities/product.dart, UseCase, AddCategoryUseCase, call, DeleteCategoryUseCase, GetCategoriesUseCase, repository (+12 more)

### Community 11 - "product_model.dart"
Cohesion: 0.09
Nodes (21): hashCode, operator, read, typeId, write, barcode, categoryId, createdAt (+13 more)

### Community 12 - "auth_bloc.dart"
Cohesion: 0.09
Nodes (21): authRepository, _authSubscription, close, getCurrentUserUseCase, loginUseCase, loginWithGoogleUseCase, logoutUseCase, _onCheckAuthStatus (+13 more)

### Community 13 - "category_bloc.dart"
Cohesion: 0.10
Nodes (19): categories, CategoryStatus, copyWith, description, id, message, name, status (+11 more)

### Community 14 - "report_usecases.dart"
Cohesion: 0.13
Nodes (19): billId, call, changeType, date, from, GetBillDetailUseCase, GetBillHistoryUseCase, GetDailySalesUseCase (+11 more)

### Community 15 - "ProductBloc"
Cohesion: 0.21
Nodes (19): AddProduct, DeleteProduct, FilterByCategory, GenerateQrCode, InitRealtime, LoadProducts, ProductEvent, ProductsRealtimeUpdated (+11 more)

### Community 16 - "home_page.dart"
Cohesion: 0.11
Nodes (17): ../../../billing/presentation/bloc/billing_bloc.dart, ../../../../core/widgets/primary_button.dart, ../../domain/entities/cart_item.dart, build, _buildBottomPanel, _buildCameraOffState, _buildCorner, _buildEmptyCart (+9 more)

### Community 17 - "package:flutter_bloc/flutter_bloc.dart"
Cohesion: 0.13
Nodes (16): InputLabel, PrimaryButton, CheckAuthStatus, authenticatedChild, AuthGate, build, _SplashScreen, BillDetailPage (+8 more)

### Community 18 - "package:billing_app/core/error/failure.dart"
Cohesion: 0.16
Nodes (14): AuthRepositoryImpl, AuthRepository, call, GetCurrentUserUseCase, repository, call, LoginWithGoogleUseCase, repository (+6 more)

### Community 19 - "report_bloc.dart"
Cohesion: 0.12
Nodes (16): getBillDetailUseCase, getBillHistoryUseCase, getDailySalesUseCase, getLowStockProductsUseCase, getSalesRangeUseCase, getStockMovementsUseCase, _onLoadBillDetail, _onLoadBillHistory (+8 more)

### Community 20 - "checkout_page.dart"
Cohesion: 0.13
Nodes (15): ../bloc/billing_bloc.dart, ClearCartEvent, _buildDataCell, _buildHeaderCell, CheckoutPage, _CheckoutPageState, createState, dispose (+7 more)

### Community 21 - "shop_model.dart"
Cohesion: 0.12
Nodes (15): hashCode, operator, read, typeId, write, int get, addressLine1, addressLine2 (+7 more)

### Community 22 - "daily_sales_page.dart"
Cohesion: 0.12
Nodes (15): build, _buildBarChart, _buildDateNavigation, _buildStatCard, _buildStatCards, createState, _dayAbbr, _formatCurrency (+7 more)

### Community 23 - "Architecture"
Cohesion: 0.13
Nodes (15): 1. Presentation Layer, 2. Domain Layer, 3. Data Layer, Architecture, Architecture Pattern: **Clean Architecture + BLoC + Supabase**, Database: Supabase (PostgreSQL), Dependency Injection, High-Level Overview (+7 more)

### Community 24 - "primary_button.dart"
Cohesion: 0.13
Nodes (14): EdgeInsetsGeometry, IconData?, borderRadius, build, elevation, icon, isFullWidth, isLoading (+6 more)

### Community 25 - "auth_repository.dart"
Cohesion: 0.13
Nodes (13): fromJson, fromProfileJson, fromSupabaseAuth, toJson, authStateChanges, getCurrentUser, login, loginWithGoogle (+5 more)

### Community 26 - "register_page.dart"
Cohesion: 0.15
Nodes (14): SignUpRequested, _confirmPasswordController, createState, dispose, _emailController, _formKey, _isLoading, _nameController (+6 more)

### Community 27 - "product.dart"
Cohesion: 0.13
Nodes (14): barcode, categoryId, copyWith, createdAt, description, id, imageUrl, location (+6 more)

### Community 28 - "add_product_page.dart"
Cohesion: 0.13
Nodes (14): AddProductPage, _barcode, build, _categoryId, createState, _description, _formKey, _imageUrl (+6 more)

### Community 29 - "bill_history_page.dart"
Cohesion: 0.16
Nodes (14): LoadBillHistory, BillHistoryPage, _BillHistoryPageState, build, _buildBillCard, createState, _datePickerButton, _fromDate (+6 more)

### Community 30 - "report_state.dart"
Cohesion: 0.13
Nodes (14): billDetail, billHistory, copyWith, currentPage, dailySales, error, hasMorePages, lowStockProducts (+6 more)

### Community 31 - ".application"
Cohesion: 0.15
Nodes (10): Any, Bool, Flutter, FlutterAppDelegate, AppDelegate, RunnerTests, UIApplication, UIKit (+2 more)

### Community 32 - "shop_repository_impl.dart"
Cohesion: 0.16
Nodes (12): core/data/hive_database.dart, ../../../../core/error/failure.dart, ../../domain/entities/shop.dart, getShop, shopKey, ShopRepositoryImpl, updateShop, getShop (+4 more)

### Community 33 - "BillingBloc"
Cohesion: 0.27
Nodes (14): AddProductToCartEvent, BillingEvent, ClearCartEvent, ClearStockErrorsEvent, PrintReceiptEvent, RemoveProductFromCartEvent, ScanBarcodeEvent, SetDiscountTypeEvent (+6 more)

### Community 34 - "Equatable"
Cohesion: 0.14
Nodes (14): BillingState, CategoryState, ProductState, Equatable, UserModel, User, BillItemModel, BillItem (+6 more)

### Community 35 - "hive_database.dart"
Cohesion: 0.14
Nodes (13): ../../features/product/data/models/product_model.dart, ../../features/shop/data/models/shop_model.dart, HiveDatabase, init, productBox, productBoxName, settingsBox, settingsBoxName (+5 more)

### Community 36 - "stock_movement_page.dart"
Cohesion: 0.14
Nodes (13): build, _buildMovementCard, _changeTypes, _chipColor, createState, _filterApplied, _formatDate, _fromDate (+5 more)

### Community 37 - "Current Session: 2026-07-17 — Auth Feature Complete (15 files) ✅"
Cohesion: 0.18
Nodes (13): Category Data Layer Added, Category Feature Complete (2026-07-17) ✅, Category UI Created, Current Session: 2026-07-17 — Auth Feature Complete (15 files) ✅, Current Session: 2026-07-17 — Supabase Realtime Sync for Products ✅, flutter analyze, flutter analyze: Pending, Google Login Support (+5 more)

### Community 38 - "category_list_page.dart"
Cohesion: 0.17
Nodes (12): add_edit_category_dialog.dart, ../bloc/category_bloc.dart, build, CategoryListPage, _CategoryListPageState, _confirmDelete, createState, dispose (+4 more)

### Community 39 - "qr_generator_page.dart"
Cohesion: 0.17
Nodes (12): core/theme/app_theme.dart, build, createState, dispose, initState, product, _qrDataController, QrGeneratorPage (+4 more)

### Community 40 - "printer_repository_impl.dart"
Cohesion: 0.15
Nodes (12): ../../../../core/utils/printer_helper.dart, ../../domain/repositories/printer_repository.dart, PrinterHelper, clearPrinterData, connect, disconnect, getSavedPrinterMac, getSavedPrinterName (+4 more)

### Community 41 - "package:fpdart/fpdart.dart"
Cohesion: 0.15
Nodes (11): ../error/failure.dart, call, NoParams, CategoryRepositoryImpl, addCategory, CategoryRepository, deleteCategory, getCategories (+3 more)

### Community 42 - "login_page.dart"
Cohesion: 0.18
Nodes (12): FormState, GoogleLoginRequested, createState, dispose, _emailController, _formKey, _isLoading, LoginPage (+4 more)

### Community 43 - "scanner_page.dart"
Cohesion: 0.17
Nodes (12): build, controller, _corner, createState, dispose, _isScanned, _onDetect, ScannerPage (+4 more)

### Community 44 - "edit_product_page.dart"
Cohesion: 0.15
Nodes (12): build, _categoryId, createState, _description, _formKey, _imageUrl, initState, _location (+4 more)

### Community 45 - "low_stock_page.dart"
Cohesion: 0.15
Nodes (12): _applyThreshold, build, createState, dispose, _formatCurrency, initState, _searchController, _searchQuery (+4 more)

### Community 46 - "printer_state.dart"
Cohesion: 0.17
Nodes (11): connecting,
  connected,
  connectionFailure,
  disconnected,, connectedMac, connectedName, copyWith, devices, errorMessage, PrinterState, PrinterStatus (+3 more)

### Community 47 - "auth_repository_impl.dart"
Cohesion: 0.17
Nodes (11): dart:async, _createProfile, _extractErrorMessage, _fetchProfile, getCurrentUser, login, loginWithGoogle, logout (+3 more)

### Community 48 - "product_repository_impl.dart"
Cohesion: 0.17
Nodes (11): ../../domain/repositories/product_repository.dart, addProduct, deleteProduct, _fromMap, getCurrentStockBulk, getProductByBarcode, getProducts, getProductsByCategory (+3 more)

### Community 49 - "AuthBloc"
Cohesion: 0.30
Nodes (11): AuthBloc, Authenticated, AuthError, AuthInitial, AuthLoading, AuthState, message, props (+3 more)

### Community 50 - "package:go_router/go_router.dart"
Cohesion: 0.18
Nodes (11): build, _buildCard, createState, ReportsHomePage, _ReportsHomePageState, package:billing_app/core/theme/app_theme.dart, package:go_router/go_router.dart, Route /reports/bills (+3 more)

### Community 51 - "printer_repository.dart"
Cohesion: 0.17
Nodes (11): PrinterRepositoryImpl, clearPrinterData, connect, disconnect, getSavedPrinterMac, getSavedPrinterName, PrinterRepository, savePrinterData (+3 more)

### Community 52 - "🛒 Mobile POS & Billing App"
Cohesion: 0.17
Nodes (11): 🤝 Contributing Guidelines, Core Features:, 📁 File Structure, 🚀 Getting Started, Installation, 🛒 Mobile POS & Billing App, Prerequisites, 🎯 Project Scope (+3 more)

### Community 53 - "Development Rules"
Cohesion: 0.18
Nodes (11): Code Quality, Database Rules, Development Rules, Git Rules, Graphify Rules, Naming Conventions, Parallel Work Rule (CRITICAL — Speed), Project Rules (+3 more)

### Community 54 - "product_list_page.dart"
Cohesion: 0.18
Nodes (10): ../bloc/product_bloc.dart, ../../../category/presentation/bloc/category_bloc.dart, createState, dispose, _filterChip, _getCategoryName, _placeholderIcon, _scanQR (+2 more)

### Community 55 - "realtime_service.dart"
Cohesion: 0.18
Nodes (10): bool get, _channels, dispose, _isConnected, RealtimeService, subscribeToProducts, subscribeToTable, unsubscribe (+2 more)

### Community 56 - "add_edit_category_dialog.dart"
Cohesion: 0.18
Nodes (10): ../../../../core/utils/app_validators.dart, build, category, createState, _descriptionController, dispose, _formKey, initState (+2 more)

### Community 57 - "Component Specs"
Cohesion: 0.17
Nodes (11): Buttons (PrimaryButton), Cards, Component Specs, Design, Icons, Input Fields, Layout Considerations, Scanner Screen (+3 more)

### Community 58 - "app_theme.dart"
Cohesion: 0.18
Nodes (10): AppTheme, backgroundColor, errorColor, primaryColor, secondaryColor, surfaceColor, textTheme, package:google_fonts/google_fonts.dart (+2 more)

### Community 59 - "auth_event.dart"
Cohesion: 0.24
Nodes (10): AuthEvent, email, LoginRequested, LogoutRequested, name, password, props, role (+2 more)

### Community 60 - "package:billing_app/features/report/domain/entities/report_entities.dart"
Cohesion: 0.18
Nodes (10): BillSummaryModel, DailySalesModel, fromJson, fromSupabaseRow, StockMovementModel, toJson, BillSummary, DailySales (+2 more)

### Community 61 - "report_repository_impl.dart"
Cohesion: 0.18
Nodes (10): getBillDetail, getBillHistory, getDailySales, getLowStockProducts, getSalesRange, getStockMovements, _supabase, package:billing_app/core/supabase/supabase_client.dart (+2 more)

### Community 62 - "manifest.json"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 63 - "CLAUDE.md — Flutter Billing App"
Cohesion: 0.20
Nodes (10): Architecture, AUTO-PILOT MODE — No Questions, Just Execute 🤖⚡, Build Commands, CLAUDE.md — Flutter Billing App, CRITICAL — Parallel Work Rule ⚡⚡, CRITICAL — Update Rule ⚡, Key Files & Their Use Cases, Project (+2 more)

### Community 64 - "category_repository_impl.dart"
Cohesion: 0.20
Nodes (9): core/supabase/supabase_client.dart, ../../domain/repositories/category_repository.dart, addCategory, deleteCategory, getCategories, _supabase, updateCategory, ../models/category_model.dart (+1 more)

### Community 65 - "CategoryBloc"
Cohesion: 0.42
Nodes (10): AddCategory, CategoryEvent, DeleteCategory, LoadCategories, UpdateCategory, CategoryBloc, _AddEditCategoryDialogState, _onSave (+2 more)

### Community 66 - "product_repository.dart"
Cohesion: 0.20
Nodes (9): ../../domain/entities/product.dart, addProduct, deleteProduct, getCurrentStockBulk, getProductByBarcode, getProducts, getProductsByCategory, ProductRepository (+1 more)

### Community 67 - "cart_item.dart"
Cohesion: 0.22
Nodes (8): double get, CartItem, copyWith, product, props, quantity, total, package:billing_app/features/product/domain/entities/product.dart

### Community 68 - "signup_usecase.dart"
Cohesion: 0.22
Nodes (8): call, email, name, password, props, repository, SignUpParams, SignUpUseCase

### Community 69 - "report_repository.dart"
Cohesion: 0.22
Nodes (8): ReportRepositoryImpl, getBillDetail, getBillHistory, getDailySales, getLowStockProducts, getSalesRange, getStockMovements, ReportRepository

### Community 70 - "shop.dart"
Cohesion: 0.22
Nodes (8): addressLine1, addressLine2, copyWith, footerText, name, phoneNumber, props, upiId

### Community 71 - "Product"
Cohesion: 0.29
Nodes (8): @HiveType, ProductModelAdapter, ShopModelAdapter, ProductModel, Product, ShopModel, Shop, TypeAdapter

### Community 72 - "BillingBloc"
Cohesion: 0.32
Nodes (8): BillingBloc, build, _buildCartItemCard, HomePage, _HomePageState, _onDetect, ScanBarcodeEvent, UpdateQuantityEvent

### Community 73 - "category.dart"
Cohesion: 0.25
Nodes (7): DateTime, copyWith, createdAt, description, id, name, props

### Community 74 - "category_model.dart"
Cohesion: 0.25
Nodes (7): ../../domain/entities/category.dart, CategoryModel, fromEntity, fromJson, toEntity, toJson, Category

### Community 75 - "supabase_client.dart"
Cohesion: 0.25
Nodes (7): _anonKey, client, initialize, SupabaseConfig, _url, package:supabase_flutter/supabase_flutter.dart, static SupabaseClient get

### Community 76 - "package:flutter/material.dart"
Cohesion: 0.25
Nodes (6): build, text, package:billing_app/main.dart, package:flutter/material.dart, package:flutter_test/flutter_test.dart, main

### Community 77 - "package:equatable/equatable.dart"
Cohesion: 0.25
Nodes (7): copyWith, email, id, name, props, role, package:equatable/equatable.dart

### Community 78 - "login_usecase.dart"
Cohesion: 0.25
Nodes (7): call, email, LoginParams, LoginUseCase, password, props, repository

### Community 79 - "shop_usecases.dart"
Cohesion: 0.29
Nodes (6): ../../../../core/usecase/usecase.dart, ../../domain/repositories/shop_repository.dart, call, GetShopUseCase, repository, UpdateShopUseCase

### Community 80 - "List"
Cohesion: 0.38
Nodes (6): CacheFailure, Failure, message, props, ServerFailure, List

### Community 81 - "StatefulWidget"
Cohesion: 0.29
Nodes (7): AddEditCategoryDialog, EditProductPage, ProductListPage, DailySalesPage, LowStockPage, StockMovementPage, StatefulWidget

### Community 82 - "bill_detail_page.dart"
Cohesion: 0.29
Nodes (6): bill, build, _buildInfoCard, _infoRow, package:billing_app/core/widgets/primary_button.dart, package:intl/intl.dart

### Community 84 - "build"
Cohesion: 0.50
Nodes (4): build, build, Route /, Route /register

### Community 85 - "_buildScannerSection"
Cohesion: 0.50
Nodes (4): _buildScannerSection, Route /categories, Route /reports, Route /settings

## Knowledge Gaps
- **725 isolated node(s):** `XCTest`, `HiveDatabase`, `productBoxName`, `shopBoxName`, `settingsBoxName` (+720 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **6 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `AuthBloc` connect `AuthBloc` to `service_locator.dart`, `billing_bloc.dart`, `shop_bloc.dart`, `login_page.dart`, `auth_bloc.dart`, `package:flutter_bloc/flutter_bloc.dart`, `register_page.dart`, `auth_event.dart`?**
  _High betweenness centrality (0.030) - this node is a cross-community bridge._
- **Why does `Product` connect `Product` to `billing_bloc.dart`, `cart_item.dart`, `Equatable`, `product_bloc.dart`, `qr_generator_page.dart`, `edit_product_page.dart`, `product.dart`?**
  _High betweenness centrality (0.027) - this node is a cross-community bridge._
- **Why does `ProductModel` connect `Product` to `product_model.dart`, `hive_database.dart`?**
  _High betweenness centrality (0.020) - this node is a cross-community bridge._
- **What connects `XCTest`, `HiveDatabase`, `productBoxName` to the rest of the system?**
  _725 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Flutter Billing App` be split into smaller, more focused modules?**
  _Cohesion score 0.0517120894479385 - nodes in this community are weakly interconnected._
- **Should `service_locator.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.04421768707482993 - nodes in this community are weakly interconnected._
- **Should `billing_bloc.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.044444444444444446 - nodes in this community are weakly interconnected._