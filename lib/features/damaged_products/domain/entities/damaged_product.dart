import 'package:equatable/equatable.dart';

class DamagedProduct extends Equatable {
  final String id; // stock_adjustment id
  final String productId;
  final String productName;
  final String? productBarcode;
  final String? productImage;
  final double productPrice;
  final int quantityDamaged;
  final int previousStock;
  final int newStock;
  final String? damageType; // 'broken', 'defective', 'expired', 'water_damage', 'other'
  final String? notes;
  final DateTime damageDate;
  final String? reportedByName;
  final double estimatedLoss; // productPrice * quantityDamaged

  const DamagedProduct({
    required this.id,
    required this.productId,
    required this.productName,
    this.productBarcode,
    this.productImage,
    required this.productPrice,
    required this.quantityDamaged,
    required this.previousStock,
    required this.newStock,
    this.damageType,
    this.notes,
    required this.damageDate,
    this.reportedByName,
    required this.estimatedLoss,
  });

  @override
  List<Object?> get props => [
        id,
        productId,
        productName,
        productBarcode,
        productImage,
        productPrice,
        quantityDamaged,
        previousStock,
        newStock,
        damageType,
        notes,
        damageDate,
        reportedByName,
        estimatedLoss,
      ];

  /// DB `note` column stores both damage type and free-form notes as
  /// "type|notes". These helpers keep that encoding in one place so the
  /// repository and the page never drift.
  static String encodeNote(String? damageType, String? notes) {
    final type = (damageType ?? '').trim();
    final note = (notes ?? '').trim();
    if (type.isEmpty && note.isEmpty) return '';
    return '$type|$note';
  }

  /// Reverse of [encodeNote]. Returns (damageType, notes).
  static (String?, String?) decodeNote(String? raw) {
    if (raw == null || raw.isEmpty) return (null, null);
    final idx = raw.indexOf('|');
    if (idx == -1) {
      // Legacy row: only the raw type was stored.
      return (raw, null);
    }
    final type = raw.substring(0, idx).trim();
    final note = raw.substring(idx + 1).trim();
    return (type.isEmpty ? null : type, note.isEmpty ? null : note);
  }

  /// Human-friendly label for the stored damage type value.
  static String damageTypeLabel(String? type) {
    switch (type) {
      case 'broken':
        return 'Broken';
      case 'defective':
        return 'Defective';
      case 'expired':
        return 'Expired';
      case 'water_damage':
        return 'Water Damage';
      case 'scratched':
        return 'Scratched';
      case 'other':
        return 'Other';
      default:
        return type ?? 'Unknown';
    }
  }
}
