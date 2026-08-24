part of 'stock_bloc.dart';

enum StockStatus { initial, loading, loaded, error, success }

class StockState extends Equatable {
  final StockStatus status;
  final List<StockAdjustment> adjustments;
  final String? message;

  const StockState({
    this.status = StockStatus.initial,
    this.adjustments = const [],
    this.message,
  });

  StockState copyWith({
    StockStatus? status,
    List<StockAdjustment>? adjustments,
    String? message,
  }) {
    return StockState(
      status: status ?? this.status,
      adjustments: adjustments ?? this.adjustments,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, adjustments, message];
}
