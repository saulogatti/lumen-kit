import 'package:material_ui/material_ui.dart';

import '../foundation/neon_tokens.dart';
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
      data: _neonSliderTheme(context, p, accent),
      child: Opacity(
        opacity: disabled ? kNeonDisabledOpacity : 1,
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

SliderThemeData _neonSliderTheme(
  BuildContext context,
  NeonPalette p,
  Color accent,
) {
  final bool glow = NeonStyle.of(context).shadow == NeonShadowKind.glow;
  return SliderTheme.of(context).copyWith(
    trackHeight: 4,
    activeTrackColor: accent,
    inactiveTrackColor: p.surfaceOutline.withValues(alpha: 0.6),
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

/// Slider de intervalo (dois thumbs) com o mesmo visual do [NeonSlider].
/// Para filtros de preço, faixa etária, horário…
///
/// ```dart
/// NeonRangeSlider(
///   values: _preco,
///   min: 0,
///   max: 500,
///   divisions: 50,
///   onChanged: (RangeValues v) => setState(() => _preco = v),
/// )
/// ```
class NeonRangeSlider extends StatelessWidget {
  /// Cria um slider de intervalo neon.
  const NeonRangeSlider({
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

  /// Intervalo selecionado. É limitado visualmente a [min]..[max].
  final RangeValues values;

  /// Callback chamado enquanto o usuário arrasta um dos thumbs.
  ///
  /// Quando `null`, o slider fica visualmente desabilitado.
  final ValueChanged<RangeValues>? onChanged;

  /// Chamado quando o usuário começa a arrastar.
  final ValueChanged<RangeValues>? onChangeStart;

  /// Chamado quando o usuário solta o thumb (bom para disparar a busca).
  final ValueChanged<RangeValues>? onChangeEnd;

  /// Menor valor permitido.
  final double min;

  /// Maior valor permitido.
  final double max;

  /// Número opcional de divisões discretas do intervalo.
  final int? divisions;

  /// Textos dos indicadores de valor (aparecem só com [divisions]).
  final RangeLabels? labels;

  /// Override da cor de destaque. Default: `palette.primary`.
  final Color? accentColor;

  /// Texto lido por leitores de tela para cada valor (ex.: "R\$ 120").
  final SemanticFormatterCallback? semanticFormatterCallback;

  @override
  Widget build(BuildContext context) {
    final NeonPalette p = NeonThemeExt.of(context).palette;
    final Color accent = accentColor ?? p.primary;
    final double start = values.start.clamp(min, max);
    final double end = values.end.clamp(start, max);

    return SliderTheme(
      data: _neonSliderTheme(context, p, accent),
      child: Opacity(
        opacity: onChanged == null ? kNeonDisabledOpacity : 1,
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
