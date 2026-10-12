import 'package:material_ui/material_ui.dart';

import '../foundation/neon_pressable.dart';
import '../foundation/neon_tokens.dart';
import '../theme/neon_palette.dart';
import '../theme/neon_style.dart';

/// Chip selecionável: base de filtros e escolhas. Diferente do `StatusChip`
/// e do `NeonTag`, que só exibem.
///
/// Para grupos prontos, use [NeonChoiceChips] (um valor) ou
/// [NeonFilterChips] (vários).
class NeonChip extends StatelessWidget {
  /// Cria um chip. Com [onSelected] `null`, fica desabilitado.
  const NeonChip({
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
    final NeonPalette p = NeonThemeExt.of(context).palette;
    final NeonStyle s = NeonStyle.of(context);
    final Color accent = accentColor ?? p.primary;
    final BorderRadius radius = s.radius(20);
    final Color fg = selected ? accent : p.textSecondary;
    final IconData? leading = selected && showCheckmark
        ? Icons.check_rounded
        : icon;

    return NeonPressable(
      onTap: onSelected == null ? null : () => onSelected!(!selected),
      borderRadius: radius,
      selected: selected,
      child: AnimatedContainer(
        duration: NeonMotion.duration(context, kNeonFastDuration),
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
                : p.surfaceOutline.withValues(alpha: 0.9),
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
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
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

/// Opção de [NeonChoiceChips] e [NeonFilterChips].
class NeonChipItem<T> {
  /// Cria uma opção com [value] e [label].
  const NeonChipItem({
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
class NeonChoiceChips<T> extends StatelessWidget {
  /// Cria o grupo. Com [onChanged] `null`, todos ficam desabilitados.
  const NeonChoiceChips({
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
  final List<NeonChipItem<T>> items;

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
        for (final NeonChipItem<T> item in items)
          NeonChip(
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
class NeonFilterChips<T> extends StatelessWidget {
  /// Cria o grupo. Com [onChanged] `null`, todos ficam desabilitados.
  const NeonFilterChips({
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
  final List<NeonChipItem<T>> items;

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
        for (final NeonChipItem<T> item in items)
          NeonChip(
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
                    final Set<T> next = <T>{...values};
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
