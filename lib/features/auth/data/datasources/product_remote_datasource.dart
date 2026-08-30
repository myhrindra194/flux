import 'package:dio/dio.dart';

class ProductRemoteDataSource {
  final Dio _dio;

  ProductRemoteDataSource(this._dio);

  Future<List<dynamic>> getProducts() async {
    final response = await _dio.get('/products');

    return response.data['products'] as List<dynamic>;
  }
}
