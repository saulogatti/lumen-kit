import 'package:material_ui/material_ui.dart';

import '../theme/neon_palette.dart';
import '../theme/neon_style.dart';
import 'status_chip.dart';

/// Tom semântico do snackbar — usa as mesmas cores de [StatusTone].
typedef NeonSnackTone = StatusTone;

/// Exibe um snackbar estilizado no `ScaffoldMessenger` mais próximo.
///
/// Reutiliza o `SnackBar` do Material mas troca o conteúdo por uma surface
/// com borda accent + glow, no estilo do resto do kit.
///
/// [tone] define cor e ícone padrão, [duration] controla o tempo de exibição e
/// [action] adiciona uma ação textual no fim do snackbar.
ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showNeonSnackBar({
  required BuildContext context,
  required String message,
  NeonSnackTone tone = StatusTone.info,
  IconData? icon,
  Duration duration = const Duration(seconds: 4),
  SnackBarAction? action,
}) {
  final NeonPalette p = NeonThemeExt.of(context).palette;
  final NeonStyle style = NeonStyle.of(context);
  final Color accent = tone.colorOf(p);

  final SnackBar bar = SnackBar(
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
        decoration: BoxDecoration(
          borderRadius: style.radius(14),
          gradient: style.fill(
            LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                p.surface.withValues(alpha: style.surfaceAlpha(0.98)),
                p.backgroundMid.withValues(alpha: style.surfaceAlpha(0.95)),
              ],
            ),
          ),
          border: style.borderAll(
            color: accent.withValues(alpha: 0.55),
            width: 1.2,
          ),
          boxShadow: style.shadows(<BoxShadow>[
            BoxShadow(
              color: accent.withValues(alpha: 0.3),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ]),
        ),
        child: Row(
          children: <Widget>[
            Icon(icon ?? _toneIcon(tone), color: accent, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: p.textPrimary),
              ),
            ),
            if (action != null) ...<Widget>[
              const SizedBox(width: 8),
              TextButton(
                onPressed: action.onPressed,
                style: TextButton.styleFrom(foregroundColor: accent),
                child: Text(action.label),
              ),
            ],
          ],
        ),
      ),
    ),
  );

  return ScaffoldMessenger.of(context).showSnackBar(bar);
}

IconData _toneIcon(NeonSnackTone tone) {
  switch (tone) {
    case StatusTone.neutral:
      return Icons.info_outline_rounded;
    case StatusTone.info:
      return Icons.bolt_rounded;
    case StatusTone.success:
      return Icons.check_circle_outline_rounded;
    case StatusTone.warning:
      return Icons.warning_amber_rounded;
    case StatusTone.danger:
      return Icons.error_outline_rounded;
  }
}
