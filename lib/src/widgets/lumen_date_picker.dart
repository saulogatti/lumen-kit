import 'dart:math' as math;

import 'package:flutter/services.dart'
    show HardwareKeyboard, KeyDownEvent, KeyEvent, KeyRepeatEvent, LogicalKeyboardKey;
import 'package:lumen_kit/src/foundation/lumen_decorations.dart';
import 'package:lumen_kit/src/foundation/lumen_pressable.dart';
import 'package:lumen_kit/src/foundation/lumen_tokens.dart';
import 'package:lumen_kit/src/theme/lumen_palette.dart';
import 'package:lumen_kit/src/theme/lumen_style.dart';
import 'package:lumen_kit/src/widgets/lumen_button.dart';
import 'package:lumen_kit/src/widgets/lumen_dialog.dart';
import 'package:lumen_kit/src/widgets/lumen_icon_button.dart';
import 'package:lumen_kit/src/widgets/lumen_text_field.dart';
import 'package:material_ui/material_ui.dart';

/// Opens a Lumen dialog for picking a date from a month grid.
///
/// The dialog shows the selected date, a month grid with previous and next
/// month buttons, a year list opened from the month title, and a text field
/// for typing the date. The returned date has no time of day.
///
/// The palette and style come from [context], as the Material-based picker
/// did, so a [LumenScope] that only wraps the caller still applies. Text,
/// localizations and media settings come from the dialog route. Month and
/// weekday names, the date format of the text field, its errors, and the
/// button labels come from [MaterialLocalizations]. [helpText] replaces the
/// title, which defaults to [MaterialLocalizations.datePickerHelpText].
///
/// [initialDate] is moved into the range from [firstDate] to [lastDate],
/// inclusive, so a date outside it opens on the nearest end. [firstDate]
/// must not be after [lastDate]. [accentColor] overrides the primary palette
/// color for the dialog border, the selected day and the buttons.
///
/// Arrow keys move the selection by a day or a week once the grid is focused,
/// which it is when the dialog opens. Page Up and Page Down move it by a
/// month, or by a year with Shift. In the year list, the arrows move by one
/// year or one row and Enter returns to the grid. Enter in the grid or the
/// text field confirms; Escape and a tap on the barrier complete with `null`.
/// Screen readers read each day as a full date, and the selected one as
/// selected.
///
/// ```dart
/// final DateTime? picked = await showLumenDatePicker(
///   context: context,
///   initialDate: DateTime.now(),
///   firstDate: DateTime(2020),
///   lastDate: DateTime(2030),
/// );
/// ```
Future<DateTime?> showLumenDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  Color? accentColor,
  String? helpText,
}) {
  final first = DateUtils.dateOnly(firstDate);
  final last = DateUtils.dateOnly(lastDate);
  assert(!first.isAfter(last), 'firstDate must not be after lastDate.');
  final theme = LumenThemeExt.of(context);

  return showDialog<DateTime>(
    context: context,
    builder: (_) => LumenScope(
      palette: theme.palette,
      style: theme.style,
      child: _LumenDatePickerDialog(
        initialDate: _clampDate(DateUtils.dateOnly(initialDate), first, last),
        firstDate: first,
        lastDate: last,
        accentColor: accentColor,
        helpText: helpText,
      ),
    ),
  );
}

/// Displays a date in a read-only field that opens [showLumenDatePicker].
///
/// The picker opens on [value] or today's date, adjusted to the allowed range.
class LumenDatePicker extends StatelessWidget {
  /// Creates a read-only field that opens a date picker on touch.
  const LumenDatePicker({
    required this.value,
    required this.firstDate,
    required this.lastDate,
    required this.onChanged,
    super.key,
    this.label,
    this.hint,
    this.accentColor,
    this.format,
  });

  /// Date currently selected.
  final DateTime? value;

  /// First date allowed in picker.
  final DateTime firstDate;

  /// Last date allowed in the picker.
  final DateTime lastDate;

  /// Callback called when a new date is chosen.
  /// When `null`, the field is visually disabled.
  final ValueChanged<DateTime>? onChanged;

  /// Label displayed by the field.
  final String? label;

  /// Text displayed when [value] is `null`.
  final String? hint;

