import 'package:equatable/equatable.dart';

class AuditLog extends Equatable {
  final String id;
  final String action;
  final String entityType;
  final String? entityId;
  final String? entityName;
  final String description;
  final Map<String, dynamic>? oldValue;
  final Map<String, dynamic>? newValue;
  final String? performedBy;
  final String? staffName;
  final String? shopId;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  const AuditLog({
    required this.id,
    required this.action,
    required this.entityType,
    this.entityId,
    this.entityName,
    required this.description,
    this.oldValue,
    this.newValue,
    this.performedBy,
    this.staffName,
    this.shopId,
    this.metadata,
    required this.createdAt,
  });

  AuditLog copyWith({
    String? id,
    String? action,
    String? entityType,
    String? entityId,
    String? entityName,
    String? description,
    Map<String, dynamic>? oldValue,
    Map<String, dynamic>? newValue,
    String? performedBy,
    String? staffName,
    String? shopId,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    bool clearOldValue = false,
    bool clearNewValue = false,
    bool clearMetadata = false,
  }) {
    return AuditLog(
      id: id ?? this.id,
      action: action ?? this.action,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      entityName: entityName ?? this.entityName,
      description: description ?? this.description,
      oldValue: clearOldValue ? null : (oldValue ?? this.oldValue),
      newValue: clearNewValue ? null : (newValue ?? this.newValue),
      performedBy: performedBy ?? this.performedBy,
      staffName: staffName ?? this.staffName,
      shopId: shopId ?? this.shopId,
      metadata: clearMetadata ? null : (metadata ?? this.metadata),
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Display label for the action
  String get actionLabel {
    switch (action) {
      case 'stock.added': return 'Stock Added';
      case 'stock.removed': return 'Stock Removed';
      case 'stock.adjusted': return 'Stock Adjusted';
      case 'bill.created': return 'Bill Created';
      case 'bill.edited': return 'Bill Edited';
      case 'bill.voided': return 'Bill Voided';
      case 'bill.payment': return 'Payment Collected';
      case 'product.created': return 'Product Added';
      case 'product.edited': return 'Product Edited';
      case 'product.deleted': return 'Product Deleted';
      case 'category.created': return 'Category Added';
      case 'category.edited': return 'Category Edited';
      case 'category.deleted': return 'Category Deleted';
      case 'auth.login': return 'Staff Login';
      case 'settings.updated': return 'Settings Updated';
      default: return action;
    }
  }

  @override
  List<Object?> get props => [
        id, action, entityType, entityId, entityName,
        description, oldValue, newValue, performedBy,
        staffName, shopId, metadata, createdAt,
      ];
}
