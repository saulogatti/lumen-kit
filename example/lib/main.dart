import 'package:flutter/widget_previews.dart';
import 'package:lumen_kit/components.dart';
import 'package:lumen_kit_example/material_gallery.dart';
import 'package:lumen_kit_example/sections/control_states_section.dart';
import 'package:lumen_kit_example/sections/foundation_section.dart';
import 'package:lumen_kit_example/sections/stepper_section.dart';
import 'package:material_ui/material_ui.dart';

void main() => runApp(const LumenExampleApp());

const LumenStyle _baseStyle = LumenStyle(
  shadow: LumenShadowKind.none,
  gradients: false,
  background: LumenBackgroundKind.plain,
  orbs: false,
);

const List<LumenMenuEntry<String>> _menuItems = <LumenMenuEntry<String>>[
  LumenMenuItem<String>(value: 'edit', label: 'Edit', icon: Icons.edit),
  LumenMenuItem<String>(
    value: 'duplicate',
    label: 'Duplicate',
    icon: Icons.copy_rounded,
  ),
  LumenMenuItem<String>(
    value: 'archive',
    label: 'Archive',
    icon: Icons.archive_outlined,
    enabled: false,
  ),
  LumenMenuDivider<String>(),
  LumenMenuItem<String>(
    value: 'delete',
    label: 'Delete',
    icon: Icons.delete_outline,
    destructive: true,
  ),
];

const List<LumenNavItem> _navItems = <LumenNavItem>[
  LumenNavItem(icon: Icons.dashboard_outlined, label: 'Home'),
  LumenNavItem(icon: Icons.bolt_outlined, label: 'Events', badge: '3'),
  LumenNavItem(icon: Icons.person_outline, label: 'Account'),
];

LumenPalette _materialPalette(ColorScheme scheme) {
  final isDark = scheme.brightness == Brightness.dark;
  return LumenPalette(
    backgroundDeep: scheme.surface,
    backgroundMid: scheme.surfaceContainerLow,
    backgroundSoft: scheme.surfaceContainer,
    surface: scheme.surfaceContainerHigh,
    surfaceOutline: scheme.outlineVariant,
    surfaceHighlight: scheme.onSurface.withValues(alpha: 0.08),
    primary: scheme.primary,
    secondary: scheme.secondary,
    tertiary: scheme.tertiary,
    textPrimary: scheme.onSurface,
    textSecondary: scheme.onSurfaceVariant,
    textMuted: scheme.onSurfaceVariant.withValues(alpha: 0.8),
    success: isDark ? Colors.green.shade300 : Colors.green.shade800,
    warning: isDark ? Colors.amber.shade300 : Colors.amber.shade900,
    danger: scheme.error,
  );
}

class LumenExampleApp extends StatefulWidget {
  /// The brightness used when the gallery opens.
  final Brightness initialBrightness;

  const LumenExampleApp({super.key, this.initialBrightness = Brightness.light});

  @override
  State<LumenExampleApp> createState() => _LumenExampleAppState();
}

class MyWidget extends StatelessWidget {
  @Preview(name: 'Constructor preview')
  const MyWidget.preview({super.key});

  @override
  Widget build(BuildContext context) =>
      const LumenExampleApp(initialBrightness: Brightness.dark);
}

class _GalleryScreen extends StatefulWidget {
  final Widget settings;

  const _GalleryScreen({required this.settings});

