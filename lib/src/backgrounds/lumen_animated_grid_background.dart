import 'package:material_ui/material_ui.dart';

import '../theme/lumen_palette.dart';
import '../theme/lumen_style.dart';

/// Nome antigo de [LumenAnimatedGridBackground].
@Deprecated('Use LumenAnimatedGridBackground')
typedef AnimatedGridBackground = LumenAnimatedGridBackground;

/// Nome antigo de [LumenGlowOrbSpec].
@Deprecated('Use LumenGlowOrbSpec')
typedef GlowOrbSpec = LumenGlowOrbSpec;

/// Pano de fundo decorativo com grade futurística, gradiente e glow orbs.
/// Totalmente parametrizável — defaults reproduzem o visual original do tema.
class LumenAnimatedGridBackground extends StatelessWidget {
  /// Cria um fundo decorativo para envolver [child].
  ///
  /// Quando não recebe customizações, usa o gradiente e os orbs padrão do kit.
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

  /// Conteúdo renderizado acima do gradiente, grid e orbs.
  final Widget child;

  /// Gradiente de fundo. Default: `palette.backgroundGradient`.
  final Gradient? gradient;

  /// Lista de orbs. Default: `palette.primary` no canto superior direito e
  /// `palette.secondary` no inferior esquerdo, ou nenhum quando
  /// [LumenStyle.orbs] é `false`.
  final List<LumenGlowOrbSpec>? orbs;

  /// Distância em px entre linhas da grid.
  final double gridSpacing;

  /// Cor das linhas da grid. Default: `palette.primary`.
  final Color? gridColor;

  /// Opacidade das linhas da grid (0..1).
  final double gridOpacity;

  /// Se `false`, omite a grid/pontos e mantém só gradiente + orbs. O tipo de
  /// decoração (grid, pontos ou nenhuma) vem de [LumenStyle.background].
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

/// Configuração de um glow orb posicionado no fundo.
@immutable
class LumenGlowOrbSpec {
  /// Cria a configuração de um orb de brilho.
  ///
  /// Os campos de posição seguem a mesma semântica de [Positioned].
  const LumenGlowOrbSpec({
    required this.color,
    required this.size,
    this.top,
    this.right,
    this.bottom,
    this.left,
    this.opacity = 0.35,
  });

  /// Cor base usada no centro do gradiente radial.
  final Color color;

  /// Diâmetro do orb em pixels lógicos.
  final double size;

  /// Distância opcional até o topo do [Stack].
  final double? top;

  /// Distância opcional até a direita do [Stack].
  final double? right;

  /// Distância opcional até a base do [Stack].
  final double? bottom;

  /// Distância opcional até a esquerda do [Stack].
  final double? left;

  /// Opacidade aplicada ao centro do orb.
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
