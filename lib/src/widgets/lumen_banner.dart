import 'package:lumen_kit/src/foundation/lumen_decorations.dart';
import 'package:lumen_kit/src/theme/lumen_palette.dart';
import 'package:lumen_kit/src/theme/lumen_style.dart';
import 'package:lumen_kit/src/widgets/lumen_button.dart';
import 'package:lumen_kit/src/widgets/lumen_icon_button.dart';
import 'package:lumen_kit/src/widgets/lumen_status_chip.dart';
import 'package:material_ui/material_ui.dart';

/// Displays a persistent inline alert with optional action and close buttons.
///
/// The caller controls visibility. The close button calls [onDismiss] when
/// provided.
///
/// ```dart
/// LumenBanner(
///   message: 'Sincronização pausada',
///   tone: LumenStatusTone.warning,
///   actionLabel: 'Retomar',
///   onAction: retomar,
///   onDismiss: () => setState(() => _aviso = false),
/// )
/// ```
class LumenBanner extends StatelessWidget {
  /// Create an inline alert with [message].
  const LumenBanner({
    required this.message,
    super.key,
    this.tone = LumenStatusTone.info,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
  });

  /// Alert text.
  final String message;

  /// Semantic tone.
  ///
  /// Default: [LumenStatusTone.info].
  final LumenStatusTone tone;

  /// Icon on the left.
  ///
  /// Default: the [tone] icon.
  final IconData? icon;

  /// Label shown on the action button when [onAction] is provided.
  final String? actionLabel;

  /// Action callback.
  ///
  /// Without it, [actionLabel] does not appear.
  final VoidCallback? onAction;

  /// Callback invoked when the close button is pressed.
  ///
  /// Omit this callback to hide the button. Remove the banner in the callback
  /// to dismiss it.
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final p = LumenThemeExt.of(context).palette;
    final s = LumenStyle.of(context);
    final color = tone.colorOf(p);
    final showAction = actionLabel != null && onAction != null;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      decoration: LumenDecorations.panel(
        p,
        s,
        accent: color,
        radius: 12,
        glowAlpha: 0.18,
        glowBlur: 16,
        glowOffset: const Offset(0, 6),
      ),
      child: Row(
        spacing: 8,
        children: <Widget>[
          Icon(icon ?? tone.icon, size: 20, color: color),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: p.textPrimary),
            ),
          ),
          if (showAction)
            LumenButton.ghost(label: actionLabel!, onPressed: onAction, accentColor: color),
          if (onDismiss != null)
            LumenIconButton.ghost(
              icon: Icons.close_rounded,
              tooltip: 'Fechar',
              onPressed: onDismiss,
              accentColor: color,
              size: 36,
              iconSize: 18,
            ),
        ],
      ),
    );
  }
}
