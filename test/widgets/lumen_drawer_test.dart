import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

void main() {
  testWidgets('LumenDrawerItem toca, marca seleção e desabilita', (tester) async {
    var taps = 0;
    await pumpBare(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          LumenDrawerItem(icon: Icons.home, label: 'Início', selected: true, onTap: () => taps++),
          const LumenDrawerItem(icon: Icons.settings, label: 'Ajustes', onTap: null),
        ],
      ),
    );

    expect(tester.widget<LumenPressable>(find.byType(LumenPressable).first).selected, isTrue);
    await tester.tap(find.text('Início'));
    await tester.pump();
    expect(taps, 1);

    await tester.tap(find.text('Ajustes'));
    await tester.pump();
    expect(taps, 1);
    expect(tester.widget<LumenPressable>(find.byType(LumenPressable).last).onTap, isNull);
  });

  testWidgets('LumenDrawer abre no Scaffold com header, itens, footer e largura', (tester) async {
    final scaffold = GlobalKey<ScaffoldState>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          key: scaffold,
          drawer: LumenDrawer(
            width: 280,
            header: const Text('Cabeçalho'),
            footer: const Text('Rodapé'),
            children: <Widget>[LumenDrawerItem(icon: Icons.home, label: 'Início', onTap: () {})],
          ),
          body: const SizedBox(),
        ),
      ),
    );
    scaffold.currentState!.openDrawer();
    await tester.pumpAndSettle();

    expect(find.text('Cabeçalho'), findsOneWidget);
    expect(find.text('Início'), findsOneWidget);
    expect(find.text('Rodapé'), findsOneWidget);
    expect(tester.getSize(find.byType(Drawer)).width, 280);
    expect(tester.takeException(), isNull);
  });
}
