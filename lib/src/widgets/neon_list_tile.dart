import 'package:material_ui/material_ui.dart';

import '../foundation/neon_pressable.dart';
import '../foundation/neon_tokens.dart';
import '../theme/neon_palette.dart';
import '../theme/neon_style.dart';

/// ListTile temático com surface translúcida, borda accent suave e estado
/// selecionado destacado por glow.
class NeonListTile extends StatelessWidget {
  /// Cria um item de lista neon.
  const NeonListTile({
    required this.title,
    super.key,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.selected = false,
    this.accentColor,
    this.dense = false,
  });

  /// Texto principal do item.
  final String title;

  /// Texto auxiliar exibido abaixo de [title].
  final String? subtitle;

  /// Widget opcional exibido antes do texto.
  final Widget? leading;

  /// Widget opcional exibido no fim da linha.
  final Widget? trailing;

  /// Callback executado ao tocar no item.
  final VoidCallback? onTap;

  /// Callback executado no toque longo.
  final VoidCallback? onLongPress;

  /// Se `true`, aplica destaque visual de seleção.
  final bool selected;

  /// Override da cor de destaque. Default: `palette.primary`.
  final Color? accentColor;

  /// Se `true`, reduz o espaçamento vertical.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final NeonPalette p = NeonThemeExt.of(context).palette;
    final NeonStyle style = NeonStyle.of(context);
    final Color accent = accentColor ?? p.primary;
    final bool disabled = onTap == null && onLongPress == null;

    // Tile sem ação é só informativo: apaga menos que um controle
    // desabilitado (0.7 em vez de kNeonDisabledOpacity).
    return Opacity(
      opacity: disabled && !selected ? 0.7 : 1,
      child: NeonPressable(
        onTap: onTap,
        onLongPress: onLongPress,
        selected: selected,
        button: !disabled,
        dimWhenDisabled: false,
        borderRadius: style.radius(14),
        child: AnimatedContainer(
          duration: NeonMotion.duration(context, kNeonFastDuration),
          padding: EdgeInsets.symmetric(
            horizontal: 14,
            vertical: dense ? 8 : 12,
          ),
          decoration: BoxDecoration(
            borderRadius: style.radius(14),
            color: selected
                ? accent.withValues(alpha: 0.14)
                : p.surface.withValues(alpha: style.surfaceAlpha(0.5)),
            border: style.borderAll(
              color: selected
                  ? accent.withValues(alpha: 0.6)
                  : p.surfaceOutline.withValues(alpha: 0.45),
            ),
            boxShadow: style.shadows(
              selected
                  ? <BoxShadow>[
                      BoxShadow(
                        color: accent.withValues(alpha: 0.28),
                        blurRadius: 14,
                        spreadRadius: -3,
                      ),
                    ]
                  : null,
            ),
          ),
          child: Row(
            children: <Widget>[
              if (leading case final Widget leading) ...<Widget>[
                leading,
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: p.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle case final String subtitle) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: p.textMuted),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing case final Widget trailing) ...<Widget>[
                const SizedBox(width: 8),
                trailing,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
