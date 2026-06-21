import 'package:flutter/material.dart';
import 'package:posta_pra_mim/core/theme/app_colors.dart';

/// Tema único do app. Widgets consomem estilo via
/// `Theme.of(context).colorScheme` / `Theme.of(context).textTheme`,
/// nunca via `TextStyle` inline com valores crus.
abstract final class AppTheme {
  static ThemeData get light {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimary,
      secondary: AppColors.primaryYellow,
      onSecondary: AppColors.onSurface,
      secondaryContainer: AppColors.primaryYellow,
      onSecondaryContainer: AppColors.onSurface,
      tertiary: AppColors.onSurfaceVariant,
      onTertiary: AppColors.onPrimary,
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.error,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      surfaceContainerLowest: AppColors.surfaceContainerLowest,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      inverseSurface: Color(0xFF2E3036),
      onInverseSurface: Color(0xFFEFF0F7),
      inversePrimary: Color(0xFFA5C8FF),
      shadow: Colors.black,
      scrim: Colors.black,
    );

    final textTheme = TextTheme(
      headlineMedium: const TextStyle(
        fontSize: 24,
        height: 32 / 24,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
      bodyLarge: const TextStyle(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w400,
      ),
      titleMedium: const TextStyle(
        fontSize: 18,
        height: 24 / 18,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: const TextStyle(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.primaryYellow,
      textTheme: textTheme,
      fontFamily: 'Inter',
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle: textTheme.titleMedium,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: textTheme.titleMedium,
        ),
      ),
    );
  }
}
