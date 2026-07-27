import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:postapramim/core/services/supabase_service.dart';
import 'package:postapramim/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:postapramim/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:postapramim/features/auth/domain/repositories/auth_repository.dart';
import 'package:postapramim/features/auth/domain/usecases/login_usecase.dart';
import 'package:postapramim/features/auth/domain/usecases/register_usecase.dart';
import 'package:postapramim/features/auth/domain/usecases/logout_usecase.dart';
import 'package:postapramim/features/auth/domain/usecases/recover_password_usecase.dart';
import 'package:postapramim/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:postapramim/features/auth/presentation/controllers/auth_controller.dart';

part 'auth_providers.g.dart';

// ---------------------------------------------------------------------------
// Injeção de dependência: Datasource -> Repository -> UseCases
// Cada camada só conhece a camada imediatamente abaixo, via abstração.
// ---------------------------------------------------------------------------

@riverpod
AuthRemoteDatasource authRemoteDatasource(Ref ref) {
  return AuthRemoteDatasourceImpl(SupabaseService.client);
}

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDatasourceProvider));
}

@riverpod
LoginUsecase loginUsecase(Ref ref) =>
    LoginUsecase(ref.watch(authRepositoryProvider));

@riverpod
RegisterUsecase registerUsecase(Ref ref) =>
    RegisterUsecase(ref.watch(authRepositoryProvider));

@riverpod
LogoutUsecase logoutUsecase(Ref ref) =>
    LogoutUsecase(ref.watch(authRepositoryProvider));

@riverpod
RecoverPasswordUsecase recoverPasswordUsecase(Ref ref) =>
    RecoverPasswordUsecase(ref.watch(authRepositoryProvider));

@riverpod
GetCurrentUserUsecase getCurrentUserUsecase(Ref ref) =>
    GetCurrentUserUsecase(ref.watch(authRepositoryProvider));

/// Stream bruta de eventos de auth do Supabase — usada pelo GoRouter
/// (`refreshListenable`) para reagir a login/logout automaticamente.
@riverpod
Stream<AuthState> authStateChanges(Ref ref) {
  return SupabaseService.auth.onAuthStateChange.asyncMap((_) async {
    final result = await ref.read(getCurrentUserUsecaseProvider)();
    return result.fold(
      onSuccess: (u) => AuthState(usuario: u),
      onFailure: (_) => AuthState.inicial,
    );
  });
}

// ---------------------------------------------------------------------------
// Controller principal consumido pela UI
// ---------------------------------------------------------------------------

@riverpod
class AuthControllerNotifier extends _$AuthControllerNotifier {
  @override
  AuthState build() {
    _carregarUsuarioAtual();
    return AuthState.inicial;
  }

  Future<void> _carregarUsuarioAtual() async {
    final result = await ref.read(getCurrentUserUsecaseProvider)();
    result.fold(
      onSuccess: (u) => state = state.copyWith(usuario: u, limparErro: true),
      onFailure: (f) => state = state.copyWith(erro: f.message),
    );
  }

  Future<void> login({required String email, required String senha}) async {
    state = state.copyWith(carregando: true, limparErro: true);
    final result = await ref.read(loginUsecaseProvider)(
      email: email,
      senha: senha,
    );
    result.fold(
      onSuccess: (u) => state = state.copyWith(
        usuario: u,
        carregando: false,
        limparErro: true,
      ),
      onFailure: (f) =>
          state = state.copyWith(carregando: false, erro: f.message),
    );
  }

  Future<void> cadastrar({
    required String nome,
    required String email,
    required String senha,
    required String perfil,
    required String cpf,
    required String celular,
  }) async {
    state = state.copyWith(carregando: true, limparErro: true);
    final result = await ref.read(registerUsecaseProvider)(
      nome: nome,
      email: email,
      senha: senha,
      perfil: perfil,
      cpf: cpf,
      celular: celular,
    );
    result.fold(
      onSuccess: (u) => state = state.copyWith(
        usuario: u,
        carregando: false,
        limparErro: true,
      ),
      onFailure: (f) =>
          state = state.copyWith(carregando: false, erro: f.message),
    );
  }

  Future<void> recuperarSenha(String email) async {
    state = state.copyWith(carregando: true, limparErro: true);
    final result = await ref.read(recoverPasswordUsecaseProvider)(email);
    result.fold(
      onSuccess: (_) => state = state.copyWith(carregando: false),
      onFailure: (f) =>
          state = state.copyWith(carregando: false, erro: f.message),
    );
  }

  Future<void> loginComGoogle() async {
    state = state.copyWith(carregando: true, limparErro: true);
    final result = await ref.read(authRepositoryProvider).loginComGoogle();
    result.fold(
      onSuccess: (_) => state = state.copyWith(carregando: false),
      onFailure: (f) =>
          state = state.copyWith(carregando: false, erro: f.message),
    );
  }

  Future<void> logout() async {
    await ref.read(logoutUsecaseProvider)();
    state = AuthState.inicial;
  }
}
