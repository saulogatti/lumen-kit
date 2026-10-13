import 'package:material_ui/material_ui.dart';

import '../theme/lumen_palette.dart';
import '../theme/lumen_style.dart';

/// Tom semântico para um chip de status.
enum LumenStatusTone {
  /// Estado neutro ou sem prioridade.
  neutral,

  /// Estado informativo.
  info,

  /// Estado de sucesso.
  success,

  /// Estado de atenção ou alerta.
  warning,

  /// Estado de erro ou perigo.
  danger,
}

/// Resolve a cor de um [LumenStatusTone] a partir da paleta ativa.
extension LumenStatusToneColor on LumenStatusTone {
  /// Cor do tom na paleta [p].
  Color colorOf(LumenPalette p) => switch (this) {
    LumenStatusTone.neutral => p.textMuted,
    LumenStatusTone.info => p.primary,
    LumenStatusTone.success => p.success,
    LumenStatusTone.warning => p.warning,
    LumenStatusTone.danger => p.danger,
  };

  /// Ícone padrão do tom (snackbar, toast).
  IconData get icon => switch (this) {
    LumenStatusTone.neutral => Icons.info_outline_rounded,
    LumenStatusTone.info => Icons.bolt_rounded,
    LumenStatusTone.success => Icons.check_circle_outline_rounded,
    LumenStatusTone.warning => Icons.warning_amber_rounded,
    LumenStatusTone.danger => Icons.error_outline_rounded,
  };
}

/// Chip compacto que comunica um status por cor semântica.
class LumenStatusChip extends StatelessWidget {
  /// Cria um chip de status com [label] e [tone].
  const LumenStatusChip({
    required this.label,
    required this.tone,
    super.key,
    this.icon,
  });

  /// Texto exibido no chip.
  final String label;

  /// Tom semântico usado para escolher a cor do chip.
  final LumenStatusTone tone;

  /// Ícone opcional exibido antes de [label].
  ///
  /// Quando `null`, o chip exibe um ponto colorido.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final LumenStyle style = LumenStyle.of(context);
    final Color c = tone.colorOf(LumenThemeExt.of(context).palette);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: style.radius(999),
        border: style.borderAll(color: c.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: icon == null ? 8 : 6,
        children: <Widget>[
          if (icon != null)
            Icon(icon, size: 14, color: c)
          else
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: c, shape: BoxShape.circle),
            ),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: c),
          ),
        ],
      ),
    );
  }
}
