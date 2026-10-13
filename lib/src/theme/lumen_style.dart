import 'dart:ui' show ImageFilter;

import 'package:material_ui/material_ui.dart';

import 'lumen_palette.dart';

/// Como as sombras dos widgets são desenhadas.
enum LumenShadowKind {
  /// Glow colorido no accent (visual neon original).
  glow,

  /// Sombra neutra e difusa, estilo elevation do Material.
  elevation,

  /// Sombra dura, sem blur, deslocada para baixo/direita.
  hard,

  /// Sem sombra.
  none,
}

/// Decoração do [AnimatedGridBackground].
enum LumenBackgroundKind {
  /// Grade de linhas.
  grid,

  /// Grade de pontos.
  dots,

  /// Só o gradiente de fundo.
  plain,
}

/// Tokens de efeito visual do kit: sombra, preenchimento, superfície, borda e
/// fundo. Independe das cores ([LumenPalette]) — qualquer estilo funciona com
/// qualquer paleta.
///
/// Use um preset ([neon], [flat], [glass], [soft], [brutal]) ou ajuste via
/// [copyWith]:
///
/// ```dart
/// AppTheme.fromPreset(LumenPreset.matrix, style: LumenStyle.flat);
/// ```
@immutable
class LumenStyle {
  /// Cria um estilo customizado. Prefira partir de um preset com [copyWith].
  const LumenStyle({
    this.shadow = LumenShadowKind.glow,
    this.shadowStrength = 1,
    this.gradients = true,
    this.surfaceOpacity = 1,
    this.blurSigma = 0,
    this.radiusScale = 1,
    this.borderScale = 1,
    this.borderOpacity = 1,
    this.background = LumenBackgroundKind.grid,
    this.orbs = true,
  });

  /// Tipo de sombra aplicado a todos os widgets.
  final LumenShadowKind shadow;

  /// Multiplicador da opacidade das sombras.
  final double shadowStrength;

  /// Se `false`, gradientes viram cor sólida (a primeira cor do gradiente).
  final bool gradients;

  /// Multiplicador da opacidade de superfícies (cards, dialogs, sheets…).
  final double surfaceOpacity;

  /// Blur aplicado atrás de superfícies (efeito vidro). `0` desliga.
  final double blurSigma;

  /// Multiplicador dos raios de canto. `0` deixa tudo quadrado.
  final double radiusScale;

  /// Multiplicador da espessura das bordas. `0` remove as bordas.
  final double borderScale;

  /// Multiplicador da opacidade das bordas.
  final double borderOpacity;

  /// Decoração do fundo.
  final LumenBackgroundKind background;

  /// Se `true`, desenha os glow orbs nos cantos do fundo.
  final bool orbs;

  /// Visual original: glow colorido, gradientes, grid e orbs.
  static const LumenStyle neon = LumenStyle();

  /// Sem glow nem gradiente, sombra neutra, fundo liso.
  static const LumenStyle flat = LumenStyle(
    shadow: LumenShadowKind.elevation,
    gradients: false,
    radiusScale: 0.6,
    borderOpacity: 0.6,
    background: LumenBackgroundKind.plain,
    orbs: false,
  );

  /// Vidro fosco: superfícies translúcidas com blur e glow suave.
  static const LumenStyle glass = LumenStyle(
    shadowStrength: 0.5,
    surfaceOpacity: 0.45,
    blurSigma: 18,
    radiusScale: 1.2,
    borderOpacity: 0.7,
    background: LumenBackgroundKind.plain,
  );

  /// Cantos bem arredondados, sombras difusas e sem bordas.
  static const LumenStyle soft = LumenStyle(
    shadow: LumenShadowKind.elevation,
    shadowStrength: 0.8,
    radiusScale: 1.6,
    borderScale: 0,
    background: LumenBackgroundKind.dots,
    orbs: false,
  );

  /// Cantos retos, borda grossa e sombra dura deslocada.
  static const LumenStyle brutal = LumenStyle(
    shadow: LumenShadowKind.hard,
    gradients: false,
    radiusScale: 0,
    borderScale: 2,
    borderOpacity: 3,
    background: LumenBackgroundKind.plain,
    orbs: false,
  );

