import 'package:posta_pra_mim/domain/entities/pedido.dart';
import 'package:posta_pra_mim/domain/entities/pedido_detalhe.dart';
import 'package:posta_pra_mim/domain/entities/pedido_status.dart';
import 'package:posta_pra_mim/domain/repositories/pedido_repository.dart';

final class GetPedidosResumoUseCase {
  const GetPedidosResumoUseCase(this._repository);

  final PedidoRepository _repository;

  Future<PedidosResumo> call() => _repository.getResumo();
}

final class GetPedidosRecentesUseCase {
  const GetPedidosRecentesUseCase(this._repository);

  final PedidoRepository _repository;

  Future<List<Pedido>> call({String? query, PedidoStatus? statusFiltro}) {
    return _repository.getPedidosRecentes(
      query: query,
      statusFiltro: statusFiltro,
    );
  }
}

final class AtualizarStatusPedidoUseCase {
  const AtualizarStatusPedidoUseCase(this._repository);

  final PedidoRepository _repository;

  Future<Pedido> call({
    required String pedidoId,
    required PedidoStatus novoStatus,
  }) {
    return _repository.atualizarStatus(
      pedidoId: pedidoId,
      novoStatus: novoStatus,
    );
  }
}

/// Busca os dados completos de um pedido para a tela de detalhes.
final class GetPedidoDetalheUseCase {
  const GetPedidoDetalheUseCase(this._repository);

  final PedidoRepository _repository;

  Future<PedidoDetalhe> call(String pedidoId) {
    return _repository.getPedidoDetalhe(pedidoId);
  }
}
