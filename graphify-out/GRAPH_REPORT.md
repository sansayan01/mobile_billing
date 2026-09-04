# Graph Report - .  (2026-09-05)

## Corpus Check
- 160 files · ~0 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 2730 nodes · 4426 edges · 130 communities (126 shown, 4 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- billing_bloc.dart
- warranty_bloc.dart
- app_colors.dart
- category_bloc.dart
- printer_helper.dart
- printer_bloc.dart
- dashboard_page.dart
- bill_history_page.dart
- app_routes.dart
- printer_state.dart
- text_styles.dart
- product_list_page.dart
- due_payments_bloc.dart
- service_locator.dart
- product_bloc.dart
- report_entities.dart
- .claude/skills/ui-ux-pro-max/scripts/validate_data.py
- product_coverflow_view.dart
- bill_detail_page.dart
- report_event.dart
- .opencode/skills/ui-ux-pro-max/scripts/validate_data.py
- app_dimensions.dart
- stock_movement_page.dart
- package:flutter/material.dart
- DesignSystemGenerator
- product_repository_impl.dart
- product_model.dart
- settings_page.dart
- shop_bloc.dart
- shop_details_page.dart
- .generate
- beep_helper.dart
- category_list_page.dart
- State
- low_stock_page.dart
- checkout_page.dart
- Changelog — Flutter Billing App
- app_theme.dart
- sales_trend_card.dart
- audit_timeline_page.dart
- product.dart
- add_product_page.dart
- .claude/skills/ui-ux-pro-max/scripts/core.py
- gray
- warranty_claim.dart
- Tailwind CSS Utility Reference
- cart_item.dart
- dashboard_action_card.dart
- .opencode/skills/ui-ux-pro-max/scripts/core.py
- shop_usecases.dart
- user.dart
- DesignSystemGenerator
- customer_repository_impl.dart
- slide_search_core.py
- daily_sales_page.dart
- add_staff_page.dart
- audit_log.dart
- audit_state.dart
- customer_bloc.dart
- package:flutter/services.dart
- button
- 🔍 FULL APP AUDIT REPORT — flutter_billing_app
- customer_detail_page.dart
- app_typography.dart
- search
- report_state.dart
- Current Session: 2026-08-24 — PREMIUM UI/UX REDESIGN PROJECT 🚀 (Research Phase ✅)
- printer_repository_impl.dart
- Tailwind CSS Utility Reference
- detect_domain
- auth_bloc.dart
- shop_model.dart
- .application
- .opencode/skills/ui-ux-pro-max/scripts/design_system.py
- BM25
- hive_database.dart
- .claude/skills/design-system/scripts/slide_search_core.py
- report_bloc.dart
- warranty_claims_page.dart
- search
- stock_bloc.dart
- Brand Guidelines v1.0
- BUG FIX 8: 2026-08-24 - AddProductPage category select crash (type mismatch)
- register_page.dart
- product_detail_page.dart
- Brand Guidelines v1.0
- auth_repository_impl.dart
- _palette_is_dark
- Design
- Design
- due_payment.dart
- damaged_products_bloc.dart
- 🎨 DESIGN SYSTEM v3 — "MIDNIGHT LIME" (Source of Truth, LOCKED after Phase 5)
- Equatable
- email_verification_page.dart
- package:billing_app/core/error/failure.dart
- printer_repository.dart
- category_repository_impl.dart
- Canvas Design System
- Design
- manifest.json
- detect_domain
- BUG FIX 2: 2026-08-21 - scan open prefilled dialog crash (firstWhere type)
- Canvas Design System
- _
- damaged_product.dart
- Previous Session: 2026-08-20 — Dual View (Classic List + Cover-flow) 🔀
- Memory — Session Log & Context
- parse_decision_rules
- List
- Prerequisites
- stock_adjustment.dart
- app_drawer.dart
- MainActivity
- Form & Input Components
- app_validators.dart
- .mcp.json
- app/build.gradle.kts
- android/build.gradle.kts
- settings.gradle.kts
- @oksbi
- Runner-Bridging-Header.h
- 🛒 Mobile POS & Billing App
- Files to Modify
- staff_bloc.dart
- Component Specs
- Current Session: 2026-08-21 — Billing Scanner Beep Sound Missing ✅
- AGENTS.md — Flutter Billing App
- CLAUDE.md — Flutter Billing App

## God Nodes (most connected - your core abstractions)
1. `AuthBloc` - 72 edges
2. `ReportBloc` - 56 edges
3. `ProductBloc` - 52 edges
4. `BillingBloc` - 40 edges
5. `CategoryBloc` - 31 edges
6. `DamagedProductsBloc` - 24 edges
7. `BillingEvent` - 22 edges
8. `build` - 21 edges
9. `_CheckoutPageState` - 19 edges
10. `PrinterBloc` - 17 edges

## Surprising Connections (you probably didn't know these)
- `createRouter` --references--> `AuthBloc`  [EXTRACTED]
  lib/config/routes/app_routes.dart → lib/features/auth/presentation/bloc/auth_bloc.dart
- `build` --references--> `AuthBloc`  [EXTRACTED]
  lib/core/widgets/quick_actions_panel.dart → lib/features/auth/presentation/bloc/auth_bloc.dart
- `_onResend` --references--> `AuthBloc`  [EXTRACTED]
  lib/features/auth/presentation/pages/email_verification_page.dart → lib/features/auth/presentation/bloc/auth_bloc.dart
- `build` --references--> `AuthBloc`  [EXTRACTED]
  lib/features/report/presentation/pages/bill_detail_page.dart → lib/features/auth/presentation/bloc/auth_bloc.dart
- `_showProductSearchDialog` --references--> `AuthBloc`  [EXTRACTED]
  lib/features/report/presentation/pages/bill_detail_page.dart → lib/features/auth/presentation/bloc/auth_bloc.dart

## Import Cycles
- None detected.

## Communities (130 total, 4 thin omitted)

### Community 0 - "billing_bloc.dart"
Cohesion: 0.03
Nodes (66): address1, address2, barcode, billId, cartItems, copyWith, customer, customPrice (+58 more)

### Community 1 - "warranty_bloc.dart"
Cohesion: 0.04
Nodes (61): appBarTheme, b, buildActions, _buildDescriptionSnippet, _buildInsightsSection, buildLeading, _buildLoadingPlaceholder, _buildQuickTiles (+53 more)

### Community 2 - "app_colors.dart"
Cohesion: 0.05
Nodes (55): ../bloc/warranty_bloc.dart, core/service_locator.dart, billId, claimId, claimReason, claimType, ClearWarrantyFeedback, CreateWarrantyClaim (+47 more)

### Community 3 - "category_bloc.dart"
Cohesion: 0.04
Nodes (56): accent, accentDark, accentLight, accentSubtle, accentText, accentTextOnLight, AppColors, bg (+48 more)

### Community 4 - "printer_helper.dart"
Cohesion: 0.04
Nodes (56): _actionChip, _actionColor, _actionLabel, _buildActionFilters, _buildAdvancedFilters, _buildAuthDetail, _buildBillDetail, _buildCategoryDetail (+48 more)

### Community 5 - "printer_bloc.dart"
Cohesion: 0.04
Nodes (51): CustomPainter, _SalesTrendPainter, _CheckPainter, _SparklinePainter, _applyDateRange, BillHistoryPage, _BillHistoryPageState, _buildBillCard (+43 more)

### Community 6 - "dashboard_page.dart"
Cohesion: 0.04
Nodes (49): app_shell.dart, ChangeNotifier, ../../features/audit/presentation/bloc/audit_bloc.dart, ../../features/audit/presentation/bloc/audit_event.dart, ../../features/audit/presentation/pages/audit_timeline_page.dart, ../../features/auth/presentation/pages/email_verification_page.dart, ../../features/auth/presentation/pages/login_page.dart, ../../features/auth/presentation/pages/register_page.dart (+41 more)

### Community 7 - "bill_history_page.dart"
Cohesion: 0.07
Nodes (46): _HeroSalesCard, _loadDashboardData, _LowStockBanner, _PaymentMethodsSection, _RecentTransactions, _StaffPerformanceSection, _TopProductsSection, ReportBloc (+38 more)

### Community 8 - "app_routes.dart"
Cohesion: 0.04
Nodes (44): ../../features/audit/data/repositories/audit_repository_impl.dart, ../../features/audit/domain/repositories/audit_repository.dart, ../../features/auth/data/repositories/auth_repository_impl.dart, ../../features/auth/domain/usecases/get_current_user_usecase.dart, ../../features/auth/domain/usecases/login_usecase.dart, ../../features/auth/domain/usecases/logout_usecase.dart, ../../features/auth/domain/usecases/signup_usecase.dart, ../../features/category/data/repositories/category_repository_impl.dart (+36 more)

### Community 9 - "printer_state.dart"
Cohesion: 0.05
Nodes (42): ../../../billing/presentation/bloc/billing_bloc.dart, ../../../../core/utils/csv_export_import.dart, allProducts, _buildDescriptionSnippet, _buildProductTile, _buildStatsBar, categories, _copyBarcode (+34 more)

### Community 10 - "text_styles.dart"
Cohesion: 0.05
Nodes (40): Brightness, Color get, actionCardSubtitle, actionCardTitle, AdaptiveTextStyles, AppTextStyles, _brightness, greetingDate (+32 more)

### Community 11 - "product_list_page.dart"
Cohesion: 0.06
Nodes (39): BillingState, CustomerState, DamagedProductsState, DuePaymentsState, ProductState, Equatable, AuditLog, CartItem (+31 more)

### Community 12 - "due_payments_bloc.dart"
Cohesion: 0.05
Nodes (40): AppDurations, AppElevation, AppRadius, AppSpacing, AppTouchTarget, buttonHeight, card, ease (+32 more)

### Community 13 - "service_locator.dart"
Cohesion: 0.06
Nodes (35): ../../../../core/realtime/realtime_service.dart, categoryId, changeType, copyWith, filteredProducts, id, message, payload (+27 more)

### Community 14 - "product_bloc.dart"
Cohesion: 0.06
Nodes (34): ../../../../core/widgets/adaptive_app_bar_leading.dart, _actionBtn, bill, build, _buildCustomerHistory, _buildInfoCard, _buildPaymentStatusRow, _buildPaymentTimeline (+26 more)

### Community 15 - "report_entities.dart"
Cohesion: 0.06
Nodes (32): build, _darkText, _EmptyState, _fmt, _glass, icon, _methodColor, paymentCounts (+24 more)

### Community 16 - ".claude/skills/ui-ux-pro-max/scripts/validate_data.py"
Cohesion: 0.06
Nodes (34): amountPaid, averageBill, billCount, changeType, copyWith, createdAt, customerId, customerName (+26 more)

### Community 17 - "product_coverflow_view.dart"
Cohesion: 0.06
Nodes (33): add_edit_category_dialog.dart, ../../domain/usecases/category_usecases.dart, _buildEmptySearch, _buildEmptyState, _buildStatsCard, _categoryIcon, _confirmSwipeDelete, _count (+25 more)

### Community 18 - "bill_detail_page.dart"
Cohesion: 0.12
Nodes (34): MarkProductAsDamaged, AddProduct, AddProductsBulk, DeleteProduct, FilterByCategory, InitRealtime, LoadProducts, ProductEvent (+26 more)

### Community 19 - "report_event.dart"
Cohesion: 0.06
Nodes (32): ../bloc/product_bloc.dart, _actionBtn, _allDialKey, _badge, _bottomPanel, build, categoryName, categoryNames (+24 more)

### Community 20 - ".opencode/skills/ui-ux-pro-max/scripts/validate_data.py"
Cohesion: 0.16
Nodes (31): AddProductToCartEvent, BillingEvent, ClearCartEvent, ClearStockErrorsEvent, PrintReceiptEvent, _ProductStockUpdatedEvent, RemoveProductFromCartEvent, ScanBarcodeEvent (+23 more)

### Community 21 - "app_dimensions.dart"
Cohesion: 0.06
Nodes (30): _applyTimeRange, _buildBarChart, _buildBestSelling, _buildDateNav, _buildHourlyHeatmap, _buildPaymentSplit, _buildStatCards, _buildSummaryHeader (+22 more)

### Community 22 - "stock_movement_page.dart"
Cohesion: 0.07
Nodes (29): app_colors.dart, app_typography.dart, aiGradient, AppTheme, backgroundColor, _baseInputTheme, darkBackground, darkBorder (+21 more)

### Community 23 - "package:flutter/material.dart"
Cohesion: 0.07
Nodes (29): adjustmentId, copyWith, damagedProducts, damageType, error, isLoading, isMarking, notes (+21 more)

### Community 24 - "DesignSystemGenerator"
Cohesion: 0.07
Nodes (29): DeleteBillUseCase, GetBillDetailUseCase, GetBillHistoryUseCase, GetDailySalesUseCase, GetLowStockProductsUseCase, GetSalesRangeUseCase, GetStockMovementsUseCase, authBloc (+21 more)

### Community 25 - "product_repository_impl.dart"
Cohesion: 0.07
Nodes (29): GlobalKey, address1, address2, amountPaid, billId, cartItems, createState, customerName (+21 more)

### Community 26 - "product_model.dart"
Cohesion: 0.07
Nodes (28): ../../../category/domain/entities/category.dart, File?, _barcodeController, build, _categoryController, _categoryId, _checkDuplicate, createState (+20 more)

### Community 27 - "settings_page.dart"
Cohesion: 0.07
Nodes (28): _animController, build, _buildDateButton, _buildDateRange, _buildEmptyState, _buildGroupedCard, _buildMovementCard, _buildStatDivider (+20 more)

### Community 28 - "shop_bloc.dart"
Cohesion: 0.07
Nodes (27): ../../../../core/utils/image_compress.dart, ../../../../core/utils/image_upload_service.dart, _barcodeController, build, _categoryId, _categoryNameController, createState, _description (+19 more)

### Community 29 - "shop_details_page.dart"
Cohesion: 0.07
Nodes (26): GetCurrentUserUseCase, authRepository, _authSubscription, close, getCurrentUserUseCase, _isLoggingOut, loginUseCase, logoutUseCase (+18 more)

### Community 30 - ".generate"
Cohesion: 0.08
Nodes (25): build, color, DashboardActionCard, icon, label, onTap, QuickActionTile, staggerDelay (+17 more)

### Community 31 - "beep_helper.dart"
Cohesion: 0.08
Nodes (25): AuthRepositoryImpl, AuthRepository, authStateChanges, getCurrentUser, login, logout, resendVerificationEmail, signUp (+17 more)

### Community 32 - "category_list_page.dart"
Cohesion: 0.08
Nodes (25): AppMoneyText, AppTypography, balance, bodyLarge, bodyMedium, bodySmall, displayLarge, displaySmall (+17 more)

### Community 33 - "State"
Cohesion: 0.08
Nodes (22): dart:io, ../../features/damaged_products/domain/entities/damaged_product.dart, ../../../../features/product/domain/entities/product.dart, CsvExportImport, exportDamagedProducts, exportProducts, importProducts, compressImage (+14 more)

### Community 34 - "low_stock_page.dart"
Cohesion: 0.08
Nodes (23): EdgeInsetsGeometry, AppFeedback, error, FeedbackType, info, _show, success, borderRadius (+15 more)

### Community 35 - "checkout_page.dart"
Cohesion: 0.08
Nodes (24): alignCenter, alignLeft, alignRight, boldOff, boldOn, bytes, checkPermission, connect (+16 more)

### Community 36 - "Changelog — Flutter Billing App"
Cohesion: 0.08
Nodes (24): _animatedCount, _animController, _applyThreshold, build, _buildCategoryChips, _buildEmptyState, _buildFilterSection, _buildProductCard (+16 more)

### Community 37 - "app_theme.dart"
Cohesion: 0.08
Nodes (23): AddCategoryUseCase, colorValue, description, iconCodePoint, id, ids, name, props (+15 more)

### Community 38 - "sales_trend_card.dart"
Cohesion: 0.11
Nodes (23): ../../../auth/presentation/bloc/auth_state.dart, adjustments, AdjustStock, copyWith, LoadAllAdjustments, LoadStockHistory, message, note (+15 more)

### Community 39 - "audit_timeline_page.dart"
Cohesion: 0.13
Nodes (23): ConnectPrinterEvent, DisconnectPrinterEvent, ../../domain/repositories/printer_repository.dart, InitPrinterEvent, _onConnect, _onDisconnect, _onInit, _onRefresh (+15 more)

### Community 40 - "product.dart"
Cohesion: 0.09
Nodes (22): _bottomPad, build, _buildPlaceholder, _buildStatChip, _buildStatsRow, _chartColor, dotFillColor, _formatCurrency (+14 more)

### Community 41 - "add_product_page.dart"
Cohesion: 0.09
Nodes (22): barcode, categoryId, createdAt, description, fromEntity, fromJson, id, imageUrl (+14 more)

### Community 42 - ".claude/skills/ui-ux-pro-max/scripts/core.py"
Cohesion: 0.09
Nodes (21): config/routes/app_routes.dart, core/theme/app_theme.dart, features/auth/domain/repositories/auth_repository.dart, features/auth/presentation/bloc/auth_event.dart, features/billing/presentation/bloc/billing_bloc.dart, features/category/presentation/bloc/category_bloc.dart, features/damaged_products/presentation/bloc/damaged_products_bloc.dart, features/product/presentation/bloc/product_bloc.dart (+13 more)

### Community 43 - "gray"
Cohesion: 0.09
Nodes (21): copyWith, customer, customerId, customers, error, isLoading, name, phone (+13 more)

### Community 44 - "warranty_claim.dart"
Cohesion: 0.09
Nodes (21): barcode, categoryId, copyWith, createdAt, description, hasWarranty, id, imageUrl (+13 more)

### Community 45 - "Tailwind CSS Utility Reference"
Cohesion: 0.12
Nodes (20): ../bloc/staff_bloc.dart, ../../../../core/widgets/app_feedback.dart, ../../../../core/widgets/app_skeleton.dart, DeleteStaffMember, ../../../../features/auth/domain/entities/user.dart, _buildStaffCard, _confirmDelete, createState (+12 more)

### Community 46 - "cart_item.dart"
Cohesion: 0.10
Nodes (20): ../../../category/presentation/bloc/category_bloc.dart, ../../../damaged_products/presentation/bloc/damaged_products_bloc.dart, ../../../damaged_products/presentation/pages/mark_damaged_dialog.dart, _actionButton, build, createState, _currentProduct, _descriptionRow (+12 more)

### Community 47 - "dashboard_action_card.dart"
Cohesion: 0.10
Nodes (20): core/utils/beep_helper.dart, build, _buildPermissionPrompt, _cameraStatus, _checkPermission, controller, _corner, createState (+12 more)

### Community 48 - ".opencode/skills/ui-ux-pro-max/scripts/core.py"
Cohesion: 0.10
Nodes (19): ../bloc/billing_bloc.dart, ../../../../core/widgets/success_burst.dart, ../../../customer/domain/entities/customer.dart, ../../../customer/presentation/bloc/customer_bloc.dart, ../../domain/entities/cart_item.dart, createState, _customerNameController, _customerPhoneController (+11 more)

### Community 49 - "shop_usecases.dart"
Cohesion: 0.18
Nodes (20): CategoryState, AddCategory, CategoryEvent, DeleteCategoriesBulk, DeleteCategory, LoadCategories, UpdateCategory, CategoryBloc (+12 more)

### Community 50 - "user.dart"
Cohesion: 0.10
Nodes (19): amount, billId, copyWith, duePayments, error, isCollecting, isLoading, query (+11 more)

### Community 51 - "DesignSystemGenerator"
Cohesion: 0.11
Nodes (19): Future, _billsFuture, build, _buildBillsSection, _buildDueBalanceSection, _buildSectionTitle, _buildWarrantySection, createState (+11 more)

### Community 52 - "customer_repository_impl.dart"
Cohesion: 0.11
Nodes (18): addCustomer, CustomerRepositoryImpl, findCustomerByPhone, getCustomerDetail, getCustomers, _resolveShopId, _supabase, updateCustomer (+10 more)

### Community 53 - "slide_search_core.py"
Cohesion: 0.11
Nodes (18): ../bloc/shop_bloc.dart, ../../domain/entities/shop.dart, _address1Controller, _address2Controller, _buildTextField, createState, dispose, _footerController (+10 more)

### Community 54 - "daily_sales_page.dart"
Cohesion: 0.11
Nodes (18): double get, int? get, copyWith, customPrice, effectiveWarrantyDuration, effectiveWarrantyType, effectiveWarrantyUnit, hasWarranty (+10 more)

### Community 55 - "add_staff_page.dart"
Cohesion: 0.11
Nodes (18): int?, billId, claimedByStaffId, claimReason, claimStatus, claimType, copyWith, createdAt (+10 more)

### Community 56 - "audit_log.dart"
Cohesion: 0.11
Nodes (18): build, _burst, _c, _card, _check, _circle, createState, dispose (+10 more)

### Community 57 - "audit_state.dart"
Cohesion: 0.11
Nodes (17): action, entityType, from, performedBy, props, searchQuery, to, colorValue (+9 more)

### Community 58 - "customer_bloc.dart"
Cohesion: 0.11
Nodes (18): damageDate, damageType, damageTypeLabel, decodeNote, encodeNote, estimatedLoss, id, newStock (+10 more)

### Community 59 - "package:flutter/services.dart"
Cohesion: 0.11
Nodes (17): ../../../auth/presentation/bloc/auth_bloc.dart, ../../../auth/presentation/bloc/auth_event.dart, ../../../../core/widgets/input_label.dart, ../../../../core/widgets/primary_button.dart, build, build, createState, dispose (+9 more)

### Community 60 - "button"
Cohesion: 0.11
Nodes (16): ../config/app_config.dart, ../../domain/repositories/category_repository.dart, _anonKey, client, initialize, SupabaseConfig, _url, addCategory (+8 more)

### Community 61 - "🔍 FULL APP AUDIT REPORT — flutter_billing_app"
Cohesion: 0.11
Nodes (17): features/auth/presentation/bloc/auth_bloc.dart, ../../../../features/auth/presentation/bloc/auth_state.dart, _ActionsPanel, build, _CloseButton, icon, item, label (+9 more)

### Community 62 - "customer_detail_page.dart"
Cohesion: 0.12
Nodes (16): IconData, currentRoute, _DrawerItem, icon, _initials, label, onTap, _ProfileHeader (+8 more)

### Community 63 - "app_typography.dart"
Cohesion: 0.11
Nodes (17): build, _buildEmptyState, _buildPaymentBadge, _buildTransactionItem, createdAt, _formatCurrency, grandTotal, id (+9 more)

### Community 64 - "search"
Cohesion: 0.11
Nodes (17): _buildBottomPanel, _buildCameraOffState, _buildCorner, _buildEmptyCart, _buildOverlayButton, _buildScannerSection, _cameraStatus, _checkCameraPermission (+9 more)

### Community 65 - "report_state.dart"
Cohesion: 0.12
Nodes (17): build, _buildCustomerTile, _buildEmptyState, createState, CustomerListPage, _CustomerListPageState, dispose, getOffset (+9 more)

### Community 66 - "Current Session: 2026-08-24 — PREMIUM UI/UX REDESIGN PROJECT 🚀 (Research Phase ✅)"
Cohesion: 0.12
Nodes (16): ../bloc/category_bloc.dart, ../../../../core/utils/app_validators.dart, AddEditCategoryDialog, build, category, _categoryColors, categoryIcons, createState (+8 more)

### Community 67 - "printer_repository_impl.dart"
Cohesion: 0.12
Nodes (16): ../bloc/printer_bloc.dart, ../bloc/printer_event.dart, ../bloc/printer_state.dart, core/theme/theme_cubit.dart, build, _buildListGroup, _buildListItem, _buildSectionHeader (+8 more)

### Community 68 - "Tailwind CSS Utility Reference"
Cohesion: 0.15
Nodes (16): class, ../../../../core/usecase/usecase.dart, ../entities/product.dart, SignUpUseCase, ProductRepositoryImpl, AddProductUseCase, call, DeleteProductUseCase (+8 more)

### Community 69 - "detect_domain"
Cohesion: 0.12
Nodes (15): ../../../../core/error/failure.dart, ../../domain/entities/stock_adjustment.dart, ../../domain/repositories/stock_repository.dart, ../entities/stock_adjustment.dart, adjustStock, _fromMap, getAllAdjustments, getStockHistory (+7 more)

### Community 70 - "auth_bloc.dart"
Cohesion: 0.17
Nodes (17): build, build, build, Route /categories, Route /customers, Route /damaged-products, Route /due-payments, Route /reports (+9 more)

### Community 71 - "shop_model.dart"
Cohesion: 0.23
Nodes (16): AuthBloc, Authenticated, AuthError, AuthInitial, AuthLoading, AuthState, email, EmailVerificationPending (+8 more)

### Community 72 - ".application"
Cohesion: 0.13
Nodes (16): SignUpRequested, _confirmPasswordController, createState, dispose, _emailController, _formKey, _isLoading, _nameController (+8 more)

### Community 73 - ".opencode/skills/ui-ux-pro-max/scripts/design_system.py"
Cohesion: 0.12
Nodes (15): active, AppBottomNav, build, children, currentRoute, _GlassPill, _go, icon (+7 more)

### Community 74 - "BM25"
Cohesion: 0.13
Nodes (15): AppSkeleton, AppSkeletonList, AppSkeletonListTile, _AppSkeletonState, build, _controller, createState, dispose (+7 more)

### Community 75 - "hive_database.dart"
Cohesion: 0.12
Nodes (15): build, _buildEmptyState, _buildGlassContainer, _buildStatChip, _buildStatsRow, currencyPrefix, _formatShort, _gridInterval (+7 more)

### Community 76 - ".claude/skills/design-system/scripts/slide_search_core.py"
Cohesion: 0.14
Nodes (14): AuditRepositoryImpl, _fromJson, getAuditLogs, getEntityAuditLogs, logAction, _supabase, AuditRepository, getAuditLogs (+6 more)

### Community 77 - "report_bloc.dart"
Cohesion: 0.12
Nodes (15): action, copyWith, createdAt, description, entityId, entityName, entityType, id (+7 more)

### Community 78 - "warranty_claims_page.dart"
Cohesion: 0.15
Nodes (15): CheckAuthStatus, createState, dispose, email, EmailVerificationPage, _EmailVerificationPageState, initState, _isChecking (+7 more)

### Community 79 - "search"
Cohesion: 0.12
Nodes (15): _buildBadge, _buildDamagedProductsList, _buildEmptyState, _buildImagePlaceholder, _buildProductImage, _buildSummaryCard, createState, DamagedProductsPage (+7 more)

### Community 80 - "stock_bloc.dart"
Cohesion: 0.13
Nodes (14): dart:math, dart:typed_data, BeepHelper, _beepPath, dispose, _fileReady, _generateBeepWav, init (+6 more)

### Community 81 - "Brand Guidelines v1.0"
Cohesion: 0.13
Nodes (14): dart:ui, double?, blur, borderOpacity, borderRadius, build, child, GlassCard (+6 more)

### Community 82 - "BUG FIX 8: 2026-08-24 - AddProductPage category select crash (type mismatch)"
Cohesion: 0.13
Nodes (14): ../../domain/entities/product.dart, ../../domain/repositories/product_repository.dart, addProduct, deleteProduct, _fromMap, getCurrentStockBulk, getProductByBarcode, getProducts (+6 more)

### Community 83 - "register_page.dart"
Cohesion: 0.15
Nodes (14): FormState, LoginRequested, createState, dispose, _emailController, _formKey, _isLoading, LoginPage (+6 more)

### Community 84 - "product_detail_page.dart"
Cohesion: 0.13
Nodes (14): AuditStatus, copyWith, currentPage, error, hasMore, lastFilterAction, lastFilterEntity, lastFilterFrom (+6 more)

### Community 85 - "Brand Guidelines v1.0"
Cohesion: 0.16
Nodes (15): CheckoutPage, HomePage, _DashboardView, _DashboardViewState, AddProductPage, EditProductPage, ProductListPage, BillDetailPage (+7 more)

### Community 86 - "auth_repository_impl.dart"
Cohesion: 0.14
Nodes (14): Customer, AddCustomerPage, _AddCustomerPageState, build, createState, dispose, editCustomer, initState (+6 more)

### Community 87 - "_palette_is_dark"
Cohesion: 0.14
Nodes (13): DamagedProductsRepositoryImpl, getDamagedProducts, markAsDamaged, _resolveShopId, _supabase, undoDamage, DamagedProductsRepository, getDamagedProducts (+5 more)

### Community 88 - "Design"
Cohesion: 0.15
Nodes (13): Animation, build, child, createState, _ctrl, delay, dispose, index (+5 more)

### Community 89 - "Design"
Cohesion: 0.14
Nodes (13): bool get, createdAt, createdBy, id, isIncrease, newStock, note, previousStock (+5 more)

### Community 90 - "due_payment.dart"
Cohesion: 0.16
Nodes (12): ../../config/routes/app_shell.dart, Cubit, AppNavigationMode, _loadMode, NavigationCubit, setMode, toggle, AdaptiveAppBarLeading (+4 more)

### Community 91 - "damaged_products_bloc.dart"
Cohesion: 0.15
Nodes (13): ../../../../core/theme/app_colors.dart, ../../../../core/theme/app_typography.dart, build, createState, dispose, initState, product, _qrDataController (+5 more)

### Community 92 - "🎨 DESIGN SYSTEM v3 — "MIDNIGHT LIME" (Source of Truth, LOCKED after Phase 5)"
Cohesion: 0.15
Nodes (12): ../entities/warranty_claim.dart, WarrantyRepositoryImpl, createClaim, getClaims, updateClaimStatus, WarrantyRepository, call, CreateWarrantyClaimUseCase (+4 more)

### Community 93 - "Equatable"
Cohesion: 0.18
Nodes (13): AppDrawer, AuthEvent, email, LogoutRequested, name, password, phone, props (+5 more)

### Community 94 - "email_verification_page.dart"
Cohesion: 0.14
Nodes (13): build, _buildGlassContainer, color, count, _healthInfo, InventoryHealthCard, label, lowStockCount (+5 more)

### Community 95 - "package:billing_app/core/error/failure.dart"
Cohesion: 0.14
Nodes (13): _avatarColor, billCount, build, _buildGlassContainer, _initial, name, revenue, _short (+5 more)

### Community 96 - "printer_repository.dart"
Cohesion: 0.14
Nodes (13): _createProfile, _ensureProfileRole, _extractErrorMessage, _fetchProfile, _friendlyMessage, getCurrentUser, login, logout (+5 more)

### Community 97 - "category_repository_impl.dart"
Cohesion: 0.16
Nodes (12): collectPayment, DuePaymentsRepositoryImpl, getDuePayments, _resolveShopId, _supabase, collectPayment, DuePaymentsRepository, getDuePayments (+4 more)

### Community 98 - "Canvas Design System"
Cohesion: 0.14
Nodes (13): deleteBill, getBillDetail, getBillHistory, getDailySales, getLowStockProducts, getSalesRange, getStockMovements, _logAudit (+5 more)

### Community 99 - "Design"
Cohesion: 0.17
Nodes (12): AnimationController, Color, AuroraGlow, _AuroraGlowState, build, color, _controller, createState (+4 more)

### Community 100 - "manifest.json"
Cohesion: 0.15
Nodes (12): core/data/hive_database.dart, ../../../../core/utils/printer_helper.dart, PrinterHelper, clearPrinterData, connect, disconnect, getSavedPrinterMac, getSavedPrinterName (+4 more)

### Community 101 - "detect_domain"
Cohesion: 0.15
Nodes (12): dart:async, _channels, dispose, _disposed, _isConnected, RealtimeService, _retryTimers, _scheduleRetry (+4 more)

### Community 102 - "BUG FIX 2: 2026-08-21 - scan open prefilled dialog crash (firstWhere type)"
Cohesion: 0.15
Nodes (12): DateTime, copyWith, createdAt, CustomerModel, fromEntity, fromJson, id, name (+4 more)

### Community 103 - "Canvas Design System"
Cohesion: 0.15
Nodes (12): amountPaid, billDate, billId, copyWith, customerName, customerPhone, dueAmount, DuePayment (+4 more)

### Community 104 - "_"
Cohesion: 0.27
Nodes (12): Bloc, AuditBloc, AuditEvent, LoadAuditLogs, LoadMoreAuditLogs, ResetAuditLogs, AuditState, AuditTimelinePage (+4 more)

### Community 105 - "damaged_product.dart"
Cohesion: 0.17
Nodes (11): core/navigation/navigation_cubit.dart, ../../core/widgets/app_bottom_nav.dart, ../../core/widgets/app_drawer.dart, AppShell, build, child, _fullScreenRoutes, scaffoldKey (+3 more)

### Community 106 - "Previous Session: 2026-08-20 — Dual View (Classic List + Cover-flow) 🔀"
Cohesion: 0.17
Nodes (11): PrinterRepositoryImpl, clearPrinterData, connect, disconnect, getSavedPrinterMac, getSavedPrinterName, PrinterRepository, savePrinterData (+3 more)

### Community 107 - "Memory — Session Log & Context"
Cohesion: 0.18
Nodes (10): audit_event.dart, audit_state.dart, auditRepository, authBloc, _onLoadAuditLogs, _onLoadMoreAuditLogs, _onReset, _pageSize (+2 more)

### Community 108 - "parse_decision_rules"
Cohesion: 0.20
Nodes (10): Curve, build, child, createState, curve, duration, _pressed, pressedScale (+2 more)

### Community 109 - "List"
Cohesion: 0.38
Nodes (11): DamagedProductsEvent, FilterDamagedProductsByDate, LoadDamagedProducts, SearchDamagedProducts, UndoDamagedProduct, DamagedProductsBloc, build, _confirmUndo (+3 more)

### Community 110 - "Prerequisites"
Cohesion: 0.18
Nodes (10): build, CountUpMoney, CountUpText, curve, decimalDigits, duration, style, symbol (+2 more)

### Community 111 - "stock_adjustment.dart"
Cohesion: 0.18
Nodes (10): _buildDuePaymentCard, createState, dispose, DuePaymentsPage, _formatPrice, _searchController, _searchDebounce, package:billing_app/core/widgets/app_feedback.dart (+2 more)

### Community 112 - "app_drawer.dart"
Cohesion: 0.20
Nodes (9): core/supabase/supabase_client.dart, ../../domain/entities/warranty_claim.dart, ../../domain/repositories/warranty_repository.dart, createClaim, _fromMap, getClaims, _resolveShopId, _supabase (+1 more)

### Community 113 - "MainActivity"
Cohesion: 0.47
Nodes (10): ClearDueMessages, CollectPayment, DuePaymentsEvent, LoadDuePayments, SearchDuePayments, DuePaymentsBloc, build, _DuePaymentsPageState (+2 more)

### Community 114 - "Form & Input Components"
Cohesion: 0.42
Nodes (9): AddCustomer, ClearCustomerMessage, CustomerEvent, GetCustomerDetail, LoadCustomers, SearchCustomers, UpdateCustomer, _showCustomerPicker (+1 more)

### Community 115 - "app_validators.dart"
Cohesion: 0.22
Nodes (8): Duration, AnimatedSwap, build, child, duration, Offset, package:billing_app/core/theme/app_dimensions.dart, Widget

### Community 116 - ".mcp.json"
Cohesion: 0.22
Nodes (8): copyWith, createdAt, id, name, phone, props, shopId, List

### Community 117 - "app/build.gradle.kts"
Cohesion: 0.25
Nodes (7): ../../domain/entities/category.dart, CategoryModel, fromEntity, fromJson, toEntity, toJson, Category

### Community 118 - "android/build.gradle.kts"
Cohesion: 0.32
Nodes (8): _printReceipt, initState, _saveShop, ShopDetailsPage, _ShopDetailsPageState, LoadShopEvent, ShopBloc, UpdateShopEvent

### Community 119 - "settings.gradle.kts"
Cohesion: 0.29
Nodes (7): build, build, build, build, Route /, Route /register, Route /verify-email

### Community 120 - "@oksbi"
Cohesion: 0.33
Nodes (5): cleaned, isValidPhone, normalized, normalizePhone, return

### Community 121 - "Runner-Bridging-Header.h"
Cohesion: 0.40
Nodes (5): @HiveType, _ProductSearchDelegate, ProductModel, Product, SearchDelegate

### Community 122 - "🛒 Mobile POS & Billing App"
Cohesion: 0.40
Nodes (5): FloatingActionButtonLocation, _AboveNavFabLocation, _AboveNavFabLocation, _AboveNavFabLocation, _AboveNavFabLocation

### Community 123 - "Files to Modify"
Cohesion: 0.40
Nodes (4): AppConfig, supabaseAnonKey, supabaseUrl, static const String

### Community 124 - "staff_bloc.dart"
Cohesion: 0.50
Nodes (4): build, build, Route /products/add, Route /scan/checkout

## Knowledge Gaps
- **1727 isolated node(s):** `_sub`, `router`, `refreshListenable`, `rootNavigatorKey`, `dispose` (+1722 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **4 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `AuthBloc` connect `shop_model.dart` to `billing_bloc.dart`, `app_colors.dart`, `dashboard_page.dart`, `bill_history_page.dart`, `service_locator.dart`, `product_bloc.dart`, `.opencode/skills/ui-ux-pro-max/scripts/validate_data.py`, `package:flutter/material.dart`, `DesignSystemGenerator`, `shop_details_page.dart`, `app_theme.dart`, `sales_trend_card.dart`, `audit_timeline_page.dart`, `.claude/skills/ui-ux-pro-max/scripts/core.py`, `gray`, `Tailwind CSS Utility Reference`, `.opencode/skills/ui-ux-pro-max/scripts/core.py`, `user.dart`, `package:flutter/services.dart`, `🔍 FULL APP AUDIT REPORT — flutter_billing_app`, `customer_detail_page.dart`, `search`, `printer_repository_impl.dart`, `auth_bloc.dart`, `.application`, `warranty_claims_page.dart`, `register_page.dart`, `Brand Guidelines v1.0`, `Equatable`, `_`, `Memory — Session Log & Context`, `AGENTS.md — Flutter Billing App`?**
  _High betweenness centrality (0.067) - this node is a cross-community bridge._
- **Why does `ReportBloc` connect `bill_history_page.dart` to `warranty_bloc.dart`, `Changelog — Flutter Billing App`, `printer_bloc.dart`, `auth_bloc.dart`, `_`, `.claude/skills/ui-ux-pro-max/scripts/core.py`, `product_list_page.dart`, `product_bloc.dart`, `Brand Guidelines v1.0`, `app_dimensions.dart`, `DesignSystemGenerator`, `settings_page.dart`?**
  _High betweenness centrality (0.026) - this node is a cross-community bridge._
- **Why does `AuthRepository` connect `beep_helper.dart` to `app_routes.dart`, `.claude/skills/ui-ux-pro-max/scripts/core.py`, `shop_details_page.dart`?**
  _High betweenness centrality (0.023) - this node is a cross-community bridge._
- **What connects `_sub`, `router`, `refreshListenable` to the rest of the system?**
  _1727 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `billing_bloc.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.029850746268656716 - nodes in this community are weakly interconnected._
- **Should `warranty_bloc.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.0370174510840825 - nodes in this community are weakly interconnected._
- **Should `app_colors.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.05200501253132832 - nodes in this community are weakly interconnected._