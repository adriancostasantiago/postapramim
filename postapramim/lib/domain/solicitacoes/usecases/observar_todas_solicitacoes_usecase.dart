import 'package:postapramim/domain/solicitacoes/entities/solicitacao_entity.dart';
import 'package:postapramim/domain/solicitacoes/repositories/solicitacoes_repository.dart';

/// Realtime de todas as solicitações do sistema — dashboard do coletador.
class ObservarTodasSolicitacoesUsecase {
  final SolicitacoesRepository _repository;
  ObservarTodasSolicitacoesUsecase(this._repository);

  Stream<List<SolicitacaoEntity>> call() {
    return _repository.observarTodas();
  }
}
