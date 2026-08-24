part of 'damaged_products_bloc.dart';

abstract class DamagedProductsEvent extends Equatable {
  const DamagedProductsEvent();
  @override
  List<Object> get props => [];
}

class LoadDamagedProducts extends DamagedProductsEvent {
  const LoadDamagedProducts();
}

class SearchDamagedProducts extends DamagedProductsEvent {
  final String? query;
  const SearchDamagedProducts(this.query);
  @override
  List<Object> get props => [query ?? ''];
}

class FilterDamagedProductsByDate extends DamagedProductsEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  const FilterDamagedProductsByDate({this.startDate, this.endDate});
  @override
  List<Object> get props => [startDate ?? '', endDate ?? ''];
}

class MarkProductAsDamaged extends DamagedProductsEvent {
  final String productId;
  final int quantity;
  final String? damageType;
  final String? notes;
  const MarkProductAsDamaged({
    required this.productId,
    required this.quantity,
    this.damageType,
    this.notes,
  });
  @override
  List<Object> get props => [productId, quantity, damageType ?? '', notes ?? ''];
}

class UndoDamagedProduct extends DamagedProductsEvent {
  final String adjustmentId;
  final String productId;
  final int quantityRestored;
  const UndoDamagedProduct({
    required this.adjustmentId,
    required this.productId,
    required this.quantityRestored,
  });
  @override
  List<Object> get props =>
      [adjustmentId, productId, quantityRestored];
}
