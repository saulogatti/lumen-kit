import 'package:flutter/services.dart'
    show
        FilteringTextInputFormatter,
        HardwareKeyboard,
        KeyDownEvent,
        KeyEvent,
        KeyRepeatEvent,
        LengthLimitingTextInputFormatter,
        LogicalKeyboardKey,
        TextInputFormatter;
import 'package:lumen_kit/src/foundation/lumen_pressable.dart';
import 'package:lumen_kit/src/foundation/lumen_tokens.dart';
import 'package:lumen_kit/src/theme/lumen_palette.dart';
import 'package:lumen_kit/src/theme/lumen_style.dart';
import 'package:lumen_kit/src/widgets/lumen_button.dart';
import 'package:lumen_kit/src/widgets/lumen_dialog.dart';
import 'package:lumen_kit/src/widgets/lumen_text_field.dart';
import 'package:material_ui/material_ui.dart';

/// Hue stops for the spectrum track, at full saturation and brightness.
final List<Color> _hueStops = <Color>[
  for (final double hue in <double>[0, 60, 120, 180, 240, 300, 360])
    HSVColor.fromAHSV(1, hue, 1, 1).toColor(),
];

final RegExp _hexPattern = RegExp(r'^[0-9a-fA-F]{6}([0-9a-fA-F]{2})?$');

/// Opens a dialog for picking a color by hue, saturation, and brightness.
///
/// The dialog shows a saturation and brightness area, a hue track, the
/// original color next to the new one, a hex field, and a row of swatches.
///
/// The palette and style are resolved from the dialog route, as with
/// [showLumenDialog]. A [LumenScope] that only wraps the caller is outside
/// that context when the navigator sits above the scope. The default
/// [swatches] are the accents of that palette: primary, secondary, tertiary,
/// success, warning, and danger. Pass an empty list to hide the row.
///
/// [initialColor] seeds the controls. Hue, saturation, and brightness stay
/// independent, so a zero saturation or brightness keeps the hue.
/// Brightness is the value channel of [HSVColor]: `0` is black and `1` is
/// fully bright.
///
/// The alpha of [initialColor] is kept. Swatches and six-digit hex input
/// (`#RRGGBB`) keep it too. Eight-digit hex input (`#AARRGGBB`) replaces it.
///
/// The color area and the hue track stay gradients in every visual style.
/// Flattening them would hide the color being edited. Their radius and
/// border, and the dialog chrome, still follow [LumenStyle].
///
/// The area and the track accept drags, taps, and arrow keys once focused.
/// Shift moves in larger steps. Screen readers adjust saturation,
/// brightness, and hue as three separate sliders named by [saturationLabel],
/// [brightnessLabel], and [hueLabel]. Tapping the original color, announced
/// as [originalLabel], restores it. [selectedLabel] names the new color.
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
  List<Color>? swatches,
  String title = 'Color',
  String okLabel = 'OK',
  String cancelLabel = 'Cancel',
  String hueLabel = 'Hue',
  String saturationLabel = 'Saturation',
  String brightnessLabel = 'Brightness',
  String hexLabel = 'Hex',
  String originalLabel = 'Original color',
  String selectedLabel = 'Selected color',
}) {
  return showDialog<Color>(
    context: context,
    builder: (_) => _LumenColorPickerDialog(
      initialColor: initialColor,
      swatches: swatches,
      title: title,
      okLabel: okLabel,
      cancelLabel: cancelLabel,
      hueLabel: hueLabel,
      saturationLabel: saturationLabel,
      brightnessLabel: brightnessLabel,
      hexLabel: hexLabel,
      originalLabel: originalLabel,
      selectedLabel: selectedLabel,
    ),
  );
}

String _degrees(double value) => '${value.round()}°';

String _percent(double value) => '${(value * 100).round()}%';

