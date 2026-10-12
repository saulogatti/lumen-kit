import 'package:material_ui/material_ui.dart';
import 'package:flutter/widget_previews.dart';
import 'package:neon_ui/neon_ui.dart';

void main() => runApp(const NeonExampleApp());

class MyWidget extends StatelessWidget {
  @Preview(name: 'Constructor preview')
  const MyWidget.preview({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'neon_ui example',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const _GalleryScreen(),
    );
  }
}

/// Preset, estilo e brilho atuais da galeria. Trocar qualquer um re-tematiza
/// o app inteiro (cores com transição animada via [NeonThemeExt.lerp]).
final ValueNotifier<NeonPreset> _preset = ValueNotifier<NeonPreset>(
  NeonPreset.neon,
);
final ValueNotifier<String> _style = ValueNotifier<String>('neon');
final ValueNotifier<Brightness> _brightness = ValueNotifier<Brightness>(
  Brightness.light,
);

class NeonExampleApp extends StatelessWidget {
  const NeonExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge(<Listenable>[_preset, _style, _brightness]),
      builder: (BuildContext context, _) => MaterialApp(
        title: 'neon_ui example',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.fromPreset(
          _preset.value,
          brightness: _brightness.value,
          style: NeonStyle.presets[_style.value]!,
        ),
        home: const _GalleryScreen(),
      ),
    );
  }
}

class _GalleryScreen extends StatefulWidget {
  const _GalleryScreen();

