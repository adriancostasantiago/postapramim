import 'package:equatable/equatable.dart';
import 'package:posta_pra_mim/core/errors/failure.dart';
import 'package:posta_pra_mim/domain/entities/novo_pedido.dart';

/// Estados mutuamente exclusivos do fluxo de criação de pedido.
sealed class NovoPedidoState extends Equatable {
  const NovoPedidoState();

  @override
  List<Object?> get props => [];
}

/// Usuário está preenchendo as 4 etapas do formulário.
/// Índices: 0 = Remetente, 1 = Destinatário, 2 = Carga, 3 = Revisão.
final class NovoPedidoEmEdicao extends NovoPedidoState {
  const NovoPedidoEmEdicao({
    this.etapaAtual = 0,
    this.remetente,
    this.destinatario,
    this.carga,
    this.formaPagamento = FormaPagamentoNovoPedido.pix,
  });

  final int etapaAtual;
  final RascunhoRemetente? remetente;
  final RascunhoDestinatario? destinatario;
  final RascunhoCarga? carga;
  final FormaPagamentoNovoPedido formaPagamento;

  NovoPedidoEmEdicao copyWith({
    int? etapaAtual,
    RascunhoRemetente? remetente,
    RascunhoDestinatario? destinatario,
    RascunhoCarga? carga,
    FormaPagamentoNovoPedido? formaPagamento,
  }) {
    return NovoPedidoEmEdicao(
      etapaAtual: etapaAtual ?? this.etapaAtual,
      remetente: remetente ?? this.remetente,
      destinatario: destinatario ?? this.destinatario,
      carga: carga ?? this.carga,
      formaPagamento: formaPagamento ?? this.formaPagamento,
    );
  }

  @override
  List<Object?> get props =>
      [etapaAtual, remetente, destinatario, carga, formaPagamento];
}

/// Pedido sendo enviado ao repositório.
final class NovoPedidoSalvando extends NovoPedidoState {
  const NovoPedidoSalvando(this.edicao);

  final NovoPedidoEmEdicao edicao;

  @override
  List<Object?> get props => [edicao];
}

/// Pedido criado com sucesso — a página navega a partir deste estado.
final class NovoPedidoCriado extends NovoPedidoState {
  const NovoPedidoCriado(this.resultado);

  final PedidoCriadoResultado resultado;

  @override
  List<Object?> get props => [resultado];
}

/// Erro ao criar o pedido — exibido na etapa de revisão.
final class NovoPedidoErro extends NovoPedidoState {
  const NovoPedidoErro({required this.failure, required this.edicao});

  final Failure failure;
  final NovoPedidoEmEdicao edicao;

  @override
  List<Object?> get props => [failure, edicao];
}
