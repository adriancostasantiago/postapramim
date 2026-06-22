import 'package:equatable/equatable.dart';
import 'package:posta_pra_mim/core/errors/failure.dart';
import 'package:posta_pra_mim/domain/entities/pedido_detalhe.dart';

/// Estados mutuamente exclusivos da tela de detalhes do pedido.
sealed class PedidoDetalheState extends Equatable {
  const PedidoDetalheState();

  @override
  List<Object?> get props => [];
}

final class PedidoDetalheInitial extends PedidoDetalheState {
  const PedidoDetalheInitial();
}

final class PedidoDetalheLoading extends PedidoDetalheState {
  const PedidoDetalheLoading();
}

final class PedidoDetalheLoaded extends PedidoDetalheState {
  const PedidoDetalheLoaded(this.detalhe);

  final PedidoDetalhe detalhe;

  @override
  List<Object?> get props => [detalhe];
}

final class PedidoDetalheError extends PedidoDetalheState {
  const PedidoDetalheError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
