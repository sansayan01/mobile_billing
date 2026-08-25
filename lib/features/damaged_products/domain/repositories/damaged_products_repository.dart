import 'package:fpdart/fpdart.dart';
import 'package:billing_app/core/error/failure.dart';
import 'package:billing_app/features/damaged_products/domain/entities/damaged_product.dart';

abstract class DamagedProductsRepository {
  /// Get all damaged products for a shop
  Future<Either<Failure, List<DamagedProduct>>> getDamagedProducts({
    String? shopId,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Mark a product as damaged (decreases stock + logs adjustment)
  Future<Either<Failure, void>> markAsDamaged({
    required String productId,
    required int quantity,
    String? damageType,
    String? notes,
    String? shopId,
  });

  /// Reverse a previously recorded damage (restores stock + removes the
  /// adjustment + logs an audit entry). [adjustmentId] is the
  /// `stock_adjustments.id` row created when the item was marked damaged.
  Future<Either<Failure, void>> undoDamage({
    required String adjustmentId,
    required String productId,
    required int quantityRestored,
    String? shopId,
  });
}
