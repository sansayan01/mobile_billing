import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:billing_app/core/error/failure.dart';
import 'package:billing_app/core/supabase/supabase_client.dart';
import 'package:billing_app/features/damaged_products/domain/entities/damaged_product.dart';
import 'package:billing_app/features/damaged_products/domain/repositories/damaged_products_repository.dart';

class DamagedProductsRepositoryImpl implements DamagedProductsRepository {
  SupabaseClient get _supabase => SupabaseConfig.client;

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
    } catch (_) {}
    return null;
  }

  @override
  Future<Either<Failure, List<DamagedProduct>>> getDamagedProducts({
    String? shopId,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final effectiveShopId = await _resolveShopId(shopId);

      // Query stock_adjustments where reason = 'damage', joined with products
      var query = _supabase
          .from('stock_adjustments')
          .select('*, products(name, barcode, price, image_url)')
          .eq('reason', 'damage');

      if (effectiveShopId != null) {
        query = query.eq('shop_id', effectiveShopId);
      }

      if (startDate != null) {
        // toUtc() — bare local ISO strings are read as UTC by Postgres (IST shift)
        query = query.gte('created_at', startDate.toUtc().toIso8601String());
      }
      if (endDate != null) {
        // Add 1 day to include the full end date
        final endDateTime = endDate.add(const Duration(days: 1));
        query = query.lt('created_at', endDateTime.toUtc().toIso8601String());
      }

      // Search is done client-side since we need to search through joined product data

      final response = await query.order('created_at', ascending: false);

      final rows = (response as List<dynamic>);

      // Resolve ALL staff names in ONE query (avoids N+1: one profiles lookup
      // per row used to fire here).
      final staffIds = rows
          .map((row) => row['created_by'] as String?)
          .whereType<String>()
          .toSet()
          .toList();
      final staffNames = <String, String>{};
      if (staffIds.isNotEmpty) {
        try {
          final profileRows = await _supabase
              .from('profiles')
              .select('id, name')
              .inFilter('id', staffIds);
          for (final p in profileRows as List<dynamic>) {
            staffNames[p['id'] as String] =
                (p['name'] as String?) ?? (p['id'] as String);
          }
        } catch (_) {
          // Name resolution is best-effort; fall back to the raw id below.
        }
      }

      var damagedProducts = await Future.wait(rows.map((row) async {
        final productData = row['products'] as Map<String, dynamic>?;
        final productName = productData?['name'] as String? ?? 'Unknown';
        final productBarcode = productData?['barcode'] as String?;
        final productImage = productData?['image_url'] as String?;
        final productPrice = (productData?['price'] as num?)?.toDouble() ?? 0.0;
        final quantityChanged = (row['quantity_changed'] as num?)?.toInt() ?? 0;

        // The `note` column stores "type|notes" (see DamagedProduct.encodeNote).
        final (decodedType, decodedNotes) =
            DamagedProduct.decodeNote(row['note'] as String?);

        final reportedByName = row['created_by'] != null
            ? staffNames[row['created_by'] as String] ??
                (row['created_by'] as String)
            : null;

        return DamagedProduct(
          id: row['id'] as String,
          productId: row['product_id'] as String,
          productName: productName,
          productBarcode: productBarcode,
          productImage: productImage,
          productPrice: productPrice,
          quantityDamaged: quantityChanged.abs(),
          previousStock: (row['previous_stock'] as num?)?.toInt() ?? 0,
          newStock: (row['new_stock'] as num?)?.toInt() ?? 0,
          damageType: decodedType,
          notes: decodedNotes,
          damageDate: DateTime.parse(row['created_at'] as String),
          reportedByName: reportedByName,
          estimatedLoss: productPrice * quantityChanged.abs(),
        );
      }));

      // Client-side search filter
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final term = searchQuery.trim().toLowerCase();
        damagedProducts = damagedProducts.where((dp) {
          return dp.productName.toLowerCase().contains(term) ||
              (dp.productBarcode?.toLowerCase().contains(term) ?? false);
        }).toList();
      }

      return Right(damagedProducts);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch damaged products: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsDamaged({
    required String productId,
    required int quantity,
    String? damageType,
    String? notes,
    String? shopId,
  }) async {
    try {
      final effectiveShopId = await _resolveShopId(shopId);

      // Get current stock
      final productData = await _supabase
          .from('products')
          .select('stock, price')
          .eq('id', productId)
          .maybeSingle();

      if (productData == null) {
        return const Left(ServerFailure('Product not found'));
      }

      // Defensive cast: Postgres may return numerics as num/double, a blind
      // `as int` crashes on those.
      final currentStock = (productData['stock'] as num?)?.toInt() ?? 0;
      final newStock = currentStock - quantity;

      if (newStock < 0) {
        return const Left(ServerFailure('Cannot mark more as damaged than available stock'));
      }

      // Build note carrying both damage type and free-form notes as
      // "type|notes" (see DamagedProduct.encodeNote).
      final String note = DamagedProduct.encodeNote(damageType, notes);

      // Update product stock
      await _supabase
          .from('products')
          .update({'stock': newStock}).eq('id', productId);

      // Log the damage adjustment
      await _supabase.from('stock_adjustments').insert({
        'id': const Uuid().v4(),
        'product_id': productId,
        'previous_stock': currentStock,
        'new_stock': newStock,
        'quantity_changed': -quantity,
        'reason': 'damage',
        'note': note,
        'created_at': DateTime.now().toUtc().toIso8601String(),
        'created_by': _supabase.auth.currentUser?.id,
        'shop_id': effectiveShopId,
      });

      // Audit log
      final userId = _supabase.auth.currentUser?.id;
      String? staffName;
      try {
        if (userId != null) {
          final profile = await _supabase
              .from('profiles')
              .select('name')
              .eq('id', userId)
              .maybeSingle();
          staffName = profile?['name'] as String?;
        }
      } catch (_) {}

      await _supabase.from('audit_logs').insert({
        'action': 'stock.damaged',
        'entity_type': 'product',
        'entity_id': productId,
        'description':
            'Marked $quantity units as damaged${damageType != null && damageType.isNotEmpty ? " ($damageType)" : ""}',
        'old_value': {'stock': currentStock},
        'new_value': {'stock': newStock},
        'staff_name': staffName,
        'shop_id': effectiveShopId,
      });

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to mark as damaged: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> undoDamage({
    required String adjustmentId,
    required String productId,
    required int quantityRestored,
    String? shopId,
  }) async {
    try {
      final effectiveShopId = await _resolveShopId(shopId);

      // Get current stock
      final productData = await _supabase
          .from('products')
          .select('stock')
          .eq('id', productId)
          .maybeSingle();

      if (productData == null) {
        return const Left(ServerFailure('Product not found'));
      }

      final currentStock = (productData['stock'] as num?)?.toInt() ?? 0;
      final newStock = currentStock + quantityRestored;

      // Restore product stock
      await _supabase
          .from('products')
          .update({'stock': newStock}).eq('id', productId);

      // Remove the original damage adjustment row
      await _supabase
          .from('stock_adjustments')
          .delete()
          .eq('id', adjustmentId);

      // Audit log
      final userId = _supabase.auth.currentUser?.id;
      String? staffName;
      try {
        if (userId != null) {
          final profile = await _supabase
              .from('profiles')
              .select('name')
              .eq('id', userId)
              .maybeSingle();
          staffName = profile?['name'] as String?;
        }
      } catch (_) {}

      await _supabase.from('audit_logs').insert({
        'action': 'stock.damaged.undo',
        'entity_type': 'product',
        'entity_id': productId,
        'description': 'Reversed damage of $quantityRestored unit(s)',
        'old_value': {'stock': currentStock},
        'new_value': {'stock': newStock},
        'staff_name': staffName,
        'shop_id': effectiveShopId,
      });

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to undo damage: $e'));
    }
  }
}