  /// Highlight color override.
  ///
  /// Default: `palette.primary`.
  final Color? accentColor;

  /// Formatter used to display [value].
  ///
  /// The default uses a two-digit day and month, followed by the year.
  final String Function(DateTime)? format;

  String _defaultFormat(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';

  @override
  Widget build(BuildContext context) {
    final p = LumenThemeExt.of(context).palette;
    final style = LumenStyle.of(context);
    final accent = accentColor ?? p.primary;
    final disabled = onChanged == null;
    final text = value == null ? null : (format ?? _defaultFormat)(value!);

    return LumenPressable(
      borderRadius: style.radius(12),
      onTap: disabled
          ? null
          : () async {
              final picked = await showLumenDatePicker(
                context: context,
                initialDate: value ?? DateTime.now(),
                firstDate: firstDate,
                lastDate: lastDate,
                accentColor: accent,
              );
              if (picked != null) {
                onChanged!(picked);
              }
            },
      child: InputDecorator(
        decoration: LumenDecorations.input(
          p,
          style,
          accent: accent,
          label: label,
          hint: hint,
          prefixIcon: Icon(Icons.calendar_today_rounded, color: accent),
        ),
        isEmpty: text == null,
        child: Text(
          text ?? '',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: p.textPrimary),
        ),
      ),
    );
  }
}

/// Years shown per row in the year list.
const int _yearColumns = 4;

/// Height of a row in the year list, spacing included.
const double _yearRowExtent = 48;

/// [date] in the range from [first] to [last], inclusive.
DateTime _clampDate(DateTime date, DateTime first, DateTime last) => date.isBefore(first)
    ? first
    : date.isAfter(last)
    ? last
    : date;

/// The palette text tone that contrasts more with [fill].
Color _foregroundOn(LumenPalette palette, Color fill) {
  final f = fill.computeLuminance();
  double contrast(Color c) {
    final l = c.computeLuminance();
    return (math.max(l, f) + 0.05) / (math.min(l, f) + 0.05);
  }

  return contrast(palette.backgroundDeep) >= contrast(palette.textPrimary)
      ? palette.backgroundDeep
      : palette.textPrimary;
}

/// Outline that marks a state, such as keyboard focus or today.
///
/// It follows [LumenStyle.borderAll], except in styles without borders
/// ([LumenStyle.borderScale] `0`, as in soft): there it keeps [width] and
/// [color], so the state stays visible.
Border _stateBorder(LumenStyle style, Color color, double width) => style.borderScale == 0
    ? Border.all(color: color, width: width)
    : style.borderAll(color: color, width: width);

/// [date] moved by [months], with the day capped to the target month.
DateTime _addMonths(DateTime date, int months) {
  final month = DateUtils.addMonthsToMonthDate(date, months);
  final days = DateUtils.getDaysInMonth(month.year, month.month);
  return DateTime(month.year, month.month, math.min(date.day, days));
}

/// Which part of the dialog is shown below the selected date.
enum _DateMode { calendar, year, input }

class _LumenDatePickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final Color? accentColor;
  final String? helpText;

  const _LumenDatePickerDialog({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.accentColor,
    required this.helpText,
  });

  @override
  State<_LumenDatePickerDialog> createState() => _LumenDatePickerDialogState();
}

class _LumenDatePickerDialogState extends State<_LumenDatePickerDialog> {
  late DateTime _selected;

  /// First day of the month shown in the grid.
  late DateTime _month;

  _DateMode _mode = _DateMode.calendar;
  final TextEditingController _text = TextEditingController();
  String? _error;

