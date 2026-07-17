import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:billing_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:billing_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:billing_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:billing_app/core/widgets/app_back_button.dart';

/// Email verification pending screen.
///
/// SignUp ke baad agar email confirmation required hai (Supabase mein on hai),
/// toh user yahan aata hai. Yahan hum:
///  - Batate hain ki "verification link {email} par bhej diya hai"
///  - "Resend" button se dobara email bhej sakte hain
///  - "I've verified — Continue" se auth state re-check kar sakte hain
///  - "Back to Login" se wapas login par ja sakte hain
class EmailVerificationPage extends StatefulWidget {
  final String email;

  const EmailVerificationPage({super.key, required this.email});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  bool _isResending = false;
  bool _isChecking = false;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    // Auto-poll: har 3 sec check karo ki email confirm ho gayi kya.
    // Jab confirm ho jayega, AuthBloc → Authenticated emit karega
    // aur BlocListener neeche redirect kar dega.
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) context.read<AuthBloc>().add(const CheckAuthStatus());
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void _onResend() {
    setState(() => _isResending = true);
    context
        .read<AuthBloc>()
        .add(ResendVerificationEmailRequested(email: widget.email));
  }

  void _onContinue() {
    // AuthGate automatically sunta hai onAuthStateChange stream.
    // Yahan sirf ek refresh maangte hain taaki agar deep-link se
    // confirm ho chuka ho toh turant AuthGate redirect kare.
    setState(() => _isChecking = true);
    context.read<AuthBloc>().add(const CheckAuthStatus());
    // Loading state app ke response tak dikhate hain.
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _isChecking = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is ResendEmailSent || state is ResendEmailError) {
          if (mounted) setState(() => _isResending = false);
        }

        if (state is ResendEmailSent) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Verification email resent. Check your inbox.'),
              backgroundColor: Colors.green[700],
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is ResendEmailError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: theme.colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is Authenticated) {
          // Email confirm ho gayi (auto-poll ya manual continue) → dashboard.
          _pollTimer?.cancel();
          context.go('/');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: const AppBackButton(icon: Icons.arrow_back),
          title: const Text('Verify Email'),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Illustration / icon
                  Icon(
                    Icons.mark_email_unread_outlined,
                    size: 96,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Verify your email',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    'We sent a verification link to',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.email,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Open the link in the same device to confirm your account.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 36),

                  // Continue / refresh button
                  SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _isChecking ? null : _onContinue,
                      icon: _isChecking
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Icon(Icons.check_circle_outline),
                      label: const Text(
                        "I've verified — Continue",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Resend button
                  SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: _isResending ? null : _onResend,
                      icon: _isResending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Icon(Icons.refresh_outlined),
                      label: const Text('Resend verification email'),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Back to login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already verified? ',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Logout karke clean state bana do aur login par jao.
                          context.read<AuthBloc>().add(const LogoutRequested());
                          context.go('/login');
                        },
                        child: Text(
                          'Back to Login',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
