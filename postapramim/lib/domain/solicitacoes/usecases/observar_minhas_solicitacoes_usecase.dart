import 'package:postapramim/domain/solicitacoes/entities/solicitacao_entity.dart';
import 'package:postapramim/domain/solicitacoes/repositories/solicitacoes_repository.dart';

/// Realtime das solicitações do cliente logado + avulsas do mesmo CPF.
class ObservarMinhasSolicitacoesUsecase {
  final SolicitacoesRepository _repository;
  ObservarMinhasSolicitacoesUsecase(this._repository);

  Stream<List<SolicitacaoEntity>> call(String clienteId) {
    return _repository.observarMinhas(clienteId);
  }
}
