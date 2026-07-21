import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:billing_app/core/theme/app_theme.dart';
import 'package:billing_app/core/widgets/primary_button.dart';
import 'package:billing_app/core/utils/printer_helper.dart';
import 'package:billing_app/core/data/hive_database.dart';
import 'package:billing_app/features/report/presentation/bloc/report_bloc.dart';
import 'package:billing_app/features/report/presentation/bloc/report_event.dart';
import 'package:billing_app/features/report/presentation/bloc/report_state.dart';
import 'package:billing_app/features/report/domain/entities/report_entities.dart';

class BillDetailPage extends StatefulWidget {
  final BillSummary bill;

  const BillDetailPage({super.key, required this.bill});

  @override
  State<BillDetailPage> createState() => _BillDetailPageState();
}

class _BillDetailPageState extends State<BillDetailPage> {
  bool _isPrinting = false;

  @override
  void initState() {
    super.initState();
    _fetchBillDetail();
  }

  void _fetchBillDetail() {
    context.read<ReportBloc>().add(LoadBillDetail(widget.bill.id));
  }

  Future<void> _printReceipt(BillSummary bill) async {
    if (_isPrinting) return;
    setState(() => _isPrinting = true);

    try {
      final printerHelper = PrinterHelper();

      if (!printerHelper.isConnected) {
        final savedMac = HiveDatabase.settingsBox.get('printer_mac');
        if (savedMac != null) {
          final connected = await printerHelper.connect(savedMac);
          if (!connected) {
            _showSnack('Failed to connect to printer', isError: true);
            return;
          }
        } else {
          _showSnack('Printer not configured', isError: true);
          return;
        }
      }

      final items = bill.items
          .map((item) => {
                'name': item.productName,
                'qty': item.quantity,
                'price': item.price,
                'total': item.total,
              })
          .toList();

      await printerHelper.printReceipt(
        shopName: '',
        address1: '',
        address2: '',
        phone: '',
        items: items,
        total: bill.grandTotal,
        footer: '',
        customerName: bill.customerName,
        customerPhone: bill.customerPhone,
      );

      _showSnack('Printed successfully', isError: false);
    } catch (e) {
      _showSnack('Print failed: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isPrinting = false);
      }
    }
  }

  void _showSnack(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.errorColor : Colors.green,
      ),
    );
  }

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
        ),
        title: const Text('Bill Details'),
      ),
      body: BlocBuilder<ReportBloc, ReportState>(
        buildWhen: (previous, current) =>
            previous.billDetail != current.billDetail ||
            previous.status != current.status,
        builder: (context, state) {
          final bill = state.billDetail ?? widget.bill;

          if (state.status == ReportStatus.loading &&
              state.billDetail == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == ReportStatus.error && state.billDetail == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.error ?? 'Something went wrong',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _fetchBillDetail,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
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
                    _infoRow('Payment Method', bill.paymentMethod.toUpperCase()),
                    if (bill.customerName != null && bill.customerName!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _infoRow('Customer Name', bill.customerName!),
                    ],
                    if (bill.customerPhone != null && bill.customerPhone!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _infoRow('Customer Phone', bill.customerPhone!),
                    ],
                  ],
                ),
                const SizedBox(height: 16),

                // Items card
                _buildInfoCard(
                  context,
                  title: 'Items',
                  children: [
                    if (bill.items.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'No items found',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      )
                    else
                      ...bill.items.map((item) {
                        final itemTotal = numberFormat.format(item.total);
                        final itemPrice = numberFormat.format(item.price);
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Qty badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${item.quantity}x',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Product name
                                  Expanded(
                                    child: Text(
                                      item.productName,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  // Price & Total
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        itemPrice,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                        itemTotal,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (item != bill.items.last) const Divider(height: 1),
                          ],
                        );
                      }),
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
                    if (bill.discount > 0) ...[
                      const SizedBox(height: 12),
                      _infoRow(
                        'Discount',
                        '-${numberFormat.format(bill.discount)}',
                        valueStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.green,
                        ),
                      ),
                    ],
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
                const SizedBox(height: 32),

                // Print button
                PrimaryButton(
                  onPressed: _isPrinting ? null : () => _printReceipt(bill),
                  label: _isPrinting ? 'Printing...' : 'Print Receipt',
                  icon: _isPrinting ? null : Icons.print,
                  isLoading: _isPrinting,
                ),
              ],
            ),
          );
        },
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
        Expanded(
          child: Text(
            value,
            style: valueStyle ??
                const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
