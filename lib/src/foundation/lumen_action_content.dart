import 'package:material_ui/material_ui.dart';

/// Default action content: spinner (when [busy]) or [icon], followed by
/// [label]. Shared by buttons, CTAs, and FABs.
class LumenActionContent extends StatelessWidget {
  /// Creates the content for an action.
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

  /// Color of the text, icon, and spinner.
  final Color color;

  /// Text. If `null`, displays only the icon/spinner.
  final String? label;

  /// Icon displayed before [label].
  final IconData? icon;

  /// Replaces the icon with a spinner.
  final bool busy;

  /// Icon size.
  final double iconSize;

  /// Spinner size.
  final double spinnerSize;

  /// Space between the icon and text.
  final double gap;

  /// Fills the available width, centering the content.
  final bool expand;

  /// Text style. Default: the theme's `labelLarge`.
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
