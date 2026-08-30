import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_datasource.dart';
import '../datasources/product_remote_datasource.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remoteDataSource;
  final ProductLocalDataSource _localDataSource;

  ProductRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<List<ProductEntity>> getProducts() async {
    try {
      final products = await _remoteDataSource.getProducts();

      final models = products.map(ProductModel.fromJson).toList();

      await _localDataSource.cacheProducts(models);

      return models;
    } catch (e) {
      final cachedProducts = _localDataSource.getCachedProducts();

      if (cachedProducts.isNotEmpty) {
        return cachedProducts;
      }

      rethrow;
    }
  }

  @override
  Future<ProductEntity> getProductById(int id) async {
    try {
      final product = await _remoteDataSource.getProductById(id);

      final model = ProductModel.fromJson(product);

      await _localDataSource.cacheProduct(model);

      return model;
    } catch (e) {
      final cachedProduct = _localDataSource.getCachedProduct(id);

      if (cachedProduct != null) {
        return cachedProduct;
      }

      rethrow;
    }
  }

  @override
  Future<List<ProductEntity>> searchProducts(String query) async {
    try {
      final products = await _remoteDataSource.searchProducts(query);

      return products.map(ProductModel.fromJson).toList();
    } catch (e) {
      rethrow;
    }
  }
}
