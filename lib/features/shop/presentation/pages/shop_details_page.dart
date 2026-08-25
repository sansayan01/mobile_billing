import 'package:billing_app/core/widgets/app_feedback.dart';
import 'package:billing_app/core/widgets/input_label.dart';
import 'package:billing_app/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import '../../../../core/widgets/adaptive_app_bar_leading.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/shop.dart';
import '../bloc/shop_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_validators.dart';

class ShopDetailsPage extends StatefulWidget {
  const ShopDetailsPage({super.key});

  @override
  State<ShopDetailsPage> createState() => _ShopDetailsPageState();
}

class _ShopDetailsPageState extends State<ShopDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _address1Controller;
  late TextEditingController _address2Controller;
  late TextEditingController _phoneController;
  late TextEditingController _upiController;
  late TextEditingController _footerController;
  Shop? _lastSyncedShop;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _address1Controller = TextEditingController();
    _address2Controller = TextEditingController();
    _phoneController = TextEditingController();
    _upiController = TextEditingController();
    _footerController = TextEditingController();

    // Load shop data
    context.read<ShopBloc>().add(LoadShopEvent());
  }

  void _updateControllers(Shop shop) {
    // Sync controllers only when the stored value actually changed — first
    // load fills everything; later reloads never clobber in-progress edits.
    final prev = _lastSyncedShop;
    if (prev == null || prev.name != shop.name) {
      _nameController.text = shop.name;
    }
    if (prev == null || prev.addressLine1 != shop.addressLine1) {
      _address1Controller.text = shop.addressLine1;
    }
    if (prev == null || prev.addressLine2 != shop.addressLine2) {
      _address2Controller.text = shop.addressLine2;
    }
    if (prev == null || prev.phoneNumber != shop.phoneNumber) {
      _phoneController.text = shop.phoneNumber;
    }
    if (prev == null || prev.upiId != shop.upiId) {
      _upiController.text = shop.upiId;
    }
    if (prev == null || prev.footerText != shop.footerText) {
      _footerController.text = shop.footerText;
    }
    _lastSyncedShop = shop;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _phoneController.dispose();
    _upiController.dispose();
    _footerController.dispose();
    super.dispose();
  }

  void _saveShop() {
    if (_formKey.currentState!.validate()) {
      final shop = Shop(
        name: _nameController.text,
        addressLine1: _address1Controller.text,
        addressLine2: _address2Controller.text,
        phoneNumber: _phoneController.text,
        upiId: _upiController.text,
        footerText: _footerController.text,
      );

      context.read<ShopBloc>().add(UpdateShopEvent(shop));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: const AdaptiveAppBarLeading(),
          title: const Text('Shop Details'),
        ),
        body: BlocConsumer<ShopBloc, ShopState>(
          listener: (context, state) {
            if (state is ShopLoaded) {
              _updateControllers(state.shop);
            } else if (state is ShopOperationSuccess) {
              AppFeedback.success(context, 'Shop details saved');
              if (Navigator.of(context).canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            } else if (state is ShopError) {
              AppFeedback.error(context, state.message);
            }
          },
          buildWhen: (previous, current) =>
              current is ShopLoading || current is ShopLoaded,
          builder: (context, state) {
            if (state is ShopLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _sectionCard(
                      context: context,
                      icon: Icons.storefront_rounded,
                      title: 'Shop Info',
                      subtitle:
                          'These details will appear on your digital and printed receipts.',
                      children: [
                        const InputLabel(text: 'Shop Name'),
                        _buildTextField(
                          controller: _nameController,
                          hint: 'e.g. QuickMart Superstore',
                          validator: AppValidators.required('Required'),
                        ),
                        const SizedBox(height: 16),
                        const InputLabel(text: 'Address Line 1'),
                        _buildTextField(
                          controller: _address1Controller,
                          hint: 'Samrajpet, Mecheri',
                          validator: AppValidators.required('Required'),
                        ),
                        const SizedBox(height: 16),
                        const InputLabel(text: 'Address Line 2 (Optional)'),
                        _buildTextField(
                          controller: _address2Controller,
                          hint: 'Salem - 636453',
                        ),
                        const SizedBox(height: 16),
                        const InputLabel(text: 'Phone Number'),
                        _buildTextField(
                          controller: _phoneController,
                          hint: '+91 7010674588',
                          keyboardType: TextInputType.phone,
                          validator: AppValidators.required('Required'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _sectionCard(
                      context: context,
                      icon: Icons.qr_code_2_rounded,
                      title: 'UPI & Payment',
                      children: [
                        const InputLabel(text: 'UPI ID'),
                        _buildTextField(
                          controller: _upiController,
                          hint: 'e.g. yourname@oksbi',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _sectionCard(
                      context: context,
                      icon: Icons.receipt_long_rounded,
                      title: 'Receipt Footer',
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const InputLabel(text: 'Footer Text'),
                            Text('Max 150 chars',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textTertiary(
                                        Theme.of(context).brightness))),
                          ],
                        ),
                        _buildTextField(
                          controller: _footerController,
                          hint: 'Thank you, Visit again!!!',
                          maxLines: 2,
                          maxLength: 60,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      onPressed: _saveShop,
                      icon: Icons.save_outlined,
                      label: 'Save Details',
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
  }

  Widget _sectionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    required List<Widget> children,
  }) {
    final b = Theme.of(context).brightness;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface(b),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border(b)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.accentSubtle,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 17, color: AppColors.accentText(b)),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                  color: AppColors.textPrimary(b),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                height: 1.35,
                color: AppColors.textTertiary(b),
              ),
            ),
          ],
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      textCapitalization: TextCapitalization.words,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
      ),
    );
  }
}
