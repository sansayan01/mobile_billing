import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:billing_app/core/service_locator.dart';
import 'package:billing_app/core/theme/app_colors.dart';
import 'package:billing_app/core/utils/phone_utils.dart';
import 'package:billing_app/features/customer/domain/entities/customer.dart';
import 'package:billing_app/features/customer/presentation/bloc/customer_bloc.dart';

class AddCustomerPage extends StatefulWidget {
  /// When [editCustomer] is provided the page runs in EDIT mode —
  /// fields pre-fill and save dispatches UpdateCustomer instead.
  final Customer? editCustomer;

  const AddCustomerPage({super.key, this.editCustomer});

  @override
  State<AddCustomerPage> createState() => _AddCustomerPageState();
}

class _AddCustomerPageState extends State<AddCustomerPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool get _isEdit => widget.editCustomer != null;

  @override
  void initState() {
    super.initState();
    final c = widget.editCustomer;
    if (c != null) {
      _nameController.text = c.name;
      _phoneController.text = c.phone;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a name',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    if (!isValidPhone(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid 10-digit phone number',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    if (_isEdit) {
      sl<CustomerBloc>().add(UpdateCustomer(
        widget.editCustomer!.copyWith(name: name, phone: phone),
      ));
    } else {
      sl<CustomerBloc>().add(AddCustomer(name: name, phone: phone));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<CustomerBloc>(),
      child: BlocConsumer<CustomerBloc, CustomerState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!,
                    style: const TextStyle(
                        color: AppColors.onAccent,
                        fontWeight: FontWeight.w600)),
                backgroundColor: AppColors.success,
              ),
            );
            sl<CustomerBloc>().add(const ClearCustomerMessage());
            context.pop();
          } else if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
            sl<CustomerBloc>().add(const ClearCustomerMessage());
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(_isEdit ? 'Edit Customer' : 'Add Customer',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios,
                    color: AppColors.accentText(Theme.of(context).brightness)),
                onPressed: () => context.pop(),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      prefixIcon: const Icon(Icons.person_outline, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone',
                      prefixIcon: const Icon(Icons.phone, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: state.isLoading ? null : _save,
                      icon: state.isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.onAccent,
                              ),
                            )
                          : const Icon(Icons.save, size: 18),
                      label: Text(state.isLoading ? 'Saving...' : (_isEdit ? 'Update' : 'Save')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.onAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
