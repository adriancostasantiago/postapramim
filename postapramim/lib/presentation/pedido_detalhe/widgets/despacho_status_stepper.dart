import 'package:flutter/material.dart';
import 'package:posta_pra_mim/core/theme/app_colors.dart';
import 'package:posta_pra_mim/domain/entities/pedido_status.dart';

/// Stepper horizontal com as etapas do funil de despacho visível ao
/// destinatário. Mapeia [PedidoStatus] (domínio) para uma rotulagem
/// simplificada de 4 passos — a tradução visual fica aqui, fora do
/// domínio, mesmo padrão de `status_badge.dart`.
class DespachoStatusStepper extends StatelessWidget {
  const DespachoStatusStepper({required this.status, super.key});

  final PedidoStatus status;

  static const double _circleSize = 36;

  static const _steps = [
    (label: 'Solicitado', icon: Icons.description_outlined),
    (label: 'Aceito', icon: Icons.task_alt),
    (label: 'A caminho', icon: Icons.local_shipping_outlined),
    (label: 'Despachado', icon: Icons.inventory_2_outlined),
  ];

  /// Índice da etapa atual dentro do funil simplificado de 4 passos.
  int get _currentStepIndex => switch (status) {
        PedidoStatus.solicitado => 0,
        PedidoStatus.aprovado => 1,
        PedidoStatus.despachado || PedidoStatus.emTransito => 2,
        PedidoStatus.finalizado => 3,
        // Cancelado não faz parte do "caminho feliz" deste funil.
        PedidoStatus.cancelado => 0,
      };

  @override
  Widget build(BuildContext context) {
    final current = _currentStepIndex;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < _steps.length; i++) ...[
          _StepCircle(
            icon: _steps[i].icon,
            label: _steps[i].label,
            isDone: i < current,
            isActive: i == current,
          ),
          if (i != _steps.length - 1)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: _circleSize / 2 - 1),
                child: Container(
                  height: 2,
                  color: i < current
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

class _StepCircle extends StatelessWidget {
  const _StepCircle({
    required this.icon,
    required this.label,
    required this.isDone,
    required this.isActive,
  });

  final IconData icon;
  final String label;
  final bool isDone;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final isReached = isDone || isActive;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: DespachoStatusStepper._circleSize,
          height: DespachoStatusStepper._circleSize,
          child: Container(
            decoration: BoxDecoration(
              color: isReached ? AppColors.primary : AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: isReached ? AppColors.primary : AppColors.outlineVariant,
                width: isActive ? 2.5 : 1,
              ),
            ),
            child: Icon(
              isDone ? Icons.check : icon,
              size: 18,
              color: isReached ? AppColors.onPrimary : AppColors.outline,
            ),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 70,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color:
                  isReached ? AppColors.onSurface : AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
