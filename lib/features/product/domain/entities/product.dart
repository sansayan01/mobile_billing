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

  // Warranty fields
  final String warrantyType; // 'none', 'warranty', 'guarantee'
  final int? warrantyDuration;
  final String? warrantyUnit; // 'days', 'months', 'years'

  // New fields
  final int minStockLevel; // Reorder point (default: 5)
  final String unit; // 'pcs', 'box', 'pack' etc.

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
    this.warrantyType = 'none',
    this.warrantyDuration,
    this.warrantyUnit,
    this.minStockLevel = 5,
    this.unit = 'pcs',
  });

  bool get hasWarranty =>
      warrantyType != 'none' && warrantyDuration != null && warrantyUnit != null;

  String get warrantyLabel {
    if (!hasWarranty) return '';
    return '$warrantyType: $warrantyDuration $warrantyUnit';
  }

  bool get isLowStock => stock <= minStockLevel;

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
    String? warrantyType,
    int? warrantyDuration,
    String? warrantyUnit,
    bool clearWarrantyDuration = false,
    bool clearWarrantyUnit = false,
    int? minStockLevel,
    String? unit,
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
      warrantyType: warrantyType ?? this.warrantyType,
      warrantyDuration: clearWarrantyDuration
          ? null
          : (warrantyDuration ?? this.warrantyDuration),
      warrantyUnit:
          clearWarrantyUnit ? null : (warrantyUnit ?? this.warrantyUnit),
      minStockLevel: minStockLevel ?? this.minStockLevel,
      unit: unit ?? this.unit,
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
        warrantyType,
        warrantyDuration,
        warrantyUnit,
        minStockLevel,
        unit,
      ];
}
