import 'package:material_ui/material_ui.dart';

import '../theme/neon_palette.dart';
import '../theme/neon_style.dart';

/// Tom semântico para um chip de status.
enum StatusTone {
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

/// Resolve a cor de um [StatusTone] a partir da paleta ativa.
extension StatusToneColor on StatusTone {
  /// Cor do tom na paleta [p].
  Color colorOf(NeonPalette p) => switch (this) {
    StatusTone.neutral => p.textMuted,
    StatusTone.info => p.primary,
    StatusTone.success => p.success,
    StatusTone.warning => p.warning,
    StatusTone.danger => p.danger,
  };
}

/// Chip compacto que comunica um status por cor semântica.
class StatusChip extends StatelessWidget {
  /// Cria um chip de status com [label] e [tone].
  const StatusChip({
    required this.label,
    required this.tone,
    super.key,
    this.icon,
  });

  /// Texto exibido no chip.
  final String label;

  /// Tom semântico usado para escolher a cor do chip.
  final StatusTone tone;

  /// Ícone opcional exibido antes de [label].
  ///
  /// Quando `null`, o chip exibe um ponto colorido.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final NeonStyle style = NeonStyle.of(context);
    final Color c = tone.colorOf(NeonThemeExt.of(context).palette);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: style.radius(999),
        border: style.borderAll(color: c.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 14, color: c),
            const SizedBox(width: 6),
          ] else ...<Widget>[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: c, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: c),
          ),
        ],
      ),
    );
  }
}
