import 'package:material_ui/material_ui.dart';

/// Default action content: spinner (when [busy]) or [icon], followed by the
/// [label].
///
/// Shared by buttons, CTA and FAB.
class LumenActionContent extends StatelessWidget {
  /// Creates the content of an action.
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

  /// It occupies the entire width, centralizing the content.
  final bool expand;

  /// Text style.
  ///
  /// Default: `labelLarge` of the theme.
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final Widget? leading = busy
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
        Text(
          label!,
          style: (textStyle ?? Theme.of(context).textTheme.labelLarge)
              ?.copyWith(color: color),
        ),
      ],
    );
  }
}
