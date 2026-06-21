import 'package:flutter/material.dart';
import 'package:posta_pra_mim/core/theme/app_colors.dart';

/// Card de métrica do topo do dashboard. Puramente apresentacional —
/// recebe valor já formatado, não calcula nada.
class MetricCard extends StatelessWidget {
  const MetricCard({
    required this.label,
    required this.value,
    this.valueColor,
    super.key,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: valueColor ?? AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
