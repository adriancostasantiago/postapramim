import 'package:posta_pra_mim/domain/entities/novo_pedido.dart';

/// Contrato de criação de pedidos e consulta de CEP.
abstract interface class NovoPedidoRepository {
  /// Consulta endereço a partir de CEP. Retorna `null` se inválido ou
  /// não encontrado.
  Future<DadosEnderecoCep?> buscarEnderecoPorCep(String cep);

  /// Cria o pedido e retorna identificador + dados de pagamento.
  Future<PedidoCriadoResultado> criarPedido({
    required RascunhoRemetente remetente,
    required RascunhoDestinatario destinatario,
    required RascunhoCarga carga,
    required FormaPagamentoNovoPedido formaPagamento,
  });

  /// Estimativa de frete calculada localmente (sem criar o pedido),
  /// usada no card de revisão antes de finalizar.
  double calcularValorEstimado(RascunhoCarga carga);
}
