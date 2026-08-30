abstract class AppException implements Exception {
  final String message;

  const AppException(this.message);
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Erreur de connexion réseau.']);
}

class ServerException extends AppException {
  const ServerException([super.message = 'Erreur du serveur.']);
}

class CacheException extends AppException {
  const CacheException([super.message = 'Erreur du cache local.']);
}
