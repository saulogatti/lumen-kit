import 'package:flutter/services.dart'
    show
        FilteringTextInputFormatter,
        KeyDownEvent,
        KeyEvent,
        KeyRepeatEvent,
        LengthLimitingTextInputFormatter,
        LogicalKeyboardKey,
        TextInputFormatter;
import 'package:lumen_kit/src/foundation/lumen_decorations.dart';
import 'package:lumen_kit/src/foundation/lumen_picker_support.dart';
import 'package:lumen_kit/src/foundation/lumen_pressable.dart';
import 'package:lumen_kit/src/foundation/lumen_tokens.dart';
import 'package:lumen_kit/src/theme/lumen_palette.dart';
import 'package:lumen_kit/src/theme/lumen_style.dart';
import 'package:lumen_kit/src/widgets/lumen_button.dart';
import 'package:lumen_kit/src/widgets/lumen_dialog.dart';
import 'package:lumen_kit/src/widgets/lumen_icon_button.dart';
import 'package:lumen_kit/src/widgets/lumen_text_field.dart';
import 'package:material_ui/material_ui.dart';

/// Opens a Lumen dialog for picking a time of day.
///
/// The dialog shows the selected time and an hour column and a minute
/// column, each with up and down buttons. In 12-hour format an AM/PM toggle
/// follows the minutes. A button switches to two text fields for typing the
/// hour and the minute.
///
/// The palette and style come from [context], as the Material-based picker
/// did, so a [LumenScope] that only wraps the caller still applies. So does
/// the 24-hour setting: [use24HourFormat] forces 24-hour formatting when
/// `true` and uses the locale's format when `false`; a `null` value uses
/// [MediaQuery.alwaysUse24HourFormatOf] for [context]. Text, localizations
/// and the remaining media settings come from the dialog route. Labels,
/// AM/PM names and the error text come from [MaterialLocalizations].
/// [helpText] replaces the title, which defaults to
/// [MaterialLocalizations.timePickerDialHelpText].
///
/// [initialEntryMode] picks the starting view: [TimePickerEntryMode.dial]
/// opens the columns and [TimePickerEntryMode.input] the text fields. The
/// `dialOnly` and `inputOnly` modes hide the button that switches views.
/// [accentColor] overrides the primary palette color for the dialog border,
/// the columns and the buttons.
///
/// The hour column takes focus when the dialog opens. Up and Down change the
/// focused column by one and wrap around; Left and Right move between the
/// columns. Enter confirms; Escape and a tap on the barrier complete with
/// `null`. Screen readers adjust the hour and the minute as separate values.
/// Changing the hour in 12-hour format keeps AM or PM.
///
/// ```dart
/// final TimeOfDay? picked = await showLumenTimePicker(
///   context: context,
///   initialTime: TimeOfDay.now(),
/// );
/// ```
Future<TimeOfDay?> showLumenTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
  Color? accentColor,
  String? helpText,
  bool? use24HourFormat,
  TimePickerEntryMode initialEntryMode = TimePickerEntryMode.dial,
}) {
  final theme = LumenThemeExt.of(context);
  final alwaysUse24 = use24HourFormat ?? MediaQuery.alwaysUse24HourFormatOf(context);

  return showDialog<TimeOfDay>(
    context: context,
    builder: (_) => LumenScope(
      palette: theme.palette,
      style: theme.style,
      child: _LumenTimePickerDialog(
        initialTime: initialTime,
        accentColor: accentColor,
        helpText: helpText,
        alwaysUse24HourFormat: alwaysUse24,
        entryMode: initialEntryMode,
      ),
    ),
  );
}

/// Read-only field that opens [showLumenTimePicker] when touched.
///
/// Pair of `LumenDatePicker` for scheduling forms.
class LumenTimePicker extends StatelessWidget {
  /// Creates a read-only field that opens a time picker on touch.
  const LumenTimePicker({
    required this.value,
    required this.onChanged,
    super.key,
    this.label,
    this.hint,
    this.accentColor,
    this.format,
    this.use24HourFormat,
  });

  /// Currently selected time.
  final TimeOfDay? value;

  /// Callback called when a new time is chosen.
  /// When `null`, the field is visually disabled.
  final ValueChanged<TimeOfDay>? onChanged;

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
  /// The default uses Material localizations and [use24HourFormat].
  final String Function(TimeOfDay)? format;

