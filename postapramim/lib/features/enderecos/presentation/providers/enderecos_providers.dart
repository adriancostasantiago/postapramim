import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:postapramim/core/services/supabase_service.dart';
import 'package:postapramim/features/enderecos/domain/entities/endereco_resumo.dart';

part 'enderecos_providers.g.dart';

/// Busca o endereço principal do cliente (ou o primeiro cadastrado, se
/// nenhum estiver marcado como principal). Retorna `null` se o cliente
/// ainda não tiver nenhum endereço cadastrado.
///
/// NOTA: isso é uma solução enxuta para destravar a tela de nova
/// solicitação, que hoje só precisa de UM endereço (o "endereço
/// cadastrado" mostrado como card não-editável). Se o app evoluir para
/// permitir múltiplos endereços com seleção pelo usuário, isso deve virar
/// uma feature `enderecos` completa (entity/model/datasource/repository),
/// no mesmo padrão de `solicitacoes`.
@riverpod
Future<EnderecoResumo?> enderecoPrincipalCliente(
  Ref ref,
  String clienteId,
) async {
  final data = await SupabaseService.client
      .from('enderecos')
      .select()
      .eq('usuario_id', clienteId)
      .order('principal', ascending: false)
      .order('criado_em', ascending: true)
      .limit(1)
      .maybeSingle();

  if (data == null) return null;
  return EnderecoResumo.fromJson(data);
}

// ---------------------------------------------------------------------------
// Cadastro/edição de endereço — usado pela `EnderecoFormPage`.
// ---------------------------------------------------------------------------

class EnderecoFormState {
  final bool carregando;
  final String? erro;
  const EnderecoFormState({this.carregando = false, this.erro});
}

@riverpod
class EnderecoFormController extends _$EnderecoFormController {
  @override
  EnderecoFormState build() => const EnderecoFormState();

  /// Salva um endereço: cria um novo se [id] for nulo, ou atualiza o
  /// existente caso contrário. Ao criar, marca automaticamente como
  /// `principal` — hoje o app só usa um único endereço por cliente na
  /// tela de nova solicitação, então não expomos essa escolha na UI.
  ///
  /// TODO: se o app evoluir para múltiplos endereços com seleção, tratar
  /// aqui a troca de qual endereço é o `principal` (hoje, ao inserir um
  /// segundo endereço, o antigo `principal = true` não é desmarcado).
  Future<bool> salvar({
    String? id,
    required String usuarioId,
    String? apelido,
    required String cep,
    required String logradouro,
    required String numero,
    String? complemento,
    required String bairro,
    required String cidade,
    required String uf,
  }) async {
    state = const EnderecoFormState(carregando: true);
    try {
      final dados = <String, dynamic>{
        'usuario_id': usuarioId,
        'apelido': apelido,
        'cep': cep,
        'logradouro': logradouro,
        'numero': numero,
        'complemento': complemento,
        'bairro': bairro,
        'cidade': cidade,
        'uf': uf,
      };

      if (id == null) {
        await SupabaseService.client.from('enderecos').insert({
          ...dados,
          'principal': true,
        });
      } else {
        await SupabaseService.client
            .from('enderecos')
            .update(dados)
            .eq('id', id);
      }

      state = const EnderecoFormState();
      ref.invalidate(enderecoPrincipalClienteProvider(usuarioId));
      return true;
    } catch (e) {
      state = EnderecoFormState(
        erro: 'Não foi possível salvar o endereço. Tente novamente.',
      );
      return false;
    }
  }
}
