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
    final goRouter = GoRouter.of(context);
    final currentRoute = routerState.matchedLocation;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        // System back → dashboard (GoRouter reference stored, not context-dependent)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          goRouter.go('/');
        });
      },
      child: Scaffold(
        drawer: AppDrawer(currentRoute: currentRoute),
        body: child,
      ),
    );
  }
}
