import 'package:material_ui/material_ui.dart';

import '../foundation/lumen_decorations.dart';
import '../theme/lumen_palette.dart';
import '../theme/lumen_style.dart';

/// Barra de busca compacta, com prefixo de lupa e botão de limpar quando há
/// conteúdo. Mantém o próprio [TextEditingController] para evitar perda de foco.
class LumenSearchBar extends StatefulWidget {
  /// Cria uma barra de busca com controller interno.
  const LumenSearchBar({
    required this.onChanged,
    super.key,
    this.hint = 'Buscar',
    this.initialValue = '',
    this.onSubmitted,
    this.accentColor,
    this.autofocus = false,
  });

  /// Callback chamado a cada alteração do texto.
  final ValueChanged<String> onChanged;

  /// Callback chamado ao submeter a busca pelo teclado.
  final ValueChanged<String>? onSubmitted;

  /// Texto exibido quando o campo está vazio.
  final String hint;

  /// Valor usado para inicializar o controller interno.
  final String initialValue;

  /// Override da cor de destaque. Default: `palette.primary`.
  final Color? accentColor;

  /// Se `true`, solicita foco automaticamente.
  final bool autofocus;

  @override
  State<LumenSearchBar> createState() => _LumenSearchBarState();
}

class _LumenSearchBarState extends State<LumenSearchBar> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleChanged(String value) {
    widget.onChanged(value);
    setState(() {});
  }

  void _clear() {
    _controller.clear();
    _handleChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final LumenPalette p = LumenThemeExt.of(context).palette;
    final LumenStyle style = LumenStyle.of(context);
    final Color accent = widget.accentColor ?? p.primary;
    final bool hasText = _controller.text.isNotEmpty;

    return TextField(
      controller: _controller,
      autofocus: widget.autofocus,
      onChanged: _handleChanged,
      onSubmitted: widget.onSubmitted,
      style: Theme.of(context).textTheme.titleMedium,
      textInputAction: TextInputAction.search,
      decoration: LumenDecorations.input(
        p,
        style,
        accent: accent,
        radius: 28,
        hint: widget.hint,
        enabledBorderAlpha: 0.3,
        prefixIcon: Icon(Icons.search_rounded, color: accent),
        suffixIcon: hasText
            ? IconButton(
                icon: Icon(Icons.close_rounded, color: p.textMuted),
                onPressed: _clear,
                tooltip: 'Limpar',
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
