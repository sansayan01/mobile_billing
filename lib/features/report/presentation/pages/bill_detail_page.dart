// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import '../../../../core/widgets/adaptive_app_bar_leading.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:billing_app/core/theme/app_colors.dart';
import 'package:billing_app/core/theme/app_typography.dart';
import 'package:billing_app/core/widgets/app_feedback.dart';
import 'package:billing_app/core/widgets/primary_button.dart';
import 'package:billing_app/core/utils/printer_helper.dart';
import 'package:billing_app/core/data/hive_database.dart';
import 'package:billing_app/core/service_locator.dart';
import 'package:billing_app/core/usecase/usecase.dart';
import 'package:billing_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:billing_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:billing_app/features/report/presentation/bloc/report_bloc.dart';
import 'package:billing_app/features/report/presentation/bloc/report_event.dart';
import 'package:billing_app/features/report/presentation/bloc/report_state.dart';
import 'package:billing_app/features/report/domain/entities/report_entities.dart';
import 'package:billing_app/features/product/domain/entities/product.dart';
import 'package:billing_app/features/product/domain/usecases/product_usecases.dart';
import 'package:billing_app/features/shop/presentation/bloc/shop_bloc.dart';
import 'package:billing_app/features/due_payments/domain/repositories/due_payments_repository.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

class BillDetailPage extends StatefulWidget {
  final BillSummary bill;

  const BillDetailPage({super.key, required this.bill});

  @override
  State<BillDetailPage> createState() => _BillDetailPageState();
}

class _BillDetailPageState extends State<BillDetailPage> {
  bool _isPrinting = false;
  bool _isSharing = false;

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

