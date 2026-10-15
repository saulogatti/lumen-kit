import 'package:material_ui/material_ui.dart';

import '../foundation/lumen_decorations.dart';
import '../theme/lumen_palette.dart';
import '../theme/lumen_style.dart';
import 'lumen_button.dart';
import 'lumen_icon_button.dart';
import 'lumen_status_chip.dart';

/// Inline alert that remains on the screen until someone closes.
/// Unlike toast and snack bars, it doesn't disappear on its own. No [onDismiss]
/// there is close button.
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

  /// Optional action label, next to close.
  final String? actionLabel;

  /// Action callback.
  ///
  /// Without it, [actionLabel] does not appear.
  final VoidCallback? onAction;

  /// Close the alert.
  ///
  /// Without it, there is no close button.
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
