import 'package:lumen_kit/src/foundation/lumen_pressable.dart';
import 'package:lumen_kit/src/foundation/lumen_tokens.dart';
import 'package:lumen_kit/src/theme/lumen_palette.dart';
import 'package:lumen_kit/src/theme/lumen_style.dart';
import 'package:material_ui/material_ui.dart';

/// Selectable chip: base of filters and choices.
///
/// Different from `LumenStatusChip` and `LumenTag`, which only display.
/// For ready-made groups, use [LumenChoiceChips] (one value) or
/// [LumenFilterChips] (various).
class LumenChip extends StatelessWidget {
  /// Create a chip.
  ///
  /// With [onSelected] `null` is disabled.
  const LumenChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    super.key,
    this.icon,
    this.accentColor,
    this.showCheckmark = false,
  });

  /// Chip text.
  final String label;

  /// If the chip is marked.
  final bool selected;

  /// Called with the new state (`!selected`) when ringing.
  final ValueChanged<bool>? onSelected;

  /// Icon before [label].
  ///
  /// Add when the check appears.
  final IconData? icon;

  /// Accent override.
  ///
  /// Default: `palette.primary`.
  final Color? accentColor;

  /// Shows a check when [selected] (filter chip pattern).
  final bool showCheckmark;

  @override
  Widget build(BuildContext context) {
    final p = LumenThemeExt.of(context).palette;
    final s = LumenStyle.of(context);
    final accent = accentColor ?? p.primary;
    final radius = s.radius(20);
    final fg = selected ? accent : p.textSecondary;
    final leading = selected && showCheckmark
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

/// Option of [LumenChoiceChips] and [LumenFilterChips].
class LumenChipItem<T> {
  /// Creates an option with [value] and [label].
  const LumenChipItem({
    required this.value,
    required this.label,
    this.icon,
    this.enabled = true,
  });

  /// Option value.
  final T value;

  /// Chip text.
  final String label;

  /// Optional icon before [label].
  final IconData? icon;

  /// If `false`, the chip is disabled.
  final bool enabled;
}

/// Group of single-choice chips (e.g.
///
/// "Day/Week/Month" in chip, size S/M/L).
class LumenChoiceChips<T> extends StatelessWidget {
  /// Create the group.
  ///
  /// With [onChanged] `null`, all are disabled.
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

  /// Options.
  final List<LumenChipItem<T>> items;

  /// Selected value.
  final T? value;

  /// Called with the new value (or `null` when clearing, if allowed).
  final ValueChanged<T?>? onChanged;

  /// Whether tapping the marked chip deselects it (sends `null`).
  final bool allowDeselect;

  /// Accent override.
  ///
  /// Default: `palette.primary`.
  final Color? accentColor;

  /// Horizontal space between chips.
  final double spacing;

  /// Space between lines when breaking.
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
                : (on) {
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

/// Group of filter chips (several marked at the same time, with check).
class LumenFilterChips<T> extends StatelessWidget {
  /// Create the group.
  ///
  /// With [onChanged] `null`, all are disabled.
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

  /// Options.
  final List<LumenChipItem<T>> items;

  /// Marked values.
  final Set<T> values;

  /// Called with the new set (one copy; [values] is not changed).
  final ValueChanged<Set<T>>? onChanged;

  /// Accent override.
  ///
  /// Default: `palette.primary`.
  final Color? accentColor;

  /// Shows the check on the marked chips.
  final bool showCheckmark;

  /// Horizontal space between chips.
  final double spacing;

  /// Space between lines when breaking.
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
                : (on) {
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
