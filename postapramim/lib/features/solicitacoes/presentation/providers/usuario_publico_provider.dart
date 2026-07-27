import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:postapramim/core/services/supabase_service.dart';

part 'usuario_publico_provider.g.dart';

/// Dados públicos mínimos de um usuário (cliente ou coletador), usados
/// somente para exibição — ex.: "Aceita por: <nome>" nos cards de
/// solicitação/coleta. Não é a `UserEntity` completa, só o necessário pra
/// UI, e não deve ser usada para nada além de exibição.
///
/// Depende da policy de RLS `usuarios_select_participante_solicitacao`
/// para conseguir ler o nome de alguém que não seja o próprio usuário
/// logado (ver rls_patch_status_e_aceite.sql).
class UsuarioPublico {
  final String id;
  final String nome;
  final String? telefone;
  const UsuarioPublico({required this.id, required this.nome, this.telefone});
}

@riverpod
Future<UsuarioPublico?> usuarioPublico(Ref ref, String usuarioId) async {
  final data = await SupabaseService.client
      .from('usuarios')
      .select('id, nome, telefone')
      .eq('id', usuarioId)
      .maybeSingle();
  if (data == null) return null;
  return UsuarioPublico(
    id: data['id'] as String,
    nome: data['nome'] as String,
    telefone: data['telefone'] as String?,
  );
}
