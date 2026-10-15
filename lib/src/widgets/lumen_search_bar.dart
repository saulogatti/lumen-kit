import 'package:material_ui/material_ui.dart';

import '../foundation/lumen_decorations.dart';
import '../theme/lumen_palette.dart';
import '../theme/lumen_style.dart';

/// Compact search bar with a magnifying glass prefix and a clear button when
/// it has content. Keeps its own [TextEditingController] to avoid losing focus.
class LumenSearchBar extends StatefulWidget {
  /// Creates a search bar with an internal controller.
  const LumenSearchBar({
    required this.onChanged,
    super.key,
    this.hint = 'Buscar',
    this.initialValue = '',
    this.onSubmitted,
    this.accentColor,
    this.autofocus = false,
  });

  /// Callback called whenever the text changes.
  final ValueChanged<String> onChanged;

  /// Callback called when the search is submitted from the keyboard.
  final ValueChanged<String>? onSubmitted;

  /// Text displayed when the field is empty.
  final String hint;

  /// Value used to initialize the internal controller.
  final String initialValue;

  /// Accent color override. Default: `palette.primary`.
  final Color? accentColor;

  /// If `true`, requests focus automatically.
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
