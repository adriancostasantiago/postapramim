import 'package:flutter/material.dart';
import 'package:posta_pra_mim/core/theme/app_colors.dart';

/// App bar do dashboard: menu hambúrguer, título, notificações e
/// avatar do usuário. Extraída como `PreferredSizeWidget` próprio
/// para manter o `Scaffold` da página enxuto.
class ManagerDashboardAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const ManagerDashboardAppBar({
    required this.userInitial,
    this.onMenuTap,
    this.onNotificationsTap,
    this.onProfileTap,
    super.key,
  });

  final String userInitial;
  final VoidCallback? onMenuTap;
  final VoidCallback? onNotificationsTap;
  final VoidCallback? onProfileTap;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surfaceContainerLowest,
      elevation: 0,
      scrolledUnderElevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: AppColors.onSurface),
        onPressed: onMenuTap,
        tooltip: 'Menu',
      ),
      title: const Text(
        'Despacho Correios',
        style: TextStyle(
          color: AppColors.onSurface,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.notifications_none_outlined,
            color: AppColors.onSurface,
          ),
          onPressed: onNotificationsTap,
          tooltip: 'Notificações',
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: InkWell(
            onTap: onProfileTap,
            borderRadius: BorderRadius.circular(999),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: Text(
                userInitial,
                style: const TextStyle(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
