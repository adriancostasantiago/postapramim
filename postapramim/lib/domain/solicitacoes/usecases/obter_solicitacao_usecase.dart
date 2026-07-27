import 'package:postapramim/core/error/result.dart';
import 'package:postapramim/domain/solicitacoes/entities/solicitacao_entity.dart';
import 'package:postapramim/domain/solicitacoes/repositories/solicitacoes_repository.dart';

class ObterSolicitacaoUsecase {
  final SolicitacoesRepository _repository;
  ObterSolicitacaoUsecase(this._repository);

  Future<Result<SolicitacaoEntity>> call(String id) =>
      _repository.obterPorId(id);
}
