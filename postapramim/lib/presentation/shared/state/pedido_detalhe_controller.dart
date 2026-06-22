import 'package:flutter/foundation.dart';
import 'package:posta_pra_mim/core/errors/failure.dart';
import 'package:posta_pra_mim/core/utils/app_logger.dart';
import 'package:posta_pra_mim/domain/usecases/pedido_usecases.dart';
import 'package:posta_pra_mim/presentation/shared/state/pedido_detalhe_state.dart';

/// Controller da tela de detalhes do pedido (padrão Provider/ChangeNotifier).
///
/// Diferente de [PedidosController] (lista do dashboard, registrado
/// globalmente em `AppProviders`), esta classe é instanciada
/// localmente pela própria página — ver `pedido_detalhe_page.dart` —
/// pois seu estado é específico de um único pedido, identificado pela
/// rota.
final class PedidoDetalheController extends ChangeNotifier {
  PedidoDetalheController({
    required GetPedidoDetalheUseCase getPedidoDetalheUseCase,
  }) : _getPedidoDetalhe = getPedidoDetalheUseCase;

  final GetPedidoDetalheUseCase _getPedidoDetalhe;
  static final _log = AppLogger.of('PedidoDetalheController');

  PedidoDetalheState _state = const PedidoDetalheInitial();
  PedidoDetalheState get state => _state;

  String? _pedidoId;

  void _setState(PedidoDetalheState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> load(String pedidoId) async {
    _pedidoId = pedidoId;
    _setState(const PedidoDetalheLoading());
    try {
      final detalhe = await _getPedidoDetalhe(pedidoId);
      _setState(PedidoDetalheLoaded(detalhe));
    } on Failure catch (failure) {
      _setState(PedidoDetalheError(failure));
    } on Exception catch (error, stackTrace) {
      _log.severe(
        'Erro inesperado ao carregar detalhes do pedido',
        error,
        stackTrace,
      );
      _setState(const PedidoDetalheError(UnknownFailure()));
    }
  }

  Future<void> retry() async {
    final id = _pedidoId;
    if (id == null) return;
    await load(id);
  }
}
