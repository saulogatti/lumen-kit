import 'package:lumen_kit/src/foundation/lumen_decorations.dart';
import 'package:lumen_kit/src/theme/lumen_palette.dart';
import 'package:lumen_kit/src/theme/lumen_style.dart';
import 'package:material_ui/material_ui.dart';

/// Compact search bar, with magnifying glass prefix and clear button when there
/// is content.
///
/// Maintains [TextEditingController] itself to prevent loss of focus.
class LumenSearchBar extends StatefulWidget {
  /// Creates a search bar with internal controller.
  const LumenSearchBar({
    required this.onChanged,
    super.key,
    this.hint = 'Buscar',
    this.initialValue = '',
    this.onSubmitted,
    this.accentColor,
    this.autofocus = false,
  });

  /// Callback called with each text change.
  final ValueChanged<String> onChanged;

  /// Callback called when submitting the keyboard search.
  final ValueChanged<String>? onSubmitted;

  /// Text displayed when the field is empty.
  final String hint;

  /// Value used to initialize the internal controller.
  final String initialValue;

  /// Highlight color override.
  ///
  /// Default: `palette.primary`.
  final Color? accentColor;

  /// Whether to automatically request focus.
  final bool autofocus;

  @override
  State<LumenSearchBar> createState() => _LumenSearchBarState();
}

class _LumenSearchBarState extends State<LumenSearchBar> {
  late final TextEditingController _controller = TextEditingController(text: widget.initialValue);

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
    final p = LumenThemeExt.of(context).palette;
    final style = LumenStyle.of(context);
    final accent = widget.accentColor ?? p.primary;
    final hasText = _controller.text.isNotEmpty;

    return TextField(
      controller: _controller,
      autofocus: widget.autofocus,
      onChanged: _handleChanged,
      onSubmitted: widget.onSubmitted,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: p.textPrimary),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
