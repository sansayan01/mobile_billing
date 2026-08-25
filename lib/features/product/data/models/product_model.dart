// ignore_for_file: overridden_fields

import 'package:hive/hive.dart';
import '../../domain/entities/product.dart';

part 'product_model.g.dart';

@HiveType(typeId: 0)
class ProductModel extends Product {
  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final String name;
  @override
  @HiveField(2)
  final String barcode;
  @override
  @HiveField(3)
  final double price;
  @override
  @HiveField(4)
  final int stock;
  @override
  @HiveField(5)
  final String? categoryId;
  @override
  @HiveField(6)
  final String? location;
  @override
  @HiveField(7)
  final String? description;
  @override
  @HiveField(8)
  final String? imageUrl;
  @override
  @HiveField(9)
  final String? qrData;
  @override
  @HiveField(10)
  final DateTime? createdAt;
  @override
  @HiveField(11)
  final DateTime? updatedAt;
  @override
  @HiveField(12)
  final String warrantyType;
  @override
  @HiveField(13)
  final int? warrantyDuration;
  @override
  @HiveField(14)
  final String? warrantyUnit;
  @override
  @HiveField(15)
  final int minStockLevel;
  @override
  @HiveField(16)
  final String unit;

  const ProductModel({
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
  }) : super(
          id: id,
          name: name,
          barcode: barcode,
          price: price,
          stock: stock,
          categoryId: categoryId,
          location: location,
          description: description,
          imageUrl: imageUrl,
          qrData: qrData,
          createdAt: createdAt,
          updatedAt: updatedAt,
          warrantyType: warrantyType,
          warrantyDuration: warrantyDuration,
          warrantyUnit: warrantyUnit,
          minStockLevel: minStockLevel,
          unit: unit,
        );

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      barcode: product.barcode,
      price: product.price,
      stock: product.stock,
      categoryId: product.categoryId,
      location: product.location,
      description: product.description,
      imageUrl: product.imageUrl,
      qrData: product.qrData,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
      warrantyType: product.warrantyType,
      warrantyDuration: product.warrantyDuration,
      warrantyUnit: product.warrantyUnit,
      minStockLevel: product.minStockLevel,
      unit: product.unit,
    );
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      // Defensive — legacy rows may have null barcode.
      barcode: json['barcode'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      categoryId: json['category_id'] as String?,
      location: json['location'] as String?,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      qrData: json['qr_data'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      warrantyType: json['warranty_type'] as String? ?? 'none',
      warrantyDuration: (json['warranty_duration'] as num?)?.toInt(),
      warrantyUnit: json['warranty_unit'] as String?,
      minStockLevel: (json['min_stock_level'] as num?)?.toInt() ?? 5,
      unit: json['unit'] as String? ?? 'pcs',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'barcode': barcode,
      'price': price,
      'stock': stock,
      'category_id': categoryId,
      'location': location,
      'description': description,
      'image_url': imageUrl,
      'qr_data': qrData,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'warranty_type': warrantyType,
      'warranty_duration': warrantyDuration,
      'warranty_unit': warrantyUnit,
      'min_stock_level': minStockLevel,
      'unit': unit,
    };
  }

  Product toEntity() {
    return Product(
      id: id,
      name: name,
      barcode: barcode,
      price: price,
      stock: stock,
      categoryId: categoryId,
      location: location,
      description: description,
      imageUrl: imageUrl,
      qrData: qrData,
      createdAt: createdAt,
      updatedAt: updatedAt,
      warrantyType: warrantyType,
      warrantyDuration: warrantyDuration,
      warrantyUnit: warrantyUnit,
      minStockLevel: minStockLevel,
      unit: unit,
    );
  }
}
