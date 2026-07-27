import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:posta_pra_mim/data/datasources/auth_local_datasource.dart';
import 'package:posta_pra_mim/data/models/user_model.dart';
import 'package:posta_pra_mim/domain/entities/user_role.dart';

/// Implementação de [AuthLocalDataSource] baseada na sessão nativa do
/// Supabase. O SDK persiste a sessão automaticamente via
/// shared_preferences — portanto [saveUser] e [clear] são noops.
///
/// [getUser] lê o usuário atual da sessão em memória (sem rede) e
/// busca o perfil no banco apenas quando necessário (ex: após cold start).
final class SupabaseLocalDataSourceImpl implements AuthLocalDataSource {
  const SupabaseLocalDataSourceImpl({required SupabaseClient client})
      : _client = client;

  final SupabaseClient _client;

  /// Noop — o Supabase SDK já persiste a sessão internamente.
  @override
  Future<void> saveUser(UserModel user) async {}

  /// Retorna o usuário da sessão ativa, buscando o perfil no banco.
  /// Retorna `null` quando não há sessão válida.
  @override
  Future<UserModel?> getUser() async {
    final supabaseUser = _client.auth.currentUser;
    if (supabaseUser == null) return null;

    try {
      final data = await _client
          .from('profiles')
          .select('name, role')
          .eq('id', supabaseUser.id)
          .single();

      return UserModel(
        id: supabaseUser.id,
        name: data['name'] as String? ?? '',
        email: supabaseUser.email ?? '',
        role: UserRole.fromJson(data['role'] as String? ?? 'manager'),
      );
    } on Exception {
      // Perfil não encontrado: retorna null para forçar novo login.
      return null;
    }
  }

  /// Noop — [AuthRemoteDataSource.logout] já chama `signOut()` que
  /// limpa a sessão do Supabase SDK.
  @override
  Future<void> clear() async {}
}
