import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:billing_app/core/supabase/supabase_client.dart';
import 'package:billing_app/features/customer/domain/entities/customer.dart';

class CustomerDetailPage extends StatefulWidget {
  final Customer customer;

  const CustomerDetailPage({super.key, required this.customer});

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  late final Future<List<Map<String, dynamic>>> _billsFuture;
  late final Future<double> _dueBalanceFuture;
  late final Future<List<Map<String, dynamic>>> _warrantyFuture;

  @override
  void initState() {
    super.initState();
    _billsFuture = _fetchBills();
    _dueBalanceFuture = _fetchDueBalance();
    _warrantyFuture = _fetchWarrantyClaims();
  }

  Future<List<Map<String, dynamic>>> _fetchBills() async {
    try {
      final response = await SupabaseConfig.client
          .from('bills')
          .select()
          .eq('customer_id', widget.customer.id)
          .order('created_at', ascending: false)
          .limit(20);
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      return Future.error('Failed to load bills: $e');
    }
  }

  Future<double> _fetchDueBalance() async {
    try {
      final response = await SupabaseConfig.client
          .from('bills')
          .select('due_amount')
          .eq('customer_id', widget.customer.id)
          .inFilter('payment_status', ['partial', 'due'])
          .gt('due_amount', 0);
      final rows = List<Map<String, dynamic>>.from(response as List);
      return rows.fold<double>(
        0,
        (sum, r) => sum + ((r['due_amount'] as num?)?.toDouble() ?? 0.0),
      );
    } catch (e) {
      return Future.error('Failed to load due balance: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchWarrantyClaims() async {
    try {
      final response = await SupabaseConfig.client
          .from('warranty_claims')
          .select()
          .eq('customer_id', widget.customer.id)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      return Future.error('Failed to load warranty claims: $e');
    }
  }

  String _shortId(String? id) {
    if (id == null) return '';
    return id.length >= 8 ? id.substring(0, 8) : id;
  }

  @override
  Widget build(BuildContext context) {
    final customer = widget.customer;
    final initial =
        customer.name.isNotEmpty ? customer.name.trim()[0].toUpperCase() : '?';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              color: Theme.of(context).primaryColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.12),
                      child: Text(
                        initial,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer.name,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            customer.phone,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Bills
            _buildSectionTitle('Bills'),
            _buildBillsSection(),
            const SizedBox(height: 20),

            // Due balance
            _buildSectionTitle('Due Balance'),
            _buildDueBalanceSection(),
            const SizedBox(height: 20),

            // Warranty claims
            _buildSectionTitle('Warranty Claims'),
            _buildWarrantySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _emptyState(BuildContext context, String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          msg,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildBillsSection() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _billsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final bills = snapshot.data ?? [];
        if (bills.isEmpty) {
          return _emptyState(context, 'No records yet');
        }
        return Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: bills.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final bill = bills[index];
              final date = DateTime.tryParse(
                      bill['created_at']?.toString() ?? '') ??
                  DateTime(0);
              final grandTotal =
                  (bill['grand_total'] as num?)?.toDouble() ?? 0.0;
              return ListTile(
                title: Text('Bill #${_shortId(bill['id']?.toString())}',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle:
                    Text(DateFormat('dd MMM yyyy').format(date)),
                trailing: Text('₹${grandTotal.toStringAsFixed(2)}'),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDueBalanceSection() {
    return FutureBuilder<double>(
      future: _dueBalanceFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final total = snapshot.data ?? 0.0;
        if (total <= 0) {
          return _emptyState(context, 'No records yet');
        }
        return Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.account_balance_wallet,
                    color: Colors.orange.shade600),
                const SizedBox(width: 12),
                const Text('Total Pending', style: TextStyle(fontSize: 14)),
                const Spacer(),
                Text(
                  '₹${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWarrantySection() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _warrantyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final claims = snapshot.data ?? [];
        if (claims.isEmpty) {
          return _emptyState(context, 'No records yet');
        }
        return Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: claims.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final claim = claims[index];
              final date = DateTime.tryParse(
                      claim['created_at']?.toString() ?? '') ??
                  DateTime(0);
              final status = claim['status']?.toString() ?? 'unknown';
              return ListTile(
                title: Text('Claim #${_shortId(claim['id']?.toString())}'),
                subtitle: Text(DateFormat('dd MMM yyyy').format(date)),
                trailing: Chip(
                  label: Text(status),
                  visualDensity: VisualDensity.compact,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
