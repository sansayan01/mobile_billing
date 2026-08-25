import 'package:flutter/material.dart';
import '../../../../core/widgets/adaptive_app_bar_leading.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/input_label.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class AddStaffPage extends StatefulWidget {
  const AddStaffPage({super.key});

  @override
  State<AddStaffPage> createState() => _AddStaffPageState();
}

class _AddStaffPageState extends State<AddStaffPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _submitted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    // Owner ki shop_id nikal lo — staff isi shop mein add hoga.
    final authState = context.read<AuthBloc>().state;
    final ownerShopId = authState is Authenticated ? authState.user.shopId : null;

    setState(() => _submitted = true);

    context.read<AuthBloc>().add(
          SignUpRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            name: _nameController.text.trim(),
            role: 'staff',
            shopId: ownerShopId,
            phone: _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final b = theme.brightness;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (!mounted) return;
        setState(() {
          _isLoading = state is AuthLoading;
        });

        if (!_submitted) return;

        // Staff signup success par AuthBloc session sign-out karke
        // Unauthenticated(kStaffAccountCreatedMessage) emit karta hai —
        // owner ki purani session hijack nahi hoti. Router redirect khud
        // login screen par le jaayega; hum sirf message dikhate hain.
        if (state is Unauthenticated &&
            state.message == kStaffAccountCreatedMessage) {
          _submitted = false;
          AppFeedback.success(context, state.message!);
          context.go('/login');
        } else if (state is EmailVerificationPending ||
            state is Authenticated) {
          // Fallback: confirmation-off projects mein signUp direct session
          // de sakta hai — phir bhi owner ko wapas bhejo.
          _submitted = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Staff account created.'),
              backgroundColor: theme.colorScheme.primaryContainer,
            ),
          );
          context.pop();
        } else if (state is AuthError) {
          _submitted = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final isOwner = state is Authenticated && state.user.role == 'owner';

          // Sirf owner hi staff add kar sakta hai.
          if (!isOwner) {
            return Scaffold(
              appBar: AppBar(
                leading: const AdaptiveAppBarLeading(),
                title: const Text('Add Staff'),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.block_rounded,
                        size: 56, color: AppColors.textTertiary(b)),
                    const SizedBox(height: 16),
                    Text(
                      'Only the shop owner can add staff.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary(b),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Scaffold(
            appBar: AppBar(
              leading: const AdaptiveAppBarLeading(),
              title: const Text('Add Staff'),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),

                      // Header
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.accentSubtle,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.person_add_alt_1_rounded,
                              size: 20,
                              color: AppColors.accentText(b),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'New Staff Member',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary(b),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Added to your shop instantly',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textTertiary(b),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Form card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surface(b),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border(b)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Full Name
                            const InputLabel(text: 'Full Name'),
                            TextFormField(
                              controller: _nameController,
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                hintText: 'Enter staff name',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter staff name';
                                }
                                if (value.trim().length < 2) {
                                  return 'Name must be at least 2 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Email
                            const InputLabel(text: 'Email'),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                hintText: 'Enter staff email',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter email';
                                }
                                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                    .hasMatch(value.trim())) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Phone (optional)
                            const InputLabel(text: 'Phone (optional)'),
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                hintText: 'Enter phone number',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return null; // optional
                                }
                                if (value.trim().length < 8) {
                                  return 'Enter a valid phone';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Password
                            const InputLabel(text: 'Password'),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              decoration: InputDecoration(
                                hintText: 'Create a password',
                                suffixIconColor:
                                    AppColors.textTertiary(b),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: AppColors.textTertiary(b),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword =
                                          !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Note
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline_rounded,
                              size: 15, color: AppColors.textTertiary(b)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Staff will be added to your shop and can log in with these credentials.',
                              style: TextStyle(
                                color: AppColors.textTertiary(b),
                                fontSize: 12.5,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Submit
                      PrimaryButton(
                        label: 'Add Staff',
                        icon: Icons.person_add_rounded,
                        isLoading: _isLoading,
                        onPressed: _isLoading ? null : _onSubmit,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
