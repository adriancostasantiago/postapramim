import 'package:flutter/material.dart';
import 'package:posta_pra_mim/core/theme/app_colors.dart';
import 'package:posta_pra_mim/domain/entities/pedido_detalhe.dart';

/// Linha de documento anexado (nota fiscal, declaração de conteúdo
/// etc). O download em si é responsabilidade de quem usa o widget —
/// aqui só reportamos o toque via callback.
class DocumentoListItem extends StatelessWidget {
  const DocumentoListItem({
    required this.documento,
    required this.onDownload,
    super.key,
  });

  final PedidoDocumento documento;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.description_outlined,
            size: 20,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  documento.titulo,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  documento.nomeArquivo,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDownload,
            tooltip: 'Baixar ${documento.titulo}',
            icon: const Icon(Icons.download_outlined),
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
