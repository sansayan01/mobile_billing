import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:billing_app/core/service_locator.dart';
import 'package:billing_app/core/theme/app_colors.dart';
import 'package:billing_app/core/widgets/app_feedback.dart';
import 'package:billing_app/core/widgets/app_skeleton.dart';
import 'package:billing_app/features/customer/domain/entities/customer.dart';
import 'package:billing_app/features/customer/presentation/bloc/customer_bloc.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    // Load on init. The bloc is a shared singleton (provided via get_it) so the
    // add page and this list stay in sync.
    sl<CustomerBloc>().add(const LoadCustomers());
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<CustomerBloc>(),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) => context.go('/'),
        child: Scaffold(
        appBar: AppBar(
          title: const Text('Customers',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios,
                color: AppColors.textPrimary(
                    Theme.of(context).brightness),
                size: 20),
            onPressed: () => context.go('/'),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.onAccent,
          onPressed: () => context.push('/customers/add'),
          child: const Icon(Icons.person_add_rounded),
        ),
        body: Column(
          children: [
            // Search Bar (reuses the due_payments / product search UX)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by name or phone...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                            sl<CustomerBloc>().add(const SearchCustomers(''));
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  isDense: true,
                ),
                onChanged: (value) {
                  setState(() {});
                  // 400ms debounce: one query per pause, not per keystroke.
                  _searchDebounce?.cancel();
                  _searchDebounce = Timer(const Duration(milliseconds: 400), () {
                    if (!mounted) return;
                    sl<CustomerBloc>().add(SearchCustomers(value));
                  });
                },
              ),
            ),
            const SizedBox(height: 16),

            // Customers List
            Expanded(
              child: BlocConsumer<CustomerBloc, CustomerState>(
                listener: (context, state) {
                  if (state.error != null) {
                    AppFeedback.error(context, state.error!);
                    sl<CustomerBloc>().add(const ClearCustomerMessage());
                  }
                },
                builder: (context, state) {
                  if (state.isLoading && state.customers.isEmpty) {
                    return const SingleChildScrollView(
                      child: AppSkeletonList(itemCount: 6),
                    );
                  }

                  if (state.customers.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                    itemCount: state.customers.length,
                    itemBuilder: (context, index) {
                      final customer = state.customers[index];
                      return _buildCustomerTile(context, customer);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final b = Theme.of(context).brightness;
    final isSearching = _searchController.text.trim().isNotEmpty;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.accentSubtle,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.people_outline,
              size: 36,
              color: AppColors.accentText(b),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isSearching ? 'No matching customers' : 'No customers yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(b),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isSearching
                ? 'Try a different name or phone'
                : 'Tap + to add your first customer',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textTertiary(b),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerTile(BuildContext context, Customer customer) {
    final theme = Theme.of(context);
    final b = theme.brightness;
    final initial = customer.name.isNotEmpty
        ? customer.name.trim()[0].toUpperCase()
        : '?';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface(b),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(b)),
      ),
      child: ListTile(
        onTap: () => context.push('/customers/detail', extra: customer),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            initial,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary(b),
            ),
          ),
        ),
        title: Text(
          customer.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(b),
          ),
        ),
        subtitle: Text(
          customer.phone,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textTertiary(b),
          ),
        ),
        trailing: Icon(Icons.chevron_right,
            size: 20, color: AppColors.textTertiary(b)),
      ),
    );
  }
}
