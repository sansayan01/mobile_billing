import 'dart:async';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/data/hive_database.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/supabase/supabase_client.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  SupabaseClient get _supabase => SupabaseConfig.client;

  ProductModel _fromMap(Map<String, dynamic> data) {
    return ProductModel(
      id: data['id'] as String,
      name: data['name'] as String,
      barcode: data['barcode'] as String,
      price: (data['price'] as num).toDouble(),
      stock: data['stock'] as int? ?? 0,
      categoryId: data['category_id'] as String?,
      location: data['location'] as String?,
      description: data['description'] as String?,
      imageUrl: data['image_url'] as String?,
      qrData: data['qr_data'] as String?,
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'] as String)
          : null,
      updatedAt: data['updated_at'] != null
          ? DateTime.parse(data['updated_at'] as String)
          : null,
    );
  }

  /// Resolve shopId: if not provided, fetch from current user's profile.
  Future<String?> _resolveShopId(String? shopId) async {
    if (shopId != null) return shopId;
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;
      final profile = await _supabase
          .from('profiles')
          .select('shop_id')
          .eq('id', userId)
          .maybeSingle();
      if (profile != null) {
        return profile['shop_id'] as String?;
      }
    } catch (_) {
      // If profile fetch fails, return null — RLS may block the operation.
    }
    return null;
  }

  @override
  Future<Either<Failure, List<Product>>> getProducts({String? shopId}) async {
    try {
      final effectiveShopId = await _resolveShopId(shopId);
      var query = _supabase.from('products').select();
      if (effectiveShopId != null) {
        query = query.eq('shop_id', effectiveShopId);
      }
      final response = await query.order('created_at', ascending: false);

      final products = (response as List<dynamic>)
          .map((e) => _fromMap(e as Map<String, dynamic>))
          .toList();

      // Cache in Hive for offline fallback (batched write)
      final box = HiveDatabase.productBox;
      await box.clear();
      await box.putAll({for (final product in products) product.id: product});

      return Right(products);
    } catch (e) {
      // Fallback to Hive cache
      try {
        final box = HiveDatabase.productBox;
        final products = box.values.toList();
        return Right(products);
      } catch (cacheError) {
        return Left(CacheFailure('Failed to fetch products: $e'));
      }
    }
  }

  @override
  Future<Either<Failure, Product>> getProductByBarcode(
    String barcode, {
    String? shopId,
  }) async {
    try {
      final effectiveShopId = await _resolveShopId(shopId);
      var query = _supabase.from('products').select().eq('barcode', barcode);
      if (effectiveShopId != null) {
        query = query.eq('shop_id', effectiveShopId);
      }
      final response = await query.maybeSingle();

      if (response != null) {
        final product = _fromMap(response);
        return Right(product);
      }

      // Fallback to Hive
      final box = HiveDatabase.productBox;
      final product = box.values.firstWhere(
        (element) => element.barcode == barcode,
        orElse: () => throw Exception('Product not found'),
      );
      return Right(product);
    } catch (e) {
      try {
        final box = HiveDatabase.productBox;
        final product = box.values.firstWhere(
          (element) => element.barcode == barcode,
          orElse: () => throw Exception('Product not found'),
        );
        return Right(product);
      } catch (cacheError) {
        return Left(CacheFailure('Failed to find product by barcode: $e'));
      }
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getProductsByCategory(
    String categoryId, {
    String? shopId,
  }) async {
    try {
      final effectiveShopId = await _resolveShopId(shopId);
      var query = _supabase
          .from('products')
          .select()
          .eq('category_id', categoryId);
      if (effectiveShopId != null) {
        query = query.eq('shop_id', effectiveShopId);
      }
      final response = await query.order('created_at', ascending: false);

      final products = (response as List<dynamic>)
          .map((e) => _fromMap(e as Map<String, dynamic>))
          .toList();

      return Right(products);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch products by category: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addProduct(
    Product product, {
    String? shopId,
  }) async {
    try {
      final effectiveShopId = await _resolveShopId(shopId);
      final model = ProductModel.fromEntity(product);
      await _supabase.from('products').insert({
        'id': model.id,
        'name': model.name,
        'barcode': model.barcode,
        'price': model.price,
        'stock': model.stock,
        'category_id': model.categoryId,
        'location': model.location,
        'description': model.description,
        'image_url': model.imageUrl,
        'qr_data': model.qrData,
        'shop_id': effectiveShopId,
      });

      // Cache in Hive
      final box = HiveDatabase.productBox;
      await box.put(model.id, model);

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to add product: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateProduct(
    Product product, {
    String? shopId,
  }) async {
    try {
      final effectiveShopId = await _resolveShopId(shopId);
      final model = ProductModel.fromEntity(product);
      await _supabase.from('products').upsert({
        'id': model.id,
        'name': model.name,
        'barcode': model.barcode,
        'price': model.price,
        'stock': model.stock,
        'category_id': model.categoryId,
        'location': model.location,
        'description': model.description,
        'image_url': model.imageUrl,
        'qr_data': model.qrData,
        'shop_id': effectiveShopId,
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Update in Hive
      final box = HiveDatabase.productBox;
      await box.put(model.id, model);

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to update product: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getCurrentStockBulk(
    List<String> productIds, {
    String? shopId,
  }) async {
    try {
      final effectiveShopId = await _resolveShopId(shopId);
      var query = _supabase
          .from('products')
          .select('id, name, stock');
      if (effectiveShopId != null) {
        query = query.eq('shop_id', effectiveShopId);
      }
      final response = await query.filter('id', 'in', productIds);

      final stockMap = <String, int>{};
      for (final row in response as List<dynamic>) {
        final data = row as Map<String, dynamic>;
        stockMap[data['id'] as String] = data['stock'] as int;
      }

      return Right(stockMap);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch current stock: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(
    String id, {
    String? shopId,
  }) async {
    try {
      // Remove dependent records first (FK constraints block direct delete)
      await _supabase.from('inventory_log').delete().eq('product_id', id);
      await _supabase.from('bill_items').delete().eq('product_id', id);

      final effectiveShopId = await _resolveShopId(shopId);
      var query = _supabase.from('products').delete().eq('id', id);
      if (effectiveShopId != null) {
        query = query.eq('shop_id', effectiveShopId);
      }
      await query;

      // Delete from Hive
      final box = HiveDatabase.productBox;
      await box.delete(id);

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to delete product: $e'));
    }
  }
}
