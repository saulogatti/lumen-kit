import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

/// Date and time fields that open the Lumen pickers.
class DateTimeSection extends StatefulWidget {
  /// Creates the date and time gallery content.
  const DateTimeSection({super.key});

  @override
  State<DateTimeSection> createState() => _DateTimeSectionState();
}

class _DateTimeSectionState extends State<DateTimeSection>
    with AutomaticKeepAliveClientMixin<DateTimeSection> {
  DateTime? _start;
  DateTime? _birth = DateTime(1990, 6, 15);
  TimeOfDay? _time;
  TimeOfDay? _shift = const TimeOfDay(hour: 22, minute: 15);

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final p = LumenThemeExt.of(context).palette;
    final body = Theme.of(context).textTheme.bodyMedium?.copyWith(color: p.textSecondary);
    final today = DateUtils.dateOnly(DateTime.now());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: <Widget>[
        Text(
          'Tap the month title to jump to a year, or the pencil to type the date. '
          'Arrow keys move the day and Page Up or Page Down the month. '
          'In the time picker, Up and Down change the focused column.',
          style: body,
        ),
        LumenDatePicker(
          label: 'Start date',
          value: _start,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030, 12, 31),
          onChanged: (v) => setState(() => _start = v),
        ),
        LumenDatePicker(
          label: 'Birth date',
          value: _birth,
          firstDate: DateTime(1900),
          lastDate: today,
          accentColor: p.tertiary,
          onChanged: (v) => setState(() => _birth = v),
        ),
        LumenTimePicker(label: 'Time', value: _time, onChanged: (v) => setState(() => _time = v)),
        LumenTimePicker(
          label: 'Shift start (24 h)',
          value: _shift,
          use24HourFormat: true,
          accentColor: p.secondary,
          onChanged: (v) => setState(() => _shift = v),
        ),
      ],
    );
  }
}
