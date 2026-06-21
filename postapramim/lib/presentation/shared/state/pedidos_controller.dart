import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:posta_pra_mim/core/errors/failure.dart';
import 'package:posta_pra_mim/core/utils/app_logger.dart';
import 'package:posta_pra_mim/domain/entities/pedido_status.dart';
import 'package:posta_pra_mim/domain/usecases/pedido_usecases.dart';
import 'package:posta_pra_mim/presentation/shared/state/pedidos_state.dart';

/// Controller do dashboard de pedidos (padrão Provider/ChangeNotifier).
///
/// Lógica de negócio (busca com debounce, filtro de status, refresh)
/// vive aqui — fora da árvore de widgets. Recebe use cases via
/// construtor, nunca os instancia internamente.
final class PedidosController extends ChangeNotifier {
  PedidosController({
    required GetPedidosResumoUseCase getPedidosResumoUseCase,
    required GetPedidosRecentesUseCase getPedidosRecentesUseCase,
    required AtualizarStatusPedidoUseCase atualizarStatusPedidoUseCase,
  })  : _getResumo = getPedidosResumoUseCase,
        _getPedidosRecentes = getPedidosRecentesUseCase,
        _atualizarStatus = atualizarStatusPedidoUseCase;

  final GetPedidosResumoUseCase _getResumo;
  final GetPedidosRecentesUseCase _getPedidosRecentes;
  final AtualizarStatusPedidoUseCase _atualizarStatus;
  static final _log = AppLogger.of('PedidosController');

  PedidosState _state = const PedidosInitial();
  PedidosState get state => _state;

  String _query = '';
  String get query => _query;

  PedidoStatus? _statusFiltro;
  PedidoStatus? get statusFiltro => _statusFiltro;

  Timer? _debounce;

  void _setState(PedidosState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> load() async {
    _setState(const PedidosLoading());
    try {
      final resumo = await _getResumo();
      final pedidos = await _getPedidosRecentes(
        query: _query,
        statusFiltro: _statusFiltro,
      );
      _setState(PedidosLoaded(resumo: resumo, pedidos: pedidos));
    } on Failure catch (failure) {
      _setState(PedidosError(failure));
    } on Exception catch (error, stackTrace) {
      _log.severe('Erro inesperado ao carregar pedidos', error, stackTrace);
      _setState(const PedidosError(UnknownFailure()));
    }
  }

  /// Atualiza a busca textual com debounce de 400ms — evita disparar
  /// uma chamada por tecla digitada.
  void updateQuery(String value) {
    _query = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      unawaited(_refreshList());
    });
  }

  Future<void> updateStatusFiltro(PedidoStatus? status) async {
    _statusFiltro = status;
    await _refreshList();
  }

  Future<void> _refreshList() async {
    final current = _state;
    if (current is! PedidosLoaded) return;

    try {
      final pedidos = await _getPedidosRecentes(
        query: _query,
        statusFiltro: _statusFiltro,
      );
      _setState(PedidosLoaded(resumo: current.resumo, pedidos: pedidos));
    } on Failure catch (failure) {
      _setState(PedidosError(failure));
    }
  }

  Future<void> avancarStatus({
    required String pedidoId,
    required PedidoStatus novoStatus,
  }) async {
    final current = _state;
    if (current is! PedidosLoaded) return;

    try {
      final atualizado = await _atualizarStatus(
        pedidoId: pedidoId,
        novoStatus: novoStatus,
      );
      final pedidosAtualizados = current.pedidos
          .map((p) => p.id == atualizado.id ? atualizado : p)
          .toList();
      _setState(PedidosLoaded(resumo: current.resumo, pedidos: pedidosAtualizados));
    } on Failure catch (failure, stackTrace) {
      _log.warning('Falha ao atualizar status do pedido', failure, stackTrace);
      _setState(PedidosError(failure));
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
