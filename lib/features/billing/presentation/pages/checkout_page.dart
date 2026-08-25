import 'package:flutter/material.dart';
import '../../../../core/widgets/adaptive_app_bar_leading.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

import '../../../shop/presentation/bloc/shop_bloc.dart';
import '../../../product/domain/entities/product.dart';
import '../../../product/domain/repositories/product_repository.dart';
import '../../../product/domain/usecases/product_usecases.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/service_locator.dart' as di;
import '../bloc/billing_bloc.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/cart_item.dart';
import '../../../customer/domain/entities/customer.dart';
import '../../../customer/presentation/bloc/customer_bloc.dart';

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
    final borderColor = Theme.of(context).dividerColor;

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
            leading: const AdaptiveAppBarLeading(),
          ),
          body: BlocConsumer<BillingBloc, BillingState>(
            listener: (context, state) {
              if (state.printSuccess) {
                AppFeedback.success(context, 'Printed successfully');
              }
              if (state.submitSuccess) {
                AppFeedback.success(context, 'Bill saved');
                context.read<BillingBloc>().add(ClearCartEvent());

                // Navigate to receipt preview
                final billId = state.lastBillId;
                final shopState = context.read<ShopBloc>().state;
                if (shopState is ShopLoaded) {
                  final paid = state.amountPaid ?? state.totalAmount;
                  final due = state.totalAmount - paid;
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
                    'billId': billId,
                    'amountPaid': paid,
                    'dueAmount': due > 0 ? due : null,
                  });
                } else {
                  // Shop/profile not loaded — bill is saved, just confirm.
                  AppFeedback.info(context, 'Bill saved');
                }
              }
              if (state.error != null) {
                AppFeedback.error(context, state.error!);
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
                            // 1. Customer Info (TOP — above product table)
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
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
                                          color: AppColors.accentText(Theme.of(context).brightness)),
                                      const SizedBox(width: 8),
                                      const Text('Customer Info',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14)),
                                      const Spacer(),
                                      // 🔍 Select from saved customers
                                      TextButton.icon(
                                        onPressed: () =>
                                            _showCustomerPicker(context),
                                        icon: const Icon(Icons.search, size: 16),
                                        label: const Text('Select'),
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          minimumSize: const Size(0, 0),
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      TextButton.icon(
                                        onPressed: () {
                                          _customerNameController.clear();
                                          _customerPhoneController.clear();
                                          context
                                              .read<BillingBloc>()
                                              .add(const UpdateCustomerInfoEvent(
                                                  customerName: null,
                                                  customerPhone: null));
                                          context
                                              .read<BillingBloc>()
                                              .add(SelectCustomerEvent(
                                                  Customer.empty()));
                                        },
                                        icon: const Icon(Icons.clear, size: 16),
                                        label: const Text('Clear'),
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          minimumSize: const Size(0, 0),
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  // Linked status chip
                                  BlocBuilder<BillingBloc, BillingState>(
                                    builder: (context, billingState) {
                                      final selected =
                                          billingState.selectedCustomer;
                                      final phone =
                                          billingState.customerPhone?.trim() ??
                                              '';
                                      if (selected != null &&
                                          selected.id.isNotEmpty) {
                                        return Container(
                                          margin: const EdgeInsets.only(bottom: 10),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(color: AppColors.success.withValues(alpha: 0.35)),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.check_circle,
                                                  size: 14, color: AppColors.successText(Theme.of(context).brightness)),
                                              const SizedBox(width: 6),
                                              Flexible(
                                                child: Text(
                                                  'Linked: ${selected.name} (${selected.phone})',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: AppColors.successText(Theme.of(context).brightness),
                                                      fontWeight:
                                                          FontWeight.w600),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                      if (phone.isNotEmpty) {
                                        return Container(
                                          margin: const EdgeInsets.only(bottom: 10),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.sync,
                                                  size: 14, color: AppColors.warningText(Theme.of(context).brightness)),
                                              const SizedBox(width: 6),
                                              Flexible(
                                                child: Text(
                                                  'Will match/create customer by phone',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: AppColors.warningText(Theme.of(context).brightness),
                                                      fontWeight:
                                                          FontWeight.w600),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _customerNameController,
                                          decoration: InputDecoration(
                                            hintText: 'Customer name (optional)',
                                            prefixIcon: const Icon(Icons.person, size: 20),
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                            isDense: true,
                                          ),
                                          onChanged: (value) {
                                            context.read<BillingBloc>().add(UpdateCustomerInfoEvent(
                                              customerName: value.isEmpty ? null : value,
                                            ));
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextField(
                                          controller: _customerPhoneController,
                                          keyboardType: TextInputType.phone,
                                          decoration: InputDecoration(
                                            hintText: 'Phone (optional)',
                                            prefixIcon: const Icon(Icons.phone, size: 20),
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                            isDense: true,
                                          ),
                                          onChanged: (value) {
                                            context.read<BillingBloc>().add(UpdateCustomerInfoEvent(
                                              customerPhone: value.isEmpty ? null : value,
                                            ));
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // 2. Product Table
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Header with Add More button
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          '${billingState.cartItems.length} item${billingState.cartItems.length == 1 ? '' : 's'}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        const Spacer(),
                                        InkWell(
                                          onTap: () => _showAddProductDialog(),
                                          borderRadius: BorderRadius.circular(8),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).colorScheme.primaryContainer,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.add_rounded, size: 16, color: Theme.of(context).colorScheme.primary),
                                                const SizedBox(width: 4),
                                                Text('Add More', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Empty state
                                  if (billingState.cartItems.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 32),
                                      child: Column(
                                        children: [
                                          Icon(Icons.add_shopping_cart_rounded, size: 40, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
                                          const SizedBox(height: 8),
                                          Text('Cart is empty', style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                                          const SizedBox(height: 12),
                                          OutlinedButton.icon(
                                            onPressed: () => _showAddProductDialog(),
                                            icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                                            label: const Text('Scan or Search Product'),
                                            style: OutlinedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  // Cart items
                                  if (billingState.cartItems.isNotEmpty)
                                    ...billingState.cartItems.map((item) {
                                      final isLowStock = item.quantity > item.product.stock;
                                      final isLowStockWarning = !isLowStock && item.quantity > item.product.stock * 0.8;
                                      final hasWarranty = item.product.hasWarranty;
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                        decoration: BoxDecoration(
                                          border: Border(bottom: BorderSide(color: borderColor)),
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                // Product name + warranty badge
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        item.product.name,
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w500,
                                                          color: isLowStock ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.onSurface,
                                                        ),
                                                      ),
                                                      if (hasWarranty)
                                                        GestureDetector(
                                                          onTap: () => _showWarrantyDialog(context, item),
                                                          child: Padding(
                                                            padding: const EdgeInsets.only(top: 2),
                                                              child: Row(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                Icon(Icons.verified_outlined, size: 12, color: AppColors.infoText(Theme.of(context).brightness)),
                                                                const SizedBox(width: 3),
                                                                Text(
                                                                  item.product.warrantyLabel,
                                                                  style: TextStyle(fontSize: 10, color: AppColors.infoText(Theme.of(context).brightness), fontWeight: FontWeight.w500),
                                                                ),
                                                                const SizedBox(width: 2),
                                                                Icon(Icons.edit_rounded, size: 9, color: AppColors.infoText(Theme.of(context).brightness).withValues(alpha: 0.7)),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      if (!hasWarranty)
                                                        GestureDetector(
                                                          onTap: () => _showWarrantyDialog(context, item),
                                                          child: Padding(
                                                            padding: const EdgeInsets.only(top: 2),
                                                            child: Row(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                Icon(Icons.verified_outlined, size: 11, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                                                                const SizedBox(width: 3),
                                                                Text(
                                                                  'Add warranty',
                                                                  style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5), fontWeight: FontWeight.w500),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      if (isLowStock)
                                                        Padding(
                                                          padding: const EdgeInsets.only(top: 2),
                                                          child: Text('Insufficient Stock (${item.product.stock} avail)', style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.error)),
                                                        )
                                                      else if (isLowStockWarning)
                                                        Padding(
                                                          padding: const EdgeInsets.only(top: 2),
                                                          child: Text('Low Stock (${item.product.stock} left)', style: TextStyle(fontSize: 10, color: AppColors.warningText(Theme.of(context).brightness))),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                                // Qty controls
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        HapticFeedback.lightImpact();
                                                        context.read<BillingBloc>().add(UpdateQuantityEvent(item.product.id, item.quantity - 1));
                                                      },
                                                      child: SizedBox(
                                                        width: 44, height: 44,
                                                        child: Center(
                                                          child: Container(
                                                            width: 26, height: 26,
                                                            decoration: BoxDecoration(
                                                              color: Theme.of(context).colorScheme.primaryContainer,
                                                              borderRadius: BorderRadius.circular(8),
                                                            ),
                                                            child: Icon(Icons.remove, size: 14, color: Theme.of(context).colorScheme.primary),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 6),
                                                      child: Text('${item.quantity}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        HapticFeedback.lightImpact();
                                                        context.read<BillingBloc>().add(UpdateQuantityEvent(item.product.id, item.quantity + 1));
                                                      },
                                                      child: SizedBox(
                                                        width: 44, height: 44,
                                                        child: Center(
                                                          child: Container(
                                                            width: 26, height: 26,
                                                            decoration: BoxDecoration(
                                                              color: Theme.of(context).colorScheme.primaryContainer,
                                                              borderRadius: BorderRadius.circular(8),
                                                            ),
                                                            child: Icon(Icons.add, size: 14, color: Theme.of(context).colorScheme.primary),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(width: 8),
                                                // Price (editable)
                                                InkWell(
                                                  onTap: () => _showEditPriceDialog(context, item),
                                                  borderRadius: BorderRadius.circular(8),
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                                    decoration: BoxDecoration(
                                                      color: item.customPrice != null
                                                          ? Theme.of(context).colorScheme.tertiaryContainer.withValues(alpha: 0.5)
                                                          : Colors.transparent,
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          '₹${_formatPrice(item.unitPrice)}',
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            fontWeight: item.customPrice != null ? FontWeight.w700 : FontWeight.w600,
                                                            color: item.customPrice != null ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.onSurface,
                                                          ),
                                                        ),
                                                        if (item.customPrice != null)
                                                          Icon(Icons.edit_rounded, size: 10, color: Theme.of(context).colorScheme.tertiary),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                // Total
                                                SizedBox(
                                                  width: 60,
                                                  child: Text(
                                                    '₹${_formatPrice(item.total)}',
                                                    textAlign: TextAlign.right,
                                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // 3. Discount + Payment (same line)
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  // Discount
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.local_offer_outlined, size: 16, color: AppColors.accentText(Theme.of(context).brightness)),
                                            const SizedBox(width: 4),
                                            Text('Discount', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                                            if (billingState.discount != null && billingState.discount! > 0) ...[
                                              const SizedBox(width: 6),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                                decoration: BoxDecoration(
                                                  color: AppColors.successText(Theme.of(context).brightness).withValues(alpha: 0.12),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  billingState.discountIsPercentage
                                                      ? '${billingState.discount!.toStringAsFixed(0)}%'
                                                      : '₹${_formatPrice(billingState.discount!)}',
                                                  style: TextStyle(fontSize: 10, color: AppColors.successText(Theme.of(context).brightness), fontWeight: FontWeight.w600),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                keyboardType: TextInputType.number,
                                                decoration: InputDecoration(
                                                  hintText: 'Amount',
                                                  prefixText: billingState.discountIsPercentage ? '' : '₹ ',
                                                  suffixText: billingState.discountIsPercentage ? '%' : null,
                                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                  isDense: true,
                                                ),
                                                onChanged: (value) {
                                                  final discount = value.isEmpty ? null : double.tryParse(value);
                                                  context.read<BillingBloc>().add(UpdateDiscountEvent(discount, billingState.discountIsPercentage));
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            GestureDetector(
                                              onTap: () => context.read<BillingBloc>().add(SetDiscountTypeEvent(!billingState.discountIsPercentage)),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: billingState.discountIsPercentage ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surfaceContainerHighest,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  billingState.discountIsPercentage ? '%' : '₹',
                                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: billingState.discountIsPercentage ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 48,
                                    margin: const EdgeInsets.symmetric(horizontal: 12),
                                    color: borderColor,
                                  ),
                                  // Payment
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.payments_outlined, size: 16, color: AppColors.accentText(Theme.of(context).brightness)),
                                            const SizedBox(width: 4),
                                            Text('Payment', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                                            if (billingState.amountPaid != null && billingState.amountPaid! > 0 && billingState.amountPaid! < billingState.totalAmount) ...[
                                              const SizedBox(width: 6),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                                decoration: BoxDecoration(
                                                  color: AppColors.warningText(Theme.of(context).brightness).withValues(alpha: 0.12),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text('Due ₹${_formatPrice(billingState.totalAmount - (billingState.amountPaid ?? 0))}', style: TextStyle(fontSize: 10, color: AppColors.warningText(Theme.of(context).brightness), fontWeight: FontWeight.w600)),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                keyboardType: TextInputType.number,
                                                decoration: InputDecoration(
                                                  hintText: 'Paid amount',
                                                  prefixText: '₹ ',
                                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                  isDense: true,
                                                ),
                                                onChanged: (value) {
                                                  final amount = value.isEmpty ? null : double.tryParse(value);
                                                  context.read<BillingBloc>().add(UpdateAmountPaidEvent(amount));
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            GestureDetector(
                                              onTap: () => context.read<BillingBloc>().add(UpdateAmountPaidEvent(billingState.totalAmount)),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context).colorScheme.primaryContainer,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text('Full', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 170), // padding for bottom fixed bar (+ SafeArea nav/inset clearance)

                            // Show warning when UPI is selected but no UPI ID configured
                            if (billingState.paymentMethod == 'upi' && upiId.isEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.warning_amber_rounded, color: Theme.of(context).colorScheme.onErrorContainer, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text('UPI ID not configured. Add in Shop Settings.', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onErrorContainer)),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Bottom Bar — SafeArea(top:false) lifts it ABOVE whatever sits
                    // at the screen bottom: floating nav height (extendBody injects it
                    // as bottom padding when nav is visible) or just the gesture-bar
                    // inset when nav is hidden (fullscreen route). Fixes nav overlap.
                    SafeArea(
                      top: false,
                      child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).shadowColor.withValues(alpha: 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Column(
                              children: [
                                // Payment Method Selector
                                SegmentedButton<String>(
                                  segments: const [
                                    ButtonSegment(value: 'cash', label: Text('Cash'), icon: Icon(Icons.money_rounded, size: 16)),
                                    ButtonSegment(value: 'upi', label: Text('UPI'), icon: Icon(Icons.qr_code_2_rounded, size: 16)),
                                  ],
                                  selected: {billingState.paymentMethod},
                                  onSelectionChanged: (Set<String> newSelection) {
                                    context.read<BillingBloc>().add(UpdatePaymentMethodEvent(newSelection.last));
                                  },
                                  showSelectedIcon: false,
                                  style: SegmentedButton.styleFrom(
                                    selectedBackgroundColor: AppColors.accentSubtle,
                                    selectedForegroundColor: AppColors.accentText(Theme.of(context).brightness),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                                // UPI QR code
                                if (billingState.paymentMethod == 'upi' && upiId.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text('Scan to Pay', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: 140, height: 140,
                                    child: PrettyQrView.data(
                                      data: 'upi://pay?pa=$upiId&pn=$shopName&am=${_formatPrice(billingState.totalAmount)}&cu=INR',
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                // Grand Total Row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text('GRAND TOTAL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant, letterSpacing: 1.0)),
                                        if (billingState.grandTotalOverride != null)
                                          Container(
                                            margin: const EdgeInsets.only(left: 6),
                                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                            decoration: BoxDecoration(color: Theme.of(context).colorScheme.tertiaryContainer, borderRadius: BorderRadius.circular(4)),
                                            child: Text('manual', style: TextStyle(fontSize: 8, color: Theme.of(context).colorScheme.onTertiaryContainer)),
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
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: -0.5,
                                                color: Theme.of(context).colorScheme.onSurface,
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
                                            style: AppMoneyText.sized(
                                              24,
                                              FontWeight.w700,
                                              Theme.of(context).colorScheme.onSurface,
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
                            padding: const EdgeInsets.fromLTRB(
                              16,
                              0,
                              16,
                              16,
                            ),
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
                                          color: AppColors.onAccent,
                                        ),
                                      )
                                    : const Icon(Icons.save, size: 20),
                                label: Text(billingState.isValidatingStock
                                    ? 'Checking...'
                                    : 'Save Bill'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accent,
                                  foregroundColor: AppColors.onAccent,
                                  disabledBackgroundColor: AppColors.accent.withValues(alpha: 0.4),
                                  disabledForegroundColor: AppColors.onAccent.withValues(alpha: 0.7),
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
            Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Insufficient Stock',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Some items don\'t have enough stock. Please adjust quantities or remove items:',
              style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(height: 16),
            ...errors.map(
              (error) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        size: 18, color: Theme.of(context).colorScheme.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        error,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.error,
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

  void _showAddProductDialog() {
    final searchController = TextEditingController();
    List<Product> allProducts = [];
    List<Product> filteredProducts = [];
    bool isLoading = true;

    fetchProducts() async {
      final authState = context.read<AuthBloc>().state;
      final shopId = authState is Authenticated ? authState.user.shopId : null;
      if (shopId == null) return;
      try {
        final result = await GetProductsUseCase(di.sl<ProductRepository>())(NoParams(), shopId: shopId);
        result.fold(
          (failure) {},
          (products) {
            allProducts = products;
            filteredProducts = products;
            isLoading = false;
          },
        );
      } catch (e) {
        isLoading = false;
      }
    }

    fetchProducts();

    // Capture the page-level context BEFORE the dialog shadows it with its own
    // `context`. The scanner/manual-submit flows pop the dialog first, so they
    // must navigate + read BillingBloc using this still-valid page context.
    final pageContext = context;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Icon(Icons.add_shopping_cart_rounded, size: 22, color: AppColors.accentText(Theme.of(context).brightness)),
                  const SizedBox(width: 8),
                  const Text('Add Product',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Barcode input row
                    TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Enter barcode...',
                        prefixIcon: const Icon(Icons.qr_code_rounded, size: 20),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.camera_alt_rounded, size: 20),
                          tooltip: 'Scan barcode',
                          onPressed: () async {
                            Navigator.pop(ctx);
                            final result = await pageContext.push<String>('/scan/scanner');
                            if (result != null && result.isNotEmpty && pageContext.mounted) {
                              pageContext
                                  .read<BillingBloc>()
                                  .add(ScanBarcodeEvent(result));
                            }
                          },
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        isDense: true,
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          Navigator.pop(ctx);
                          pageContext
                              .read<BillingBloc>()
                              .add(ScanBarcodeEvent(value));
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    // Search field
                    TextField(
                      controller: searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Search products...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onChanged: (value) {
                        final query = value.toLowerCase().trim();
                        setDialogState(() {
                          filteredProducts = allProducts.where((product) {
                            return product.name.toLowerCase().contains(query) ||
                                product.barcode.toLowerCase().contains(query);
                          }).toList();
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    // Product list
                    isLoading
                        ? const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()))
                        : filteredProducts.isEmpty
                            ? SizedBox(
                                height: 120,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.inventory_2_outlined, size: 36, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                      const SizedBox(height: 8),
                                      Text(
                                        searchController.text.trim().isEmpty ? 'No products found' : 'No match',
                                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Container(
                                constraints: const BoxConstraints(maxHeight: 280),
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: filteredProducts.map((product) {
                                      final inCart = context.read<BillingBloc>().state.cartItems.any((i) => i.product.id == product.id);
                                      return InkWell(
                                        onTap: product.stock > 0
                                            ? () {
                                                context.read<BillingBloc>().add(AddProductToCartEvent(product));
                                                Navigator.of(ctx).pop();
                                                // SnackBar removed — cart update is visual feedback enough
                                              }
                                            : null,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                          decoration: BoxDecoration(
                                            border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
                                            color: product.stock == 0 ? Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3) : null,
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                                    const SizedBox(height: 2),
                                                    Text('Code: ${product.barcode}', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                                                  ],
                                                ),
                                              ),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Text('Stock: ${product.stock}', style: TextStyle(fontSize: 12, color: product.stock > 0 ? Theme.of(context).colorScheme.onSurfaceVariant : Theme.of(context).colorScheme.error)),
                                                  Text('₹${product.price.toStringAsFixed(2)}', style: AppMoneyText.sized(14, FontWeight.w700, AppColors.accentText(Theme.of(context).brightness))),
                                                ],
                                              ),
                                              if (inCart) ...[
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(4)),
                                                  child: Text('In Cart', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary)),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) => searchController.dispose());
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
            Icon(Icons.edit_rounded, size: 20, color: AppColors.accentText(Theme.of(context).brightness)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Edit Price',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
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
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.product.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '₹${_formatPrice(item.product.price)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
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
                fillColor: Theme.of(context).colorScheme.surface,
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
    ).then((_) => controller.dispose());
  }

  void _showWarrantyDialog(BuildContext context, CartItem item) {
    String selectedType = item.effectiveWarrantyType ?? 'none';
    final durationController = TextEditingController(
      text: item.effectiveWarrantyDuration?.toString() ?? '',
    );
    String selectedUnit = item.effectiveWarrantyUnit ?? 'months';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(Icons.verified_outlined, size: 22, color: AppColors.accentText(Theme.of(ctx).brightness)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Warranty / Guarantee',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Theme.of(ctx).colorScheme.onSurface),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(ctx).colorScheme.onSurface)),
                const SizedBox(height: 16),

                // Type selector
                Text('Type', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(ctx).colorScheme.onSurfaceVariant)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _warrantyTypeChip(ctx, 'None', 'none', selectedType, (v) => setDialogState(() => selectedType = v)),
                    const SizedBox(width: 8),
                    _warrantyTypeChip(ctx, 'Warranty', 'warranty', selectedType, (v) => setDialogState(() => selectedType = v)),
                    const SizedBox(width: 8),
                    _warrantyTypeChip(ctx, 'Guarantee', 'guarantee', selectedType, (v) => setDialogState(() => selectedType = v)),
                  ],
                ),

                if (selectedType != 'none') ...[
                  const SizedBox(height: 16),

                  // Duration
                  Text('Duration', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(ctx).colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: durationController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'e.g. 12',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(ctx).dividerColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: selectedUnit,
                          underline: const SizedBox(),
                          isDense: true,
                          items: const [
                            DropdownMenuItem(value: 'days', child: Text('Days')),
                            DropdownMenuItem(value: 'months', child: Text('Months')),
                            DropdownMenuItem(value: 'years', child: Text('Years')),
                          ],
                          onChanged: (val) {
                            if (val != null) setDialogState(() => selectedUnit = val);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            actions: [
              if (item.hasWarranty)
                TextButton(
                  onPressed: () {
                    context.read<BillingBloc>().add(UpdateItemWarrantyEvent(
                      productId: item.product.id,
                      warrantyType: 'none',
                    ));
                    Navigator.pop(ctx);
                  },
                  child: const Text('Remove'),
                ),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final duration = int.tryParse(durationController.text);
                  context.read<BillingBloc>().add(UpdateItemWarrantyEvent(
                    productId: item.product.id,
                    warrantyType: selectedType,
                    warrantyDuration: duration,
                    warrantyUnit: selectedUnit,
                  ));
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    ).then((_) => durationController.dispose());
  }

  /// Opens a searchable bottom-sheet listing saved customers.
  /// Tapping one emits SelectCustomerEvent so the billing bloc links it.
  Future<void> _showCustomerPicker(BuildContext context) async {
    final customerBloc = di.sl<CustomerBloc>();
    customerBloc.add(const LoadCustomers());

    final TextEditingController searchCtl = TextEditingController();

    final picked = await showModalBottomSheet<Customer?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (_, scrollController) {
            return BlocProvider.value(
              value: customerBloc,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  children: [
                    // Drag handle
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // Title
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Select Customer',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          icon: const Icon(Icons.close, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Search bar
                    TextField(
                      controller: searchCtl,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Search name or phone...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                      ),
                      onChanged: (v) {
                        customerBloc.add(SearchCustomers(v));
                      },
                    ),
                    const SizedBox(height: 12),
                    // Customer list
                    Expanded(
                      child: BlocBuilder<CustomerBloc, CustomerState>(
                        builder: (_, state) {
                          if (state.isLoading && state.customers.isEmpty) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (state.customers.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.people_outline, size: 48, color: Colors.grey),
                                    SizedBox(height: 12),
                                    Text('No customers found', style: TextStyle(fontSize: 14, color: Colors.grey)),
                                  ],
                                ),
                              ),
                            );
                          }
                          return ListView.builder(
                            controller: scrollController,
                            padding: EdgeInsets.zero,
                            itemCount: state.customers.length,
                            itemBuilder: (_, i) {
                              final c = state.customers[i];
                              final initial = c.name.isNotEmpty
                                  ? c.name.trim()[0].toUpperCase()
                                  : '?';
                              return Card(
                                margin: const EdgeInsets.only(bottom: 6),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                    child: Text(
                                      initial,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    c.name,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Text(
                                    c.phone.isNotEmpty ? c.phone : 'No phone',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  trailing: const Icon(Icons.chevron_right, size: 20),
                                  onTap: () {
                                    Navigator.of(sheetContext).pop(c);
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (picked != null && context.mounted) {
      context.read<BillingBloc>().add(SelectCustomerEvent(picked));
      _customerNameController.text = picked.name;
      _customerPhoneController.text = picked.phone;
    }
    searchCtl.dispose();
  }

  Widget _warrantyTypeChip(BuildContext ctx, String label, String value, String selected, Function(String) onTap) {
    final isSelected = selected == value;
    final theme = Theme.of(ctx);
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
