import 'package:material_ui/material_ui.dart';

import '../foundation/lumen_decorations.dart';
import '../theme/lumen_palette.dart';
import '../theme/lumen_style.dart';
import 'lumen_status_chip.dart';

/// Tom semântico do snackbar — usa as mesmas cores de [LumenStatusTone].
typedef LumenSnackTone = LumenStatusTone;

/// Exibe um snackbar estilizado no `ScaffoldMessenger` mais próximo.
///
/// Reutiliza o `SnackBar` do Material mas troca o conteúdo por uma surface
/// com borda accent + glow, no estilo do resto do kit.
///
/// [tone] define cor e ícone padrão, [duration] controla o tempo de exibição e
/// [action] adiciona uma ação textual no fim do snackbar.
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
