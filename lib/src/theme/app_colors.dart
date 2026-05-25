import 'package:flutter/material.dart';

/// Paleta de cores da aplicação (tema futurístico).
/// Centraliza tokens visuais para reuso e fácil manutenção.
class AppColors {
  const AppColors._();

  /// Tom mais profundo do fundo da aplicação.
  static const Color backgroundDeep = Color(0xFF05060F);

  /// Tom intermediário usado em gradientes de fundo.
  static const Color backgroundMid = Color(0xFF0B1023);

  /// Tom mais claro do fundo, usado para suavizar o gradiente.
  static const Color backgroundSoft = Color(0xFF11183A);

  /// Cor base para cards, overlays e superfícies elevadas.
  static const Color surface = Color(0xFF131A38);

  /// Contorno translúcido usado em bordas de superfícies.
  static const Color surfaceOutline = Color(0x3360E0FF);

  /// Realce sutil aplicado dentro de superfícies translúcidas.
  static const Color surfaceHighlight = Color(0x1A60E0FF);

  /// Accent primário usado em bordas, ícones e estados ativos.
  static const Color accentCyan = Color(0xFF00E5FF);

  /// Accent secundário usado em glows e composições de gradiente.
  static const Color accentMagenta = Color(0xFFB14BFF);

  /// Accent intermediário que conecta cyan e magenta nos gradientes.
  static const Color accentBlue = Color(0xFF4D7CFE);

  /// Cor de maior contraste para títulos e conteúdo principal.
  static const Color textPrimary = Color(0xFFEAF6FF);

  /// Cor de contraste médio para textos de apoio.
  static const Color textSecondary = Color(0xB3EAF6FF);

  /// Cor de menor contraste para legendas, hints e conteúdo auxiliar.
  static const Color textMuted = Color(0x80EAF6FF);

  /// Cor semântica para estados de sucesso.
  static const Color success = Color(0xFF22E0A1);

  /// Cor semântica para estados de alerta.
  static const Color warning = Color(0xFFFFC857);

  /// Cor semântica para estados de erro ou perigo.
  static const Color danger = Color(0xFFFF5C7A);

  /// Gradiente padrão de fundo da aplicação.
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [backgroundDeep, backgroundMid, backgroundSoft],
    stops: [0.0, 0.55, 1.0],
  );

  /// Gradiente de destaque usado em CTAs, indicadores e elementos ativos.
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentCyan, accentBlue, accentMagenta],
  );
}
