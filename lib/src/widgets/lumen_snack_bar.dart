import 'package:lumen_kit/src/foundation/lumen_decorations.dart';
import 'package:lumen_kit/src/theme/lumen_palette.dart';
import 'package:lumen_kit/src/theme/lumen_style.dart';
import 'package:lumen_kit/src/widgets/lumen_status_chip.dart';
import 'package:material_ui/material_ui.dart';

/// Snackbar semantic tone — uses the same colors as [LumenStatusTone].
typedef LumenSnackTone = LumenStatusTone;

/// Displays a styled snackbar on the nearest `ScaffoldMessenger`.
/// Reuses the `SnackBar` from the Material but exchanges the content for a
/// surface with accent + glow border, in the style of the rest of the kit.
/// [tone] sets default color and icon, [duration] controls display time and
/// [action] adds a textual action at the end of the snackbar.
ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showLumenSnackBar({
  required BuildContext context,
  required String message,
  LumenSnackTone tone = LumenStatusTone.info,
  IconData? icon,
  Duration duration = const Duration(seconds: 4),
  SnackBarAction? action,
}) {
  final p = LumenThemeExt.of(context).palette;
  final style = LumenStyle.of(context);
  final accent = tone.colorOf(p);
  final messenger = ScaffoldMessenger.of(context);

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
                // Igual ao SnackBarAction: a ação também fecha o snackbar.
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
