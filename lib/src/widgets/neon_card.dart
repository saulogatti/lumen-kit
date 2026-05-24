import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Container base do tema neon: gradiente sutil + borda accent + opcional onTap.
/// Use como peça fundamental para qualquer tela — cards, painéis, seções.
class NeonCard extends StatelessWidget {
  const NeonCard({
    required this.child,
    super.key,
    this.accent,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 20,
    this.onTap,
    this.borderOpacity = 0.35,
    this.glow = false,
  });

  final Widget child;

  /// Cor de destaque (borda + glow). Default: [AppColors.accentCyan].
  final Color? accent;

  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final VoidCallback? onTap;
  final double borderOpacity;

  /// Se `true`, adiciona um leve glow ao redor do card.
  final bool glow;

  @override
  Widget build(BuildContext context) {
    final Color a = accent ?? AppColors.accentCyan;
    final BorderRadius radius = BorderRadius.circular(borderRadius);

    final Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.surface.withValues(alpha: 0.95),
            AppColors.backgroundMid.withValues(alpha: 0.85),
          ],
        ),
        border: Border.all(
          color: a.withValues(alpha: borderOpacity),
          width: 1.2,
        ),
      ),
      child: child,
    );

    final Widget body = onTap == null
        ? content
        : Material(
            color: Colors.transparent,
            borderRadius: radius,
            child: InkWell(
              onTap: onTap,
              borderRadius: radius,
              child: content,
            ),
          );

    if (!glow) return body;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: a.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: body,
    );
  }
}
