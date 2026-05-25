import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

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

  Color get _color {
    switch (tone) {
      case StatusTone.neutral:
        return AppColors.textMuted;
      case StatusTone.info:
        return AppColors.accentCyan;
      case StatusTone.success:
        return AppColors.success;
      case StatusTone.warning:
        return AppColors.warning;
      case StatusTone.danger:
        return AppColors.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color c = _color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: c.withValues(alpha: 0.5)),
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
