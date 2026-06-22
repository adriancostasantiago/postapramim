import 'package:flutter/material.dart';
import 'package:posta_pra_mim/core/theme/app_colors.dart';
import 'widgets/carga_step.dart';
import 'widgets/destinatario_step.dart';
import 'widgets/novo_pedido_step_indicator.dart';
import 'widgets/pix_pagamento_page.dart';
import 'widgets/remetente_step.dart';
import 'widgets/revisao_step.dart';

/// Fluxo de criação de novo pedido em 4 etapas:
/// 0 — Remetente
/// 1 — Destinatário
/// 2 — Carga
/// 3 — Revisão
///
/// A navegação entre etapas é gerida localmente por [_currentStep].
/// Os dados de cada etapa são mantidos em objetos `*StepData` que
/// sobrevivem à troca de passo (não são recriados no build).
class NovoPedidoPage extends StatefulWidget {
  const NovoPedidoPage({super.key});

  @override
  State<NovoPedidoPage> createState() => _NovoPedidoPageState();
}

class _NovoPedidoPageState extends State<NovoPedidoPage> {
  int _currentStep = 0;

  // Dados das etapas — criados uma vez e passados para os widgets filhos.
  final _remetenteData = RemetenteStepData();
  final _destinatarioData = DestinatarioStepData();
  final _cargaData = CargaStepData();

  // Chave global do revisão step para acessar o pagamento selecionado.
  final _revisaoKey = GlobalKey<RevisaoStepState>();

  // Controla o scroll para o topo ao trocar de etapa.
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _remetenteData.dispose();
    _destinatarioData.dispose();
    _cargaData.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _goToNext() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
      _scrollToTop();
    } else {
      _finalizarPedido();
    }
  }

  void _goToPrevious() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _scrollToTop();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _finalizarPedido() {
    final pagamento = _revisaoKey.currentState?.selectedPagamento;

    if (pagamento == FormaPagamentoNovo.pix) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PixPagamentoPage(
            codigoPedido: 'BR992831',
            valor: 45.90,
            onConfirmar: () {
              // Volta ao dashboard fechando toda a pilha de navegação
              Navigator.of(context).popUntil((route) => route.isFirst);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pedido criado! Pagamento confirmado.'),
                ),
              );
            },
          ),
        ),
      );
    } else {
      Navigator.of(context).popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pedido criado com sucesso!')),
      );
    }
  }

  String get _nextLabel => switch (_currentStep) {
        0 => 'Próximo Passo →',
        1 => 'Próximo Passo →',
        2 => 'Revisar Pedido →',
        _ => 'Finalizar Pedido →',
      };

  String get _appBarTitle => switch (_currentStep) {
        0 => 'Novo Pedido - Remetente',
        1 => 'Novo Pedido - Destinatário',
        2 => 'Novo Pedido - Dados da Carga',
        _ => 'Revisão do Pedido',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: _goToPrevious,
          tooltip: _currentStep == 0 ? 'Cancelar' : 'Anterior',
        ),
        title: Text(
          _appBarTitle,
          style: const TextStyle(
            color: AppColors.onSurface,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          if (_currentStep == 3)
            IconButton(
              icon: const Icon(Icons.help_outline, color: AppColors.onSurface),
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ajuda em breve.')),
              ),
              tooltip: 'Ajuda',
            ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: const Text(
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
            // Step indicator fixo no topo
            Container(
              color: AppColors.surfaceContainerLowest,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: NovoPedidoStepIndicator(currentStep: _currentStep),
            ),
            const Divider(height: 1),

            // Conteúdo scrollável
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: KeyedSubtree(
                    key: ValueKey(_currentStep),
                    child: _buildCurrentStep(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom action bar
      bottomNavigationBar: _BottomActionBar(
        currentStep: _currentStep,
        nextLabel: _nextLabel,
        onNext: _goToNext,
        onPrevious: _currentStep > 0 ? _goToPrevious : null,
        onCancel: _currentStep == 0
            ? () => Navigator.of(context).maybePop()
            : null,
      ),
    );
  }

  Widget _buildCurrentStep() {
    return switch (_currentStep) {
      0 => RemetenteStep(data: _remetenteData),
      1 => DestinatarioStep(data: _destinatarioData),
      2 => CargaStep(data: _cargaData),
      _ => RevisaoStep(
          key: _revisaoKey,
          remetente: _remetenteData,
          destinatario: _destinatarioData,
          carga: _cargaData,
        ),
    };
  }
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.currentStep,
    required this.nextLabel,
    required this.onNext,
    this.onPrevious,
    this.onCancel,
  });

  final int currentStep;
  final String nextLabel;
  final VoidCallback onNext;
  final VoidCallback? onPrevious;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(top: BorderSide(color: AppColors.outlineVariant)),
      ),
      child: Row(
        children: [
          // Botão esquerdo: "Cancelar" no passo 0, "← Anterior" nos demais
          if (onCancel != null)
            TextButton(
              onPressed: onCancel,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: AppColors.onSurfaceVariant),
              ),
            )
          else if (onPrevious != null)
            OutlinedButton(
              onPressed: onPrevious,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                side: BorderSide(color: AppColors.outlineVariant),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '← Anterior',
                style: TextStyle(color: AppColors.onSurface),
              ),
            ),

          const SizedBox(width: 12),

          Expanded(
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: currentStep == 3
                    ? AppColors.primaryYellow
                    : AppColors.primary,
                foregroundColor: currentStep == 3
                    ? AppColors.onSurface
                    : AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                nextLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
