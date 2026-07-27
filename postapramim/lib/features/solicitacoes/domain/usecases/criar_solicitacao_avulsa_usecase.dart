import 'package:postapramim/core/error/result.dart';
import 'package:postapramim/features/solicitacoes/domain/repositories/solicitacoes_repository.dart';

class CriarSolicitacaoAvulsaUsecase {
  final SolicitacoesRepository _repository;
  CriarSolicitacaoAvulsaUsecase(this._repository);

  Future<Result<void>> call({
    required String codigoDevolucao,
    required String nomeContato,
    required String cpfContato,
    required String telefoneContato,
    required String cep,
    required String logradouro,
    required String numero,
    String? complemento,
    required String bairro,
    required String cidade,
    required String uf,
  }) {
    return _repository.criarAvulsa(
      codigoDevolucao: codigoDevolucao,
      nomeContato: nomeContato,
      cpfContato: cpfContato,
      telefoneContato: telefoneContato,
      cep: cep,
      logradouro: logradouro,
      numero: numero,
      complemento: complemento,
      bairro: bairro,
      cidade: cidade,
      uf: uf,
    );
  }
}