    // Real shop details from ShopBloc (fallback to blanks if not loaded).
    String shopName = '';
    String address1 = '';
    String address2 = '';
    String phone = '';
    final shopState = context.read<ShopBloc>().state;
    if (shopState is ShopLoaded) {
      shopName = shopState.shop.name;
      address1 = shopState.shop.addressLine1;
      address2 = shopState.shop.addressLine2;
      phone = shopState.shop.phoneNumber;
    }

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
        shopName: shopName,
        address1: address1,
        address2: address2,
        phone: phone,
        items: items,
        total: bill.grandTotal,
        footer: '',
        customerName: bill.customerName,
        customerPhone: bill.customerPhone,
      );

      _showSnack('Printed successfully', isError: false);
    } catch (e) {
      _showSnack('Print failed. Check printer connection and try again.',
          isError: true);
    } finally {
      if (mounted) {
        setState(() => _isPrinting = false);
      }
    }
  }

  void _showSnack(String message, {required bool isError}) {
    if (!mounted) return;
    if (isError) {
      AppFeedback.error(context, message);
    } else {
      AppFeedback.success(context, message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final numberFormat =
        NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    final authState = context.read<AuthBloc>().state;
    final isOwner = authState is Authenticated && authState.user.role == 'owner';

    return BlocListener<ReportBloc, ReportState>(
      listenWhen: (previous, current) =>
          (!previous.billDeleted && current.billDeleted) ||
          (previous.message != current.message && current.message != null),
      listener: (context, state) {
        if (state.billDeleted) {
          Navigator.of(context).pop();
          return;
        }
        if (state.message != null) {
          _showSnack(state.message!, isError: state.status == ReportStatus.error);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: const AdaptiveAppBarLeading(),
          title: const Text('Bill Details'),
          actions: isOwner
              ? [
                  IconButton(
                    icon: Icon(Icons.edit,
                        color: AppColors.accentText(theme.brightness)),
                    onPressed: () => _showEditDialog(context),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: theme.colorScheme.error),
                    onPressed: () => _confirmDelete(context),
                  ),
                ]
              : null,
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
                      color: theme.colorScheme.error,
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

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
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
                    const SizedBox(height: 12),
                    _buildPaymentStatusRow(bill),
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
                            color: theme.colorScheme.onSurfaceVariant,
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
                                      color: AppColors.accentSubtle,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${item.quantity}x',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.accentText(theme.brightness),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Product name + warranty
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.productName,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        if (item.hasWarranty)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 2),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                              decoration: BoxDecoration(
                                                color: AppColors.info.withValues(alpha: 0.14),
                                                borderRadius: BorderRadius.circular(4),
                                                border: Border.all(color: AppColors.info.withValues(alpha: 0.35)),
                                              ),
                                              child: Text(
                                                item.warrantyLabel,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: AppColors.infoText(theme.brightness),
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  // Price & Total
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        itemPrice,
                                        style: AppMoneyText.sized(
                                          12,
                                          FontWeight.w400,
                                          theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      Text(
                                        itemTotal,
                                        style: AppMoneyText.sized(
                                          14,
                                          FontWeight.w600,
                                          theme.colorScheme.onSurface,
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
                      valueStyle: AppMoneyText.sized(
                        15,
                        FontWeight.w500,
                        theme.colorScheme.onSurface,
                      ),
                    ),
                    if (bill.discount > 0) ...[
                      const SizedBox(height: 12),
                      _infoRow(
                        'Discount',
                        '-${numberFormat.format(bill.discount)}',
                        valueStyle: AppMoneyText.sized(
                          15,
                          FontWeight.w500,
                          AppColors.accentText(theme.brightness).withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    const Divider(),
                    _infoRow(
                      'Grand Total',
                      numberFormat.format(bill.grandTotal),
                      valueStyle: AppMoneyText.sized(
                        18,
                        FontWeight.bold,
                        AppColors.accentText(theme.brightness),
                      ),
                    ),
                    // Payment breakdown for due bills
                    if (bill.hasDue) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Amount Paid', style: TextStyle(fontSize: 13, color: AppColors.successText(theme.brightness))),
                                Text(numberFormat.format(bill.amountPaid), style: AppMoneyText.sized(13, FontWeight.w600, AppColors.successText(theme.brightness))),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Due Amount', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                                Text(numberFormat.format(bill.dueAmount), style: AppMoneyText.sized(17, FontWeight.w700, AppColors.warningText(theme.brightness))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),

                // Collect Payment button for due bills
                if (bill.hasDue)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showCollectPaymentDialog(context, bill),
                      icon: const Icon(Icons.payments, size: 18),
                      label: const Text('Collect Payment'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: AppColors.onAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // Payment Timeline
                if (bill.hasDue || bill.amountPaid > 0) ...[
                  _buildPaymentTimeline(bill),
                  const SizedBox(height: 16),
                ],

                // Customer History
                _buildCustomerHistory(bill),
                const SizedBox(height: 16),

                // Action Buttons Row
                Row(children: [
                  Expanded(
                    child: _actionBtn('WhatsApp', Icons.share_rounded, Colors.green, () => _shareOnWhatsApp(bill)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _actionBtn('Notes', Icons.notes_rounded, AppColors.accentText(theme.brightness), () => _showNotesDialog(context, bill)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Tooltip(
                      message: 'Coming soon',
                      child: _actionBtn('Void', Icons.cancel_outlined,
                          AppColors.warningText(theme.brightness), null),
                    ),
                  ),
                ]),
                const SizedBox(height: 12),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
              // Sticky footer — pinned above floating nav
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                child: PrimaryButton(
                  onPressed: _isPrinting ? null : () => _printReceipt(bill),
                  label: _isPrinting ? 'Printing...' : 'Print Receipt',
                  icon: _isPrinting ? null : Icons.print,
                  isLoading: _isPrinting,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          );
        },
      ),
    ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  HIDDEN RECEIPT WIDGET (for WhatsApp screenshot)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildReceiptWidget(BillSummary bill) {
    final nf = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final dateFormat = DateFormat('dd-MM-yyyy hh:mm a');
    return Container(
      width: 360,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Shop header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
            child: Column(
              children: [
                const Text('Receipt', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.black87)),
                const SizedBox(height: 6),
                Text(dateFormat.format(bill.createdAt), textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: Divider(height: 24, thickness: 1)),
          // Bill info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _receiptInfoRow('Bill ID', bill.id.substring(0, bill.id.length > 8 ? 8 : bill.id.length)),
                const SizedBox(height: 4),
                _receiptInfoRow('Staff', bill.staffName),
                const SizedBox(height: 4),
                _receiptInfoRow('Payment', bill.paymentMethod.toUpperCase()),
                if (bill.customerName != null && bill.customerName!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _receiptInfoRow('Customer', bill.customerName!),
                ],
              ],
            ),
          ),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: Divider(height: 24, thickness: 1)),
          // Items header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: const [
                Expanded(flex: 3, child: Text('Item', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.black54))),
                Expanded(flex: 1, child: Text('Qty', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.black54), textAlign: TextAlign.center)),
                Expanded(flex: 2, child: Text('Total', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.black54), textAlign: TextAlign.right)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Items
          ...bill.items.map((item) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text(item.productName, style: const TextStyle(fontSize: 14, color: Colors.black87), overflow: TextOverflow.ellipsis)),
                Expanded(flex: 1, child: Text('${item.quantity}x', textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: Colors.black54))),
                Expanded(flex: 2, child: Text(nf.format(item.total), textAlign: TextAlign.right, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87))),
              ],
            ),
          )),
          const SizedBox(height: 12),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: Divider(thickness: 1)),
          // Grand total
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('GRAND TOTAL', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black87)),
                Text(nf.format(bill.grandTotal), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.black87)),
              ],
            ),
          ),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: Divider(thickness: 1)),
          // Footer
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Text('Thank you for your purchase!', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _receiptInfoRow(String label, String value) {
    return Row(
      children: [
        Text('$label: ', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54)),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13, color: Colors.black87))),
      ],
    );
  }

  void _showEditDialog(BuildContext context) {
    final theme = Theme.of(context);
    final bill = context.read<ReportBloc>().state.billDetail ?? widget.bill;
    final nameController = TextEditingController(text: bill.customerName ?? '');
    final phoneController = TextEditingController(text: bill.customerPhone ?? '');
    final discountController =
        TextEditingController(text: bill.discount.toString());

    // Editable items list — start with current bill items
    final List<BillItem> editItems = List.from(bill.items);
    String paymentMethod = bill.paymentMethod;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Calculate totals live
            final totalAmount = editItems.fold<double>(
                0, (sum, item) => sum + item.price * item.quantity);
            final discount =
                double.tryParse(discountController.text) ?? 0.0;
            final grandTotal = totalAmount - discount;

            return AlertDialog(
              title: const Text('Edit Bill'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Customer Name
                      TextField(
                        controller: nameController,
                        decoration:
                            const InputDecoration(labelText: 'Customer Name'),
                      ),
                      const SizedBox(height: 12),

                      // Customer Phone
                      TextField(
                        controller: phoneController,
                        decoration:
                            const InputDecoration(labelText: 'Customer Phone'),
                      ),
                      const SizedBox(height: 12),

                      // Payment Method Dropdown
                      DropdownButtonFormField<String>(
                        initialValue: paymentMethod,
                        decoration: const InputDecoration(
                            labelText: 'Payment Method'),
                        items: const [
                          DropdownMenuItem(value: 'upi', child: Text('UPI')),
                          DropdownMenuItem(value: 'cash', child: Text('Cash')),
                          DropdownMenuItem(value: 'card', child: Text('Card')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() => paymentMethod = value);
                          }
                        },
                      ),
                      const SizedBox(height: 12),

                      // Discount
                      TextField(
                        controller: discountController,
                        decoration:
                            const InputDecoration(labelText: 'Discount'),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}')),
                        ],
                        onChanged: (_) => setDialogState(() {}),
                      ),
                      const SizedBox(height: 16),

                      // Items Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Items',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _showProductSearchDialog(
                              context,
                              editItems,
                              setDialogState,
                            ),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add Item'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      if (editItems.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text(
                              'No items. Tap "Add Item" to add products.',
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        )
                      else
                        ...editItems.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final item = entry.value;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                children: [
                                  // Product name
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.productName,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text.rich(
                                          TextSpan(
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: theme.colorScheme.onSurfaceVariant,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: '₹${item.price.toStringAsFixed(0)}',
                                                style: AppMoneyText.sized(
                                                  11,
                                                  FontWeight.w400,
                                                  theme.colorScheme.onSurfaceVariant,
                                                ),
                                              ),
                                              const TextSpan(text: ' each'),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Quantity controls
                                  IconButton(
                                    onPressed: () {
                                      setDialogState(() {
                                        if (item.quantity > 1) {
                                          editItems[idx] = item.copyWith(
                                              quantity: item.quantity - 1);
                                        } else {
                                          editItems.removeAt(idx);
                                        }
                                      });
                                    },
                                    icon: Icon(
                                      item.quantity > 1
                                          ? Icons.remove_circle_outline
                                          : Icons.delete_outline,
                                      size: 20,
                                      color: item.quantity > 1
                                          ? Theme.of(context).colorScheme.onSurfaceVariant
                                          : Theme.of(context).colorScheme.error,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: Text(
                                      '${item.quantity}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setDialogState(() {
                                        editItems[idx] = item.copyWith(
                                            quantity: item.quantity + 1);
                                      });
                                    },
                                    icon: Icon(
                                      Icons.add_circle_outline,
                                      size: 20,
                                      color: AppColors.accentText(
                                          Theme.of(context).brightness),
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),

                                  const SizedBox(width: 8),

                                  // Item total
                                  Text(
                                    '₹${(item.price * item.quantity).toStringAsFixed(0)}',
                                    style: AppMoneyText.sized(
                                      13,
                                      FontWeight.w600,
                                      theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),

                      const SizedBox(height: 12),

                      // Totals
                      const Divider(),
                      _editInfoRow('Total',
                          '₹${totalAmount.toStringAsFixed(0)}'),
                      if (discount > 0)
                        _editInfoRow('Discount',
                            '-₹${discount.toStringAsFixed(0)}',
                            valueColor: AppColors.accentText(
                                Theme.of(context).brightness)),
                      const Divider(),
                      _editInfoRow(
                        'Grand Total',
                        '₹${grandTotal.toStringAsFixed(0)}',
                        isBold: true,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: editItems.isEmpty
                      ? null
                      : () {
                          context.read<ReportBloc>().add(UpdateBill(
                                billId: widget.bill.id,
                                updates: {
                                  'customer_name': nameController.text,
                                  'customer_phone': phoneController.text,
                                  'discount':
                                      double.tryParse(discountController.text) ??
                                          0,
                                  'payment_method': paymentMethod,
                                },
                                items: editItems,
                              ));
                          Navigator.of(dialogContext).pop();
                        },
                  child: const Text('Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showProductSearchDialog(
    BuildContext context,
    List<BillItem> editItems,
    StateSetter setDialogState,
  ) async {
    final theme = Theme.of(context);
    // Fetch all products for the shop
    final authState = context.read<AuthBloc>().state;
    final shopId =
        authState is Authenticated ? authState.user.shopId : null;

    List<Product> allProducts = [];
    try {
      final useCase = sl<GetProductsUseCase>();
      final result = await useCase(NoParams(), shopId: shopId);
      result.fold(
        (failure) {
          if (!context.mounted) return;
          AppFeedback.error(context, 'Failed to load products: ${failure.message}');
        },
        (products) => allProducts = products,
      );
    } catch (e) {
      if (!context.mounted) return;
      AppFeedback.error(context, 'Could not load products. Please try again.');
      return;
    }

    if (!context.mounted) return;

    String searchQuery = '';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setInnerState) {
            final filtered = allProducts.where((p) {
              final query = searchQuery.toLowerCase();
              return p.name.toLowerCase().contains(query) ||
                  p.barcode.toLowerCase().contains(query);
            }).toList();

            return AlertDialog(
              title: const Text('Add Product'),
              content: SizedBox(
                width: double.maxFinite,
                height: MediaQuery.of(context).size.height * 0.5,
                child: Column(
                  children: [
                    TextField(
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Search by name or barcode...',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setInnerState(() => searchQuery = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final product = filtered[index];
                          // Check if already in bill
                          final existingIdx = editItems.indexWhere(
                              (i) => i.productId == product.id);
                          final alreadyAdded = existingIdx != -1;

                          return ListTile(
                            title: Text(
                              product.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: alreadyAdded ? Theme.of(context).colorScheme.onSurfaceVariant : null,
                              ),
                            ),
                            subtitle: Text.rich(
                              TextSpan(
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                children: [
                                  TextSpan(
                                    text: '₹${product.price.toStringAsFixed(0)}',
                                    style: AppMoneyText.sized(
                                      12,
                                      FontWeight.w400,
                                      theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  TextSpan(text: ' • Stock: ${product.stock}'),
                                ],
                              ),
                            ),
                            trailing: alreadyAdded
                                ? Icon(Icons.check_circle,
                                    color: theme.colorScheme.primary, size: 20)
                                : null,
                            onTap: alreadyAdded
                                ? null
                                : () {
                                    setDialogState(() {
                                      editItems.add(BillItem(
                                        id: '',
                                        productId: product.id,
                                        productName: product.name,
                                        quantity: 1,
                                        price: product.price,
                                        total: product.price,
                                      ));
                                    });
                                    Navigator.of(dialogContext).pop();
                                  },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _editInfoRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: AppMoneyText.sized(
              isBold ? 16 : 14,
              isBold ? FontWeight.bold : FontWeight.w500,
              valueColor ?? theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  void _showCollectPaymentDialog(BuildContext context, BillSummary bill) {
    final amountController = TextEditingController(
      text: _formatDueAmount(bill.dueAmount),
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.payments, color: AppColors.accentText(Theme.of(context).brightness), size: 24),
              const SizedBox(width: 8),
              const Expanded(child: Text('Collect Payment', style: TextStyle(fontSize: 18))),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer info
              if (bill.customerName != null && bill.customerName!.isNotEmpty)
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
                              bill.customerName!,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
                            ),
                            if (bill.customerPhone != null && bill.customerPhone!.isNotEmpty)
                              Text(
                                bill.customerPhone!,
                                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
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
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Bill Total', style: TextStyle(fontSize: 13, color: AppColors.warningText(Theme.of(context).brightness))),
                        Text('₹${_formatDueAmount(bill.grandTotal)}', style: AppMoneyText.sized(13, FontWeight.w400, AppColors.warningText(Theme.of(context).brightness))),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Already Paid', style: TextStyle(fontSize: 13, color: AppColors.successText(Theme.of(context).brightness))),
                        Text('₹${_formatDueAmount(bill.amountPaid)}', style: AppMoneyText.sized(13, FontWeight.w400, AppColors.successText(Theme.of(context).brightness))),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Due Amount', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                        Text('₹${_formatDueAmount(bill.dueAmount)}', style: AppMoneyText.sized(17, FontWeight.w700, AppColors.warningText(Theme.of(context).brightness))),
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
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                final amount = double.tryParse(amountController.text.trim());
                if (amount != null && amount > 0 && amount <= bill.dueAmount) {
                  // Collect payment via repository
                  final repo = sl<DuePaymentsRepository>();
                  final result = await repo.collectPayment(
                    billId: bill.id,
                    amount: amount,
                  );
                result.fold(
                  (failure) {
                    if (dialogContext.mounted) {
                      AppFeedback.error(context, failure.message);
                    }
                  },
                  (_) {
                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                      AppFeedback.success(context, 'Payment collected');
                      // Refresh bill detail
                      context.read<ReportBloc>().add(LoadBillDetail(bill.id));
                    }
                  },
                );
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
        );
      },
    );
  }

  String _formatDueAmount(double amount) {
    final fixed = amount.toStringAsFixed(2);
    if (fixed.endsWith('.00')) {
      return fixed.substring(0, fixed.length - 3);
    }
    return fixed.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Bill'),
          content: const Text(
              'Are you sure you want to delete this bill? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context
                    .read<ReportBloc>()
                    .add(DeleteBill(widget.bill.id));
                Navigator.of(dialogContext).pop();
              },
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
              child: Text(
                'Delete',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  WHATSAPP SHARE
  // ═══════════════════════════════════════════════════════════════
  Future<void> _shareOnWhatsApp(BillSummary bill) async {
    if (_isSharing) return;
    setState(() => _isSharing = true);

    OverlayEntry? overlayEntry;
    try {
      // Build receipt on-demand via overlay (not in the widget tree)
      // so theme-change rebuilds don't cause renderObject.child == child.
      // Wrap in Theme(brightness: light) so receipt is always white even in dark mode.
      final overlayKey = GlobalKey();
      overlayEntry = OverlayEntry(
        builder: (_) => Positioned(
          left: -9999,
          child: RepaintBoundary(
            key: overlayKey,
            child: Theme(
              data: Theme.of(context).copyWith(brightness: Brightness.light),
              child: _buildReceiptWidget(bill),
            ),
          ),
        ),
      );
      Overlay.of(context).insert(overlayEntry);

      // Capture context-dependent values before the async gap.
      final size = MediaQuery.of(context).size;

      // Let the overlay render one frame before capturing.
      await Future.delayed(const Duration(milliseconds: 150));

      final boundaryContext = overlayKey.currentContext;
      if (boundaryContext == null || !boundaryContext.mounted) {
        debugPrint('WhatsApp share: overlay boundaryContext is NULL');
        if (mounted) AppFeedback.error(context, 'Receipt not ready.');
        return;
      }
      debugPrint('WhatsApp share: boundaryContext found, capturing...');
      final boundary =
          boundaryContext.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      debugPrint('WhatsApp share: image captured, converting...');
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = File(
          '${tempDir.path}/bill_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(pngBytes);
      debugPrint('WhatsApp share: file saved at ${file.path}');

      final shareOrigin = Rect.fromLTWH(
          size.width / 2 - 150, size.height / 2 - 300, 300, 600);
      final phone = bill.customerPhone;
      if (phone != null && phone.isNotEmpty) {
        final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
        final waPhone = digits.startsWith('91') && digits.length == 12
            ? digits
            : digits.length == 10
                ? '91$digits'
                : digits;
        bool shared = false;
        try {
          final result = await const MethodChannel(
                  'com.example.billing_app/whatsapp_share')
              .invokeMethod(
                  'shareFile', {'phone': waPhone, 'filePath': [file.path]});
          shared = result == true;
        } on PlatformException catch (_) {}
        if (!shared) {
          await Share.shareXFiles(
            [XFile(file.path)],
            text:
                'Receipt - Bill #${bill.id.substring(0, bill.id.length > 8 ? 8 : bill.id.length)}',
            sharePositionOrigin: shareOrigin,
          );
        }
      } else {
        await Share.shareXFiles(
          [XFile(file.path)],
          text:
              'Receipt - Bill #${bill.id.substring(0, bill.id.length > 8 ? 8 : bill.id.length)}',
          sharePositionOrigin: shareOrigin,
        );
      }
    } catch (e, st) {
      debugPrint('WhatsApp share error: $e\n$st');
      if (mounted) {
        AppFeedback.error(context, 'Failed to share: ${e.toString()}');
      }
    } finally {
      overlayEntry?.remove();
      if (mounted) setState(() => _isSharing = false);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  //  VOID / CANCEL BILL — not implemented yet (button shows 'Coming soon')
  // ═══════════════════════════════════════════════════════════════

  // ═══════════════════════════════════════════════════════════════
  //  NOTES / REMARKS
  // ═══════════════════════════════════════════════════════════════
  void _showNotesDialog(BuildContext context, BillSummary bill) {
    final notesController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.accentSubtle, borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.notes_rounded, color: AppColors.accentText(Theme.of(context).brightness), size: 22)),
            const SizedBox(width: 12),
            const Expanded(child: Text('Add Notes', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700))),
          ]),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: notesController, decoration: const InputDecoration(labelText: 'Notes / Remarks', hintText: 'e.g. Gift wrapped, Home delivery', prefixIcon: Icon(Icons.edit_note_rounded)), maxLines: 3),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                // Save notes
                Navigator.pop(dialogContext);
                AppFeedback.success(context, 'Notes saved');
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: AppColors.onAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  PAYMENT TIMELINE
  // ═══════════════════════════════════════════════════════════════
  Widget _buildPaymentTimeline(BillSummary bill) {
    final theme = Theme.of(context);
    final nf = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM, hh:mm a');

    // Build timeline entries
    final entries = <Map<String, dynamic>>[
      {'label': 'Bill Created', 'amount': nf.format(bill.grandTotal), 'date': bill.createdAt, 'icon': Icons.receipt_long_rounded, 'color': AppColors.accentText(theme.brightness)},
    ];

    if (bill.amountPaid > 0) {
      entries.add({'label': 'Payment Received', 'amount': nf.format(bill.amountPaid), 'date': bill.createdAt, 'icon': Icons.check_circle_rounded, 'color': AppColors.successText(theme.brightness)});
    }

    if (bill.hasDue) {
      entries.add({'label': 'Due Amount', 'amount': nf.format(bill.dueAmount), 'date': null, 'icon': Icons.warning_amber_rounded, 'color': AppColors.warningText(theme.brightness)});
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: theme.shadowColor.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Payment Timeline', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 16),
        ...entries.asMap().entries.map((entry) {
          final idx = entry.key;
          final e = entry.value;
          final isLast = idx == entries.length - 1;
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Column(children: [
              Container(width: 32, height: 32, decoration: BoxDecoration(color: (e['color'] as Color).withValues(alpha: 0.12), shape: BoxShape.circle),
                  child: Icon(e['icon'] as IconData, size: 16, color: e['color'] as Color)),
              if (!isLast) Container(width: 2, height: 32, color: theme.dividerColor),
            ]),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(e['label'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 2),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(e['amount'] as String, style: AppMoneyText.sized(13, FontWeight.w700, e['color'] as Color)),
                if (e['date'] != null) Text(dateFormat.format(e['date'] as DateTime), style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
              ]),
              if (!isLast) const SizedBox(height: 8),
            ])),
          ]);
        }),
      ]),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  CUSTOMER PURCHASE HISTORY
  // ═══════════════════════════════════════════════════════════════
  Widget _buildCustomerHistory(BillSummary bill) {
    final theme = Theme.of(context);
    if (bill.customerName == null || bill.customerName!.isEmpty) return const SizedBox.shrink();

    return BlocBuilder<ReportBloc, ReportState>(
      builder: (context, state) {
        final allBills = state.billHistory;
        final customerBills = allBills.where((b) => b.customerName == bill.customerName).toList();
        final totalSpent = customerBills.fold(0.0, (sum, b) => sum + b.grandTotal);
        final nf = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: theme.shadowColor.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Customer History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Row(children: [
              Icon(Icons.person_rounded, size: 20, color: AppColors.accentText(theme.brightness)),
              const SizedBox(width: 8),
              Text(bill.customerName!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              _customerStat('Total Bills', '${customerBills.length}', Icons.receipt_long_rounded),
              const SizedBox(width: 12),
              _customerStat('Total Spent', nf.format(totalSpent), Icons.currency_rupee_rounded, money: true),
            ]),
          ]),
        );
      },
    );
  }

  Widget _customerStat(String label, String value, IconData icon, {bool money = false}) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 16, color: AppColors.accentText(theme.brightness)),
          const SizedBox(height: 6),
          Text(
            value,
            style: money
                ? AppMoneyText.sized(16, FontWeight.w700, theme.colorScheme.onSurface)
                : const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          Text(label, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
        ]),
      ),
    );
  }

  Widget _buildPaymentStatusRow(BillSummary bill) {
    final theme = Theme.of(context);
    final b = theme.brightness;
    Color bgColor;
    Color textColor;
    String label;
    IconData icon;

    switch (bill.paymentStatus) {
      case 'paid':
        bgColor = AppColors.success.withValues(alpha: 0.12);
        textColor = AppColors.successText(b);
        label = 'Paid';
        icon = Icons.check_circle;
        break;
      case 'partial':
        bgColor = AppColors.warning.withValues(alpha: 0.12);
        textColor = AppColors.warningText(b);
        label = 'Partial';
        icon = Icons.access_time;
        break;
      case 'due':
        bgColor = theme.colorScheme.error.withValues(alpha: 0.12);
        textColor = theme.colorScheme.error;
        label = 'Due';
        icon = Icons.warning_amber;
        break;
      default:
        bgColor = AppColors.success.withValues(alpha: 0.12);
        textColor = AppColors.successText(b);
        label = 'Paid';
        icon = Icons.check_circle;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Payment Status',
          style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: textColor),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
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
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: theme.colorScheme.onSurfaceVariant,
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

  // ═══════════════════════════════════════════════════════════════
  //  ACTION BUTTON
  // ═══════════════════════════════════════════════════════════════
  Widget _actionBtn(String label, IconData icon, Color color, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.45 : 1.0,
        child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
        ]),
        ),
      ),
    );
  }
}
