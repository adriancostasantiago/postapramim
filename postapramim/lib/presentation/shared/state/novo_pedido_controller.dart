import 'package:flutter/foundation.dart';
import 'package:posta_pra_mim/core/errors/failure.dart';
import 'package:posta_pra_mim/core/utils/app_logger.dart';
import 'package:posta_pra_mim/domain/entities/novo_pedido.dart';
import 'package:posta_pra_mim/domain/usecases/novo_pedido_usecases.dart';
import 'package:posta_pra_mim/presentation/shared/state/novo_pedido_state.dart';

/// Controller do fluxo de criação de pedido (Provider/ChangeNotifier).
///
/// Instanciado localmente em `NovoPedidoPage` — mesmo padrão de
/// `PedidoDetalheController`. Use cases chegam via construtor.
final class NovoPedidoController extends ChangeNotifier {
  NovoPedidoController({
    required BuscarEnderecoPorCepUseCase buscarEnderecoPorCepUseCase,
    required CriarPedidoUseCase criarPedidoUseCase,
    required CalcularValorEstimadoUseCase calcularValorEstimadoUseCase,
  })  : _buscarCep = buscarEnderecoPorCepUseCase,
        _criarPedido = criarPedidoUseCase,
        _calcularValor = calcularValorEstimadoUseCase;

  final BuscarEnderecoPorCepUseCase _buscarCep;
  final CriarPedidoUseCase _criarPedido;
  final CalcularValorEstimadoUseCase _calcularValor;
  static final _log = AppLogger.of('NovoPedidoController');

  NovoPedidoState _state = const NovoPedidoEmEdicao();
  NovoPedidoState get state => _state;

  void _setState(NovoPedidoState s) {
    _state = s;
    notifyListeners();
  }

  NovoPedidoEmEdicao get _edicao => switch (_state) {
        NovoPedidoEmEdicao() => _state as NovoPedidoEmEdicao,
        NovoPedidoSalvando(:final edicao) => edicao,
        NovoPedidoErro(:final edicao) => edicao,
        NovoPedidoCriado() => const NovoPedidoEmEdicao(),
      };

  void confirmarRemetente(RascunhoRemetente remetente) =>
      _setState(_edicao.copyWith(etapaAtual: 1, remetente: remetente));

  void confirmarDestinatario(RascunhoDestinatario destinatario) =>
      _setState(_edicao.copyWith(etapaAtual: 2, destinatario: destinatario));

  void confirmarCarga(RascunhoCarga carga) =>
      _setState(_edicao.copyWith(etapaAtual: 3, carga: carga));

  void selecionarFormaPagamento(FormaPagamentoNovoPedido forma) =>
      _setState(_edicao.copyWith(formaPagamento: forma));

  void voltarEtapa() {
    final e = _edicao;
    if (e.etapaAtual == 0) return;
    _setState(e.copyWith(etapaAtual: e.etapaAtual - 1));
  }

  /// Retorna o resultado diretamente (sem alterar o state principal)
  /// para que os widgets de etapa preencham os campos do formulário.
  Future<DadosEnderecoCep?> buscarCep(String cep) async {
    try {
      return await _buscarCep(cep);
    } on Exception catch (error, stackTrace) {
      _log.warning('Falha ao buscar CEP $cep', error, stackTrace);
      return null;
    }
  }

  double calcularValorEstimado(RascunhoCarga carga) => _calcularValor(carga);

  Future<void> finalizarPedido() async {
    final edicao = _edicao;
    final remetente = edicao.remetente;
    final destinatario = edicao.destinatario;
    final carga = edicao.carga;
    assert(
      remetente != null && destinatario != null && carga != null,
      'finalizarPedido() chamado antes de todas as etapas serem preenchidas.',
    );

    _setState(NovoPedidoSalvando(edicao));
    try {
      final resultado = await _criarPedido(
        remetente: remetente!,
        destinatario: destinatario!,
        carga: carga!,
        formaPagamento: edicao.formaPagamento,
      );
      _setState(NovoPedidoCriado(resultado));
    } on Failure catch (failure) {
      _setState(NovoPedidoErro(failure: failure, edicao: edicao));
    } on Exception catch (error, stackTrace) {
      _log.severe('Erro inesperado ao criar pedido', error, stackTrace);
      _setState(
        NovoPedidoErro(failure: const UnknownFailure(), edicao: edicao),
      );
    }
  }
}
