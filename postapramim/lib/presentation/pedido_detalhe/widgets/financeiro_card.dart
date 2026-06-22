import 'package:flutter/material.dart';
import 'package:posta_pra_mim/core/theme/app_colors.dart';
import 'package:posta_pra_mim/core/utils/currency_formatter.dart';
import 'package:posta_pra_mim/core/utils/date_formatter.dart';
import 'package:posta_pra_mim/domain/entities/pedido_status.dart';
import 'package:posta_pra_mim/presentation/pedido_detalhe/widgets/pedido_detalhe_section.dart';

/// Conteúdo da seção "Financeiro": valor total do serviço e dados do
/// pagamento — ou aviso de pendência, via [FormaPagamento.isPago].
class FinanceiroCard extends StatelessWidget {
  const FinanceiroCard({
    required this.formaPagamento,
    required this.valor,
    required this.dataPagamento,
    super.key,
  });

  final FormaPagamento formaPagamento;
  final double valor;
  final DateTime? dataPagamento;

  @override
  Widget build(BuildContext context) {
    return PedidoDetalheSection(
      icon: Icons.account_balance_wallet_outlined,
      title: 'Financeiro',
      trailing: _PagamentoBadge(isPago: formaPagamento.isPago),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total do Serviço',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.format(valor),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.error,
            ),
          ),
          if (formaPagamento.isPago && dataPagamento != null) ...[
            const SizedBox(height: 6),
            Text(
              '${formaPagamento.label} em '
              '${DateFormatter.formatDateTime(dataPagamento!)}',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PagamentoBadge extends StatelessWidget {
  const _PagamentoBadge({required this.isPago});

  final bool isPago;

  @override
  Widget build(BuildContext context) {
    final color = isPago ? const Color(0xFF0A7D3F) : const Color(0xFFB8860B);
    final background =
        isPago ? const Color(0xFFE3F5EA) : const Color(0xFFFFF4D6);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isPago ? 'PAGO' : 'PENDENTE',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
