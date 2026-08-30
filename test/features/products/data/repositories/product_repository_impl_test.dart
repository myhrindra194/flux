import 'package:api/core/errors/exceptions.dart';
import 'package:api/core/errors/failures.dart';
import 'package:api/core/errors/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:api/features/products/data/datasources/product_local_datasource.dart';
import 'package:api/features/products/data/datasources/product_remote_datasource.dart';
import 'package:api/features/products/data/models/product_model.dart';
import 'package:api/features/products/data/repositories/product_repository_impl.dart';

class MockProductRemoteDataSource extends Mock
    implements ProductRemoteDataSource {}

class MockProductLocalDataSource extends Mock
    implements ProductLocalDataSource {}

void main() {
  late MockProductRemoteDataSource remoteDataSource;
  late MockProductLocalDataSource localDataSource;
  late ProductRepositoryImpl repository;

  setUp(() {
    remoteDataSource = MockProductRemoteDataSource();
    localDataSource = MockProductLocalDataSource();

    repository = ProductRepositoryImpl(remoteDataSource, localDataSource);
  });

  group('getProducts', () {
    test('should return products from API and save them to cache', () async {
      final apiProducts = [
        {
          'id': 1,
          'title': 'iPhone',
          'description': 'Smartphone',
          'price': 999.99,
          'rating': 4.5,
          'thumbnail': 'image.jpg',
          'category': 'smartphones',
        },
      ];

      when(
        () => remoteDataSource.getProducts(),
      ).thenAnswer((_) async => apiProducts);

      when(() => localDataSource.cacheProducts(any())).thenAnswer((_) async {});

      final result = await repository.getProducts();

      expect(result, isA<Success>());

      final success = result as Success;

      expect(success.data.length, 1);
      expect(success.isFromCache, false);

      verify(() => remoteDataSource.getProducts()).called(1);

      verify(() => localDataSource.cacheProducts(any())).called(1);
    });

    test('should return cached products when API fails', () async {
      final cachedProduct = ProductModel(
        id: 1,
        title: 'iPhone',
        description: 'Smartphone',
        price: 999.99,
        rating: 4.5,
        thumbnail: 'image.jpg',
        category: 'smartphones',
      );

      when(() => remoteDataSource.getProducts()).thenThrow(NetworkException());

      when(
        () => localDataSource.getCachedProducts(),
      ).thenReturn([cachedProduct]);

      final result = await repository.getProducts();

      expect(result, isA<Success>());

      final success = result as Success;

      expect(success.data.length, 1);
      expect(success.isFromCache, true);

      verify(() => remoteDataSource.getProducts()).called(1);

      verify(() => localDataSource.getCachedProducts()).called(1);
    });

    test(
      'should return CacheFailure when API fails and cache is empty',
      () async {
        when(
          () => remoteDataSource.getProducts(),
        ).thenThrow(NetworkException());

        when(() => localDataSource.getCachedProducts()).thenReturn([]);

        final result = await repository.getProducts();

        expect(result, isA<Error>());

        final error = result as Error;

        expect(error.failure, isA<CacheFailure>());
      },
    );
  });
}
