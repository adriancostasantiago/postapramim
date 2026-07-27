import 'package:postapramim/core/error/result.dart';
import 'package:postapramim/features/solicitacoes/domain/entities/solicitacao_entity.dart';
import 'package:postapramim/features/solicitacoes/domain/repositories/solicitacoes_repository.dart';

/// Lista as solicitações do cliente logado, incluindo as avulsas feitas
/// com o mesmo CPF do cadastro dele.
class ListarMinhasSolicitacoesUsecase {
  final SolicitacoesRepository _repository;
  ListarMinhasSolicitacoesUsecase(this._repository);

  Future<Result<List<SolicitacaoEntity>>> call(String clienteId) {
    return _repository.listarMinhas(clienteId);
  }
}
