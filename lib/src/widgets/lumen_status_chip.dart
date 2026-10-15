import 'package:material_ui/material_ui.dart';

import '../theme/lumen_palette.dart';
import '../theme/lumen_style.dart';

/// Semantic tone for a status chip.
enum LumenStatusTone {
  /// Neutral or non-priority state.
  neutral,

  /// Informational status.
  info,

  /// Success status.
  success,

  /// State of attention or alert.
  warning,

  /// Error or danger state.
  danger,
}

/// Resolves the color of a [LumenStatusTone] from the active palette.
extension LumenStatusToneColor on LumenStatusTone {
  /// Shade color in the [p] palette.
  Color colorOf(LumenPalette p) => switch (this) {
    LumenStatusTone.neutral => p.textMuted,
    LumenStatusTone.info => p.primary,
    LumenStatusTone.success => p.success,
    LumenStatusTone.warning => p.warning,
    LumenStatusTone.danger => p.danger,
  };

  /// Default tone icon (snackbar, toast).
  IconData get icon => switch (this) {
    LumenStatusTone.neutral => Icons.info_outline_rounded,
    LumenStatusTone.info => Icons.bolt_rounded,
    LumenStatusTone.success => Icons.check_circle_outline_rounded,
    LumenStatusTone.warning => Icons.warning_amber_rounded,
    LumenStatusTone.danger => Icons.error_outline_rounded,
  };
}

/// Compact chip that communicates status by color semantics.
class LumenStatusChip extends StatelessWidget {
  /// Creates a status chip with [label] and [tone].
  const LumenStatusChip({
    required this.label,
    required this.tone,
    super.key,
    this.icon,
  });

  /// Text displayed on the chip.
  final String label;

  /// Semantic tone used to choose the color of the chip.
  final LumenStatusTone tone;

  /// Optional icon displayed before [label].
  /// When `null`, the chip displays a colored dot.
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
