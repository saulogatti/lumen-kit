import 'package:flutter/services.dart';
import 'package:lumen_kit/src/foundation/lumen_tokens.dart';
import 'package:lumen_kit/src/theme/lumen_palette.dart';
import 'package:lumen_kit/src/theme/lumen_style.dart';
import 'package:material_ui/material_ui.dart';

/// Code field (OTP): a sequence of places controlled by [value].
/// `onChanged == null` disables. [onCompleted] fires when the last house is
/// filled. Pasting a code completes the sequence all at once.
/// ```dart
/// LumenPinField(
///   length: 6,
///   value: _codigo,
///   onChanged: (String v) => setState(() => _codigo = v),
///   onCompleted: enviar,
/// )
/// ```
class LumenPinField extends StatefulWidget {
  /// Creates a field of [length] houses.
  ///
  /// Default: 6.
  const LumenPinField({
    super.key,
    this.length = 6,
    this.value = '',
    this.onChanged,
    this.onCompleted,
    this.obscure = false,
    this.semanticLabel,
  }) : assert(length > 0, 'length precisa ser positivo.');

  /// Number of houses.
  final int length;

  /// Digits already filled in.
  ///
  /// Anything past [length] is ignored.
  final String value;

  /// Receives only digits, maximum [length].
  ///
  /// `null` disables the field.
  final ValueChanged<String>? onChanged;

  /// Called once when [value] reaches [length] digits.
  final ValueChanged<String>? onCompleted;

  /// Whether each place shows a dot instead of the digit.
  final bool obscure;

  /// Label for screen readers.
  ///
  /// Default: "N-digit code".
  final String? semanticLabel;

  @override
  State<LumenPinField> createState() => _LumenPinFieldState();
}

class _LumenPinFieldState extends State<LumenPinField> {
  late final TextEditingController _controller;
  late final FocusNode _focus;
  int _previousLength = 0;

  bool get _enabled => widget.onChanged != null;

  @override
  Widget build(BuildContext context) {
    final p = LumenThemeExt.of(context).palette;
    final s = LumenStyle.of(context);
    final accent = p.primary;
    final text = _digits(_controller.text);
    final cursor = text.length.clamp(0, widget.length - 1);
    return Opacity(
      opacity: _enabled ? 1 : kLumenDisabledOpacity,
      child: Semantics(
        label: widget.semanticLabel ?? 'Código de ${widget.length} dígitos',
        value: widget.obscure ? null : text,
        textField: true,
        enabled: _enabled,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Row(
              spacing: 8,
              children: <Widget>[
                for (int i = 0; i < widget.length; i++)
                  Expanded(
                    child: _PinCell(
                      char: i < text.length ? (widget.obscure ? '•' : text[i]) : '',
                      active: _enabled && _focus.hasFocus && i == cursor,
                      accent: accent,
                      palette: p,
                      style: s,
                    ),
                  ),
              ],
            ),
            Positioned.fill(
              child: IgnorePointer(
                ignoring: !_enabled,
                child: Opacity(
                  opacity: 0,
                  child: TextField(
                    controller: _controller,
                    focusNode: _focus,
                    enabled: _enabled,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    autofillHints: const <String>[AutofillHints.oneTimeCode],
                    maxLength: widget.length,
                    showCursor: false,
                    enableInteractiveSelection: _enabled,
                    style: const TextStyle(color: Color(0x00000000), fontSize: 1),
                    decoration: const InputDecoration(
                      counterText: '',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(widget.length),
                    ],
                    onChanged: _changed,
                    onTap: () => setState(() {}),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(LumenPinField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = _digits(widget.value);
    if (next != _controller.text) {
      _controller.value = TextEditingValue(
        text: next,
        selection: TextSelection.collapsed(offset: next.length),
      );
    }
    _previousLength = next.length;
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocus);
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final initial = _digits(widget.value);
    _controller = TextEditingController(text: initial);
    _previousLength = initial.length;
    _focus = FocusNode()..addListener(_onFocus);
  }

  void _changed(String raw) {
    if (!_enabled) {
      return;
    }
    final next = _digits(raw);
    if (next != _controller.text) {
      _controller.value = TextEditingValue(
        text: next,
        selection: TextSelection.collapsed(offset: next.length),
      );
    }
    final justCompleted = next.length == widget.length && _previousLength != widget.length;
    _previousLength = next.length;
    if (next != widget.value) {
      widget.onChanged!(next);
    }
    if (justCompleted) {
      widget.onCompleted?.call(next);
    }
    setState(() {});
  }

  String _digits(String raw) {
    final only = raw.replaceAll(RegExp(r'\D'), '');
    if (only.length <= widget.length) {
      return only;
    }
    return only.substring(0, widget.length);
  }

  void _onFocus() {
    if (mounted) {
      setState(() {});
    }
  }
}

class _PinCell extends StatelessWidget {
  const _PinCell({
    required this.char,
    required this.active,
    required this.accent,
    required this.palette,
    required this.style,
  });

  final String char;
  final bool active;
  final Color accent;
  final LumenPalette palette;
  final LumenStyle style;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.8,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.surface.withValues(alpha: style.surfaceAlpha(0.7)),
          borderRadius: style.radius(10),
          border: style.borderAll(
            color: active ? accent : palette.surfaceOutline.outlineAlpha(0.7),
            width: active ? 1.4 : 1,
          ),
        ),
        child: Center(
          child: Text(
            char,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: palette.textPrimary),
          ),
        ),
      ),
    );
  }
}
