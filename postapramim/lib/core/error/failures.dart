abstract class Failure {
  final String message;
  final String? code;
  const Failure(this.message, {this.code});

  @override
  String toString() => 'Failure(code: $code, message: $message)';
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});
}

class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code});
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code});
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code});
}

class PermissionFailure extends Failure {
  const PermissionFailure(super.message, {super.code});
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message, {super.code});
}