  /// Controls the 24-hour override in the field and picker.
  ///
  /// `true` forces 24-hour formatting, `false` uses the locale's format, and
  /// `null` preserves the inherited setting. [format] takes precedence for
  /// the field text.
  final bool? use24HourFormat;

  @override
  Widget build(BuildContext context) {
    final p = LumenThemeExt.of(context).palette;
    final style = LumenStyle.of(context);
    final accent = accentColor ?? p.primary;
    final disabled = onChanged == null;
    final text = value == null
        ? null
        : (format?.call(value!) ??
              MaterialLocalizations.of(context).formatTimeOfDay(
                value!,
                alwaysUse24HourFormat:
                    use24HourFormat ?? MediaQuery.alwaysUse24HourFormatOf(context),
              ));

    return LumenPressable(
      borderRadius: style.radius(12),
      onTap: disabled
          ? null
          : () async {
              final picked = await showLumenTimePicker(
                context: context,
                initialTime: value ?? TimeOfDay.now(),
                accentColor: accent,
                use24HourFormat: use24HourFormat,
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
          prefixIcon: Icon(Icons.schedule_rounded, color: accent),
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

/// Height of the value box in a column and of the AM/PM toggle.
const double _boxHeight = 64;

/// [time] with [hour] wrapped into the day.
TimeOfDay _withHour(TimeOfDay time, int hour) =>
    TimeOfDay(hour: hour % TimeOfDay.hoursPerDay, minute: time.minute);

class _LumenTimePickerDialog extends StatefulWidget {
  final TimeOfDay initialTime;
  final Color? accentColor;
  final String? helpText;
  final bool alwaysUse24HourFormat;
  final TimePickerEntryMode entryMode;

  const _LumenTimePickerDialog({
    required this.initialTime,
    required this.accentColor,
    required this.helpText,
    required this.alwaysUse24HourFormat,
    required this.entryMode,
  });

  @override
  State<_LumenTimePickerDialog> createState() => _LumenTimePickerDialogState();
}

class _LumenTimePickerDialogState extends State<_LumenTimePickerDialog> {
  late TimeOfDay _time;
  late bool _input;
  bool _invalid = false;
  bool _textFilled = false;
  final TextEditingController _hourText = TextEditingController();
  final TextEditingController _minuteText = TextEditingController();
  final FocusNode _minuteFocus = FocusNode(debugLabel: 'LumenTimeMinuteField');

  @override
  Widget build(BuildContext context) {
    final p = LumenThemeExt.of(context).palette;
    final l = MaterialLocalizations.of(context);
    final accent = widget.accentColor ?? p.primary;
    final use24 = _uses24Hours(l);
    final canSwitch =
        widget.entryMode == TimePickerEntryMode.dial ||
        widget.entryMode == TimePickerEntryMode.input;
    final Widget? period = use24
        ? null
        : _PeriodToggle(
            period: _time.period,
            accent: accent,
            onChanged: (period) => setState(() {
              _time = _withHour(
                _time,
                _time.hour % TimeOfDay.hoursPerPeriod +
                    (period == DayPeriod.pm ? TimeOfDay.hoursPerPeriod : 0),
              );
            }),
          );

    return LumenDialog(
      title: widget.helpText ?? l.timePickerDialHelpText,
      icon: Icons.schedule_rounded,
      accent: accent,
      maxWidth: 380,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: <Widget>[
          Row(
            spacing: 8,
            children: <Widget>[
              Expanded(
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    l.formatTimeOfDay(_time, alwaysUse24HourFormat: widget.alwaysUse24HourFormat),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: p.textPrimary),
                  ),
                ),
              ),
              if (canSwitch)
                LumenIconButton(
                  icon: _input ? Icons.schedule_rounded : Icons.keyboard_outlined,
                  tooltip: _input ? l.dialModeButtonLabel : l.inputTimeModeButtonLabel,
                  variant: LumenIconButtonVariant.ghost,
                  accentColor: accent,
                  onPressed: _toggleInput,
                ),
            ],
          ),
          if (_input) _inputs(l, p, accent, period) else _columns(l, accent, use24, period),
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
    _hourText.dispose();
    _minuteText.dispose();
    _minuteFocus.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _time = widget.initialTime;
    _input =
        widget.entryMode == TimePickerEntryMode.input ||
        widget.entryMode == TimePickerEntryMode.inputOnly;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Localizations are not available in initState.
    if (_input && !_textFilled) {
      _fillText();
    }
  }

  Widget _columns(MaterialLocalizations l, Color accent, bool use24, Widget? period) {
    // In 12-hour format the hour wraps within AM or PM.
    TimeOfDay stepHour(int delta) => use24
        ? _withHour(_time, _time.hour + delta)
        : _withHour(
            _time,
            _time.period.index * TimeOfDay.hoursPerPeriod +
                (_time.hour + delta) % TimeOfDay.hoursPerPeriod,
          );
    String hour(int delta) =>
        l.formatHour(stepHour(delta), alwaysUse24HourFormat: widget.alwaysUse24HourFormat);

    String minute(int delta) => l.formatMinute(
      TimeOfDay(hour: 0, minute: (_time.minute + delta) % TimeOfDay.minutesPerHour),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 8,
      children: <Widget>[
        _TimeColumn(
          debugLabel: 'LumenTimeHour',
          label: l.timePickerHourLabel,
          value: hour(0),
          increased: hour(1),
          decreased: hour(-1),
          accent: accent,
          autofocus: true,
          onStep: (delta) => setState(() => _time = stepHour(delta)),
          onEnter: _confirm,
        ),
        ExcludeSemantics(
          child: Text(
            ':',
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(color: LumenThemeExt.of(context).palette.textMuted),
          ),
        ),
        _TimeColumn(
          debugLabel: 'LumenTimeMinute',
          label: l.timePickerMinuteLabel,
          value: minute(0),
          increased: minute(1),
          decreased: minute(-1),
          accent: accent,
          onStep: (delta) => setState(() {
            _time = TimeOfDay(
              hour: _time.hour,
              minute: (_time.minute + delta) % TimeOfDay.minutesPerHour,
            );
          }),
          onEnter: _confirm,
        ),
        ?period,
      ],
    );
  }

  /// Confirms the selection, or shows why the typed time is not accepted.
  void _confirm() {
    if (_input && _parsed() == null) {
      setState(() => _invalid = true);
      return;
    }
    Navigator.of(context).pop(_time);
  }

  void _fillText() {
    final l = MaterialLocalizations.of(context);
    _hourText.text = l.formatHour(_time, alwaysUse24HourFormat: widget.alwaysUse24HourFormat);
    _minuteText.text = l.formatMinute(_time);
    _textFilled = true;
  }

  Widget _inputs(MaterialLocalizations l, LumenPalette p, Color accent, Widget? period) {
    final formatters = <TextInputFormatter>[
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(2),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: <Widget>[
            Expanded(
              child: LumenTextField(
                label: l.timePickerHourLabel,
                controller: _hourText,
                autofocus: true,
                accentColor: accent,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: formatters,
                onChanged: (_) => _onTextChanged(),
                onSubmitted: (_) => _minuteFocus.requestFocus(),
              ),
            ),
            Expanded(
              child: LumenTextField(
                label: l.timePickerMinuteLabel,
                controller: _minuteText,
                focusNode: _minuteFocus,
                accentColor: accent,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                inputFormatters: formatters,
                onChanged: (_) => _onTextChanged(),
                onSubmitted: (_) => _confirm(),
              ),
            ),
            ?period,
          ],
        ),
        if (_invalid)
          Semantics(
            liveRegion: true,
            child: Text(
              l.invalidTimeLabel,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: p.danger),
            ),
          ),
      ],
    );
  }

  void _onTextChanged() {
    final parsed = _parsed();
    setState(() {
      _invalid = false;
      if (parsed != null) {
        _time = parsed;
      }
    });
  }

  /// The time typed in the fields, or `null` when it is not valid.
  ///
  /// In 12-hour format the hour goes from 1 to 12 and keeps AM or PM.
  TimeOfDay? _parsed() {
    final hour = int.tryParse(_hourText.text);
    final minute = int.tryParse(_minuteText.text);
    if (hour == null || minute == null || minute >= TimeOfDay.minutesPerHour) {
      return null;
    }
    if (_uses24Hours(MaterialLocalizations.of(context))) {
      return hour < TimeOfDay.hoursPerDay ? TimeOfDay(hour: hour, minute: minute) : null;
    }
    if (hour < 1 || hour > TimeOfDay.hoursPerPeriod) {
      return null;
    }
    final offset = _time.period == DayPeriod.pm ? TimeOfDay.hoursPerPeriod : 0;
    return TimeOfDay(hour: hour % TimeOfDay.hoursPerPeriod + offset, minute: minute);
  }

  void _toggleInput() {
    setState(() {
      _input = !_input;
      _invalid = false;
      if (_input) {
        _fillText();
      }
    });
  }

  /// Whether the hours go from 0 to 23 rather than 1 to 12 with AM/PM.
  bool _uses24Hours(MaterialLocalizations l) =>
      hourFormat(of: l.timeOfDayFormat(alwaysUse24HourFormat: widget.alwaysUse24HourFormat)) !=
      HourFormat.h;
}

/// AM and PM, stacked, with the current one selected.
class _PeriodToggle extends StatelessWidget {
  final DayPeriod period;
  final Color accent;
  final ValueChanged<DayPeriod> onChanged;

