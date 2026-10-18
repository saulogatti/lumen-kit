import 'package:lumen_kit/src/foundation/lumen_tokens.dart';
import 'package:lumen_kit/src/theme/lumen_palette.dart';
import 'package:lumen_kit/src/theme/lumen_style.dart';
import 'package:material_ui/material_ui.dart';

/// Linear progress bar with neon and glow gradient.
/// If [value] is `null`, displays indeterminate animation.
class LumenLinearProgress extends StatelessWidget {
  /// Creates a linear progress bar.
  const LumenLinearProgress({
    super.key,
    this.value,
    this.height = 6,
    this.gradient,
    this.glowColor,
    this.trackColor,
    this.borderRadius = 999,
    this.semanticsLabel,
  });

  /// Value between 0 and 1.
  ///
  /// `null` = undetermined.
  final double? value;

  /// Bar height in logical pixels.
  final double height;

  /// Gradient of the filled portion.
  ///
  /// Default: `palette.accentGradient`.
  final Gradient? gradient;

  /// Glow color of the filled portion.
  ///
  /// Default: `palette.secondary`.
  final Color? glowColor;

  /// Background track color.
  final Color? trackColor;

  /// Radius of the bar corners.
  final double borderRadius;

  /// Label read by screen readers (e.g.
  ///
  /// "Sending file").
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final p = LumenThemeExt.of(context).palette;
    final style = LumenStyle.of(context);
    final g = gradient ?? p.accentGradient;
    final glow = glowColor ?? p.secondary;
    final track = trackColor ?? p.surfaceOutline.outlineAlpha(0.4);

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

/// Announces progress as Material's `ProgressIndicator`: value in % when
/// determined, only the label when indeterminate.
class _ProgressSemantics extends StatelessWidget {
  const _ProgressSemantics({required this.label, required this.value, required this.child});

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
    final style = LumenStyle.of(context);
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

class _IndeterminateBarState extends State<_IndeterminateBar> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    LumenMotion.syncRepeat(_ctrl, context, rest: 0.6);
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
      builder: (ctx, _) {
        return LayoutBuilder(
          builder: (_, c) {
            final barWidth = c.maxWidth * 0.35;
            final dx = (c.maxWidth + barWidth) * _ctrl.value - barWidth;
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

/// Circular spinner with neon gradient.
///
/// If [value] is `null`, rotate loop; otherwise, it draws an arc proportional
/// to the progress.
class LumenCircularProgress extends StatefulWidget {
  /// Creates a circular progress indicator.
  const LumenCircularProgress({
    super.key,
    this.value,
    this.size = 32,
    this.strokeWidth = 3,
    this.gradient,
    this.glowColor,
    this.trackColor,
    this.semanticsLabel,
  });

  /// Value between 0 and 1.
  ///
  /// `null` = undetermined.
  final double? value;

  /// Width and height of the indicator.
  final double size;

  /// Arc thickness.
  final double strokeWidth;

  /// Active arc gradient.
  ///
  /// Default: `palette.accentGradient`.
  final Gradient? gradient;

  /// Active arc glow color.
  ///
  /// Default: `palette.secondary`.
  final Color? glowColor;

  /// Background circular trail color.
  final Color? trackColor;

  /// Label read by screen readers (e.g.
  ///
  /// "Loading").
  final String? semanticsLabel;

  @override
  State<LumenCircularProgress> createState() => _LumenCircularProgressState();
}

class _LumenCircularProgressState extends State<LumenCircularProgress>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    LumenMotion.syncRepeat(_ctrl, context, active: widget.value == null);
  }

  @override
  void didUpdateWidget(covariant LumenCircularProgress old) {
    super.didUpdateWidget(old);
    LumenMotion.syncRepeat(_ctrl, context, active: widget.value == null);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = LumenThemeExt.of(context).palette;
    final style = LumenStyle.of(context);
    final g = widget.gradient ?? p.accentGradient;
    final glow = widget.glowColor ?? p.secondary;
    final track = widget.trackColor ?? p.surfaceOutline.outlineAlpha(0.4);

    return _ProgressSemantics(
      label: widget.semanticsLabel,
      value: widget.value,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (ctx, _) {
            return CustomPaint(
              painter: _LumenCircularPainter(
                progress: widget.value,
                rotation: _ctrl.value,
                gradient: style.fill(g)!,
                showGlow: style.shadow == LumenShadowKind.glow,
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

class _LumenCircularPainter extends CustomPainter {
  _LumenCircularPainter({
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
    final radius = (size.shortestSide - strokeWidth) / 2;
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
  bool shouldRepaint(covariant _LumenCircularPainter old) =>
      old.progress != progress ||
      old.rotation != rotation ||
      old.strokeWidth != strokeWidth ||
      old.trackColor != trackColor ||
      old.gradient != gradient ||
      old.showGlow != showGlow;
}
