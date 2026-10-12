import 'package:material_ui/material_ui.dart';

import '../theme/neon_palette.dart';

/// Divider em gradiente accent que desbota nas pontas. Suporta orientação
/// horizontal (default) ou vertical, e um [label] opcional centralizado.
class NeonDivider extends StatelessWidget {
  /// Cria um divisor neon horizontal ou vertical.
  const NeonDivider({
    super.key,
    this.thickness = 1,
    this.indent = 0,
    this.endIndent = 0,
    this.vertical = false,
    this.label,
    this.accentColor,
  });

  /// Espessura da linha em pixels lógicos.
  final double thickness;

  /// Espaço antes da linha no eixo principal.
  final double indent;

  /// Espaço depois da linha no eixo principal.
  final double endIndent;

  /// Se `true`, desenha o divisor na vertical.
  final bool vertical;

  /// Texto central exibido apenas no modo horizontal.
  final String? label;

  /// Override da cor de destaque. Default: `palette.primary`.
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final NeonPalette p = NeonThemeExt.of(context).palette;
    final Color accent = accentColor ?? p.primary;
    final List<Color> colors = <Color>[
      accent.withValues(alpha: 0),
      accent.withValues(alpha: 0.65),
      p.secondary.withValues(alpha: 0.65),
      accent.withValues(alpha: 0),
    ];

    if (vertical) {
      return Padding(
        padding: EdgeInsets.only(top: indent, bottom: endIndent),
        child: Container(
          width: thickness,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: colors,
            ),
          ),
        ),
      );
    }

    final Widget line = Container(
      height: thickness,
      decoration: BoxDecoration(gradient: LinearGradient(colors: colors)),
    );

    if (label == null) {
      return Padding(
        padding: EdgeInsets.only(left: indent, right: endIndent),
        child: line,
      );
    }

    return Padding(
      padding: EdgeInsets.only(left: indent, right: endIndent),
      child: Row(
        children: <Widget>[
          Expanded(child: line),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label!,
              style: TextStyle(
                color: p.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Expanded(child: line),
        ],
      ),
    );
  }
}
