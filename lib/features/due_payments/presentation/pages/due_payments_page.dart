import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:billing_app/features/due_payments/presentation/bloc/due_payments_bloc.dart';
import 'package:billing_app/features/due_payments/domain/entities/due_payment.dart';
import 'package:billing_app/core/widgets/app_feedback.dart';
import 'package:billing_app/core/widgets/app_skeleton.dart';

class DuePaymentsPage extends StatefulWidget {
  const DuePaymentsPage({super.key});

  @override
  State<DuePaymentsPage> createState() => _DuePaymentsPageState();
}

class _DuePaymentsPageState extends State<DuePaymentsPage> {
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    context.read<DuePaymentsBloc>().add(const LoadDuePayments());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatPrice(double value) {
    final fixed = value.toStringAsFixed(2);
    if (fixed.endsWith('.00')) {
      return fixed.substring(0, fixed.length - 3);
    }
    return fixed.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\\.$'), '');
  }

  void _showCollectPaymentDialog(DuePayment duePayment) {
    final amountController = TextEditingController(
      text: _formatPrice(duePayment.dueAmount),
    );
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.payments, color: Theme.of(context).primaryColor, size: 24),
            const SizedBox(width: 8),
            const Expanded(
              child: Text('Collect Payment', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer info
            if (duePayment.customerName != null && duePayment.customerName!.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.person, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            duePayment.customerName!,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          if (duePayment.customerPhone != null && duePayment.customerPhone!.isNotEmpty)
                            Text(
                              duePayment.customerPhone!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            
            // Due amount summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Bill Total', style: TextStyle(fontSize: 13, color: Colors.orange.shade700)),
                      Text('₹${_formatPrice(duePayment.grandTotal)}', style: TextStyle(fontSize: 13, color: Colors.orange.shade700)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Already Paid', style: TextStyle(fontSize: 13, color: Colors.green.shade700)),
                      Text('₹${_formatPrice(duePayment.amountPaid)}', style: TextStyle(fontSize: 13, color: Colors.green.shade700)),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Due Amount', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      Text('₹${_formatPrice(duePayment.dueAmount)}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.orange)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Amount input
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter amount to collect',
                prefixIcon: const Icon(Icons.currency_rupee, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              final amount = double.tryParse(amountController.text.trim());
              if (amount != null && amount > 0 && amount <= duePayment.dueAmount) {
                context.read<DuePaymentsBloc>().add(CollectPayment(
                  billId: duePayment.billId,
                  amount: amount,
                ));
                Navigator.of(ctx).pop();
              } else {
                AppFeedback.error(context, 'Please enter a valid amount');
              }
            },
            icon: const Icon(Icons.check_circle, size: 18),
            label: const Text('Collect'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.surface,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Due Payments',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).primaryColor),
          onPressed: () => context.go('/'),
        ),
      ),
      body: BlocConsumer<DuePaymentsBloc, DuePaymentsState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            AppFeedback.success(context, state.successMessage!);
            context.read<DuePaymentsBloc>().add(const LoadDuePayments());
          }
          if (state.error != null) {
            AppFeedback.error(context, state.error!);
            context.read<DuePaymentsBloc>().add(const LoadDuePayments());
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // Total Pending Due Card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.shade400,
                      Colors.orange.shade600,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.shade200,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Pending Due',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹${_formatPrice(state.totalPendingDue)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${state.duePayments.length} bills',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by customer name or bill ID...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              context.read<DuePaymentsBloc>().add(const SearchDuePayments(null));
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    isDense: true,
                  ),
                  onChanged: (value) {
                    setState(() {});
                    context.read<DuePaymentsBloc>().add(SearchDuePayments(value.isEmpty ? null : value));
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Due Payments List
              Expanded(
                child: state.isLoading
                    ? const SingleChildScrollView(
                        child: AppSkeletonList(itemCount: 6),
                      )
                    : state.duePayments.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_outline, size: 64, color: Colors.green.shade300),
                                const SizedBox(height: 16),
                                Text(
                                  'No pending dues!',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'All bills are fully paid',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: state.duePayments.length,
                            itemBuilder: (context, index) {
                              final duePayment = state.duePayments[index];
                              return _buildDuePaymentCard(duePayment);
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDuePaymentCard(DuePayment duePayment) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final billDate = dateFormat.format(duePayment.billDate);
    
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    duePayment.paymentMethod.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  billDate,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Text(
                  'Bill #${duePayment.billId.substring(0, 8)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Customer Info
            if (duePayment.customerName != null && duePayment.customerName!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.person_outline, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            duePayment.customerName!,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          if (duePayment.customerPhone != null && duePayment.customerPhone!.isNotEmpty)
                            Text(
                              duePayment.customerPhone!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Amount Details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Bill Total', style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      Text('₹${_formatPrice(duePayment.grandTotal)}', style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Paid', style: TextStyle(fontSize: 13, color: Colors.green.shade600)),
                      Text('₹${_formatPrice(duePayment.amountPaid)}', style: TextStyle(fontSize: 13, color: Colors.green.shade600)),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Due', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      Text('₹${_formatPrice(duePayment.dueAmount)}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.orange)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Collect Payment Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showCollectPaymentDialog(duePayment),
                icon: const Icon(Icons.payment, size: 18),
                label: const Text('Collect Payment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.surface,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
