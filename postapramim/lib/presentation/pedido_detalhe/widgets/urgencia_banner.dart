import 'package:flutter/material.dart';
import 'package:posta_pra_mim/core/theme/app_colors.dart';

/// Banner de destaque para pedidos urgentes — exibido apenas quando
/// `pedido.prioridade == PedidoPrioridade.urgente` (ver
/// `domain/entities/pedido_status.dart`).
class UrgenciaBanner extends StatelessWidget {
  const UrgenciaBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.errorContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.priority_high, color: AppColors.error, size: 18),
          SizedBox(height: 2),
          Text(
            'URGENTE',
            style: TextStyle(
              color: AppColors.error,
              fontWeight: FontWeight.w800,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            'Sim',
            style: TextStyle(
              color: AppColors.error,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}