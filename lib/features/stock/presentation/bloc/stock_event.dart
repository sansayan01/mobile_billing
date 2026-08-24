part of 'stock_bloc.dart';

abstract class StockEvent extends Equatable {
  const StockEvent();

  @override
  List<Object> get props => [];
}

class AdjustStock extends StockEvent {
  final String productId;
  final int quantityChange;
  final StockAdjustmentReason reason;
  final String? note;

  const AdjustStock({
    required this.productId,
    required this.quantityChange,
    required this.reason,
    this.note,
  });

  @override
  List<Object> get props => [productId, quantityChange, reason, note ?? ''];
}

class LoadStockHistory extends StockEvent {
  final String productId;
  const LoadStockHistory(this.productId);

  @override
  List<Object> get props => [productId];
}

class LoadAllAdjustments extends StockEvent {}
