import 'dart:ui' show ImageFilter;

import 'package:material_ui/material_ui.dart';

import 'lumen_palette.dart';

/// How widget shadows are drawn.
enum LumenShadowKind {
  /// Colorful glow on the accent (original neon look).
  glow,

  /// Neutral and diffuse shadow, Material elevation style.
  elevation,

  /// Hard shadow, no blur, shifted to the bottom/right.
  hard,

  /// No shade.
  none,
}

/// [LumenAnimatedGridBackground] decoration.
enum LumenBackgroundKind {
  /// Line grid.
  grid,

  /// Dot grid.
  dots,

  /// Just the background gradient.
  plain,
}

/// Kit visual effect tokens: shadow, fill, surface, border and background.
///
/// Independent of colors ([LumenPalette]) — any style works with any palette.
/// Use a preset ([neon], [flat], [glass], [soft], [brutal]) or adjust via
/// [copyWith]:
/// ```dart
/// AppTheme.fromPreset(LumenPreset.matrix, style: LumenStyle.flat);
/// ```
@immutable
class LumenStyle {
  /// Creates a custom style.
  ///
  /// Prefer to start from a preset with [copyWith].
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

  /// Shadow type applied to all widgets.
  final LumenShadowKind shadow;

  /// Shadow opacity multiplier.
  final double shadowStrength;

  /// If `false`, gradients become solid color (the first color of the gradient).
  final bool gradients;

  /// Surface opacity multiplier (cards, dialogs, sheets…).
  final double surfaceOpacity;

  /// Blur applied behind surfaces (glass effect).
  ///
  /// `0` turns off.
  final double blurSigma;

  /// Corner radius multiplier.
  ///
  /// `0` makes everything square.
  final double radiusScale;

  /// Edge thickness multiplier.
  ///
  /// `0` removes borders.
  final double borderScale;

  /// Edge opacity multiplier.
  final double borderOpacity;

  /// Background decoration.
  final LumenBackgroundKind background;

  /// Whether to draw the glow orbs in the bottom corners.
  final bool orbs;

  /// Original look: colorful glow, gradients, grid and orbs.
  static const LumenStyle neon = LumenStyle();

  /// No glow or gradient, neutral shade, smooth background.
  static const LumenStyle flat = LumenStyle(
    shadow: LumenShadowKind.elevation,
    gradients: false,
    radiusScale: 0.6,
    borderOpacity: 0.6,
    background: LumenBackgroundKind.plain,
    orbs: false,
  );

  /// Frosted glass: translucent surfaces with blur and soft glow.
  static const LumenStyle glass = LumenStyle(
    shadowStrength: 0.5,
    surfaceOpacity: 0.45,
    blurSigma: 18,
    radiusScale: 1.2,
    borderOpacity: 0.7,
    background: LumenBackgroundKind.plain,
  );

  /// Well-rounded corners, diffuse shadows and no edges.
  static const LumenStyle soft = LumenStyle(
    shadow: LumenShadowKind.elevation,
    shadowStrength: 0.8,
    radiusScale: 1.6,
    borderScale: 0,
    background: LumenBackgroundKind.dots,
    orbs: false,
  );

  /// Straight corners, thick border and offset hard shadow.
  static const LumenStyle brutal = LumenStyle(
    shadow: LumenShadowKind.hard,
    gradients: false,
    radiusScale: 0,
    borderScale: 2,
    borderOpacity: 3,
    background: LumenBackgroundKind.plain,
    orbs: false,
  );

  /// All presets, in displayed order.
  static const Map<String, LumenStyle> presets = <String, LumenStyle>{
    'neon': neon,
    'flat': flat,
    'glass': glass,
    'soft': soft,
    'brutal': brutal,
  };

  /// Style registered with the nearest [Theme].
  static LumenStyle of(BuildContext context) => LumenThemeExt.of(context).style;

  /// Adapts shadows written in a neon (glow) look to the current style.
  /// Small glows (blur < 10, e.g. status points) are decorative and only exist in
  /// style [LumenShadowKind.glow].
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
    final Color glow = s.color.scaleAlpha(shadowStrength);
    switch (shadow) {
      case LumenShadowKind.glow:
        return BoxShadow(
          color: glow,
          blurRadius: s.blurRadius,
          spreadRadius: s.spreadRadius,
          offset: s.offset,
        );
      case LumenShadowKind.elevation:
        return BoxShadow(
          color: const Color(0xFF000000)
              .withValues(alpha: (glow.a * 0.8).clamp(0.08, 0.3)),
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

  /// Fill gradient; turns solid color when [gradients] is false.
  Gradient? fill(Gradient? gradient) {
    if (gradient == null || gradients || gradient.colors.isEmpty) {
      return gradient;
    }
    final Color c = gradient.colors.first;
    return LinearGradient(colors: <Color>[c, c]);
  }

  /// Opacity of a surface adjusted by [surfaceOpacity].
  double surfaceAlpha(double alpha) => (alpha * surfaceOpacity).clamp(0, 1);

  /// Corner radius scaled by [radiusScale].
  BorderRadius radius(double r) => BorderRadius.circular(r * radiusScale);

  /// Uniform border with style-adjusted thickness and opacity.
  Border borderAll({Color color = const Color(0xFF000000), double width = 1}) {
    if (borderScale == 0) {
      return const Border();
    }
    return Border.all(
      color: color.scaleAlpha(borderOpacity),
      width: width * borderScale,
    );
  }

  /// Wraps a surface with background blur when [blurSigma] > 0.
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

  /// Returns a new style preserving unspecified tokens.
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
