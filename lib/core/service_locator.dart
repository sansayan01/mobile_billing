import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/login_with_google_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/signup_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/category/data/repositories/category_repository_impl.dart';
import '../../features/category/domain/repositories/category_repository.dart';
import '../../features/category/domain/usecases/category_usecases.dart';
import '../../features/category/presentation/bloc/category_bloc.dart';
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
import 'realtime/realtime_service.dart';

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
  sl.registerLazySingleton(() => LoginWithGoogleUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      signUpUseCase: sl(),
      loginWithGoogleUseCase: sl(),
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
  sl.registerLazySingleton(() => GetProductsByCategoryUseCase(sl()));
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

  // ============== Report Feature ==============
  // Repository
  sl.registerLazySingleton<ReportRepository>(
    () => ReportRepositoryImpl(),
  );

  // Use cases
  sl.registerLazySingleton(() => GetBillHistoryUseCase(sl()));
  sl.registerLazySingleton(() => GetBillDetailUseCase(sl()));
  sl.registerLazySingleton(() => GetDailySalesUseCase(sl()));
  sl.registerLazySingleton(() => GetSalesRangeUseCase(sl()));
  sl.registerLazySingleton(() => GetLowStockProductsUseCase(sl()));
  sl.registerLazySingleton(() => GetStockMovementsUseCase(sl()));

  // Bloc
  sl.registerFactory(
    () => ReportBloc(
      getBillHistoryUseCase: sl(),
      getBillDetailUseCase: sl(),
      getDailySalesUseCase: sl(),
      getSalesRangeUseCase: sl(),
      getLowStockProductsUseCase: sl(),
      getStockMovementsUseCase: sl(),
      authBloc: sl(),
    ),
  );
}
