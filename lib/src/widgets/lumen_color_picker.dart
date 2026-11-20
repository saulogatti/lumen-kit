import 'package:lumen_kit/src/theme/lumen_palette.dart';
import 'package:lumen_kit/src/theme/lumen_style.dart';
import 'package:lumen_kit/src/widgets/lumen_button.dart';
import 'package:lumen_kit/src/widgets/lumen_dialog.dart';
import 'package:material_ui/material_ui.dart';

/// Hue stops for the spectrum track, at full saturation and brightness.
final List<Color> _hueStops = <Color>[
  for (final double hue in <double>[0, 60, 120, 180, 240, 300, 360])
    HSVColor.fromAHSV(1, hue, 1, 1).toColor(),
];

/// Opens a dialog for picking a color by hue, saturation, and brightness.
///
/// The palette and style are resolved from the dialog route, as with
/// [showLumenDialog]. A [LumenScope] that only wraps the caller is outside
/// that context when the navigator sits above the scope.
///
/// [initialColor] seeds the three tracks. Hue, saturation, and brightness
/// stay independent, so a zero saturation or brightness keeps the hue.
/// Brightness is the value channel of [HSVColor]: `0` is black and `1` is
/// fully bright. The alpha of [initialColor] is kept. The tracks themselves
/// are drawn fully opaque so the spectrum stays visible.
///
/// Those track gradients stay gradients in every visual style. Flattening
/// them would hide the color being edited. The dialog chrome still follows
/// [LumenStyle].
///
/// OK completes with the selected color. Cancel, and a tap on the barrier,
/// complete with `null`.
///
/// ```dart
/// final Color? picked = await showLumenColorPicker(
///   context: context,
///   initialColor: const Color(0xFF00E5FF),
/// );
/// ```
Future<Color?> showLumenColorPicker({
  required BuildContext context,
  required Color initialColor,
  String title = 'Color',
  String okLabel = 'OK',
  String cancelLabel = 'Cancel',
  String hueLabel = 'Hue',
  String saturationLabel = 'Saturation',
  String brightnessLabel = 'Brightness',
}) {
  return showDialog<Color>(
    context: context,
    builder: (_) => _LumenColorPickerDialog(
      initialColor: initialColor,
      title: title,
      okLabel: okLabel,
      cancelLabel: cancelLabel,
      hueLabel: hueLabel,
      saturationLabel: saturationLabel,
      brightnessLabel: brightnessLabel,
    ),
  );
}

String _degrees(double value) => '${value.round()}°';

String _percent(double value) => '${(value * 100).round()}%';

class _ColorPreview extends StatelessWidget {
  final Color color;

  const _ColorPreview({required this.color});

  @override
  Widget build(BuildContext context) {
    final palette = LumenThemeExt.of(context).palette;
    final style = LumenStyle.of(context);
    return Semantics(
      label: 'Selected color',
      child: Container(
        width: 56,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          borderRadius: style.radius(10),
          border: style.borderAll(color: palette.surfaceOutline),
        ),
      ),
    );
  }
}

/// Horizontal slider whose track is [gradient].
///
/// The gradient is the color being edited, so it is not passed through
/// [LumenStyle.fill]. Radius and border still follow [LumenStyle].
class _GradientSlider extends StatelessWidget {
  /// Matches [RoundSliderOverlayShape], which insets the track on each side.
  static const double _trackInset = 20;

  static const double _thumbRadius = 11;
  final String label;
  final double value;
  final double max;
  final Gradient gradient;
  final String Function(double value) semanticFormatter;

  final ValueChanged<double> onChanged;

