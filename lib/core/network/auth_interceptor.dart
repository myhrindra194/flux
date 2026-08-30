import 'package:dio/dio.dart';

import '../auth/auth_session_manager.dart';

class AuthInterceptor extends Interceptor {
  final AuthSessionManager _sessionManager;

  late Dio _dio;

  AuthInterceptor(this._sessionManager);

  void setDio(Dio dio) {
    _dio = dio;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Si la requête est déjà un retry,
    // on conserve le token qui a été ajouté par le refresh.
    if (options.extra['retried'] == true) {
      handler.next(options);
      return;
    }

    final token = _sessionManager.accessToken;

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // On traite uniquement les erreurs 401.
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    // La requête a déjà été rejouée.
    // On ne fait surtout pas un deuxième refresh.
    if (err.requestOptions.extra['retried'] == true) {
      handler.next(err);
      return;
    }

    try {
      // Demande un nouveau token.
      final newToken = await _sessionManager.refreshAccessToken();

      // Aucun nouveau token disponible.
      if (newToken == null) {
        handler.next(err);
        return;
      }

      final requestOptions = err.requestOptions;

      // Marque la requête comme déjà retentée.
      requestOptions.extra['retried'] = true;

      // Utilise le nouveau token.
      requestOptions.headers['Authorization'] = 'Bearer $newToken';

      // Rejoue la requête avec le même Dio.
      final response = await _dio.fetch(requestOptions);

      // Si le retry retourne encore 401,
      // on laisse l'erreur remonter.
      if (response.statusCode == 401) {
        handler.next(
          DioException(
            requestOptions: requestOptions,
            response: response,
            type: DioExceptionType.badResponse,
          ),
        );
        return;
      }

      // Le retry a réussi.
      handler.resolve(response);
    } on DioException catch (retryError) {
      // Le retry a échoué.
      // Pas de nouveau refresh.
      handler.next(retryError);
    } catch (_) {
      // Le refresh a échoué.
      handler.next(err);
    }
  }
}
