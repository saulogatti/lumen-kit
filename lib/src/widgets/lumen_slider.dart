import 'package:lumen_kit/src/foundation/lumen_tokens.dart';
import 'package:lumen_kit/src/theme/lumen_palette.dart';
import 'package:lumen_kit/src/theme/lumen_style.dart';
import 'package:material_ui/material_ui.dart';

/// Slider with accent gradient track and glow thumb.
class LumenSlider extends StatelessWidget {
  /// Creates a neon slider.
  const LumenSlider({
    required this.value,
    required this.onChanged,
    super.key,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.label,
    this.accentColor,
  });

  /// Current slider value.
  /// The value is visually limited to the range between [min] and [max].
  final double value;

  /// Callback called when the user changes the value.
  /// When `null`, the slider is visually disabled.
  final ValueChanged<double>? onChanged;

  /// Lowest value allowed.
  final double min;

  /// Highest value allowed.
  final double max;

  /// Optional number of discrete divisions of the range.
  final int? divisions;

  /// Text displayed on the [Slider] value indicator.
  final String? label;

  /// Highlight color override.
  ///
  /// Default: `palette.primary`.
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final p = LumenThemeExt.of(context).palette;
    final accent = accentColor ?? p.primary;
    final disabled = onChanged == null;

    return SliderTheme(
      data: _lumenSliderTheme(context, p, accent),
      child: Opacity(
        opacity: disabled ? kLumenDisabledOpacity : 1,
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

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size.fromRadius(_thumbRadius);

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
    _paintGlowThumb(context.canvas, center, glow, showGlow: showGlow);
  }
}

const double _thumbRadius = 10;

SliderThemeData _lumenSliderTheme(BuildContext context, LumenPalette p, Color accent) {
  final glow = LumenStyle.of(context).shadow == LumenShadowKind.glow;
  return SliderTheme.of(context).copyWith(
    trackHeight: 4,
    activeTrackColor: accent,
    inactiveTrackColor: p.surfaceOutline.outlineAlpha(0.6),
    thumbColor: accent,
    overlayColor: accent.withValues(alpha: 0.18),
    valueIndicatorColor: p.surface,
    valueIndicatorTextStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: p.textPrimary),
    thumbShape: _GlowThumbShape(glow: accent, showGlow: glow),
    trackShape: const RoundedRectSliderTrackShape(),
    rangeThumbShape: _GlowRangeThumbShape(glow: accent, showGlow: glow),
    rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
    rangeValueIndicatorShape: const PaddleRangeSliderValueIndicatorShape(),
    // Com divisions, os ticks do Material viram um pontilhado sobre o
    // trilho; o thumb já mostra onde o valor encaixa.
    rangeTickMarkShape: const RoundRangeSliderTickMarkShape(tickMarkRadius: 0),
  );
}

void _paintGlowThumb(Canvas canvas, Offset center, Color glow, {required bool showGlow}) {
  if (showGlow) {
    canvas.drawCircle(
      center,
      _thumbRadius + 2,
      Paint()
        ..color = glow.withValues(alpha: 0.55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
  }
  canvas.drawCircle(center, _thumbRadius, Paint()..color = glow);
  canvas.drawCircle(
    center,
    _thumbRadius * 0.45,
    Paint()..color = Colors.white.withValues(alpha: 0.85),
  );
}

/// Interval slider (two thumbs) with the same look as [LumenSlider].
///
/// For price filters, age range, time…
/// ```dart
/// LumenRangeSlider(
///   values: _preco,
///   min: 0,
///   max: 500,
///   divisions: 50,
///   onChanged: (RangeValues v) => setState(() => _preco = v),
/// )
/// ```
class LumenRangeSlider extends StatelessWidget {
  /// Creates a neon interval slider.
  const LumenRangeSlider({
    required this.values,
    required this.onChanged,
    super.key,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.labels,
    this.accentColor,
    this.onChangeStart,
    this.onChangeEnd,
    this.semanticFormatterCallback,
  });

  /// Selected range.
  ///
  /// It is visually limited to [min]..[max].
  final RangeValues values;

  /// Callback called while the user drags one of the thumbs.
  /// When `null`, the slider is visually disabled.
  final ValueChanged<RangeValues>? onChanged;

  /// Called when the user starts dragging.
  final ValueChanged<RangeValues>? onChangeStart;

  /// Called when the user releases the thumb (good for triggering the search).
  final ValueChanged<RangeValues>? onChangeEnd;

  /// Lowest value allowed.
  final double min;

  /// Highest value allowed.
  final double max;

  /// Optional number of discrete divisions of the range.
  final int? divisions;

  /// Value indicator texts (appear only with [divisions]).
  final RangeLabels? labels;

  /// Highlight color override.
  ///
  /// Default: `palette.primary`.
  final Color? accentColor;

  /// Text read by screen readers for each value (e.g.: "R\$ 120").
  final SemanticFormatterCallback? semanticFormatterCallback;

  @override
  Widget build(BuildContext context) {
    final p = LumenThemeExt.of(context).palette;
    final accent = accentColor ?? p.primary;
    final start = values.start.clamp(min, max);
    final end = values.end.clamp(start, max);

    return SliderTheme(
      data: _lumenSliderTheme(context, p, accent),
      child: Opacity(
        opacity: onChanged == null ? kLumenDisabledOpacity : 1,
        child: RangeSlider(
          values: RangeValues(start, end),
          min: min,
          max: max,
          divisions: divisions,
          labels: labels,
          onChanged: onChanged,
          onChangeStart: onChangeStart,
          onChangeEnd: onChangeEnd,
          semanticFormatterCallback: semanticFormatterCallback,
        ),
      ),
    );
  }
}

class _GlowRangeThumbShape extends RangeSliderThumbShape {
  const _GlowRangeThumbShape({required this.glow, required this.showGlow});

  final Color glow;
  final bool showGlow;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size.fromRadius(_thumbRadius);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required SliderThemeData sliderTheme,
    bool isDiscrete = false,
    bool isEnabled = false,
    bool? isOnTop,
    TextDirection? textDirection,
    Thumb? thumb,
    bool? isPressed,
  }) {
    _paintGlowThumb(context.canvas, center, glow, showGlow: showGlow);
  }
}
