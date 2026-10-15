import 'package:flutter/foundation.dart';
import 'package:lumen_kit/src/theme/lumen_palette.dart';
import 'package:material_ui/material_ui.dart';

/// Control followed by a text label, with the color turned off when disabled.
///
/// Box, radio and switch base with `label`.
class LumenLabeled extends StatelessWidget {
  /// Creates a labeled control.
  ///
  /// Without [label], returns only [control].
  const LumenLabeled({
    required this.control,
    super.key,
    this.label,
    this.enabled = true,
    this.gap = 10,
  });

  /// The control (box, circle, rail…).
  final Widget control;

  /// Text next to the control.
  final String? label;

  /// If `false`, the text uses `palette.textMuted`.
  final bool enabled;

  /// Space between control and text.
  final double gap;

  @override
  Widget build(BuildContext context) {
    if (label == null) {
      return control;
    }
    final p = LumenThemeExt.of(context).palette;
    final Widget text = Text(
      label!,
      style: Theme.of(context).textTheme.bodyMedium
          ?.copyWith(color: enabled ? p.textPrimary : p.textMuted),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: gap,
      children: <Widget>[
        control,
        Flexible(child: text),
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('label', label));
    properties.add(DiagnosticsProperty<bool>('enabled', enabled));
    properties.add(DoubleProperty('gap', gap));
  }
}
