import 'package:material_ui/material_ui.dart';

import '../foundation/lumen_decorations.dart';
import '../theme/lumen_palette.dart';
import '../theme/lumen_style.dart';

/// Stylized dialog with gradient surface, accent border and theme typography.
///
/// Can be used directly via [showLumenDialog].
class LumenDialog extends StatelessWidget {
  /// Creates a neon dialog with custom content.
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
    final TextTheme text = Theme.of(context).textTheme;
    final LumenPalette p = LumenThemeExt.of(context).palette;
    final LumenStyle style = LumenStyle.of(context);
    final Color a = accent ?? p.primary;

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
                DefaultTextStyle.merge(
                  style: text.bodyMedium ?? const TextStyle(),
                  child: content,
                ),
                if (actions.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 24),
                  // Wrap: ações longas quebram linha em vez de estourar.
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 12,
                    runSpacing: 8,
                    children: actions,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper to display a [LumenDialog] with `showDialog`.
/// Returns the same result as [showDialog]. [barrierDismissible] controls
/// whether tapping outside the dialog closes the modal route.
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
    builder: (BuildContext ctx) => LumenDialog(
      title: title,
      content: content,
      actions: actions,
      accent: accent,
      icon: icon,
    ),
  );
}
