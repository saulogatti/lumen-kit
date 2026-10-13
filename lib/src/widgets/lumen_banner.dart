import 'package:material_ui/material_ui.dart';

import '../foundation/lumen_decorations.dart';
import '../theme/lumen_palette.dart';
import '../theme/lumen_style.dart';
import 'lumen_button.dart';
import 'lumen_icon_button.dart';
import 'lumen_status_chip.dart';

/// Alerta inline que permanece na tela até alguém fechar.
///
/// Diferente do toast e do snack bar, não some sozinho. Sem [onDismiss] não
/// há botão de fechar.
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
  /// Cria um alerta inline com [message].
  const LumenBanner({
    required this.message,
    super.key,
    this.tone = LumenStatusTone.info,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
  });

  /// Texto do alerta.
  final String message;

  /// Tom semântico. Default: [LumenStatusTone.info].
  final LumenStatusTone tone;

  /// Ícone à esquerda. Default: o ícone do [tone].
  final IconData? icon;

  /// Rótulo da ação opcional, ao lado do fechar.
  final String? actionLabel;

  /// Callback da ação. Sem ele, [actionLabel] não aparece.
  final VoidCallback? onAction;

  /// Fecha o alerta. Sem ele, não há botão de fechar.
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
