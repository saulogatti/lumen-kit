import 'package:flutter/services.dart' show TextInputFormatter;
import 'package:lumen_kit/src/foundation/lumen_decorations.dart';
import 'package:lumen_kit/src/theme/lumen_palette.dart';
import 'package:lumen_kit/src/theme/lumen_style.dart';
import 'package:material_ui/material_ui.dart';

/// Neon text field.
///
/// Works loose or inside a [Form] (via [validator]) and becomes a textarea with
/// [maxLines] > 1.
/// Without [controller], it maintains an internal controller initialized with
/// [initialValue] to preserve focus/cursor between rebuilds.
class LumenTextField extends StatefulWidget {
  /// Creates a neon text field.
  const LumenTextField({
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

  /// Label displayed by the field.
  final String label;

  /// Initial text of the internal controller.
  ///
  /// Ignored when there is [controller].
  final String initialValue;

  /// Callback called when text changes.
  final ValueChanged<String>? onChanged;

  /// External controller.
  ///
  /// The one who creates is the one who discards.
  final TextEditingController? controller;

  /// External focus, to chain fields or focus via code.
  final FocusNode? focusNode;

  /// Error message displayed below the field (overlaps [validator]).
  final String? errorText;

  /// Tip text displayed with empty field.
  final String? hint;

  /// Help text displayed below the field.
  final String? helperText;

  /// Optional icon displayed before the text.
  final IconData? icon;

  /// Whether to hide the typed text.
  final bool obscure;

  /// Type of keyboard requested from the system.
  final TextInputType? keyboardType;

  /// Keyboard confirmation button action (next, finish…).
  final TextInputAction? textInputAction;

  /// Optional widget displayed at the end of the field.
  final Widget? suffix;

  /// Validation used by an ancestor [Form].
  final FormFieldValidator<String>? validator;

  /// Callback when confirming via keyboard.
  final ValueChanged<String>? onSubmitted;

  /// When to validate automatically.
  final AutovalidateMode? autovalidateMode;

  /// If `false`, the field is disabled.
  final bool enabled;

  /// Whether the text can be be edited (but can be selected).
  final bool readOnly;

  /// Whether to request focus when appearing.
  final bool autofocus;

  /// Minimum visible lines (textarea).
  final int? minLines;

  /// Maximum lines.
  ///
  /// `null` grows without limit.
  final int? maxLines;

  /// Character limit, with counter.
  final int? maxLength;

  /// Formatters applied to input.
  final List<TextInputFormatter>? inputFormatters;

  /// Autocomplete tips.
  final Iterable<String>? autofillHints;

  /// Highlight color override.
  ///
  /// Default: `palette.primary`.
  final Color? accentColor;

  @override
  State<LumenTextField> createState() => _LumenTextFieldState();
}

class _LumenTextFieldState extends State<LumenTextField> {
  TextEditingController? _internal;

  TextEditingController get _controller =>
      widget.controller ?? (_internal ??= TextEditingController(text: widget.initialValue));

  @override
  Widget build(BuildContext context) {
    final p = LumenThemeExt.of(context).palette;
    final style = LumenStyle.of(context);
    final accent = widget.accentColor ?? p.primary;
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
      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: p.textPrimary),
      decoration: LumenDecorations.input(
        p,
        style,
        accent: accent,
        label: widget.label,
        hint: widget.hint,
        helper: widget.helperText,
        error: widget.errorText,
        prefixIcon: widget.icon == null ? null : Icon(widget.icon, color: accent),
        suffixIcon: widget.suffix,
      ).copyWith(alignLabelWithHint: (widget.maxLines ?? 2) > 1),
    );
  }

  @override
  void didUpdateWidget(LumenTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Passou a usar controller interno: herda o texto do externo antigo.
    if (oldWidget.controller != null && widget.controller == null) {
      _internal ??= TextEditingController.fromValue(oldWidget.controller!.value);
    }
  }

  @override
  void dispose() {
    _internal?.dispose();
    super.dispose();
  }
}
