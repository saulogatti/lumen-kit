import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

/// Demonstrates the building blocks used to compose Lumen controls.
class FoundationSection extends StatefulWidget {
  /// Creates the foundation examples with independent local state.
  const FoundationSection({super.key});

  @override
  State<FoundationSection> createState() => _FoundationSectionState();
}

class _FoundationSectionState extends State<FoundationSection>
    with AutomaticKeepAliveClientMixin<FoundationSection> {
  bool _selected = false;
  bool _focused = false;
  bool _notifications = true;
  int _actions = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final LumenPalette p = LumenThemeExt.of(context).palette;
    final LumenStyle s = LumenStyle.of(context);
    final textTheme = Theme.of(context).textTheme;

    Widget heading(String text) =>
        Text(text, style: textTheme.titleSmall?.copyWith(color: p.textPrimary));

    Widget pressableContent(String label) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: LumenDecorations.selectable(
        p,
        s,
        accent: p.primary,
        selected: _selected,
      ),
      child: Text(
        label,
        style: textTheme.labelLarge?.copyWith(color: p.textPrimary),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: <Widget>[
        heading('LumenPressable'),
        Text(
          'Use Tab to focus the control, then Enter or Space to select it.',
          style: textTheme.bodyMedium?.copyWith(color: p.textSecondary),
        ),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: <Widget>[
            Focus(
              canRequestFocus: false,
              onFocusChange: (focused) => setState(() => _focused = focused),
              child: LumenPressable(
                key: const ValueKey('foundation-select'),
                selected: _selected,
                borderRadius: s.radius(12),
                onTap: () => setState(() => _selected = !_selected),
                child: pressableContent('Select item'),
              ),
            ),
            LumenPressable(
              key: const ValueKey('foundation-disabled'),
              enabled: false,
              borderRadius: s.radius(12),
              onTap: () => setState(() => _selected = !_selected),
              child: pressableContent('Disabled item'),
            ),
          ],
        ),
        Text(
          '${_selected ? 'Selected' : 'Not selected'} · '
          '${_focused ? 'Keyboard focus active' : 'No keyboard focus'}',
          style: textTheme.bodySmall?.copyWith(color: p.textSecondary),
        ),
        heading('LumenActionContent'),
        Wrap(
          spacing: 20,
          runSpacing: 12,
          children: <Widget>[
            LumenActionContent(color: p.textPrimary, label: 'Text only'),
            LumenActionContent(
              color: p.primary,
              icon: Icons.save_outlined,
              label: 'Icon and text',
            ),
            LumenActionContent(
              color: p.secondary,
              label: 'Working',
              busy: true,
            ),
          ],
        ),
        heading('LumenLabeled'),
        LumenPressable(
          key: const ValueKey('foundation-notifications'),
          checked: _notifications,
          borderRadius: s.radius(12),
          onTap: () => setState(() => _notifications = !_notifications),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: LumenLabeled(
              label: 'Email notifications',
              control: Icon(
                _notifications
                    ? Icons.check_box_outlined
                    : Icons.check_box_outline_blank,
                color: p.primary,
              ),
            ),
          ),
        ),
        LumenPressable(
          checked: false,
          enabled: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: LumenLabeled(
              label: 'Unavailable preference',
              enabled: false,
              control: Icon(Icons.check_box_outline_blank, color: p.textMuted),
            ),
          ),
        ),
        LumenLabeled(
          label:
              'A longer label wraps within the available width while keeping '
              'the control visible.',
          control: Icon(Icons.info_outline, color: p.primary),
        ),
        heading('Custom composition'),
        Text(
          'LumenPressable + LumenDecorations + LumenActionContent',
          style: textTheme.bodySmall?.copyWith(color: p.textSecondary),
        ),
        s.frost(
          borderRadius: s.radius(14),
          child: LumenPressable(
            key: const ValueKey('foundation-custom-action'),
            borderRadius: s.radius(14),
            onTap: () => setState(() => _actions++),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: LumenDecorations.panel(p, s, accent: p.secondary),
              child: LumenActionContent(
                color: p.secondary,
                icon: Icons.bolt_outlined,
                label: 'Custom action',
                expand: true,
              ),
            ),
          ),
        ),
        Text(
          'Custom actions: $_actions',
          style: textTheme.bodySmall?.copyWith(color: p.textSecondary),
        ),
      ],
    );
  }
}
