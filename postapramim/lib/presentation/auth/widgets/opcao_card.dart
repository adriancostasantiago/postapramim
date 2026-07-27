import 'package:flutter/material.dart';
import 'package:postapramim/app/theme/app_colors.dart';
import 'package:postapramim/app/theme/app_text_styles.dart';

class OpcaoCard extends StatelessWidget {
  final String icone;
  final Color corFundoIcone;
  final String titulo;
  final String subtitulo;
  final String botaoLabel;
  final bool botaoPreenchido;
  final VoidCallback onPressed;

  const OpcaoCard({
    super.key,
    required this.icone,
    required this.corFundoIcone,
    required this.titulo,
    required this.subtitulo,
    required this.botaoLabel,
    required this.botaoPreenchido,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cinzaFundo,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cinzaBorda),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: corFundoIcone,
                child: Image.asset(icone, fit: BoxFit.contain),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: AppTextStyles.subtitulo.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(subtitulo, style: AppTextStyles.legenda),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: botaoPreenchido
                ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.azulInstitucional,
                      foregroundColor: AppColors.branco,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: onPressed,
                    child: _LabelComSeta(label: botaoLabel),
                  )
                : OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.azulInstitucional,
                      side: const BorderSide(
                        color: AppColors.azulInstitucional,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: onPressed,
                    child: _LabelComSeta(label: botaoLabel),
                  ),
          ),
        ],
      ),
    );
  }
}

class _LabelComSeta extends StatelessWidget {
  final String label;

  const _LabelComSeta({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label, style: AppTextStyles.botao),
        const SizedBox(width: 6),
        const Icon(Icons.chevron_right, size: 20),
      ],
    );
  }
}
