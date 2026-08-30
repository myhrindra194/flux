import 'package:api/core/errors/exceptions.dart';
import 'package:dio/dio.dart';

class ProductRemoteDataSource {
  final Dio _dio;

  ProductRemoteDataSource(this._dio);

  Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      final response = await _dio.get('/products');

      final products = response.data['products'] as List;

      return products
          .map((product) => Map<String, dynamic>.from(product))
          .toList();
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('Format de réponse invalide.');
    }
  }

  Future<Map<String, dynamic>> getProductById(int id) async {
    try {
      final response = await _dio.get('/products/$id');

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('Format de réponse invalide.');
    }
  }

  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    try {
      final response = await _dio.get(
        '/products/search',
        queryParameters: {'q': query},
      );

      final products = response.data['products'] as List;

      return products
          .map((product) => Map<String, dynamic>.from(product))
          .toList();
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('Format de réponse invalide.');
    }
  }

  Exception _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return NetworkException();

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;

        if (statusCode != null && statusCode >= 500) {
          return ServerException();
        }

        return ServerException('La requête a échoué.');

      default:
        return NetworkException();
    }
  }
}
