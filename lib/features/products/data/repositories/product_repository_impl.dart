import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remoteDataSource;

  ProductRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<ProductEntity>> getProducts() async {
    final products = await _remoteDataSource.getProducts();

    return products.map(ProductModel.fromJson).toList();
  }

  @override
  Future<ProductEntity> getProductById(int id) async {
    final product = await _remoteDataSource.getProductById(id);

    return ProductModel.fromJson(product);
  }

  @override
  Future<List<ProductEntity>> searchProducts(String query) async {
    final products = await _remoteDataSource.searchProducts(query);

    return products.map(ProductModel.fromJson).toList();
  }
}
