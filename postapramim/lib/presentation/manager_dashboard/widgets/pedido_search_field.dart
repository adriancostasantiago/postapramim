import 'package:flutter/material.dart';
import 'package:posta_pra_mim/core/theme/app_colors.dart';

/// Campo de busca do dashboard. Apenas reporta mudanças via callback
/// — o debounce e a lógica de filtro vivem no `PedidosController`.
class PedidoSearchField extends StatelessWidget {
  const PedidoSearchField({required this.onChanged, super.key});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Buscar por código, cliente ou CPF...',
        hintStyle: TextStyle(
          fontSize: 14,
          color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
        ),
        prefixIcon: Icon(
          Icons.search,
          size: 20,
          color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
        ),
        filled: true,
        fillColor: AppColors.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
