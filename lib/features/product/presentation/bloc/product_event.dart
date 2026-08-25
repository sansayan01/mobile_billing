part of 'product_bloc.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object> get props => [];
}

class LoadProducts extends ProductEvent {}

class AddProduct extends ProductEvent {
  final Product product;
  const AddProduct(this.product);
  @override
  List<Object> get props => [product];
}

/// Bulk insert (e.g. CSV import) — reloads products once after the batch.
class AddProductsBulk extends ProductEvent {
  final List<Product> products;
  const AddProductsBulk(this.products);
  @override
  List<Object> get props => [products];
}

class UpdateProduct extends ProductEvent {
  final Product product;
  const UpdateProduct(this.product);
  @override
  List<Object> get props => [product];
}

class DeleteProduct extends ProductEvent {
  final String id;
  const DeleteProduct(this.id);
  @override
  List<Object> get props => [id];
}

class FilterByCategory extends ProductEvent {
  final String? categoryId;
  const FilterByCategory(this.categoryId);
  @override
  List<Object> get props => [categoryId ?? ''];
}

class InitRealtime extends ProductEvent {}

class ProductsRealtimeUpdated extends ProductEvent {
  final String changeType;
  final Map<String, dynamic> payload;

  const ProductsRealtimeUpdated({
    required this.changeType,
    required this.payload,
  });

  @override
  List<Object> get props => [changeType, payload];
}
