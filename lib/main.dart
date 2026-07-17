import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'config/routes/app_routes.dart';
import 'core/data/hive_database.dart';
import 'core/service_locator.dart' as di;
import 'core/supabase/supabase_client.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/billing/presentation/bloc/billing_bloc.dart';
import 'features/category/presentation/bloc/category_bloc.dart';
import 'features/product/presentation/bloc/product_bloc.dart';
import 'features/report/presentation/bloc/report_bloc.dart';
import 'features/shop/presentation/bloc/shop_bloc.dart';
import 'features/settings/presentation/bloc/printer_bloc.dart';
import 'features/settings/presentation/bloc/printer_event.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  await HiveDatabase.init();
  await di.init();

  // Auth state subscription ek baar hi setup — MyApp ke build() mein nahi,
  // warna har rebuild par naye listener banenge → infinite loop + spam logout.
  di.sl<AuthBloc>().subscribeToAuthChanges(
    () => di.sl<AuthRepository>().authStateChanges,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => di.sl<AuthBloc>()..add(const CheckAuthStatus()),
        ),
        BlocProvider<ProductBloc>(
            create: (context) => di.sl<ProductBloc>()
              ..add(LoadProducts())
              ..add(InitRealtime())),
        BlocProvider<ShopBloc>(
            create: (context) => di.sl<ShopBloc>()..add(LoadShopEvent())),
        BlocProvider<BillingBloc>(
            create: (context) => di.sl<BillingBloc>()),
        BlocProvider<CategoryBloc>(
            create: (context) => di.sl<CategoryBloc>()..add(LoadCategories())),
        BlocProvider<ReportBloc>(
            create: (context) => di.sl<ReportBloc>()),
        BlocProvider<PrinterBloc>(
            create: (context) => di.sl<PrinterBloc>()..add(InitPrinterEvent())),
      ],
      child: MaterialApp.router(
        title: 'Billing App',
        theme: AppTheme.lightTheme,
        routerConfig: createRouter(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
