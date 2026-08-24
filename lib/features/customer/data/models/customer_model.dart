import 'package:billing_app/features/customer/domain/entities/customer.dart';

class CustomerModel {
  final String id;
  final String shopId;
  final String name;
  final String phone;
  final DateTime createdAt;

  const CustomerModel({
    required this.id,
    required this.shopId,
    required this.name,
    required this.phone,
    required this.createdAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as String,
      shopId: json['shop_id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_id': shopId,
      'name': name,
      'phone': phone,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Customer toEntity() {
    return Customer(
      id: id,
      shopId: shopId,
      name: name,
      phone: phone,
      createdAt: createdAt,
    );
  }

  factory CustomerModel.fromEntity(Customer customer) {
    return CustomerModel(
      id: customer.id,
      shopId: customer.shopId,
      name: customer.name,
      phone: customer.phone,
      createdAt: customer.createdAt,
    );
  }

  CustomerModel copyWith({
    String? id,
    String? shopId,
    String? name,
    String? phone,
    DateTime? createdAt,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
