import 'package:postapramim/presentation/auth/providers/auth_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:postapramim/core/services/supabase_service.dart';

part 'perfil_providers.g.dart';

class PerfilFormState {
  final bool carregando;
  final String? erro;
  const PerfilFormState({this.carregando = false, this.erro});
}

@riverpod
class PerfilFormController extends _$PerfilFormController {
  @override
  PerfilFormState build() => const PerfilFormState();

  Future<bool> salvar({
    required String usuarioId,
    required String nome,
    required String telefone,
  }) async {
    state = const PerfilFormState(carregando: true);
    try {
      await SupabaseService.client
          .from('usuarios')
          .update({'nome': nome, 'telefone': telefone})
          .eq('id', usuarioId);

      await ref.read(authControllerProvider.notifier).recarregar();
      state = const PerfilFormState();
      return true;
    } catch (e) {
      state = PerfilFormState(erro: 'Não foi possível salvar: $e');
      return false;
    }
  }
}
