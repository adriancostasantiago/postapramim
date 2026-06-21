import 'package:flutter/material.dart';
import 'package:posta_pra_mim/core/theme/app_colors.dart';
import 'package:posta_pra_mim/core/utils/currency_formatter.dart';
import 'package:posta_pra_mim/domain/entities/pedido.dart';
import 'package:posta_pra_mim/presentation/manager_dashboard/widgets/metric_card.dart';

/// Grade de métricas do topo do dashboard: 2x2 de cards + card de
/// valor total. Recebe [PedidosResumo] já carregado — não calcula
/// nem busca dados.
class MetricsGrid extends StatelessWidget {
  const MetricsGrid({required this.resumo, super.key});

  final PedidosResumo resumo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: MetricCard(
                label: 'Total Pedidos',
                value: resumo.totalPedidos.toString(),
                valueColor: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricCard(
                label: 'Solicitados',
                value: resumo.solicitados.toString(),
                valueColor: const Color(0xFFB8860B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: MetricCard(
                label: 'Aceitos',
                value: resumo.aceitos > 0 ? resumo.aceitos.toString() : '—',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricCard(
                label: 'Despachados',
                value: resumo.despachados.toString(),
                valueColor: const Color(0xFF0A7D3F),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Valor Total',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                CurrencyFormatter.formatCompact(resumo.valorTotal),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFBA1A1A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
