import 'package:material_ui/material_ui.dart';

import '../foundation/lumen_decorations.dart';
import '../theme/lumen_palette.dart';
import '../theme/lumen_style.dart';
import 'lumen_status_chip.dart';

/// Semantic snackbar tone — uses the same colors as [LumenStatusTone].
typedef LumenSnackTone = LumenStatusTone;

/// Displays a styled snackbar in the nearest `ScaffoldMessenger`.
///
/// Reuses Material's `SnackBar` but replaces its content with a surface that
/// has an accent border + glow, matching the rest of the kit.
///
/// [tone] defines the default color and icon, [duration] controls the display
/// time, and [action] adds a text action at the end of the snackbar.
ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showLumenSnackBar({
  required BuildContext context,
  required String message,
  LumenSnackTone tone = LumenStatusTone.info,
  IconData? icon,
  Duration duration = const Duration(seconds: 4),
  SnackBarAction? action,
}) {
  final LumenPalette p = LumenThemeExt.of(context).palette;
  final LumenStyle style = LumenStyle.of(context);
  final Color accent = tone.colorOf(p);
  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

  final bar = SnackBar(
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    elevation: 0,
    duration: duration,
    padding: EdgeInsets.zero,
    margin: const EdgeInsets.all(16),
    content: style.frost(
      borderRadius: style.radius(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: LumenDecorations.panel(p, style, accent: accent),
        child: Row(
          spacing: 12,
          children: <Widget>[
            Icon(icon ?? tone.icon, color: accent, size: 20),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: p.textPrimary),
              ),
            ),
            if (action != null)
              TextButton(
                // Like SnackBarAction, the action also closes the snackbar.
                onPressed: () {
                  messenger.hideCurrentSnackBar(
                    reason: SnackBarClosedReason.action,
                  );
                  action.onPressed();
                },
                style: TextButton.styleFrom(foregroundColor: accent),
                child: Text(action.label),
              ),
          ],
        ),
      ),
    ),
  );

  return messenger.showSnackBar(bar);
}
