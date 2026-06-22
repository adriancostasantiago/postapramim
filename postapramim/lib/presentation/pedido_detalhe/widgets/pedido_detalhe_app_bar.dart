import 'package:flutter/material.dart';
import 'package:posta_pra_mim/core/theme/app_colors.dart';

/// App bar da tela de detalhes do pedido: código, badge de urgência
/// opcional e ação de mais opções. Extraída como `PreferredSizeWidget`
/// próprio — mesmo padrão de `manager_dashboard_app_bar.dart`.
class PedidoDetalheAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const PedidoDetalheAppBar({
    required this.codigo,
    required this.isUrgente,
    this.onMoreOptions,
    super.key,
  });

  final String codigo;
  final bool isUrgente;
  final VoidCallback? onMoreOptions;

  @override
  Size get preferredSize => Size.fromHeight(isUrgente ? 72 : 56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surfaceContainerLowest,
      elevation: 0,
      scrolledUnderElevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
        onPressed: () => Navigator.of(context).maybePop(),
        tooltip: 'Voltar',
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Pedido #$codigo',
            style: const TextStyle(
              color: AppColors.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (isUrgente)
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: _UrgenteTag(),
            ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: AppColors.onSurface),
          onPressed: onMoreOptions,
          tooltip: 'Mais opções',
        ),
      ],
    );
  }
}

class _UrgenteTag extends StatelessWidget {
  const _UrgenteTag();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: AppColors.error,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        const Text(
          'PEDIDO URGENTE',
          style: TextStyle(
            color: AppColors.error,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