  @override
  State<_GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<_GalleryScreen> {
  double _progress = 0.35;
  bool _busy = false;
  String _slug = 'my-app';

  // Inputs
  bool _switchOn = true;
  bool? _checkbox = true;
  String _radio = 'a';
  double _slider = 0.4;
  String _dropdown = 'primary';
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
  bool _chipSelected = false;
  String _pin = '';

  // Navigation
  int _tab = 0;
  int _segment = 1;
  int _bottomNav = 0;

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
            label: 'Events',
            trailing: const LumenBadge(label: '3'),
            onTap: () => Navigator.pop(context),
          ),
          LumenDrawerItem(
            icon: Icons.settings_outlined,
            label: 'Settings',
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
      bottomNavigationBar: LumenBottomNavBar(
        selectedIndex: _bottomNav,
        onChanged: (int i) => setState(() => _bottomNav = i),
        items: _navItems,
      ),
      floatingActionButton: LumenFab.extended(
        icon: Icons.bolt_rounded,
        label: 'ACTION',
        onPressed: () => showLumenToast(
          context: context,
          message: 'FAB tapped!',
          tone: LumenStatusTone.success,
          position: LumenToastPosition.top,
        ),
      ),
      body: LumenAnimatedGridBackground(
        gradient: LumenStyle.of(context).fill(p.backgroundGradient),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          children: <Widget>[
            _section('Colors and style', widget.settings),
            _section('Foundation', const FoundationSection()),
            _section('Control states', const ControlStatesSection()),
            _section(
              'Cards & status',
              LumenCard(
                glow: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: const <Widget>[
                    Text('Telemetry service', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 8),
                    Text('Real-time event streaming, 124 active connections.'),
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
                          label: 'WARNING',
                          tone: LumenStatusTone.warning,
                        ),
                        LumenStatusChip(
                          label: 'FAILURE',
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
              'Buttons',
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  LumenButton(
                    label: 'RUN',
                    icon: Icons.play_arrow_rounded,
                    busy: _busy,
                    onPressed: () async {
                      setState(() => _busy = true);
                      await Future<void>.delayed(const Duration(seconds: 1));
                      if (!context.mounted) return;
                      setState(() => _busy = false);
                      showLumenSnackBar(
                        context: context,
                        message: 'Pipeline completed successfully',
                        tone: LumenStatusTone.success,
                      );
                    },
                  ),
                  LumenButton.outline(
                    label: 'EDIT',
                    icon: Icons.edit,
                    onPressed: () {},
                  ),
                  LumenButton.ghost(label: 'cancel', onPressed: () {}),
                  LumenButton.danger(
                    label: 'DELETE',
                    icon: Icons.delete_outline,
                    onPressed: () {},
                  ),
                  LumenButton.outline(
                    label: 'RETRY',
                    icon: Icons.refresh_rounded,
                    tone: LumenStatusTone.warning,
                    onPressed: () {},
                  ),
                  LumenCta(
                    label: 'Continue',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () => showLumenToast(
                      context: context,
                      message: 'Primary action selected',
                    ),
                  ),
                ],
              ),
            ),
            _section(
              'Icon buttons & FAB',
              Row(
                children: <Widget>[
                  LumenIconButton(
                    icon: Icons.favorite,
                    tooltip: 'Like',
                    onPressed: () {},
                  ),
                  const SizedBox(width: 12),
                  LumenIconButton.solid(
                    icon: Icons.refresh,
                    tooltip: 'Refresh',
                    onPressed: () {},
                  ),
                  const SizedBox(width: 12),
                  LumenIconButton.ghost(
                    icon: Icons.more_vert,
                    tooltip: 'More',
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
                    message: 'Square button with tooltip',
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
              'Inputs — text & search',
              Column(
                children: <Widget>[
                  LumenTextField(
                    label: 'Project slug',
                    initialValue: _slug,
                    icon: Icons.tag_rounded,
                    onChanged: (String v) => _slug = v,
                  ),
                  const SizedBox(height: 16),
                  LumenSearchBar(
                    hint: 'Search components…',
                    initialValue: _search,
                    onChanged: (String v) => setState(() => _search = v),
                  ),
                ],
              ),
            ),
            _section(
              'Inputs — selection',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  LumenSwitch(
                    value: _switchOn,
                    label: 'Real-time notifications',
                    onChanged: (bool v) => setState(() => _switchOn = v),
                  ),
                  const SizedBox(height: 12),
                  LumenCheckbox(
                    value: _checkbox,
                    tristate: true,
                    label: 'I accept the terms (tristate)',
                    onChanged: (bool? v) => setState(() => _checkbox = v),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    children: <Widget>[
                      LumenRadio<String>(
                        value: 'a',
                        groupValue: _radio,
                        label: 'Primary',
                        onChanged: (String? v) =>
                            setState(() => _radio = v ?? _radio),
                      ),
                      LumenRadio<String>(
                        value: 'b',
                        groupValue: _radio,
                        label: 'Secondary',
                        accentColor: p.secondary,
                        onChanged: (String? v) =>
                            setState(() => _radio = v ?? _radio),
                      ),
                      LumenRadio<String>(
                        value: 'c',
                        groupValue: _radio,
                        label: 'Tertiary',
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
                    'Price (R\$ ${_price.start.round()} – '
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
                    label: 'Accent color',
                    value: _dropdown,
                    items: const <LumenDropdownItem<String>>[
                      LumenDropdownItem<String>(
                        value: 'primary',
                        label: 'Primary',
                        icon: Icons.circle_outlined,
                      ),
                      LumenDropdownItem<String>(
                        value: 'secondary',
                        label: 'Secondary',
                        icon: Icons.circle_outlined,
                      ),
                      LumenDropdownItem<String>(
                        value: 'tertiary',
                        label: 'Tertiary',
                        icon: Icons.circle_outlined,
                      ),
                    ],
                    onChanged: (String? v) =>
                        setState(() => _dropdown = v ?? _dropdown),
                  ),
                  const SizedBox(height: 16),
                  LumenDatePicker(
                    label: 'Start date',
                    value: _date,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    onChanged: (DateTime v) => setState(() => _date = v),
                  ),
                  const SizedBox(height: 16),
                  LumenTimePicker(
                    label: 'Time',
                    value: _time,
                    onChanged: (TimeOfDay v) => setState(() => _time = v),
                  ),
                ],
              ),
            ),
            _section(
              'Code (PIN)',
              LumenPinField(
                value: _pin,
                onChanged: (String v) => setState(() => _pin = v),
                onCompleted: (String v) => showLumenToast(
                  context: context,
                  message: 'Code $v complete',
                  tone: LumenStatusTone.success,
                ),
              ),
            ),
            _section(
              'Chips, quantity & rating',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: <Widget>[
                  LumenChip(
                    label: 'Favorite',
                    selected: _chipSelected,
                    showCheckmark: true,
                    onSelected: (bool selected) =>
                        setState(() => _chipSelected = selected),
                  ),
                  LumenChoiceChips<String>(
                    value: _size,
                    onChanged: (String? v) => setState(() => _size = v),
                    items: const <LumenChipItem<String>>[
                      LumenChipItem<String>(value: 's', label: 'S'),
                      LumenChipItem<String>(value: 'm', label: 'M'),
                      LumenChipItem<String>(value: 'l', label: 'L'),
                      LumenChipItem<String>(
                        value: 'xl',
                        label: 'XL',
                        enabled: false,
                      ),
                    ],
                  ),
                  LumenFilterChips<String>(
                    values: _filters,
                    onChanged: (Set<String> v) => setState(() => _filters = v),
                    items: const <LumenChipItem<String>>[
                      LumenChipItem<String>(value: 'promo', label: 'Sale'),
                      LumenChipItem<String>(
                        value: 'frete',
                        label: 'Free shipping',
                        icon: Icons.local_shipping_outlined,
                      ),
                      LumenChipItem<String>(value: 'new', label: 'New arrival'),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      LumenQuantityStepper(
                        value: _qty,
                        min: 1,
                        max: 10,
                        semanticLabel: 'Quantity',
                        onChanged: (int v) => setState(() => _qty = v),
                      ),
                      const Spacer(),
                      LumenRating(
                        value: _rating,
                        allowHalf: true,
                        semanticLabel: 'Rating',
                        onChanged: (double v) => setState(() => _rating = v),
                      ),
                    ],
                  ),
                  Row(
                    spacing: 8,
                    children: <Widget>[
                      const LumenRating(value: 4.3, size: 16),
                      Text(
                        '4.3 (128 ratings)',
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
                            'Card with action menu',
                            style: TextStyle(color: p.textSecondary),
                          ),
                        ),
                        LumenMenuButton<String>(
                          items: _menuItems,
                          onSelected: (String v) => showLumenToast(
                            context: context,
                            message: 'Action: $v',
                          ),
                        ),
                      ],
                    ),
                  ),
                  LumenContextMenu<String>(
                    items: _menuItems,
                    onSelected: (String v) =>
                        showLumenToast(context: context, message: 'Action: $v'),
                    child: LumenLoadingOverlay(
                      loading: _overlay,
                      message: 'Syncing…',
                      borderRadius: LumenStyle.of(context).radius(20),
                      child: LumenCard(
                        child: SizedBox(
                          height: 120,
                          child: Center(
                            child: LumenSwitch(
                              value: _overlay,
                              label: 'Overlay for 3s (right-click: menu)',
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
                    label: 'SUBMIT (full screen)',
                    icon: Icons.send_rounded,
                    onPressed: () async {
                      await showLumenLoading<void>(
                        context: context,
                        message: 'Submitting form…',
                        task: () =>
                            Future<void>.delayed(const Duration(seconds: 2)),
                      );
                      if (!context.mounted) return;
                      showLumenSnackBar(
                        context: context,
                        message: 'Form submitted',
                        tone: LumenStatusTone.success,
                      );
                    },
                  ),
                ],
              ),
            ),
            _section(
              'Carousel',
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
              'Progress',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Determinate (${(_progress * 100).round()}%)'),
                  const SizedBox(height: 8),
                  LumenLinearProgress(value: _progress),
                  const SizedBox(height: 12),
                  LumenSlider(
                    value: _progress,
                    onChanged: (double v) => setState(() => _progress = v),
                  ),
                  const SizedBox(height: 12),
                  const Text('Indeterminate'),
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
              'Banner, empty state and list',
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: <Widget>[
                  if (_bannerVisible)
                    LumenBanner(
                      message: 'Sync paused on this device.',
                      tone: LumenStatusTone.warning,
                      actionLabel: 'Resume',
                      onAction: () => showLumenToast(
                        context: context,
                        message: 'Resuming',
                        tone: LumenStatusTone.info,
                      ),
                      onDismiss: () => setState(() => _bannerVisible = false),
                    )
                  else
                    Align(
                      alignment: Alignment.centerLeft,
                      child: LumenButton.ghost(
                        label: 'Show banner',
                        onPressed: () => setState(() => _bannerVisible = true),
                      ),
                    ),
                  const LumenEmptyState(
                    icon: Icons.inbox_outlined,
                    title: 'No events',
                    message:
                        'The list below only builds items that are on screen.',
                  ),
                  SizedBox(
                    height: 220,
                    child: LumenList(
                      itemCount: 24,
                      separatorBuilder: (BuildContext context, int index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (BuildContext context, int i) =>
                          LumenListTile(
                            title: 'Event ${i + 1}',
                            subtitle: 'virtualized item',
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
                      message: 'Warning snackbar',
                      tone: LumenStatusTone.warning,
                      action: SnackBarAction(label: 'undo', onPressed: () {}),
                    ),
                  ),
                  LumenButton.outline(
                    label: 'TOAST',
                    icon: Icons.bolt_outlined,
                    onPressed: () => showLumenToast(
                      context: context,
                      message: 'Floating toast via Overlay',
                      tone: LumenStatusTone.info,
                    ),
                  ),
                  LumenButton.outline(
                    label: 'DIALOG',
                    icon: Icons.warning_amber_rounded,
                    onPressed: () => showLumenDialog<void>(
                      context: context,
                      title: 'Confirm action',
                      icon: Icons.warning_amber_rounded,
                      content: const Text(
                        'This operation cannot be undone. Do you want to continue?',
                      ),
                      actions: <Widget>[
                        LumenButton.ghost(
                          label: 'Cancel',
                          onPressed: () => Navigator.pop(context),
                        ),
                        LumenButton(
                          label: 'CONFIRM',
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
                              'Quick actions',
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
                              title: 'Share',
                              subtitle: 'Creates an invitation link',
                              onTap: () => Navigator.pop(context),
                            ),
                            const SizedBox(height: 8),
                            LumenListTile(
                              leading: Icon(
                                Icons.delete_outline,
                                color: p.danger,
                              ),
                              title: 'Remove',
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
                      LumenTabItem(label: 'Overview', icon: Icons.bar_chart),
                      LumenTabItem(label: 'Events', icon: Icons.bolt_outlined),
                      LumenTabItem(label: 'Alerts', icon: Icons.warning_amber),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LumenSegmentedControl(
                    selectedIndex: _segment,
                    onChanged: (int i) => setState(() => _segment = i),
                    items: const <LumenTabItem>[
                      LumenTabItem(label: 'Day'),
                      LumenTabItem(label: 'Week'),
                      LumenTabItem(label: 'Month'),
                    ],
                  ),
                ],
              ),
            ),
            _section('Stepper', const StepperSection()),
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
                  const LumenTag(label: 'new', icon: Icons.fiber_new_outlined),
                  LumenTag(label: 'beta', color: p.secondary),
                  LumenAvatarGroup(
                    maxVisible: 3,
                    total: 12,
                    semanticLabel: '12 participants',
                    onOverflowTap: () => showLumenToast(
                      context: context,
                      message: '+9 participants',
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
              'List, divider & expansion',
              Column(
                children: <Widget>[
                  LumenListTile(
                    leading: Icon(Icons.dashboard_outlined, color: p.primary),
                    title: 'Dashboard',
                    subtitle: 'real-time overview',
                    trailing: const LumenTag(label: 'live'),
                    selected: true,
                    onTap: () {},
                  ),
                  const SizedBox(height: 8),
                  LumenListTile(
                    leading: Icon(Icons.settings_outlined, color: p.secondary),
                    title: 'Settings',
                    subtitle: 'tokens, palette and integrations',
                    onTap: () {},
                  ),
                  const LumenDivider(label: 'advanced'),
                  LumenExpansionTile(
                    title: 'Integrations',
                    subtitle: 'webhooks, SSO, API keys',
                    leading: Icon(Icons.hub_outlined, color: p.primary),
                    initiallyExpanded: _expanded,
                    onExpansionChanged: (bool v) =>
                        setState(() => _expanded = v),
                    children: <Widget>[
                      LumenListTile(
                        title: 'Event webhook',
                        subtitle: 'POST → https://hooks.example.com',
                        trailing: const LumenTag(
                          label: 'active',
                          icon: Icons.check_circle_outline,
                        ),
                        onTap: () {},
                      ),
                      const SizedBox(height: 6),
                      LumenListTile(
                        title: 'Primary API key',
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
                  DataColumn(label: Text('Service')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Latency'), numeric: true),
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
                          label: 'WARNING',
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
                          label: 'FAILURE',
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
              'Table rows',
              const Column(
                children: <Widget>[
                  LumenTableRow(
                    isHeader: true,
                    cells: <Widget>[Text('Service'), Text('State')],
                  ),
                  LumenTableRow(
                    cells: <Widget>[Text('API'), Text('Available')],
                  ),
                ],
              ),
            ),

            _section(
              'Navigation (cards and rail)',
              Column(
                children: <Widget>[
                  SizedBox(
                    height: 250,
                    child: LumenNavRail(
                      items: _navItems,
                      selectedIndex: _bottomNav,
                      onChanged: (int index) =>
                          setState(() => _bottomNav = index),
                    ),
                  ),
                  const SizedBox(height: 12),
                  LumenNavigationCard(
                    title: 'Dashboard',
                    subtitle: 'real-time overview',
                    icon: Icons.dashboard_outlined,
                    accent: p.primary,
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  LumenNavigationCard(
                    key: const ValueKey('gallery-end'),
                    title: 'Settings',
                    subtitle: 'tokens, palette and integrations',
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

class _LumenExampleAppState extends State<LumenExampleApp> {
  late Brightness _brightness = widget.initialBrightness;
  LumenPreset _preset = LumenPreset.neon;
  String _style = 'neon';
  bool _useLumenColors = true;
  bool _useLumenStyle = true;

  @override
  Widget build(BuildContext context) {
    final materialTheme = ThemeData(brightness: _brightness);
    final palette = _useLumenColors
        ? _preset.palette(brightness: _brightness)
        : _materialPalette(materialTheme.colorScheme);
    final style = _useLumenStyle ? LumenStyle.presets[_style]! : _baseStyle;

    return MaterialApp(
      title: 'lumen_kit example',
      debugShowCheckedModeBanner: false,
      theme: materialTheme.copyWith(
        extensions: <ThemeExtension<dynamic>>[
          LumenThemeExt(palette: palette, style: style),
        ],
      ),
      home: _GalleryScreen(
        settings: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: <Widget>[
            Builder(
              builder: (context) => LumenButton.outline(
                label: 'Default Material',
                icon: Icons.compare_arrows_rounded,
                onPressed: () => showMaterialGallery(context),
              ),
            ),
            LumenSwitch(
              label: 'Lumen colors',
              value: _useLumenColors,
              onChanged: (bool value) =>
                  setState(() => _useLumenColors = value),
            ),
            if (_useLumenColors)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  for (final LumenPreset preset in LumenPreset.values)
                    LumenTag(
                      label: preset.name,
                      color: preset.primary,
                      icon: _preset == preset ? Icons.check_rounded : null,
                      onTap: () => setState(() => _preset = preset),
                    ),
                ],
              ),
            LumenSwitch(
              label: 'Component style',
              value: _useLumenStyle,
              onChanged: (bool value) => setState(() => _useLumenStyle = value),
            ),
            if (_useLumenStyle)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  for (final String name in LumenStyle.presets.keys)
                    LumenTag(
                      label: name,
                      icon: _style == name
                          ? Icons.check_rounded
                          : Icons.auto_awesome_outlined,
                      onTap: () => setState(() => _style = name),
                    ),
                ],
              ),
            LumenSwitch(
              label: 'Dark mode',
              value: _brightness == Brightness.dark,
              onChanged: (bool dark) => setState(
                () => _brightness = dark ? Brightness.dark : Brightness.light,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
