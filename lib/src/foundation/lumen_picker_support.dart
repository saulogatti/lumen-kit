// Internal helpers shared by the date and time pickers. Not exported.
import 'dart:math' as math;

import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:lumen_kit/src/theme/lumen_palette.dart';
import 'package:lumen_kit/src/theme/lumen_style.dart';
import 'package:material_ui/material_ui.dart';

/// The palette text tone that contrasts more with [fill].
Color lumenForegroundOn(LumenPalette palette, Color fill) {
  final f = fill.computeLuminance();
  double contrast(Color c) {
    final l = c.computeLuminance();
    return (math.max(l, f) + 0.05) / (math.min(l, f) + 0.05);
  }

  return contrast(palette.backgroundDeep) >= contrast(palette.textPrimary)
      ? palette.backgroundDeep
      : palette.textPrimary;
}

/// Whether [key] is Enter on the main keyboard or the numeric keypad.
bool isLumenEnterKey(LogicalKeyboardKey key) =>
    key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.numpadEnter;

/// Focus target of a picker control that outlines itself while it has
/// keyboard focus in the traditional (keyboard) highlight mode.
///
/// Touch users do not see the outline, even with [autofocus].
class LumenPickerFocusFrame extends StatefulWidget {
  /// Creates a focusable frame around [child].
  const LumenPickerFocusFrame({
    required this.debugLabel,
    required this.onKey,
    required this.child,
    super.key,
    this.autofocus = true,
    this.radius = 14,
  });

  /// Name of the focus node in debug output.
  final String debugLabel;

  /// Handles key events while the frame has focus.
  final FocusOnKeyEventCallback onKey;

  /// Content inside the frame.
  final Widget child;

  /// Whether the frame takes focus when it is first built.
  final bool autofocus;

  /// Corner radius before [LumenStyle.radius].
  final double radius;

  @override
  State<LumenPickerFocusFrame> createState() => _LumenPickerFocusFrameState();
}

class _LumenPickerFocusFrameState extends State<LumenPickerFocusFrame> {
  late final FocusNode _focus = FocusNode(debugLabel: widget.debugLabel);
  bool _focused = false;
  bool _keyboard = FocusManager.instance.highlightMode == FocusHighlightMode.traditional;

  @override
  Widget build(BuildContext context) {
    final p = LumenThemeExt.of(context).palette;
    final style = LumenStyle.of(context);
    final outlined = _focused && _keyboard;

    return Focus(
      focusNode: _focus,
      autofocus: widget.autofocus,
      onFocusChange: (focused) => setState(() => _focused = focused),
      onKeyEvent: widget.onKey,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: style.radius(widget.radius),
          border: style.borderAll(
            color: outlined ? p.primary : p.primary.withValues(alpha: 0),
            width: 2,
          ),
        ),
        child: widget.child,
      ),
    );
  }

  @override
  void dispose() {
    FocusManager.instance.removeHighlightModeListener(_onHighlightMode);
    _focus.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    FocusManager.instance.addHighlightModeListener(_onHighlightMode);
  }

  void _onHighlightMode(FocusHighlightMode mode) {
    setState(() => _keyboard = mode == FocusHighlightMode.traditional);
  }
}
