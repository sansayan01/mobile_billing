# Graph Report - flutter_billing_app-main  (2026-07-17)

## Corpus Check
- 115 files · ~38,302 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1418 nodes · 2194 edges · 98 communities (92 shown, 6 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 19 edges (avg confidence: 0.88)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `7208ee8c`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Printer Helper (ESC/POS)
- Printer Bloc & Settings
- Billing Bloc & State
- Shop Bloc & Details Page
- Project Docs (CLAUDE/RPD/phases)
- Product Bloc & Realtime
- Billing Scanner & Home Page
- Repositories & Service Locator
- Category Bloc & Usecases
- Auth Bloc
- Route Definitions & Pages
- Auth Usecases
- Report Entities
- Report Bloc
- Report Usecase Params
- Product Model (Hive)
- Shop Repository & Usecases
- Daily Sales Page
- Product Usecases
- Auth Event & Login Page
- Main App Bootstrap
- Product List Page
- Billing Events
- Edit Product Page
- Report Event
- Stock Movement Page
- Shop Model (Hive)
- Auth Gate & Login
- Low Stock Page
- Memory Session Log
- Auth User Model & Repo
- Register Page
- Product Entity
- Report State
- iOS Runner
- Auth Router Guard
- Hive Database Core
- App Drawer & Widgets
- Add Product Page
- Checkout Page
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
- Community 88
- Community 91
- Community 93
- Community 94
- Community 98
- Community 100
- Community 101

## God Nodes (most connected - your core abstractions)
1. `AuthBloc` - 34 edges
2. `ReportBloc` - 30 edges
3. `UseCase` - 25 edges
4. `BillingBloc` - 25 edges
5. `ProductBloc` - 24 edges
6. `CategoryBloc` - 23 edges
7. `ShopBloc` - 18 edges
8. `PrinterBloc` - 16 edges
9. `BillingEvent` - 15 edges
10. `Flutter Billing App` - 14 edges

## Surprising Connections (you probably didn't know these)
- `supabase_flutter` --implements--> `Supabase`  [INFERRED]
  pubspec.yaml → CLAUDE.md
- `Flutter Billing App` --conceptually_related_to--> `Product Overview`  [INFERRED]
  CLAUDE.md → RPD.md
- `Supabase` --conceptually_related_to--> `Real-time Sync Feature`  [INFERRED]
  CLAUDE.md → RPD.md
- `print_bluetooth_thermal` --conceptually_related_to--> `Billing Feature`  [INFERRED]
  CLAUDE.md → RPD.md
- `mobile_scanner` --conceptually_related_to--> `Product Inventory Feature`  [INFERRED]
  CLAUDE.md → RPD.md

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Clean Architecture Implementation** — claude_clean_architecture, claude_flutter_bloc, claude_supabase, claude_hive, claude_get_it [INFERRED 0.85]
- **Core Retail Features** — rpd_categories, rpd_product_inventory, rpd_billing, rpd_shelf_location [EXTRACTED 1.00]
- **Development Workflow Rules** — claude_update_rule, claude_autopilot_mode, claude_parallel_work_rule [EXTRACTED 1.00]

## Communities (98 total, 6 thin omitted)

### Community 0 - "Printer Helper (ESC/POS)"
Cohesion: 0.08
Nodes (38): ../bloc/shop_bloc.dart, LoadShopEvent, message, ShopError, ShopEvent, ShopInitial, ShopLoaded, ShopLoading (+30 more)

### Community 1 - "Printer Bloc & Settings"
Cohesion: 0.04
Nodes (45): ../../../../core/utils/printer_helper.dart, ../../domain/repositories/printer_repository.dart, alignCenter, alignLeft, alignRight, boldOff, boldOn, checkPermission (+37 more)

### Community 2 - "Billing Bloc & State"
Cohesion: 0.04
Nodes (44): address1, address2, barcode, cartItems, copyWith, discountIsPercentage, error, footer (+36 more)

### Community 3 - "Shop Bloc & Details Page"
Cohesion: 0.09
Nodes (31): Auto-Pilot Mode, Clean Architecture, Flutter 3.x, Flutter Billing App, flutter_bloc, get_it, go_router, Hive (+23 more)

### Community 4 - "Project Docs (CLAUDE/RPD/phases)"
Cohesion: 0.09
Nodes (33): ../bloc/printer_bloc.dart, ../bloc/printer_event.dart, ../bloc/printer_state.dart, _onConnect, _onDisconnect, _onInit, _onRefresh, _onScan (+25 more)

### Community 5 - "Product Bloc & Realtime"
Cohesion: 0.06
Nodes (33): ../../../../core/realtime/realtime_service.dart, categoryId, changeType, copyWith, filteredProducts, id, message, payload (+25 more)

### Community 6 - "Billing Scanner & Home Page"
Cohesion: 0.08
Nodes (32): App Routes (app_routes.dart), AuthBloc, Auth Feature, AuthRepository, BillingBloc, CategoryBloc, Category Feature, CheckoutPage (+24 more)

### Community 7 - "Repositories & Service Locator"
Cohesion: 0.05
Nodes (41): config/routes/app_routes.dart, core/service_locator.dart, ../../features/auth/data/repositories/auth_repository_impl.dart, ../../features/auth/domain/repositories/auth_repository.dart, ../../features/auth/domain/usecases/get_current_user_usecase.dart, ../../features/auth/domain/usecases/login_usecase.dart, ../../features/auth/domain/usecases/login_with_google_usecase.dart, ../../features/auth/domain/usecases/logout_usecase.dart (+33 more)

### Community 8 - "Category Bloc & Usecases"
Cohesion: 0.07
Nodes (27): app_shell.dart, ../../features/auth/presentation/bloc/auth_state.dart, ../../features/auth/presentation/pages/login_page.dart, ../../features/auth/presentation/pages/register_page.dart, ../../features/billing/presentation/pages/checkout_page.dart, ../../features/billing/presentation/pages/home_page.dart, ../../features/billing/presentation/pages/scanner_page.dart, ../../features/category/presentation/pages/category_list_page.dart (+19 more)

### Community 9 - "Auth Bloc"
Cohesion: 0.09
Nodes (21): authRepository, _authSubscription, close, getCurrentUserUseCase, loginUseCase, loginWithGoogleUseCase, logoutUseCase, _onCheckAuthStatus (+13 more)

### Community 10 - "Route Definitions & Pages"
Cohesion: 0.16
Nodes (14): AuthRepositoryImpl, AuthRepository, call, GetCurrentUserUseCase, repository, call, LoginWithGoogleUseCase, repository (+6 more)

### Community 11 - "Auth Usecases"
Cohesion: 0.08
Nodes (23): averageBill, billCount, changeType, copyWith, createdAt, date, discount, grandTotal (+15 more)

### Community 12 - "Report Entities"
Cohesion: 0.10
Nodes (20): GetBillDetailUseCase, GetBillHistoryUseCase, GetLowStockProductsUseCase, GetStockMovementsUseCase, getBillDetailUseCase, getBillHistoryUseCase, getDailySalesUseCase, getLowStockProductsUseCase (+12 more)

### Community 13 - "Report Bloc"
Cohesion: 0.09
Nodes (26): class, ProductState, Equatable, UserModel, User, BillDetailParams, BillHistoryParams, billId (+18 more)

### Community 14 - "Report Usecase Params"
Cohesion: 0.09
Nodes (21): hashCode, operator, read, typeId, write, barcode, categoryId, createdAt (+13 more)

### Community 15 - "Product Model (Hive)"
Cohesion: 0.14
Nodes (15): currentRoute, icon, _initials, label, onTap, route, _SectionHeader, title (+7 more)

### Community 16 - "Shop Repository & Usecases"
Cohesion: 0.14
Nodes (19): ../entities/product.dart, UseCase, AddCategoryUseCase, call, DeleteCategoryUseCase, GetCategoriesUseCase, repository, UpdateCategoryUseCase (+11 more)

### Community 17 - "Daily Sales Page"
Cohesion: 0.10
Nodes (19): categories, CategoryStatus, copyWith, description, id, message, name, status (+11 more)

### Community 18 - "Product Usecases"
Cohesion: 0.18
Nodes (10): build, color, DashboardActionCard, icon, label, onTap, QuickActionTile, subtitle (+2 more)

### Community 19 - "Auth Event & Login Page"
Cohesion: 0.25
Nodes (7): ../../domain/entities/category.dart, CategoryModel, fromEntity, fromJson, toEntity, toJson, Category

### Community 20 - "Main App Bootstrap"
Cohesion: 0.11
Nodes (17): ../../../billing/presentation/bloc/billing_bloc.dart, ../../../../core/widgets/primary_button.dart, ../../domain/entities/cart_item.dart, build, _buildBottomPanel, _buildCameraOffState, _buildCorner, _buildEmptyCart (+9 more)

### Community 21 - "Product List Page"
Cohesion: 0.06
Nodes (33): Category Data Layer Added, Category Feature Complete (2026-07-17) ✅, Category UI Created, Current Session: 2026-07-17 — Auth Feature Complete (15 files) ✅, Current Session: 2026-07-17 — Dashboard Homepage + Improved Side Menu ✅, Current Session: 2026-07-17 — Reports & History Data + Domain Layers ✅, Current Session: 2026-07-17 — Reports & History Feature (Presentation Layer + Domain/Data) ✅, Current Session: 2026-07-17 — Supabase Realtime Sync for Products ✅ (+25 more)

### Community 22 - "Billing Events"
Cohesion: 0.18
Nodes (10): DateTime, billId, changeType, date, from, page, productId, props (+2 more)

### Community 23 - "Edit Product Page"
Cohesion: 0.13
Nodes (15): build, _buildMovementCard, _changeTypes, _chipColor, createState, _filterApplied, _formatDate, _fromDate (+7 more)

### Community 24 - "Report Event"
Cohesion: 0.15
Nodes (14): ../bloc/billing_bloc.dart, ClearCartEvent, build, _buildDataCell, _buildHeaderCell, CheckoutPage, _CheckoutPageState, createState (+6 more)

### Community 25 - "Stock Movement Page"
Cohesion: 0.12
Nodes (18): core/data/hive_database.dart, ../../../../core/error/failure.dart, ../../../../core/usecase/usecase.dart, ../../domain/entities/shop.dart, ../../domain/repositories/shop_repository.dart, getShop, shopKey, ShopRepositoryImpl (+10 more)

### Community 26 - "Shop Model (Hive)"
Cohesion: 0.10
Nodes (22): _DrawerItem, _ProfileHeader, build, InputLabel, text, DashboardPage, _DashboardView, _formatCurrency (+14 more)

### Community 27 - "Auth Gate & Login"
Cohesion: 0.12
Nodes (15): hashCode, operator, read, typeId, write, int get, addressLine1, addressLine2 (+7 more)

### Community 28 - "Low Stock Page"
Cohesion: 0.18
Nodes (9): ../error/failure.dart, call, NoParams, addCategory, deleteCategory, getCategories, updateCategory, package:billing_app/features/category/domain/entities/category.dart (+1 more)

### Community 29 - "Memory Session Log"
Cohesion: 0.11
Nodes (20): LoadDailySales, LoadSalesRange, build, _buildBarChart, _buildDateNavigation, _buildStatCard, _buildStatCards, createState (+12 more)

### Community 30 - "Auth User Model & Repo"
Cohesion: 0.22
Nodes (8): authStateChanges, getCurrentUser, login, loginWithGoogle, logout, signUp, updateProfile, Stream

### Community 31 - "Register Page"
Cohesion: 0.18
Nodes (10): _confirmPasswordController, createState, dispose, _emailController, _formKey, _isLoading, _nameController, _obscureConfirmPassword (+2 more)

### Community 32 - "Product Entity"
Cohesion: 0.17
Nodes (12): LoginPage, RegisterPage, HomePage, EditProductPage, ProductListPage, BillHistoryPage, _buildCard, createState (+4 more)

### Community 33 - "Report State"
Cohesion: 0.13
Nodes (14): barcode, categoryId, copyWith, createdAt, description, id, imageUrl, location (+6 more)

### Community 34 - "iOS Runner"
Cohesion: 0.12
Nodes (15): BillSummaryModel, BillSummary, billDetail, billHistory, copyWith, currentPage, dailySales, error (+7 more)

### Community 35 - "Auth Router Guard"
Cohesion: 0.20
Nodes (9): _buildBillCard, createState, _datePickerButton, _fromDate, initState, _selectDate, _toDate, package:billing_app/features/report/presentation/bloc/report_bloc.dart (+1 more)

### Community 36 - "Hive Database Core"
Cohesion: 0.15
Nodes (10): Any, Bool, Flutter, FlutterAppDelegate, AppDelegate, RunnerTests, UIApplication, UIKit (+2 more)

### Community 37 - "App Drawer & Widgets"
Cohesion: 0.17
Nodes (11): dart:async, _createProfile, _extractErrorMessage, _fetchProfile, getCurrentUser, login, loginWithGoogle, logout (+3 more)

### Community 38 - "Add Product Page"
Cohesion: 0.15
Nodes (13): core/theme/app_theme.dart, build, createState, dispose, initState, product, _qrDataController, QrGeneratorPage (+5 more)

### Community 39 - "Checkout Page"
Cohesion: 0.23
Nodes (17): AddProductToCartEvent, BillingEvent, BillingState, ClearStockErrorsEvent, PrintReceiptEvent, RemoveProductFromCartEvent, ScanBarcodeEvent, SetDiscountTypeEvent (+9 more)

### Community 40 - "Community 40"
Cohesion: 0.17
Nodes (11): ../../domain/repositories/product_repository.dart, addProduct, deleteProduct, _fromMap, getCurrentStockBulk, getProductByBarcode, getProducts, getProductsByCategory (+3 more)

### Community 41 - "Community 41"
Cohesion: 0.14
Nodes (13): ../../features/product/data/models/product_model.dart, ../../features/shop/data/models/shop_model.dart, HiveDatabase, init, productBox, productBoxName, settingsBox, settingsBoxName (+5 more)

### Community 42 - "Community 42"
Cohesion: 0.18
Nodes (21): AppDrawer, AuthBloc, AuthEvent, CheckAuthStatus, email, GoogleLoginRequested, LoginRequested, LogoutRequested (+13 more)

### Community 43 - "Community 43"
Cohesion: 0.14
Nodes (13): _barcode, build, _categoryId, createState, _description, _formKey, _imageUrl, _location (+5 more)

### Community 44 - "Community 44"
Cohesion: 0.09
Nodes (22): ../bloc/product_bloc.dart, ../../../category/presentation/bloc/category_bloc.dart, ../../../../core/utils/app_validators.dart, build, _categoryId, createState, _description, _formKey (+14 more)

### Community 45 - "Community 45"
Cohesion: 0.12
Nodes (24): Bloc, AddCategory, CategoryEvent, CategoryState, DeleteCategory, LoadCategories, UpdateCategory, CategoryBloc (+16 more)

### Community 46 - "Community 46"
Cohesion: 0.14
Nodes (13): EdgeInsetsGeometry, borderRadius, build, elevation, icon, isFullWidth, isLoading, label (+5 more)

### Community 47 - "Community 47"
Cohesion: 0.22
Nodes (8): FormState, createState, dispose, _emailController, _formKey, _isLoading, _obscurePassword, _passwordController

### Community 48 - "Community 48"
Cohesion: 0.18
Nodes (10): BillItemModel, DailySalesModel, fromJson, fromSupabaseRow, StockMovementModel, toJson, BillItem, DailySales (+2 more)

### Community 49 - "Community 49"
Cohesion: 0.18
Nodes (10): getBillDetail, getBillHistory, getDailySales, getLowStockProducts, getSalesRange, getStockMovements, _supabase, package:billing_app/core/supabase/supabase_client.dart (+2 more)

### Community 50 - "Community 50"
Cohesion: 0.14
Nodes (14): _applyThreshold, build, createState, dispose, _formatCurrency, initState, LowStockPage, _LowStockPageState (+6 more)

### Community 51 - "Community 51"
Cohesion: 0.18
Nodes (11): add_edit_category_dialog.dart, ../bloc/category_bloc.dart, build, CategoryListPage, _CategoryListPageState, createState, dispose, _openAddEditDialog (+3 more)

### Community 52 - "Community 52"
Cohesion: 0.18
Nodes (11): 2A — Categories ✅, 2B — Products (Inventory) ✅, 2C — Billing (Enhanced) ✅, Phase 0 — Foundation ✅ (Complete), Phase 1 — Database & Auth 🏗️ ✅, Phase 2 — Core Features 🔧 ✅, Phase 3 — Real-time & Multi-user 🔄 ✅, Phase 4.5 — Dashboard & Navigation UX ✅ (+3 more)

### Community 53 - "Community 53"
Cohesion: 0.17
Nodes (11): connecting,
  connected,
  connectionFailure,
  disconnected,, connectedMac, connectedName, copyWith, devices, errorMessage, PrinterState, PrinterStatus (+3 more)

### Community 54 - "Community 54"
Cohesion: 0.32
Nodes (12): ReportBloc, LoadBillDetail, LoadBillHistory, LoadLowStockProducts, LoadStockMovements, ReportEvent, ResetReport, _BillHistoryPageState (+4 more)

### Community 55 - "Community 55"
Cohesion: 0.17
Nodes (11): 🤝 Contributing Guidelines, Core Features:, 📁 File Structure, 🚀 Getting Started, Installation, 🛒 Mobile POS & Billing App, Prerequisites, 🎯 Project Scope (+3 more)

### Community 56 - "Community 56"
Cohesion: 0.18
Nodes (10): bool get, _channels, dispose, _isConnected, RealtimeService, subscribeToProducts, subscribeToTable, unsubscribe (+2 more)

### Community 57 - "Community 57"
Cohesion: 0.19
Nodes (20): AddProduct, DeleteProduct, FilterByCategory, GenerateQrCode, InitRealtime, LoadProducts, ProductEvent, ProductsRealtimeUpdated (+12 more)

### Community 58 - "Community 58"
Cohesion: 0.18
Nodes (10): AppTheme, backgroundColor, errorColor, primaryColor, secondaryColor, surfaceColor, textTheme, package:google_fonts/google_fonts.dart (+2 more)

### Community 59 - "Community 59"
Cohesion: 0.17
Nodes (12): build, controller, _corner, createState, dispose, _isScanned, _onDetect, ScannerPage (+4 more)

### Community 60 - "Community 60"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 61 - "Community 61"
Cohesion: 0.20
Nodes (10): Architecture, Database: Supabase (PostgreSQL), Dependency Injection, High-Level Overview, Navigation, Offline Strategy, Project Structure, Real-time Sync (+2 more)

### Community 62 - "Community 62"
Cohesion: 0.20
Nodes (10): Architecture, AUTO-PILOT MODE — No Questions, Just Execute 🤖⚡, Build Commands, CLAUDE.md — Flutter Billing App, CRITICAL — Parallel Work Rule ⚡⚡, CRITICAL — Update Rule ⚡, Key Files & Their Use Cases, Project (+2 more)

### Community 63 - "Community 63"
Cohesion: 0.17
Nodes (11): core/supabase/supabase_client.dart, ../../domain/repositories/category_repository.dart, addCategory, CategoryRepositoryImpl, deleteCategory, getCategories, _supabase, updateCategory (+3 more)

### Community 64 - "Community 64"
Cohesion: 0.22
Nodes (8): double get, CartItem, copyWith, product, props, quantity, total, package:billing_app/features/product/domain/entities/product.dart

### Community 65 - "Community 65"
Cohesion: 0.25
Nodes (7): copyWith, email, id, name, props, role, package:equatable/equatable.dart

### Community 66 - "Community 66"
Cohesion: 0.22
Nodes (8): Color, IconData?, build, color, icon, label, StatCard, value

### Community 67 - "Community 67"
Cohesion: 0.31
Nodes (9): Authenticated, AuthError, AuthInitial, AuthLoading, AuthState, message, props, Unauthenticated (+1 more)

### Community 68 - "Community 68"
Cohesion: 0.22
Nodes (8): addressLine1, addressLine2, copyWith, footerText, name, phoneNumber, props, upiId

### Community 69 - "Community 69"
Cohesion: 0.22
Nodes (8): call, email, name, password, props, repository, SignUpParams, SignUpUseCase

### Community 70 - "Community 70"
Cohesion: 0.22
Nodes (5): Design, Layout Considerations, Screens, Theme, Typography

### Community 71 - "Community 71"
Cohesion: 0.25
Nodes (7): copyWith, createdAt, description, id, name, props, String?

### Community 72 - "Community 72"
Cohesion: 0.18
Nodes (10): ../../domain/entities/product.dart, ProductRepositoryImpl, addProduct, deleteProduct, getCurrentStockBulk, getProductByBarcode, getProducts, getProductsByCategory (+2 more)

### Community 73 - "Community 73"
Cohesion: 0.25
Nodes (7): _anonKey, client, initialize, SupabaseConfig, _url, package:supabase_flutter/supabase_flutter.dart, static SupabaseClient get

### Community 74 - "Community 74"
Cohesion: 0.13
Nodes (21): build, build, build, _buildScannerSection, build, _buildQuickTiles, build, build (+13 more)

### Community 75 - "Community 75"
Cohesion: 0.40
Nodes (4): package:billing_app/main.dart, package:flutter/material.dart, package:flutter_test/flutter_test.dart, main

### Community 76 - "Community 76"
Cohesion: 0.29
Nodes (8): @HiveType, ProductModelAdapter, ShopModelAdapter, ProductModel, Product, ShopModel, Shop, TypeAdapter

### Community 77 - "Community 77"
Cohesion: 0.25
Nodes (7): call, email, LoginParams, LoginUseCase, password, props, repository

### Community 78 - "Community 78"
Cohesion: 0.22
Nodes (8): ReportRepositoryImpl, getBillDetail, getBillHistory, getDailySales, getLowStockProducts, getSalesRange, getStockMovements, ReportRepository

### Community 79 - "Community 79"
Cohesion: 0.25
Nodes (7): bill, BillDetailPage, build, _buildInfoCard, _infoRow, package:billing_app/core/widgets/primary_button.dart, package:intl/intl.dart

### Community 80 - "Community 80"
Cohesion: 0.25
Nodes (8): 1. Categories (Dynamic), 2. Product Inventory, 3. Billing (Point of Sale), 4. Real-time Sync (Supabase), 5. Shelf / Location Tracking, 6. QR Code Generator, 7. Reports & History, Core Features

### Community 81 - "Community 81"
Cohesion: 0.33
Nodes (5): fromJson, fromProfileJson, fromSupabaseAuth, toJson, package:billing_app/features/auth/domain/entities/user.dart

### Community 82 - "Community 82"
Cohesion: 0.38
Nodes (6): CacheFailure, Failure, message, props, ServerFailure, List

### Community 83 - "Community 83"
Cohesion: 0.29
Nodes (6): ../../core/widgets/app_drawer.dart, AppShell, build, child, package:go_router/go_router.dart, Widget

### Community 84 - "Community 84"
Cohesion: 0.22
Nodes (9): Buttons (PrimaryButton), Cards, Component Specs, Dashboard Screen, DashboardActionCard (`lib/core/widgets/dashboard_action_card.dart`), Icons, Input Fields, Scanner Screen (+1 more)

### Community 85 - "Community 85"
Cohesion: 0.29
Nodes (6): Client Profile, Constraints, RPD — Requirements & Product Definition, Target Platforms, Tech Stack Changes, User Roles

### Community 86 - "Community 86"
Cohesion: 0.17
Nodes (11): Code Quality, Database Rules, Development Rules, Git Rules, Graphify Rules, Naming Conventions, Parallel Work Rule (CRITICAL — Speed), Project Rules (+3 more)

### Community 88 - "Community 88"
Cohesion: 0.40
Nodes (5): 1. Presentation Layer, 2. Domain Layer, 3. Data Layer, Architecture Pattern: **Clean Architecture + BLoC + Supabase**, Layers

## Knowledge Gaps
- **783 isolated node(s):** `XCTest`, `rootNavigatorKey`, `child`, `build`, `HiveDatabase` (+778 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **6 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `AuthBloc` connect `Community 42` to `Billing Bloc & State`, `Community 67`, `Repositories & Service Locator`, `Category Bloc & Usecases`, `Auth Bloc`, `Community 74`, `Community 45`, `Product Model (Hive)`, `Community 47`, `Shop Model (Hive)`, `Register Page`?**
  _High betweenness centrality (0.037) - this node is a cross-community bridge._
- **Why does `Product` connect `Community 76` to `Community 64`, `Report State`, `Billing Bloc & State`, `Product Bloc & Realtime`, `Add Product Page`, `Community 44`, `Report Bloc`?**
  _High betweenness centrality (0.025) - this node is a cross-community bridge._
- **Why does `ProductModel` connect `Community 76` to `Community 41`, `Report Usecase Params`?**
  _High betweenness centrality (0.019) - this node is a cross-community bridge._
- **What connects `XCTest`, `rootNavigatorKey`, `child` to the rest of the system?**
  _783 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Printer Helper (ESC/POS)` be split into smaller, more focused modules?**
  _Cohesion score 0.07948717948717948 - nodes in this community are weakly interconnected._
- **Should `Printer Bloc & Settings` be split into smaller, more focused modules?**
  _Cohesion score 0.04343971631205674 - nodes in this community are weakly interconnected._
- **Should `Billing Bloc & State` be split into smaller, more focused modules?**
  _Cohesion score 0.044444444444444446 - nodes in this community are weakly interconnected._