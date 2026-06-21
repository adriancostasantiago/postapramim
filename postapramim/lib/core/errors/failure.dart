import 'package:equatable/equatable.dart';

/// Falhas tipadas que cruzam a fronteira domain → presentation.
///
/// Exceções de rede/parsing nunca devem alcançar a UI diretamente;
/// repositórios as capturam e convertem em [Failure] com mensagem
/// amigável e localizável.
sealed class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Sem conexão com a internet.']);
}

final class ServerFailure extends Failure {
  const ServerFailure([
    super.message = 'Não foi possível completar a solicitação. Tente novamente.',
  ]);
}

final class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Sessão expirada. Faça login novamente.']);
}

final class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Algo deu errado. Tente novamente.']);
}
