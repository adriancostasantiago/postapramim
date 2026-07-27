import 'package:postapramim/core/constants/app_constants.dart';
import 'package:postapramim/core/error/result.dart';
import 'package:postapramim/features/solicitacoes/domain/repositories/solicitacoes_repository.dart';

class AtualizarStatusSolicitacaoUsecase {
  final SolicitacoesRepository _repository;
  AtualizarStatusSolicitacaoUsecase(this._repository);

  Future<Result<void>> call({
    required String id,
    required StatusSolicitacao status,
    String? coletadorId,
  }) {
    return _repository.atualizarStatus(
      id: id,
      status: status,
      coletadorId: coletadorId,
    );
  }
}
