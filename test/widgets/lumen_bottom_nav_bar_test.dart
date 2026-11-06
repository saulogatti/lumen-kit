import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

const List<LumenNavItem> _items = <LumenNavItem>[
  LumenNavItem(icon: Icons.home, label: 'Início'),
  LumenNavItem(icon: Icons.search, label: 'Busca', badge: '2'),
  LumenNavItem(icon: Icons.person, label: 'Conta'),
];

void main() {
  testWidgets('LumenBottomNavBar troca o índice e mostra o badge', (tester) async {
    var index = 0;
    await tester.pumpWidget(
      bareApp(
        StatefulBuilder(
          builder: (context, setState) => LumenBottomNavBar(
            items: _items,
            selectedIndex: index,
            onChanged: (next) => setState(() => index = next),
          ),
        ),
      ),
    );

    expect(find.text('2'), findsOneWidget);
    await tester.tap(find.text('Conta'));
    await tester.pump();
    expect(index, 2);
  });

  testWidgets('LumenNavRail troca o índice pelo toque e marca o selecionado', (tester) async {
    var index = 0;
    await tester.pumpWidget(
      bareApp(
        SizedBox(
          height: 400,
          child: StatefulBuilder(
            builder: (context, setState) => LumenNavRail(
              items: _items,
              selectedIndex: index,
              onChanged: (next) => setState(() => index = next),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Busca'));
    await tester.pump();
    expect(index, 1);
    final selected = tester.widget<LumenPressable>(
      find.ancestor(of: find.text('Busca'), matching: find.byType(LumenPressable)),
    );
    expect(selected.selected, isTrue);
  });
}
