import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProductsUseCase implements UseCase<List<Product>, NoParams> {
  final ProductRepository repository;

  GetProductsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Product>>> call(
    NoParams params, {
    String? shopId,
  }) {
    return repository.getProducts(shopId: shopId);
  }
}

class AddProductUseCase implements UseCase<void, Product> {
  final ProductRepository repository;

  AddProductUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(
    Product params, {
    String? shopId,
  }) {
    return repository.addProduct(params, shopId: shopId);
  }
}

class UpdateProductUseCase implements UseCase<void, Product> {
  final ProductRepository repository;

  UpdateProductUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(
    Product params, {
    String? shopId,
  }) {
    return repository.updateProduct(params, shopId: shopId);
  }
}

class DeleteProductUseCase implements UseCase<void, String> {
  final ProductRepository repository;

  DeleteProductUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(
    String params, {
    String? shopId,
  }) {
    return repository.deleteProduct(params, shopId: shopId);
  }
}

class GetProductByBarcodeUseCase implements UseCase<Product, String> {
  final ProductRepository repository;

  GetProductByBarcodeUseCase(this.repository);

  @override
  Future<Either<Failure, Product>> call(
    String params, {
    String? shopId,
  }) {
    return repository.getProductByBarcode(params, shopId: shopId);
  }
}

class GetProductsByCategoryUseCase
    implements UseCase<List<Product>, String> {
  final ProductRepository repository;

  GetProductsByCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<Product>>> call(
    String params, {
    String? shopId,
  }) {
    return repository.getProductsByCategory(params, shopId: shopId);
  }
}

class GetCurrentStockBulkUseCase
    implements UseCase<Map<String, int>, List<String>> {
  final ProductRepository repository;

  GetCurrentStockBulkUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, int>>> call(
    List<String> params, {
    String? shopId,
  }) {
    return repository.getCurrentStockBulk(params, shopId: shopId);
  }
}
