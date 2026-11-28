import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

/// Panel demonstration: toggle each decorative effect on a live panel.
class PanelSection extends StatefulWidget {
  /// Creates the panel gallery content.
  const PanelSection({super.key});

  @override
  State<PanelSection> createState() => _PanelSectionState();
}

class _PanelSectionState extends State<PanelSection>
    with AutomaticKeepAliveClientMixin<PanelSection> {
  final Set<LumenPanelEffect> _effects = <LumenPanelEffect>{.grid, .orb, .gradientBorder};

  @override
  bool get wantKeepAlive => true;

  void _toggle(LumenPanelEffect effect) => setState(() {
    if (!_effects.remove(effect)) {
      _effects.add(effect);
    }
  });

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final p = LumenThemeExt.of(context).palette;
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: <Widget>[
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (final LumenPanelEffect effect in LumenPanelEffect.values)
              LumenTag(
                label: effect.name,
                icon: _effects.contains(effect) ? Icons.check_rounded : Icons.add_rounded,
                onTap: () => _toggle(effect),
              ),
          ],
        ),
        LumenPanel(
          key: const ValueKey<String>('gallery-panel'),
          // A new set per build, so the panel sees each toggle as a change.
          effects: <LumenPanelEffect>{..._effects},
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: <Widget>[
              Text('Sales today', style: text.titleMedium?.copyWith(color: p.textPrimary)),
              Text(
                'The effects sit behind the content and follow the palette and style.',
                style: text.bodyMedium?.copyWith(color: p.textSecondary),
              ),
              const SizedBox(height: 4),
              const LumenLinearProgress(value: 0.64),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: LumenButton.outline(label: 'OPEN REPORT', onPressed: () {}),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
