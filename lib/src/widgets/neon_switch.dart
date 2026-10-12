import 'package:material_ui/material_ui.dart';

import '../foundation/neon_decorations.dart';
import '../foundation/neon_labeled.dart';
import '../foundation/neon_pressable.dart';
import '../foundation/neon_tokens.dart';
import '../theme/neon_palette.dart';
import '../theme/neon_style.dart';

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

  /// Override da cor de destaque. Default: `palette.primary`.
  final Color? accentColor;

  /// Texto opcional exibido ao lado do switch.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final NeonPalette p = NeonThemeExt.of(context).palette;
    final NeonStyle style = NeonStyle.of(context);
    final Color accent = accentColor ?? p.primary;
    final bool disabled = onChanged == null;
    final Duration duration = NeonMotion.duration(context, kNeonMediumDuration);

    final Widget track = AnimatedContainer(
      duration: duration,
      curve: Curves.easeOut,
      width: 52,
      height: 30,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: value
            ? accent.withValues(alpha: 0.25)
            : p.surface.withValues(alpha: style.surfaceAlpha(0.7)),
        borderRadius: style.radius(30),
        border: style.borderAll(
          color: value
              ? accent.withValues(alpha: 0.9)
              : p.surfaceOutline.withValues(alpha: 0.8),
          width: 1.2,
        ),
        boxShadow: style.shadows(
          value
              ? <BoxShadow>[
                  BoxShadow(
                    color: accent.withValues(alpha: 0.45),
                    blurRadius: 14,
                    spreadRadius: -2,
                  ),
                ]
              : null,
        ),
      ),
      child: AnimatedAlign(
        duration: duration,
        curve: Curves.easeOut,
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: style.fill(
              value ? NeonDecorations.accent(p, accent) : null,
            ),
            color: value ? null : p.textMuted.withValues(alpha: 0.85),
            boxShadow: style.shadows(
              value
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
    );

    return NeonPressable(
      onTap: disabled ? null : () => onChanged!(!value),
      borderRadius: style.radius(30),
      toggled: value,
      child: NeonLabeled(
        control: track,
        label: label,
        enabled: !disabled,
        gap: 12,
      ),
    );
  }
}
