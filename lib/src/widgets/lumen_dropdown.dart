import 'package:material_ui/material_ui.dart';

import '../foundation/lumen_decorations.dart';
import '../theme/lumen_palette.dart';
import '../theme/lumen_style.dart';

/// Item displayed in [LumenDropdown]. Preserves the generic value type.
class LumenDropdownItem<T> {
  /// Creates a dropdown item with [value] and [label].
  const LumenDropdownItem({
    required this.value,
    required this.label,
    this.icon,
  });

  /// Value returned when this item is selected.
  final T value;

  /// Text displayed in the options list.
  final String label;

  /// Optional icon displayed before [label].
  final IconData? icon;
}

/// Dropdown styled with the theme's border and glow. Replaces the standard
/// [DropdownButton] using [DropdownButtonFormField].
class LumenDropdown<T> extends StatelessWidget {
  /// Creates a neon dropdown for values of type [T].
  const LumenDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    super.key,
    this.label,
    this.hint,
    this.icon,
    this.accentColor,
    this.errorText,
    this.validator,
    this.autovalidateMode,
  });

  /// Currently selected value.
  final T? value;

  /// Options displayed by the dropdown.
  final List<LumenDropdownItem<T>> items;

  /// Callback called when the selection changes.
  ///
  /// When `null`, the dropdown is disabled by [DropdownButtonFormField].
  final ValueChanged<T?>? onChanged;

  /// Label displayed by the field.
  final String? label;

  /// Text displayed when no value is selected.
  final String? hint;

  /// Optional icon displayed at the beginning of the field.
  final IconData? icon;

  /// Accent color override. Default: `palette.primary`.
  final Color? accentColor;

  /// Error message displayed below the field.
  final String? errorText;

  /// Validation used by an ancestor [Form].
  final FormFieldValidator<T>? validator;

  /// When to validate automatically.
  final AutovalidateMode? autovalidateMode;

  @override
  Widget build(BuildContext context) {
    final LumenPalette p = LumenThemeExt.of(context).palette;
    final LumenStyle style = LumenStyle.of(context);
    final Color accent = accentColor ?? p.primary;

    return DropdownButtonFormField<T>(
      initialValue: value,
      onChanged: onChanged,
      validator: validator,
      autovalidateMode: autovalidateMode,
      dropdownColor: p.surface,
      iconEnabledColor: accent,
      style: Theme.of(context).textTheme.titleMedium,
      isExpanded: true,
      borderRadius: style.radius(12),
      hint: hint == null
          ? null
          : Text(hint!, style: TextStyle(color: p.textMuted)),
      items: <DropdownMenuItem<T>>[
        for (final LumenDropdownItem<T> it in items)
          DropdownMenuItem<T>(
            value: it.value,
            child: Row(
              spacing: 10,
              children: <Widget>[
                if (it.icon != null) Icon(it.icon, color: accent, size: 18),
                Flexible(
                  child: Text(
                    it.label,
                    style: TextStyle(color: p.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
      ],
      decoration: LumenDecorations.input(
        p,
        style,
        accent: accent,
        label: label,
        error: errorText,
        prefixIcon: icon == null ? null : Icon(icon, color: accent),
      ),
    );
  }
}
