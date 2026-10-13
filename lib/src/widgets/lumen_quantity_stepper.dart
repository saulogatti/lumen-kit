import 'package:material_ui/material_ui.dart';

import '../foundation/lumen_tokens.dart';
import '../theme/lumen_palette.dart';
import '../theme/lumen_style.dart';
import 'lumen_icon_button.dart';

/// Input numérico "− 1 +" para carrinho e configurações. Não confundir com
/// o `LumenStepper`, que mostra etapas de um fluxo.
///
/// ```dart
/// LumenQuantityStepper(
///   value: _qtd,
///   min: 1,
///   max: 10,
///   onChanged: (int v) => setState(() => _qtd = v),
/// )
/// ```
class LumenQuantityStepper extends StatelessWidget {
  /// Cria o stepper. Com [onChanged] `null`, fica desabilitado.
  const LumenQuantityStepper({
    required this.value,
    required this.onChanged,
    super.key,
    this.min = 0,
    this.max,
    this.step = 1,
    this.accentColor,
    this.buttonSize = 36,
    this.semanticLabel,
    this.format,
  }) : assert(step > 0),
       assert(max == null || max >= min);

  /// Valor atual.
  final int value;

  /// Chamado com o novo valor, já limitado a [min]..[max].
  final ValueChanged<int>? onChanged;

  /// Menor valor. No mínimo, o "−" fica desabilitado.
  final int min;

  /// Maior valor. `null` = sem limite.
  final int? max;

  /// Quanto cada toque soma ou subtrai.
  final int step;

  /// Override do accent. Default: `palette.primary`.
  final Color? accentColor;

  /// Lado dos botões − e +.
  final double buttonSize;

  /// Rótulo para leitores de tela (ex.: "Quantidade").
  final String? semanticLabel;

  /// Formata o valor exibido (ex.: `(v) => '$v un.'`).
  final String Function(int value)? format;

  int _clamp(int v) {
    final int low = v < min ? min : v;
    return max != null && low > max! ? max! : low;
  }

  @override
  Widget build(BuildContext context) {
    final LumenPalette p = LumenThemeExt.of(context).palette;
    final LumenStyle s = LumenStyle.of(context);
    final Color accent = accentColor ?? p.primary;
    final int current = _clamp(value);
    final enabled = onChanged != null;
    final bool canDec = enabled && current > min;
    final bool canInc = enabled && (max == null || current < max!);
    final VoidCallback? dec = canDec
        ? () => onChanged!(_clamp(current - step))
        : null;
    final VoidCallback? inc = canInc
        ? () => onChanged!(_clamp(current + step))
        : null;
    final String text = format?.call(current) ?? '$current';

    return Semantics(
      container: true,
      enabled: enabled,
      label: semanticLabel,
      value: text,
      increasedValue: canInc
          ? (format?.call(_clamp(current + step)) ??
                '${_clamp(current + step)}')
          : null,
      decreasedValue: canDec
          ? (format?.call(_clamp(current - step)) ??
                '${_clamp(current - step)}')
          : null,
      onIncrease: inc,
      onDecrease: dec,
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            borderRadius: s.radius(buttonSize / 2 + 3),
            color: p.surface.withValues(alpha: s.surfaceAlpha(0.6)),
            border: s.borderAll(
              color: accent.withValues(alpha: enabled ? 0.5 : 0.25),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              LumenIconButton.ghost(
                icon: Icons.remove_rounded,
                onPressed: dec,
                accentColor: accent,
                size: buttonSize,
                iconSize: 18,
              ),
              ConstrainedBox(
                constraints: BoxConstraints(minWidth: buttonSize),
                child: AnimatedSwitcher(
                  duration: LumenMotion.duration(context, kLumenFastDuration),
                  transitionBuilder: (Widget child, Animation<double> a) =>
                      ScaleTransition(
                        scale: Tween<double>(begin: 0.7, end: 1).animate(a),
                        child: FadeTransition(opacity: a, child: child),
                      ),
                  child: Text(
                    text,
                    key: ValueKey<int>(current),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: enabled ? p.textPrimary : p.textMuted,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const <FontFeature>[
                        FontFeature.tabularFigures(),
                      ],
                    ),
                  ),
                ),
              ),
              LumenIconButton.ghost(
                icon: Icons.add_rounded,
                onPressed: inc,
                accentColor: accent,
                size: buttonSize,
                iconSize: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
