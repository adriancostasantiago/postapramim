import 'package:flutter/foundation.dart';
import 'package:posta_pra_mim/core/errors/failure.dart';
import 'package:posta_pra_mim/core/utils/app_logger.dart';
import 'package:posta_pra_mim/domain/repositories/auth_repository.dart';
import 'package:posta_pra_mim/domain/usecases/auth_usecases.dart';
import 'package:posta_pra_mim/presentation/shared/state/auth_state.dart';

/// Controller de autenticação (padrão Provider/ChangeNotifier).
///
/// Lógica de negócio vive aqui, fora da árvore de widgets. Recebe
/// use cases via construtor — nunca os instancia internamente.
final class AuthController extends ChangeNotifier {
  AuthController({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required SignInWithGoogleUseCase signInWithGoogleUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required AuthRepository authRepository,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _signInWithGoogleUseCase = signInWithGoogleUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _authRepository = authRepository;

  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final SignInWithGoogleUseCase _signInWithGoogleUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final AuthRepository _authRepository;
  static final _log = AppLogger.of('AuthController');

  AuthState _state = const AuthInitial();
  AuthState get state => _state;

  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Verifica sessão ativa — chamado pela splash ao iniciar o app.
  Future<void> checkSession() async {
    _setState(const AuthLoading());
    try {
      final user = await _getCurrentUserUseCase();
      _setState(user != null ? AuthAuthenticated(user) : const AuthUnauthenticated());
    } on Failure catch (failure) {
      _setState(AuthError(failure));
    } on Exception catch (error, stackTrace) {
      _log.severe('Erro inesperado ao checar sessão', error, stackTrace);
      _setState(const AuthError(UnknownFailure()));
    }
  }

  Future<void> login({required String email, required String password}) async {
    _setState(const AuthLoading());
    try {
      final user = await _loginUseCase(email: email, password: password);
      _setState(AuthAuthenticated(user));
    } on Failure catch (failure) {
      _setState(AuthError(failure));
    } on Exception catch (error, stackTrace) {
      _log.severe('Erro inesperado no login', error, stackTrace);
      _setState(const AuthError(UnknownFailure()));
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _setState(const AuthLoading());
    try {
      final user = await _registerUseCase(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );
      _setState(AuthAuthenticated(user));
    } on Failure catch (failure) {
      _setState(AuthError(failure));
    } on Exception catch (error, stackTrace) {
      _log.severe('Erro inesperado no cadastro', error, stackTrace);
      _setState(const AuthError(UnknownFailure()));
    }
  }

  Future<void> signInWithGoogle() async {
    _setState(const AuthLoading());
    try {
      final user = await _signInWithGoogleUseCase();
      _setState(AuthAuthenticated(user));
    } on Failure catch (failure) {
      _setState(AuthError(failure));
    } on Exception catch (error, stackTrace) {
      _log.severe('Erro inesperado no login com Google', error, stackTrace);
      _setState(const AuthError(UnknownFailure()));
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    _setState(const AuthUnauthenticated());
  }
}
