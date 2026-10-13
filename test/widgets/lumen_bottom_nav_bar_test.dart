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
  testWidgets('LumenBottomNavBar troca o índice e mostra o badge', (
    WidgetTester tester,
  ) async {
    var index = 0;
    await tester.pumpWidget(
      bareApp(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) =>
              LumenBottomNavBar(
                items: _items,
                selectedIndex: index,
                onChanged: (int next) => setState(() => index = next),
              ),
        ),
      ),
    );

    expect(find.text('2'), findsOneWidget);
    await tester.tap(find.text('Conta'));
    await tester.pump();
    expect(index, 2);
  });
}
