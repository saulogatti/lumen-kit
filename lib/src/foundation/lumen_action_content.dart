import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

/// Default action content: spinner (when [busy]) or [icon], followed by the
/// [label].
///
/// The label stays on one line. When the row gets less width than it needs,
/// the label is truncated with an ellipsis while the icon or spinner keeps its
/// size.
///
/// Shared by buttons, CTA and FAB.
class LumenActionContent extends StatelessWidget {
  /// Creates the content of an action.
  ///
  /// [color] applies to the text, icon, and spinner; [key] identifies this
  /// widget. An optional [label] is shown on one line and ellipsized when
  /// necessary. An optional [icon] precedes it; [busy], false by default,
  /// replaces the icon with a spinner even when no icon was supplied. With
  /// neither a label nor a leading item, the content is empty.
  ///
  /// [iconSize] and [spinnerSize] default to 18 and 16 logical pixels.
  /// [gap] defaults to 10 logical pixels between leading content and text.
  /// [expand] defaults to false; when a label is present, true makes the row
  /// fill its available width and center its content. [textStyle] defaults
  /// to the theme's `labelLarge`, with its color overridden by [color].
  const LumenActionContent({
    required this.color,
    super.key,
    this.label,
    this.icon,
    this.busy = false,
    this.iconSize = 18,
    this.spinnerSize = 16,
    this.gap = 10,
    this.expand = false,
    this.textStyle,
  });

  /// Text, icon and spinner color.
  final Color color;

  /// Text.
  ///
  /// If `null`, it only shows the icon/spinner.
  final String? label;

  /// Icon displayed before [label].
  final IconData? icon;

  /// Swap the icon for a spinner.
  final bool busy;

  /// Icon size.
  final double iconSize;

  /// Spinner side.
  final double spinnerSize;

  /// Space between icon and text.
  final double gap;

  /// Whether to expand the row and center its content when [label] is present.
  final bool expand;

  /// Text style.
  ///
  /// Default: `labelLarge` of the theme.
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final leading = busy
        ? SizedBox.square(
            dimension: spinnerSize,
            child: CircularProgressIndicator(strokeWidth: 2, color: color),
          )
        : icon == null
        ? null
        : Icon(icon, color: color, size: iconSize);

    if (label == null) {
      return leading ?? const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: gap,
      children: <Widget>[
        ?leading,
        Flexible(
          child: Text(
            label!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: (textStyle ?? Theme.of(context).textTheme.labelLarge)?.copyWith(color: color),
          ),
        ),
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty('color', color));
    properties.add(StringProperty('label', label));
    properties.add(DiagnosticsProperty<IconData?>('icon', icon));
    properties.add(DiagnosticsProperty<bool>('busy', busy));
    properties.add(DoubleProperty('iconSize', iconSize));
    properties.add(DoubleProperty('spinnerSize', spinnerSize));
    properties.add(DoubleProperty('gap', gap));
    properties.add(DiagnosticsProperty<bool>('expand', expand));
    properties.add(DiagnosticsProperty<TextStyle?>('textStyle', textStyle));
  }
}
