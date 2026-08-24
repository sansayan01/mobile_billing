import 'package:equatable/equatable.dart';

enum StockAdjustmentReason {
  sale,        // Bill se stock kam hua
  return_,     // Customer return
  damage,      // Product damage
  sample,      // Sample diya
  found,       // Stock mila
  theft,       // Chori/loss
  adjustment,  // Manual correction
  restock,     // Naya stock aaya
}

class StockAdjustment extends Equatable {
  final String id;
  final String productId;
  final int previousStock;
  final int newStock;
  final int quantityChanged; // +ve ya -ve
  final StockAdjustmentReason reason;
  final String? note;
  final DateTime createdAt;
  final String? createdBy;

  const StockAdjustment({
    required this.id,
    required this.productId,
    required this.previousStock,
    required this.newStock,
    required this.quantityChanged,
    required this.reason,
    this.note,
    required this.createdAt,
    this.createdBy,
  });

  String get reasonLabel {
    switch (reason) {
      case StockAdjustmentReason.sale:
        return 'Sale';
      case StockAdjustmentReason.return_:
        return 'Return';
      case StockAdjustmentReason.damage:
        return 'Damage';
      case StockAdjustmentReason.sample:
        return 'Sample';
      case StockAdjustmentReason.found:
        return 'Found';
      case StockAdjustmentReason.theft:
        return 'Theft/Loss';
      case StockAdjustmentReason.adjustment:
        return 'Adjustment';
      case StockAdjustmentReason.restock:
        return 'Restock';
    }
  }

  bool get isIncrease => quantityChanged > 0;

  @override
  List<Object?> get props => [
        id,
        productId,
        previousStock,
        newStock,
        quantityChanged,
        reason,
        note,
        createdAt,
        createdBy,
      ];
}