  @override
  Widget build(BuildContext context) {
    final p = LumenThemeExt.of(context).palette;
    final l = MaterialLocalizations.of(context);
    final accent = widget.accentColor ?? p.primary;
    final input = _mode == _DateMode.input;

    final body = switch (_mode) {
      _DateMode.calendar => _CalendarView(
        key: const ValueKey<_DateMode>(_DateMode.calendar),
        month: _month,
        selected: _selected,
        firstDate: widget.firstDate,
        lastDate: widget.lastDate,
        accent: accent,
        onMonthChanged: (month) => setState(() => _month = month),
        onSelected: _select,
        onKey: _onGridKey,
        onYearMode: () => setState(() => _mode = _DateMode.year),
      ),
      _DateMode.year => _YearView(
        key: const ValueKey<_DateMode>(_DateMode.year),
        selected: _selected,
        firstDate: widget.firstDate,
        lastDate: widget.lastDate,
        accent: accent,
        onSelected: (year) {
          _select(_inYear(year));
          setState(() => _mode = _DateMode.calendar);
        },
        onKey: _onYearKey,
      ),
      _DateMode.input => Padding(
        key: const ValueKey<_DateMode>(_DateMode.input),
        padding: const EdgeInsets.only(top: 4),
        child: LumenTextField(
          label: l.dateInputLabel,
          hint: l.dateHelpText,
          controller: _text,
          autofocus: true,
          accentColor: accent,
          keyboardType: TextInputType.datetime,
          textInputAction: TextInputAction.done,
          errorText: _error,
          onChanged: _onTextChanged,
          onSubmitted: (_) => _confirm(),
        ),
      ),
    };

    return LumenDialog(
      title: widget.helpText ?? l.datePickerHelpText,
      icon: Icons.calendar_today_rounded,
      accent: accent,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: <Widget>[
          Row(
            spacing: 8,
            children: <Widget>[
              Expanded(
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    l.formatFullDate(_selected),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: p.textPrimary),
                  ),
                ),
              ),
              LumenIconButton(
                icon: input ? Icons.calendar_today_rounded : Icons.edit_outlined,
                tooltip: input ? l.calendarModeButtonLabel : l.inputDateModeButtonLabel,
                variant: LumenIconButtonVariant.ghost,
                accentColor: accent,
                onPressed: _toggleInput,
              ),
            ],
          ),
          // Swapped at once, so the new view's autofocus is not held back by
          // the old view while it fades out.
          body,
        ],
      ),
      actions: <Widget>[
        LumenButton.outline(
          label: l.cancelButtonLabel,
          accentColor: accent,
          onPressed: () => Navigator.of(context).pop(),
        ),
        LumenButton(label: l.okButtonLabel, accentColor: accent, onPressed: _confirm),
      ],
    );
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _selected = widget.initialDate;
    _month = DateTime(_selected.year, _selected.month);
  }

  /// Confirms the selection, or shows why the typed date is not accepted.
  void _confirm() {
    if (_mode == _DateMode.input) {
      final l = MaterialLocalizations.of(context);
      final parsed = l.parseCompactDate(_text.text);
      final error = parsed == null
          ? l.invalidDateFormatLabel
          : _inRange(parsed)
          ? null
          : l.dateOutOfRangeLabel;
      if (error != null) {
        setState(() => _error = error);
        return;
      }
    }
    Navigator.of(context).pop(_selected);
  }

  bool _inRange(DateTime date) =>
      !date.isBefore(widget.firstDate) && !date.isAfter(widget.lastDate);

  /// The selected day and month in [year], kept in range.
  DateTime _inYear(int year) {
    final days = DateUtils.getDaysInMonth(year, _selected.month);
    return _clampDate(
      DateTime(year, _selected.month, math.min(_selected.day, days)),
      widget.firstDate,
      widget.lastDate,
    );
  }

  KeyEventResult _onGridKey(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent && _isEnter(event.logicalKey)) {
      _confirm();
      return KeyEventResult.handled;
    }
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    final forward = Directionality.of(context) == TextDirection.rtl ? -1 : 1;
    final years = HardwareKeyboard.instance.isShiftPressed ? 12 : 1;
    final next = switch (key) {
      LogicalKeyboardKey.arrowLeft => DateUtils.addDaysToDate(_selected, -forward),
      LogicalKeyboardKey.arrowRight => DateUtils.addDaysToDate(_selected, forward),
      LogicalKeyboardKey.arrowUp => DateUtils.addDaysToDate(_selected, -DateTime.daysPerWeek),
      LogicalKeyboardKey.arrowDown => DateUtils.addDaysToDate(_selected, DateTime.daysPerWeek),
      LogicalKeyboardKey.pageUp => _addMonths(_selected, -years),
      LogicalKeyboardKey.pageDown => _addMonths(_selected, years),
      _ => null,
    };
    if (next == null) {
      return KeyEventResult.ignored;
    }
    _select(_clampDate(next, widget.firstDate, widget.lastDate));
    return KeyEventResult.handled;
  }

  void _onTextChanged(String text) {
    final parsed = MaterialLocalizations.of(context).parseCompactDate(text);
    setState(() {
      _error = null;
      if (parsed != null && _inRange(parsed)) {
        _selected = parsed;
        _month = DateTime(parsed.year, parsed.month);
      }
    });
  }

  KeyEventResult _onYearKey(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent && _isEnter(event.logicalKey)) {
      setState(() => _mode = _DateMode.calendar);
      return KeyEventResult.handled;
    }
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final forward = Directionality.of(context) == TextDirection.rtl ? -1 : 1;
    final delta = switch (event.logicalKey) {
      LogicalKeyboardKey.arrowLeft => -forward,
      LogicalKeyboardKey.arrowRight => forward,
      LogicalKeyboardKey.arrowUp => -_yearColumns,
      LogicalKeyboardKey.arrowDown => _yearColumns,
      _ => null,
    };
    if (delta == null) {
      return KeyEventResult.ignored;
    }
    final year = (_selected.year + delta).clamp(widget.firstDate.year, widget.lastDate.year);
    _select(_inYear(year));
    return KeyEventResult.handled;
  }

  void _select(DateTime date) {
    setState(() {
      _selected = date;
      _month = DateTime(date.year, date.month);
    });
  }

  void _toggleInput() {
    setState(() {
      if (_mode == _DateMode.input) {
        _mode = _DateMode.calendar;
      } else {
        _mode = _DateMode.input;
        _error = null;
        _text.text = MaterialLocalizations.of(context).formatCompactDate(_selected);
      }
    });
  }

  static bool _isEnter(LogicalKeyboardKey key) =>
      key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.numpadEnter;
}

