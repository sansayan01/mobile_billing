import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/navigation/navigation_cubit.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/app_drawer.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  /// Outer shell scaffold — pages ke nested Scaffolds iske peeche chhupe hain.
  /// Drawer hamesha isi pe hai, isliye hamburger isko key se open karta hai.
  static final GlobalKey<ScaffoldState> scaffoldKey =
      GlobalKey<ScaffoldState>(debugLabel: 'shellScaffold');

  static const List<String> _fullScreenRoutes = [
    '/scan/scanner',
    '/scan/checkout',
    '/scan/receipt-preview',
  ];

  @override
  Widget build(BuildContext context) {
    // Get current route location from GoRouter.
    // NOTE: GoRouterState.of(context).matchedLocation can be stale inside a
    // ShellRoute builder when the sub-route was opened via context.push()
    // (imperative match) — e.g. checkout kept showing the bottom nav.
    // routerDelegate.currentConfiguration always reflects the REAL location.
    final currentRoute = GoRouter.of(context)
        .routerDelegate
        .currentConfiguration
        .uri
        .path;

    final isFullScreen =
        _fullScreenRoutes.any((r) => currentRoute.startsWith(r));

    return BlocBuilder<NavigationCubit, AppNavigationMode>(
      builder: (context, navMode) {
        final useBottomNav = navMode == AppNavigationMode.bottomNav;

        // NOTE: Do NOT wrap the whole shell in PopScope(canPop:false). That used to
        // swallow every Android back press and force go('/'), which closed the app
        // from sub-pages instead of returning to the dashboard. Individual pages
        // now pop normally; only DashboardPage guards the "back = exit app" case.
        return Scaffold(
          key: scaffoldKey,
          drawer: AppDrawer(currentRoute: currentRoute),
          body: child,
          extendBody: useBottomNav,
          bottomNavigationBar: useBottomNav && !isFullScreen
              ? AppBottomNav(currentRoute: currentRoute)
              : null,
        );
      },
    );
  }
}
