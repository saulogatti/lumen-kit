import 'package:material_ui/material_ui.dart';

import '../foundation/lumen_decorations.dart';
import '../theme/lumen_palette.dart';
import '../theme/lumen_style.dart';
import 'lumen_button.dart';
import 'lumen_icon_button.dart';
import 'lumen_status_chip.dart';

/// Inline alert that stays on screen until dismissed.
///
/// Unlike a toast or snack bar, it does not disappear on its own. Without
/// [onDismiss], there is no close button.
///
/// ```dart
/// LumenBanner(
///   message: 'Sync paused',
///   tone: LumenStatusTone.warning,
///   actionLabel: 'Resume',
///   onAction: retomar,
///   onDismiss: () => setState(() => _aviso = false),
/// )
/// ```
class LumenBanner extends StatelessWidget {
  /// Creates an inline alert with [message].
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

  /// Semantic tone. Default: [LumenStatusTone.info].
  final LumenStatusTone tone;

  /// Icon on the left. Default: the icon for [tone].
  final IconData? icon;

  /// Optional action label, next to the close button.
  final String? actionLabel;

  /// Action callback. Without it, [actionLabel] is not shown.
  final VoidCallback? onAction;

  /// Dismisses the alert. Without it, there is no close button.
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final LumenPalette p = LumenThemeExt.of(context).palette;
    final LumenStyle s = LumenStyle.of(context);
    final Color color = tone.colorOf(p);
    final bool showAction = actionLabel != null && onAction != null;
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
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: p.textPrimary),
            ),
          ),
          if (showAction)
            LumenButton.ghost(
              label: actionLabel!,
              onPressed: onAction,
              accentColor: color,
            ),
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
