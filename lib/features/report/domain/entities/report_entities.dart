import 'package:equatable/equatable.dart';

class BillItem extends Equatable {
  final String id;
  final String productId;
  final String productName;
  final int quantity;
  final double price;
  final double total;

  const BillItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.total,
  });

  BillItem copyWith({
    String? id,
    String? productId,
    String? productName,
    int? quantity,
    double? price,
    double? total,
  }) {
    return BillItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      total: total ?? this.total,
    );
  }

  @override
  List<Object?> get props =>
      [id, productId, productName, quantity, price, total];
}

class BillSummary extends Equatable {
  final String id;
  final String staffName;
  final int itemCount;
  final double totalAmount;
  final double discount;
  final double grandTotal;
  final String paymentMethod;
  final DateTime createdAt;
  final List<BillItem> items;
  final String? customerName;
  final String? customerPhone;

  const BillSummary({
    required this.id,
    required this.staffName,
    this.itemCount = 0,
    this.totalAmount = 0.0,
    this.discount = 0.0,
    this.grandTotal = 0.0,
    this.paymentMethod = 'Unknown',
    required this.createdAt,
    this.items = const [],
    this.customerName,
    this.customerPhone,
  });

  BillSummary copyWith({
    String? id,
    String? staffName,
    int? itemCount,
    double? totalAmount,
    double? discount,
    double? grandTotal,
    String? paymentMethod,
    DateTime? createdAt,
    List<BillItem>? items,
    String? customerName,
    String? customerPhone,
  }) {
    return BillSummary(
      id: id ?? this.id,
      staffName: staffName ?? this.staffName,
      itemCount: itemCount ?? this.itemCount,
      totalAmount: totalAmount ?? this.totalAmount,
      discount: discount ?? this.discount,
      grandTotal: grandTotal ?? this.grandTotal,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
    );
  }

  @override
  List<Object?> get props => [
        id,
        staffName,
        itemCount,
        totalAmount,
        discount,
        grandTotal,
        paymentMethod,
        createdAt,
        items,
        customerName,
        customerPhone,
      ];
}

class DailySales extends Equatable {
  final DateTime date;
  final double totalSales;
  final int billCount;
  final double averageBill;
  final double totalDiscount;

  const DailySales({
    required this.date,
    this.totalSales = 0.0,
    this.billCount = 0,
    this.averageBill = 0.0,
    this.totalDiscount = 0.0,
  });

  DailySales copyWith({
    DateTime? date,
    double? totalSales,
    int? billCount,
    double? averageBill,
    double? totalDiscount,
  }) {
    return DailySales(
      date: date ?? this.date,
      totalSales: totalSales ?? this.totalSales,
      billCount: billCount ?? this.billCount,
      averageBill: averageBill ?? this.averageBill,
      totalDiscount: totalDiscount ?? this.totalDiscount,
    );
  }

  @override
  List<Object?> get props =>
      [date, totalSales, billCount, averageBill, totalDiscount];
}

class StockMovement extends Equatable {
  final String id;
  final String productName;
  final String changeType;
  final int quantity;
  final String staffName;
  final String? notes;
  final DateTime createdAt;

  const StockMovement({
    required this.id,
    required this.productName,
    required this.changeType,
    required this.quantity,
    required this.staffName,
    this.notes,
    required this.createdAt,
  });

  StockMovement copyWith({
    String? id,
    String? productName,
    String? changeType,
    int? quantity,
    String? staffName,
    String? notes,
    DateTime? createdAt,
  }) {
    return StockMovement(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      changeType: changeType ?? this.changeType,
      quantity: quantity ?? this.quantity,
      staffName: staffName ?? this.staffName,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        productName,
        changeType,
        quantity,
        staffName,
        notes,
        createdAt,
      ];
}
