import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

double _opacity(WidgetTester tester, String title) => tester
    .widget<Opacity>(
      find
          .descendant(of: find.widgetWithText(LumenListTile, title), matching: find.byType(Opacity))
          .first,
    )
    .opacity;

void main() {
  testWidgets('LumenListTile sem ação apaga a 0.7, menos que controle desabilitado', (
    tester,
  ) async {
    await pumpBare(
      tester,
      SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const LumenListTile(title: 'Info', subtitle: 'só leitura'),
            const LumenListTile(title: 'Atual', selected: true),
            LumenListTile(title: 'Ação', onTap: () {}),
          ],
        ),
      ),
    );

    expect(find.text('só leitura'), findsOneWidget);
    expect(_opacity(tester, 'Info'), 0.7);
    expect(_opacity(tester, 'Atual'), 1);
    expect(_opacity(tester, 'Ação'), 1);
  });
}
