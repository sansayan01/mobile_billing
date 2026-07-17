import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final String barcode;
  final double price;
  final int stock;
  final String? categoryId;
  final String? location;
  final String? description;
  final String? imageUrl;
  final String? qrData;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Product({
    required this.id,
    required this.name,
    required this.barcode,
    required this.price,
    this.stock = 0,
    this.categoryId,
    this.location,
    this.description,
    this.imageUrl,
    this.qrData,
    this.createdAt,
    this.updatedAt,
  });

  Product copyWith({
    String? id,
    String? name,
    String? barcode,
    double? price,
    int? stock,
    String? categoryId,
    String? location,
    String? description,
    String? imageUrl,
    String? qrData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      categoryId: categoryId ?? this.categoryId,
      location: location ?? this.location,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      qrData: qrData ?? this.qrData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        barcode,
        price,
        stock,
        categoryId,
        location,
        description,
        imageUrl,
        qrData,
        createdAt,
        updatedAt,
      ];
}
