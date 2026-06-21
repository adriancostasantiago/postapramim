import 'package:flutter/material.dart';
import 'package:posta_pra_mim/core/theme/app_colors.dart';

/// Itens da navegação inferior do dashboard. Puramente apresentacional
/// — qual aba está selecionada é decidido por quem usa o widget.
class ManagerBottomNav extends StatelessWidget {
  const ManagerBottomNav({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    (icon: Icons.local_shipping_outlined, label: 'Rastrear'),
    (icon: Icons.history, label: 'Histórico'),
    (icon: Icons.add, label: 'Novo'),
    (icon: Icons.person_outline, label: 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(top: BorderSide(color: AppColors.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (var i = 0; i < _items.length; i++)
              _NavItem(
                icon: _items[i].icon,
                label: _items[i].label,
                isHighlighted: i == 2, // botão "Novo" se destaca
                isSelected: i == currentIndex,
                onTap: () => onTap(i),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isHighlighted,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isHighlighted;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : AppColors.onSurfaceVariant;

    if (isHighlighted) {
      return InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: AppColors.primaryYellow,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.onSurface),
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
