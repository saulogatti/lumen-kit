import 'package:material_ui/material_ui.dart';

import '../theme/neon_palette.dart';

/// TextField estilizado para o formulário de cadastro.
/// Mantém o próprio controller para preservar foco/cursor entre rebuilds.
class NeonTextField extends StatefulWidget {
  /// Cria um campo de texto controlado internamente.
  const NeonTextField({
    required this.label,
    required this.initialValue,
    required this.onChanged,
    super.key,
    this.errorText,
    this.icon,
    this.obscure = false,
    this.keyboardType,
    this.suffix,
  });

  /// Rótulo exibido pelo campo.
  final String label;

  /// Valor usado para inicializar o controller interno.
  final String initialValue;

  /// Callback chamado quando o texto muda.
  final ValueChanged<String> onChanged;

  /// Mensagem de erro exibida abaixo do campo.
  final String? errorText;

  /// Ícone opcional exibido antes do texto.
  final IconData? icon;

  /// Se `true`, oculta o texto digitado.
  final bool obscure;

  /// Tipo de teclado solicitado ao sistema.
  final TextInputType? keyboardType;

  /// Widget opcional exibido no final do campo.
  final Widget? suffix;

  @override
  State<NeonTextField> createState() => _NeonTextFieldState();
}

class _NeonTextFieldState extends State<NeonTextField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final NeonPalette p = NeonThemeExt.of(context).palette;
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      obscureText: widget.obscure,
      keyboardType: widget.keyboardType,
      style: Theme.of(context).textTheme.titleMedium,
      decoration: InputDecoration(
        labelText: widget.label,
        errorText: widget.errorText,
        prefixIcon: widget.icon == null
            ? null
            : Icon(widget.icon, color: p.primary),
        suffixIcon: widget.suffix,
        filled: true,
        fillColor: p.surface.withValues(alpha: 0.7),
        labelStyle: TextStyle(color: p.textMuted),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: p.primary.withValues(alpha: 0.35)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: p.primary, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: p.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: p.danger, width: 1.4),
        ),
      ),
    );
  }
}
