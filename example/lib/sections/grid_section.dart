import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

/// Grid demonstration: adaptive columns with selectable vertical tiles.
class GridSection extends StatefulWidget {
  /// Creates the grid gallery content.
  const GridSection({super.key});

  @override
  State<GridSection> createState() => _GridSectionState();
}

class _GridSectionState extends State<GridSection> with AutomaticKeepAliveClientMixin<GridSection> {
  static const List<({IconData icon, String title, String subtitle})> _modules =
      <({IconData icon, String title, String subtitle})>[
        (icon: Icons.receipt_long_outlined, title: 'Orders', subtitle: '12 open'),
        (icon: Icons.inventory_2_outlined, title: 'Stock', subtitle: '3 low items'),
        (icon: Icons.people_outline, title: 'Customers', subtitle: '248 active'),
        (icon: Icons.bar_chart_outlined, title: 'Reports', subtitle: 'updated today'),
        (icon: Icons.local_shipping_outlined, title: 'Deliveries', subtitle: '5 on the way'),
        (icon: Icons.settings_outlined, title: 'Settings', subtitle: 'tokens and palette'),
      ];

  int _selected = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final p = LumenThemeExt.of(context).palette;
    final body = Theme.of(context).textTheme.bodyMedium?.copyWith(color: p.textSecondary);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: <Widget>[
        Text('Columns follow the width. Tap a tile to select it.', style: body),
        LumenGrid.extent(
          key: const ValueKey<String>('gallery-grid'),
          maxCrossAxisExtent: 160,
          mainAxisExtent: 124,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _modules.length,
          itemBuilder: (context, i) => LumenGridTile(
            title: _modules[i].title,
            subtitle: _modules[i].subtitle,
            leading: Icon(_modules[i].icon),
            selected: i == _selected,
            onTap: () => setState(() => _selected = i),
          ),
        ),
      ],
    );
  }
}
