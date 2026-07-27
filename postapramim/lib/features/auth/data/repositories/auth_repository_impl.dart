import 'package:postapramim/core/error/exceptions.dart';
import 'package:postapramim/core/error/failures.dart';
import 'package:postapramim/core/error/result.dart';
import 'package:postapramim/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:postapramim/features/auth/domain/entities/user_entity.dart';
import 'package:postapramim/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remote;
  AuthRepositoryImpl(this._remote);

  @override
  Future<Result<UserEntity>> login({
    required String email,
    required String senha,
  }) async {
    try {
      final model = await _remote.login(email: email, senha: senha);
      return Result.success(model.toEntity());
    } on AuthException catch (e) {
      return Result.failure(AuthFailure(e.message, code: e.code));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<UserEntity>> cadastrar({
    required String nome,
    required String email,
    required String senha,
    required String perfil,
    required String cpf,
    required String celular,
  }) async {
    try {
      final model = await _remote.cadastrar(
        nome: nome,
        email: email,
        senha: senha,
        perfil: perfil,
        cpf: cpf,
        celular: celular,
      );
      return Result.success(model.toEntity());
    } on AuthException catch (e) {
      return Result.failure(AuthFailure(e.message, code: e.code));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> loginComGoogle() async {
    try {
      await _remote.loginComGoogle();
      return const Result.success(null);
    } catch (e) {
      return Result.failure(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> loginComApple() async {
    try {
      await _remote.loginComApple();
      return const Result.success(null);
    } catch (e) {
      return Result.failure(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> enviarMagicLink(String email) async {
    try {
      await _remote.enviarMagicLink(email);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> recuperarSenha(String email) async {
    try {
      await _remote.recuperarSenha(email);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _remote.logout();
      return const Result.success(null);
    } catch (e) {
      return Result.failure(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Result<UserEntity?>> usuarioAtual() async {
    try {
      final model = await _remote.usuarioAtual();
      return Result.success(model?.toEntity());
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges =>
      _remote.authStateChanges.asyncMap((_) async {
        final result = await usuarioAtual();
        return result.fold(onSuccess: (u) => u, onFailure: (_) => null);
      });
}
