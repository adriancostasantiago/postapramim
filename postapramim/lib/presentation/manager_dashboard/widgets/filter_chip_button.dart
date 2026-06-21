import 'package:flutter/material.dart';
import 'package:posta_pra_mim/core/theme/app_colors.dart';

/// Chip de filtro estilizado (outline, ícone + texto). Puramente
/// apresentacional — recebe callback de toque.
class FilterChipButton extends StatelessWidget {
  const FilterChipButton({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
