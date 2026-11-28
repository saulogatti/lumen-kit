import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:lumen_kit/src/foundation/lumen_decorations.dart';
import 'package:lumen_kit/src/foundation/lumen_tokens.dart';
import 'package:lumen_kit/src/theme/lumen_palette.dart';
import 'package:lumen_kit/src/theme/lumen_style.dart';
import 'package:material_ui/material_ui.dart';

/// Integer digits accepted while typing; a `double` keeps about 15 exact digits.
const int _maxIntegerDigits = 15;

final RegExp _leadingZeros = RegExp(r'^0+(?=\d)');
final RegExp _trailingZeros = RegExp(r'0+$');

/// Numeric text field for prices, quantities and stock, controlled by [value].
///
/// Typing accepts only digits, one decimal separator (when [decimals] > 0) and
/// a leading minus sign (when [min] is null or negative). Fraction digits past
/// [decimals] are dropped and [groupSeparator], when set, is inserted while
/// typing without moving the cursor. An empty field reports `null`.
///
/// [min] and [max] are applied when the field loses focus or is submitted, so
/// they never fight the user mid-typing. A null [onChanged] disables the field.
///
/// ```dart
/// LumenNumberField(
///   label: 'Price',
///   value: _price,
///   decimals: 2,
///   min: 0,
///   prefixText: r'$ ',
///   groupSeparator: ',',
///   padDecimals: true,
///   onChanged: (double? v) => setState(() => _price = v),
/// )
/// ```
///
/// For a Brazilian price, pass `decimalSeparator: ','` and
/// `groupSeparator: '.'`.
class LumenNumberField extends StatefulWidget {
  /// Creates a numeric field.
  ///
  /// [label] identifies the field and [value] supplies its current number,
  /// or `null` for empty. [onChanged] receives edits and committed changes;
  /// passing `null` disables input. The caller must update [value].
  ///
  /// [decimals] defaults to 0 and must be between 0 and 20. Typing accepts
  /// digits, at most one decimal separator when decimals are enabled, and a
  /// leading minus when [min] is null or negative. [min] and [max] default
  /// to unbounded and are applied on blur or submission, not while typing.
  /// Bounds are rounded inward to representable values; if none fits, the
  /// rounded minimum wins. [padDecimals] defaults to false.
  ///
  /// [decimalSeparator] defaults to `.`; optional [groupSeparator] inserts
  /// grouping. Both must be single, distinct characters. [prefixText],
  /// [suffixText], [hint], and [helperText] provide optional decoration.
  /// [validator] validates the parsed number in a form and takes precedence
  /// over [errorText]. [accentColor] defaults to the palette's primary color.
  ///
  /// [focusNode] optionally supplies external focus control; [autofocus]
  /// defaults to false. [textInputAction] configures the keyboard action and
  /// [onSubmitted] receives the committed value. [textAlign] defaults to
  /// [TextAlign.start], and [key] identifies the widget.
  const LumenNumberField({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
    this.decimals = 0,
    this.min,
    this.max,
    this.padDecimals = false,
    this.decimalSeparator = '.',
    this.groupSeparator,
    this.prefixText,
    this.suffixText,
    this.hint,
    this.helperText,
    this.errorText,
    this.validator,
    this.accentColor,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
    this.textAlign = TextAlign.start,
    this.autofocus = false,
  }) : assert(decimals >= 0 && decimals <= 20, 'decimals must be between 0 and 20.'),
       assert(decimalSeparator.length == 1, 'decimalSeparator must be one character.'),
       assert(
         groupSeparator == null || groupSeparator.length == 1,
         'groupSeparator must be one character.',
       ),
       assert(
         groupSeparator != decimalSeparator,
         'groupSeparator must differ from decimalSeparator.',
       ),
       assert(min == null || max == null || min <= max, 'min must not be greater than max.');

  /// Label displayed by the field.
  final String label;

  /// Current number, or `null` for an empty field.
  ///
  /// It is shown rounded to [decimals]. A new value from outside replaces the
  /// text, unless it equals what the user is typing.
  final double? value;

  /// Called with the typed number whenever it changes, and with the value
  /// limited to [min]..[max] when the field loses focus or is submitted.
  ///
  /// Receives `null` when the field is emptied. `null` disables the field.
  final ValueChanged<double?>? onChanged;

  /// Number of fraction digits accepted.
  ///
  /// Default: `0`, integers only.
  final int decimals;

