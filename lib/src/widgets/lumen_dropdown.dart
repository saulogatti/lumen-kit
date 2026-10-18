import 'package:lumen_kit/src/foundation/lumen_decorations.dart';
import 'package:lumen_kit/src/theme/lumen_palette.dart';
import 'package:lumen_kit/src/theme/lumen_style.dart';
import 'package:material_ui/material_ui.dart';

/// Item displayed on [LumenDropdown].
///
/// Maintains the type of the generic value.
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

/// Stylized dropdown with theme border and glow.
///
/// Replaces the [DropdownButton] defaults to [DropdownButtonFormField].
class LumenDropdown<T> extends StatelessWidget {
  /// Creates a neon dropdown for values ​​of type [T].
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

  /// Options displayed by dropdown.
  final List<LumenDropdownItem<T>> items;

  /// Callback called when the selection changes.
  /// When `null`, the dropdown is disabled by [DropdownButtonFormField].
  final ValueChanged<T?>? onChanged;

  /// Label displayed by the field.
  final String? label;

  /// Text displayed when no value has been selected.
  final String? hint;

  /// Optional icon displayed at the beginning of the field.
  final IconData? icon;

  /// Highlight color override.
  ///
  /// Default: `palette.primary`.
  final Color? accentColor;

  /// Error message displayed below the field.
  final String? errorText;

  /// Validation used by an ancestor [Form].
  final FormFieldValidator<T>? validator;

  /// When to validate automatically.
  final AutovalidateMode? autovalidateMode;

  @override
  Widget build(BuildContext context) {
    final p = LumenThemeExt.of(context).palette;
    final style = LumenStyle.of(context);
    final accent = accentColor ?? p.primary;

    return DropdownButtonFormField<T>(
      initialValue: value,
      onChanged: onChanged,
      validator: validator,
      autovalidateMode: autovalidateMode,
      dropdownColor: p.surface,
      iconEnabledColor: accent,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(color: p.textPrimary),
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
