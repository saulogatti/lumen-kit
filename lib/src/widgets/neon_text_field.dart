import 'package:flutter/services.dart' show TextInputFormatter;
import 'package:material_ui/material_ui.dart';

import '../foundation/neon_decorations.dart';
import '../theme/neon_palette.dart';
import '../theme/neon_style.dart';

/// Campo de texto neon. Funciona solto ou dentro de um [Form] (via
/// [validator]) e vira textarea com [maxLines] > 1.
///
/// Sem [controller], mantém um controller interno inicializado com
/// [initialValue] para preservar foco/cursor entre rebuilds.
class NeonTextField extends StatefulWidget {

  /// Cria um campo de texto neon.
  const NeonTextField({
    required this.label,
    super.key,
    this.initialValue = '',
    this.onChanged,
    this.controller,
    this.focusNode,
    this.errorText,
    this.hint,
    this.helperText,
    this.icon,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.suffix,
    this.validator,
    this.onSubmitted,
    this.autovalidateMode,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.minLines,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.autofillHints,
    this.accentColor,
  });
  /// Rótulo exibido pelo campo.
  final String label;

  /// Texto inicial do controller interno. Ignorado quando há [controller].
  final String initialValue;

  /// Callback chamado quando o texto muda.
  final ValueChanged<String>? onChanged;

  /// Controller externo. Quem cria é quem descarta.
  final TextEditingController? controller;

  /// Foco externo, para encadear campos ou focar via código.
  final FocusNode? focusNode;

  /// Mensagem de erro exibida abaixo do campo (sobrepõe o [validator]).
  final String? errorText;

  /// Texto de dica exibido com o campo vazio.
  final String? hint;

  /// Texto de ajuda exibido abaixo do campo.
  final String? helperText;

  /// Ícone opcional exibido antes do texto.
  final IconData? icon;

  /// Se `true`, oculta o texto digitado.
  final bool obscure;

  /// Tipo de teclado solicitado ao sistema.
  final TextInputType? keyboardType;

  /// Ação do botão de confirmação do teclado (próximo, concluir…).
  final TextInputAction? textInputAction;

  /// Widget opcional exibido no final do campo.
  final Widget? suffix;

  /// Validação usada por um [Form] ancestral.
  final FormFieldValidator<String>? validator;

  /// Callback ao confirmar pelo teclado.
  final ValueChanged<String>? onSubmitted;

  /// Quando validar automaticamente.
  final AutovalidateMode? autovalidateMode;

  /// Se `false`, o campo fica desabilitado.
  final bool enabled;

  /// Se `true`, o texto não pode ser editado (mas pode ser selecionado).
  final bool readOnly;

  /// Se `true`, solicita foco ao aparecer.
  final bool autofocus;

  /// Mínimo de linhas visíveis (textarea).
  final int? minLines;

  /// Máximo de linhas. `null` cresce sem limite.
  final int? maxLines;

  /// Limite de caracteres, com contador.
  final int? maxLength;

  /// Formatadores aplicados à entrada.
  final List<TextInputFormatter>? inputFormatters;

  /// Dicas de preenchimento automático.
  final Iterable<String>? autofillHints;

  /// Override da cor de destaque. Default: `palette.primary`.
  final Color? accentColor;

  @override
  State<NeonTextField> createState() => _NeonTextFieldState();
}

class _NeonTextFieldState extends State<NeonTextField> {
  TextEditingController? _internal;

  TextEditingController get _controller =>
      widget.controller ??
      (_internal ??= TextEditingController(text: widget.initialValue));

  @override
  Widget build(BuildContext context) {
    final NeonPalette p = NeonThemeExt.of(context).palette;
    final NeonStyle style = NeonStyle.of(context);
    final Color accent = widget.accentColor ?? p.primary;
    return TextFormField(
      controller: _controller,
      focusNode: widget.focusNode,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      validator: widget.validator,
      autovalidateMode: widget.autovalidateMode,
      obscureText: widget.obscure,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      minLines: widget.minLines,
      maxLines: widget.obscure ? 1 : widget.maxLines,
      maxLength: widget.maxLength,
      inputFormatters: widget.inputFormatters,
      autofillHints: widget.autofillHints,
      cursorColor: accent,
      style: Theme.of(context).textTheme.titleMedium,
      decoration: NeonDecorations.input(
        p,
        style,
        accent: accent,
        label: widget.label,
        hint: widget.hint,
        helper: widget.helperText,
        error: widget.errorText,
        prefixIcon: widget.icon == null
            ? null
            : Icon(widget.icon, color: accent),
        suffixIcon: widget.suffix,
      ).copyWith(alignLabelWithHint: (widget.maxLines ?? 2) > 1),
    );
  }

  @override
  void didUpdateWidget(NeonTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Passou a usar controller interno: herda o texto do externo antigo.
    if (oldWidget.controller != null && widget.controller == null) {
      _internal ??= TextEditingController.fromValue(
        oldWidget.controller!.value,
      );
    }
  }

  @override
  void dispose() {
    _internal?.dispose();
    super.dispose();
  }
}
