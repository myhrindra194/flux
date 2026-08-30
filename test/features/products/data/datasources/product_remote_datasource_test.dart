import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:api/features/products/data/datasources/product_remote_datasource.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late ProductRemoteDataSource dataSource;

  setUp(() {
    dio = MockDio();
    dataSource = ProductRemoteDataSource(dio);
  });

  group('getProducts', () {
    test('should return products from API', () async {
      when(() => dio.get('/products')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/products'),
          data: {
            'products': [
              {
                'id': 1,
                'title': 'iPhone',
                'description': 'Smartphone',
                'price': 999.99,
                'rating': 4.5,
                'thumbnail': 'image.jpg',
                'category': 'smartphones',
              },
            ],
          },
          statusCode: 200,
        ),
      );

      final result = await dataSource.getProducts();

      expect(result.length, 1);
      expect(result.first['id'], 1);
      expect(result.first['title'], 'iPhone');

      verify(() => dio.get('/products')).called(1);
    });
  });

  group('getProductById', () {
    test('should return a product from API', () async {
      when(() => dio.get('/products/1')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/products/1'),
          data: {
            'id': 1,
            'title': 'iPhone',
            'description': 'Smartphone',
            'price': 999.99,
            'rating': 4.5,
            'thumbnail': 'image.jpg',
            'category': 'smartphones',
          },
          statusCode: 200,
        ),
      );

      final result = await dataSource.getProductById(1);

      expect(result['id'], 1);
      expect(result['title'], 'iPhone');

      verify(() => dio.get('/products/1')).called(1);
    });
  });

  group('searchProducts', () {
    test('should return search results from API', () async {
      when(
        () => dio.get('/products/search', queryParameters: {'q': 'phone'}),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/products/search'),
          data: {
            'products': [
              {
                'id': 1,
                'title': 'iPhone',
                'description': 'Smartphone',
                'price': 999.99,
                'rating': 4.5,
                'thumbnail': 'image.jpg',
                'category': 'smartphones',
              },
            ],
          },
          statusCode: 200,
        ),
      );

      final result = await dataSource.searchProducts('phone');

      expect(result.length, 1);
      expect(result.first['title'], 'iPhone');

      verify(
        () => dio.get('/products/search', queryParameters: {'q': 'phone'}),
      ).called(1);
    });
  });
}
