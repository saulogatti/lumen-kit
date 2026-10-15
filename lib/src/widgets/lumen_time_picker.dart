import 'package:lumen_kit/src/foundation/lumen_decorations.dart';
import 'package:lumen_kit/src/foundation/lumen_pressable.dart';
import 'package:lumen_kit/src/theme/lumen_palette.dart';
import 'package:lumen_kit/src/theme/lumen_style.dart';
import 'package:material_ui/material_ui.dart';

/// Opens the default [showTimePicker] applying the neon theme.
/// [initialTime] is the start time, [accentColor] replaces the default accent
/// and [helpText] is passed to the Material picker. [use24HourFormat] strength
/// (or turns off) the 24-hour clock; when `null`, it follows the configuration
/// of the system.
Future<TimeOfDay?> showLumenTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
  Color? accentColor,
  String? helpText,
  bool? use24HourFormat,
  TimePickerEntryMode initialEntryMode = TimePickerEntryMode.dial,
}) {
  final p = LumenThemeExt.of(context).palette;
  final s = LumenStyle.of(context);
  final accent = accentColor ?? p.primary;

  return showTimePicker(
    context: context,
    initialTime: initialTime,
    helpText: helpText,
    initialEntryMode: initialEntryMode,
    builder: (ctx, child) {
      final base = Theme.of(ctx);
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

/// Read-only field that opens [showLumenTimePicker] when touched.
///
/// Pair of `LumenDatePicker` for scheduling forms.
class LumenTimePicker extends StatelessWidget {
  /// Creates a read-only field that opens a time picker on touch.
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

  /// Callback called when a new time is chosen.
  /// When `null`, the field is visually disabled.
  final ValueChanged<TimeOfDay>? onChanged;

  /// Label displayed by the field.
  final String? label;

  /// Text displayed when [value] is `null`.
  final String? hint;

  /// Highlight color override.
  ///
  /// Default: `palette.primary`.
  final Color? accentColor;

  /// Formatter used to display [value].
  ///
  /// Default: locale format, in 12h or 24h depending on [use24HourFormat] /
  /// system.
  final String Function(TimeOfDay)? format;

  /// Forces a 24-hour clock (in the field and at the picker).
  ///
  /// `null` follows the system.
  final bool? use24HourFormat;

  @override
  Widget build(BuildContext context) {
    final p = LumenThemeExt.of(context).palette;
    final style = LumenStyle.of(context);
    final accent = accentColor ?? p.primary;
    final disabled = onChanged == null;
    final text = value == null
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
              final picked = await showLumenTimePicker(
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
