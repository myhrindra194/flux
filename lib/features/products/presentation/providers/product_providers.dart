import 'package:api/features/products/data/datasources/product_local_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/network/dio_provider.dart';
import '../../data/datasources/product_remote_datasource.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';

final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource>((
  ref,
) {
  final dio = ref.watch(dioProvider);

  return ProductRemoteDataSource(dio);
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final remoteDataSource = ref.watch(productRemoteDataSourceProvider);

  final localDataSource = ProductLocalDataSource();

  return ProductRepositoryImpl(remoteDataSource, localDataSource);
});

final productsProvider = FutureProvider<List<ProductEntity>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);

  return repository.getProducts();
});
final productSearchQueryProvider = StateProvider<String>((ref) => '');
final productSearchProvider = FutureProvider<List<ProductEntity>>((ref) async {
  final query = ref.watch(productSearchQueryProvider);

  if (query.isEmpty) {
    return [];
  }

  final repository = ref.watch(productRepositoryProvider);

  return repository.searchProducts(query);
});

final productDetailProvider = FutureProvider.family<ProductEntity, int>((
  ref,
  id,
) async {
  final repository = ref.watch(productRepositoryProvider);

  return repository.getProductById(id);
});
