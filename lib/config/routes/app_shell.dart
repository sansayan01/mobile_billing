import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/app_drawer.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Get current route location from GoRouter
    final router = GoRouterState.of(context);
    final currentRoute = router.matchedLocation;

    return Scaffold(
      drawer: AppDrawer(currentRoute: currentRoute),
      body: child,
    );
  }
}
