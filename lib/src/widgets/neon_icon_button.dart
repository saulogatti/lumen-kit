import 'package:flutter/material.dart';

import '../theme/neon_palette.dart';

/// Variantes visuais do [NeonIconButton].
enum NeonIconButtonVariant {
  /// Preenchido com gradiente neon.
  solid,

  /// Borda neon com fundo translúcido.
  outline,

  /// Apenas ícone na cor de accent, sem fundo nem borda.
  ghost,
}

/// Botão circular/quadrado contendo apenas um ícone, no estilo neon.
class NeonIconButton extends StatelessWidget {
  const NeonIconButton({
    required this.icon,
    required this.onPressed,
    super.key,
    this.variant = NeonIconButtonVariant.outline,
    this.tooltip,
    this.busy = false,
    this.accentColor,
    this.size = 44,
    this.iconSize = 20,
    this.shape = NeonIconButtonShape.circle,
  });

  const NeonIconButton.solid({
    required this.icon,
    required this.onPressed,
    super.key,
    this.tooltip,
    this.busy = false,
    this.accentColor,
    this.size = 44,
    this.iconSize = 20,
    this.shape = NeonIconButtonShape.circle,
  }) : variant = NeonIconButtonVariant.solid;

  const NeonIconButton.ghost({
    required this.icon,
    required this.onPressed,
    super.key,
    this.tooltip,
    this.busy = false,
    this.accentColor,
    this.size = 44,
    this.iconSize = 20,
    this.shape = NeonIconButtonShape.circle,
  }) : variant = NeonIconButtonVariant.ghost;

  final IconData icon;
  final VoidCallback? onPressed;
  final NeonIconButtonVariant variant;
  final String? tooltip;
  final bool busy;
  final Color? accentColor;

  /// Tamanho da área total (largura = altura).
  final double size;

  final double iconSize;

  /// Formato do botão: círculo ou quadrado arredondado.
  final NeonIconButtonShape shape;

  @override
  Widget build(BuildContext context) {
    final NeonPalette palette = NeonThemeExt.of(context).palette;
    final bool enabled = onPressed != null && !busy;
    final Color accent = accentColor ?? palette.accentCyan;

    final BorderRadius radius = switch (shape) {
      NeonIconButtonShape.circle => BorderRadius.circular(size / 2),
      NeonIconButtonShape.rounded => BorderRadius.circular(12),
    };

    final Color fg = variant == NeonIconButtonVariant.solid
        ? palette.backgroundDeep
        : accent;

    final Widget content = Center(
      child: busy
          ? SizedBox(
              width: iconSize,
              height: iconSize,
              child: CircularProgressIndicator(strokeWidth: 2, color: fg),
            )
          : Icon(icon, color: fg, size: iconSize),
    );

    final Widget body = switch (variant) {
      NeonIconButtonVariant.solid => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: palette.accentGradient,
            borderRadius: radius,
            boxShadow: enabled
                ? <BoxShadow>[
                    BoxShadow(
                      color: (accentColor ?? palette.accentMagenta)
                          .withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: content,
        ),
      NeonIconButtonVariant.outline => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: palette.surface.withValues(alpha: 0.35),
            borderRadius: radius,
            border:
                Border.all(color: accent.withValues(alpha: 0.85), width: 1.2),
            boxShadow: enabled
                ? <BoxShadow>[
                    BoxShadow(
                      color: accent.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: content,
        ),
      NeonIconButtonVariant.ghost => SizedBox(
          width: size,
          height: size,
          child: content,
        ),
    };

    Widget interactive = Opacity(
      opacity: enabled ? 1.0 : 0.55,
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: radius,
          child: body,
        ),
      ),
    );

    if (tooltip != null) {
      interactive = Tooltip(message: tooltip!, child: interactive);
    }

    return interactive;
  }
}

/// Formato do [NeonIconButton].
enum NeonIconButtonShape { circle, rounded }
