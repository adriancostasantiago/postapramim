/// Status do ciclo de vida de um pedido. Enum exhaustivo — a UI trata
/// cada variante explicitamente (switch exaustivo), nunca via
/// combinação de booleans.
///
/// Apresentação visual (cores, ícones) fica na camada de apresentação
/// — ver `presentation/manager_dashboard/widgets/status_badge.dart` —
/// para manter o domínio livre de dependências de UI.
enum PedidoStatus {
  solicitado,
  aprovado,
  despachado,
  emTransito,
  entregue,
  cancelado;

  String get label => switch (this) {
        PedidoStatus.solicitado => 'Solicitado',
        PedidoStatus.aprovado => 'Aprovado',
        PedidoStatus.despachado => 'Despachado',
        PedidoStatus.emTransito => 'Em Trânsito',
        PedidoStatus.entregue => 'Entregue',
        PedidoStatus.cancelado => 'Cancelado',
      };
}

/// Prioridade de atendimento do pedido.
enum PedidoPrioridade {
  normal,
  urgente;

  String get label => switch (this) {
        PedidoPrioridade.normal => 'Normal',
        PedidoPrioridade.urgente => 'Urgente',
      };
}

/// Forma de pagamento do pedido.
enum FormaPagamento {
  pendente,
  pix,
  cartao,
  boleto;

  String get label => switch (this) {
        FormaPagamento.pendente => 'Pendente',
        FormaPagamento.pix => 'Pago via Pix',
        FormaPagamento.cartao => 'Pago (Cartão)',
        FormaPagamento.boleto => 'Pago (Boleto)',
      };

  bool get isPago => this != FormaPagamento.pendente;
}
