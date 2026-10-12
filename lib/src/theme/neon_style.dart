import 'dart:ui' show ImageFilter;

import 'package:material_ui/material_ui.dart';

import 'neon_palette.dart';

/// Como as sombras dos widgets são desenhadas.
enum NeonShadowKind {
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
enum NeonBackgroundKind {
  /// Grade de linhas.
  grid,

  /// Grade de pontos.
  dots,

  /// Só o gradiente de fundo.
  plain,
}

/// Tokens de efeito visual do kit: sombra, preenchimento, superfície, borda e
/// fundo. Independe das cores ([NeonPalette]) — qualquer estilo funciona com
/// qualquer paleta.
///
/// Use um preset ([neon], [flat], [glass], [soft], [brutal]) ou ajuste via
/// [copyWith]:
///
/// ```dart
/// AppTheme.fromPreset(NeonPreset.matrix, style: NeonStyle.flat);
/// ```
@immutable
class NeonStyle {
  /// Cria um estilo customizado. Prefira partir de um preset com [copyWith].
  const NeonStyle({
    this.shadow = NeonShadowKind.glow,
    this.shadowStrength = 1,
    this.gradients = true,
    this.surfaceOpacity = 1,
    this.blurSigma = 0,
    this.radiusScale = 1,
    this.borderScale = 1,
    this.borderOpacity = 1,
    this.background = NeonBackgroundKind.grid,
    this.orbs = true,
  });

  /// Tipo de sombra aplicado a todos os widgets.
  final NeonShadowKind shadow;

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
  final NeonBackgroundKind background;

  /// Se `true`, desenha os glow orbs nos cantos do fundo.
  final bool orbs;

  /// Visual original: glow colorido, gradientes, grid e orbs.
  static const NeonStyle neon = NeonStyle();

  /// Sem glow nem gradiente, sombra neutra, fundo liso.
  static const NeonStyle flat = NeonStyle(
    shadow: NeonShadowKind.elevation,
    gradients: false,
    radiusScale: 0.6,
    borderOpacity: 0.6,
    background: NeonBackgroundKind.plain,
    orbs: false,
  );

  /// Vidro fosco: superfícies translúcidas com blur e glow suave.
  static const NeonStyle glass = NeonStyle(
    shadowStrength: 0.5,
    surfaceOpacity: 0.45,
    blurSigma: 18,
    radiusScale: 1.2,
    borderOpacity: 0.7,
    background: NeonBackgroundKind.plain,
  );

  /// Cantos bem arredondados, sombras difusas e sem bordas.
  static const NeonStyle soft = NeonStyle(
    shadow: NeonShadowKind.elevation,
    shadowStrength: 0.8,
    radiusScale: 1.6,
    borderScale: 0,
    background: NeonBackgroundKind.dots,
    orbs: false,
  );

  /// Cantos retos, borda grossa e sombra dura deslocada.
  static const NeonStyle brutal = NeonStyle(
    shadow: NeonShadowKind.hard,
    gradients: false,
    radiusScale: 0,
    borderScale: 2,
    borderOpacity: 3,
    background: NeonBackgroundKind.plain,
    orbs: false,
  );

  /// Todos os presets, na ordem de exibição.
  static const Map<String, NeonStyle> presets = <String, NeonStyle>{
    'neon': neon,
    'flat': flat,
    'glass': glass,
    'soft': soft,
    'brutal': brutal,
  };

  /// Estilo registrado no [Theme] mais próximo.
  static NeonStyle of(BuildContext context) => NeonThemeExt.of(context).style;

  /// Adapta sombras escritas no visual neon (glow) ao estilo atual.
  ///
  /// Glows pequenos (blur < 10, ex. pontos de status) são decorativos e só
  /// existem no estilo [NeonShadowKind.glow].
  List<BoxShadow>? shadows(List<BoxShadow>? glows) {
    if (glows == null || shadow == NeonShadowKind.none) {
      return null;
    }
    final out = <BoxShadow>[
      for (final BoxShadow s in glows)
        if (shadow == NeonShadowKind.glow || s.blurRadius >= 10) _adapt(s),
    ];
    return out.isEmpty ? null : out;
  }

  BoxShadow _adapt(BoxShadow s) {
    final double alpha = (s.color.a * shadowStrength).clamp(0.0, 1.0);
    switch (shadow) {
      case NeonShadowKind.glow:
        return BoxShadow(
          color: s.color.withValues(alpha: alpha),
          blurRadius: s.blurRadius,
          spreadRadius: s.spreadRadius,
          offset: s.offset,
        );
      case NeonShadowKind.elevation:
        return BoxShadow(
          color: const Color(0xFF000000)
              .withValues(alpha: (alpha * 0.8).clamp(0.08, 0.3)),
          blurRadius: s.blurRadius,
          spreadRadius: s.spreadRadius < 0 ? 0 : s.spreadRadius,
          offset: s.offset == Offset.zero
              ? Offset(0, s.blurRadius / 4)
              : s.offset,
        );
      case NeonShadowKind.hard:
        return BoxShadow(
          color: s.color.withValues(alpha: 1),
          offset: const Offset(4, 4),
        );
      case NeonShadowKind.none:
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
  NeonStyle copyWith({
    NeonShadowKind? shadow,
    double? shadowStrength,
    bool? gradients,
    double? surfaceOpacity,
    double? blurSigma,
    double? radiusScale,
    double? borderScale,
    double? borderOpacity,
    NeonBackgroundKind? background,
    bool? orbs,
  }) => NeonStyle(
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
