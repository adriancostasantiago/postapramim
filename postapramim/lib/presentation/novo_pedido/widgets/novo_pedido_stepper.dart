import 'package:flutter/material.dart';
import 'package:posta_pra_mim/core/theme/app_colors.dart';

/// Stepper horizontal no topo das telas do novo pedido:
/// Remetente → Destinatário → Carga → Revisão.
class NovoPedidoStepper extends StatelessWidget {
  const NovoPedidoStepper({required this.etapaAtual, super.key});

  final int etapaAtual;

  static const _etapas = ['Remetente', 'Destinatário', 'Carga', 'Revisão'];

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < _etapas.length; i++) ...[
          _StepNode(
            numero: i + 1,
            label: _etapas[i],
            isDone: i < etapaAtual,
            isActive: i == etapaAtual,
          ),
          if (i < _etapas.length - 1)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Container(
                  height: 2,
                  color: i < etapaAtual
                      ? AppColors.primary
                      : AppColors.outlineVariant,
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _StepNode extends StatelessWidget {
  const _StepNode({
    required this.numero,
    required this.label,
    required this.isDone,
    required this.isActive,
  });

  final int numero;
  final String label;
  final bool isDone;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final isReached = isDone || isActive;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isReached ? AppColors.primary : AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: isReached ? AppColors.primary : AppColors.outlineVariant,
              width: isActive ? 2.5 : 1.5,
            ),
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, size: 18, color: AppColors.onPrimary)
                : Text(
                    '$numero',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isActive
                          ? AppColors.onPrimary
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 68,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isReached ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
