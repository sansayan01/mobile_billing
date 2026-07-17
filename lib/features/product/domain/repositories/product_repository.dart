import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/product.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getProducts({String? shopId});
  Future<Either<Failure, Product>> getProductByBarcode(
    String barcode, {
    String? shopId,
  });
  Future<Either<Failure, List<Product>>> getProductsByCategory(
    String categoryId, {
    String? shopId,
  });
  Future<Either<Failure, void>> addProduct(
    Product product, {
    String? shopId,
  });
  Future<Either<Failure, void>> updateProduct(
    Product product, {
    String? shopId,
  });
  Future<Either<Failure, void>> deleteProduct(
    String id, {
    String? shopId,
  });
  Future<Either<Failure, Map<String, int>>> getCurrentStockBulk(
    List<String> productIds, {
    String? shopId,
  });
}
