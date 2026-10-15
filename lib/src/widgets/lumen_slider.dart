import 'package:material_ui/material_ui.dart';

import '../foundation/lumen_tokens.dart';
import '../theme/lumen_palette.dart';
import '../theme/lumen_style.dart';

/// Slider with an accent gradient track and glowing thumb.
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
  ///
  /// The value is visually clamped to the range between [min] and [max].
  final double value;

  /// Callback called when the user changes the value.
  ///
  /// When `null`, the slider appears disabled.
  final ValueChanged<double>? onChanged;

  /// Minimum allowed value.
  final double min;

  /// Maximum allowed value.
  final double max;

  /// Optional number of discrete divisions in the range.
  final int? divisions;

  /// Text displayed in the [Slider] value indicator.
  final String? label;

  /// Accent color override. Default: `palette.primary`.
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final LumenPalette p = LumenThemeExt.of(context).palette;
    final Color accent = accentColor ?? p.primary;
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
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size.fromRadius(_thumbRadius);

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

SliderThemeData _lumenSliderTheme(
  BuildContext context,
  LumenPalette p,
  Color accent,
) {
  final glow = LumenStyle.of(context).shadow == LumenShadowKind.glow;
  return SliderTheme.of(context).copyWith(
    trackHeight: 4,
    activeTrackColor: accent,
    inactiveTrackColor: p.surfaceOutline.outlineAlpha(0.6),
    thumbColor: accent,
    overlayColor: accent.withValues(alpha: 0.18),
    valueIndicatorColor: p.surface,
    valueIndicatorTextStyle: Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: p.textPrimary),
    thumbShape: _GlowThumbShape(glow: accent, showGlow: glow),
    trackShape: const RoundedRectSliderTrackShape(),
    rangeThumbShape: _GlowRangeThumbShape(glow: accent, showGlow: glow),
    rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
    rangeValueIndicatorShape: const PaddleRangeSliderValueIndicatorShape(),
    // With divisions, Material ticks become dots over the track; the thumb
    // already shows where the value snaps.
    rangeTickMarkShape: const RoundRangeSliderTickMarkShape(tickMarkRadius: 0),
  );
}

void _paintGlowThumb(
  Canvas canvas,
  Offset center,
  Color glow, {
  required bool showGlow,
}) {
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

/// Range slider (two thumbs) with the same look as [LumenSlider].
/// For price ranges, age ranges, time ranges…
///
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
  /// Creates a neon range slider.
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

  /// Selected range. Visually clamped to [min]..[max].
  final RangeValues values;

  /// Callback called while the user drags either thumb.
  ///
  /// When `null`, the slider appears disabled.
  final ValueChanged<RangeValues>? onChanged;

  /// Called when the user starts dragging.
  final ValueChanged<RangeValues>? onChangeStart;

  /// Called when the user releases the thumb (useful for triggering a search).
  final ValueChanged<RangeValues>? onChangeEnd;

  /// Minimum allowed value.
  final double min;

  /// Maximum allowed value.
  final double max;

  /// Optional number of discrete divisions in the range.
  final int? divisions;

  /// Value indicator labels (shown only when [divisions] is set).
  final RangeLabels? labels;

  /// Accent color override. Default: `palette.primary`.
  final Color? accentColor;

  /// Text read by screen readers for each value (e.g. "$120").
  final SemanticFormatterCallback? semanticFormatterCallback;

  @override
  Widget build(BuildContext context) {
    final LumenPalette p = LumenThemeExt.of(context).palette;
    final Color accent = accentColor ?? p.primary;
    final double start = values.start.clamp(min, max);
    final double end = values.end.clamp(start, max);

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
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size.fromRadius(_thumbRadius);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = false,
    bool? isOnTop,
    TextDirection? textDirection,
    required SliderThemeData sliderTheme,
    Thumb? thumb,
    bool? isPressed,
  }) {
    _paintGlowThumb(context.canvas, center, glow, showGlow: showGlow);
  }
}
