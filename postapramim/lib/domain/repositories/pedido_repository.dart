import 'package:posta_pra_mim/domain/entities/pedido.dart';
import 'package:posta_pra_mim/domain/entities/pedido_status.dart';

/// Contrato de acesso a dados de pedidos. Implementações concretas
/// (mock, HTTP) ficam na camada `data` — widgets e use cases
/// dependem apenas desta abstração.
abstract interface class PedidoRepository {
  /// Retorna o resumo agregado (cards de métricas do topo).
  Future<PedidosResumo> getResumo();

  /// Lista pedidos recentes, com filtro textual opcional (código,
  /// nome do cliente ou CPF) e filtro de status opcional.
  Future<List<Pedido>> getPedidosRecentes({
    String? query,
    PedidoStatus? statusFiltro,
  });

  /// Avança o status de um pedido (ex: solicitado → aprovado).
  Future<Pedido> atualizarStatus({
    required String pedidoId,
    required PedidoStatus novoStatus,
  });
}
