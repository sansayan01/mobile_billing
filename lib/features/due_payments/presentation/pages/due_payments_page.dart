import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:billing_app/features/due_payments/presentation/bloc/due_payments_bloc.dart';
import 'package:billing_app/features/due_payments/domain/entities/due_payment.dart';
import 'package:billing_app/core/theme/app_colors.dart';
import 'package:billing_app/core/theme/app_typography.dart';
import 'package:billing_app/core/widgets/app_feedback.dart';
import 'package:billing_app/core/widgets/app_skeleton.dart';

class DuePaymentsPage extends StatefulWidget {
  const DuePaymentsPage({super.key});

  @override
  State<DuePaymentsPage> createState() => _DuePaymentsPageState();
}

class _DuePaymentsPageState extends State<DuePaymentsPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    context.read<DuePaymentsBloc>().add(const LoadDuePayments());
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  String _formatPrice(double value) {
    final fixed = value.toStringAsFixed(2);
    if (fixed.endsWith('.00')) {
      return fixed.substring(0, fixed.length - 3);
    }
    return fixed.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }

  void _showCollectPaymentDialog(DuePayment duePayment) {
    final b = Theme.of(context).brightness;
    final amountController = TextEditingController(
      text: _formatPrice(duePayment.dueAmount),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.payments, color: AppColors.accentText(b), size: 24),
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
                color: AppColors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Bill Total', style: TextStyle(fontSize: 13, color: AppColors.warningText(b))),
                      Text('₹${_formatPrice(duePayment.grandTotal)}', style: AppMoneyText.sized(13, FontWeight.w400, AppColors.warningText(b))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Already Paid', style: TextStyle(fontSize: 13, color: AppColors.successText(b))),
                      Text('₹${_formatPrice(duePayment.amountPaid)}', style: AppMoneyText.sized(13, FontWeight.w400, AppColors.successText(b))),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Due Amount', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      Text('₹${_formatPrice(duePayment.dueAmount)}', style: AppMoneyText.sized(17, FontWeight.w700, AppColors.warningText(b))),
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
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.onAccent,
            ),
          ),
        ],
      ),
    ).whenComplete(() => amountController.dispose());
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
          icon: Icon(Icons.arrow_back_ios, color: AppColors.accentText(Theme.of(context).brightness)),
          onPressed: () => context.go('/'),
        ),
      ),
      body: BlocConsumer<DuePaymentsBloc, DuePaymentsState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            AppFeedback.success(context, state.successMessage!);
          }
          if (state.error != null) {
            AppFeedback.error(context, state.error!);
          }
          // Consume the message so it can't re-fire on the next state change.
          // The bloc already reloads the list after a successful collect.
          if (state.successMessage != null || state.error != null) {
            context.read<DuePaymentsBloc>().add(const ClearDueMessages());
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
                  color: AppColors.warning,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.warning.withValues(alpha: 0.25),
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
                        color: AppColors.onAccent.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.account_balance_wallet, color: AppColors.onAccent, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Pending Due',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.onAccent.withValues(alpha: 0.85),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹${_formatPrice(state.totalPendingDue)}',
                          style: AppMoneyText.sized(
                            24,
                            FontWeight.bold,
                            AppColors.onAccent,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.onAccent.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${state.duePayments.length} bills',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onAccent,
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
                    // 400ms debounce: one query per pause, not per keystroke.
                    _searchDebounce?.cancel();
                    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
                      if (!mounted) return;
                      context
                          .read<DuePaymentsBloc>()
                          .add(SearchDuePayments(value.isEmpty ? null : value));
                    });
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
                                Icon(Icons.check_circle_outline, size: 64, color: AppColors.successText(Theme.of(context).brightness)),
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
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
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
    final b = Theme.of(context).brightness;
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
                    color: AppColors.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    duePayment.paymentMethod.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.warningText(b),
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
                  'Bill #${duePayment.billId.length >= 8 ? duePayment.billId.substring(0, 8) : duePayment.billId}',
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
                      Text('₹${_formatPrice(duePayment.grandTotal)}', style: AppMoneyText.sized(13, FontWeight.w400, Theme.of(context).colorScheme.onSurfaceVariant)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Paid', style: TextStyle(fontSize: 13, color: AppColors.successText(b))),
                      Text('₹${_formatPrice(duePayment.amountPaid)}', style: AppMoneyText.sized(13, FontWeight.w400, AppColors.successText(b))),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Due', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      Text('₹${_formatPrice(duePayment.dueAmount)}', style: AppMoneyText.sized(17, FontWeight.w700, AppColors.warningText(b))),
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
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.onAccent,
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
