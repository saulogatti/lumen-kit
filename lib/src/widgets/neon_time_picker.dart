import 'package:material_ui/material_ui.dart';

import '../foundation/neon_decorations.dart';
import '../foundation/neon_pressable.dart';
import '../theme/neon_palette.dart';
import '../theme/neon_style.dart';

/// Abre o [showTimePicker] padrão aplicando o tema neon.
///
/// [initialTime] é o horário inicial, [accentColor] substitui o accent padrão
/// e [helpText] é repassado ao picker do Material. [use24HourFormat] força
/// (ou desliga) o relógio de 24h; quando `null`, segue a configuração do
/// sistema.
Future<TimeOfDay?> showNeonTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
  Color? accentColor,
  String? helpText,
  bool? use24HourFormat,
  TimePickerEntryMode initialEntryMode = TimePickerEntryMode.dial,
}) {
  final NeonPalette p = NeonThemeExt.of(context).palette;
  final NeonStyle s = NeonStyle.of(context);
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

/// Campo somente-leitura que abre o [showNeonTimePicker] ao ser tocado.
/// Par do `NeonDatePicker` para formulários de agendamento.
class NeonTimePicker extends StatelessWidget {
  /// Cria um campo somente-leitura que abre um time picker ao toque.
  const NeonTimePicker({
    required this.value,
    required this.onChanged,
    super.key,
    this.label,
    this.hint,
    this.accentColor,
    this.format,
    this.use24HourFormat,
  });

  /// Horário atualmente selecionado.
  final TimeOfDay? value;

  /// Callback chamado quando um novo horário é escolhido.
  ///
  /// Quando `null`, o campo fica visualmente desabilitado.
  final ValueChanged<TimeOfDay>? onChanged;

  /// Rótulo exibido pelo campo.
  final String? label;

  /// Texto exibido quando [value] é `null`.
  final String? hint;

  /// Override da cor de destaque. Default: `palette.primary`.
  final Color? accentColor;

  /// Formatador usado para exibir [value]. Default: formato do locale, em
  /// 12h ou 24h conforme [use24HourFormat] / sistema.
  final String Function(TimeOfDay)? format;

  /// Força o relógio de 24h (no campo e no picker). `null` segue o sistema.
  final bool? use24HourFormat;

  @override
  Widget build(BuildContext context) {
    final NeonPalette p = NeonThemeExt.of(context).palette;
    final NeonStyle style = NeonStyle.of(context);
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

    return NeonPressable(
      borderRadius: style.radius(12),
      onTap: disabled
          ? null
          : () async {
              final TimeOfDay? picked = await showNeonTimePicker(
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
        decoration: NeonDecorations.input(
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
