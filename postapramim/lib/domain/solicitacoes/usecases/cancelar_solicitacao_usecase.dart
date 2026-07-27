import 'package:postapramim/core/error/result.dart';
import 'package:postapramim/domain/solicitacoes/repositories/solicitacoes_repository.dart';

class CancelarSolicitacaoUsecase {
  final SolicitacoesRepository _repository;
  CancelarSolicitacaoUsecase(this._repository);

  Future<Result<void>> call(String id) => _repository.cancelar(id);
}
