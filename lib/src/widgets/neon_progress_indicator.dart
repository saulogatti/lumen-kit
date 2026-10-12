import 'package:material_ui/material_ui.dart';

import '../foundation/neon_tokens.dart';
import '../theme/neon_palette.dart';
import '../theme/neon_style.dart';

/// Barra de progresso linear com gradiente neon e glow.
///
/// Se [value] for `null`, exibe animação indeterminada.
class NeonLinearProgress extends StatelessWidget {
  /// Cria uma barra de progresso linear.
  const NeonLinearProgress({
    super.key,
    this.value,
    this.height = 6,
    this.gradient,
    this.glowColor,
    this.trackColor,
    this.borderRadius = 999,
    this.semanticsLabel,
  });

  /// Valor entre 0 e 1. `null` = indeterminado.
  final double? value;

  /// Altura da barra em pixels lógicos.
  final double height;

  /// Gradiente da porção preenchida. Default: `palette.accentGradient`.
  final Gradient? gradient;

  /// Cor do glow da porção preenchida. Default: `palette.secondary`.
  final Color? glowColor;

  /// Cor da trilha de fundo.
  final Color? trackColor;

  /// Raio dos cantos da barra.
  final double borderRadius;

  /// Rótulo lido por leitores de tela (ex.: "Enviando arquivo").
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final NeonPalette p = NeonThemeExt.of(context).palette;
    final NeonStyle style = NeonStyle.of(context);
    final Gradient g = gradient ?? p.accentGradient;
    final Color glow = glowColor ?? p.secondary;
    final Color track = trackColor ?? p.surfaceOutline.withValues(alpha: 0.4);

    return _ProgressSemantics(
      label: semanticsLabel,
      value: value,
      child: ClipRRect(
        borderRadius: style.radius(borderRadius),
        child: SizedBox(
          height: height,
          child: Stack(
            children: <Widget>[
              Container(color: track),
              if (value != null)
                FractionallySizedBox(
                  widthFactor: value!.clamp(0.0, 1.0),
                  child: _GlowBar(gradient: g, glow: glow),
                )
              else
                _IndeterminateBar(gradient: g, glow: glow),
            ],
          ),
        ),
      ),
    );
  }
}

/// Anuncia o progresso como o `ProgressIndicator` do Material: valor em %
/// quando determinado, só o rótulo quando indeterminado.
class _ProgressSemantics extends StatelessWidget {
  const _ProgressSemantics({
    required this.label,
    required this.value,
    required this.child,
  });

  final String? label;
  final double? value;
  final Widget child;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: label,
    value: value == null ? null : '${(value!.clamp(0.0, 1.0) * 100).round()}%',
    child: child,
  );
}

class _GlowBar extends StatelessWidget {
  const _GlowBar({required this.gradient, required this.glow});
  final Gradient gradient;
  final Color glow;

  @override
  Widget build(BuildContext context) {
    final NeonStyle style = NeonStyle.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: style.fill(gradient),
        boxShadow: style.shadows(<BoxShadow>[
          BoxShadow(color: glow.withValues(alpha: 0.55), blurRadius: 12),
        ]),
      ),
    );
  }
}

class _IndeterminateBar extends StatefulWidget {
  const _IndeterminateBar({required this.gradient, required this.glow});
  final Gradient gradient;
  final Color glow;

  @override
  State<_IndeterminateBar> createState() => _IndeterminateBarState();
}

class _IndeterminateBarState extends State<_IndeterminateBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    NeonMotion.syncRepeat(_ctrl, context, rest: 0.6);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (BuildContext ctx, _) {
        return LayoutBuilder(
          builder: (BuildContext _, BoxConstraints c) {
            final double barWidth = c.maxWidth * 0.35;
            final double dx = (c.maxWidth + barWidth) * _ctrl.value - barWidth;
            return Stack(
              children: <Widget>[
                Positioned(
                  left: dx,
                  top: 0,
                  bottom: 0,
                  width: barWidth,
                  child: _GlowBar(gradient: widget.gradient, glow: widget.glow),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// Spinner circular com gradiente neon. Se [value] for `null`, gira em
/// loop; caso contrário, desenha um arco proporcional ao progresso.
class NeonCircularProgress extends StatefulWidget {
  /// Cria um indicador circular de progresso.
  const NeonCircularProgress({
    super.key,
    this.value,
    this.size = 32,
    this.strokeWidth = 3,
    this.gradient,
    this.glowColor,
    this.trackColor,
    this.semanticsLabel,
  });

  /// Valor entre 0 e 1. `null` = indeterminado.
  final double? value;

  /// Largura e altura do indicador.
  final double size;

  /// Espessura do arco.
  final double strokeWidth;

  /// Gradiente do arco ativo. Default: `palette.accentGradient`.
  final Gradient? gradient;

  /// Cor do glow do arco ativo. Default: `palette.secondary`.
  final Color? glowColor;

  /// Cor da trilha circular de fundo.
  final Color? trackColor;

  /// Rótulo lido por leitores de tela (ex.: "Carregando").
  final String? semanticsLabel;

  @override
  State<NeonCircularProgress> createState() => _NeonCircularProgressState();
}

class _NeonCircularProgressState extends State<NeonCircularProgress>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    NeonMotion.syncRepeat(_ctrl, context, active: widget.value == null);
  }

  @override
  void didUpdateWidget(covariant NeonCircularProgress old) {
    super.didUpdateWidget(old);
    NeonMotion.syncRepeat(_ctrl, context, active: widget.value == null);
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
    final Gradient g = widget.gradient ?? p.accentGradient;
    final Color glow = widget.glowColor ?? p.secondary;
    final Color track =
        widget.trackColor ?? p.surfaceOutline.withValues(alpha: 0.4);

    return _ProgressSemantics(
      label: widget.semanticsLabel,
      value: widget.value,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (BuildContext ctx, _) {
            return CustomPaint(
              painter: _NeonCircularPainter(
                progress: widget.value,
                rotation: _ctrl.value,
                gradient: style.fill(g)!,
                showGlow: style.shadow == NeonShadowKind.glow,
                glowColor: glow,
                trackColor: track,
                strokeWidth: widget.strokeWidth,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NeonCircularPainter extends CustomPainter {
  _NeonCircularPainter({
    required this.progress,
    required this.rotation,
    required this.gradient,
    required this.showGlow,
    required this.glowColor,
    required this.trackColor,
    required this.strokeWidth,
  });

  final double? progress;
  final double rotation;
  final Gradient gradient;
  final bool showGlow;
  final Color glowColor;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final double radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = trackColor;
    canvas.drawCircle(center, radius, trackPaint);

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = gradient.createShader(rect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = gradient.createShader(rect);

    const tau = 6.283185307179586;
    final double startAngle;
    final double sweep;
    if (progress != null) {
      startAngle = -tau / 4;
      sweep = (progress!.clamp(0.0, 1.0)) * tau;
    } else {
      startAngle = rotation * tau - tau / 4;
      sweep = tau * 0.75;
    }

    if (showGlow) {
      canvas.drawArc(rect, startAngle, sweep, false, glowPaint);
    }
    canvas.drawArc(rect, startAngle, sweep, false, arcPaint);
  }

  @override
  bool shouldRepaint(covariant _NeonCircularPainter old) =>
      old.progress != progress ||
      old.rotation != rotation ||
      old.strokeWidth != strokeWidth ||
      old.trackColor != trackColor ||
      old.gradient != gradient ||
      old.showGlow != showGlow;
}
