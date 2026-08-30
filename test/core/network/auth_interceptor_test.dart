import 'dart:typed_data';

import 'package:api/core/auth/auth_session_manager.dart';
import 'package:api/core/network/auth_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthSessionManager extends Mock implements AuthSessionManager {}

class FakeRequestOptions extends Fake implements RequestOptions {}

void main() {
  late MockAuthSessionManager sessionManager;
  late Dio dio;
  late AuthInterceptor interceptor;

  setUpAll(() {
    registerFallbackValue(FakeRequestOptions());
  });

  setUp(() {
    sessionManager = MockAuthSessionManager();

    dio = Dio(BaseOptions(baseUrl: 'https://test.example.com'));

    interceptor = AuthInterceptor(sessionManager);

    interceptor.setDio(dio);

    dio.interceptors.add(interceptor);
  });

  test('ajoute le token dans Authorization', () async {
    when(() => sessionManager.accessToken).thenReturn('access-token');

    dio.httpClientAdapter = _FakeAdapter((options) {
      expect(options.headers['Authorization'], 'Bearer access-token');

      return ResponseBody.fromString(
        '{"success":true}',
        200,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      );
    });

    final response = await dio.get('/test');

    expect(response.statusCode, 200);

    verify(() => sessionManager.accessToken).called(1);
  });

  test('refresh le token après un 401 puis rejoue la requête', () async {
    var requestCount = 0;

    when(() => sessionManager.accessToken).thenReturn('old-token');

    when(
      () => sessionManager.refreshAccessToken(),
    ).thenAnswer((_) async => 'new-token');

    dio.httpClientAdapter = _FakeAdapter((options) {
      requestCount++;

      if (requestCount == 1) {
        return ResponseBody.fromString(
          '{"error":"unauthorized"}',
          401,
          headers: {
            Headers.contentTypeHeader: ['application/json'],
          },
        );
      }

      expect(options.headers['Authorization'], 'Bearer new-token');

      return ResponseBody.fromString(
        '{"success":true}',
        200,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      );
    });

    final response = await dio.get('/test');

    expect(response.statusCode, 200);
    expect(requestCount, 2);

    verify(() => sessionManager.refreshAccessToken()).called(1);
  });

  test('ne boucle pas si le retry retourne encore 401', () async {
    var requestCount = 0;

    when(() => sessionManager.accessToken).thenReturn('old-token');

    when(
      () => sessionManager.refreshAccessToken(),
    ).thenAnswer((_) async => 'new-token');

    dio.httpClientAdapter = _FakeAdapter((options) {
      requestCount++;

      return ResponseBody.fromString(
        '{"error":"unauthorized"}',
        401,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      );
    });

    await expectLater(dio.get('/test'), throwsA(isA<DioException>()));

    expect(requestCount, 2);

    verify(() => sessionManager.refreshAccessToken()).called(1);
  });
}

class _FakeAdapter implements HttpClientAdapter {
  final ResponseBody Function(RequestOptions options) handler;

  _FakeAdapter(this.handler);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}
