import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// CTA primário com gradiente neon. Reutilizado em todas as telas.
class GradientCta extends StatelessWidget {
  const GradientCta({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.busy = false,
    this.gradient,
    this.glowColor,
    this.foregroundColor,
    this.borderRadius = 14,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool busy;

  /// Gradiente do botão. Default: [AppColors.accentGradient].
  final Gradient? gradient;

  /// Cor do glow (boxShadow). Default: [AppColors.accentMagenta].
  final Color? glowColor;

  /// Cor do texto/ícone. Default: [AppColors.backgroundDeep].
  final Color? foregroundColor;

  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null && !busy;
    final Gradient g = gradient ?? AppColors.accentGradient;
    final Color glow = glowColor ?? AppColors.accentMagenta;
    final Color fg = foregroundColor ?? AppColors.backgroundDeep;

    return Opacity(
      opacity: enabled ? 1.0 : 0.55,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            decoration: BoxDecoration(
              gradient: g,
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: enabled
                  ? <BoxShadow>[
                      BoxShadow(
                        color: glow.withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (busy)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: fg,
                    ),
                  )
                else if (icon != null)
                  Icon(icon, color: fg, size: 18),
                if (busy || icon != null) const SizedBox(width: 10),
                Text(
                  label,
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: fg),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