/// `#RRGGBB` for opaque colors, `#AARRGGBB` otherwise.
String _hexOf(Color color) {
  final argb = color.toARGB32();
  String byte(int shift) => ((argb >> shift) & 0xFF).toRadixString(16).padLeft(2, '0');
  final rgb = '${byte(16)}${byte(8)}${byte(0)}'.toUpperCase();
  final alpha = (argb >> 24) & 0xFF;
  return alpha == 0xFF ? '#$rgb' : '#${byte(24).toUpperCase()}$rgb';
}

/// Parses `RRGGBB` (keeping [alpha]) or `AARRGGBB`, with an optional `#`.
Color? _parseHex(String text, double alpha) {
  final digits = text.trim().replaceFirst('#', '');
  if (!_hexPattern.hasMatch(digits)) {
    return null;
  }
  final value = int.parse(digits, radix: 16);
  return digits.length == 6 ? Color(0xFF000000 | value).withValues(alpha: alpha) : Color(value);
}

/// Text color that stays readable on top of [background].
Color _onColor(Color background) =>
    ThemeData.estimateBrightnessForColor(background) == Brightness.dark
    ? Colors.white
    : Colors.black;

/// Returns the step for an arrow key press, or `null` for other keys.
///
/// [decrease] and [increase] name the keys of one axis. Shift multiplies
/// the step by ten.
double? _arrowStep(
  KeyEvent event,
  LogicalKeyboardKey decrease,
  LogicalKeyboardKey increase,
  double step,
) {
  if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
    return null;
  }
  final scaled = HardwareKeyboard.instance.isShiftPressed ? step * 10 : step;
  if (event.logicalKey == decrease) {
    return -scaled;
  }
  if (event.logicalKey == increase) {
    return scaled;
  }
  return null;
}

/// Invisible adjustable node, so screen readers can change one channel.
class _ChannelSemantics extends StatelessWidget {
  final String label;
  final double value;
  final double max;
  final double step;
  final String Function(double value) format;
  final ValueChanged<double> onChanged;

  const _ChannelSemantics({
    required this.label,
    required this.value,
    required this.max,
    required this.step,
    required this.format,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final up = (value + step).clamp(0, max).toDouble();
    final down = (value - step).clamp(0, max).toDouble();
    return Semantics(
      container: true,
      slider: true,
      label: label,
      value: format(value),
      increasedValue: format(up),
      decreasedValue: format(down),
      onIncrease: value < max ? () => onChanged(up) : null,
      onDecrease: value > 0 ? () => onChanged(down) : null,
      child: const SizedBox.expand(),
    );
  }
}

/// Saturation (x) and brightness (y) area for one hue.
class _ColorArea extends StatefulWidget {
  static const double height = 184;

  final double hue;
  final double saturation;
  final double brightness;
  final String saturationLabel;
  final String brightnessLabel;

  /// Receives only the channels that changed, so two updates in one frame
  /// do not overwrite each other with stale values.
  final void Function({double? saturation, double? brightness}) onChanged;

  const _ColorArea({
    required this.hue,
    required this.saturation,
    required this.brightness,
    required this.saturationLabel,
    required this.brightnessLabel,
    required this.onChanged,
  });

  @override
  State<_ColorArea> createState() => _ColorAreaState();
}

class _ColorAreaState extends State<_ColorArea> {
  final FocusNode _focus = FocusNode(debugLabel: 'LumenColorArea');
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final p = LumenThemeExt.of(context).palette;
    final style = LumenStyle.of(context);
    final radius = style.radius(14);
    final color = HSVColor.fromAHSV(1, widget.hue, widget.saturation, widget.brightness).toColor();

