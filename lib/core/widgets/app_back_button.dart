import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shared back button for every page's AppBar `leading`.
///
/// Pops the current route when possible; falls back to the dashboard
/// (`/`) when there is nothing on the stack (e.g. the route was
/// reached via `context.go` instead of `context.push`).
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, this.icon = Icons.chevron_left, this.size = 28});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: size, color: Theme.of(context).primaryColor),
      tooltip: 'Back',
      onPressed: () {
        if (Navigator.of(context).canPop()) {
          context.pop();
        } else {
          context.go('/');
        }
      },
    );
  }
}
