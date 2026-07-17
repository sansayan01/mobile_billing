import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/email_verification_page.dart';
import '../../features/billing/presentation/pages/home_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/product/presentation/pages/product_list_page.dart';
import '../../features/product/presentation/pages/add_product_page.dart';
import '../../features/product/presentation/pages/edit_product_page.dart';
import '../../features/product/presentation/pages/qr_generator_page.dart';
import '../../features/report/presentation/pages/reports_home_page.dart';
import '../../features/report/presentation/pages/bill_history_page.dart';
import '../../features/report/presentation/pages/bill_detail_page.dart';
import '../../features/report/presentation/pages/daily_sales_page.dart';
import '../../features/report/presentation/pages/low_stock_page.dart';
import '../../features/report/presentation/pages/stock_movement_page.dart';
import '../../features/shop/presentation/pages/shop_details_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/billing/presentation/pages/scanner_page.dart';
import '../../features/billing/presentation/pages/checkout_page.dart';
import '../../features/product/domain/entities/product.dart';
import '../../features/report/domain/entities/report_entities.dart';
import '../../features/category/presentation/pages/category_list_page.dart';
import 'app_shell.dart';

GoRouter createRouter() {
  final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/login',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final authState = context.read<AuthBloc>().state;
      final isLoggedIn = authState is Authenticated;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/verify-email';

      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }

      // Agar logged in ho aur auth route par ho toh app mein bhejo.
      // (AuthGate hi verification pending ko handle karega agar logged in
      //  but unconfirmed hai — par verify-email direct route pe bhi jaa sakte hain.)
      if (isLoggedIn && (state.matchedLocation == '/login' ||
          state.matchedLocation == '/register')) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return EmailVerificationPage(email: email);
        },
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: '/scan',
            builder: (context, state) => const HomePage(),
            routes: [
              GoRoute(
                path: 'scanner',
                builder: (context, state) => const ScannerPage(),
              ),
              GoRoute(
                path: 'checkout',
                builder: (context, state) => const CheckoutPage(),
              ),
            ],
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsPage(),
          ),
          GoRoute(
            path: '/products',
            builder: (context, state) => const ProductListPage(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const AddProductPage(),
              ),
              GoRoute(
                path: 'edit/:id',
                builder: (context, state) {
                  final product = state.extra as Product?;
                  if (product == null) {
                    return const ProductListPage();
                  }
                  return EditProductPage(product: product);
                },
              ),
              GoRoute(
                path: 'qr/:id',
                builder: (context, state) {
                  final product = state.extra as Product?;
                  if (product == null) {
                    return const ProductListPage();
                  }
                  return QrGeneratorPage(product: product);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/categories',
            builder: (context, state) => const CategoryListPage(),
          ),
          GoRoute(
            path: '/shop',
            builder: (context, state) => const ShopDetailsPage(),
          ),
          GoRoute(
            path: '/reports',
            builder: (context, state) => const ReportsHomePage(),
            routes: [
              GoRoute(
                path: 'bills',
                builder: (context, state) => const BillHistoryPage(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final bill = state.extra;
                      if (bill == null) {
                        return const BillHistoryPage();
                      }
                      return BillDetailPage(bill: bill as BillSummary);
                    },
                  ),
                ],
              ),
              GoRoute(
                path: 'daily-sales',
                builder: (context, state) => const DailySalesPage(),
              ),
              GoRoute(
                path: 'low-stock',
                builder: (context, state) => const LowStockPage(),
              ),
              GoRoute(
                path: 'stock-movements',
                builder: (context, state) => const StockMovementPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
