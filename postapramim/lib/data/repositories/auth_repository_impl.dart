import 'package:posta_pra_mim/core/errors/failure.dart';
import 'package:posta_pra_mim/core/utils/app_logger.dart';
import 'package:posta_pra_mim/data/datasources/auth_local_datasource.dart';
import 'package:posta_pra_mim/data/datasources/auth_remote_datasource.dart';
import 'package:posta_pra_mim/data/datasources/google_auth_datasource.dart';
import 'package:posta_pra_mim/domain/entities/user.dart';
import 'package:posta_pra_mim/domain/repositories/auth_repository.dart';

final class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
    required GoogleAuthDataSource googleAuthDataSource,
  })  : _remote = remoteDataSource,
        _local = localDataSource,
        _google = googleAuthDataSource;

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;
  final GoogleAuthDataSource _google;
  static final _log = AppLogger.of('AuthRepositoryImpl');

  @override
  Future<User> login({required String email, required String password}) async {
    try {
      final userModel = await _remote.login(email: email, password: password);
      await _local.saveUser(userModel);
      return userModel.toEntity();
    } on Failure catch (failure, stackTrace) {
      _log.warning('Login falhou', failure, stackTrace);
      rethrow;
    }
  }

  @override
  Future<User> registerWithEmail({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final userModel = await _remote.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );
      await _local.saveUser(userModel);
      return userModel.toEntity();
    } on Failure catch (failure, stackTrace) {
      _log.warning('Cadastro falhou', failure, stackTrace);
      rethrow;
    }
  }

  @override
  Future<User> signInWithGoogle() async {
    try {
      final userModel = await _google.signIn();
      await _local.saveUser(userModel);
      return userModel.toEntity();
    } on Failure catch (failure, stackTrace) {
      _log.warning('Login com Google falhou', failure, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _remote.logout();
    } on Failure catch (failure, stackTrace) {
      // Falha de rede no logout não deve travar o usuário localmente.
      _log.warning('Logout remoto falhou, limpando sessão local', failure, stackTrace);
    } finally {
      await _local.clear();
    }
  }

  @override
  Future<User?> currentUser() async {
    final userModel = await _local.getUser();
    return userModel?.toEntity();
  }
}