  /// Smallest value, applied when the field loses focus or is submitted.
  ///
  /// With more fraction digits than [decimals], it is rounded up to the
  /// nearest value the field can show, so the committed number never falls
  /// below it. When no such value fits between [min] and [max] (for example
  /// `min: 1.231`, `max: 1.239` with two decimals), the rounded [min] wins.
  ///
  /// A null or negative [min] also accepts a leading minus sign. An empty
  /// field stays `null`; use [validator] to require a value.
  final double? min;

  /// Largest value, applied when the field loses focus or is submitted.
  ///
  /// With more fraction digits than [decimals], it is rounded down to the
  /// nearest value the field can show, so the committed number never exceeds
  /// it.
  final double? max;

  /// Whether the text shows exactly [decimals] fraction digits after focus
  /// leaves (`12.50` instead of `12.5`).
  final bool padDecimals;

  /// Character between the integer and the fraction.
  ///
  /// Default: `.`. Typing a single `.` or `,` (or [groupSeparator]) inserts
  /// this separator, so numeric keypads with only one of them still work.
  final String decimalSeparator;

  /// Character inserted between groups of three integer digits.
  ///
  /// Default: `null`, no grouping. Pasted text has it removed before parsing.
  final String? groupSeparator;

  /// Text before the number, such as a currency symbol.
  final String? prefixText;

  /// Text after the number, such as a unit or `%`.
  final String? suffixText;

  /// Tip text displayed with an empty field.
  final String? hint;

  /// Help text displayed below the field.
  final String? helperText;

  /// Error message displayed below the field.
  ///
  /// A non-null message returned by [validator] takes precedence.
  final String? errorText;

  /// Validation used by an ancestor [Form], with the parsed number.
  final FormFieldValidator<double?>? validator;

  /// Highlight color override.
  ///
  /// Default: `palette.primary`.
  final Color? accentColor;

  /// External focus, to chain fields or focus via code.
  final FocusNode? focusNode;

  /// Keyboard confirmation button action (next, done…).
  final TextInputAction? textInputAction;

  /// Called when confirming via keyboard, with the value after [min] and
  /// [max] are applied.
  final ValueChanged<double?>? onSubmitted;

  /// Horizontal alignment of the number.
  final TextAlign textAlign;

  /// Whether to request focus when appearing.
  final bool autofocus;

  @override
  State<LumenNumberField> createState() => _LumenNumberFieldState();
}

class _LumenNumberFieldState extends State<LumenNumberField> {
  late final TextEditingController _controller;
  FocusNode? _internalFocus;

  /// The number in the text, as last reported to [LumenNumberField.onChanged].
  double? _textValue;

  FocusNode get _focus => widget.focusNode ?? (_internalFocus ??= FocusNode());

  _NumberFormat get _format => _NumberFormat.of(widget);

