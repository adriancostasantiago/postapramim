import 'package:flutter/material.dart';
import 'package:postapramim/app/theme/app_colors.dart';
import 'package:postapramim/app/theme/app_text_styles.dart';

/// Barra de pesquisa reutilizada nos dashboards e nas listas de
/// solicitações/coletas — campo de texto arredondado com ícone de lupa e,
/// opcionalmente, um botão de filtro ao lado (usado quando a tela também
/// tem os chips de status/período de `FiltroSolicitacoesBar`).
class CampoBusca extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  final VoidCallback? onFiltrar;

  const CampoBusca({
    super.key,
    required this.hint,
    required this.onChanged,
    this.onFiltrar,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cinzaFundo,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.cinzaBorda),
            ),
            child: TextField(
              onChanged: onChanged,
              style: AppTextStyles.corpo.copyWith(fontSize: 14),
              decoration: InputDecoration(
                isDense: true,
                hintText: hint,
                hintStyle: AppTextStyles.corpo.copyWith(
                  fontSize: 13,
                  color: AppColors.cinzaTexto,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.cinzaTexto,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
        if (onFiltrar != null) ...[
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.cinzaFundo,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.cinzaBorda),
            ),
            child: IconButton(
              tooltip: 'Filtrar',
              icon: const Icon(Icons.tune, color: AppColors.cinzaTexto),
              onPressed: onFiltrar,
            ),
          ),
        ],
      ],
    );
  }
}
