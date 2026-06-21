import 'package:posta_pra_mim/domain/entities/user.dart';
import 'package:posta_pra_mim/domain/repositories/auth_repository.dart';

/// Use cases de autenticação. Cada classe tem responsabilidade única
/// e recebe o repositório via injeção de dependência — nunca o
/// constrói internamente.

final class LoginUseCase {
  const LoginUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<User> call({required String email, required String password}) {
    return _authRepository.login(email: email, password: password);
  }
}

/// Verifica sessão ativa ao abrir o app (usado pela splash).
final class GetCurrentUserUseCase {
  const GetCurrentUserUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<User?> call() => _authRepository.currentUser();
}

/// Cria conta com e-mail/senha.
final class RegisterUseCase {
  const RegisterUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<User> call({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) {
    return _authRepository.registerWithEmail(
      name: name,
      email: email,
      phone: phone,
      password: password,
    );
  }
}

/// Login social via Google.
final class SignInWithGoogleUseCase {
  const SignInWithGoogleUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<User> call() => _authRepository.signInWithGoogle();
}
