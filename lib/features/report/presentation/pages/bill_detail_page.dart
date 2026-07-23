// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:billing_app/core/theme/app_theme.dart';
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
import 'package:flutter/services.dart';

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

    final authState = context.read<AuthBloc>().state;
    final isOwner = authState is Authenticated && authState.user.role == 'owner';

    return BlocListener<ReportBloc, ReportState>(
      listenWhen: (previous, current) =>
          previous.message != current.message && current.message != null,
      listener: (context, state) {
        _showSnack(state.message!, isError: state.status == ReportStatus.error);
        if (state.message == 'Bill deleted successfully') {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.menu, color: Theme.of(context).primaryColor),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
          title: const Text('Bill Details'),
          actions: isOwner
              ? [
                  IconButton(
                    icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
                    onPressed: () => _showEditDialog(context),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: AppTheme.errorColor),
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
    ),
    );
  }

  void _showEditDialog(BuildContext context) {
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
                                color: Colors.grey[500],
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
                                        Text(
                                          '₹${item.price.toStringAsFixed(0)} each',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[600],
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
                                          ? Colors.grey[600]
                                          : AppTheme.errorColor,
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
                                      color: AppTheme.primaryColor,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),

                                  const SizedBox(width: 8),

                                  // Item total
                                  Text(
                                    '₹${(item.price * item.quantity).toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
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
                            valueColor: Colors.green),
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load products: ${failure.message}')),
          );
        },
        (products) => allProducts = products,
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading products: $e')),
      );
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
                                color: alreadyAdded ? Colors.grey : null,
                              ),
                            ),
                            subtitle: Text(
                              '₹${product.price.toStringAsFixed(0)} • Stock: ${product.stock}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            trailing: alreadyAdded
                                ? const Icon(Icons.check_circle,
                                    color: Colors.green, size: 20)
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
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
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
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
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
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
