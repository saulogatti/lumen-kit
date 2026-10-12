import 'package:material_ui/material_ui.dart';

import '../foundation/neon_decorations.dart';
import '../foundation/neon_pressable.dart';
import '../theme/neon_palette.dart';
import '../theme/neon_style.dart';

/// Abre o [showDatePicker] padrão aplicando o tema neon.
///
/// Usa [initialDate] como data inicial e limita a seleção ao intervalo entre
/// [firstDate] e [lastDate]. [accentColor] substitui o accent padrão e
/// [helpText] é repassado ao picker do Material.
Future<DateTime?> showNeonDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  Color? accentColor,
  String? helpText,
}) {
  final NeonPalette p = NeonThemeExt.of(context).palette;
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

/// Campo somente-leitura que abre o [showNeonDatePicker] ao ser tocado.
class NeonDatePicker extends StatelessWidget {
  /// Cria um campo somente-leitura que abre um date picker ao toque.
  const NeonDatePicker({
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

  /// Data atualmente selecionada.
  final DateTime? value;

  /// Primeira data permitida no picker.
  final DateTime firstDate;

  /// Última data permitida no picker.
  final DateTime lastDate;

  /// Callback chamado quando uma nova data é escolhida.
  ///
  /// Quando `null`, o campo fica visualmente desabilitado.
  final ValueChanged<DateTime>? onChanged;

  /// Rótulo exibido pelo campo.
  final String? label;

  /// Texto exibido quando [value] é `null`.
  final String? hint;

  /// Override da cor de destaque. Default: `palette.primary`.
  final Color? accentColor;

  /// Formatador usado para exibir [value].
  final String Function(DateTime)? format;

  String _defaultFormat(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';

  @override
  Widget build(BuildContext context) {
    final NeonPalette p = NeonThemeExt.of(context).palette;
    final NeonStyle style = NeonStyle.of(context);
    final Color accent = accentColor ?? p.primary;
    final disabled = onChanged == null;
    final String? text = value == null
        ? null
        : (format ?? _defaultFormat)(value!);

    return NeonPressable(
      borderRadius: style.radius(12),
      onTap: disabled
          ? null
          : () async {
              final DateTime? picked = await showNeonDatePicker(
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
        decoration: NeonDecorations.input(
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

  // showDatePicker exige initialDate dentro de [firstDate, lastDate]; "hoje"
  // fora do intervalo derrubava o app com assert.
  DateTime _clamp(DateTime d) => d.isBefore(firstDate)
      ? firstDate
      : d.isAfter(lastDate)
      ? lastDate
      : d;
}