  const _PeriodToggle({required this.period, required this.accent, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final p = LumenThemeExt.of(context).palette;
    final style = LumenStyle.of(context);
    final l = MaterialLocalizations.of(context);
    final radius = style.radius(12);

    Widget option(DayPeriod value, String label) {
      final selected = value == period;
      return Expanded(
        child: LumenPressable(
          onTap: () => onChanged(value),
          borderRadius: radius,
          selected: selected,
          child: AnimatedContainer(
            duration: LumenMotion.duration(context, kLumenFastDuration),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: radius,
              color: selected ? accent : accent.withValues(alpha: 0),
            ),
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(color: selected ? lumenForegroundOn(p, accent) : p.textSecondary),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: _boxHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          border: style.borderAll(color: accent.withValues(alpha: 0.5)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 2,
              children: <Widget>[
                option(DayPeriod.am, l.anteMeridiemAbbreviation),
                option(DayPeriod.pm, l.postMeridiemAbbreviation),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One value (hour or minute) between up and down buttons.
class _TimeColumn extends StatelessWidget {
  final String debugLabel;
  final String label;
  final String value;
  final String increased;
  final String decreased;
  final Color accent;
  final bool autofocus;
  final ValueChanged<int> onStep;
  final VoidCallback onEnter;

  const _TimeColumn({
    required this.debugLabel,
    required this.label,
    required this.value,
    required this.increased,
    required this.decreased,
    required this.accent,
    required this.onStep,
    required this.onEnter,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = LumenThemeExt.of(context).palette;
    final style = LumenStyle.of(context);

    // The buttons repeat what the value node already offers to screen
    // readers (increase and decrease) and to the keyboard (Up and Down).
    Widget step(IconData icon, int delta) => ExcludeSemantics(
      child: ExcludeFocus(
        child: LumenIconButton(
          icon: icon,
          variant: LumenIconButtonVariant.ghost,
          accentColor: accent,
          size: 40,
          onPressed: () => onStep(delta),
        ),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: <Widget>[
        step(Icons.keyboard_arrow_up_rounded, 1),
        LumenPickerFocusFrame(
          debugLabel: debugLabel,
          autofocus: autofocus,
          onKey: _onKey,
          child: Semantics(
            container: true,
            slider: true,
            label: label,
            value: value,
            increasedValue: increased,
            decreasedValue: decreased,
            onIncrease: () => onStep(1),
            onDecrease: () => onStep(-1),
            child: Container(
              width: 80,
              height: _boxHeight,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: style.radius(14),
                color: accent.withValues(alpha: style.surfaceAlpha(0.12)),
                border: style.borderAll(color: accent.withValues(alpha: 0.5)),
              ),
              child: ExcludeSemantics(
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: p.textPrimary,
                    fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
          ),
        ),
        step(Icons.keyboard_arrow_down_rounded, -1),
      ],
    );
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent && isLumenEnterKey(event.logicalKey)) {
      onEnter();
      return KeyEventResult.handled;
    }
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      onStep(1);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      onStep(-1);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }
}