  /// Todos os presets, na ordem de exibição.
  static const Map<String, LumenStyle> presets = <String, LumenStyle>{
    'neon': neon,
    'flat': flat,
    'glass': glass,
    'soft': soft,
    'brutal': brutal,
  };

  /// Estilo registrado no [Theme] mais próximo.
  static LumenStyle of(BuildContext context) => LumenThemeExt.of(context).style;

  /// Adapta sombras escritas no visual neon (glow) ao estilo atual.
  ///
  /// Glows pequenos (blur < 10, ex. pontos de status) são decorativos e só
  /// existem no estilo [LumenShadowKind.glow].
  List<BoxShadow>? shadows(List<BoxShadow>? glows) {
    if (glows == null || shadow == LumenShadowKind.none) {
      return null;
    }
    final out = <BoxShadow>[
      for (final BoxShadow s in glows)
        if (shadow == LumenShadowKind.glow || s.blurRadius >= 10) _adapt(s),
    ];
    return out.isEmpty ? null : out;
  }

  BoxShadow _adapt(BoxShadow s) {
    final double alpha = (s.color.a * shadowStrength).clamp(0.0, 1.0);
    switch (shadow) {
      case LumenShadowKind.glow:
        return BoxShadow(
          color: s.color.withValues(alpha: alpha),
          blurRadius: s.blurRadius,
          spreadRadius: s.spreadRadius,
          offset: s.offset,
        );
      case LumenShadowKind.elevation:
        return BoxShadow(
          color: const Color(0xFF000000)
              .withValues(alpha: (alpha * 0.8).clamp(0.08, 0.3)),
          blurRadius: s.blurRadius,
          spreadRadius: s.spreadRadius < 0 ? 0 : s.spreadRadius,
          offset: s.offset == Offset.zero
              ? Offset(0, s.blurRadius / 4)
              : s.offset,
        );
      case LumenShadowKind.hard:
        return BoxShadow(
          color: s.color.withValues(alpha: 1),
          offset: const Offset(4, 4),
        );
      case LumenShadowKind.none:
        return const BoxShadow(color: Color(0x00000000));
    }
  }

  /// Gradiente de preenchimento; vira cor sólida quando [gradients] é falso.
  Gradient? fill(Gradient? gradient) {
    if (gradient == null || gradients || gradient.colors.isEmpty) {
      return gradient;
    }
    final Color c = gradient.colors.first;
    return LinearGradient(colors: <Color>[c, c]);
  }

  /// Opacidade de uma superfície ajustada por [surfaceOpacity].
  double surfaceAlpha(double alpha) => (alpha * surfaceOpacity).clamp(0, 1);

  /// Raio de canto escalado por [radiusScale].
  BorderRadius radius(double r) => BorderRadius.circular(r * radiusScale);

  /// Borda uniforme com espessura e opacidade ajustadas ao estilo.
  Border borderAll({Color color = const Color(0xFF000000), double width = 1}) {
    if (borderScale == 0) {
      return const Border();
    }
    return Border.all(
      color: color.withValues(alpha: (color.a * borderOpacity).clamp(0.0, 1.0)),
      width: width * borderScale,
    );
  }

  /// Envolve uma superfície com blur de fundo quando [blurSigma] > 0.
  Widget frost({required Widget child, BorderRadius? borderRadius}) {
    if (blurSigma <= 0) {
      return child;
    }
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: child,
      ),
    );
  }

  /// Retorna um novo estilo preservando os tokens não informados.
  LumenStyle copyWith({
    LumenShadowKind? shadow,
    double? shadowStrength,
    bool? gradients,
    double? surfaceOpacity,
    double? blurSigma,
    double? radiusScale,
    double? borderScale,
    double? borderOpacity,
    LumenBackgroundKind? background,
    bool? orbs,
  }) => LumenStyle(
    shadow: shadow ?? this.shadow,
    shadowStrength: shadowStrength ?? this.shadowStrength,
    gradients: gradients ?? this.gradients,
    surfaceOpacity: surfaceOpacity ?? this.surfaceOpacity,
    blurSigma: blurSigma ?? this.blurSigma,
    radiusScale: radiusScale ?? this.radiusScale,
    borderScale: borderScale ?? this.borderScale,
    borderOpacity: borderOpacity ?? this.borderOpacity,
    background: background ?? this.background,
    orbs: orbs ?? this.orbs,
  );
}
