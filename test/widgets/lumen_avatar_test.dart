import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

void main() {
  testWidgets('LumenAvatar mostra iniciais em caixa alta e "?" sem nada', (tester) async {
    await pumpBare(
      tester,
      const Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          LumenAvatar(initials: 'sg'),
          LumenAvatar(),
        ],
      ),
    );
    expect(find.text('SG'), findsOneWidget);
    expect(find.text('?'), findsOneWidget);
  });

  testWidgets('LumenAvatar com statusColor desenha o ponto sem mudar o tamanho', (tester) async {
    const online = Color(0xFF00C853);
    await pumpBare(tester, const LumenAvatar(initials: 'ab', radius: 20, statusColor: online));

    expect(tester.getSize(find.byType(LumenAvatar)), const Size(40, 40));
    final dot = find.descendant(
      of: find.byType(Positioned),
      matching: find.byWidgetPredicate(
        (w) => w is Container && (w.decoration as BoxDecoration?)?.color == online,
      ),
    );
    expect(dot, findsOneWidget);
  });
}
