import 'package:postapramim/features/solicitacoes/domain/entities/solicitacao_entity.dart';
import 'package:postapramim/features/solicitacoes/domain/repositories/solicitacoes_repository.dart';

class ObservarSolicitacoesUsecase {
  final SolicitacoesRepository _repository;
  ObservarSolicitacoesUsecase(this._repository);

  Stream<List<SolicitacaoEntity>> call(String clienteId) =>
      _repository.observarPorCliente(clienteId);
}
