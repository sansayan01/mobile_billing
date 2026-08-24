import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../config/routes/app_shell.dart';
import '../navigation/navigation_cubit.dart';

class AdaptiveAppBarLeading extends StatelessWidget {
  const AdaptiveAppBarLeading({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, AppNavigationMode>(
      builder: (context, mode) {
        if (mode == AppNavigationMode.drawer) {
          return IconButton(
            icon: Icon(Icons.menu, color: Theme.of(context).primaryColor),
            onPressed: () =>
                AppShell.scaffoldKey.currentState?.openDrawer(),
            tooltip: 'Open menu',
          );
        }

        final route = GoRouterState.of(context).matchedLocation;
        if (route == '/') return const SizedBox.shrink();

        return IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
          tooltip: 'Back',
        );
      },
    );
  }
}
