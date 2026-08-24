import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:billing_app/core/service_locator.dart';
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

  @override
  void initState() {
    super.initState();
    // Load on init. The bloc is a shared singleton (provided via get_it) so the
    // add page and this list stay in sync.
    sl<CustomerBloc>().add(const LoadCustomers());
  }

  @override
  void dispose() {
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
            icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).primaryColor),
            onPressed: () => context.go('/'),
          ),
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
                  sl<CustomerBloc>().add(SearchCustomers(value));
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/customers/add'),
          icon: const Icon(Icons.add),
          label: const Text('Add Customer'),
        ),
      ),
    ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isSearching = _searchController.text.trim().isNotEmpty;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            isSearching ? 'No matching customers' : 'No customers yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearching
                ? 'Try a different name or phone'
                : 'Tap + to add your first customer',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerTile(BuildContext context, Customer customer) {
    final initial = customer.name.isNotEmpty
        ? customer.name.trim()[0].toUpperCase()
        : '?';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: () => context.push('/customers/detail', extra: customer),
        leading: CircleAvatar(
          backgroundColor:
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
          child: Text(
            initial,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        title: Text(
          customer.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(customer.phone),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
