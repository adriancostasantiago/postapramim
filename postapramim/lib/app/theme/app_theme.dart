import 'package:flutter/material.dart';
import 'package:postapramim/app/theme/app_colors.dart';
import 'package:postapramim/app/theme/app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.cinzaFundo,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.azulInstitucional,
      brightness: Brightness.light,
      primary: AppColors.azulInstitucional,
      secondary: AppColors.amarelo,
      surface: AppColors.branco,
      error: AppColors.erro,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.branco,
      foregroundColor: AppColors.preto,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AppTextStyles.subtitulo,
    ),
    cardTheme: CardThemeData(
      color: AppColors.branco,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.amarelo,
        foregroundColor: AppColors.preto,
        minimumSize: const Size.fromHeight(52),
        textStyle: AppTextStyles.botao,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.azulInstitucional,
        minimumSize: const Size.fromHeight(52),
        side: const BorderSide(color: AppColors.azulInstitucional),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.branco,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.cinzaBorda),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.cinzaBorda),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.azulInstitucional,
          width: 1.5,
        ),
      ),
    ),
    textTheme: const TextTheme(
      headlineSmall: AppTextStyles.titulo,
      titleMedium: AppTextStyles.subtitulo,
      bodyMedium: AppTextStyles.corpo,
      bodySmall: AppTextStyles.legenda,
      labelLarge: AppTextStyles.botao,
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkFundo,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.azulInstitucional,
      brightness: Brightness.dark,
      secondary: AppColors.amarelo,
      surface: AppColors.darkSurface,
      error: AppColors.erro,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      foregroundColor: AppColors.branco,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.amarelo,
        foregroundColor: AppColors.preto,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  );
}