  bool get _enabled => widget.onChanged != null;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _syncText(widget.value);
    _focus.addListener(_focusChanged);
  }

  @override
  Widget build(BuildContext context) {
    final p = LumenThemeExt.of(context).palette;
    final s = LumenStyle.of(context);
    final accent = widget.accentColor ?? p.primary;
    final format = _format;
    final textStyle = Theme.of(context).textTheme.titleMedium?.copyWith(color: p.textPrimary);
    final affixStyle = textStyle?.copyWith(color: p.textMuted);
    final validator = widget.validator;
    return Opacity(
      opacity: _enabled ? 1 : kLumenDisabledOpacity,
      child: TextFormField(
        controller: _controller,
        focusNode: _focus,
        enabled: _enabled,
        autofocus: widget.autofocus,
        keyboardType: TextInputType.numberWithOptions(
          signed: format.allowNegative,
          decimal: widget.decimals > 0,
        ),
        textInputAction: widget.textInputAction,
        textAlign: widget.textAlign,
        inputFormatters: <TextInputFormatter>[_NumberInputFormatter(format)],
        onChanged: _textChanged,
        onFieldSubmitted: (_) {
          // Commit even without a callback: actions that keep focus never blur.
          final value = _commit();
          widget.onSubmitted?.call(value);
        },
        validator: validator == null ? null : (text) => validator(format.parse(text ?? '')),
        cursorColor: accent,
        style: textStyle,
        decoration:
            LumenDecorations.input(
              p,
              s,
              accent: accent,
              label: widget.label,
              hint: widget.hint,
              helper: widget.helperText,
              error: widget.errorText,
            ).copyWith(
              prefixText: widget.prefixText,
              suffixText: widget.suffixText,
              prefixStyle: affixStyle,
              suffixStyle: affixStyle,
            ),
      ),
    );
  }

  @override
  void didUpdateWidget(LumenNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _internalFocus)?.removeListener(_focusChanged);
      _focus.addListener(_focusChanged);
    }
    final oldFormat = _NumberFormat.of(oldWidget);
    final typed = oldFormat.parse(_controller.text);
    if (widget.value != oldWidget.value && widget.value != typed) {
      _syncText(widget.value);
    } else if (!_format.sameAs(oldFormat)) {
      _syncText(typed);
    }
  }

  @override
  void dispose() {
    _focus.removeListener(_focusChanged);
    _internalFocus?.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// Applies [LumenNumberField.min]/[LumenNumberField.max], rewrites the text
  /// in its final form and reports the result.
  double? _commit() {
    final text = _format.format(_clamp(_format.parse(_controller.text)), pad: widget.padDecimals);
    _replaceText(text);
    _textChanged(text);
    return _textValue;
  }

  /// Limits [value] to the bounds rounded inward to [LumenNumberField.decimals],
  /// so rounding the result for display cannot leave the range.
  double? _clamp(double? value) {
    if (value == null) return null;
    final format = _format;
    final min = widget.min;
    final max = widget.max;
    var clamped = value;
    if (max != null) clamped = math.min(clamped, format.snap(max, up: false));
    // Applied last, so the rounded min wins when no value fits the range.
    if (min != null) clamped = math.max(clamped, format.snap(min, up: true));
    return clamped;
  }

  void _focusChanged() {
    if (!_focus.hasFocus) _commit();
  }

  void _replaceText(String text) => _controller.value = TextEditingValue(
    text: text,
    selection: TextSelection.collapsed(offset: text.length),
  );

  /// Shows [value] without reporting it back.
  void _syncText(double? value) {
    final text = _format.format(value, pad: widget.padDecimals);
    _replaceText(text);
    _textValue = _format.parse(text);
  }

  void _textChanged(String text) {
    final value = _format.parse(text);
    if (value == _textValue) return;
    _textValue = value;
    widget.onChanged?.call(value);
  }
}

/// Separators and limits shared by parsing, formatting and the input filter.
class _NumberFormat {
  const _NumberFormat({
    required this.decimals,
    required this.decimalSeparator,
    required this.groupSeparator,
    required this.allowNegative,
  });

  _NumberFormat.of(LumenNumberField field)
    : this(
        decimals: field.decimals,
        decimalSeparator: field.decimalSeparator,
        groupSeparator: field.groupSeparator,
        allowNegative: field.min == null || field.min! < 0,
      );

  final int decimals;
  final String decimalSeparator;
  final String? groupSeparator;
  final bool allowNegative;

  /// [bound] rounded to [decimals], up or down when rounding to the nearest
  /// value would cross it.
  double snap(double bound, {required bool up}) {
    double fixed(double v) => double.parse(v.toStringAsFixed(decimals));
    final step = 1 / math.pow(10, decimals);
    final nearest = fixed(bound);
    if (up && nearest < bound) return fixed(nearest + step);
    if (!up && nearest > bound) return fixed(nearest - step);
    return nearest;
  }

  bool sameAs(_NumberFormat other) =>
      decimals == other.decimals &&
      decimalSeparator == other.decimalSeparator &&
      groupSeparator == other.groupSeparator &&
      allowNegative == other.allowNegative;

  /// Text for [value] rounded to [decimals]; trailing zeros only with [pad].
  String format(double? value, {required bool pad}) {
    if (value == null || !value.isFinite) return '';
    final fixed = value.abs().toStringAsFixed(decimals);
    final dot = fixed.indexOf('.');
    final integer = dot < 0 ? fixed : fixed.substring(0, dot);
    var fraction = dot < 0 ? '' : fixed.substring(dot + 1);
    if (!pad) fraction = fraction.replaceFirst(_trailingZeros, '');
    final negative = value < 0 && double.parse(fixed) != 0;
    return compose(integer, fraction, negative: negative, hasSeparator: fraction.isNotEmpty);
  }

