import 'package:posta_pra_mim/core/errors/failure.dart';
import 'package:posta_pra_mim/domain/entities/user.dart';

/// Result simples sem libs externas: usa Dart 3 sealed class via Failure
/// ou sucesso explícito. Repositórios e use cases lançam [Failure]
/// tipado — nunca exceções cruas de http/parsing.
abstract interface class AuthRepository {
  Future<User> login({required String email, required String password});

  /// Cria uma nova conta e já autentica o usuário.
  Future<User> registerWithEmail({
    required String name,
    required String email,
    required String phone,
    required String password,
  });

  /// Autentica via Google OAuth. A implementação concreta delega o
  /// fluxo nativo (account picker) a um [GoogleAuthDataSource] — ver
  /// `data/datasources/google_auth_datasource.dart`.
  Future<User> signInWithGoogle();

  Future<void> logout();

  /// Retorna `null` se não houver sessão ativa.
  Future<User?> currentUser();
}

/// Exceção interna de domínio — convertida em [Failure] pela camada
/// de apresentação ou pelo repositório antes de chegar à UI.
final class AuthException implements Exception {
  const AuthException(this.failure);

  final Failure failure;
}
