import 'package:material_ui/material_ui.dart';

import '../theme/neon_palette.dart';
import '../theme/neon_style.dart';

/// Item exibido no [NeonDropdown]. Mantém o tipo do valor genérico.
class NeonDropdownItem<T> {
  /// Cria um item de dropdown com [value] e [label].
  const NeonDropdownItem({required this.value, required this.label, this.icon});

  /// Valor retornado quando este item é selecionado.
  final T value;

  /// Texto exibido na lista de opções.
  final String label;

  /// Ícone opcional exibido antes de [label].
  final IconData? icon;
}

/// Dropdown estilizado com a borda e o glow do tema. Substitui o
/// [DropdownButton] padrão usando [DropdownButtonFormField].
class NeonDropdown<T> extends StatelessWidget {
  /// Cria um dropdown neon para valores do tipo [T].
  const NeonDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    super.key,
    this.label,
    this.hint,
    this.icon,
    this.accentColor,
    this.errorText,
  });

  /// Valor atualmente selecionado.
  final T? value;

  /// Opções exibidas pelo dropdown.
  final List<NeonDropdownItem<T>> items;

  /// Callback chamado quando a seleção muda.
  ///
  /// Quando `null`, o dropdown fica desabilitado pelo [DropdownButtonFormField].
  final ValueChanged<T?>? onChanged;

  /// Rótulo exibido pelo campo.
  final String? label;

  /// Texto exibido quando nenhum valor foi selecionado.
  final String? hint;

  /// Ícone opcional exibido no início do campo.
  final IconData? icon;

  /// Override da cor de destaque. Default: `palette.primary`.
  final Color? accentColor;

  /// Mensagem de erro exibida abaixo do campo.
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final NeonPalette p = NeonThemeExt.of(context).palette;
    final NeonStyle style = NeonStyle.of(context);
    final Color accent = accentColor ?? p.primary;

    return DropdownButtonFormField<T>(
      initialValue: value,
      onChanged: onChanged,
      dropdownColor: p.surface,
      iconEnabledColor: accent,
      style: Theme.of(context).textTheme.titleMedium,
      isExpanded: true,
      borderRadius: style.radius(12),
      hint: hint == null
          ? null
          : Text(hint!, style: TextStyle(color: p.textMuted)),
      items: items
          .map(
            (NeonDropdownItem<T> it) => DropdownMenuItem<T>(
              value: it.value,
              child: Row(
                children: <Widget>[
                  if (it.icon != null) ...<Widget>[
                    Icon(it.icon, color: accent, size: 18),
                    const SizedBox(width: 10),
                  ],
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
          )
          .toList(),
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        prefixIcon: icon == null ? null : Icon(icon, color: accent),
        filled: true,
        fillColor: p.surface.withValues(alpha: style.surfaceAlpha(0.7)),
        labelStyle: TextStyle(color: p.textMuted),
        enabledBorder: OutlineInputBorder(
          borderRadius: style.radius(12),
          borderSide: BorderSide(color: accent.withValues(alpha: 0.35)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: style.radius(12),
          borderSide: BorderSide(color: accent, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: style.radius(12),
          borderSide: BorderSide(color: p.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: style.radius(12),
          borderSide: BorderSide(color: p.danger, width: 1.4),
        ),
      ),
    );
  }
}