    return Focus(
      focusNode: _focus,
      onFocusChange: (focused) => setState(() => _focused = focused),
      onKeyEvent: _onKey,
      child: SizedBox(
        height: _ColorArea.height,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.biggest;
            void pick(Offset local) {
              _focus.requestFocus();
              widget.onChanged(
                saturation: (local.dx / size.width).clamp(0, 1).toDouble(),
                brightness: (1 - local.dy / size.height).clamp(0, 1).toDouble(),
              );
            }

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              // The dialog content scrolls on short screens. A vertical drag
              // recognizer here wins over the scroll view's, so dragging up
              // or down inside the area edits brightness instead of scrolling.
              // With two recognizers competing, the winner only accepts after
              // the touch slop, so its start position is handled too.
              onPanDown: (details) => pick(details.localPosition),
              onPanStart: (details) => pick(details.localPosition),
              onPanUpdate: (details) => pick(details.localPosition),
              onVerticalDragDown: (details) => pick(details.localPosition),
              onVerticalDragStart: (details) => pick(details.localPosition),
              onVerticalDragUpdate: (details) => pick(details.localPosition),
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Positioned.fill(
                    child: ExcludeSemantics(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: radius,
                          gradient: LinearGradient(
                            colors: <Color>[
                              Colors.white,
                              HSVColor.fromAHSV(1, widget.hue, 1, 1).toColor(),
                            ],
                          ),
                        ),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: radius,
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: <Color>[Color(0x00000000), Color(0xFF000000)],
                            ),
                            border: _focused
                                ? style.borderAll(color: p.primary, width: 2)
                                : style.borderAll(color: p.surfaceOutline),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Expanded(
                          child: _ChannelSemantics(
                            label: widget.saturationLabel,
                            value: widget.saturation,
                            max: 1,
                            step: 0.05,
                            format: _percent,
                            onChanged: (s) => widget.onChanged(saturation: s),
                          ),
                        ),
                        Expanded(
                          child: _ChannelSemantics(
                            label: widget.brightnessLabel,
                            value: widget.brightness,
                            max: 1,
                            step: 0.05,
                            format: _percent,
                            onChanged: (v) => widget.onChanged(brightness: v),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: widget.saturation * size.width - _Thumb.size / 2,
                    top: (1 - widget.brightness) * size.height - _Thumb.size / 2,
                    child: _Thumb(color: color, focused: _focused),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    final ds = _arrowStep(event, LogicalKeyboardKey.arrowLeft, LogicalKeyboardKey.arrowRight, 0.01);
    final dv = _arrowStep(event, LogicalKeyboardKey.arrowDown, LogicalKeyboardKey.arrowUp, 0.01);
    if (ds == null && dv == null) {
      return KeyEventResult.ignored;
    }
    widget.onChanged(
      saturation: ds == null ? null : (widget.saturation + ds).clamp(0, 1).toDouble(),
      brightness: dv == null ? null : (widget.brightness + dv).clamp(0, 1).toDouble(),
    );
    return KeyEventResult.handled;
  }
}

/// Original color next to the selected one. Tapping the original restores it.
class _ColorCompare extends StatelessWidget {
  final Color original;
  final Color selected;
  final String originalLabel;
  final String selectedLabel;
  final VoidCallback onRestore;

  const _ColorCompare({
    required this.original,
    required this.selected,
    required this.originalLabel,
    required this.selectedLabel,
    required this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    final p = LumenThemeExt.of(context).palette;
    final style = LumenStyle.of(context);
    final radius = style.radius(12);

    return Container(
      width: 112,
      height: 56,
      foregroundDecoration: BoxDecoration(
        borderRadius: radius,
        border: style.borderAll(color: p.surfaceOutline),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: ColoredBox(
                color: original,
                child: LumenPressable(
                  onTap: onRestore,
                  semanticLabel: originalLabel,
                  child: Tooltip(
                    message: originalLabel,
                    excludeFromSemantics: true,
                    child: Center(
                      child: Icon(Icons.undo_rounded, size: 18, color: _onColor(original)),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Semantics(
                label: selectedLabel,
                value: _hexOf(selected),
                child: ColoredBox(color: selected),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Horizontal hue track.
class _HueTrack extends StatefulWidget {
  static const double _barHeight = 14;

  final double hue;
  final String label;
  final ValueChanged<double> onChanged;

  const _HueTrack({required this.hue, required this.label, required this.onChanged});

  @override
  State<_HueTrack> createState() => _HueTrackState();
}

class _HueTrackState extends State<_HueTrack> {
  final FocusNode _focus = FocusNode(debugLabel: 'LumenHueTrack');
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final p = LumenThemeExt.of(context).palette;
    final style = LumenStyle.of(context);

    return Focus(
      focusNode: _focus,
      onFocusChange: (focused) => setState(() => _focused = focused),
      onKeyEvent: _onKey,
      child: SizedBox(
        height: _Thumb.size + 8,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            void pick(Offset local) {
              _focus.requestFocus();
              widget.onChanged((local.dx / width * 360).clamp(0, 360).toDouble());
            }

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragDown: (details) => pick(details.localPosition),
              // Competes with the dialog's scroll view, as in the area.
              onHorizontalDragStart: (details) => pick(details.localPosition),
              onHorizontalDragUpdate: (details) => pick(details.localPosition),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.centerLeft,
                children: <Widget>[
                  Positioned.fill(
                    child: _ChannelSemantics(
                      label: widget.label,
                      value: widget.hue,
                      max: 360,
                      step: 5,
                      format: _degrees,
                      onChanged: widget.onChanged,
                    ),
                  ),
                  Container(
                    height: _HueTrack._barHeight,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: _hueStops),
                      borderRadius: style.radius(_HueTrack._barHeight / 2),
                      border: _focused
                          ? style.borderAll(color: p.primary, width: 2)
                          : style.borderAll(color: p.surfaceOutline),
                    ),
                  ),
                  Positioned(
                    left: widget.hue / 360 * width - _Thumb.size / 2,
                    child: _Thumb(
                      color: HSVColor.fromAHSV(1, widget.hue, 1, 1).toColor(),
                      focused: _focused,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    final step = _arrowStep(event, LogicalKeyboardKey.arrowLeft, LogicalKeyboardKey.arrowRight, 1);
    if (step == null) {
      return KeyEventResult.ignored;
    }
    widget.onChanged((widget.hue + step).clamp(0, 360).toDouble());
    return KeyEventResult.handled;
  }
}

class _LumenColorPickerDialog extends StatefulWidget {
  final Color initialColor;
  final List<Color>? swatches;
  final String title;
  final String okLabel;
  final String cancelLabel;
  final String hueLabel;
  final String saturationLabel;
  final String brightnessLabel;
  final String hexLabel;
  final String originalLabel;
  final String selectedLabel;

  const _LumenColorPickerDialog({
    required this.initialColor,
    required this.swatches,
    required this.title,
    required this.okLabel,
    required this.cancelLabel,
    required this.hueLabel,
    required this.saturationLabel,
    required this.brightnessLabel,
    required this.hexLabel,
    required this.originalLabel,
    required this.selectedLabel,
  });

  @override
  State<_LumenColorPickerDialog> createState() => _LumenColorPickerDialogState();
}

class _LumenColorPickerDialogState extends State<_LumenColorPickerDialog> {
  late double _hue;
  late double _saturation;
  late double _brightness;
  late double _alpha;
  late final TextEditingController _hex;
  final FocusNode _hexFocus = FocusNode(debugLabel: 'LumenColorHex');

  Color get _selected => HSVColor.fromAHSV(_alpha, _hue, _saturation, _brightness).toColor();

  @override
  Widget build(BuildContext context) {
    final p = LumenThemeExt.of(context).palette;
    final swatches =
        (widget.swatches ??
                <Color>[p.primary, p.secondary, p.tertiary, p.success, p.warning, p.danger])
            .toSet()
            .toList();
    final selected = _selected;

    return LumenDialog(
      title: widget.title,
      icon: Icons.palette_outlined,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: <Widget>[
          _ColorArea(
            hue: _hue,
            saturation: _saturation,
            brightness: _brightness,
            saturationLabel: widget.saturationLabel,
            brightnessLabel: widget.brightnessLabel,
            onChanged: ({saturation, brightness}) => _update(() {
              _saturation = saturation ?? _saturation;
              _brightness = brightness ?? _brightness;
            }),
          ),
          _HueTrack(hue: _hue, label: widget.hueLabel, onChanged: (h) => _update(() => _hue = h)),
          Row(
            spacing: 12,
            children: <Widget>[
              _ColorCompare(
                original: widget.initialColor,
                selected: selected,
                originalLabel: widget.originalLabel,
                selectedLabel: widget.selectedLabel,
                onRestore: () => _apply(widget.initialColor),
              ),
              Expanded(
                child: LumenTextField(
                  label: widget.hexLabel,
                  controller: _hex,
                  focusNode: _hexFocus,
                  textInputAction: TextInputAction.done,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp('[#0-9a-fA-F]')),
                    LengthLimitingTextInputFormatter(9),
                  ],
                  onChanged: (text) {
                    final parsed = _parseHex(text, _alpha);
                    if (parsed != null) {
                      _apply(parsed, syncText: false);
                    }
                  },
                  onSubmitted: (_) => _syncHex(),
                ),
              ),
            ],
          ),
          if (swatches.isNotEmpty)
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                for (final Color swatch in swatches)
                  _Swatch(
                    color: swatch,
                    selected: (swatch.toARGB32() & 0xFFFFFF) == (selected.toARGB32() & 0xFFFFFF),
                    onTap: () => _apply(swatch.withValues(alpha: _alpha)),
                  ),
              ],
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
  void dispose() {
    _hex.dispose();
    _hexFocus.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final hsv = HSVColor.fromColor(widget.initialColor);
    _hue = hsv.hue;
    _saturation = hsv.saturation;
    _brightness = hsv.value;
    _alpha = hsv.alpha;
    _hex = TextEditingController(text: _hexOf(_selected));
    _hexFocus.addListener(() {
      if (!_hexFocus.hasFocus) {
        _syncHex();
      }
    });
  }

  /// Moves every control to [color].
  ///
  /// A gray or black [color] has no hue, so the current hue is kept. Black
  /// also keeps the current saturation.
  void _apply(Color color, {bool syncText = true}) {
    final hsv = HSVColor.fromColor(color);
    _update(() {
      if (hsv.saturation > 0 && hsv.value > 0) {
        _hue = hsv.hue;
      }
      if (hsv.value > 0) {
        _saturation = hsv.saturation;
      }
      _brightness = hsv.value;
      _alpha = hsv.alpha;
    }, syncText: syncText);
  }

  void _syncHex() {
    final text = _hexOf(_selected);
    if (_hex.text != text) {
      _hex.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
  }

  void _update(VoidCallback change, {bool syncText = true}) {
    setState(change);
    if (syncText) {
      _syncHex();
    }
  }
}

/// Tappable preset color.
class _Swatch extends StatelessWidget {
  static const double size = 32;

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _Swatch({required this.color, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = LumenThemeExt.of(context).palette;
    final style = LumenStyle.of(context);
    final radius = style.radius(size / 2);

    return LumenPressable(
      onTap: onTap,
      borderRadius: radius,
      semanticLabel: _hexOf(color),
      selected: selected,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: radius,
          border: selected
              ? style.borderAll(color: p.textPrimary, width: 2)
              : style.borderAll(color: p.surfaceOutline),
        ),
        child: selected ? Icon(Icons.check_rounded, size: 18, color: _onColor(color)) : null,
      ),
    );
  }
}

/// Round handle: the color it controls inside a white ring and a dark edge,
/// so it stays visible on light and dark parts of a gradient.
class _Thumb extends StatelessWidget {
  static const double size = 24;

  final Color color;
  final bool focused;

  const _Thumb({required this.color, required this.focused});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedScale(
        scale: focused ? 1.15 : 1,
        duration: LumenMotion.duration(context, kLumenFastDuration),
        child: Container(
          width: size,
          height: size,
          padding: const EdgeInsets.all(1),
          decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0x99000000)),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: Border.all(color: Colors.white, width: 3),
            ),
          ),
        ),
      ),
    );
  }
}
