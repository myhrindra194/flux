abstract class Failure implements Exception {
  final String message;

  const Failure(this.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Vérifiez votre connexion Internet.']);
}

class ServerFailure extends Failure {
  const ServerFailure([
    super.message = 'Le serveur est temporairement indisponible.',
  ]);
}

class CacheFailure extends Failure {
  const CacheFailure([
    super.message = 'Les données locales sont indisponibles.',
  ]);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Une erreur inattendue est survenue.']);
}
