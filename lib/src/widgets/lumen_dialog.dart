import 'package:lumen_kit/src/foundation/lumen_decorations.dart';
import 'package:lumen_kit/src/theme/lumen_palette.dart';
import 'package:lumen_kit/src/theme/lumen_style.dart';
import 'package:material_ui/material_ui.dart';

/// Stylized dialog with gradient surface, accent border and theme typography.
///
/// Can be used directly via [showLumenDialog].
class LumenDialog extends StatelessWidget {
  /// Creates a neon dialog with custom content.
  ///
  /// [title] is displayed in the header and [content] in a vertically
  /// scrollable body. The body has unbounded height, so lists should use
  /// `shrinkWrap: true` and [content] should not be a direct [Expanded].
  /// [actions] defaults to an empty list and appears in the footer; [icon]
  /// optionally precedes the title. [accent] defaults to the palette's
  /// primary color, and [maxWidth] to 460 logical pixels. [key] identifies
  /// the widget in the tree.
  const LumenDialog({
    required this.title,
    required this.content,
    super.key,
    this.actions = const <Widget>[],
    this.accent,
    this.icon,
    this.maxWidth = 460,
  });

  /// Title displayed in the dialog header.
  final String title;

  /// Main content of the dialogue.
  ///
  /// It scrolls vertically when it does not fit, so the title and [actions]
  /// stay visible. It is laid out with unbounded height: use
  /// `shrinkWrap: true` on lists and avoid [Expanded] directly inside it.
  final Widget content;

  /// Actions displayed in the footer, aligned to the right.
  final List<Widget> actions;

  /// Accent color (border + icon).
  ///
  /// Default: `palette.primary`.
  final Color? accent;

  /// Optional icon displayed before the title.
  final IconData? icon;

  /// Maximum dialog width.
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final p = LumenThemeExt.of(context).palette;
    final style = LumenStyle.of(context);
    final a = accent ?? p.primary;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: style.frost(
          borderRadius: style.radius(20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: LumenDecorations.panel(
              p,
              style,
              accent: a,
              radius: 20,
              borderAlpha: 0.5,
              glowAlpha: 0.25,
              glowBlur: 32,
              glowOffset: const Offset(0, 16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  spacing: 14,
                  children: <Widget>[
                    if (icon != null)
                      Container(
                        width: 40,
                        height: 40,
                        decoration: LumenDecorations.iconBox(style, accent: a),
                        child: Icon(icon, color: a, size: 22),
                      ),
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(title, style: text.headlineMedium),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                // Scrolls when the screen is short (keyboard open, landscape)
                // while the header and the actions stay in view.
                Flexible(
                  child: SingleChildScrollView(
                    child: DefaultTextStyle.merge(
                      style: text.bodyMedium ?? const TextStyle(),
                      child: content,
                    ),
                  ),
                ),
                if (actions.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 24),
                  // Wrap: long actions flow onto another line instead of overflowing.
                  Wrap(alignment: WrapAlignment.end, spacing: 12, runSpacing: 8, children: actions),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Displays a [LumenDialog] and returns the result of [showDialog].
///
/// The dialog resolves its palette and style from the route's build context.
/// A [LumenScope] that only wraps the caller is outside that context when
/// the navigator is above the scope. Use [accent] to override the dialog accent.
///
/// [barrierDismissible] controls whether tapping outside closes the dialog.
Future<T?> showLumenDialog<T>({
  required BuildContext context,
  required String title,
  required Widget content,
  List<Widget> actions = const <Widget>[],
  Color? accent,
  IconData? icon,
  bool barrierDismissible = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (ctx) =>
        LumenDialog(title: title, content: content, actions: actions, accent: accent, icon: icon),
  );
}
