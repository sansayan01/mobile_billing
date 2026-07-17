import 'package:billing_app/features/report/domain/entities/report_entities.dart';

class BillItemModel extends BillItem {
  const BillItemModel({
    required super.id,
    required super.productId,
    required super.productName,
    required super.quantity,
    required super.price,
    required super.total,
  });

  factory BillItemModel.fromJson(Map<String, dynamic> json) {
    return BillItemModel(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'price': price,
      'total': total,
    };
  }
}

class BillSummaryModel extends BillSummary {
  const BillSummaryModel({
    required super.id,
    required super.staffName,
    super.itemCount,
    super.totalAmount,
    super.discount,
    super.grandTotal,
    super.paymentMethod,
    required super.createdAt,
    super.items,
  });

  factory BillSummaryModel.fromJson(Map<String, dynamic> json) {
    return BillSummaryModel(
      id: json['id'] as String,
      staffName: json['staff_name'] as String,
      itemCount: json['item_count'] as int? ?? 0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      grandTotal: (json['grand_total'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['payment_method'] as String? ?? 'Unknown',
      createdAt: DateTime.parse(json['created_at'] as String),
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => BillItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'staff_name': staffName,
      'item_count': itemCount,
      'total_amount': totalAmount,
      'discount': discount,
      'grand_total': grandTotal,
      'payment_method': paymentMethod,
      'created_at': createdAt.toIso8601String(),
      'items': items.map((e) => (e as BillItemModel).toJson()).toList(),
    };
  }

  factory BillSummaryModel.fromSupabaseRow(Map<String, dynamic> row) {
    // Extract item count from embedded bill_items relationship if present
    int itemCount = 0;
    List<BillItem> items = [];
    if (row['bill_items'] != null && row['bill_items'] is List) {
      final billItems = row['bill_items'] as List;
      itemCount = billItems.length;
      items = billItems
          .map((e) => BillItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // Extract staff name from embedded profiles relationship
    final profileData = row['profiles'] as Map<String, dynamic>?;
    final staffName = profileData?['name'] as String? ?? 'Unknown';

    return BillSummaryModel(
      id: row['id'] as String,
      staffName: staffName,
      itemCount: itemCount,
      totalAmount: (row['total_amount'] as num?)?.toDouble() ?? 0.0,
      discount: (row['discount'] as num?)?.toDouble() ?? 0.0,
      grandTotal: (row['grand_total'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: row['payment_method'] as String? ?? 'Unknown',
      createdAt: DateTime.parse(row['created_at'] as String),
      items: items,
    );
  }
}

class DailySalesModel extends DailySales {
  const DailySalesModel({
    required super.date,
    super.totalSales,
    super.billCount,
    super.averageBill,
    super.totalDiscount,
  });

  factory DailySalesModel.fromJson(Map<String, dynamic> json) {
    return DailySalesModel(
      date: DateTime.parse(json['date'] as String),
      totalSales: (json['total_sales'] as num?)?.toDouble() ?? 0.0,
      billCount: json['bill_count'] as int? ?? 0,
      averageBill: (json['average_bill'] as num?)?.toDouble() ?? 0.0,
      totalDiscount: (json['total_discount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'total_sales': totalSales,
      'bill_count': billCount,
      'average_bill': averageBill,
      'total_discount': totalDiscount,
    };
  }
}

class StockMovementModel extends StockMovement {
  const StockMovementModel({
    required super.id,
    required super.productName,
    required super.changeType,
    required super.quantity,
    required super.staffName,
    super.notes,
    required super.createdAt,
  });

  factory StockMovementModel.fromJson(Map<String, dynamic> json) {
    return StockMovementModel(
      id: json['id'] as String,
      productName: json['product_name'] as String,
      changeType: json['change_type'] as String,
      quantity: json['quantity'] as int,
      staffName: json['staff_name'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_name': productName,
      'change_type': changeType,
      'quantity': quantity,
      'staff_name': staffName,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory StockMovementModel.fromSupabaseRow(Map<String, dynamic> row) {
    // Extract product name from embedded products relationship
    final productData = row['products'] as Map<String, dynamic>?;
    final productName = productData?['name'] as String? ?? 'Unknown';

    // Extract staff name from embedded profiles relationship
    final profileData = row['profiles'] as Map<String, dynamic>?;
    final staffName = profileData?['name'] as String? ?? 'Unknown';

    return StockMovementModel(
      id: row['id'] as String,
      productName: productName,
      changeType: row['change_type'] as String,
      quantity: row['quantity'] as int,
      staffName: staffName,
      notes: row['notes'] as String?,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }
}
