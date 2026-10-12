import 'package:material_ui/material_ui.dart';

import '../foundation/neon_decorations.dart';
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
    this.validator,
    this.autovalidateMode,
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

  /// Validação usada por um [Form] ancestral.
  final FormFieldValidator<T>? validator;

  /// Quando validar automaticamente.
  final AutovalidateMode? autovalidateMode;

  @override
  Widget build(BuildContext context) {
    final NeonPalette p = NeonThemeExt.of(context).palette;
    final NeonStyle style = NeonStyle.of(context);
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
        for (final NeonDropdownItem<T> it in items)
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
      decoration: NeonDecorations.input(
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