  const _GradientSlider({
    required this.label,
    required this.value,
    required this.max,
    required this.gradient,
    required this.semanticFormatter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final palette = LumenThemeExt.of(context).palette;
    final style = LumenStyle.of(context);
    final text = Theme.of(context).textTheme;

    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(label, style: text.bodySmall?.copyWith(color: palette.textSecondary)),
          SizedBox(
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: _trackInset),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: style.radius(7),
                      border: style.borderAll(color: palette.surfaceOutline),
                    ),
                    child: const SizedBox(height: 14, width: double.infinity),
                  ),
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 14,
                    trackShape: const RoundedRectSliderTrackShape(),
                    activeTrackColor: Colors.transparent,
                    inactiveTrackColor: Colors.transparent,
                    overlayColor: palette.textPrimary.withValues(alpha: 0.12),
                    thumbColor: Colors.white,
                    thumbShape: const _OutlinedThumbShape(radius: _thumbRadius),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: _trackInset),
                    showValueIndicator: ShowValueIndicator.never,
                  ),
                  child: Slider(
                    value: value.clamp(0, max).toDouble(),
                    max: max,
                    semanticFormatterCallback: semanticFormatter,
                    onChanged: onChanged,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LumenColorPickerDialog extends StatefulWidget {
  final Color initialColor;

  final String title;
  final String okLabel;
  final String cancelLabel;
  final String hueLabel;
  final String saturationLabel;
  final String brightnessLabel;
  const _LumenColorPickerDialog({
    required this.initialColor,
    required this.title,
    required this.okLabel,
    required this.cancelLabel,
    required this.hueLabel,
    required this.saturationLabel,
    required this.brightnessLabel,
  });

  @override
  State<_LumenColorPickerDialog> createState() => _LumenColorPickerDialogState();
}

class _LumenColorPickerDialogState extends State<_LumenColorPickerDialog> {
  late double _hue;
  late double _saturation;
  late double _brightness;
  late double _alpha;

  Color get _selected => HSVColor.fromAHSV(_alpha, _hue, _saturation, _brightness).toColor();

  @override
  Widget build(BuildContext context) {
    return LumenDialog(
      title: widget.title,
      icon: Icons.palette_outlined,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: <Widget>[
          Center(child: _ColorPreview(color: _selected)),
          _GradientSlider(
            label: widget.hueLabel,
            value: _hue,
            max: 360,
            gradient: LinearGradient(colors: _hueStops),
            semanticFormatter: _degrees,
            onChanged: (value) => setState(() => _hue = value),
          ),
          _GradientSlider(
            label: widget.saturationLabel,
            value: _saturation,
            max: 1,
            gradient: LinearGradient(
              colors: <Color>[
                HSVColor.fromAHSV(1, _hue, 0, _brightness).toColor(),
                HSVColor.fromAHSV(1, _hue, 1, _brightness).toColor(),
              ],
            ),
            semanticFormatter: _percent,
            onChanged: (value) => setState(() => _saturation = value),
          ),
          _GradientSlider(
            label: widget.brightnessLabel,
            value: _brightness,
            max: 1,
            gradient: LinearGradient(
              colors: <Color>[
                HSVColor.fromAHSV(1, _hue, _saturation, 0).toColor(),
                HSVColor.fromAHSV(1, _hue, _saturation, 1).toColor(),
              ],
            ),
            semanticFormatter: _percent,
            onChanged: (value) => setState(() => _brightness = value),
          ),
        ],
      ),
      actions: <Widget>[
        LumenButton.outline(
          label: widget.cancelLabel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        LumenButton(label: widget.okLabel, onPressed: () => Navigator.of(context).pop(_selected)),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    final hsv = HSVColor.fromColor(widget.initialColor);
    _hue = hsv.hue;
    _saturation = hsv.saturation;
    _brightness = hsv.value;
    _alpha = hsv.alpha;
  }
}

class _OutlinedThumbShape extends SliderComponentShape {
  final double radius;

  const _OutlinedThumbShape({required this.radius});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size.fromRadius(radius);

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
    final canvas = context.canvas;
    canvas.drawCircle(center, radius, Paint()..color = const Color(0xFF1A1D24));
    canvas.drawCircle(center, radius - 2.5, Paint()..color = Colors.white);
  }
}
