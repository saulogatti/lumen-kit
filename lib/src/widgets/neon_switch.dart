import 'package:flutter/material.dart';

import '../theme/neon_palette.dart';

/// Switch estilizado com track translúcida, thumb em accent e glow quando ativo.
class NeonSwitch extends StatelessWidget {
  /// Cria um switch neon.
  const NeonSwitch({
    required this.value,
    required this.onChanged,
    super.key,
    this.accentColor,
    this.label,
  });

  /// Valor atual do switch.
  final bool value;

  /// Callback chamado com o valor invertido ao tocar no switch.
  ///
  /// Quando `null`, o switch fica visualmente desabilitado.
  final ValueChanged<bool>? onChanged;

  /// Override da cor de destaque. Default: `palette.accentCyan`.
  final Color? accentColor;

  /// Texto opcional exibido ao lado do switch.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final NeonPalette p = NeonThemeExt.of(context).palette;
    final Color accent = accentColor ?? p.accentCyan;
    final bool disabled = onChanged == null;
    final double opacity = disabled ? 0.55 : 1;

    final Widget switchWidget = Opacity(
      opacity: opacity,
      child: GestureDetector(
        onTap: disabled ? null : () => onChanged!(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          width: 52,
          height: 30,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: value
                ? accent.withValues(alpha: 0.25)
                : p.surface.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: value
                  ? accent.withValues(alpha: 0.9)
                  : p.surfaceOutline.withValues(alpha: 0.8),
              width: 1.2,
            ),
            boxShadow: value
                ? <BoxShadow>[
                    BoxShadow(
                      color: accent.withValues(alpha: 0.45),
                      blurRadius: 14,
                      spreadRadius: -2,
                    ),
                  ]
                : null,
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: value
                    ? LinearGradient(
                        colors: <Color>[accent, p.accentMagenta],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: value ? null : p.textMuted.withValues(alpha: 0.85),
                boxShadow: value
                    ? <BoxShadow>[
                        BoxShadow(
                          color: accent.withValues(alpha: 0.55),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        ),
      ),
    );

    if (label == null) return switchWidget;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        switchWidget,
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            label!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: disabled ? p.textMuted : p.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
