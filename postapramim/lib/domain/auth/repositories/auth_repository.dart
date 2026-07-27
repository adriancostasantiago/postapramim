import 'package:postapramim/core/error/result.dart';
import 'package:postapramim/domain/auth/entities/user_entity.dart';

/// Contrato do domínio. A UI e os UseCases dependem SOMENTE desta abstração,
/// nunca da implementação concreta nem do Supabase diretamente.
abstract interface class AuthRepository {
  Future<Result<UserEntity>> login({
    required String email,
    required String senha,
  });

  Future<Result<UserEntity>> cadastrar({
    required String nome,
    required String email,
    required String senha,
    required String perfil,
    required String cpf,
    required String celular,
  });

  Future<Result<void>> loginComGoogle();
  Future<Result<void>> loginComApple();
  Future<Result<void>> enviarMagicLink(String email);
  Future<Result<void>> recuperarSenha(String email);
  Future<Result<void>> logout();
  Future<Result<UserEntity?>> usuarioAtual();
  Stream<UserEntity?> get authStateChanges;
}
