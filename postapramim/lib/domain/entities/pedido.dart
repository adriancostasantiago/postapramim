import 'package:equatable/equatable.dart';
import 'package:posta_pra_mim/domain/entities/pedido_status.dart';

/// Entidade de domínio — não conhece JSON, banco ou widgets.
final class Pedido extends Equatable {
  const Pedido({
    required this.id,
    required this.codigo,
    required this.clienteNome,
    required this.status,
    required this.prioridade,
    required this.formaPagamento,
    required this.endereco,
    required this.valor,
    required this.criadoEm,
  });

  /// Identificador único interno (não exibido).
  final String id;

  /// Código exibido ao usuário (ex: "FORD-90234").
  final String codigo;

  final String clienteNome;
  final PedidoStatus status;
  final PedidoPrioridade prioridade;
  final FormaPagamento formaPagamento;
  final String endereco;

  /// Valor em reais (não em centavos) — formatado pela camada de
  /// apresentação via `intl` ou helper dedicado.
  final double valor;

  final DateTime criadoEm;

  @override
  List<Object?> get props => [
        id,
        codigo,
        clienteNome,
        status,
        prioridade,
        formaPagamento,
        endereco,
        valor,
        criadoEm,
      ];
}

/// Métricas agregadas exibidas nos cards do topo do dashboard.
final class PedidosResumo extends Equatable {
  const PedidosResumo({
    required this.totalPedidos,
    required this.solicitados,
    required this.aceitos,
    required this.despachados,
    required this.valorTotal,
  });

  final int totalPedidos;
  final int solicitados;
  final int aceitos;
  final int despachados;
  final double valorTotal;

  @override
  List<Object?> get props => [
        totalPedidos,
        solicitados,
        aceitos,
        despachados,
        valorTotal,
      ];
}
