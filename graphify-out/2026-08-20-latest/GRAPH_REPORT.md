# Graph Report - .  (2026-08-20)

## Corpus Check
- Large corpus: 223 files · ~1,462,504 words. Semantic extraction will be expensive (many Claude tokens). Consider running on a subfolder.

## Summary
- 2389 nodes · 3853 edges · 122 communities (119 shown, 3 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- Billing Cart & Checkout
- Warranty Claims
- Shop & Settings
- Stock & Category BLoC
- Receipt Printer Utils
- Printer BLoC & Theme
- Dashboard Widgets
- Bill History UI
- Audit BLoC & Timeline
- Staff BLoC & Auth
- Text Styles & Theme
- Product List & CSV
- Due Payments BLoC
- Auth Repository & UseCases
- Product BLoC & Realtime
- Report Domain Entities
- Daily Sales Page
- Product Coverflow View
- Receipt Preview Page
- Bill Detail Page
- Image Upload & Edit Product
- State Models & UseCases
- Stock Movement Page
- Category Entities & Add Product
- Product Events & Init
- App Drawer & Auth Bloc
- Product Model (Hive/Generated)
- Low Stock Page
- Category List & Dialog
- Billing Home & Product Repo
- Equatable & Models
- Dashboard Page
- Billing Events
- Service Locator
- App Routes & Config
- Printer Repository
- Product Coverflow Items
- App Theme & Colors
- Migration SQL
- Billing State & Cart
- Warranty Claims Page
- Product CRUD Events
- Shop BLoC State
- Auth Events & State
- Warranty Repository
- Staff List & Add Page
- Report Repository
- Product UseCases
- Shop Repository
- Staff Repository
- Staff Performance Card
- Category Repository
- Billing Bloc Logic
- Report BLoC
- Auth Repository
- Product Repository
- Audit Repository
- Audit Timeline Page
- Product Detail Page
- Dashboard Analytics
- Graph Report
- Login & Register UI
- Billing UseCases
- Dashboard Action Cards
- Report UseCases
- Product Edit Page
- Due Payment Entity
- Audit Log Entity
- Report BLoC State
- Stock BLoC
- Staff BLoC
- Dashboard Trend Cards
- Design Doc
- RPD Doc
- Warranty UseCases
- Shop Details Page
- Auth BLoC
- Staff Add Page
- Shop Model
- Deep Link Config
- Shop Register
- Product BLoC Events
- Product Add Page
- Audit Events & State
- Printer Helper
- Shop BLoC
- Auth State
- AGENTS.md
- Product Events
- Shop Repository Impl
- Staff BLoC Events
- Billing Repository
- Report BLoC Events
- Shop UseCases
- Product Data Models
- Audit BLoC
- Staff BLoC State
- Warranty BLoC
- Product Data Model
- Shop BLoC Events
- App Text Styles
- Category BLoC
- Auth BLoC Events
- Product Image Utils
- Product Repository Impl
- Warranty Repository Impl
- Billing Repository Impl
- Category BLoC Events
- Auth Events
- Report BLoC Events
- Billing Events
- Hive Database
- Report Repository Impl
- Report BLoC
- Bill History Data
- Memory Doc
- Phases Doc
- Supabase Config

## God Nodes (most connected - your core abstractions)
1. `AuthBloc` - 65 edges
2. `ReportBloc` - 53 edges
3. `ProductBloc` - 47 edges
4. `BillingBloc` - 37 edges
5. `CategoryBloc` - 30 edges
6. `UseCase` - 29 edges
7. `BillingEvent` - 21 edges
8. `ShopBloc` - 20 edges
9. `PrinterBloc` - 16 edges
10. `AuditBloc` - 15 edges

## Surprising Connections (you probably didn't know these)
- `createRouter` --references--> `AuthBloc`  [EXTRACTED]
  lib/config/routes/app_routes.dart → lib/features/auth/presentation/bloc/auth_bloc.dart
- `_onResend` --references--> `AuthBloc`  [EXTRACTED]
  lib/features/auth/presentation/pages/email_verification_page.dart → lib/features/auth/presentation/bloc/auth_bloc.dart
- `build` --references--> `AuthBloc`  [EXTRACTED]
  lib/features/report/presentation/pages/bill_detail_page.dart → lib/features/auth/presentation/bloc/auth_bloc.dart
- `_showProductSearchDialog` --references--> `AuthBloc`  [EXTRACTED]
  lib/features/report/presentation/pages/bill_detail_page.dart → lib/features/auth/presentation/bloc/auth_bloc.dart
- `_showEditPriceDialog` --references--> `BillingBloc`  [EXTRACTED]
  lib/features/billing/presentation/pages/checkout_page.dart → lib/features/billing/presentation/bloc/billing_bloc.dart

## Import Cycles
- None detected.

## Communities (122 total, 3 thin omitted)

### Community 0 - "Billing Cart & Checkout"
Cohesion: 0.03
Nodes (68): address1, address2, barcode, billId, cartItems, copyWith, customPrice, discountIsPercentage (+60 more)

### Community 1 - "Warranty Claims"
Cohesion: 0.05
Nodes (52): ../bloc/warranty_bloc.dart, billId, claimId, claimReason, claims, claimType, copyWith, CreateWarrantyClaim (+44 more)

### Community 2 - "Shop & Settings"
Cohesion: 0.06
Nodes (49): ../bloc/shop_bloc.dart, ../../../../core/usecase/usecase.dart, LoadShopEvent, message, ShopError, ShopEvent, ShopInitial, ShopLoaded (+41 more)

### Community 3 - "Stock & Category BLoC"
Cohesion: 0.05
Nodes (44): Bloc, ../../../category/presentation/bloc/category_bloc.dart, adjustments, AdjustStock, copyWith, LoadAllAdjustments, LoadStockHistory, message (+36 more)

### Community 4 - "Receipt Printer Utils"
Cohesion: 0.05
Nodes (43): ../../../../core/utils/printer_helper.dart, alignCenter, alignLeft, alignRight, boldOff, boldOn, checkPermission, connect (+35 more)

### Community 5 - "Printer BLoC & Theme"
Cohesion: 0.07
Nodes (41): ../bloc/printer_bloc.dart, ../bloc/printer_event.dart, ../bloc/printer_state.dart, core/theme/theme_cubit.dart, Cubit, ../../domain/repositories/printer_repository.dart, ThemeCubit, _onConnect (+33 more)

### Community 6 - "Dashboard Widgets"
Cohesion: 0.05
Nodes (43): appBarTheme, buildActions, _buildDescriptionSnippet, buildLeading, _buildLoadingPlaceholder, buildResults, _buildSearchResults, buildSuggestions (+35 more)

### Community 7 - "Bill History UI"
Cohesion: 0.05
Nodes (43): _applyDateRange, _buildBillCard, _buildBillComparison, _buildPaymentPieChart, _buildPaymentStatusBadge, _buildQuickDateFilters, _buildSalesTrend, _buildStaffFilterItems (+35 more)

### Community 8 - "Audit BLoC & Timeline"
Cohesion: 0.05
Nodes (42): app_shell.dart, ChangeNotifier, ../../features/audit/presentation/bloc/audit_bloc.dart, ../../features/audit/presentation/bloc/audit_event.dart, ../../features/audit/presentation/pages/audit_timeline_page.dart, ../../features/auth/presentation/pages/email_verification_page.dart, ../../features/auth/presentation/pages/login_page.dart, ../../features/auth/presentation/pages/register_page.dart (+34 more)

### Community 9 - "Staff BLoC & Auth"
Cohesion: 0.07
Nodes (39): ../bloc/staff_bloc.dart, copyWith, DeleteStaffMember, id, LoadStaff, message, staff, StaffEvent (+31 more)

### Community 10 - "Text Styles & Theme"
Cohesion: 0.05
Nodes (41): Brightness, Color get, actionCardSubtitle, actionCardTitle, AdaptiveTextStyles, AppTextStyles, _brightness, greetingDate (+33 more)

### Community 11 - "Product List & CSV"
Cohesion: 0.05
Nodes (41): ../../../../core/utils/csv_export_import.dart, _addToBillButton, allProducts, build, _buildProductTile, _buildStatsBar, categories, _copyBarcode (+33 more)

### Community 12 - "Due Payments BLoC"
Cohesion: 0.08
Nodes (36): amount, billId, CollectPayment, copyWith, duePayments, DuePaymentsEvent, DuePaymentsState, error (+28 more)

### Community 13 - "Auth Repository & UseCases"
Cohesion: 0.06
Nodes (35): ../../features/audit/data/repositories/audit_repository_impl.dart, ../../features/audit/domain/repositories/audit_repository.dart, ../../features/auth/data/repositories/auth_repository_impl.dart, ../../features/auth/domain/usecases/get_current_user_usecase.dart, ../../features/auth/domain/usecases/login_usecase.dart, ../../features/auth/domain/usecases/login_with_google_usecase.dart, ../../features/auth/domain/usecases/logout_usecase.dart, ../../features/auth/domain/usecases/signup_usecase.dart (+27 more)

### Community 14 - "Product BLoC & Realtime"
Cohesion: 0.06
Nodes (33): ../../../../core/realtime/realtime_service.dart, categoryId, changeType, copyWith, filteredProducts, id, message, payload (+25 more)

### Community 15 - "Report Domain Entities"
Cohesion: 0.06
Nodes (33): amountPaid, averageBill, billCount, changeType, copyWith, createdAt, customerName, customerPhone (+25 more)

### Community 16 - "Daily Sales Page"
Cohesion: 0.06
Nodes (32): _applyTimeRange, build, _buildBarChart, _buildBestSelling, _buildDateNav, _buildHourlyHeatmap, _buildPaymentSplit, _buildStatCards (+24 more)

### Community 17 - "Product Coverflow View"
Cohesion: 0.07
Nodes (30): ../bloc/product_bloc.dart, _actionBtn, _allDialKey, _badge, _bottomPanel, build, categoryName, categoryNames (+22 more)

### Community 18 - "Receipt Preview Page"
Cohesion: 0.07
Nodes (29): GlobalKey, address1, address2, amountPaid, billId, cartItems, createState, customerName (+21 more)

### Community 19 - "Bill Detail Page"
Cohesion: 0.07
Nodes (29): LoadBillDetail, _actionBtn, bill, BillDetailPage, _BillDetailPageState, build, _buildCustomerHistory, _buildInfoCard (+21 more)

### Community 20 - "Image Upload & Edit Product"
Cohesion: 0.07
Nodes (28): ../../../../core/utils/image_compress.dart, ../../../../core/utils/image_upload_service.dart, _barcodeController, build, _categoryId, createState, _description, dispose (+20 more)

### Community 21 - "State Models & UseCases"
Cohesion: 0.09
Nodes (28): BillingState, ProductState, Equatable, BillDetailParams, BillHistoryParams, billId, call, changeType (+20 more)

### Community 22 - "Stock Movement Page"
Cohesion: 0.07
Nodes (28): _animController, build, _buildDateButton, _buildDateRange, _buildEmptyState, _buildGroupedCard, _buildMovementCard, _buildStaffAndGroupControls (+20 more)

### Community 23 - "Category Entities & Add Product"
Cohesion: 0.07
Nodes (27): ../../../category/domain/entities/category.dart, File?, AddProductPage, _AddProductPageState, _barcodeController, build, _categoryId, createState (+19 more)

### Community 24 - "Product Events & Init"
Cohesion: 0.12
Nodes (28): AddProduct, DeleteProduct, FilterByCategory, GenerateQrCode, InitRealtime, LoadProducts, ProductEvent, ProductsRealtimeUpdated (+20 more)

### Community 25 - "App Drawer & Auth Bloc"
Cohesion: 0.14
Nodes (27): AppDrawer, AuthBloc, AuthEvent, CheckAuthStatus, email, GoogleLoginRequested, LoginRequested, LogoutRequested (+19 more)

### Community 26 - "Product Model (Hive/Generated)"
Cohesion: 0.07
Nodes (26): hashCode, operator, read, typeId, write, barcode, categoryId, createdAt (+18 more)

### Community 27 - "Low Stock Page"
Cohesion: 0.08
Nodes (25): Animation, _animatedCount, _animController, _applyThreshold, build, _buildCategoryChips, _buildEmptyState, _buildFilterSection (+17 more)

### Community 28 - "Category List & Dialog"
Cohesion: 0.08
Nodes (24): add_edit_category_dialog.dart, AnimationController, _buildEmptySearch, _buildEmptyState, _buildStatsCard, _categoryCard, _confirmSwipeDelete, createState (+16 more)

### Community 29 - "Billing Home & Product Repo"
Cohesion: 0.08
Nodes (24): ../../../billing/presentation/bloc/billing_bloc.dart, ../../../../features/product/domain/repositories/product_repository.dart, ../../../../features/product/domain/usecases/product_usecases.dart, build, _buildBottomPanel, _buildCameraOffState, _buildCorner, _buildEmptyCart (+16 more)

### Community 30 - "Equatable & Models"
Cohesion: 0.16
Nodes (25): AddProductToCartEvent, BillingEvent, ClearStockErrorsEvent, PrintReceiptEvent, _ProductStockUpdatedEvent, RemoveProductFromCartEvent, ScanBarcodeEvent, SetDiscountTypeEvent (+17 more)

### Community 31 - "Dashboard Page"
Cohesion: 0.09
Nodes (21): Color, IconData?, AppBackButton, icon, size, build, color, DashboardActionCard (+13 more)

### Community 32 - "Billing Events"
Cohesion: 0.08
Nodes (23): categories, CategoryState, CategoryStatus, colorValue, copyWith, description, iconCodePoint, id (+15 more)

### Community 33 - "Service Locator"
Cohesion: 0.09
Nodes (21): _loadThemeMode, setThemeMode, toggleTheme, currentRoute, _DrawerItem, icon, _initials, label (+13 more)

### Community 34 - "App Routes & Config"
Cohesion: 0.08
Nodes (23): authRepository, _authSubscription, close, getCurrentUserUseCase, _isLoggingOut, loginUseCase, loginWithGoogleUseCase, logoutUseCase (+15 more)

### Community 35 - "Printer Repository"
Cohesion: 0.10
Nodes (21): ../bloc/billing_bloc.dart, ClearCartEvent, UpdatePaymentMethodEvent, ../../domain/entities/cart_item.dart, _amountPaidController, build, _buildDataCell, _buildHeaderCell (+13 more)

### Community 36 - "Product Coverflow Items"
Cohesion: 0.12
Nodes (21): class, ../entities/product.dart, UseCase, AddProductUseCase, call, DeleteProductUseCase, GetCurrentStockBulkUseCase, GetProductByBarcodeUseCase (+13 more)

### Community 37 - "App Theme & Colors"
Cohesion: 0.09
Nodes (21): aiGradient, AppTheme, backgroundColor, _baseInputTheme, darkBackground, darkBorder, darkCard, darkGradient (+13 more)

### Community 38 - "Migration SQL"
Cohesion: 0.09
Nodes (21): _bottomPad, build, _buildPlaceholder, _buildStatChip, _buildStatsRow, dotFillColor, _formatCurrency, _hasData (+13 more)

### Community 39 - "Billing State & Cart"
Cohesion: 0.09
Nodes (21): _buildEmptyState, _buildFilters, _buildSearch, _buildTimelineItem, _buildValueDiff, createState, _dateKey, dispose (+13 more)

### Community 40 - "Warranty Claims Page"
Cohesion: 0.09
Nodes (21): barcode, categoryId, copyWith, createdAt, description, hasWarranty, id, imageUrl (+13 more)

### Community 41 - "Product CRUD Events"
Cohesion: 0.09
Nodes (21): authBloc, deleteBillUseCase, getBillDetailUseCase, getBillHistoryUseCase, getDailySalesUseCase, getLowStockProductsUseCase, getSalesRangeUseCase, getStockMovementsUseCase (+13 more)

### Community 42 - "Shop BLoC State"
Cohesion: 0.10
Nodes (19): core/data/hive_database.dart, core/supabase/supabase_client.dart, ../../domain/repositories/product_repository.dart, addProduct, deleteProduct, _fromMap, getCurrentStockBulk, getProductByBarcode (+11 more)

### Community 43 - "Auth Events & State"
Cohesion: 0.10
Nodes (20): core/utils/beep_helper.dart, build, _buildPermissionPrompt, _cameraStatus, _checkPermission, controller, _corner, createState (+12 more)

### Community 44 - "Warranty Repository"
Cohesion: 0.10
Nodes (19): int?, billId, claimedByStaffId, claimReason, claimStatus, claimType, copyWith, createdAt (+11 more)

### Community 45 - "Staff List & Add Page"
Cohesion: 0.11
Nodes (18): ../../../auth/presentation/bloc/auth_bloc.dart, ../../../auth/presentation/bloc/auth_event.dart, ../../../auth/presentation/bloc/auth_state.dart, ../../../../core/widgets/input_label.dart, ../../../../core/widgets/primary_button.dart, AddStaffPage, _AddStaffPageState, build (+10 more)

### Community 46 - "Report Repository"
Cohesion: 0.11
Nodes (18): double get, CartItem, copyWith, customPrice, effectiveWarrantyDuration, effectiveWarrantyType, effectiveWarrantyUnit, hasWarranty (+10 more)

### Community 47 - "Product UseCases"
Cohesion: 0.12
Nodes (17): _, DeepLinkConfig, emailRedirectTo, host, scheme, _anonKey, client, initialize (+9 more)

### Community 48 - "Shop Repository"
Cohesion: 0.12
Nodes (16): ../../../../core/error/failure.dart, ../../domain/entities/stock_adjustment.dart, ../../domain/repositories/stock_repository.dart, ../entities/stock_adjustment.dart, adjustStock, _fromMap, getAllAdjustments, getStockHistory (+8 more)

### Community 49 - "Staff Repository"
Cohesion: 0.11
Nodes (17): build, _buildEmptyState, _buildPaymentBadge, _buildTransactionItem, createdAt, _formatCurrency, grandTotal, id (+9 more)

### Community 50 - "Staff Performance Card"
Cohesion: 0.11
Nodes (17): copyWith, email, emailConfirmedAt, fromString, id, isEmailConfirmed, isOwner, isStaff (+9 more)

### Community 51 - "Category Repository"
Cohesion: 0.12
Nodes (16): ../bloc/category_bloc.dart, ../../../../core/utils/app_validators.dart, AddEditCategoryDialog, build, category, _categoryColors, _categoryIcons, createState (+8 more)

### Community 52 - "Billing Bloc Logic"
Cohesion: 0.12
Nodes (16): config/routes/app_routes.dart, core/service_locator.dart, features/auth/domain/repositories/auth_repository.dart, features/auth/presentation/bloc/auth_event.dart, features/billing/presentation/bloc/billing_bloc.dart, features/category/presentation/bloc/category_bloc.dart, features/product/presentation/bloc/product_bloc.dart, features/report/presentation/bloc/report_bloc.dart (+8 more)

### Community 53 - "Report BLoC"
Cohesion: 0.23
Nodes (17): AddCategory, CategoryEvent, DeleteCategory, LoadCategories, UpdateCategory, CategoryBloc, _AddEditCategoryDialogState, _onSave (+9 more)

### Community 54 - "Auth Repository"
Cohesion: 0.12
Nodes (16): hashCode, operator, read, typeId, write, int get, addressLine1, addressLine2 (+8 more)

### Community 55 - "Product Repository"
Cohesion: 0.12
Nodes (15): dart:io, ../../../../features/product/domain/entities/product.dart, CsvExportImport, exportProducts, importProducts, compressImage, compressImageAsBytes, getCompressedSizeKB (+7 more)

### Community 56 - "Audit Repository"
Cohesion: 0.12
Nodes (16): action, AuditLog, copyWith, createdAt, description, entityId, entityName, entityType (+8 more)

### Community 57 - "Audit Timeline Page"
Cohesion: 0.12
Nodes (16): AuditState, AuditStatus, copyWith, currentPage, entityLogs, error, hasMore, lastFilterAction (+8 more)

### Community 58 - "Product Detail Page"
Cohesion: 0.26
Nodes (17): ReportBloc, DeleteBill, LoadBillHistory, LoadDailySales, LoadLowStockProducts, LoadSalesRange, LoadStockMovements, ReportEvent (+9 more)

### Community 59 - "Dashboard Analytics"
Cohesion: 0.13
Nodes (15): core/theme/app_theme.dart, _ProductSearchDelegate, Product, build, createState, dispose, initState, product (+7 more)

### Community 60 - "Graph Report"
Cohesion: 0.12
Nodes (15): build, _buildEmptyState, _buildGlassContainer, _buildStatChip, _buildStatsRow, currencyPrefix, _formatShort, _gridInterval (+7 more)

### Community 61 - "Login & Register UI"
Cohesion: 0.19
Nodes (15): UserModel, User, Authenticated, AuthError, AuthInitial, AuthLoading, AuthState, email (+7 more)

### Community 62 - "Billing UseCases"
Cohesion: 0.16
Nodes (13): AuthRepositoryImpl, AuthRepository, call, GetCurrentUserUseCase, repository, call, LoginWithGoogleUseCase, repository (+5 more)

### Community 63 - "Dashboard Action Cards"
Cohesion: 0.16
Nodes (15): build, build, _buildQuickActions, _buildQuickStats, _featureCard, _quickAction, ReportsHomePage, _statItem (+7 more)

### Community 64 - "Report UseCases"
Cohesion: 0.13
Nodes (14): collectPayment, DuePaymentsRepositoryImpl, getBillForDuePayment, getDuePayments, getTotalPendingDue, _resolveShopId, _supabase, collectPayment (+6 more)

### Community 65 - "Product Edit Page"
Cohesion: 0.12
Nodes (15): billDetail, billHistory, copyWith, currentPage, dailySales, error, hasMorePages, lowStockProducts (+7 more)

### Community 66 - "Due Payment Entity"
Cohesion: 0.13
Nodes (14): dart:math, dart:typed_data, BeepHelper, _beepPath, dispose, _fileReady, _generateBeepWav, init (+6 more)

### Community 67 - "Audit Log Entity"
Cohesion: 0.13
Nodes (14): dart:ui, double?, blur, borderOpacity, borderRadius, build, child, GlassCard (+6 more)

### Community 68 - "Report BLoC State"
Cohesion: 0.14
Nodes (12): ../error/failure.dart, call, NoParams, addCategory, deleteCategory, getCategories, updateCategory, deleteStaffMember (+4 more)

### Community 69 - "Stock BLoC"
Cohesion: 0.14
Nodes (13): AuditRepositoryImpl, _fromJson, getAuditLogs, getEntityAuditLogs, logAction, _supabase, AuditRepository, getAuditLogs (+5 more)

### Community 70 - "Staff BLoC"
Cohesion: 0.13
Nodes (14): _createProfile, _ensureProfileRole, _ensureShopForOwner, _extractErrorMessage, _fetchProfile, getCurrentUser, login, loginWithGoogle (+6 more)

### Community 71 - "Dashboard Trend Cards"
Cohesion: 0.18
Nodes (15): HomePage, _DashboardView, _DashboardViewState, ProductCoverflowSkeleton, _ProductCoverflowSkeletonState, ProductListPage, BillHistoryPage, DailySalesPage (+7 more)

### Community 72 - "Design Doc"
Cohesion: 0.15
Nodes (10): Any, Bool, Flutter, FlutterAppDelegate, AppDelegate, RunnerTests, UIApplication, UIKit (+2 more)

### Community 73 - "RPD Doc"
Cohesion: 0.14
Nodes (13): EdgeInsetsGeometry, borderRadius, build, elevation, icon, isFullWidth, isLoading, label (+5 more)

### Community 74 - "Warranty UseCases"
Cohesion: 0.15
Nodes (12): ../entities/warranty_claim.dart, WarrantyRepositoryImpl, createClaim, getClaims, updateClaimStatus, WarrantyRepository, call, CreateWarrantyClaimUseCase (+4 more)

### Community 75 - "Shop Details Page"
Cohesion: 0.14
Nodes (13): ../../features/product/data/models/product_model.dart, ../../features/shop/data/models/shop_model.dart, HiveDatabase, init, productBox, productBoxName, settingsBox, settingsBoxName (+5 more)

### Community 76 - "Auth BLoC"
Cohesion: 0.15
Nodes (12): build, GreetingHeader, _monthName, userName, build, color, icon, label (+4 more)

### Community 77 - "Staff Add Page"
Cohesion: 0.14
Nodes (13): _avatarColor, billCount, build, _buildGlassContainer, _initial, name, revenue, _short (+5 more)

### Community 78 - "Shop Model"
Cohesion: 0.14
Nodes (13): action, description, entityId, entityName, entityType, from, newValue, oldValue (+5 more)

### Community 79 - "Deep Link Config"
Cohesion: 0.15
Nodes (13): _confirmPasswordController, createState, dispose, _emailController, _formKey, _isLoading, _nameController, _obscureConfirmPassword (+5 more)

### Community 80 - "Shop Register"
Cohesion: 0.14
Nodes (13): deleteBill, getBillDetail, getBillHistory, getDailySales, getLowStockProducts, getSalesRange, getStockMovements, _logAudit (+5 more)

### Community 81 - "Product BLoC Events"
Cohesion: 0.14
Nodes (13): billId, changeType, date, from, items, page, paymentMethod, productId (+5 more)

### Community 82 - "Product Add Page"
Cohesion: 0.14
Nodes (13): createdAt, createdBy, id, isIncrease, newStock, note, previousStock, productId (+5 more)

### Community 83 - "Audit Events & State"
Cohesion: 0.15
Nodes (12): audit_event.dart, audit_state.dart, auditRepository, authBloc, _onLoadAuditLogs, _onLoadEntityAuditLogs, _onLoadMoreAuditLogs, _onLogAuditAction (+4 more)

### Community 84 - "Printer Helper"
Cohesion: 0.15
Nodes (12): connecting,
  connected,
  connectionFailure,
  disconnected,, connectedMac, connectedName, copyWith, devices, errorMessage, PrinterState, PrinterStatus (+4 more)

### Community 85 - "Shop BLoC"
Cohesion: 0.15
Nodes (12): ../../core/widgets/app_drawer.dart, AppShell, build, child, build, build, build, build (+4 more)

### Community 86 - "Auth State"
Cohesion: 0.17
Nodes (12): FormState, build, createState, dispose, _emailController, _formKey, _isLoading, LoginPage (+4 more)

### Community 87 - "AGENTS.md"
Cohesion: 0.15
Nodes (12): build, _darkText, _EmptyState, _fmt, _glass, icon, _methodColor, paymentCounts (+4 more)

### Community 88 - "Product Events"
Cohesion: 0.15
Nodes (12): build, _glass, name, ProductAggregator, products, ProductSales, quantity, revenue (+4 more)

### Community 89 - "Shop Repository Impl"
Cohesion: 0.15
Nodes (12): call, email, emailRedirectTo, name, password, props, repository, role (+4 more)

### Community 90 - "Staff BLoC Events"
Cohesion: 0.15
Nodes (12): amountPaid, billDate, billId, copyWith, customerName, customerPhone, dueAmount, DuePayment (+4 more)

### Community 91 - "Billing Repository"
Cohesion: 0.15
Nodes (12): BillItemModel, BillSummaryModel, DailySalesModel, fromJson, fromSupabaseRow, StockMovementModel, toJson, BillItem (+4 more)

### Community 92 - "Report BLoC Events"
Cohesion: 0.17
Nodes (11): dart:async, createState, dispose, email, EmailVerificationPage, _isChecking, _isResending, _onResend (+3 more)

### Community 93 - "Shop UseCases"
Cohesion: 0.17
Nodes (11): ../../domain/repositories/category_repository.dart, addCategory, CategoryRepositoryImpl, deleteCategory, getCategories, _logAudit, _resolveShopId, _supabase (+3 more)

### Community 94 - "Product Data Models"
Cohesion: 0.17
Nodes (11): build, _buildGlassContainer, color, count, InventoryHealthCard, label, lowStockCount, onViewDetails (+3 more)

### Community 95 - "Audit BLoC"
Cohesion: 0.30
Nodes (12): AuditBloc, AuditEvent, LoadAuditLogs, LoadEntityAuditLogs, LoadMoreAuditLogs, LogAuditAction, ResetAuditLogs, AuditTimelinePage (+4 more)

### Community 96 - "Staff BLoC State"
Cohesion: 0.18
Nodes (10): ../../../auth/data/models/user_model.dart, ../../../auth/domain/entities/user.dart, ../../domain/repositories/staff_repository.dart, deleteStaffMember, getStaffMembers, _resolveShopId, StaffRepositoryImpl, _supabase (+2 more)

### Community 97 - "Warranty BLoC"
Cohesion: 0.27
Nodes (11): build, _buildQuickTiles, _confirmDelete, Route /categories, Route /due-payments, Route /products, Route /reports, Route /settings (+3 more)

### Community 98 - "Product Data Model"
Cohesion: 0.18
Nodes (10): ReportRepositoryImpl, deleteBill, getBillDetail, getBillHistory, getDailySales, getLowStockProducts, getSalesRange, getStockMovements (+2 more)

### Community 99 - "Shop BLoC Events"
Cohesion: 0.18
Nodes (10): addressLine1, addressLine2, copyWith, footerText, id, name, phoneNumber, props (+2 more)

### Community 100 - "App Text Styles"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 101 - "Category BLoC"
Cohesion: 0.20
Nodes (9): DateTime, colorValue, copyWith, createdAt, description, iconCodePoint, id, name (+1 more)

### Community 102 - "Auth BLoC Events"
Cohesion: 0.20
Nodes (9): authStateChanges, getCurrentUser, login, loginWithGoogle, logout, resendVerificationEmail, signUp, updateProfile (+1 more)

### Community 103 - "Product Image Utils"
Cohesion: 0.22
Nodes (8): bool get, _channels, dispose, _isConnected, RealtimeService, subscribeToProducts, subscribeToTable, unsubscribe

### Community 104 - "Product Repository Impl"
Cohesion: 0.22
Nodes (8): ../../domain/entities/product.dart, addProduct, deleteProduct, getCurrentStockBulk, getProductByBarcode, getProducts, getProductsByCategory, updateProduct

### Community 105 - "Warranty Repository Impl"
Cohesion: 0.22
Nodes (8): ../../domain/entities/warranty_claim.dart, ../../domain/repositories/warranty_repository.dart, createClaim, _fromMap, getClaims, _resolveShopId, _supabase, updateClaimStatus

### Community 106 - "Billing Repository Impl"
Cohesion: 0.22
Nodes (7): build, InputLabel, text, package:billing_app/main.dart, package:flutter/material.dart, package:flutter_test/flutter_test.dart, main

### Community 107 - "Category BLoC Events"
Cohesion: 0.25
Nodes (7): ../../domain/entities/category.dart, CategoryModel, fromEntity, fromJson, toEntity, toJson, Category

### Community 108 - "Auth Events"
Cohesion: 0.25
Nodes (7): call, email, LoginParams, LoginUseCase, password, props, repository

### Community 109 - "Report BLoC Events"
Cohesion: 0.25
Nodes (7): AddCategoryUseCase, call, DeleteCategoryUseCase, GetCategoriesUseCase, repository, UpdateCategoryUseCase, package:billing_app/features/category/domain/repositories/category_repository.dart

### Community 110 - "Billing Events"
Cohesion: 0.33
Nodes (7): @HiveType, ProductModelAdapter, ShopModelAdapter, ProductModel, ShopModel, Shop, TypeAdapter

### Community 111 - "Hive Database"
Cohesion: 0.38
Nodes (6): CacheFailure, Failure, message, props, ServerFailure, List

### Community 112 - "Report Repository Impl"
Cohesion: 0.33
Nodes (5): fromJson, fromProfileJson, fromSupabaseAuth, toJson, package:billing_app/features/auth/domain/entities/user.dart

### Community 113 - "Report BLoC"
Cohesion: 0.40
Nodes (3): MainActivity, FlutterActivity, FlutterEngine

### Community 114 - "Bill History Data"
Cohesion: 0.40
Nodes (5): CustomPainter, _SalesTrendPainter, _LineChartPainter, _PieChartPainter, _DonutPainter

## Knowledge Gaps
- **1470 isolated node(s):** `supabase`, `XCTest`, `_sub`, `rootNavigatorKey`, `dispose` (+1465 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **3 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `AuthBloc` connect `App Drawer & Auth Bloc` to `Billing Cart & Checkout`, `Warranty Claims`, `Stock & Category BLoC`, `Printer BLoC & Theme`, `Dashboard Widgets`, `Audit BLoC & Timeline`, `Staff BLoC & Auth`, `Due Payments BLoC`, `Product BLoC & Realtime`, `Bill Detail Page`, `Billing Home & Product Repo`, `Equatable & Models`, `Billing Events`, `Service Locator`, `App Routes & Config`, `Product CRUD Events`, `Staff List & Add Page`, `Billing Bloc Logic`, `Login & Register UI`, `Dashboard Trend Cards`, `Deep Link Config`, `Audit Events & State`, `Auth State`, `Report BLoC Events`, `Warranty BLoC`?**
  _High betweenness centrality (0.073) - this node is a cross-community bridge._
- **Why does `Product` connect `Dashboard Analytics` to `Billing Cart & Checkout`, `Stock & Category BLoC`, `Warranty Claims Page`, `Billing Events`, `Report Repository`, `Product BLoC & Realtime`, `Product Coverflow View`, `Image Upload & Edit Product`, `State Models & UseCases`?**
  _High betweenness centrality (0.020) - this node is a cross-community bridge._
- **Why does `ProductBloc` connect `Product Events & Init` to `Warranty BLoC`, `Stock & Category BLoC`, `Printer BLoC & Theme`, `Dashboard Widgets`, `Product List & CSV`, `Product BLoC & Realtime`, `Product Coverflow View`, `Image Upload & Edit Product`, `Report BLoC`, `State Models & UseCases`, `Category Entities & Add Product`, `Billing Bloc Logic`, `Dashboard Analytics`, `Category List & Dialog`, `Equatable & Models`?**
  _High betweenness centrality (0.019) - this node is a cross-community bridge._
- **What connects `supabase`, `XCTest`, `_sub` to the rest of the system?**
  _1470 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Billing Cart & Checkout` be split into smaller, more focused modules?**
  _Cohesion score 0.028985507246376812 - nodes in this community are weakly interconnected._
- **Should `Warranty Claims` be split into smaller, more focused modules?**
  _Cohesion score 0.053109713487071976 - nodes in this community are weakly interconnected._
- **Should `Shop & Settings` be split into smaller, more focused modules?**
  _Cohesion score 0.05805515239477504 - nodes in this community are weakly interconnected._