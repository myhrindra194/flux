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
  final dataSource = ref.watch(productRemoteDataSourceProvider);

  return ProductRepositoryImpl(dataSource);
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
