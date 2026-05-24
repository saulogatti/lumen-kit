import 'package:flutter/material.dart';

import '../theme/neon_palette.dart';

/// Tooltip estilizado seguindo a identidade neon (surface translúcida, borda
/// accent + glow). Wrapper fino sobre o [Tooltip] do Material.
class NeonTooltip extends StatelessWidget {
  const NeonTooltip({
    required this.message,
    required this.child,
    super.key,
    this.accentColor,
    this.waitDuration = const Duration(milliseconds: 300),
    this.showDuration = const Duration(milliseconds: 1800),
    this.preferBelow,
  });

  final String message;
  final Widget child;
  final Color? accentColor;
  final Duration waitDuration;
  final Duration showDuration;
  final bool? preferBelow;

  @override
  Widget build(BuildContext context) {
    final NeonPalette p = NeonThemeExt.of(context).palette;
    final Color accent = accentColor ?? p.accentCyan;

    return Tooltip(
      message: message,
      waitDuration: waitDuration,
      showDuration: showDuration,
      preferBelow: preferBelow,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      textStyle: Theme.of(context)
          .textTheme
          .bodySmall
          ?.copyWith(color: p.textPrimary),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            p.surface.withValues(alpha: 0.98),
            p.backgroundMid.withValues(alpha: 0.95),
          ],
        ),
        border: Border.all(color: accent.withValues(alpha: 0.55), width: 1),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: accent.withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}
