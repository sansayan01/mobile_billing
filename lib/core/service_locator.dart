import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/signup_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/category/data/repositories/category_repository_impl.dart';
import '../../features/category/domain/repositories/category_repository.dart';
import '../../features/category/domain/usecases/category_usecases.dart';
import '../../features/category/presentation/bloc/category_bloc.dart';
import '../../features/staff/data/repositories/staff_repository_impl.dart';
import '../../features/staff/domain/repositories/staff_repository.dart';
import '../../features/staff/domain/usecases/staff_usecases.dart';
import '../../features/staff/presentation/bloc/staff_bloc.dart';
import '../../features/product/data/repositories/product_repository_impl.dart';
import '../../features/product/domain/repositories/product_repository.dart';
import '../../features/product/domain/usecases/product_usecases.dart';
import '../../features/product/presentation/bloc/product_bloc.dart';
import '../../features/report/data/repositories/report_repository_impl.dart';
import '../../features/report/domain/repositories/report_repository.dart';
import '../../features/report/domain/usecases/report_usecases.dart';
import '../../features/report/presentation/bloc/report_bloc.dart';
import '../../features/shop/data/repositories/shop_repository_impl.dart';
import '../../features/shop/domain/repositories/shop_repository.dart';
import '../../features/shop/domain/usecases/shop_usecases.dart';
import '../../features/shop/presentation/bloc/shop_bloc.dart';
import '../../features/settings/data/repositories/printer_repository_impl.dart';
import '../../features/settings/domain/repositories/printer_repository.dart';
import '../../features/settings/presentation/bloc/printer_bloc.dart';
import '../../features/billing/presentation/bloc/billing_bloc.dart';
import '../../features/warranty/data/repositories/warranty_repository_impl.dart';
import '../../features/warranty/domain/repositories/warranty_repository.dart';
import '../../features/warranty/domain/usecases/warranty_usecases.dart';
import '../../features/warranty/presentation/bloc/warranty_bloc.dart';
import '../../features/due_payments/data/repositories/due_payments_repository_impl.dart';
import '../../features/due_payments/domain/repositories/due_payments_repository.dart';
import '../../features/due_payments/presentation/bloc/due_payments_bloc.dart';
import '../../features/customer/data/repositories/customer_repository_impl.dart';
import '../../features/customer/domain/repositories/customer_repository.dart';
import '../../features/customer/presentation/bloc/customer_bloc.dart';
import '../../features/stock/data/repositories/stock_repository_impl.dart';
import '../../features/stock/domain/repositories/stock_repository.dart';
import '../../features/stock/presentation/bloc/stock_bloc.dart';
import '../../features/damaged_products/data/repositories/damaged_products_repository_impl.dart';
import '../../features/damaged_products/domain/repositories/damaged_products_repository.dart';
import '../../features/damaged_products/presentation/bloc/damaged_products_bloc.dart';
import '../../core/theme/theme_cubit.dart';
import '../../core/navigation/navigation_cubit.dart';
import 'realtime/realtime_service.dart';
import '../../features/audit/data/repositories/audit_repository_impl.dart';
import '../../features/audit/domain/repositories/audit_repository.dart';
import '../../features/audit/presentation/bloc/audit_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Supabase client
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // ============== Auth Feature ==============
  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  // Bloc
  // SINGLETON — main.dart (subscribeToAuthChanges + BlocProvider + createRouter)
  // teeno ko EK hi AuthBloc instance milna chahiye. Factory se har call par naya
  // instance banta tha → 3 instances → auth state sync issues.
  sl.registerLazySingleton(
    () => AuthBloc(
      loginUseCase: sl(),
      signUpUseCase: sl(),
      logoutUseCase: sl(),
      getCurrentUserUseCase: sl(),
      authRepository: sl(),
    ),
  );

  // ============== Realtime Service ==============
  sl.registerLazySingleton(() => RealtimeService());

  // ============== Product Feature ==============
  // Bloc
  sl.registerFactory(
    () => ProductBloc(
      getProductsUseCase: sl(),
      addProductUseCase: sl(),
      updateProductUseCase: sl(),
      deleteProductUseCase: sl(),
      realtimeService: sl(),
      authBloc: sl(),
    ),
  );

  sl.registerFactory(
    () => ShopBloc(
      getShopUseCase: sl(),
      updateShopUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => PrinterBloc(
      repository: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetProductsUseCase(sl()));
  sl.registerLazySingleton(() => AddProductUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProductUseCase(sl()));
  sl.registerLazySingleton(() => DeleteProductUseCase(sl()));
  sl.registerLazySingleton(() => GetProductByBarcodeUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentStockBulkUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(),
  );

  // ============== Category Feature ==============
  // Use cases
  sl.registerLazySingleton(() => GetCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => AddCategoryUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCategoryUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCategoryUseCase(sl()));

  // Repository
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(),
  );

  // Bloc
  sl.registerFactory(
    () => CategoryBloc(
      getCategoriesUseCase: sl(),
      addCategoryUseCase: sl(),
      updateCategoryUseCase: sl(),
      deleteCategoryUseCase: sl(),
      authBloc: sl(),
    ),
  );

  // ============== Shop Feature ==============
  // Use cases
  sl.registerLazySingleton(() => GetShopUseCase(sl()));
  sl.registerLazySingleton(() => UpdateShopUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ShopRepository>(
    () => ShopRepositoryImpl(),
  );

  // ============== Settings / Printer ==============
  sl.registerLazySingleton<PrinterRepository>(
    () => PrinterRepositoryImpl(),
  );

  // ============== Billing Feature ==============
  sl.registerFactory(
    () => BillingBloc(
      getProductByBarcodeUseCase: sl(),
      getCurrentStockBulkUseCase: sl(),
      authBloc: sl(),
    ),
  );

  // ============== Staff Feature ==============
  // Use cases
  sl.registerLazySingleton(() => GetStaffMembersUseCase(sl()));
  sl.registerLazySingleton(() => DeleteStaffMemberUseCase(sl()));

  // Repository
  sl.registerLazySingleton<StaffRepository>(
    () => StaffRepositoryImpl(),
  );

  // Bloc
  sl.registerFactory(
    () => StaffBloc(
      getStaffMembersUseCase: sl(),
      deleteStaffMemberUseCase: sl(),
      authBloc: sl(),
    ),
  );

  // ============== Warranty Feature ==============
  // Repository
  sl.registerLazySingleton<WarrantyRepository>(
    () => WarrantyRepositoryImpl(),
  );

  // Use cases
  sl.registerLazySingleton(() => CreateWarrantyClaimUseCase(sl()));
  sl.registerLazySingleton(() => GetWarrantyClaimsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateClaimStatusUseCase(sl()));

  // Bloc
  sl.registerFactory(
    () => WarrantyBloc(
      createClaimUseCase: sl(),
      getClaimsUseCase: sl(),
      updateClaimStatusUseCase: sl(),
      authBloc: sl(),
    ),
  );

  // ============== Due Payments Feature ==============
  // Repository
  sl.registerLazySingleton<DuePaymentsRepository>(
    () => DuePaymentsRepositoryImpl(),
  );

  // Bloc
  sl.registerFactory(
    () => DuePaymentsBloc(
      repository: sl(),
      authBloc: sl(),
    ),
  );

  // ============== Customer Feature ==============
  // Repository
  sl.registerLazySingleton<CustomerRepository>(
    () => CustomerRepositoryImpl(),
  );

  // Bloc (shared singleton so the list + add pages stay in sync)
  sl.registerLazySingleton(
    () => CustomerBloc(
      repository: sl(),
      authBloc: sl(),
    ),
  );

  // ============== Stock Feature ==============
  // Repository
  sl.registerLazySingleton<StockRepository>(
    () => StockRepositoryImpl(),
  );

  // Bloc
  sl.registerFactory(
    () => StockBloc(
      stockRepository: sl(),
      authBloc: sl(),
    ),
  );

  // ============== Damaged Products Feature ==============
  // Repository
  sl.registerLazySingleton<DamagedProductsRepository>(
    () => DamagedProductsRepositoryImpl(),
  );

  // Bloc
  sl.registerFactory(
    () => DamagedProductsBloc(
      repository: sl(),
      authBloc: sl(),
    ),
  );

  // ============== Audit Feature ==============
  // Repository
  sl.registerLazySingleton<AuditRepository>(
    () => AuditRepositoryImpl(),
  );

  // Bloc
  sl.registerFactory(
    () => AuditBloc(
      auditRepository: sl(),
      authBloc: sl(),
    ),
  );

  // ============== Theme ==============
  sl.registerSingleton(ThemeCubit());

  // ============== Navigation ==============
  sl.registerSingleton(NavigationCubit());

  // ============== Report Feature ==============
  // Repository
  sl.registerLazySingleton<ReportRepository>(
    () => ReportRepositoryImpl(),
  );

  // Use cases
  sl.registerLazySingleton(() => GetBillHistoryUseCase(sl()));
  sl.registerLazySingleton(() => GetBillDetailUseCase(sl()));
  sl.registerLazySingleton(() => UpdateBillUseCase(sl()));
  sl.registerLazySingleton(() => DeleteBillUseCase(sl()));
  sl.registerLazySingleton(() => GetDailySalesUseCase(sl()));
  sl.registerLazySingleton(() => GetSalesRangeUseCase(sl()));
  sl.registerLazySingleton(() => GetLowStockProductsUseCase(sl()));
  sl.registerLazySingleton(() => GetStockMovementsUseCase(sl()));

  // Bloc
  sl.registerFactory(
    () => ReportBloc(
      getBillHistoryUseCase: sl(),
      getBillDetailUseCase: sl(),
      updateBillUseCase: sl(),
      deleteBillUseCase: sl(),
      getDailySalesUseCase: sl(),
      getSalesRangeUseCase: sl(),
      getLowStockProductsUseCase: sl(),
      getStockMovementsUseCase: sl(),
      authBloc: sl(),
    ),
  );
}
