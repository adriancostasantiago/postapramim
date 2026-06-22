import 'package:flutter/material.dart';
import 'package:posta_pra_mim/core/theme/app_colors.dart';
import 'package:posta_pra_mim/domain/entities/pedido_detalhe.dart';
import 'package:posta_pra_mim/presentation/pedido_detalhe/widgets/pedido_detalhe_section.dart';

/// Conteúdo da seção "Informações da Carga": tipo, peso, dimensões e
/// indicador de fragilidade (a célula "Frágil" se destaca em vermelho
/// quando `true`).
class CargaInfoCard extends StatelessWidget {
  const CargaInfoCard({required this.carga, super.key});

  final InformacoesCarga carga;

  @override
  Widget build(BuildContext context) {
    return PedidoDetalheSection(
      icon: Icons.inventory_2_outlined,
      title: 'Informações da Carga',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _InfoCell(label: 'Tipo', value: carga.tipo)),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoCell(
                  label: 'Peso',
                  value:
                      '${carga.pesoKg.toStringAsFixed(1).replaceAll('.', ',')} kg',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _InfoCell(label: 'Dimen.', value: carga.dimensoesLabel),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoCell(
                  label: 'Frágil',
                  value: carga.fragil ? 'Sim' : 'Não',
                  isAlert: carga.fragil,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoCell extends StatelessWidget {
  const _InfoCell({
    required this.label,
    required this.value,
    this.isAlert = false,
  });

  final String label;
  final String value;
  final bool isAlert;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isAlert
            ? AppColors.errorContainer.withValues(alpha: 0.5)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isAlert
              ? AppColors.error.withValues(alpha: 0.3)
              : AppColors.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isAlert
                  ? AppColors.error
                  : AppColors.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isAlert ? AppColors.error : AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
