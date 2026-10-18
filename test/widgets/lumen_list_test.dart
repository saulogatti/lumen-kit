import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

void main() {
  testWidgets('LumenList constrói só o visível e toca o item', (tester) async {
    int? tapped;
    await pumpBare(
      tester,
      SizedBox(
        height: 180,
        width: 320,
        child: LumenList(
          itemCount: 80,
          itemBuilder: (context, i) => LumenListTile(title: 'item $i', onTap: () => tapped = i),
        ),
      ),
    );
    expect(find.text('item 0'), findsOneWidget);
    expect(find.text('item 79'), findsNothing);
    await tester.tap(find.text('item 0'));
    await tester.pump();
    expect(tapped, 0);
  });

  testWidgets('LumenList vazia mostra empty', (tester) async {
    await pumpBare(
      tester,
      LumenList(
        itemCount: 0,
        empty: const Text('nenhum evento'),
        itemBuilder: (context, i) => Text('item $i'),
      ),
    );
    expect(find.text('nenhum evento'), findsOneWidget);
    expect(find.text('item 0'), findsNothing);
  });
}
