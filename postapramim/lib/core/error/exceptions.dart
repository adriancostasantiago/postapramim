/// Exceptions lançadas na camada de dados (datasources) e capturadas
/// nos Repositories, que as convertem em Failure via Result Pattern.
class ServerException implements Exception {
  final String message;
  final String? code;
  const ServerException(this.message, {this.code});
}

class AuthException implements Exception {
  final String message;
  final String? code;
  const AuthException(this.message, {this.code});
}

class CacheException implements Exception {
  final String message;
  const CacheException(this.message);
}

class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);
}

class ValidationException implements Exception {
  final String message;
  const ValidationException(this.message);
}
