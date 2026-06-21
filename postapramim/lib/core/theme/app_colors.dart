import 'package:flutter/material.dart';

/// Design tokens — cores extraídas do design original do app.
///
/// Widgets nunca devem usar `Color(0x...)` diretamente; sempre via
/// `Theme.of(context).colorScheme` ou, para tokens fora do ColorScheme
/// padrão do Material, via [AppColors].
abstract final class AppColors {
  static const Color primaryYellow = Color(0xFFFFCC29);
  static const Color primary = Color(0xFF004480);
  static const Color primaryContainer = Color(0xFF005CA9);
  static const Color onPrimary = Color(0xFFFFFFFF);

  static const Color onSurface = Color(0xFF191C21);
  static const Color onSurfaceVariant = Color(0xFF414751);

  static const Color surface = Color(0xFFF9F9FF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);

  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);

  static const Color outline = Color(0xFF727782);
  static const Color outlineVariant = Color(0xFFC1C6D3);
}

/// Espaçamentos consistentes (tokens do design original em `spacing`).
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double gutter = 12;
  static const double lg = 24;
  static const double xl = 32;
  static const double containerMargin = 16;
}

/// Border radius consistentes.
abstract final class AppRadius {
  static const double sm = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double full = 9999;
}
