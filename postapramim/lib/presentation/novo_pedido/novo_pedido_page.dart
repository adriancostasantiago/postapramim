import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:posta_pra_mim/core/router/app_routes.dart';
import 'package:posta_pra_mim/core/theme/app_colors.dart';
import 'package:posta_pra_mim/domain/usecases/novo_pedido_usecases.dart';
import 'package:posta_pra_mim/presentation/novo_pedido/steps/carga_step.dart';
import 'package:posta_pra_mim/presentation/novo_pedido/steps/destinatario_step.dart';
import 'package:posta_pra_mim/presentation/novo_pedido/steps/remetente_step.dart';
import 'package:posta_pra_mim/presentation/novo_pedido/steps/revisao_step.dart';
import 'package:posta_pra_mim/presentation/novo_pedido/widgets/novo_pedido_stepper.dart';
import 'package:posta_pra_mim/presentation/shared/state/novo_pedido_controller.dart';
import 'package:posta_pra_mim/presentation/shared/state/novo_pedido_state.dart';

/// Tela de criação de novo pedido — orquestra as 4 etapas do
/// formulário. Não chama rede/IO diretamente: delega ao
/// `NovoPedidoController`, instanciado localmente.
class NovoPedidoPage extends StatelessWidget {
  const NovoPedidoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<NovoPedidoController>(
      create: (ctx) => NovoPedidoController(
        buscarEnderecoPorCepUseCase: ctx.read<BuscarEnderecoPorCepUseCase>(),
        criarPedidoUseCase: ctx.read<CriarPedidoUseCase>(),
        calcularValorEstimadoUseCase: ctx.read<CalcularValorEstimadoUseCase>(),
      ),
      child: const _NovoPedidoView(),
    );
  }
}

class _NovoPedidoView extends StatefulWidget {
  const _NovoPedidoView();

  @override
  State<_NovoPedidoView> createState() => _NovoPedidoViewState();
}

class _NovoPedidoViewState extends State<_NovoPedidoView> {
  // Chaves de formulário por etapa — mantidas no State para persistir
  // entre rebuilds do Consumer.
  final _formKeyRemetente = GlobalKey<FormState>();
  final _formKeyDestinatario = GlobalKey<FormState>();
  final _formKeyCarga = GlobalKey<FormState>();

  // Referências às State classes dos steps para chamar confirmarEAvancar().
  final _remetenteKey = GlobalKey<RemetenteStepState>();
  final _destinatarioKey = GlobalKey<DestinatarioStepState>();
  final _cargaKey = GlobalKey<CargaStepState>();

  static const _titulos = [
    'Novo Pedido - Remetente',
    'Novo Pedido - Destinatário',
    'Novo Pedido - Dados da Carga',
    'Revisão do Pedido',
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<NovoPedidoController>().state;

    // Navegação acionada por mudança de estado — mesmo padrão da SplashPage.
    _handleStateNavigation(state);

    final edicao = switch (state) {
      NovoPedidoEmEdicao() => state,
      NovoPedidoSalvando(:final edicao) => edicao,
      NovoPedidoErro(:final edicao) => edicao,
      NovoPedidoCriado() => null,
    };
    if (edicao == null) return const SizedBox.shrink();

    final etapa = edicao.etapaAtual;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () {
            if (etapa == 0) {
              context.pop();
            } else {
              context.read<NovoPedidoController>().voltarEtapa();
            }
          },
        ),
        title: Text(
          _titulos[etapa],
          style: const TextStyle(
            color: AppColors.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: const [
          Icon(
            Icons.notifications_none_outlined,
            color: AppColors.onSurface,
          ),
          SizedBox(width: 8),
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: Text(
                'G',
                style: TextStyle(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Stepper sempre visível no topo do body.
            Container(
              color: AppColors.surfaceContainerLowest,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: NovoPedidoStepper(etapaAtual: etapa),
            ),
            Expanded(
              child: IndexedStack(
                index: etapa,
                children: [
                  RemetenteStep(
                    key: _remetenteKey,
                    formKey: _formKeyRemetente,
                    dadosIniciais: edicao.remetente,
                  ),
                  DestinatarioStep(
                    key: _destinatarioKey,
                    formKey: _formKeyDestinatario,
                    dadosIniciais: edicao.destinatario,
                  ),
                  CargaStep(
                    key: _cargaKey,
                    formKey: _formKeyCarga,
                    dadosIniciais: edicao.carga,
                  ),
                  RevisaoStep(edicao: edicao),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNav(
        etapa: etapa,
        isSalvando: state is NovoPedidoSalvando,
        onAnterior: () => context.read<NovoPedidoController>().voltarEtapa(),
        onProximo: _avancar,
        onCancelar: () => context.pop(),
      ),
    );
  }

  void _avancar() {
    final state = context.read<NovoPedidoController>().state;
    final etapa = switch (state) {
      NovoPedidoEmEdicao(:final etapaAtual) => etapaAtual,
      _ => -1,
    };

    switch (etapa) {
      case 0:
        _remetenteKey.currentState?.confirmarEAvancar();
      case 1:
        _destinatarioKey.currentState?.confirmarEAvancar();
      case 2:
        _cargaKey.currentState?.confirmarEAvancar();
      case 3:
        context.read<NovoPedidoController>().finalizarPedido();
    }
  }

  void _handleStateNavigation(NovoPedidoState state) {
    if (state is NovoPedidoCriado) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final resultado = state.resultado;
        if (resultado.pix != null) {
          context.pushReplacement(
            AppRoutes.pagamentoPix,
            extra: resultado.pix,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Pedido ${resultado.codigo} criado! '
                'Você receberá as instruções de pagamento por e-mail.',
              ),
            ),
          );
          context.go(AppRoutes.managerDashboard);
        }
      });
    } else if (state is NovoPedidoErro) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.failure.message)),
        );
      });
    }
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.etapa,
    required this.isSalvando,
    required this.onAnterior,
    required this.onProximo,
    required this.onCancelar,
  });

  final int etapa;
  final bool isSalvando;
  final VoidCallback onAnterior;
  final VoidCallback onProximo;
  final VoidCallback onCancelar;

  bool get _isRevisao => etapa == 3;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(top: BorderSide(color: AppColors.outlineVariant)),
      ),
      child: Row(
        children: [
          if (etapa == 0)
            TextButton(
              onPressed: onCancelar,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.onSurfaceVariant,
              ),
              child: const Text('Cancelar'),
            )
          else
            OutlinedButton.icon(
              onPressed: onAnterior,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.outlineVariant),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              icon: const Icon(Icons.arrow_back, size: 16),
              label: const Text('Anterior'),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: isSalvando ? null : onProximo,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isRevisao ? AppColors.primary : AppColors.primaryYellow,
                foregroundColor:
                    _isRevisao ? AppColors.onPrimary : AppColors.onSurface,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: isSalvando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isRevisao ? 'Finalizar Pedido' : 'Próximo Passo',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
