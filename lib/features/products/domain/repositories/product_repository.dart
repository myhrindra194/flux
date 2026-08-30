import '../entities/product_entity.dart';

abstract class ProductRepository {
  Future<List<ProductEntity>> getProducts();

  Future<ProductEntity> getProductById(int id);

  Future<List<ProductEntity>> searchProducts(String query);
}
