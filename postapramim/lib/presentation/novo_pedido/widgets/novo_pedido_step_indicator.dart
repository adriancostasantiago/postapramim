import 'package:flutter/material.dart';
import 'package:posta_pra_mim/core/theme/app_colors.dart';

/// Indicador de progresso com 4 etapas para o fluxo de novo pedido.
/// Círculos numerados conectados por linhas — etapas concluídas
/// exibem check, etapa atual exibe número destacado.
class NovoPedidoStepIndicator extends StatelessWidget {
  const NovoPedidoStepIndicator({required this.currentStep, super.key});

  /// Índice 0-based da etapa atual.
  final int currentStep;

  static const _steps = ['Remetente', 'Destinatário', 'Carga', 'Revisão'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < _steps.length; i++) ...[
          _StepDot(
            index: i,
            label: _steps[i],
            isDone: i < currentStep,
            isActive: i == currentStep,
          ),
          if (i != _steps.length - 1)
            Expanded(
              child: Container(
                height: 2,
                color: i < currentStep
                    ? AppColors.primary
                    : AppColors.outlineVariant,
              ),
            ),
        ],
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.index,
    required this.label,
    required this.isDone,
    required this.isActive,
  });

  final int index;
  final String label;
  final bool isDone;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final isReached = isDone || isActive;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isReached ? AppColors.primary : AppColors.surface,
              border: Border.all(
                color: isReached ? AppColors.primary : AppColors.outlineVariant,
                width: isActive ? 2.5 : 1.5,
              ),
            ),
            child: Center(
              child: isDone
                  ? const Icon(Icons.check,
                      size: 16, color: AppColors.onPrimary)
                  : Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isActive
                            ? AppColors.onPrimary
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isReached ? AppColors.primary : AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
