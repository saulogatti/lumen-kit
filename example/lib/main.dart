import 'package:flutter/widget_previews.dart';
import 'package:lumen_kit/lumen_kit.dart';
import 'package:material_ui/material_ui.dart';

void main() => runApp(const LumenExampleApp());

const List<LumenMenuEntry<String>> _menuItems = <LumenMenuEntry<String>>[
  LumenMenuItem<String>(value: 'editar', label: 'Editar', icon: Icons.edit),
  LumenMenuItem<String>(
    value: 'duplicar',
    label: 'Duplicar',
    icon: Icons.copy_rounded,
  ),
  LumenMenuItem<String>(
    value: 'arquivar',
    label: 'Arquivar',
    icon: Icons.archive_outlined,
    enabled: false,
  ),
  LumenMenuDivider<String>(),
  LumenMenuItem<String>(
    value: 'excluir',
    label: 'Excluir',
    icon: Icons.delete_outline,
    destructive: true,
  ),
];

final ValueNotifier<Brightness> _brightness = ValueNotifier<Brightness>(
  Brightness.light,
);

/// Preset, estilo e brilho atuais da galeria. Trocar qualquer um re-tematiza
/// o app inteiro (cores com transição animada via [LumenThemeExt.lerp]).
final ValueNotifier<LumenPreset> _preset = ValueNotifier<LumenPreset>(
  LumenPreset.neon,
);

final ValueNotifier<String> _style = ValueNotifier<String>('neon');

class LumenExampleApp extends StatelessWidget {
  const LumenExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge(<Listenable>[_preset, _style, _brightness]),
      builder: (BuildContext context, _) => MaterialApp(
        title: 'lumen_kit example',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.fromPreset(
          _preset.value,
          brightness: _brightness.value,
          style: LumenStyle.presets[_style.value]!,
        ),
        home: const _GalleryScreen(),
      ),
    );
  }
}

