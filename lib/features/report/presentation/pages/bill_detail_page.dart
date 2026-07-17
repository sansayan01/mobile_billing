import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:billing_app/core/theme/app_theme.dart';
import 'package:billing_app/core/widgets/primary_button.dart';
import 'package:billing_app/features/report/domain/entities/report_entities.dart';

class BillDetailPage extends StatelessWidget {
  final BillSummary bill;

  const BillDetailPage({super.key, required this.bill});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final numberFormat =
        NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu, color: Theme.of(context).primaryColor),
          onPressed: () => Scaffold.of(context).openDrawer(),
          tooltip: 'Open menu',
        ),
        title: const Text('Bill Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bill Info card
            _buildInfoCard(
              context,
              title: 'Bill Info',
              children: [
                _infoRow('Bill ID', bill.id),
                const SizedBox(height: 12),
                _infoRow('Staff', bill.staffName),
                const SizedBox(height: 12),
                _infoRow(
                  'Date',
                  dateFormat.format(bill.createdAt),
                ),
                const SizedBox(height: 12),
                _infoRow('Payment Method', bill.paymentMethod),
              ],
            ),
            const SizedBox(height: 16),

            // Amount Summary card
            _buildInfoCard(
              context,
              title: 'Amount Summary',
              children: [
                _infoRow(
                  'Total Amount',
                  numberFormat.format(bill.totalAmount),
                ),
                const SizedBox(height: 12),
                _infoRow(
                  'Discount',
                  numberFormat.format(bill.discount),
                ),
                const SizedBox(height: 12),
                const Divider(),
                _infoRow(
                  'Grand Total',
                  numberFormat.format(bill.grandTotal),
                  valueStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Items card
            _buildInfoCard(
              context,
              title: 'Items',
              children: [
                _infoRow('Item Count', '${bill.itemCount}'),
              ],
            ),
            const SizedBox(height: 32),

            // Print button
            PrimaryButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Print functionality coming soon'),
                  ),
                );
              },
              label: 'Print Receipt',
              icon: Icons.print,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(
    String label,
    String value, {
    TextStyle? valueStyle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: valueStyle ??
              const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
