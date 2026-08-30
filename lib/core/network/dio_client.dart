import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_interceptor.dart';

class DioClient {
  static const String baseUrl = 'https://dummyjson.com';

  late final Dio dio;

  DioClient() {
    final supabase = Supabase.instance.client;

    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(AuthInterceptor(supabase));
  }
}
