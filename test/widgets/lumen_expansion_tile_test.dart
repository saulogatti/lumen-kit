import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

void main() {
  testWidgets('LumenExpansionTile abre, fecha e avisa cada troca', (tester) async {
    final changes = <bool>[];
    await pumpBare(
      tester,
      SizedBox(
        width: 320,
        child: LumenExpansionTile(
          title: 'Detalhes',
          subtitle: 'mais informações',
          onExpansionChanged: changes.add,
          children: const <Widget>[Text('corpo')],
        ),
      ),
    );
    expect(find.text('mais informações'), findsOneWidget);

    await tester.tap(find.text('Detalhes'));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.text('corpo')).height, greaterThan(0));

    await tester.tap(find.text('Detalhes'));
    await tester.pumpAndSettle();
    expect(changes, <bool>[true, false]);
    expect(find.text('corpo').hitTestable(), findsNothing);
  });
}
