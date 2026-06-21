import 'package:flutter/material.dart';
import 'package:posta_pra_mim/domain/entities/pedido_status.dart';

/// Mapeia [PedidoStatus] para cores de apresentação. Mantido na
/// camada de UI — o domínio (`pedido_status.dart`) não conhece Color.
class StatusBadge extends StatelessWidget {
  const StatusBadge({required this.status, super.key});

  final PedidoStatus status;

  ({Color background, Color foreground}) get _colors => switch (status) {
        PedidoStatus.solicitado => (
            background: const Color(0xFFFFF4D6),
            foreground: const Color(0xFFB8860B),
          ),
        PedidoStatus.aprovado => (
            background: const Color(0xFFE3F5EA),
            foreground: const Color(0xFF0A7D3F),
          ),
        PedidoStatus.despachado => (
            background: const Color(0xFFEDEAFB),
            foreground: const Color(0xFF6B5FD6),
          ),
        PedidoStatus.emTransito => (
            background: const Color(0xFFE3EEFB),
            foreground: const Color(0xFF0A5FAC),
          ),
        PedidoStatus.entregue => (
            background: const Color(0xFFE3F5EA),
            foreground: const Color(0xFF0A7D3F),
          ),
        PedidoStatus.cancelado => (
            background: const Color(0xFFFFDAD6),
            foreground: const Color(0xFFBA1A1A),
          ),
      };

  @override
  Widget build(BuildContext context) {
    final colors = _colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: colors.foreground,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Badge de prioridade "Urgente" (só exibido quando aplicável).
class PriorityBadge extends StatelessWidget {
  const PriorityBadge({required this.prioridade, super.key});

  final PedidoPrioridade prioridade;

  @override
  Widget build(BuildContext context) {
    if (prioridade != PedidoPrioridade.urgente) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFDAD6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.priority_high, size: 12, color: Color(0xFFBA1A1A)),
          SizedBox(width: 2),
          Text(
            'URGENTE',
            style: TextStyle(
              color: Color(0xFFBA1A1A),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
