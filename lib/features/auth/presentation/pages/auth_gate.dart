import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:billing_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:billing_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:billing_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:billing_app/features/auth/presentation/pages/login_page.dart';

/// A wrapper widget that listens to [AuthBloc] state and shows either:
/// - [HomePage] (or any authenticated content widget) when the user is
///   authenticated
/// - [LoginPage] when the user is unauthenticated
/// - A splash / loading indicator while checking auth status
class AuthGate extends StatelessWidget {
  /// The widget to show when the user is authenticated.
  /// Typically a [HomePage] or a [Navigator]/[MaterialApp.router].
  final Widget authenticatedChild;

  const AuthGate({
    super.key,
    required this.authenticatedChild,
  });

  @override
  Widget build(BuildContext context) {
    // Dispatch CheckAuthStatus when this widget first appears.
    // This is safe because BlocProvider is above this widget in the tree.
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial) {
          // First time — trigger auth check
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<AuthBloc>().add(const CheckAuthStatus());
          });
          return const _SplashScreen();
        }

        if (state is AuthLoading) {
          return const _SplashScreen();
        }

        if (state is Authenticated) {
          return authenticatedChild;
        }

        // Unauthenticated or AuthError — show login
        return const LoginPage();
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_rounded,
              size: 80,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Billing App',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
