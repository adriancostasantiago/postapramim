import 'package:posta_pra_mim/domain/entities/user.dart';
import 'package:posta_pra_mim/domain/repositories/auth_repository.dart';

/// Use case com responsabilidade única. Recebe o repositório por
/// injeção de dependência — nunca o constrói internamente.
final class LoginUseCase {
  const LoginUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<User> call({required String email, required String password}) {
    return _authRepository.login(email: email, password: password);
  }
}

/// Use case para verificar sessão ativa ao abrir o app (usado pela splash).
final class GetCurrentUserUseCase {
  const GetCurrentUserUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<User?> call() => _authRepository.currentUser();
}
