import 'package:api/core/errors/exceptions.dart';
import 'package:api/core/errors/failures.dart';
import 'package:api/core/errors/result.dart';

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
  Future<Result<List<ProductEntity>>> getProducts() async {
    try {
      final products = await _remoteDataSource.getProducts();

      final models = products.map(ProductModel.fromJson).toList();

      try {
        await _localDataSource.cacheProducts(models);
      } on CacheException {
        // Le cache ne doit pas bloquer l'API.
      }

      return Success(models);
    } on NetworkException {
      return _getCachedProducts();
    } on ServerException {
      return _getCachedProducts();
    } on CacheException {
      return const Error(CacheFailure('Impossible de récupérer les produits.'));
    } catch (_) {
      return const Error(UnknownFailure());
    }
  }

  @override
  Future<Result<ProductEntity>> getProductById(int id) async {
    try {
      final product = await _remoteDataSource.getProductById(id);

      final model = ProductModel.fromJson(product);

      try {
        await _localDataSource.cacheProduct(model);
      } on CacheException {
        // On ignore l'erreur du cache.
      }

      return Success(model);
    } on NetworkException {
      return _getCachedProduct(id);
    } on ServerException {
      return _getCachedProduct(id);
    } on CacheException {
      return const Error(CacheFailure('Impossible de récupérer ce produit.'));
    } catch (_) {
      return const Error(UnknownFailure());
    }
  }

  @override
  Future<Result<List<ProductEntity>>> searchProducts(String query) async {
    try {
      final products = await _remoteDataSource.searchProducts(query);

      final models = products.map(ProductModel.fromJson).toList();

      return Success(models);
    } on NetworkException {
      return const Error(
        NetworkFailure('Impossible de rechercher les produits sans connexion.'),
      );
    } on ServerException {
      return const Error(
        ServerFailure('Le serveur est temporairement indisponible.'),
      );
    } catch (_) {
      return const Error(UnknownFailure());
    }
  }

  Future<Result<List<ProductEntity>>> _getCachedProducts() async {
    try {
      final cachedProducts = _localDataSource.getCachedProducts();

      if (cachedProducts.isNotEmpty) {
        return Success(cachedProducts, isFromCache: true);
      }

      return const Error(CacheFailure('Aucun produit disponible hors ligne.'));
    } on CacheException {
      return const Error(
        CacheFailure('Impossible de récupérer les produits hors ligne.'),
      );
    }
  }

  Future<Result<ProductEntity>> _getCachedProduct(int id) async {
    try {
      final cachedProduct = _localDataSource.getCachedProduct(id);

      if (cachedProduct != null) {
        return Success(cachedProduct, isFromCache: true);
      }

      return const Error(
        CacheFailure('Ce produit n’est pas disponible hors ligne.'),
      );
    } on CacheException {
      return const Error(
        CacheFailure('Impossible de récupérer ce produit hors ligne.'),
      );
    }
  }
}
