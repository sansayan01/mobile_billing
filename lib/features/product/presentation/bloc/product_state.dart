part of 'product_bloc.dart';

enum ProductStatus { initial, loading, loaded, error, success }

class ProductState extends Equatable {
  final ProductStatus status;
  final List<Product> products;
  final List<Product> filteredProducts;
  final String? selectedCategoryId;
  final String? message;

  const ProductState({
    this.status = ProductStatus.initial,
    this.products = const [],
    this.filteredProducts = const [],
    this.selectedCategoryId,
    this.message,
  });

  ProductState copyWith({
    ProductStatus? status,
    List<Product>? products,
    List<Product>? filteredProducts,
    String? selectedCategoryId,
    bool clearSelectedCategory = false,
    String? message,
  }) {
    return ProductState(
      status: status ?? this.status,
      products: products ?? this.products,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      selectedCategoryId: clearSelectedCategory ? null : (selectedCategoryId ?? this.selectedCategoryId),
      message: message,
    );
  }

  @override
  List<Object?> get props => [
        status,
        products,
        filteredProducts,
        selectedCategoryId,
        message,
      ];
}
