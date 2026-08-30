import 'package:dio/dio.dart';

class ProductRemoteDataSource {
  final Dio _dio;

  ProductRemoteDataSource(this._dio);

  Future<List<Map<String, dynamic>>> getProducts() async {
    final response = await _dio.get('/products');

    final products = response.data['products'] as List;

    return products.map((product) => product as Map<String, dynamic>).toList();
  }

  Future<Map<String, dynamic>> getProductById(int id) async {
    final response = await _dio.get('/products/$id');

    return response.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    final response = await _dio.get(
      '/products/search',
      queryParameters: {'q': query},
    );

    final products = response.data['products'] as List;

    return products.map((product) => product as Map<String, dynamic>).toList();
  }
}
