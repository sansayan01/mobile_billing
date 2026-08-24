import 'package:equatable/equatable.dart';
import 'package:billing_app/features/product/domain/entities/product.dart';

class CartItem extends Equatable {
  final Product product;
  final int quantity;
  final double? customPrice;
  
  // Warranty override — checkout pe manual warranty set karne ke liye
  final String? warrantyTypeOverride;
  final int? warrantyDurationOverride;
  final String? warrantyUnitOverride;

  const CartItem({
    required this.product,
    this.quantity = 1,
    this.customPrice,
    this.warrantyTypeOverride,
    this.warrantyDurationOverride,
    this.warrantyUnitOverride,
  });

  double get unitPrice => customPrice ?? product.price;
  double get total => unitPrice * quantity;

  /// Actual warranty type — override ya product ka default
  String? get effectiveWarrantyType =>
      warrantyTypeOverride ?? product.warrantyType;

  /// Actual warranty duration — override ya product ka default
  int? get effectiveWarrantyDuration =>
      warrantyDurationOverride ?? product.warrantyDuration;

  /// Actual warranty unit — override ya product ka default
  String? get effectiveWarrantyUnit =>
      warrantyUnitOverride ?? product.warrantyUnit;

  /// Check if product has effective warranty
  bool get hasWarranty =>
      effectiveWarrantyType != null &&
      effectiveWarrantyType != 'none' &&
      effectiveWarrantyDuration != null;

  /// Warranty label for display
  String get warrantyLabel {
    if (!hasWarranty) return '';
    final type = effectiveWarrantyType == 'guarantee' ? 'Guarantee' : 'Warranty';
    return '$type: $effectiveWarrantyDuration $effectiveWarrantyUnit';
  }

  CartItem copyWith({
    Product? product,
    int? quantity,
    double? customPrice,
    bool clearCustomPrice = false,
    String? warrantyTypeOverride,
    int? warrantyDurationOverride,
    String? warrantyUnitOverride,
    bool clearWarrantyOverride = false,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      customPrice: clearCustomPrice ? null : (customPrice ?? this.customPrice),
      warrantyTypeOverride: clearWarrantyOverride ? null : (warrantyTypeOverride ?? this.warrantyTypeOverride),
      warrantyDurationOverride: clearWarrantyOverride ? null : (warrantyDurationOverride ?? this.warrantyDurationOverride),
      warrantyUnitOverride: clearWarrantyOverride ? null : (warrantyUnitOverride ?? this.warrantyUnitOverride),
    );
  }

  @override
  List<Object?> get props => [
        product,
        quantity,
        customPrice,
        warrantyTypeOverride,
        warrantyDurationOverride,
        warrantyUnitOverride,
      ];
}
