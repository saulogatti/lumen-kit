import 'package:flutter/material.dart';

import '../theme/neon_palette.dart';

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
  final Color accent = accentColor ?? p.accentCyan;

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

  /// Override da cor de destaque. Default: `palette.accentCyan`.
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
    final Color accent = accentColor ?? p.accentCyan;
    final bool disabled = onChanged == null;
    final String? text = value == null
        ? null
        : (format ?? _defaultFormat)(value!);

    return Opacity(
      opacity: disabled ? 0.55 : 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: disabled
            ? null
            : () async {
                final DateTime? picked = await showNeonDatePicker(
                  context: context,
                  initialDate: value ?? DateTime.now(),
                  firstDate: firstDate,
                  lastDate: lastDate,
                  accentColor: accent,
                );
                if (picked != null) onChanged!(picked);
              },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: Icon(Icons.calendar_today_rounded, color: accent),
            filled: true,
            fillColor: p.surface.withValues(alpha: 0.7),
            labelStyle: TextStyle(color: p.textMuted),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: accent.withValues(alpha: 0.35)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: accent, width: 1.4),
            ),
          ),
          isEmpty: text == null,
          child: Text(
            text ?? '',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: p.textPrimary),
          ),
        ),
      ),
    );
  }
}
