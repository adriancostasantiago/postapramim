import 'package:flutter/material.dart';
import 'package:postapramim/app/theme/app_colors.dart';
import 'package:postapramim/app/theme/app_text_styles.dart';
import 'package:postapramim/shared/widgets/confirm_dialog.dart';

/// Diálogo de confirmação no Design System do app: ícone circular colorido,
/// título, mensagem e dois botões (cancelar em outline + ação preenchida
/// na cor do contexto). Usado antes de qualquer ação irreversível
/// (cancelar, avançar status, aceitar solicitação, etc.) para evitar
/// toques acidentais.
///
/// Retorna `true` se o usuário confirmou, `false` caso contrário (inclui
/// fechar o diálogo tocando fora dele).
Future<bool> showAppConfirmDialog(
  BuildContext context, {
  required IconData icone,
  required Color cor,
  required String titulo,
  required String mensagem,
  String labelConfirmar = 'Confirmar',
  String labelCancelar = 'Voltar',
}) async {
  final confirmou = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: .45),
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        decoration: BoxDecoration(
          color: AppColors.branco,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: cor.withValues(alpha: .12),
              child: Icon(icone, color: cor, size: 30),
            ),
            const SizedBox(height: 18),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: AppTextStyles.subtitulo.copyWith(fontSize: 17),
            ),
            const SizedBox(height: 8),
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: AppTextStyles.corpo.copyWith(
                fontSize: 14,
                color: AppColors.cinzaTexto,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.cinzaTexto,
                      side: const BorderSide(color: AppColors.cinzaBorda),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      labelCancelar,
                      style: AppTextStyles.botao.copyWith(fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cor,
                      foregroundColor: AppColors.branco,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(
                      labelConfirmar,
                      style: AppTextStyles.botao.copyWith(
                        fontSize: 14,
                        color: AppColors.branco,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return confirmou == true;
}
