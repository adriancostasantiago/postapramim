import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:postapramim/core/constants/supabase_constants.dart';
import 'package:postapramim/core/error/exceptions.dart';
import 'package:postapramim/core/services/logger_service.dart';
import 'package:postapramim/data/auth/models/user_model.dart';

abstract interface class AuthRemoteDatasource {
  Future<UserModel> login({required String email, required String senha});
  Future<UserModel> cadastrar({
    required String nome,
    required String email,
    required String senha,
    required String perfil,
    required String cpf,
    required String celular,
  });
  Future<void> loginComGoogle();
  Future<void> loginComApple();
  Future<void> enviarMagicLink(String email);
  Future<void> recuperarSenha(String email);
  Future<void> logout();
  Future<UserModel?> usuarioAtual();
  Stream<AuthState> get authStateChanges;
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final SupabaseClient _client;
  AuthRemoteDatasourceImpl(this._client);

  @override
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  @override
  Future<UserModel> login({
    required String email,
    required String senha,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: senha,
      );
      if (response.user == null) {
        throw const AuthException(
          'Falha ao autenticar. Verifique suas credenciais.',
        );
      }
      return _buscarPerfilCompleto(response.user!.id);
    } on AuthException {
      rethrow;
    } catch (e) {
      LoggerService.error('Erro no login', e);
      throw AuthException('Erro ao fazer login: $e');
    }
  }

  @override
  Future<UserModel> cadastrar({
    required String nome,
    required String email,
    required String senha,
    required String perfil,
    required String cpf,
    required String celular,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: senha,
        data: {'nome': nome, 'perfil': perfil, 'cpf': cpf, 'telefone': celular},
      );

      if (response.user == null) {
        throw const AuthException('Falha ao criar conta.');
      }

      if (response.session == null) {
        // O projeto Supabase está com "Confirm email" habilitado: a conta
        // já foi criada e o trigger `handle_new_user` já rodou (o registro
        // em `usuarios`/`clientes`/`coletadores` existe), mas ainda não há
        // sessão ativa. Sem sessão, `auth.uid()` é null e a policy RLS de
        // `usuarios` bloqueia a leitura do perfil abaixo — por isso
        // avisamos o usuário em vez de tentar buscar o perfil e falhar
        // com um erro genérico.
        throw const AuthException(
          'Conta criada! Verifique seu e-mail para confirmar antes de fazer login.',
        );
      }

      // A linha em `usuarios` (+ tabela de perfil específica) é criada
      // automaticamente por trigger no banco (ver database/schema.sql ->
      // handle_new_user), a partir do metadata acima.
      return _buscarPerfilCompleto(response.user!.id);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Erro ao cadastrar: $e');
    }
  }

  @override
  Future<void> loginComGoogle() async {
    await _client.auth.signInWithOAuth(OAuthProvider.google);
  }

  @override
  Future<void> loginComApple() async {
    await _client.auth.signInWithOAuth(OAuthProvider.apple);
  }

  @override
  Future<void> enviarMagicLink(String email) async {
    await _client.auth.signInWithOtp(email: email);
  }

  @override
  Future<void> recuperarSenha(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  @override
  Future<void> logout() async {
    await _client.auth.signOut();
  }

  @override
  Future<UserModel?> usuarioAtual() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return _buscarPerfilCompleto(user.id);
  }

  Future<UserModel> _buscarPerfilCompleto(String userId) async {
    final data = await _client
        .from(SupabaseConstants.tableUsuarios)
        .select()
        .eq('id', userId)
        .single();
    return UserModel.fromJson(data);
  }
}
