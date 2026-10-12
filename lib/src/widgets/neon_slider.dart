import 'package:material_ui/material_ui.dart';

import '../theme/neon_palette.dart';
import '../theme/neon_style.dart';

/// Slider com track em gradiente accent e thumb com glow.
class NeonSlider extends StatelessWidget {
  /// Cria um slider neon.
  const NeonSlider({
    required this.value,
    required this.onChanged,
    super.key,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.label,
    this.accentColor,
  });

  /// Valor atual do slider.
  ///
  /// O valor é limitado visualmente ao intervalo entre [min] e [max].
  final double value;

  /// Callback chamado quando o usuário muda o valor.
  ///
  /// Quando `null`, o slider fica visualmente desabilitado.
  final ValueChanged<double>? onChanged;

  /// Menor valor permitido.
  final double min;

  /// Maior valor permitido.
  final double max;

  /// Número opcional de divisões discretas do intervalo.
  final int? divisions;

  /// Texto exibido no indicador de valor do [Slider].
  final String? label;

  /// Override da cor de destaque. Default: `palette.primary`.
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final NeonPalette p = NeonThemeExt.of(context).palette;
    final Color accent = accentColor ?? p.primary;
    final bool disabled = onChanged == null;

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 4,
        activeTrackColor: accent,
        inactiveTrackColor: p.surfaceOutline.withValues(alpha: 0.6),
        thumbColor: accent,
        overlayColor: accent.withValues(alpha: 0.18),
        valueIndicatorColor: p.surface,
        valueIndicatorTextStyle: Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: p.textPrimary),
        thumbShape: _GlowThumbShape(
          glow: accent,
          showGlow: NeonStyle.of(context).shadow == NeonShadowKind.glow,
        ),
        trackShape: const RoundedRectSliderTrackShape(),
      ),
      child: Opacity(
        opacity: disabled ? 0.55 : 1,
        child: Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: divisions,
          label: label,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _GlowThumbShape extends SliderComponentShape {
  const _GlowThumbShape({required this.glow, required this.showGlow});

  final Color glow;
  final bool showGlow;

  static const double _radius = 10;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size.fromRadius(_radius);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;
    final Paint glowPaint = Paint()
      ..color = glow.withValues(alpha: 0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    if (showGlow) canvas.drawCircle(center, _radius + 2, glowPaint);

    final Paint thumbPaint = Paint()..color = glow;
    canvas.drawCircle(center, _radius, thumbPaint);

    final Paint innerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85);
    canvas.drawCircle(center, _radius * 0.45, innerPaint);
  }
}
