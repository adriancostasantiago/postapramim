import 'package:postapramim/core/error/result.dart';
import 'package:postapramim/features/solicitacoes/domain/entities/solicitacao_entity.dart';
import 'package:postapramim/features/solicitacoes/domain/repositories/solicitacoes_repository.dart';

/// Lista todas as solicitações do sistema — usado no dashboard do
/// coletador, que precisa ver toda a demanda em aberto (não só a
/// atribuída a ele).
class ListarTodasSolicitacoesUsecase {
  final SolicitacoesRepository _repository;
  ListarTodasSolicitacoesUsecase(this._repository);

  Future<Result<List<SolicitacaoEntity>>> call() {
    return _repository.listarTodas();
  }
}
