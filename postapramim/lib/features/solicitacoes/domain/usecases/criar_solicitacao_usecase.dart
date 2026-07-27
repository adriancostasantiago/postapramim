import 'package:postapramim/core/error/result.dart';
import 'package:postapramim/features/solicitacoes/domain/entities/solicitacao_entity.dart';
import 'package:postapramim/features/solicitacoes/domain/repositories/solicitacoes_repository.dart';

class CriarSolicitacaoUsecase {
  final SolicitacoesRepository _repository;
  CriarSolicitacaoUsecase(this._repository);

  Future<Result<SolicitacaoEntity>> call(SolicitacaoEntity solicitacao) {
    return _repository.criar(solicitacao);
  }
}