/// Month title with previous and next buttons, weekday names and day grid.
class _CalendarView extends StatelessWidget {
  final DateTime month;
  final DateTime selected;
  final DateTime firstDate;
  final DateTime lastDate;
  final Color accent;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<DateTime> onSelected;
  final FocusOnKeyEventCallback onKey;
  final VoidCallback onYearMode;

  const _CalendarView({
    required this.month,
    required this.selected,
    required this.firstDate,
    required this.lastDate,
    required this.accent,
    required this.onMonthChanged,
    required this.onSelected,
    required this.onKey,
    required this.onYearMode,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final p = LumenThemeExt.of(context).palette;
    final style = LumenStyle.of(context);
    final l = MaterialLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final previous = DateUtils.addMonthsToMonthDate(month, -1);
    final next = DateUtils.addMonthsToMonthDate(month, 1);
    final canGoBack = !previous.isBefore(DateTime(firstDate.year, firstDate.month));
    final canGoForward = !next.isAfter(lastDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: LumenPressable(
                  onTap: onYearMode,
                  borderRadius: style.radius(10),
                  semanticLabel: l.selectYearSemanticsLabel,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 4,
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            l.formatMonthYear(month),
                            style: text.titleSmall?.copyWith(color: p.textPrimary),
                          ),
                        ),
                        Icon(Icons.arrow_drop_down_rounded, color: accent),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            LumenIconButton(
              icon: Icons.chevron_left_rounded,
              tooltip: l.previousMonthTooltip,
              variant: LumenIconButtonVariant.ghost,
              accentColor: accent,
              size: 40,
              onPressed: canGoBack ? () => onMonthChanged(previous) : null,
            ),
            LumenIconButton(
              icon: Icons.chevron_right_rounded,
              tooltip: l.nextMonthTooltip,
              variant: LumenIconButtonVariant.ghost,
              accentColor: accent,
              size: 40,
              onPressed: canGoForward ? () => onMonthChanged(next) : null,
            ),
          ],
        ),
        _FocusFrame(
          debugLabel: 'LumenDateGrid',
          color: accent,
          onKey: onKey,
          child: AnimatedSwitcher(
            duration: LumenMotion.duration(context, kLumenMediumDuration),
            child: _MonthGrid(
              key: ValueKey<DateTime>(month),
              month: month,
              selected: selected,
              firstDate: firstDate,
              lastDate: lastDate,
              accent: accent,
              onSelected: onSelected,
            ),
          ),
        ),
      ],
    );
  }
}

