import 'package:equatable/equatable.dart';
import 'package:posta_pra_mim/core/errors/failure.dart';
import 'package:posta_pra_mim/domain/entities/pedido.dart';

/// Estados mutuamente exclusivos da listagem de pedidos do dashboard.
sealed class PedidosState extends Equatable {
  const PedidosState();

  @override
  List<Object?> get props => [];
}

final class PedidosInitial extends PedidosState {
  const PedidosInitial();
}

final class PedidosLoading extends PedidosState {
  const PedidosLoading();
}

final class PedidosLoaded extends PedidosState {
  const PedidosLoaded({required this.resumo, required this.pedidos});

  final PedidosResumo resumo;
  final List<Pedido> pedidos;

  @override
  List<Object?> get props => [resumo, pedidos];
}

final class PedidosError extends PedidosState {
  const PedidosError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
