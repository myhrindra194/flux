import 'package:api/core/errors/result.dart';

import '../entities/product_entity.dart';

abstract class ProductRepository {
  Future<Result<List<ProductEntity>>> getProducts();

  Future<Result<ProductEntity>> getProductById(int id);

  Future<Result<List<ProductEntity>>> searchProducts(String query);
}