class MyWidget extends StatelessWidget {
  @Preview(name: 'Constructor preview')
  const MyWidget.preview({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'lumen_kit example',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const _GalleryScreen(),
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
  TimeOfDay? _time;
  RangeValues _price = const RangeValues(80, 320);
  String? _size = 'm';
  Set<String> _filters = <String>{'promo'};
  int _qty = 1;
  double _rating = 4;
  bool _overlay = false;
  bool _bannerVisible = true;
  String _pin = '';

  // Navegação
  int _tab = 0;
  int _segment = 1;
  int _bottomNav = 0;
  int _step = 1;

  // Display
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final LumenPalette p = LumenThemeExt.of(context).palette;
    return Scaffold(
      appBar: LumenAppBar(
        title: 'lumen_kit',
        subtitle: 'gallery',
        leading: Builder(
          builder: (BuildContext ctx) => LumenIconButton.ghost(
            icon: Icons.menu_rounded,
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
      ),
      drawer: LumenDrawer(
        header: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Row(
            children: <Widget>[
              const LumenAvatar(initials: 'NU', radius: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'lumen_kit',
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
          LumenDrawerItem(
            icon: Icons.dashboard_outlined,
            label: 'Dashboard',
            selected: true,
            onTap: () => Navigator.pop(context),
          ),
          LumenDrawerItem(
            icon: Icons.bolt_outlined,
            label: 'Eventos',
            trailing: const LumenBadge(label: '3'),
            onTap: () => Navigator.pop(context),
          ),
          LumenDrawerItem(
            icon: Icons.settings_outlined,
            label: 'Configurações',
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
      bottomNavigationBar: LumenBottomNavBar(
        selectedIndex: _bottomNav,
        onChanged: (int i) => setState(() => _bottomNav = i),
        items: const <LumenNavItem>[
          LumenNavItem(icon: Icons.dashboard_outlined, label: 'Home'),
          LumenNavItem(icon: Icons.bolt_outlined, label: 'Eventos', badge: '3'),
          LumenNavItem(icon: Icons.person_outline, label: 'Conta'),
        ],
      ),
      floatingActionButton: LumenFab.extended(
        icon: Icons.bolt_rounded,
        label: 'AÇÃO',
        onPressed: () => showLumenToast(
          context: context,
          message: 'FAB tocado!',
          tone: LumenStatusTone.success,
          position: LumenToastPosition.top,
        ),
      ),
      body: LumenAnimatedGridBackground(
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
                      for (final LumenPreset preset in LumenPreset.values)
                        LumenTag(
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
                      for (final String name in LumenStyle.presets.keys)
                        LumenTag(
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
                      LumenSwitch(
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
              LumenCard(
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
                        LumenStatusChip(
                          label: 'OK',
                          tone: LumenStatusTone.success,
                        ),
                        LumenStatusChip(
                          label: 'INFO',
                          tone: LumenStatusTone.info,
                        ),
                        LumenStatusChip(
                          label: 'ALERTA',
                          tone: LumenStatusTone.warning,
                        ),
                        LumenStatusChip(
                          label: 'FALHA',
                          tone: LumenStatusTone.danger,
                        ),
                        LumenStatusChip(
                          label: 'OFFLINE',
                          tone: LumenStatusTone.neutral,
                        ),
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
                  LumenButton(
                    label: 'EXECUTAR',
                    icon: Icons.play_arrow_rounded,
                    busy: _busy,
                    onPressed: () async {
                      setState(() => _busy = true);
                      await Future<void>.delayed(const Duration(seconds: 1));
                      if (!context.mounted) return;
                      setState(() => _busy = false);
                      showLumenSnackBar(
                        context: context,
                        message: 'Pipeline executado com sucesso',
                        tone: LumenStatusTone.success,
                      );
                    },
                  ),
                  LumenButton.outline(
                    label: 'EDITAR',
                    icon: Icons.edit,
                    onPressed: () {},
                  ),
                  LumenButton.ghost(label: 'cancelar', onPressed: () {}),
                ],
              ),
            ),
            _section(
              'Icon buttons & FAB',
              Row(
                children: <Widget>[
                  LumenIconButton(
                    icon: Icons.favorite,
                    tooltip: 'Curtir',
                    onPressed: () {},
                  ),
                  const SizedBox(width: 12),
                  LumenIconButton.solid(
                    icon: Icons.refresh,
                    tooltip: 'Atualizar',
                    onPressed: () {},
                  ),
                  const SizedBox(width: 12),
                  LumenIconButton.ghost(
                    icon: Icons.more_vert,
                    tooltip: 'Mais',
                    onPressed: () {},
                  ),
                  const SizedBox(width: 12),
                  LumenIconButton(
                    icon: Icons.lock_outline_rounded,
                    shape: LumenIconButtonShape.rounded,
                    onPressed: null,
                  ),
                  const Spacer(),
                  LumenTooltip(
                    message: 'Quadrado, com tooltip neon',
                    child: LumenIconButton(
                      icon: Icons.info_outline,
                      shape: LumenIconButtonShape.rounded,
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
                  LumenTextField(
                    label: 'Slug do projeto',
                    initialValue: _slug,
                    icon: Icons.tag_rounded,
                    onChanged: (String v) => _slug = v,
                  ),
                  const SizedBox(height: 16),
                  LumenSearchBar(
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
                  LumenSwitch(
                    value: _switchOn,
                    label: 'Notificações em tempo real',
                    onChanged: (bool v) => setState(() => _switchOn = v),
                  ),
                  const SizedBox(height: 12),
                  LumenCheckbox(
                    value: _checkbox,
                    tristate: true,
                    label: 'Aceito os termos (tristate)',
                    onChanged: (bool? v) => setState(() => _checkbox = v),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    children: <Widget>[
                      LumenRadio<String>(
                        value: 'a',
                        groupValue: _radio,
                        label: 'Cyan',
                        onChanged: (String? v) =>
                            setState(() => _radio = v ?? _radio),
                      ),
                      LumenRadio<String>(
                        value: 'b',
                        groupValue: _radio,
                        label: 'Magenta',
                        accentColor: p.secondary,
                        onChanged: (String? v) =>
                            setState(() => _radio = v ?? _radio),
                      ),
                      LumenRadio<String>(
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
                  LumenSlider(
                    value: _slider,
                    onChanged: (double v) => setState(() => _slider = v),
                  ),
                  Text(
                    'Preço (R\$ ${_price.start.round()} – '
                    'R\$ ${_price.end.round()})',
                    style: TextStyle(color: p.textMuted),
                  ),
                  LumenRangeSlider(
                    values: _price,
                    max: 500,
                    divisions: 50,
                    labels: RangeLabels(
                      'R\$ ${_price.start.round()}',
                      'R\$ ${_price.end.round()}',
                    ),
                    onChanged: (RangeValues v) => setState(() => _price = v),
                  ),
                  const SizedBox(height: 4),
                  LumenDropdown<String>(
                    label: 'Accent padrão',
                    value: _dropdown,
                    items: const <LumenDropdownItem<String>>[
                      LumenDropdownItem<String>(
                        value: 'cyan',
                        label: 'Cyan',
                        icon: Icons.circle_outlined,
                      ),
                      LumenDropdownItem<String>(
                        value: 'magenta',
                        label: 'Magenta',
                        icon: Icons.circle_outlined,
                      ),
                      LumenDropdownItem<String>(
                        value: 'blue',
                        label: 'Blue',
                        icon: Icons.circle_outlined,
                      ),
                    ],
                    onChanged: (String? v) =>
                        setState(() => _dropdown = v ?? _dropdown),
                  ),
                  const SizedBox(height: 16),
                  LumenDatePicker(
                    label: 'Data de início',
                    value: _date,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    onChanged: (DateTime v) => setState(() => _date = v),
                  ),
                  const SizedBox(height: 16),
                  LumenTimePicker(
                    label: 'Horário',
                    value: _time,
                    onChanged: (TimeOfDay v) => setState(() => _time = v),
                  ),
                ],
              ),
            ),
            _section(
              'Código (pin)',
              LumenPinField(
                value: _pin,
                onChanged: (String v) => setState(() => _pin = v),
                onCompleted: (String v) => showLumenToast(
                  context: context,
                  message: 'Código $v completo',
                  tone: LumenStatusTone.success,
                ),
              ),
            ),
            _section(
              'Chips, quantidade & avaliação',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: <Widget>[
                  LumenChoiceChips<String>(
                    value: _size,
                    onChanged: (String? v) => setState(() => _size = v),
                    items: const <LumenChipItem<String>>[
                      LumenChipItem<String>(value: 'p', label: 'P'),
                      LumenChipItem<String>(value: 'm', label: 'M'),
                      LumenChipItem<String>(value: 'g', label: 'G'),
                      LumenChipItem<String>(
                        value: 'gg',
                        label: 'GG',
                        enabled: false,
                      ),
                    ],
                  ),
                  LumenFilterChips<String>(
                    values: _filters,
                    onChanged: (Set<String> v) => setState(() => _filters = v),
                    items: const <LumenChipItem<String>>[
                      LumenChipItem<String>(value: 'promo', label: 'Promoção'),
                      LumenChipItem<String>(
                        value: 'frete',
                        label: 'Frete grátis',
                        icon: Icons.local_shipping_outlined,
                      ),
                      LumenChipItem<String>(value: 'novo', label: 'Lançamento'),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      LumenQuantityStepper(
                        value: _qty,
                        min: 1,
                        max: 10,
                        semanticLabel: 'Quantidade',
                        onChanged: (int v) => setState(() => _qty = v),
                      ),
                      const Spacer(),
                      LumenRating(
                        value: _rating,
                        allowHalf: true,
                        semanticLabel: 'Avaliação',
                        onChanged: (double v) => setState(() => _rating = v),
                      ),
                    ],
                  ),
                  Row(
                    spacing: 8,
                    children: <Widget>[
                      const LumenRating(value: 4.3, size: 16),
                      Text(
                        '4.3 (128 avaliações)',
                        style: TextStyle(color: p.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _section(
              'Menu & loading',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: <Widget>[
                  LumenCard(
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            'Card com menu de ações',
                            style: TextStyle(color: p.textSecondary),
                          ),
                        ),
                        LumenMenuButton<String>(
                          items: _menuItems,
                          onSelected: (String v) => showLumenToast(
                            context: context,
                            message: 'Ação: $v',
                          ),
                        ),
                      ],
                    ),
                  ),
                  LumenContextMenu<String>(
                    items: _menuItems,
                    onSelected: (String v) =>
                        showLumenToast(context: context, message: 'Ação: $v'),
                    child: LumenLoadingOverlay(
                      loading: _overlay,
                      message: 'Sincronizando…',
                      borderRadius: LumenStyle.of(context).radius(20),
                      child: LumenCard(
                        child: SizedBox(
                          height: 120,
                          child: Center(
                            child: LumenSwitch(
                              value: _overlay,
                              label: 'Overlay por 3s (clique direito: menu)',
                              onChanged: (bool v) async {
                                setState(() => _overlay = v);
                                await Future<void>.delayed(
                                  const Duration(seconds: 3),
                                );
                                if (mounted) setState(() => _overlay = false);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  LumenButton.outline(
                    label: 'ENVIAR (tela cheia)',
                    icon: Icons.send_rounded,
                    onPressed: () async {
                      await showLumenLoading<void>(
                        context: context,
                        message: 'Enviando formulário…',
                        task: () =>
                            Future<void>.delayed(const Duration(seconds: 2)),
                      );
                      if (!context.mounted) return;
                      showLumenSnackBar(
                        context: context,
                        message: 'Formulário enviado',
                        tone: LumenStatusTone.success,
                      );
                    },
                  ),
                ],
              ),
            ),
            _section(
              'Carrossel',
              LumenCarousel(
                itemCount: 4,
                height: 150,
                itemBuilder: (BuildContext context, int i) {
                  final List<Color> c = <Color>[
                    p.primary,
                    p.secondary,
                    p.tertiary,
                    p.success,
                  ];
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[
                          c[i].withValues(alpha: 0.55),
                          p.surface,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Slide ${i + 1}',
                        style: TextStyle(
                          color: p.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            _section(
              'Progresso',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Determinado (${(_progress * 100).round()}%)'),
                  const SizedBox(height: 8),
                  LumenLinearProgress(value: _progress),
                  const SizedBox(height: 12),
                  LumenSlider(
                    value: _progress,
                    onChanged: (double v) => setState(() => _progress = v),
                  ),
                  const SizedBox(height: 12),
                  const Text('Indeterminado'),
                  const SizedBox(height: 8),
                  const LumenLinearProgress(),
                  const SizedBox(height: 20),
                  Row(
                    children: const <Widget>[
                      LumenCircularProgress(value: 0.7),
                      SizedBox(width: 20),
                      LumenCircularProgress(),
                      SizedBox(width: 20),
                      LumenCircularProgress(size: 56, strokeWidth: 5),
                    ],
                  ),
                ],
              ),
            ),
            _section(
              'Skeleton (loading state)',
              Row(
                children: const <Widget>[
                  LumenSkeleton.circle(size: 48),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        LumenSkeleton(width: 160),
                        SizedBox(height: 8),
                        LumenSkeleton(width: 220, height: 10),
                        SizedBox(height: 8),
                        LumenSkeleton(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _section(
              'Banner, vazio e lista',
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: <Widget>[
                  if (_bannerVisible)
                    LumenBanner(
                      message: 'Sincronização pausada neste dispositivo.',
                      tone: LumenStatusTone.warning,
                      actionLabel: 'Retomar',
                      onAction: () => showLumenToast(
                        context: context,
                        message: 'Retomando',
                        tone: LumenStatusTone.info,
                      ),
                      onDismiss: () => setState(() => _bannerVisible = false),
                    )
                  else
                    Align(
                      alignment: Alignment.centerLeft,
                      child: LumenButton.ghost(
                        label: 'Mostrar banner',
                        onPressed: () => setState(() => _bannerVisible = true),
                      ),
                    ),
                  const LumenEmptyState(
                    icon: Icons.inbox_outlined,
                    title: 'Nenhum evento',
                    message:
                        'A lista abaixo só monta os itens que estão na tela.',
                  ),
                  SizedBox(
                    height: 220,
                    child: LumenList(
                      itemCount: 24,
                      separatorBuilder: (BuildContext context, int index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (BuildContext context, int i) =>
                          LumenListTile(
                            title: 'Evento ${i + 1}',
                            subtitle: 'item virtualizado',
                            onTap: () {},
                          ),
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
                  LumenButton.outline(
                    label: 'SNACKBAR',
                    icon: Icons.notifications_active_outlined,
                    onPressed: () => showLumenSnackBar(
                      context: context,
                      message: 'Snackbar com tom de alerta',
                      tone: LumenStatusTone.warning,
                      action: SnackBarAction(
                        label: 'desfazer',
                        onPressed: () {},
                      ),
                    ),
                  ),
                  LumenButton.outline(
                    label: 'TOAST',
                    icon: Icons.bolt_outlined,
                    onPressed: () => showLumenToast(
                      context: context,
                      message: 'Toast flutuante via Overlay',
                      tone: LumenStatusTone.info,
                    ),
                  ),
                  LumenButton.outline(
                    label: 'DIALOG',
                    icon: Icons.warning_amber_rounded,
                    onPressed: () => showLumenDialog<void>(
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
                        LumenButton(
                          label: 'CONFIRMAR',
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  LumenButton.outline(
                    label: 'BOTTOM SHEET',
                    icon: Icons.vertical_align_bottom_rounded,
                    onPressed: () => showLumenBottomSheet<void>(
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
                            LumenListTile(
                              leading: Icon(
                                Icons.share_outlined,
                                color: p.primary,
                              ),
                              title: 'Compartilhar',
                              subtitle: 'Gera um link de convite',
                              onTap: () => Navigator.pop(context),
                            ),
                            const SizedBox(height: 8),
                            LumenListTile(
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
                  LumenTabs(
                    selectedIndex: _tab,
                    onChanged: (int i) => setState(() => _tab = i),
                    items: const <LumenTabItem>[
                      LumenTabItem(label: 'Visão geral', icon: Icons.bar_chart),
                      LumenTabItem(label: 'Eventos', icon: Icons.bolt_outlined),
                      LumenTabItem(label: 'Alertas', icon: Icons.warning_amber),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LumenSegmentedControl(
                    selectedIndex: _segment,
                    onChanged: (int i) => setState(() => _segment = i),
                    items: const <LumenTabItem>[
                      LumenTabItem(label: 'Dia'),
                      LumenTabItem(label: 'Semana'),
                      LumenTabItem(label: 'Mês'),
                    ],
                  ),
                ],
              ),
            ),
            _section(
              'Stepper',
              LumenStepper(
                currentStep: _step,
                onStepTapped: (int i) => setState(() => _step = i),
                steps: const <LumenStep>[
                  LumenStep(title: 'Conta', subtitle: 'criar credenciais'),
                  LumenStep(title: 'Perfil', subtitle: 'dados pessoais'),
                  LumenStep(title: 'Pronto', subtitle: 'concluir'),
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
                  const LumenAvatar(initials: 'SG', radius: 26),
                  LumenAvatar(
                    initials: 'NU',
                    radius: 26,
                    statusColor: p.success,
                  ),
                  LumenBadge(
                    label: '12',
                    child: Icon(
                      Icons.notifications_outlined,
                      color: p.textPrimary,
                      size: 30,
                    ),
                  ),
                  LumenBadge.dot(
                    color: p.success,
                    child: Icon(
                      Icons.mail_outline,
                      color: p.textPrimary,
                      size: 30,
                    ),
                  ),
                  const LumenTag(label: 'novo', icon: Icons.fiber_new_outlined),
                  LumenTag(label: 'beta', color: p.secondary),
                  LumenAvatarGroup(
                    maxVisible: 3,
                    total: 12,
                    semanticLabel: '12 participantes',
                    onOverflowTap: () => showLumenToast(
                      context: context,
                      message: '+9 participantes',
                    ),
                    avatars: const <LumenAvatar>[
                      LumenAvatar(initials: 'SG'),
                      LumenAvatar(initials: 'NU'),
                      LumenAvatar(initials: 'AB'),
                      LumenAvatar(initials: 'CD'),
                    ],
                  ),
                ],
              ),
            ),
            _section(
              'Lista, divider & expansion',
              Column(
                children: <Widget>[
                  LumenListTile(
                    leading: Icon(Icons.dashboard_outlined, color: p.primary),
                    title: 'Dashboard',
                    subtitle: 'visão geral em tempo real',
                    trailing: const LumenTag(label: 'live'),
                    selected: true,
                    onTap: () {},
                  ),
                  const SizedBox(height: 8),
                  LumenListTile(
                    leading: Icon(Icons.settings_outlined, color: p.secondary),
                    title: 'Configurações',
                    subtitle: 'tokens, paleta e integrações',
                    onTap: () {},
                  ),
                  const LumenDivider(label: 'avançado'),
                  LumenExpansionTile(
                    title: 'Integrações',
                    subtitle: 'webhooks, SSO, API keys',
                    leading: Icon(Icons.hub_outlined, color: p.primary),
                    initiallyExpanded: _expanded,
                    onExpansionChanged: (bool v) =>
                        setState(() => _expanded = v),
                    children: <Widget>[
                      LumenListTile(
                        title: 'Webhook de eventos',
                        subtitle: 'POST → https://hooks.example.com',
                        trailing: const LumenTag(
                          label: 'ativo',
                          icon: Icons.check_circle_outline,
                        ),
                        onTap: () {},
                      ),
                      const SizedBox(height: 6),
                      LumenListTile(
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
              LumenDataTable(
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
                        LumenStatusChip(
                          label: 'OK',
                          tone: LumenStatusTone.success,
                        ),
                      ),
                      DataCell(Text('42ms')),
                    ],
                  ),
                  DataRow(
                    cells: <DataCell>[
                      DataCell(Text('worker')),
                      DataCell(
                        LumenStatusChip(
                          label: 'ALERTA',
                          tone: LumenStatusTone.warning,
                        ),
                      ),
                      DataCell(Text('118ms')),
                    ],
                  ),
                  DataRow(
                    cells: <DataCell>[
                      DataCell(Text('cache')),
                      DataCell(
                        LumenStatusChip(
                          label: 'FALHA',
                          tone: LumenStatusTone.danger,
                        ),
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
                  LumenNavigationCard(
                    title: 'Dashboard',
                    subtitle: 'visão geral em tempo real',
                    icon: Icons.dashboard_outlined,
                    accent: p.primary,
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  LumenNavigationCard(
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
    final LumenPalette p = LumenThemeExt.of(context).palette;
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
