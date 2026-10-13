import 'package:material_ui/material_ui.dart';

import '../foundation/lumen_pressable.dart';
import '../foundation/lumen_tokens.dart';
import '../theme/lumen_palette.dart';
import '../theme/lumen_style.dart';

/// Chip selecionável: base de filtros e escolhas. Diferente do `LumenStatusChip`
/// e do `LumenTag`, que só exibem.
///
/// Para grupos prontos, use [LumenChoiceChips] (um valor) ou
/// [LumenFilterChips] (vários).
class LumenChip extends StatelessWidget {
  /// Cria um chip. Com [onSelected] `null`, fica desabilitado.
  const LumenChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    super.key,
    this.icon,
    this.accentColor,
    this.showCheckmark = false,
  });

  /// Texto do chip.
  final String label;

  /// Se o chip está marcado.
  final bool selected;

  /// Chamado com o novo estado (`!selected`) ao tocar.
  final ValueChanged<bool>? onSelected;

  /// Ícone antes do [label]. Some quando o check aparece.
  final IconData? icon;

  /// Override do accent. Default: `palette.primary`.
  final Color? accentColor;

  /// Mostra um check quando [selected] (padrão de chips de filtro).
  final bool showCheckmark;

  @override
  Widget build(BuildContext context) {
    final LumenPalette p = LumenThemeExt.of(context).palette;
    final LumenStyle s = LumenStyle.of(context);
    final Color accent = accentColor ?? p.primary;
    final BorderRadius radius = s.radius(20);
    final Color fg = selected ? accent : p.textSecondary;
    final IconData? leading = selected && showCheckmark
        ? Icons.check_rounded
        : icon;

    return LumenPressable(
      onTap: onSelected == null ? null : () => onSelected!(!selected),
      borderRadius: radius,
      selected: selected,
      child: AnimatedContainer(
        duration: LumenMotion.duration(context, kLumenFastDuration),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: radius,
          color: selected
              ? accent.withValues(alpha: 0.16)
              : p.surface.withValues(alpha: s.surfaceAlpha(0.5)),
          border: s.borderAll(
            color: selected
                ? accent.withValues(alpha: 0.8)
                : accent.withValues(alpha: 0.35),
            width: 1.2,
          ),
          boxShadow: s.shadows(
            selected
                ? <BoxShadow>[
                    BoxShadow(
                      color: accent.withValues(alpha: 0.3),
                      blurRadius: 12,
                      spreadRadius: -2,
                    ),
                  ]
                : null,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: <Widget>[
            if (leading != null) Icon(leading, size: 16, color: fg),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: fg,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Opção de [LumenChoiceChips] e [LumenFilterChips].
class LumenChipItem<T> {
  /// Cria uma opção com [value] e [label].
  const LumenChipItem({
    required this.value,
    required this.label,
    this.icon,
    this.enabled = true,
  });

  /// Valor da opção.
  final T value;

  /// Texto do chip.
  final String label;

  /// Ícone opcional antes do [label].
  final IconData? icon;

  /// Se `false`, o chip fica desabilitado.
  final bool enabled;
}

/// Grupo de chips de escolha única (ex.: "Dia / Semana / Mês" em formato de
/// chip, tamanho P/M/G).
class LumenChoiceChips<T> extends StatelessWidget {
  /// Cria o grupo. Com [onChanged] `null`, todos ficam desabilitados.
  const LumenChoiceChips({
    required this.items,
    required this.value,
    required this.onChanged,
    super.key,
    this.allowDeselect = false,
    this.accentColor,
    this.spacing = 8,
    this.runSpacing = 8,
  });

  /// Opções.
  final List<LumenChipItem<T>> items;

  /// Valor selecionado.
  final T? value;

  /// Chamado com o novo valor (ou `null` ao desmarcar, se permitido).
  final ValueChanged<T?>? onChanged;

  /// Se `true`, tocar no chip marcado desmarca (manda `null`).
  final bool allowDeselect;

  /// Override do accent. Default: `palette.primary`.
  final Color? accentColor;

  /// Espaço horizontal entre chips.
  final double spacing;

  /// Espaço entre linhas quando quebra.
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: <Widget>[
        for (final LumenChipItem<T> item in items)
          LumenChip(
            label: item.label,
            icon: item.icon,
            accentColor: accentColor,
            selected: item.value == value,
            onSelected: onChanged == null || !item.enabled
                ? null
                : (bool on) {
                    if (on) {
                      onChanged!(item.value);
                    } else if (allowDeselect) {
                      onChanged!(null);
                    }
                  },
          ),
      ],
    );
  }
}

/// Grupo de chips de filtro (vários marcados ao mesmo tempo, com check).
class LumenFilterChips<T> extends StatelessWidget {
  /// Cria o grupo. Com [onChanged] `null`, todos ficam desabilitados.
  const LumenFilterChips({
    required this.items,
    required this.values,
    required this.onChanged,
    super.key,
    this.accentColor,
    this.showCheckmark = true,
    this.spacing = 8,
    this.runSpacing = 8,
  });

  /// Opções.
  final List<LumenChipItem<T>> items;

  /// Valores marcados.
  final Set<T> values;

  /// Chamado com o novo conjunto (uma cópia; [values] não é alterado).
  final ValueChanged<Set<T>>? onChanged;

  /// Override do accent. Default: `palette.primary`.
  final Color? accentColor;

  /// Mostra o check nos chips marcados.
  final bool showCheckmark;

  /// Espaço horizontal entre chips.
  final double spacing;

  /// Espaço entre linhas quando quebra.
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: <Widget>[
        for (final LumenChipItem<T> item in items)
          LumenChip(
            label: item.label,
            icon: item.icon,
            accentColor: accentColor,
            showCheckmark: showCheckmark,
            selected: values.contains(item.value),
            onSelected: onChanged == null || !item.enabled
                ? null
                : (bool on) {
                    // Cascata dentro de ternário pega a expressão inteira;
                    // por isso o if explícito.
                    final next = <T>{...values};
                    if (on) {
                      next.add(item.value);
                    } else {
                      next.remove(item.value);
                    }
                    onChanged!(next);
                  },
          ),
      ],
    );
  }
}
