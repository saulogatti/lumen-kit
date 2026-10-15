import 'package:material_ui/material_ui.dart';

import '../foundation/lumen_decorations.dart';
import '../foundation/lumen_pressable.dart';
import '../theme/lumen_palette.dart';
import '../theme/lumen_style.dart';

/// Opens the standard [showTimePicker] with the neon theme applied.
///
/// [initialTime] is the initial time, [accentColor] overrides the default
/// accent, and [helpText] is passed to the Material picker. [use24HourFormat]
/// forces (or disables) the 24-hour clock; when `null`, follows the system
/// setting.
Future<TimeOfDay?> showLumenTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
  Color? accentColor,
  String? helpText,
  bool? use24HourFormat,
  TimePickerEntryMode initialEntryMode = TimePickerEntryMode.dial,
}) {
  final LumenPalette p = LumenThemeExt.of(context).palette;
  final LumenStyle s = LumenStyle.of(context);
  final Color accent = accentColor ?? p.primary;

  return showTimePicker(
    context: context,
    initialTime: initialTime,
    helpText: helpText,
    initialEntryMode: initialEntryMode,
    builder: (BuildContext ctx, Widget? child) {
      final ThemeData base = Theme.of(ctx);
      Widget picker = Theme(
        data: base.copyWith(
          colorScheme: base.colorScheme.copyWith(
            primary: accent,
            onPrimary: p.textPrimary,
            surface: p.surface,
            onSurface: p.textPrimary,
            onSurfaceVariant: p.textSecondary,
            primaryContainer: accent.withValues(alpha: 0.22),
            onPrimaryContainer: accent,
            tertiaryContainer: accent.withValues(alpha: 0.22),
            onTertiaryContainer: accent,
            surfaceContainerHighest: p.backgroundSoft,
            outline: p.surfaceOutline,
          ),
          timePickerTheme: TimePickerThemeData(
            backgroundColor: p.backgroundMid,
            dialBackgroundColor: p.surface,
            dialHandColor: accent,
            entryModeIconColor: accent,
            shape: RoundedRectangleBorder(borderRadius: s.radius(24)),
            hourMinuteShape: RoundedRectangleBorder(borderRadius: s.radius(12)),
            dayPeriodShape: RoundedRectangleBorder(borderRadius: s.radius(10)),
            dayPeriodBorderSide: BorderSide(
              color: accent.withValues(alpha: 0.45),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: accent),
          ),
        ),
        child: child ?? const SizedBox.shrink(),
      );
      if (use24HourFormat != null) {
        picker = MediaQuery(
          data: MediaQuery.of(ctx)
              .copyWith(alwaysUse24HourFormat: use24HourFormat),
          child: picker,
        );
      }
      return picker;
    },
  );
}

/// Read-only field that opens [showLumenTimePicker] when tapped.
/// Counterpart to `LumenDatePicker` for scheduling forms.
class LumenTimePicker extends StatelessWidget {
  /// Creates a read-only field that opens a time picker when tapped.
  const LumenTimePicker({
    required this.value,
    required this.onChanged,
    super.key,
    this.label,
    this.hint,
    this.accentColor,
    this.format,
    this.use24HourFormat,
  });

  /// Currently selected time.
  final TimeOfDay? value;

  /// Callback called when a new time is selected.
  ///
  /// When `null`, the field appears disabled.
  final ValueChanged<TimeOfDay>? onChanged;

  /// Label displayed by the field.
  final String? label;

  /// Text displayed when [value] is `null`.
  final String? hint;

  /// Accent color override. Default: `palette.primary`.
  final Color? accentColor;

  /// Formatter used to display [value]. Default: locale format, in 12- or
  /// 24-hour time according to [use24HourFormat] / system settings.
  final String Function(TimeOfDay)? format;

  /// Forces a 24-hour clock (in the field and picker). `null` follows the system.
  final bool? use24HourFormat;

  @override
  Widget build(BuildContext context) {
    final LumenPalette p = LumenThemeExt.of(context).palette;
    final LumenStyle style = LumenStyle.of(context);
    final Color accent = accentColor ?? p.primary;
    final disabled = onChanged == null;
    final String? text = value == null
        ? null
        : (format?.call(value!) ??
              MaterialLocalizations.of(context).formatTimeOfDay(
                value!,
                alwaysUse24HourFormat:
                    use24HourFormat ??
                    MediaQuery.alwaysUse24HourFormatOf(context),
              ));

    return LumenPressable(
      borderRadius: style.radius(12),
      onTap: disabled
          ? null
          : () async {
              final TimeOfDay? picked = await showLumenTimePicker(
                context: context,
                initialTime: value ?? TimeOfDay.now(),
                accentColor: accent,
                use24HourFormat: use24HourFormat,
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
          prefixIcon: Icon(Icons.schedule_rounded, color: accent),
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
}
