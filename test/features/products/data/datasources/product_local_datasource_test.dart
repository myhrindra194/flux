import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:api/core/storage/hive_boxes.dart';
import 'package:api/features/products/data/datasources/product_local_datasource.dart';
import 'package:api/features/products/data/models/product_model.dart';
import 'package:hive_test/hive_test.dart';

void main() {
  late ProductLocalDataSource dataSource;

  setUp(() async {
    await setUpTestHive();

    await Hive.openBox(HiveBoxes.products);

    dataSource = ProductLocalDataSource();
  });

  tearDown(() async {
    await tearDownTestHive();
  });

  final product = ProductModel(
    id: 1,
    title: 'iPhone',
    description: 'Smartphone',
    price: 999.99,
    rating: 4.5,
    thumbnail: 'image.jpg',
    category: 'smartphones',
  );

  group('cacheProducts', () {
    test('should cache and retrieve products', () async {
      await dataSource.cacheProducts([product]);

      final result = dataSource.getCachedProducts();

      expect(result.length, 1);
      expect(result.first.id, 1);
      expect(result.first.title, 'iPhone');
    });
  });

  group('cacheProduct', () {
    test('should cache and retrieve a product', () async {
      await dataSource.cacheProduct(product);

      final result = dataSource.getCachedProduct(1);

      expect(result, isNotNull);
      expect(result!.id, 1);
      expect(result.title, 'iPhone');
    });
  });

  group('getCachedProduct', () {
    test('should return null when product does not exist', () {
      final result = dataSource.getCachedProduct(999);

      expect(result, isNull);
    });
  });
}
