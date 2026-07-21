import 'package:equatable/equatable.dart';
import 'package:billing_app/features/product/domain/entities/product.dart';

class CartItem extends Equatable {
  final Product product;
  final int quantity;
  final double? customPrice;

  const CartItem({
    required this.product,
    this.quantity = 1,
    this.customPrice,
  });

  double get unitPrice => customPrice ?? product.price;
  double get total => unitPrice * quantity;

  CartItem copyWith({
    Product? product,
    int? quantity,
    double? customPrice,
    bool clearCustomPrice = false,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      customPrice: clearCustomPrice ? null : (customPrice ?? this.customPrice),
    );
  }

  @override
  List<Object?> get props => [product, quantity, customPrice];
}
