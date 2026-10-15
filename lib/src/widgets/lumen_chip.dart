import 'package:material_ui/material_ui.dart';

import '../foundation/lumen_pressable.dart';
import '../foundation/lumen_tokens.dart';
import '../theme/lumen_palette.dart';
import '../theme/lumen_style.dart';

/// Selectable chip: a building block for filters and choices. Unlike
/// `LumenStatusChip` and `LumenTag`, which are display-only.
///
/// For ready-made groups, use [LumenChoiceChips] (one value) or
/// [LumenFilterChips] (multiple values).
class LumenChip extends StatelessWidget {
  /// Creates a chip. It is disabled when [onSelected] is `null`.
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

  /// Whether the chip is selected.
  final bool selected;

  /// Called with the new state (`!selected`) when tapped.
  final ValueChanged<bool>? onSelected;

  /// Icon before [label]. Hidden when the check appears.
  final IconData? icon;

  /// Accent override. Default: `palette.primary`.
  final Color? accentColor;

  /// Shows a check when [selected] (the usual filter chip pattern).
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

/// Option for [LumenChoiceChips] and [LumenFilterChips].
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

/// Group of single-choice chips (e.g. "Day / Week / Month" as chips, or sizes
/// S/M/L).
class LumenChoiceChips<T> extends StatelessWidget {
  /// Creates the group. When [onChanged] is `null`, all chips are disabled.
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

  /// Called with the new value (or `null` when deselected, if allowed).
  final ValueChanged<T?>? onChanged;

  /// If `true`, tapping the selected chip deselects it (sends `null`).
  final bool allowDeselect;

  /// Accent override. Default: `palette.primary`.
  final Color? accentColor;

  /// Horizontal spacing between chips.
  final double spacing;

  /// Spacing between wrapped rows.
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

/// Group of filter chips (multiple can be selected at once, with a check).
class LumenFilterChips<T> extends StatelessWidget {
  /// Creates the group. When [onChanged] is `null`, all chips are disabled.
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

  /// Selected values.
  final Set<T> values;

  /// Called with the new set (a copy; [values] is not modified).
  final ValueChanged<Set<T>>? onChanged;

  /// Accent override. Default: `palette.primary`.
  final Color? accentColor;

  /// Shows a check on selected chips.
  final bool showCheckmark;

  /// Horizontal spacing between chips.
  final double spacing;

  /// Spacing between wrapped rows.
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
                    // A ternary within a cascade captures the whole
                    // expression; use an explicit if instead.
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
