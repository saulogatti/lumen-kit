import 'package:material_ui/material_ui.dart';

/// Opens a comparison gallery with the default Material theme and widgets.
Future<void> showMaterialGallery(BuildContext context) async {
  await Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (context) => Theme(
        data: ThemeData(brightness: Theme.of(context).brightness),
        child: const ScaffoldMessenger(child: _MaterialGallery()),
      ),
    ),
  );
}

class _MaterialGallery extends StatefulWidget {
  const _MaterialGallery();

  @override
  State<_MaterialGallery> createState() => _MaterialGalleryState();
}

class _MaterialGalleryState extends State<_MaterialGallery> {
  static const _destinations = <NavigationDestination>[
    NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Home'),
    NavigationDestination(
      icon: Badge(label: Text('3'), child: Icon(Icons.bolt_outlined)),
      label: 'Events',
    ),
    NavigationDestination(icon: Icon(Icons.person_outline), label: 'Account'),
  ];

  bool _notifications = true;
  bool? _acceptedTerms = true;
  bool _favorite = false;
  String? _accent = 'Primary';
  String _size = 'M';
  double _volume = 0.4;
  RangeValues _price = const RangeValues(80, 320);
  DateTime? _date;
  TimeOfDay? _time;
  int _destination = 0;

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Default Material')),
      bottomNavigationBar: NavigationBar(
        destinations: _destinations,
        selectedIndex: _destination,
        onDestinationSelected: (index) => setState(() => _destination = index),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.bolt_rounded),
        label: const Text('ACTION'),
        onPressed: () => _showMessage(context, 'FAB tapped!'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
        children: <Widget>[
          _section(
            'Cards and status',
            const Align(
              alignment: AlignmentDirectional.centerStart,
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: <Widget>[
                      Text('Telemetry service'),
                      Text(
                        'Real-time event streaming, 124 active connections.',
                      ),
                      Wrap(
                        spacing: 8,
                        children: <Widget>[
                          Chip(label: Text('OK')),
                          Chip(label: Text('INFO')),
                          Chip(label: Text('WARNING')),
                          Chip(label: Text('FAILURE')),
                          Chip(label: Text('OFFLINE')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _section(
            'Buttons',
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                FilledButton.icon(
                  onPressed: () =>
                      _showMessage(context, 'Pipeline completed successfully'),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('RUN'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _showMessage(context, 'Edit'),
                  icon: const Icon(Icons.edit),
                  label: const Text('EDIT'),
                ),
                TextButton(
                  onPressed: () => _showMessage(context, 'Canceled'),
                  child: const Text('cancel'),
                ),
                ElevatedButton(
                  onPressed: () =>
                      _showMessage(context, 'Primary action selected'),
                  child: const Text('Continue'),
                ),
                IconButton(
                  onPressed: () => _showMessage(context, 'Like'),
                  icon: const Icon(Icons.favorite),
                  tooltip: 'Like',
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _showMessage(context, value),
                  itemBuilder: (_) => const <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(value: 'Edit', child: Text('Edit')),
                    PopupMenuItem<String>(
                      value: 'Duplicate',
                      child: Text('Duplicate'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _section(
            'Fields and selection',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: <Widget>[
                const TextField(
                  decoration: InputDecoration(labelText: 'Project name'),
                ),
                const SearchBar(
                  hintText: 'Search events',
                  leading: Icon(Icons.search),
                ),
                SwitchListTile(
                  title: const Text('Real-time notifications'),
                  value: _notifications,
                  onChanged: (value) => setState(() => _notifications = value),
                ),
                CheckboxListTile(
                  title: const Text('I accept the terms (tristate)'),
                  value: _acceptedTerms,
                  tristate: true,
                  onChanged: (value) => setState(() => _acceptedTerms = value),
                ),
                RadioGroup<String>(
                  groupValue: _accent,
                  onChanged: (value) => setState(() => _accent = value),
                  child: const Column(
                    children: <Widget>[
                      RadioListTile<String>(
                        value: 'Primary',
                        title: Text('Primary'),
                      ),
                      RadioListTile<String>(
                        value: 'Secondary',
                        title: Text('Secondary'),
                      ),
                      RadioListTile<String>(
                        value: 'Tertiary',
                        title: Text('Tertiary'),
                      ),
                    ],
                  ),
                ),
                DropdownMenu<String>(
                  label: const Text('Accent color'),
                  initialSelection: 'primary',
                  dropdownMenuEntries: const <DropdownMenuEntry<String>>[
                    DropdownMenuEntry<String>(
                      value: 'primary',
                      label: 'Primary',
                    ),
                    DropdownMenuEntry<String>(
                      value: 'secondary',
                      label: 'Secondary',
                    ),
                    DropdownMenuEntry<String>(
                      value: 'tertiary',
                      label: 'Tertiary',
                    ),
                  ],
                ),
                Text('Volume (${(_volume * 100).round()}%)'),
                Slider(
                  value: _volume,
                  onChanged: (value) => setState(() => _volume = value),
                ),
                const Text('Price range'),
                RangeSlider(
                  values: _price,
                  max: 500,
                  divisions: 50,
                  labels: RangeLabels(
                    _price.start.round().toString(),
                    _price.end.round().toString(),
                  ),
                  onChanged: (value) => setState(() => _price = value),
                ),
                Wrap(
                  spacing: 8,
                  children: <Widget>[
                    FilterChip(
                      label: const Text('Favorite'),
                      selected: _favorite,
                      onSelected: (value) => setState(() => _favorite = value),
                    ),
                    for (final size in <String>['S', 'M', 'L'])
                      ChoiceChip(
                        label: Text(size),
                        selected: _size == size,
                        onSelected: (_) => setState(() => _size = size),
                      ),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_today_outlined),
                      label: Text(
                        _date == null
                            ? 'Start date'
                            : localizations.formatCompactDate(_date!),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: _pickTime,
                      icon: const Icon(Icons.schedule),
                      label: Text(
                        _time == null
                            ? 'Time'
                            : localizations.formatTimeOfDay(_time!),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _section(
            'Feedback and progress',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: <Widget>[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    OutlinedButton(
                      onPressed: () =>
                          _showMessage(context, 'Material snackbar'),
                      child: const Text('SNACKBAR'),
                    ),
                    OutlinedButton(
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Confirm action'),
                          content: const Text('Do you want to continue?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      ),
                      child: const Text('DIALOG'),
                    ),
                    OutlinedButton(
                      onPressed: () => showModalBottomSheet<void>(
                        context: context,
                        builder: (context) => const SafeArea(
                          child: ListTile(
                            leading: Icon(Icons.bolt_outlined),
                            title: Text('Quick actions'),
                          ),
                        ),
                      ),
                      child: const Text('BOTTOM SHEET'),
                    ),
                  ],
                ),
                const LinearProgressIndicator(value: 0.35),
                const CircularProgressIndicator(value: 0.35),
              ],
            ),
          ),
          _section(
            'List and table',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.dashboard_outlined),
                  title: const Text('Dashboard'),
                  subtitle: const Text('Real-time overview'),
                  onTap: () => _showMessage(context, 'Dashboard'),
                ),
                const Divider(),
                const ExpansionTile(
                  leading: Icon(Icons.hub_outlined),
                  title: Text('Integrations'),
                  children: <Widget>[ListTile(title: Text('Event webhook'))],
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const <DataColumn>[
                      DataColumn(label: Text('Service')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Latency'), numeric: true),
                    ],
                    rows: const <DataRow>[
                      DataRow(
                        cells: <DataCell>[
                          DataCell(Text('api')),
                          DataCell(Text('OK')),
                          DataCell(Text('42ms')),
                        ],
                      ),
                      DataRow(
                        cells: <DataCell>[
                          DataCell(Text('worker')),
                          DataCell(Text('WARNING')),
                          DataCell(Text('118ms')),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (mounted && date != null) setState(() => _date = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );
    if (mounted && time != null) setState(() => _time = time);
  }

  Widget _section(String title, Widget child) => Padding(
    padding: const EdgeInsets.only(bottom: 28),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        child,
      ],
    ),
  );

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
