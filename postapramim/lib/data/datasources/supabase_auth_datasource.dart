import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:supabase_flutter/supabase_flutter.dart' as supa
    show AuthException;
import 'package:posta_pra_mim/core/errors/failure.dart';
import 'package:posta_pra_mim/data/datasources/auth_remote_datasource.dart';
import 'package:posta_pra_mim/data/models/user_model.dart';
import 'package:posta_pra_mim/domain/entities/user_role.dart';

/// Implementação de [AuthRemoteDataSource] usando Supabase Auth.
/// Substitui [AuthRemoteDataSourceImpl] (HTTP puro) — a interface e o
/// repositório acima não mudam, apenas esta classe concreta.
final class SupabaseAuthDataSourceImpl implements AuthRemoteDataSource {
  const SupabaseAuthDataSourceImpl({required SupabaseClient client})
      : _client = client;

  final SupabaseClient _client;

  // ----------------------------------------------------------------
  // Login com e-mail e senha
  // ----------------------------------------------------------------
  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        throw const AuthFailure('Login falhou. Tente novamente.');
      }
      return _buscarPerfil(user.id, email);
    } on supa.AuthException catch (e) {
      throw AuthFailure(_traduzirErro(e.message));
    } on Failure {
      rethrow;
    } on Exception {
      throw const NetworkFailure();
    }
  }

  // ----------------------------------------------------------------
  // Cadastro com e-mail e senha
  // ----------------------------------------------------------------
  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'phone': phone,
          // Todos os cadastros via app são gestores neste protótipo.
          // Adapte quando houver seleção de perfil na tela de registro.
          'role': 'manager',
        },
      );

      final user = response.user;
      if (user == null) {
        throw const AuthFailure(
          'Cadastro não concluído. Tente novamente.',
        );
      }

      // Quando "Email confirmations" está ATIVO no Supabase, session
      // é null após signUp — o usuário precisa confirmar o e-mail antes
      // de fazer login. Para dev, desative em:
      // Authentication → Settings → "Enable email confirmations" → OFF.
      if (response.session == null) {
        throw const AuthFailure(
          'Cadastro realizado! Confirme seu e-mail para fazer login.',
        );
      }

      // Perfil criado pelo trigger `on_auth_user_created` — retorna
      // dados locais para evitar race condition com o INSERT do trigger.
      return UserModel(
        id: user.id,
        name: name,
        email: email,
        role: UserRole.manager,
      );
    } on supa.AuthException catch (e) {
      throw AuthFailure(_traduzirErro(e.message));
    } on Failure {
      rethrow;
    } on Exception {
      throw const NetworkFailure();
    }
  }

  // ----------------------------------------------------------------
  // Logout
  // ----------------------------------------------------------------
  @override
  Future<void> logout() async {
    try {
      await _client.auth.signOut();
    } on Exception {
      throw const NetworkFailure();
    }
  }

  // ----------------------------------------------------------------
  // Helpers internos
  // ----------------------------------------------------------------

  /// Busca o perfil do usuário na tabela `profiles`. Em caso de falha
  /// (ex: trigger ainda não executou), retorna dados mínimos para não
  /// bloquear o login.
  Future<UserModel> _buscarPerfil(String userId, String email) async {
    try {
      final data = await _client
          .from('profiles')
          .select('name, role')
          .eq('id', userId)
          .single();

      return UserModel(
        id: userId,
        name: data['name'] as String? ?? email.split('@').first,
        email: email,
        role: UserRole.fromJson(data['role'] as String? ?? 'manager'),
      );
    } on Exception {
      // Fallback seguro: dados básicos se perfil ainda não existe.
      return UserModel(
        id: userId,
        name: email.split('@').first,
        email: email,
        role: UserRole.manager,
      );
    }
  }

  /// Converte mensagens de erro do Supabase (em inglês) para pt-BR.
  static String _traduzirErro(String message) {
    final m = message.toLowerCase();
    if (m.contains('invalid login credentials') ||
        m.contains('invalid email or password') ||
        m.contains('email not confirmed')) {
      return 'E-mail ou senha inválidos.';
    }
    if (m.contains('already registered') ||
        m.contains('user already registered')) {
      return 'Este e-mail já está cadastrado.';
    }
    if (m.contains('password should be at least') ||
        m.contains('weak password')) {
      return 'A senha deve ter pelo menos 6 caracteres.';
    }
    if (m.contains('rate limit') || m.contains('too many requests')) {
      return 'Muitas tentativas. Aguarde alguns minutos.';
    }
    if (m.contains('network') || m.contains('connection')) {
      return 'Sem conexão com a internet.';
    }
    return 'Algo deu errado. Tente novamente.';
  }
}
