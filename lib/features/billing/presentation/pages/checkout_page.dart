import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

import '../../../shop/presentation/bloc/shop_bloc.dart';
import '../bloc/billing_bloc.dart';
import '../../domain/entities/cart_item.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final TextEditingController _totalOverrideController =
      TextEditingController();
  final TextEditingController _customerNameController =
      TextEditingController();
  final TextEditingController _customerPhoneController =
      TextEditingController();
  bool _isEditingTotal = false;
  bool _stockErrorsHandled = false;

  @override
  void dispose() {
    _totalOverrideController.dispose();
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    super.dispose();
  }

  String _formatPrice(double value) {
    final fixed = value.toStringAsFixed(2);
    if (fixed.endsWith('.00')) {
      return fixed.substring(0, fixed.length - 3);
    }
    return fixed.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFFE5E5EA);

    return PopScope(
        canPop: true,
        onPopInvokedWithResult: (bool didPop, dynamic result) {
          if (!didPop) return;
          context.read<BillingBloc>().add(ClearCartEvent());
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Checkout',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.menu,
                  size: 24, color: Theme.of(context).primaryColor),
              onPressed: () => Scaffold.of(context).openDrawer(),
              tooltip: 'Open menu',
            ),
          ),
          body: BlocConsumer<BillingBloc, BillingState>(
            listener: (context, state) {
              if (state.printSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Printed successfully'),
                    backgroundColor: Colors.green));
              }
              if (state.submitSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Bill saved successfully'),
                    backgroundColor: Colors.green));
                context.read<BillingBloc>().add(ClearCartEvent());

                // Navigate to receipt preview
                final shopState = context.read<ShopBloc>().state;
                if (shopState is ShopLoaded) {
                  context.push('/scan/receipt-preview', extra: {
                    'shopName': shopState.shop.name,
                    'address1': shopState.shop.addressLine1,
                    'address2': shopState.shop.addressLine2,
                    'phone': shopState.shop.phoneNumber,
                    'footer': shopState.shop.footerText,
                    'cartItems': state.cartItems,
                    'totalAmount': state.totalAmount,
                    'discount': state.discount ?? 0.0,
                    'discountIsPercentage': state.discountIsPercentage,
                    'customerName': state.customerName,
                    'customerPhone': state.customerPhone,
                    'paymentMethod': state.paymentMethod,
                  });
                }
              }
              if (state.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(state.error!),
                    backgroundColor: Colors.red));
              }
              if (state.stockErrors != null &&
                  state.stockErrors!.isNotEmpty &&
                  !_stockErrorsHandled) {
                _stockErrorsHandled = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _showStockErrorsDialog(context, state.stockErrors!);
                    context
                        .read<BillingBloc>()
                        .add(const ClearStockErrorsEvent());
                  }
                });
              }
            },
            builder: (context, billingState) {
              return BlocBuilder<ShopBloc, ShopState>(
                  builder: (context, shopState) {
                String upiId = '';
                String shopName = 'Your Shop';

                if (shopState is ShopLoaded) {
                  upiId = shopState.shop.upiId;
                  shopName = shopState.shop.name;
                }

                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        child: Column(
                          children: [
                            // Table
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Table(
                                  border: const TableBorder(
                                    horizontalInside:
                                        BorderSide(color: borderColor),
                                    bottom: BorderSide(color: borderColor),
                                  ),
                                  children: [
                                    // Header row
                                    TableRow(
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF8FAFC),
                                        border: Border(
                                            bottom: BorderSide(
                                                color: borderColor)),
                                      ),
                                      children: [
                                        _buildHeaderCell(
                                            'Product Name', TextAlign.left),
                                        _buildHeaderCell(
                                            'Price', TextAlign.right),
                                        _buildHeaderCell(
                                            'Total', TextAlign.right),
                                      ],
                                    ),
                                    // Items rows
                                    ...billingState.cartItems.map((item) {
                                      final isLowStock = item.quantity >
                                          item.product.stock;
                                      final isLowStockWarning =
                                          !isLowStock &&
                                              item.quantity >
                                                  item.product.stock * 0.8;
                                      return TableRow(
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 16),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${item.quantity} x ${item.product.name}',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: isLowStock
                                                        ? Colors.red.shade700
                                                        : Colors.black87,
                                                  ),
                                                ),
                                                if (isLowStock)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 4),
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                              horizontal: 6,
                                                              vertical: 2),
                                                      decoration:
                                                          BoxDecoration(
                                                        color: Colors
                                                            .red.shade50,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                        border: Border.all(
                                                            color: Colors
                                                                .red.shade200),
                                                      ),
                                                      child: Text(
                                                        'Insufficient Stock (${item.product.stock} avail)',
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          color:
                                                              Colors.red.shade700,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                else if (isLowStockWarning)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 4),
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                              horizontal: 6,
                                                              vertical: 2),
                                                      decoration:
                                                          BoxDecoration(
                                                        color: Colors
                                                            .orange.shade50,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                        border: Border.all(
                                                            color: Colors
                                                                .orange
                                                                .shade200),
                                                      ),
                                                      child: Text(
                                                        'Low Stock (${item.product.stock} left)',
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          color: Colors
                                                              .orange.shade700,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: InkWell(
                                                onTap: () {
                                                  _showEditPriceDialog(context, item);
                                                },
                                                borderRadius: BorderRadius.circular(6),
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: item.customPrice != null
                                                        ? const Color(0xFFFFF7ED)
                                                        : const Color(0xFFF3F4F6),
                                                    borderRadius: BorderRadius.circular(6),
                                                    border: Border.all(
                                                      color: item.customPrice != null
                                                          ? const Color(0xFFFDBA74)
                                                          : const Color(0xFFE5E7EB),
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        '₹${_formatPrice(item.unitPrice)}',
                                                        textAlign: TextAlign.right,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight: item.customPrice != null
                                                              ? FontWeight.w700
                                                              : FontWeight.w600,
                                                          color: item.customPrice != null
                                                              ? const Color(0xFFC2410C)
                                                              : const Color(0xFF111827),
                                                          letterSpacing: -0.2,
                                                        ),
                                                      ),
                                                      if (item.customPrice != null)
                                                        const Padding(
                                                          padding: EdgeInsets.only(left: 4),
                                                          child: Icon(
                                                            Icons.edit_rounded,
                                                            size: 12,
                                                            color: Color(0xFFC2410C),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          _buildDataCell(
                                              '₹${_formatPrice(item.total)}',
                                              TextAlign.right,
                                              isBold: true),
                                        ],
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Customer Info Section
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.person_outline,
                                          size: 18,
                                          color: Theme.of(context).primaryColor),
                                      const SizedBox(width: 8),
                                      const Text('Customer Info',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14)),
                                      const Spacer(),
                                      TextButton.icon(
                                        onPressed: () {
                                          _customerNameController.clear();
                                          _customerPhoneController.clear();
                                          context
                                              .read<BillingBloc>()
                                              .add(const UpdateCustomerInfoEvent(
                                                  customerName: null,
                                                  customerPhone: null));
                                        },
                                        icon: const Icon(Icons.clear,
                                            size: 16),
                                        label: const Text('Clear'),
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          minimumSize: const Size(0, 0),
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _customerNameController,
                                          decoration: InputDecoration(
                                            hintText: 'Customer name (optional)',
                                            prefixIcon: const Icon(
                                                Icons.person,
                                                size: 20),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 10),
                                            isDense: true,
                                          ),
                                          onChanged: (value) {
                                            context
                                                .read<BillingBloc>()
                                                .add(UpdateCustomerInfoEvent(
                                                  customerName: value.isEmpty
                                                      ? null
                                                      : value,
                                                ));
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextField(
                                          controller: _customerPhoneController,
                                          keyboardType:
                                              TextInputType.phone,
                                          decoration: InputDecoration(
                                            hintText: 'Phone (optional)',
                                            prefixIcon: const Icon(
                                                Icons.phone,
                                                size: 20),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 10),
                                            isDense: true,
                                          ),
                                          onChanged: (value) {
                                            context
                                                .read<BillingBloc>()
                                                .add(UpdateCustomerInfoEvent(
                                                  customerPhone: value.isEmpty
                                                      ? null
                                                      : value,
                                                ));
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Discount Section
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text('Discount',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600)),
                                      const Spacer(),
                                      if (billingState.discount != null &&
                                          billingState.discount! > 0)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade50,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            billingState.discountIsPercentage
                                                ? '${billingState.discount!.toStringAsFixed(0)}% off'
                                                : '₹${_formatPrice(billingState.discount!)} off',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.green.shade700,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            hintText: 'Discount amount',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 10),
                                            isDense: true,
                                          ),
                                          onChanged: (value) {
                                            final discount = value.isEmpty
                                                ? null
                                                : double.tryParse(value);
                                            context
                                                .read<BillingBloc>()
                                                .add(UpdateDiscountEvent(
                                                  discount,
                                                  billingState
                                                      .discountIsPercentage,
                                                ));
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      ToggleButtons(
                                        isSelected: [
                                          !billingState.discountIsPercentage,
                                          billingState.discountIsPercentage
                                        ],
                                        onPressed: (index) {
                                          context
                                              .read<BillingBloc>()
                                              .add(SetDiscountTypeEvent(
                                                  index == 1));
                                        },
                                        borderRadius:
                                            BorderRadius.circular(8),
                                        constraints: const BoxConstraints(
                                            minWidth: 44, minHeight: 36),
                                        children: const [
                                          Text('₹',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.w600)),
                                          Text('%',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.w600)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                                height: 120), // padding for bottom fixed bar
                          ],
                        ),
                      ),
                    ),

                    // Bottom Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(24),
                            right: Radius.circular(24)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 8,
                                ),
                                // Payment Method Selector
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: SegmentedButton<String>(
                                    segments: const [
                                      ButtonSegment(
                                        value: 'cash',
                                        label: Text('Cash'),
                                        icon: Icon(Icons.money_rounded, size: 18),
                                      ),
                                      ButtonSegment(
                                        value: 'upi',
                                        label: Text('UPI'),
                                        icon: Icon(Icons.qr_code_2_rounded, size: 18),
                                      ),
                                    ],
                                    selected: {billingState.paymentMethod},
                                    onSelectionChanged: (Set<String> newSelection) {
                                      context.read<BillingBloc>().add(
                                            UpdatePaymentMethodEvent(newSelection.last),
                                          );
                                    },
                                    showSelectedIcon: false,
                                    style: SegmentedButton.styleFrom(
                                      selectedBackgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                      selectedForegroundColor: Theme.of(context).primaryColor,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (billingState.paymentMethod == 'upi' && upiId.isNotEmpty)
                                  Column(
                                    children: [
                                      const Text(
                                        'Scan to Pay',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                          letterSpacing: 1.1,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      SizedBox(
                                        width: 180,
                                        height: 180,
                                        child: PrettyQrView.data(
                                          data:
                                              'upi://pay?pa=$upiId&pn=$shopName&am=${_formatPrice(billingState.totalAmount)}&cu=INR',
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                    ],
                                  ),
                                // Grand Total Row
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'GRAND TOTAL',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[400],
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                        if (billingState.grandTotalOverride !=
                                            null)
                                          Container(
                                            margin:
                                                const EdgeInsets.only(left: 6),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              'manual',
                                              style: TextStyle(
                                                fontSize: 9,
                                                color: Colors.orange.shade700,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    if (_isEditingTotal)
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: 120,
                                            child: TextField(
                                              controller:
                                                  _totalOverrideController,
                                              keyboardType:
                                                  TextInputType.number,
                                              textInputAction:
                                                  TextInputAction.done,
                                              decoration:
                                                  const InputDecoration(
                                                border: InputBorder.none,
                                                isDense: true,
                                              ),
                                              style: const TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: -0.5,
                                                color: Color(0xFF0F172A),
                                              ),
                                              onChanged: (value) {
                                                final total = value.isEmpty
                                                    ? null
                                                    : double.tryParse(value);
                                                context
                                                    .read<BillingBloc>()
                                                    .add(
                                                        UpdateGrandTotalOverrideEvent(
                                                            total));
                                              },
                                              onSubmitted: (_) => setState(
                                                  () =>
                                                      _isEditingTotal = false),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.check,
                                                size: 20),
                                            onPressed: () => setState(
                                                () => _isEditingTotal = false),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                        ],
                                      )
                                    else
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '₹${_formatPrice(billingState.totalAmount)}',
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: -0.5,
                                              color: Color(0xFF0F172A),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.edit,
                                                size: 16),
                                            onPressed: () {
                                              setState(() {
                                                _isEditingTotal = true;
                                                _totalOverrideController
                                                        .text =
                                                    _formatPrice(billingState.totalAmount);
                                              });
                                            },
                                            padding: EdgeInsets.zero,
                                            constraints:
                                                const BoxConstraints(),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                          // Save Bill Button (full width)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: (billingState.isSubmitting ||
                                        billingState.isValidatingStock)
                                    ? null
                                    : () {
                                        _stockErrorsHandled = false;
                                        context
                                            .read<BillingBloc>()
                                            .add(const ValidateStockBeforeBill());
                                      },
                                icon: (billingState.isSubmitting ||
                                        billingState.isValidatingStock)
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.save, size: 20),
                                label: Text(billingState.isValidatingStock
                                    ? 'Checking...'
                                    : 'Save Bill'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              });
            },
          ),
        ));
  }

  Future<void> _showStockErrorsDialog(
      BuildContext context, List<String> errors) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700, size: 24),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Insufficient Stock',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Some items don\'t have enough stock. Please adjust quantities or remove items:',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            ...errors.map(
              (error) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        size: 18, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        error,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.red.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (mounted) {
      _stockErrorsHandled = false;
    }
  }

  void _showEditPriceDialog(BuildContext context, CartItem item) {
    final controller = TextEditingController(
      text: item.customPrice != null ? _formatPrice(item.customPrice!) : _formatPrice(item.product.price),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.edit_rounded, size: 20, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Edit Price',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[900],
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.product.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    '₹${_formatPrice(item.product.price)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[900],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'New Unit Price',
                prefixIcon: const Icon(Icons.currency_rupee, size: 20),
                prefixIconConstraints: const BoxConstraints(minWidth: 40),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              context
                  .read<BillingBloc>()
                  .add(UpdateItemPriceEvent(item.product.id, null));
              Navigator.of(ctx).pop();
            },
            icon: const Icon(Icons.restore_rounded, size: 18),
            label: const Text('Reset'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              final newPrice = double.tryParse(controller.text.trim());
              context
                  .read<BillingBloc>()
                  .add(UpdateItemPriceEvent(item.product.id, newPrice));
              Navigator.of(ctx).pop();
            },
            icon: const Icon(Icons.check_rounded, size: 18),
            label: const Text('Save'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, TextAlign align) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Text(
        text.toUpperCase(),
        textAlign: align,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildDataCell(String text, TextAlign align,
      {bool isBold = false, bool isSubtitle = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: isSubtitle ? 12 : 14,
          fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          color: isSubtitle ? Colors.grey[500] : Colors.black87,
        ),
      ),
    );
  }
}
