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
      label: 'Eventos',
    ),
    NavigationDestination(icon: Icon(Icons.person_outline), label: 'Conta'),
  ];

  bool _notifications = true;
  bool? _acceptedTerms = true;
  bool _favorite = false;
  String? _accent = 'Primária';
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
      appBar: AppBar(title: const Text('Material padrão')),
      bottomNavigationBar: NavigationBar(
        destinations: _destinations,
        selectedIndex: _destination,
        onDestinationSelected: (index) => setState(() => _destination = index),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.bolt_rounded),
        label: const Text('AÇÃO'),
        onPressed: () => _showMessage(context, 'FAB tocado!'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
        children: <Widget>[
          _section(
            'Cards e status',
            const Align(
              alignment: AlignmentDirectional.centerStart,
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: <Widget>[
                      Text('Serviço de telemetria'),
                      Text(
                        'Streaming de eventos em tempo real, 124 conexões ativas.',
                      ),
                      Wrap(
                        spacing: 8,
                        children: <Widget>[
                          Chip(label: Text('OK')),
                          Chip(label: Text('INFO')),
                          Chip(label: Text('ALERTA')),
                          Chip(label: Text('FALHA')),
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
            'Botões',
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                FilledButton.icon(
                  onPressed: () =>
                      _showMessage(context, 'Pipeline executado com sucesso'),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('EXECUTAR'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _showMessage(context, 'Editar'),
                  icon: const Icon(Icons.edit),
                  label: const Text('EDITAR'),
                ),
                TextButton(
                  onPressed: () => _showMessage(context, 'Cancelado'),
                  child: const Text('cancelar'),
                ),
                ElevatedButton(
                  onPressed: () =>
                      _showMessage(context, 'Ação principal selecionada'),
                  child: const Text('Continuar'),
                ),
                IconButton(
                  onPressed: () => _showMessage(context, 'Curtir'),
                  icon: const Icon(Icons.favorite),
                  tooltip: 'Curtir',
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _showMessage(context, value),
                  itemBuilder: (_) => const <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'Editar',
                      child: Text('Editar'),
                    ),
                    PopupMenuItem<String>(
                      value: 'Duplicar',
                      child: Text('Duplicar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _section(
            'Campos e seleções',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: <Widget>[
                const TextField(
                  decoration: InputDecoration(labelText: 'Nome do projeto'),
                ),
                const SearchBar(
                  hintText: 'Buscar eventos',
                  leading: Icon(Icons.search),
                ),
                SwitchListTile(
                  title: const Text('Notificações em tempo real'),
                  value: _notifications,
                  onChanged: (value) => setState(() => _notifications = value),
                ),
                CheckboxListTile(
                  title: const Text('Aceito os termos (tristate)'),
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
                        value: 'Primária',
                        title: Text('Primária'),
                      ),
                      RadioListTile<String>(
                        value: 'Secundária',
                        title: Text('Secundária'),
                      ),
                      RadioListTile<String>(
                        value: 'Terciária',
                        title: Text('Terciária'),
                      ),
                    ],
                  ),
                ),
                DropdownMenu<String>(
                  label: const Text('Cor de destaque'),
                  initialSelection: 'primary',
                  dropdownMenuEntries: const <DropdownMenuEntry<String>>[
                    DropdownMenuEntry<String>(
                      value: 'primary',
                      label: 'Primária',
                    ),
                    DropdownMenuEntry<String>(
                      value: 'secondary',
                      label: 'Secundária',
                    ),
                    DropdownMenuEntry<String>(
                      value: 'tertiary',
                      label: 'Terciária',
                    ),
                  ],
                ),
                Text('Volume (${(_volume * 100).round()}%)'),
                Slider(
                  value: _volume,
                  onChanged: (value) => setState(() => _volume = value),
                ),
                const Text('Faixa de preço'),
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
                      label: const Text('Favorito'),
                      selected: _favorite,
                      onSelected: (value) => setState(() => _favorite = value),
                    ),
                    for (final size in <String>['P', 'M', 'G'])
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
                            ? 'Data de início'
                            : localizations.formatCompactDate(_date!),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: _pickTime,
                      icon: const Icon(Icons.schedule),
                      label: Text(
                        _time == null
                            ? 'Horário'
                            : localizations.formatTimeOfDay(_time!),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _section(
            'Feedback e progresso',
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
                          _showMessage(context, 'Snackbar do Material'),
                      child: const Text('SNACKBAR'),
                    ),
                    OutlinedButton(
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Confirmar ação'),
                          content: const Text('Deseja prosseguir?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Fechar'),
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
                            title: Text('Ações rápidas'),
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
            'Lista e tabela',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.dashboard_outlined),
                  title: const Text('Dashboard'),
                  subtitle: const Text('Visão geral em tempo real'),
                  onTap: () => _showMessage(context, 'Dashboard'),
                ),
                const Divider(),
                const ExpansionTile(
                  leading: Icon(Icons.hub_outlined),
                  title: Text('Integrações'),
                  children: <Widget>[
                    ListTile(title: Text('Webhook de eventos')),
                  ],
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const <DataColumn>[
                      DataColumn(label: Text('Serviço')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Latência'), numeric: true),
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
                          DataCell(Text('ALERTA')),
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
