part of 'billing_bloc.dart';

abstract class BillingEvent extends Equatable {
  const BillingEvent();
  @override
  List<Object> get props => [];
}

class ScanBarcodeEvent extends BillingEvent {
  final String barcode;
  const ScanBarcodeEvent(this.barcode);
  @override
  List<Object> get props => [barcode];
}

class AddProductToCartEvent extends BillingEvent {
  final Product product;
  const AddProductToCartEvent(this.product);
  @override
  List<Object> get props => [product];
}

class RemoveProductFromCartEvent extends BillingEvent {
  final String productId;
  const RemoveProductFromCartEvent(this.productId);
  @override
  List<Object> get props => [productId];
}

class UpdateQuantityEvent extends BillingEvent {
  final String productId;
  final int quantity;
  const UpdateQuantityEvent(this.productId, this.quantity);
  @override
  List<Object> get props => [productId, quantity];
}

class UpdateItemPriceEvent extends BillingEvent {
  final String productId;
  final double? customPrice;
  const UpdateItemPriceEvent(this.productId, this.customPrice);
  @override
  List<Object> get props => [productId, customPrice ?? -1.0];
}

class ClearCartEvent extends BillingEvent {}

class PrintReceiptEvent extends BillingEvent {
  final String shopName;
  final String address1;
  final String address2;
  final String phone;
  final String footer;
  final String? customerName;
  final String? customerPhone;

  const PrintReceiptEvent({
    required this.shopName,
    required this.address1,
    required this.address2,
    required this.phone,
    required this.footer,
    this.customerName,
    this.customerPhone,
  });

  @override
  List<Object> get props => [
        shopName,
        address1,
        address2,
        phone,
        footer,
        customerName ?? '',
        customerPhone ?? '',
      ];
}

class UpdateDiscountEvent extends BillingEvent {
  final double? discount;
  final bool isPercentage;
  const UpdateDiscountEvent(this.discount, this.isPercentage);
  @override
  List<Object> get props => [discount ?? 0.0, isPercentage];
}

class UpdateGrandTotalOverrideEvent extends BillingEvent {
  final double? grandTotal;
  const UpdateGrandTotalOverrideEvent(this.grandTotal);
  @override
  List<Object> get props => [grandTotal ?? 0.0];
}

class SetDiscountTypeEvent extends BillingEvent {
  final bool isPercentage;
  const SetDiscountTypeEvent(this.isPercentage);
  @override
  List<Object> get props => [isPercentage];
}

class SubmitBillEvent extends BillingEvent {
  const SubmitBillEvent();
}

class ValidateStockBeforeBill extends BillingEvent {
  const ValidateStockBeforeBill();
}

class ClearStockErrorsEvent extends BillingEvent {
  const ClearStockErrorsEvent();
}

class UpdateCustomerInfoEvent extends BillingEvent {
  final String? customerName;
  final String? customerPhone;
  const UpdateCustomerInfoEvent({this.customerName, this.customerPhone});

  @override
  List<Object> get props => [customerName ?? '', customerPhone ?? ''];
}