/// Tappable day of the month grid.
class _DayCell extends StatelessWidget {
  static const double size = 40;

  final DateTime date;
  final bool selected;
  final bool today;
  final bool enabled;
  final Color accent;
  final VoidCallback onTap;

  const _DayCell({
    required this.date,
    required this.selected,
    required this.today,
    required this.enabled,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = LumenThemeExt.of(context).palette;
    final style = LumenStyle.of(context);
    final l = MaterialLocalizations.of(context);
    final radius = style.radius(size / 2);
    final fullDate = l.formatFullDate(date);

    return Center(
      child: SizedBox.square(
        dimension: size,
        // Focus stays on the grid, which moves the selection with the arrows.
        child: ExcludeFocus(
          child: LumenPressable(
            onTap: enabled ? onTap : null,
            borderRadius: radius,
            selected: selected,
            semanticLabel: today ? '$fullDate, ${l.currentDateLabel}' : fullDate,
            child: AnimatedContainer(
              duration: LumenMotion.duration(context, kLumenFastDuration),
              decoration: BoxDecoration(
                borderRadius: radius,
                color: selected ? accent : accent.withValues(alpha: 0),
                border: today && !selected ? _stateBorder(style, accent, 1) : null,
                boxShadow: selected
                    ? style.shadows(<BoxShadow>[
                        BoxShadow(color: accent.withValues(alpha: 0.45), blurRadius: 14),
                      ])
                    : null,
              ),
              child: Center(
                child: ExcludeSemantics(
                  child: Text(
                    l.formatDecimal(date.day),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: selected ? _foregroundOn(p, accent) : p.textPrimary,
                      fontWeight: selected || today ? FontWeight.w700 : null,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Focus target for a picker grid that outlines itself while it has
/// keyboard focus in the traditional (keyboard) highlight mode.
class _FocusFrame extends StatefulWidget {
  final String debugLabel;
  final Color color;
  final FocusOnKeyEventCallback onKey;
  final Widget child;

  const _FocusFrame({
    required this.debugLabel,
    required this.color,
    required this.onKey,
    required this.child,
  });

  @override
  State<_FocusFrame> createState() => _FocusFrameState();
}

class _FocusFrameState extends State<_FocusFrame> {
  late final FocusNode _focus = FocusNode(debugLabel: widget.debugLabel);
  bool _focused = false;
  bool _keyboard = FocusManager.instance.highlightMode == FocusHighlightMode.traditional;

  @override
  Widget build(BuildContext context) {
    final style = LumenStyle.of(context);
    final outlined = _focused && _keyboard;

    return Focus(
      focusNode: _focus,
      autofocus: true,
      onFocusChange: (focused) => setState(() => _focused = focused),
      onKeyEvent: widget.onKey,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: style.radius(14),
          // Transparent while unfocused, so the grid keeps its size.
          border: _stateBorder(
            style,
            outlined ? widget.color : widget.color.withValues(alpha: 0),
            2,
          ),
        ),
        child: widget.child,
      ),
    );
  }

  @override
  void dispose() {
    FocusManager.instance.removeHighlightModeListener(_onHighlightMode);
    _focus.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    FocusManager.instance.addHighlightModeListener(_onHighlightMode);
  }

  void _onHighlightMode(FocusHighlightMode mode) {
    setState(() => _keyboard = mode == FocusHighlightMode.traditional);
  }
}

/// Weekday names and six weeks of days for [month].
class _MonthGrid extends StatelessWidget {
  final DateTime month;
  final DateTime selected;
  final DateTime firstDate;
  final DateTime lastDate;
  final Color accent;
  final ValueChanged<DateTime> onSelected;

  const _MonthGrid({
    required this.month,
    required this.selected,
    required this.firstDate,
    required this.lastDate,
    required this.accent,
    required this.onSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final p = LumenThemeExt.of(context).palette;
    final l = MaterialLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final offset = DateUtils.firstDayOffset(month.year, month.month, l);
    final days = DateUtils.getDaysInMonth(month.year, month.month);
    final today = DateUtils.dateOnly(DateTime.now());

    Widget cell(int index) {
      final day = index - offset + 1;
      if (day < 1 || day > days) {
        return const SizedBox(height: _DayCell.size);
      }
      final date = DateTime(month.year, month.month, day);
      return _DayCell(
        date: date,
        selected: DateUtils.isSameDay(date, selected),
        today: DateUtils.isSameDay(date, today),
        enabled: !date.isBefore(firstDate) && !date.isAfter(lastDate),
        accent: accent,
        onTap: () => onSelected(date),
      );
    }

    return Column(
      spacing: 2,
      children: <Widget>[
        ExcludeSemantics(
          child: Row(
            children: <Widget>[
              for (var i = 0; i < DateTime.daysPerWeek; i++)
                Expanded(
                  child: Center(
                    child: Text(
                      l.narrowWeekdays[(l.firstDayOfWeekIndex + i) % DateTime.daysPerWeek],
                      style: text.labelMedium?.copyWith(color: p.textMuted),
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Six weeks always, so the dialog keeps its height between months.
        for (var week = 0; week < 6; week++)
          Row(
            children: <Widget>[
              for (var i = 0; i < DateTime.daysPerWeek; i++)
                Expanded(child: cell(week * DateTime.daysPerWeek + i)),
            ],
          ),
      ],
    );
  }
}

/// Grid of the years in range, scrolled to the selected one.
class _YearView extends StatefulWidget {
  final DateTime selected;
  final DateTime firstDate;
  final DateTime lastDate;
  final Color accent;
  final ValueChanged<int> onSelected;
  final FocusOnKeyEventCallback onKey;

  const _YearView({
    required this.selected,
    required this.firstDate,
    required this.lastDate,
    required this.accent,
    required this.onSelected,
    required this.onKey,
    super.key,
  });

  @override
  State<_YearView> createState() => _YearViewState();
}

class _YearViewState extends State<_YearView> {
  static const int _visibleRows = 5;

  late final ScrollController _scroll;

  @override
  Widget build(BuildContext context) {
    final p = LumenThemeExt.of(context).palette;
    final style = LumenStyle.of(context);
    final l = MaterialLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final first = widget.firstDate.year;
    final count = widget.lastDate.year - first + 1;

    return _FocusFrame(
      debugLabel: 'LumenYearGrid',
      color: widget.accent,
      onKey: widget.onKey,
      child: SizedBox(
        // A short range shows only its rows, up to five before scrolling.
        height: _yearRowExtent * math.min(_rowOf(widget.lastDate.year) + 1, _visibleRows),
        child: GridView.builder(
          controller: _scroll,
          itemCount: count,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _yearColumns,
            mainAxisExtent: _yearRowExtent,
          ),
          itemBuilder: (context, index) {
            final year = first + index;
            final selected = year == widget.selected.year;
            final radius = style.radius(18);
            return Padding(
              padding: const EdgeInsets.all(4),
              child: ExcludeFocus(
                child: LumenPressable(
                  onTap: () => widget.onSelected(year),
                  borderRadius: radius,
                  selected: selected,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: radius,
                      color: selected ? widget.accent : widget.accent.withValues(alpha: 0),
                    ),
                    child: Center(
                      child: Text(
                        l.formatYear(DateTime(year)),
                        style: text.bodyMedium?.copyWith(
                          color: selected ? _foregroundOn(p, widget.accent) : p.textPrimary,
                          fontWeight: selected ? FontWeight.w700 : null,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(_YearView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected.year != widget.selected.year) {
      // Keeps the selected row in view while the arrows move through years.
      final top = _rowOf(widget.selected.year) * _yearRowExtent;
      final bottom = top - _yearRowExtent * (_visibleRows - 1);
      _scroll.jumpTo(_scroll.offset.clamp(bottom, top).clamp(0, _maxOffset).toDouble());
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final centered = (_rowOf(widget.selected.year) - _visibleRows ~/ 2) * _yearRowExtent;
    _scroll = ScrollController(initialScrollOffset: centered.clamp(0, _maxOffset).toDouble());
  }

  /// Scroll offset that shows the last row at the bottom of the list.
  double get _maxOffset =>
      math.max(0, _rowOf(widget.lastDate.year) + 1 - _visibleRows) * _yearRowExtent;

  int _rowOf(int year) => (year - widget.firstDate.year) ~/ _yearColumns;
}
