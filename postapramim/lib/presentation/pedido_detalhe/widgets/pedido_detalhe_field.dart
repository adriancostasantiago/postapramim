import 'package:flutter/material.dart';
import 'package:posta_pra_mim/core/theme/app_colors.dart';

/// Par label/valor reutilizado pelos cards de contato da tela de
/// detalhes (`DestinatarioCard`, `RemetenteCard`) — evita duplicar o
/// mesmo `Column` de texto em cada um.
class PedidoDetalheField extends StatelessWidget {
  const PedidoDetalheField(
      {required this.label, required this.value, super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}
