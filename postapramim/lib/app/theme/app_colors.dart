import 'package:flutter/material.dart';

/// Paleta baseada no Design System do app: muito branco, amarelo
/// predominante (ação/destaque) e azul institucional (confiança/marca).
class AppColors {
  AppColors._();

  // Marca
  static const Color amarelo = Color(0xFFFEB003);
  static const Color amareloEscuro = Color(0xFFE6AC00);
  static const Color amareloClaro = Color(0xFFFDD365);
  static const Color azulInstitucional = Color(0xFF0B3D91);
  static const Color azulClaro = Color(0xFF4A73C4);

  // Neutros
  static const Color branco = Color(0xFFFFFFFF);
  static const Color cinzaFundo = Color(0xFFF7F7F9);
  static const Color cinzaBorda = Color(0xFFE3E4E8);
  static const Color cinzaTexto = Color(0xFF6B6F76);
  static const Color preto = Color(0xFF1A1A1A);

  // Status
  static const Color sucesso = Color(0xFF2E9E5B);
  static const Color alerta = Color(0xFFE0A000);
  static const Color erro = Color(0xFFD64545);
  static const Color info = Color(0xFF3B82F6);

  // Dark mode
  static const Color darkFundo = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkBorda = Color(0xFF2C2C2E);

  static Color statusColor(String status) => switch (status) {
    'concluida' => sucesso,
    'cancelada' => erro,
    'solicitacao_realizada' => cinzaTexto,
    'aguardando_coleta' => alerta,
    'em_transito' => azulInstitucional,
    _ => cinzaTexto,
  };
}
