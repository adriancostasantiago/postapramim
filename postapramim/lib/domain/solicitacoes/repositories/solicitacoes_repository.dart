import 'package:postapramim/core/constants/app_constants.dart';
import 'package:postapramim/core/error/result.dart';
import 'package:postapramim/domain/solicitacoes/entities/solicitacao_entity.dart';

abstract interface class SolicitacoesRepository {
  Future<Result<SolicitacaoEntity>> criar(SolicitacaoEntity solicitacao);

  Future<Result<void>> criarAvulsa({
    required String codigoDevolucao,
    required String nomeContato,
    required String cpfContato,
    required String telefoneContato,
    required String cep,
    required String logradouro,
    required String numero,
    String? complemento,
    required String bairro,
    required String cidade,
    required String uf,
  });

  /// Solicitações do cliente logado (compatibilidade — não inclui avulsas).
  Future<Result<List<SolicitacaoEntity>>> listarPorCliente(String clienteId);
  Stream<List<SolicitacaoEntity>> observarPorCliente(String clienteId);

  /// Solicitações do cliente logado + avulsas feitas com o mesmo CPF do
  /// cadastro. É o que a Home do cliente deve usar.
  Future<Result<List<SolicitacaoEntity>>> listarMinhas(String clienteId);
  Stream<List<SolicitacaoEntity>> observarMinhas(String clienteId);

  /// Todas as solicitações do sistema — dashboard do coletador.
  Future<Result<List<SolicitacaoEntity>>> listarTodas();
  Stream<List<SolicitacaoEntity>> observarTodas();

  Future<Result<SolicitacaoEntity>> obterPorId(String id);
  Future<Result<void>> cancelar(String id);

  /// Avança/atualiza o status de uma solicitação. Quando [coletadorId] é
  /// informado, também associa a solicitação a esse coletador — usado no
  /// momento em que ele ACEITA uma solicitação em aberto (RLS
  /// `solicitacoes_aceitar_coletador` garante que só é permitido quando a
  /// linha ainda não tem coletador).
  Future<Result<void>> atualizarStatus({
    required String id,
    required StatusSolicitacao status,
    String? coletadorId,
  });
}
