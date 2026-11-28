import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

/// Sliver demonstration: an app bar that collapses over a grid and a list
/// sharing one scroll view.
class SliversSection extends StatelessWidget {
  /// Creates the slivers gallery content.
  const SliversSection({super.key});

  static const List<({IconData icon, String title})> _shortcuts = <({IconData icon, String title})>[
    (icon: Icons.receipt_long_outlined, title: 'Orders'),
    (icon: Icons.inventory_2_outlined, title: 'Stock'),
    (icon: Icons.people_outline, title: 'Customers'),
  ];

  @override
  Widget build(BuildContext context) {
    final p = LumenThemeExt.of(context).palette;
    final style = LumenStyle.of(context);
    final body = Theme.of(context).textTheme.bodyMedium?.copyWith(color: p.textSecondary);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: <Widget>[
        Text('Scroll inside the frame: the large title collapses into the bar.', style: body),
        Container(
          height: 380,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: style.radius(16),
            border: style.borderAll(color: p.surfaceOutline.outlineAlpha(0.45)),
          ),
          child: CustomScrollView(
            key: const ValueKey<String>('gallery-slivers'),
            slivers: <Widget>[
              LumenSliverAppBar(
                title: 'Store',
                subtitle: 'collapsing sliver app bar',
                expandedHeight: 148,
                // The frame sits in the middle of the page, not under the
                // status bar.
                primary: false,
                actions: <Widget>[
                  LumenIconButton(icon: Icons.search, tooltip: 'Search', onPressed: () {}),
                ],
              ),
              LumenSliverGrid(
                crossAxisCount: 3,
                mainAxisExtent: 96,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                itemCount: _shortcuts.length,
                itemBuilder: (context, i) => LumenGridTile(
                  title: _shortcuts[i].title,
                  leading: Icon(_shortcuts[i].icon),
                  onTap: () {},
                ),
              ),
              LumenSliverList(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                itemCount: 12,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, i) => LumenListTile(
                  title: 'Order ${1040 + i}',
                  subtitle: 'sliver list item',
                  onTap: () {},
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