  /// The number in [text], or `null` when it holds no digits.
  double? parse(String text) {
    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      final char = text[i];
      if (char == decimalSeparator) {
        buffer.write('.');
      } else if (char != groupSeparator) {
        buffer.write(char);
      }
    }
    final value = double.tryParse(buffer.toString());
    // `-0` reads as zero.
    return value == 0 ? 0 : value;
  }

  String compose(
    String integer,
    String fraction, {
    required bool negative,
    required bool hasSeparator,
  }) {
    final buffer = StringBuffer(negative ? '-' : '');
    for (var i = 0; i < integer.length; i++) {
      if (i > 0 && _groupStartsAt(integer.length, i)) buffer.write(groupSeparator);
      buffer.write(integer[i]);
    }
    if (hasSeparator) buffer.write('$decimalSeparator$fraction');
    return buffer.toString();
  }

  /// Group separators before the first [count] of [length] integer digits,
  /// leaving out one that sits right after them.
  int groupsBefore(int length, int count) {
    var groups = 0;
    for (var i = 1; i < count; i++) {
      if (_groupStartsAt(length, i)) groups++;
    }
    return groups;
  }

  bool _groupStartsAt(int length, int index) =>
      groupSeparator != null && index > 0 && (length - index) % 3 == 0;
}

/// Keeps the text a valid number in [format] while preserving the cursor.
class _NumberInputFormatter extends TextInputFormatter {
  _NumberInputFormatter(this.format);

  final _NumberFormat format;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    var selection = newValue.selection;
    final oldText = oldValue.text;
    final group = format.groupSeparator;
    final collapsed = selection.isValid && selection.isCollapsed;
    final at = selection.baseOffset;

    // Deleting a group separator deletes the digit next to it instead, since
    // the separator would come right back.
    if (group != null && collapsed && text.length == oldText.length - 1) {
      if (oldText[at] == group && oldText.replaceRange(at, at + 1, '') == text) {
        final backspace = oldValue.selection.baseOffset == at + 1;
        final digit = backspace ? at - 1 : at;
        text = text.replaceRange(digit, digit + 1, '');
        selection = TextSelection.collapsed(offset: digit);
      }
    }

    // A single typed `.` or `,` becomes the decimal separator.
    var promoted = -1;
    if (format.decimals > 0 && collapsed && at > 0 && text.length == oldText.length + 1) {
      final char = text[at - 1];
      final separator = char == '.' || char == ',' || char == group;
      if (separator && text.replaceRange(at - 1, at, '') == oldText) promoted = at - 1;
    }

    final base = selection.isValid ? selection.baseOffset : text.length;
    final extent = selection.isValid ? selection.extentOffset : text.length;
    var negative = false;
    var hasSeparator = false;
    var integer = '';
    var fraction = '';
    var kept = 0;
    var keptBase = 0;
    var keptExtent = 0;
    for (var i = 0; i <= text.length; i++) {
      if (i == base) keptBase = kept;
      if (i == extent) keptExtent = kept;
      if (i == text.length) break;
      final char = i == promoted ? format.decimalSeparator : text[i];
      if (_isDigit(char)) {
        if (hasSeparator) {
          fraction += char;
        } else {
          integer += char;
        }
      } else if (char == '-' && format.allowNegative && kept == 0) {
        negative = true;
      } else if (char == format.decimalSeparator && format.decimals > 0) {
        // A second separator would move the decimal point: refuse the edit.
        if (hasSeparator) return oldValue;
        hasSeparator = true;
      } else {
        continue;
      }
      kept++;
    }

    final shownFraction = fraction.length > format.decimals
        ? fraction.substring(0, format.decimals)
        : fraction;
    var shownInteger = integer.replaceFirst(_leadingZeros, '');
    if (shownInteger.isEmpty && hasSeparator) shownInteger = '0';
    if (shownInteger.length > _maxIntegerDigits) return oldValue;

    final sign = negative ? 1 : 0;
    // Zeros removed from the front (−1 when a `0` was added before the separator).
    final shift = integer.length - shownInteger.length;
    int offsetOf(int keptBefore) {
      if (keptBefore <= sign) return keptBefore;
      final digits = keptBefore - sign;
      if (digits <= integer.length) {
        final shown = (digits - shift).clamp(0, shownInteger.length);
        return sign + shown + format.groupsBefore(shownInteger.length, shown);
      }
      final tail = math.min(digits - integer.length, 1 + shownFraction.length);
      return sign +
          shownInteger.length +
          format.groupsBefore(shownInteger.length, shownInteger.length) +
          tail;
    }

    return TextEditingValue(
      text: format.compose(
        shownInteger,
        shownFraction,
        negative: negative,
        hasSeparator: hasSeparator,
      ),
      selection: TextSelection(baseOffset: offsetOf(keptBase), extentOffset: offsetOf(keptExtent)),
    );
  }

  static bool _isDigit(String char) {
    final code = char.codeUnitAt(0);
    return code >= 0x30 && code <= 0x39;
  }
}
