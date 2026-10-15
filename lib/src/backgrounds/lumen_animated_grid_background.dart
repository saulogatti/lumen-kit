import 'package:material_ui/material_ui.dart';

import '../theme/lumen_palette.dart';
import '../theme/lumen_style.dart';

/// Old name of [LumenAnimatedGridBackground].
@Deprecated('Use LumenAnimatedGridBackground')
typedef AnimatedGridBackground = LumenAnimatedGridBackground;

/// Old name of [LumenGlowOrbSpec].
@Deprecated('Use LumenGlowOrbSpec')
typedef GlowOrbSpec = LumenGlowOrbSpec;

/// Decorative backdrop with futuristic grid, gradient and glow orbs.
///
/// Fully configurable — defaults reproduce the original look of the theme.
class LumenAnimatedGridBackground extends StatelessWidget {
  /// Creates a decorative background to surround [child].
  /// When it doesn't receive customizations, it uses the kit's default gradient
  /// and orbs.
  const LumenAnimatedGridBackground({
    required this.child,
    super.key,
    this.gradient,
    this.orbs,
    this.gridSpacing = 56,
    this.gridColor,
    this.gridOpacity = 0.05,
    this.showGrid = true,
  });

  /// Content rendered above the gradient, grid and orbs.
  final Widget child;

  /// Background gradient.
  ///
  /// Default: `palette.backgroundGradient`.
  final Gradient? gradient;

  /// Orb list.
  ///
  /// Default: `palette.primary` in the upper right corner and `palette.secondary`
  /// at bottom left, or none when [LumenStyle.orbs] is `false`.
  final List<LumenGlowOrbSpec>? orbs;

  /// Distance in px between grid lines.
  final double gridSpacing;

  /// Color of the grid lines.
  ///
  /// Default: `palette.primary`.
  final Color? gridColor;

  /// Opacity of the grid lines (0..1).
  final double gridOpacity;

  /// If `false`, omits the grid/points and only keeps gradient + orbs.
  ///
  /// The type of decoration (grid, dots or none) comes from
  /// [LumenStyle.background].
  final bool showGrid;

  @override
  Widget build(BuildContext context) {
    final LumenPalette p = LumenThemeExt.of(context).palette;
    final LumenStyle style = LumenStyle.of(context);
    final List<LumenGlowOrbSpec> orbList =
        orbs ?? (style.orbs ? _defaultOrbs(p) : const <LumenGlowOrbSpec>[]);
    final bool drawPattern =
        showGrid && style.background != LumenBackgroundKind.plain;
    final Color effectiveGridColor = gridColor ?? p.primary;
    final Gradient effectiveGradient = gradient ?? p.backgroundGradient;

    return DecoratedBox(
      decoration: BoxDecoration(gradient: effectiveGradient),
      child: Stack(
        children: <Widget>[
          if (drawPattern)
            Positioned.fill(
              child: CustomPaint(
                painter: _GridPainter(
                  spacing: gridSpacing,
                  color: effectiveGridColor.withValues(alpha: gridOpacity),
                  dots: style.background == LumenBackgroundKind.dots,
                ),
              ),
            ),
          for (final LumenGlowOrbSpec spec in orbList)
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

  static List<LumenGlowOrbSpec> _defaultOrbs(
    LumenPalette p,
  ) => <LumenGlowOrbSpec>[
    LumenGlowOrbSpec(color: p.primary, size: 320, top: -120, right: -80),
    LumenGlowOrbSpec(color: p.secondary, size: 360, bottom: -160, left: -100),
  ];
}

/// Configuration of a glow orb positioned in the background.
@immutable
class LumenGlowOrbSpec {
  /// Creates a glow orb configuration.
  /// Position fields follow the same semantics as [Positioned].
  const LumenGlowOrbSpec({
    required this.color,
    required this.size,
    this.top,
    this.right,
    this.bottom,
    this.left,
    this.opacity = 0.35,
  });

  /// Base color used at the center of the radial gradient.
  final Color color;

  /// Orb diameter in logical pixels.
  final double size;

  /// Optional distance to the top of the [Stack].
  final double? top;

  /// Optional distance to the right of [Stack].
  final double? right;

  /// Optional distance to the base of the [Stack].
  final double? bottom;

  /// Optional distance to the left of the [Stack].
  final double? left;

  /// Opacity applied to the center of the orb.
  final double opacity;
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.spec});

  final LumenGlowOrbSpec spec;

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
  _GridPainter({
    required this.spacing,
    required this.color,
    required this.dots,
  });

  final double spacing;
  final Color color;
  final bool dots;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    if (dots) {
      // Pontos ficam mais discretos que linhas; compensa na opacidade.
      paint.color = color.scaleAlpha(3);
      for (double x = 0; x <= size.width; x += spacing / 2) {
        for (double y = 0; y <= size.height; y += spacing / 2) {
          canvas.drawCircle(Offset(x, y), 1.2, paint);
        }
      }
      return;
    }
    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter old) =>
      old.spacing != spacing || old.color != color || old.dots != dots;
}
