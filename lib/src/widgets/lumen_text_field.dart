import 'package:flutter/services.dart' show TextInputFormatter;
import 'package:material_ui/material_ui.dart';

import '../foundation/lumen_decorations.dart';
import '../theme/lumen_palette.dart';
import '../theme/lumen_style.dart';

/// Neon text field. Works standalone or inside a [Form] (via [validator])
/// and becomes a textarea when [maxLines] > 1.
///
/// Without [controller], keeps an internal controller initialized with
/// [initialValue] to preserve focus/cursor across rebuilds.
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

  /// Initial text for the internal controller. Ignored when [controller] is set.
  final String initialValue;

  /// Callback called when the text changes.
  final ValueChanged<String>? onChanged;

  /// External controller. The creator is responsible for disposing it.
  final TextEditingController? controller;

  /// External focus, for chaining fields or focusing programmatically.
  final FocusNode? focusNode;

  /// Error message displayed below the field (overrides [validator]).
  final String? errorText;

  /// Hint text displayed when the field is empty.
  final String? hint;

  /// Helper text displayed below the field.
  final String? helperText;

  /// Optional icon displayed before the text.
  final IconData? icon;

  /// If `true`, hides the entered text.
  final bool obscure;

  /// Keyboard type requested from the system.
  final TextInputType? keyboardType;

  /// Keyboard action button type (next, done…).
  final TextInputAction? textInputAction;

  /// Optional widget displayed at the end of the field.
  final Widget? suffix;

  /// Validation used by an ancestor [Form].
  final FormFieldValidator<String>? validator;

  /// Callback when submitting from the keyboard.
  final ValueChanged<String>? onSubmitted;

  /// When to validate automatically.
  final AutovalidateMode? autovalidateMode;

  /// If `false`, the field is disabled.
  final bool enabled;

  /// If `true`, the text cannot be edited (but can be selected).
  final bool readOnly;

  /// If `true`, requests focus when shown.
  final bool autofocus;

  /// Minimum number of visible lines (textarea).
  final int? minLines;

  /// Maximum number of lines. `null` grows without a limit.
  final int? maxLines;

  /// Character limit, with a counter.
  final int? maxLength;

  /// Formatters applied to the input.
  final List<TextInputFormatter>? inputFormatters;

  /// Autofill hints.
  final Iterable<String>? autofillHints;

  /// Accent color override. Default: `palette.primary`.
  final Color? accentColor;

  @override
  State<LumenTextField> createState() => _LumenTextFieldState();
}

class _LumenTextFieldState extends State<LumenTextField> {
  TextEditingController? _internal;

  TextEditingController get _controller =>
      widget.controller ??
      (_internal ??= TextEditingController(text: widget.initialValue));

  @override
  Widget build(BuildContext context) {
    final LumenPalette p = LumenThemeExt.of(context).palette;
    final LumenStyle style = LumenStyle.of(context);
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
      decoration: LumenDecorations.input(
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
  void didUpdateWidget(LumenTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Switched to an internal controller: inherit text from the previous external one.
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
