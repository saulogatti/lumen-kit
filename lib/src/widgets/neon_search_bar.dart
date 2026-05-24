import 'package:flutter/material.dart';

import '../theme/neon_palette.dart';

/// Barra de busca compacta, com prefixo de lupa e botão de limpar quando há
/// conteúdo. Mantém o próprio [TextEditingController] para evitar perda de foco.
class NeonSearchBar extends StatefulWidget {
  const NeonSearchBar({
    required this.onChanged,
    super.key,
    this.hint = 'Buscar',
    this.initialValue = '',
    this.onSubmitted,
    this.accentColor,
    this.autofocus = false,
  });

  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final String hint;
  final String initialValue;
  final Color? accentColor;
  final bool autofocus;

  @override
  State<NeonSearchBar> createState() => _NeonSearchBarState();
}

class _NeonSearchBarState extends State<NeonSearchBar> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialValue);

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
    final NeonPalette p = NeonThemeExt.of(context).palette;
    final Color accent = widget.accentColor ?? p.accentCyan;
    final bool hasText = _controller.text.isNotEmpty;

    return TextField(
      controller: _controller,
      autofocus: widget.autofocus,
      onChanged: _handleChanged,
      onSubmitted: widget.onSubmitted,
      style: Theme.of(context).textTheme.titleMedium,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: TextStyle(color: p.textMuted),
        prefixIcon: Icon(Icons.search_rounded, color: accent),
        suffixIcon: hasText
            ? IconButton(
                icon: Icon(Icons.close_rounded, color: p.textMuted),
                onPressed: _clear,
                tooltip: 'Limpar',
              )
            : null,
        filled: true,
        fillColor: p.surface.withValues(alpha: 0.7),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: accent.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: accent, width: 1.4),
        ),
      ),
    );
  }
}
