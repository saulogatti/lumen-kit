import 'package:material_ui/material_ui.dart';

import '../foundation/neon_tokens.dart';
import '../theme/neon_palette.dart';
import '../theme/neon_style.dart';

/// Skeleton/shimmer no estilo neon. Use enquanto o conteúdo real está
/// carregando.
///
/// Exemplos:
/// ```dart
/// NeonSkeleton(width: 200, height: 14);
/// NeonSkeleton.circle(size: 48);
/// ```
class NeonSkeleton extends StatefulWidget {
  /// Cria um skeleton retangular.
  const NeonSkeleton({
    super.key,
    this.width,
    this.height = 14,
    this.borderRadius = 8,
    this.baseColor,
    this.highlightColor,
  }) : shape = BoxShape.rectangle;

  /// Cria um skeleton circular com largura e altura iguais a [size].
  const NeonSkeleton.circle({
    super.key,
    required double size,
    this.baseColor,
    this.highlightColor,
  }) : width = size,
       height = size,
       borderRadius = 0,
       shape = BoxShape.circle;

  /// Largura do skeleton. Quando `null`, ocupa a largura imposta pelo pai.
  final double? width;

  /// Altura do skeleton.
  final double height;

  /// Raio dos cantos quando [shape] é [BoxShape.rectangle].
  final double borderRadius;

  /// Forma visual do skeleton.
  final BoxShape shape;

  /// Cor base do shimmer. Default: surface translúcida da paleta.
  final Color? baseColor;

  /// Cor do brilho animado. Default: accent cyan translúcido da paleta.
  final Color? highlightColor;

  @override
  State<NeonSkeleton> createState() => _NeonSkeletonState();
}

class _NeonSkeletonState extends State<NeonSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Com "reduzir animações", o brilho fica parado no meio.
    NeonMotion.syncRepeat(_ctrl, context);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final NeonPalette p = NeonThemeExt.of(context).palette;
    final NeonStyle style = NeonStyle.of(context);
    final Color base =
        widget.baseColor ??
        p.surface.withValues(alpha: style.surfaceAlpha(0.55));
    final Color highlight =
        widget.highlightColor ?? p.primary.withValues(alpha: 0.25);

    final BorderRadius radius = widget.shape == BoxShape.circle
        ? BorderRadius.zero
        : style.radius(widget.borderRadius);

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (BuildContext ctx, _) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (Rect rect) {
            final double t = _ctrl.value;
            return LinearGradient(
              begin: Alignment(-1 + 2 * t - 0.3, 0),
              end: Alignment(-1 + 2 * t + 0.3, 0),
              colors: <Color>[
                Colors.transparent,
                highlight,
                Colors.transparent,
              ],
              stops: const <double>[0.0, 0.5, 1.0],
            ).createShader(rect);
          },
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: base,
              shape: widget.shape,
              borderRadius: widget.shape == BoxShape.rectangle ? radius : null,
            ),
          ),
        );
      },
    );
  }
}
