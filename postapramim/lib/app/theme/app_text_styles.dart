import 'package:flutter/material.dart';
import 'package:postapramim/app/theme/app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const _fontFamily = 'Roboto';

  static const TextStyle titulo = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.preto,
  );

  static const TextStyle subtitulo = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.preto,
  );

  static const TextStyle corpo = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.preto,
  );

  static const TextStyle legenda = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.cinzaTexto,
  );

  static const TextStyle botao = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
}
