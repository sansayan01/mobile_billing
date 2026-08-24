import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  final String id;
  final String shopId;
  final String name;
  final String phone;
  final DateTime createdAt;

  const Customer({
    required this.id,
    required this.shopId,
    required this.name,
    required this.phone,
    required this.createdAt,
  });

  /// Empty instance for safe UI initialization.
  Customer.empty()
      : id = '',
        shopId = '',
        name = '',
        phone = '',
        createdAt = DateTime(0);

  Customer copyWith({
    String? id,
    String? shopId,
    String? name,
    String? phone,
    DateTime? createdAt,
  }) {
    return Customer(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, shopId, name, phone, createdAt];
}
