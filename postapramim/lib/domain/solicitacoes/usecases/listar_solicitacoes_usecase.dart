import 'package:postapramim/core/error/result.dart';
import 'package:postapramim/domain/solicitacoes/entities/solicitacao_entity.dart';
import 'package:postapramim/domain/solicitacoes/repositories/solicitacoes_repository.dart';

class ListarSolicitacoesUsecase {
  final SolicitacoesRepository _repository;
  ListarSolicitacoesUsecase(this._repository);

  Future<Result<List<SolicitacaoEntity>>> call(String clienteId) {
    return _repository.listarPorCliente(clienteId);
  }
}
