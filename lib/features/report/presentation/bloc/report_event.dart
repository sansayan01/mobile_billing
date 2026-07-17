import 'package:equatable/equatable.dart';

abstract class ReportEvent extends Equatable {
  const ReportEvent();

  @override
  List<Object?> get props => [];
}

class LoadBillHistory extends ReportEvent {
  final DateTime? from;
  final DateTime? to;
  final int page;

  const LoadBillHistory({this.from, this.to, this.page = 1});

  @override
  List<Object?> get props => [from, to, page];
}

class LoadBillDetail extends ReportEvent {
  final String billId;

  const LoadBillDetail(this.billId);

  @override
  List<Object?> get props => [billId];
}

class LoadDailySales extends ReportEvent {
  final DateTime date;

  const LoadDailySales(this.date);

  @override
  List<Object?> get props => [date];
}

class LoadSalesRange extends ReportEvent {
  final DateTime from;
  final DateTime to;

  const LoadSalesRange({required this.from, required this.to});

  @override
  List<Object?> get props => [from, to];
}

class LoadLowStockProducts extends ReportEvent {
  final int threshold;

  const LoadLowStockProducts(this.threshold);

  @override
  List<Object?> get props => [threshold];
}

class LoadStockMovements extends ReportEvent {
  final String? productId;
  final DateTime? from;
  final DateTime? to;
  final String? changeType;

  const LoadStockMovements({this.productId, this.from, this.to, this.changeType});

  @override
  List<Object?> get props => [productId, from, to, changeType];
}

class ResetReport extends ReportEvent {}
