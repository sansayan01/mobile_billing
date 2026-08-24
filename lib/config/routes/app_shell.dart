import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/app_drawer.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Get current route location from GoRouter
    final routerState = GoRouterState.of(context);
    final currentRoute = routerState.matchedLocation;

    // NOTE: Do NOT wrap the whole shell in PopScope(canPop:false). That used to
    // swallow every Android back press and force go('/'), which closed the app
    // from sub-pages instead of returning to the dashboard. Individual pages
    // now pop normally; only DashboardPage guards the "back = exit app" case.
    return Scaffold(
      drawer: AppDrawer(currentRoute: currentRoute),
      body: child,
    );
  }
}
