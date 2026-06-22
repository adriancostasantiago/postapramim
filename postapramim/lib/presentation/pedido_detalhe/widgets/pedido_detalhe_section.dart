import 'package:flutter/material.dart';
import 'package:posta_pra_mim/core/theme/app_colors.dart';

/// Seção com cabeçalho (ícone + título) e corpo em card branco.
/// Reutilizada por todas as seções da tela de detalhes do pedido —
/// evita duplicar `Container`/`BoxDecoration` em cada widget filho.
class PedidoDetalheSection extends StatelessWidget {
  const PedidoDetalheSection({
    required this.title,
    required this.child,
    this.icon,
    this.trailing,
    super.key,
  });

  final String title;
  final IconData? icon;
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 6),
            ],
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: child,
        ),
      ],
    );
  }
}
