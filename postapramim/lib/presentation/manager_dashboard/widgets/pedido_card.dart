import 'package:flutter/material.dart';
import 'package:posta_pra_mim/core/theme/app_colors.dart';
import 'package:posta_pra_mim/core/utils/currency_formatter.dart';
import 'package:posta_pra_mim/domain/entities/pedido.dart';
import 'package:posta_pra_mim/domain/entities/pedido_status.dart';
import 'package:posta_pra_mim/presentation/manager_dashboard/widgets/status_badge.dart';

/// Card de pedido na lista "Pedidos Recentes". A ação principal do
/// rodapé varia conforme o status (Aprovar / Rastrear / Detalhes) —
/// decidido aqui via switch exaustivo sobre [PedidoStatus], nunca via
/// booleans soltos.
class PedidoCard extends StatelessWidget {
  const PedidoCard({
    required this.pedido,
    required this.onPrimaryAction,
    required this.onMoreOptions,
    super.key,
  });

  final Pedido pedido;
  final VoidCallback onPrimaryAction;
  final VoidCallback onMoreOptions;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PedidoCardHeader(pedido: pedido),
          const SizedBox(height: 12),
          _PedidoCardInfoRow(
            icon: Icons.location_on_outlined,
            text: pedido.endereco,
          ),
          const SizedBox(height: 6),
          _PedidoCardInfoRow(
            icon: Icons.payments_outlined,
            text: 'Valor do pagamento',
            trailing: Text(
              '${CurrencyFormatter.format(pedido.valor)} • ${pedido.formaPagamento.label}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: pedido.formaPagamento.isPago
                    ? const Color(0xFF0A7D3F)
                    : const Color(0xFFB8860B),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _PedidoCardActionRow(
            pedido: pedido,
            onPrimaryAction: onPrimaryAction,
            onMoreOptions: onMoreOptions,
          ),
        ],
      ),
    );
  }
}

class _PedidoCardHeader extends StatelessWidget {
  const _PedidoCardHeader({required this.pedido});

  final Pedido pedido;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pedido.codigo,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                pedido.clienteNome,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          alignment: WrapAlignment.end,
          children: [
            PriorityBadge(prioridade: pedido.prioridade),
            StatusBadge(status: pedido.status),
          ],
        ),
      ],
    );
  }
}

class _PedidoCardInfoRow extends StatelessWidget {
  const _PedidoCardInfoRow({
    required this.icon,
    required this.text,
    this.trailing,
  });

  final IconData icon;
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.onSurfaceVariant.withValues(alpha: 0.6)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _PedidoCardActionRow extends StatelessWidget {
  const _PedidoCardActionRow({
    required this.pedido,
    required this.onPrimaryAction,
    required this.onMoreOptions,
  });

  final Pedido pedido;
  final VoidCallback onPrimaryAction;
  final VoidCallback onMoreOptions;

  /// Decide o texto/ícone da ação primária conforme o status atual.
  ({String label, IconData icon, bool isFilled}) get _actionSpec {
    return switch (pedido.status) {
      PedidoStatus.solicitado => (
          label: 'Aprovar Pedido',
          icon: Icons.arrow_forward,
          isFilled: true,
        ),
      PedidoStatus.aprovado => (
          label: 'Despachar Pedido',
          icon: Icons.local_shipping_outlined,
          isFilled: true,
        ),
      PedidoStatus.despachado => (
          label: 'Rastrear Pacote',
          icon: Icons.print_outlined,
          isFilled: false,
        ),
      PedidoStatus.emTransito => (
          label: 'Detalhes',
          icon: Icons.chevron_right,
          isFilled: false,
        ),
      PedidoStatus.entregue => (
          label: 'Detalhes',
          icon: Icons.chevron_right,
          isFilled: false,
        ),
      PedidoStatus.cancelado => (
          label: 'Detalhes',
          icon: Icons.chevron_right,
          isFilled: false,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final spec = _actionSpec;

    return Row(
      children: [
        Expanded(
          child: spec.isFilled
              ? ElevatedButton(
                  onPressed: onPrimaryAction,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(spec.label),
                      const SizedBox(width: 6),
                      Icon(spec.icon, size: 16),
                    ],
                  ),
                )
              : OutlinedButton(
                  onPressed: onPrimaryAction,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: AppColors.outlineVariant),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        spec.label,
                        style: const TextStyle(color: AppColors.onSurface),
                      ),
                      const SizedBox(width: 6),
                      Icon(spec.icon, size: 16, color: AppColors.onSurface),
                    ],
                  ),
                ),
        ),
        if (pedido.status == PedidoStatus.solicitado) ...[
          const SizedBox(width: 8),
          IconButton(
            onPressed: onMoreOptions,
            tooltip: 'Mais opções',
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: AppColors.outlineVariant),
              ),
            ),
            icon: const Icon(Icons.more_vert, size: 18),
          ),
        ],
      ],
    );
  }
}
