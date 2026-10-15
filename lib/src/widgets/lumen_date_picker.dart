import 'package:material_ui/material_ui.dart';

import '../foundation/lumen_decorations.dart';
import '../foundation/lumen_pressable.dart';
import '../theme/lumen_palette.dart';
import '../theme/lumen_style.dart';

/// Opens the standard [showDatePicker] with the neon theme applied.
///
/// Uses [initialDate] as the initial date and limits selection to the range
/// between [firstDate] and [lastDate]. [accentColor] overrides the default
/// accent, and [helpText] is passed to the Material picker.
Future<DateTime?> showLumenDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  Color? accentColor,
  String? helpText,
}) {
  final LumenPalette p = LumenThemeExt.of(context).palette;
  final Color accent = accentColor ?? p.primary;

  return showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
    helpText: helpText,
    builder: (BuildContext ctx, Widget? child) {
      final ThemeData base = Theme.of(ctx);
      return Theme(
        data: base.copyWith(
          colorScheme: base.colorScheme.copyWith(
            primary: accent,
            onPrimary: p.textPrimary,
            surface: p.surface,
            onSurface: p.textPrimary,
          ),
          dialogTheme: DialogThemeData(backgroundColor: p.backgroundMid),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: accent),
          ),
        ),
        child: child ?? const SizedBox.shrink(),
      );
    },
  );
}

/// Read-only field that opens [showLumenDatePicker] when tapped.
class LumenDatePicker extends StatelessWidget {
  /// Creates a read-only field that opens a date picker when tapped.
  const LumenDatePicker({
    required this.value,
    required this.firstDate,
    required this.lastDate,
    required this.onChanged,
    super.key,
    this.label,
    this.hint,
    this.accentColor,
    this.format,
  });

  /// Currently selected date.
  final DateTime? value;

  /// Earliest date allowed in the picker.
  final DateTime firstDate;

  /// Latest date allowed in the picker.
  final DateTime lastDate;

  /// Callback called when a new date is selected.
  ///
  /// When `null`, the field appears disabled.
  final ValueChanged<DateTime>? onChanged;

  /// Label displayed by the field.
  final String? label;

  /// Text displayed when [value] is `null`.
  final String? hint;

  /// Accent color override. Default: `palette.primary`.
  final Color? accentColor;

  /// Formatter used to display [value].
  final String Function(DateTime)? format;

  String _defaultFormat(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';

  @override
  Widget build(BuildContext context) {
    final LumenPalette p = LumenThemeExt.of(context).palette;
    final LumenStyle style = LumenStyle.of(context);
    final Color accent = accentColor ?? p.primary;
    final disabled = onChanged == null;
    final String? text = value == null
        ? null
        : (format ?? _defaultFormat)(value!);

    return LumenPressable(
      borderRadius: style.radius(12),
      onTap: disabled
          ? null
          : () async {
              final DateTime? picked = await showLumenDatePicker(
                context: context,
                initialDate: _clamp(value ?? DateTime.now()),
                firstDate: firstDate,
                lastDate: lastDate,
                accentColor: accent,
              );
              if (picked != null) {
                onChanged!(picked);
              }
            },
      child: InputDecorator(
        decoration: LumenDecorations.input(
          p,
          style,
          accent: accent,
          label: label,
          hint: hint,
          prefixIcon: Icon(Icons.calendar_today_rounded, color: accent),
        ),
        isEmpty: text == null,
        child: Text(
          text ?? '',
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(color: p.textPrimary),
        ),
      ),
    );
  }

  // showDatePicker requires initialDate to be within [firstDate, lastDate];
  // "today" outside the range caused an assertion failure in the app.
  DateTime _clamp(DateTime d) => d.isBefore(firstDate)
      ? firstDate
      : d.isAfter(lastDate)
      ? lastDate
      : d;
}