  @override
  State<_GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<_GalleryScreen> {
  double _progress = 0.35;
  bool _busy = false;
  String _slug = 'meu-app-neon';

  // Inputs
  bool _switchOn = true;
  bool? _checkbox = true;
  String _radio = 'a';
  double _slider = 0.4;
  String _dropdown = 'cyan';
  String _search = '';
  DateTime? _date;

  // Navegação
  int _tab = 0;
  int _segment = 1;
  int _bottomNav = 0;
  int _step = 1;

  // Display
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final NeonPalette p = NeonThemeExt.of(context).palette;
    return Scaffold(
      appBar: NeonAppBar(
        title: 'neon_ui',
        subtitle: 'gallery',
        leading: Builder(
          builder: (BuildContext ctx) => NeonIconButton.ghost(
            icon: Icons.menu_rounded,
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
      ),
      drawer: NeonDrawer(
        header: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Row(
            children: <Widget>[
              const NeonAvatar(initials: 'NU', radius: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'neon_ui',
                      style: TextStyle(
                        color: p.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'demo gallery',
                      style: TextStyle(color: p.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        children: <Widget>[
          NeonDrawerItem(
            icon: Icons.dashboard_outlined,
            label: 'Dashboard',
            selected: true,
            onTap: () => Navigator.pop(context),
          ),
          NeonDrawerItem(
            icon: Icons.bolt_outlined,
            label: 'Eventos',
            trailing: const NeonBadge(label: '3'),
            onTap: () => Navigator.pop(context),
          ),
          NeonDrawerItem(
            icon: Icons.settings_outlined,
            label: 'Configurações',
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
      bottomNavigationBar: NeonBottomNavBar(
        selectedIndex: _bottomNav,
        onChanged: (int i) => setState(() => _bottomNav = i),
        items: const <NeonNavItem>[
          NeonNavItem(icon: Icons.dashboard_outlined, label: 'Home'),
          NeonNavItem(icon: Icons.bolt_outlined, label: 'Eventos', badge: '3'),
          NeonNavItem(icon: Icons.person_outline, label: 'Conta'),
        ],
      ),
      floatingActionButton: NeonFab.extended(
        icon: Icons.bolt_rounded,
        label: 'AÇÃO',
        onPressed: () => showNeonToast(
          context: context,
          message: 'FAB tocado!',
          tone: StatusTone.success,
          position: NeonToastPosition.top,
        ),
      ),
      body: AnimatedGridBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          children: <Widget>[
            _section(
              'Paleta e estilo',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      for (final NeonPreset preset in NeonPreset.values)
                        NeonTag(
                          label: preset.name,
                          color: preset.primary,
                          icon: _preset.value == preset
                              ? Icons.check_rounded
                              : null,
                          onTap: () => _preset.value = preset,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      for (final String name in NeonStyle.presets.keys)
                        NeonTag(
                          label: name,
                          icon: _style.value == name
                              ? Icons.check_rounded
                              : Icons.auto_awesome_outlined,
                          onTap: () => _style.value = name,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      NeonSwitch(
                        value: _brightness.value == Brightness.dark,
                        onChanged: (bool dark) => _brightness.value = dark
                            ? Brightness.dark
                            : Brightness.light,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'modo escuro',
                        style: TextStyle(color: p.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _section(
              'Cards & status',
              NeonCard(
                glow: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: const <Widget>[
                    Text(
                      'Serviço de telemetria',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Streaming de eventos em tempo real, 124 conexões ativas.',
                    ),
                    SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        StatusChip(label: 'OK', tone: StatusTone.success),
                        StatusChip(label: 'INFO', tone: StatusTone.info),
                        StatusChip(label: 'ALERTA', tone: StatusTone.warning),
                        StatusChip(label: 'FALHA', tone: StatusTone.danger),
                        StatusChip(label: 'OFFLINE', tone: StatusTone.neutral),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            _section(
              'Botões',
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  NeonButton(
                    label: 'EXECUTAR',
                    icon: Icons.play_arrow_rounded,
                    busy: _busy,
                    onPressed: () async {
                      setState(() => _busy = true);
                      await Future<void>.delayed(const Duration(seconds: 1));
                      if (!context.mounted) return;
                      setState(() => _busy = false);
                      showNeonSnackBar(
                        context: context,
                        message: 'Pipeline executado com sucesso',
                        tone: StatusTone.success,
                      );
                    },
                  ),
                  NeonButton.outline(
                    label: 'EDITAR',
                    icon: Icons.edit,
                    onPressed: () {},
                  ),
                  NeonButton.ghost(label: 'cancelar', onPressed: () {}),
                ],
              ),
            ),
            _section(
              'Icon buttons & FAB',
              Row(
                children: <Widget>[
                  NeonIconButton(
                    icon: Icons.favorite,
                    tooltip: 'Curtir',
                    onPressed: () {},
                  ),
                  const SizedBox(width: 12),
                  NeonIconButton.solid(
                    icon: Icons.refresh,
                    tooltip: 'Atualizar',
                    onPressed: () {},
                  ),
                  const SizedBox(width: 12),
                  NeonIconButton.ghost(
                    icon: Icons.more_vert,
                    tooltip: 'Mais',
                    onPressed: () {},
                  ),
                  const SizedBox(width: 12),
                  NeonIconButton(
                    icon: Icons.lock_outline_rounded,
                    shape: NeonIconButtonShape.rounded,
                    onPressed: null,
                  ),
                  const Spacer(),
                  NeonTooltip(
                    message: 'Quadrado, com tooltip neon',
                    child: NeonIconButton(
                      icon: Icons.info_outline,
                      shape: NeonIconButtonShape.rounded,
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
            _section(
              'Inputs — texto & busca',
              Column(
                children: <Widget>[
                  NeonTextField(
                    label: 'Slug do projeto',
                    initialValue: _slug,
                    icon: Icons.tag_rounded,
                    onChanged: (String v) => _slug = v,
                  ),
                  const SizedBox(height: 16),
                  NeonSearchBar(
                    hint: 'Buscar componente…',
                    initialValue: _search,
                    onChanged: (String v) => setState(() => _search = v),
                  ),
                ],
              ),
            ),
            _section(
              'Inputs — seleção',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  NeonSwitch(
                    value: _switchOn,
                    label: 'Notificações em tempo real',
                    onChanged: (bool v) => setState(() => _switchOn = v),
                  ),
                  const SizedBox(height: 12),
                  NeonCheckbox(
                    value: _checkbox,
                    tristate: true,
                    label: 'Aceito os termos (tristate)',
                    onChanged: (bool? v) => setState(() => _checkbox = v),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    children: <Widget>[
                      NeonRadio<String>(
                        value: 'a',
                        groupValue: _radio,
                        label: 'Cyan',
                        onChanged: (String? v) =>
                            setState(() => _radio = v ?? _radio),
                      ),
                      NeonRadio<String>(
                        value: 'b',
                        groupValue: _radio,
                        label: 'Magenta',
                        accentColor: p.secondary,
                        onChanged: (String? v) =>
                            setState(() => _radio = v ?? _radio),
                      ),
                      NeonRadio<String>(
                        value: 'c',
                        groupValue: _radio,
                        label: 'Blue',
                        accentColor: p.tertiary,
                        onChanged: (String? v) =>
                            setState(() => _radio = v ?? _radio),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Volume (${(_slider * 100).round()}%)',
                    style: TextStyle(color: p.textMuted),
                  ),
                  NeonSlider(
                    value: _slider,
                    onChanged: (double v) => setState(() => _slider = v),
                  ),
                  const SizedBox(height: 4),
                  NeonDropdown<String>(
                    label: 'Accent padrão',
                    value: _dropdown,
                    items: const <NeonDropdownItem<String>>[
                      NeonDropdownItem<String>(
                        value: 'cyan',
                        label: 'Cyan',
                        icon: Icons.circle_outlined,
                      ),
                      NeonDropdownItem<String>(
                        value: 'magenta',
                        label: 'Magenta',
                        icon: Icons.circle_outlined,
                      ),
                      NeonDropdownItem<String>(
                        value: 'blue',
                        label: 'Blue',
                        icon: Icons.circle_outlined,
                      ),
                    ],
                    onChanged: (String? v) =>
                        setState(() => _dropdown = v ?? _dropdown),
                  ),
                  const SizedBox(height: 16),
                  NeonDatePicker(
                    label: 'Data de início',
                    value: _date,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    onChanged: (DateTime v) => setState(() => _date = v),
                  ),
                ],
              ),
            ),
            _section(
              'Progresso',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Determinado (${(_progress * 100).round()}%)'),
                  const SizedBox(height: 8),
                  NeonLinearProgress(value: _progress),
                  const SizedBox(height: 12),
                  NeonSlider(
                    value: _progress,
                    onChanged: (double v) => setState(() => _progress = v),
                  ),
                  const SizedBox(height: 12),
                  const Text('Indeterminado'),
                  const SizedBox(height: 8),
                  const NeonLinearProgress(),
                  const SizedBox(height: 20),
                  Row(
                    children: const <Widget>[
                      NeonCircularProgress(value: 0.7),
                      SizedBox(width: 20),
                      NeonCircularProgress(),
                      SizedBox(width: 20),
                      NeonCircularProgress(size: 56, strokeWidth: 5),
                    ],
                  ),
                ],
              ),
            ),
            _section(
              'Skeleton (loading state)',
              Row(
                children: const <Widget>[
                  NeonSkeleton.circle(size: 48),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        NeonSkeleton(width: 160),
                        SizedBox(height: 8),
                        NeonSkeleton(width: 220, height: 10),
                        SizedBox(height: 8),
                        NeonSkeleton(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _section(
              'Feedback (snackbar, toast, dialog, bottom sheet)',
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  NeonButton.outline(
                    label: 'SNACKBAR',
                    icon: Icons.notifications_active_outlined,
                    onPressed: () => showNeonSnackBar(
                      context: context,
                      message: 'Snackbar com tom de alerta',
                      tone: StatusTone.warning,
                      action: SnackBarAction(
                        label: 'desfazer',
                        onPressed: () {},
                      ),
                    ),
                  ),
                  NeonButton.outline(
                    label: 'TOAST',
                    icon: Icons.bolt_outlined,
                    onPressed: () => showNeonToast(
                      context: context,
                      message: 'Toast flutuante via Overlay',
                      tone: StatusTone.info,
                    ),
                  ),
                  NeonButton.outline(
                    label: 'DIALOG',
                    icon: Icons.warning_amber_rounded,
                    onPressed: () => showNeonDialog<void>(
                      context: context,
                      title: 'Confirmar ação',
                      icon: Icons.warning_amber_rounded,
                      content: const Text(
                        'Esta operação não pode ser desfeita. Deseja prosseguir?',
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar'),
                        ),
                        NeonButton(
                          label: 'CONFIRMAR',
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  NeonButton.outline(
                    label: 'BOTTOM SHEET',
                    icon: Icons.vertical_align_bottom_rounded,
                    onPressed: () => showNeonBottomSheet<void>(
                      context: context,
                      builder: (BuildContext _) => Padding(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text(
                              'Ações rápidas',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            NeonListTile(
                              leading: Icon(
                                Icons.share_outlined,
                                color: p.primary,
                              ),
                              title: 'Compartilhar',
                              subtitle: 'Gera um link de convite',
                              onTap: () => Navigator.pop(context),
                            ),
                            const SizedBox(height: 8),
                            NeonListTile(
                              leading: Icon(
                                Icons.delete_outline,
                                color: p.danger,
                              ),
                              title: 'Remover',
                              onTap: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _section(
              'Tabs & segmented',
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  NeonTabs(
                    selectedIndex: _tab,
                    onChanged: (int i) => setState(() => _tab = i),
                    items: const <NeonTabItem>[
                      NeonTabItem(label: 'Visão geral', icon: Icons.bar_chart),
                      NeonTabItem(label: 'Eventos', icon: Icons.bolt_outlined),
                      NeonTabItem(label: 'Alertas', icon: Icons.warning_amber),
                    ],
                  ),
                  const SizedBox(height: 16),
                  NeonSegmentedControl(
                    selectedIndex: _segment,
                    onChanged: (int i) => setState(() => _segment = i),
                    items: const <NeonTabItem>[
                      NeonTabItem(label: 'Dia'),
                      NeonTabItem(label: 'Semana'),
                      NeonTabItem(label: 'Mês'),
                    ],
                  ),
                ],
              ),
            ),
            _section(
              'Stepper',
              NeonStepper(
                currentStep: _step,
                onStepTapped: (int i) => setState(() => _step = i),
                steps: const <NeonStep>[
                  NeonStep(title: 'Conta', subtitle: 'criar credenciais'),
                  NeonStep(title: 'Perfil', subtitle: 'dados pessoais'),
                  NeonStep(title: 'Pronto', subtitle: 'concluir'),
                ],
              ),
            ),
            _section(
              'Avatar, badge & tag',
              Wrap(
                spacing: 16,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  const NeonAvatar(initials: 'SG', radius: 26),
                  NeonAvatar(
                    initials: 'NU',
                    radius: 26,
                    statusColor: p.success,
                  ),
                  const NeonBadge(
                    label: '12',
                    child: Icon(
                      Icons.notifications_outlined,
                      color: Colors.white70,
                      size: 30,
                    ),
                  ),
                  NeonBadge.dot(
                    color: p.success,
                    child: const Icon(
                      Icons.mail_outline,
                      color: Colors.white70,
                      size: 30,
                    ),
                  ),
                  const NeonTag(label: 'novo', icon: Icons.fiber_new_outlined),
                  NeonTag(label: 'beta', color: p.secondary),
                ],
              ),
            ),
            _section(
              'Lista, divider & expansion',
              Column(
                children: <Widget>[
                  NeonListTile(
                    leading: Icon(Icons.dashboard_outlined, color: p.primary),
                    title: 'Dashboard',
                    subtitle: 'visão geral em tempo real',
                    trailing: const NeonTag(label: 'live'),
                    selected: true,
                    onTap: () {},
                  ),
                  const SizedBox(height: 8),
                  NeonListTile(
                    leading: Icon(Icons.settings_outlined, color: p.secondary),
                    title: 'Configurações',
                    subtitle: 'tokens, paleta e integrações',
                    onTap: () {},
                  ),
                  const NeonDivider(label: 'avançado'),
                  NeonExpansionTile(
                    title: 'Integrações',
                    subtitle: 'webhooks, SSO, API keys',
                    leading: Icon(Icons.hub_outlined, color: p.primary),
                    initiallyExpanded: _expanded,
                    onExpansionChanged: (bool v) =>
                        setState(() => _expanded = v),
                    children: <Widget>[
                      NeonListTile(
                        title: 'Webhook de eventos',
                        subtitle: 'POST → https://hooks.example.com',
                        trailing: const NeonTag(
                          label: 'ativo',
                          icon: Icons.check_circle_outline,
                        ),
                        onTap: () {},
                      ),
                      const SizedBox(height: 6),
                      NeonListTile(
                        title: 'API Key principal',
                        subtitle: 'sk_live_••••8421',
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _section(
              'Data table',
              NeonDataTable(
                columns: const <DataColumn>[
                  DataColumn(label: Text('Serviço')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Latência'), numeric: true),
                ],
                rows: const <DataRow>[
                  DataRow(
                    cells: <DataCell>[
                      DataCell(Text('api')),
                      DataCell(
                        StatusChip(label: 'OK', tone: StatusTone.success),
                      ),
                      DataCell(Text('42ms')),
                    ],
                  ),
                  DataRow(
                    cells: <DataCell>[
                      DataCell(Text('worker')),
                      DataCell(
                        StatusChip(label: 'ALERTA', tone: StatusTone.warning),
                      ),
                      DataCell(Text('118ms')),
                    ],
                  ),
                  DataRow(
                    cells: <DataCell>[
                      DataCell(Text('cache')),
                      DataCell(
                        StatusChip(label: 'FALHA', tone: StatusTone.danger),
                      ),
                      DataCell(Text('—')),
                    ],
                  ),
                ],
              ),
            ),
            _section(
              'Navegação (cards)',
              Column(
                children: <Widget>[
                  NavigationCard(
                    title: 'Dashboard',
                    subtitle: 'visão geral em tempo real',
                    icon: Icons.dashboard_outlined,
                    accent: p.primary,
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  NavigationCard(
                    title: 'Configurações',
                    subtitle: 'tokens, paleta e integrações',
                    icon: Icons.settings_outlined,
                    accent: p.secondary,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, Widget child) {
    final NeonPalette p = NeonThemeExt.of(context).palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: p.textSecondary,
              fontSize: 12,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
