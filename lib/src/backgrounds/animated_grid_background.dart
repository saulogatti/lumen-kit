import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Configuração de um glow orb posicionado no fundo.
@immutable
class GlowOrbSpec {
  const GlowOrbSpec({
    required this.color,
    required this.size,
    this.top,
    this.right,
    this.bottom,
    this.left,
    this.opacity = 0.35,
  });

  final Color color;
  final double size;
  final double? top;
  final double? right;
  final double? bottom;
  final double? left;
  final double opacity;
}

/// Pano de fundo decorativo com grade futurística, gradiente e glow orbs.
/// Totalmente parametrizável — defaults reproduzem o visual original do tema.
class AnimatedGridBackground extends StatelessWidget {
  const AnimatedGridBackground({
    required this.child,
    super.key,
    this.gradient,
    this.orbs,
    this.gridSpacing = 56,
    this.gridColor,
    this.gridOpacity = 0.05,
    this.showGrid = true,
  });

  final Widget child;

  /// Gradiente de fundo. Default: [AppColors.backgroundGradient].
  final Gradient? gradient;

  /// Lista de orbs. Default: cyan no canto superior direito e magenta no
  /// inferior esquerdo (mesmo visual original).
  final List<GlowOrbSpec>? orbs;

  /// Distância em px entre linhas da grid.
  final double gridSpacing;

  /// Cor das linhas da grid. Default: [AppColors.accentCyan].
  final Color? gridColor;

  /// Opacidade das linhas da grid (0..1).
  final double gridOpacity;

  /// Se `false`, omite a grid e mantém só gradiente + orbs.
  final bool showGrid;

  static const List<GlowOrbSpec> _defaultOrbs = <GlowOrbSpec>[
    GlowOrbSpec(
      color: AppColors.accentCyan,
      size: 320,
      top: -120,
      right: -80,
    ),
    GlowOrbSpec(
      color: AppColors.accentMagenta,
      size: 360,
      bottom: -160,
      left: -100,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final List<GlowOrbSpec> orbList = orbs ?? _defaultOrbs;
    final Color effectiveGridColor = gridColor ?? AppColors.accentCyan;
    final Gradient effectiveGradient = gradient ?? AppColors.backgroundGradient;

    return DecoratedBox(
      decoration: BoxDecoration(gradient: effectiveGradient),
      child: Stack(
        children: <Widget>[
          if (showGrid)
            Positioned.fill(
              child: CustomPaint(
                painter: _GridPainter(
                  spacing: gridSpacing,
                  color: effectiveGridColor.withValues(alpha: gridOpacity),
                ),
              ),
            ),
          for (final GlowOrbSpec spec in orbList)
            Positioned(
              top: spec.top,
              right: spec.right,
              bottom: spec.bottom,
              left: spec.left,
              child: _GlowOrb(spec: spec),
            ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.spec});

  final GlowOrbSpec spec;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: spec.size,
        height: spec.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: <Color>[
              spec.color.withValues(alpha: spec.opacity),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter({required this.spacing, required this.color});

  final double spacing;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter old) =>
      old.spacing != spacing || old.color != color;
}
