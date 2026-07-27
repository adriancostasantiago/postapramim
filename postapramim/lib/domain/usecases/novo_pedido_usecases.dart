import 'package:posta_pra_mim/domain/entities/novo_pedido.dart';
import 'package:posta_pra_mim/domain/repositories/novo_pedido_repository.dart';

/// Consulta endereço por CEP — usada nos passos de remetente e
/// destinatário para preencher logradouro/bairro/cidade/UF.
final class BuscarEnderecoPorCepUseCase {
  const BuscarEnderecoPorCepUseCase(this._repository);

  final NovoPedidoRepository _repository;

  Future<DadosEnderecoCep?> call(String cep) =>
      _repository.buscarEnderecoPorCep(cep);
}

/// Cria um pedido completo com os dados das 4 etapas.
final class CriarPedidoUseCase {
  const CriarPedidoUseCase(this._repository);

  final NovoPedidoRepository _repository;

  Future<PedidoCriadoResultado> call({
    required RascunhoRemetente remetente,
    required RascunhoDestinatario destinatario,
    required RascunhoCarga carga,
    required FormaPagamentoNovoPedido formaPagamento,
  }) {
    return _repository.criarPedido(
      remetente: remetente,
      destinatario: destinatario,
      carga: carga,
      formaPagamento: formaPagamento,
    );
  }
}

/// Calcula valor estimado do frete sem criar o pedido — usado na
/// etapa de revisão para exibir o total antes de finalizar.
final class CalcularValorEstimadoUseCase {
  const CalcularValorEstimadoUseCase(this._repository);

  final NovoPedidoRepository _repository;

  double call(RascunhoCarga carga) => _repository.calcularValorEstimado(carga);
}
