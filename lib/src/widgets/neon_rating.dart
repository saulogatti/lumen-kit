import 'package:material_ui/material_ui.dart';

import '../foundation/neon_pressable.dart';
import '../theme/neon_palette.dart';
import '../theme/neon_style.dart';

/// Estrelas de avaliação. Com [onChanged], o usuário escolhe a nota tocando;
/// sem ele, só exibe (inclusive notas fracionadas, como 4.3).
///
/// ```dart
/// NeonRating(value: _nota, onChanged: (double v) => setState(() => _nota = v))
/// NeonRating(value: produto.media) // somente leitura
/// ```
class NeonRating extends StatelessWidget {
  /// Cria a avaliação.
  const NeonRating({
    required this.value,
    super.key,
    this.onChanged,
    this.max = 5,
    this.allowHalf = false,
    this.size = 28,
    this.spacing = 2,
    this.color,
    this.icon = Icons.star_rounded,
    this.emptyIcon = Icons.star_outline_rounded,
    this.semanticLabel,
  }) : assert(max > 0);

  /// Nota atual, de 0 a [max]. Aceita frações na exibição.
  final double value;

  /// Chamado com a nota tocada. `null` = somente leitura.
  final ValueChanged<double>? onChanged;

  /// Número de estrelas.
  final int max;

  /// Permite escolher meia estrela (toque na metade esquerda).
  final bool allowHalf;

  /// Tamanho de cada estrela.
  final double size;

  /// Espaço entre estrelas.
  final double spacing;

  /// Cor das estrelas preenchidas. Default: `palette.warning`.
  final Color? color;

  /// Ícone preenchido.
  final IconData icon;

  /// Ícone vazio.
  final IconData emptyIcon;

  /// Rótulo para leitores de tela (ex.: "Avaliação").
  final String? semanticLabel;

  String _fmt(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final NeonPalette p = NeonThemeExt.of(context).palette;
    final NeonStyle s = NeonStyle.of(context);
    final Color fill = color ?? p.warning;
    final Color idle = p.textMuted.withValues(alpha: 0.6);
    final double current = value.clamp(0, max.toDouble());
    final double step = allowHalf ? 0.5 : 1;
    final interactive = onChanged != null;
    final List<Shadow>? glow = s.shadow == NeonShadowKind.glow
        ? <Shadow>[
            Shadow(
              color: fill.withValues(alpha: 0.6 * s.shadowStrength),
              blurRadius: 10,
            ),
          ]
        : null;

    Widget star(int i) {
      final double f = (current - i).clamp(0.0, 1.0);
      final Widget body = SizedBox.square(
        dimension: size,
        child: Stack(
          children: <Widget>[
            Icon(emptyIcon, size: size, color: idle),
            if (f > 0)
              ClipRect(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  widthFactor: f,
                  child: Icon(icon, size: size, color: fill, shadows: glow),
                ),
              ),
          ],
        ),
      );
      if (!interactive) {
        return body;
      }

      final r = BorderRadius.circular(size / 2);
      if (!allowHalf) {
        return NeonPressable(
          onTap: () => onChanged!(i + 1.0),
          customBorder: const CircleBorder(),
          child: body,
        );
      }
      return Stack(
        children: <Widget>[
          body,
          Positioned.fill(
            child: Row(
              children: <Widget>[
                for (final double v in <double>[i + 0.5, i + 1.0])
                  Expanded(
                    child: NeonPressable(
                      onTap: () => onChanged!(v),
                      borderRadius: r,
                      child: const SizedBox.expand(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      );
    }

    final double up = (current + step).clamp(0, max.toDouble());
    final double down = (current - step).clamp(0, max.toDouble());
    return Semantics(
      container: true,
      label: semanticLabel,
      value: '${_fmt(current)}/$max',
      increasedValue: interactive && up != current ? '${_fmt(up)}/$max' : null,
      decreasedValue: interactive && down != current
          ? '${_fmt(down)}/$max'
          : null,
      onIncrease: interactive && up != current ? () => onChanged!(up) : null,
      onDecrease: interactive && down != current
          ? () => onChanged!(down)
          : null,
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: spacing,
          children: <Widget>[for (int i = 0; i < max; i++) star(i)],
        ),
      ),
    );
  }
}
