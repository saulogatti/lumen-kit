import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

const List<LumenAvatar> _five = <LumenAvatar>[
  LumenAvatar(initials: 'AA'),
  LumenAvatar(initials: 'BB'),
  LumenAvatar(initials: 'CC'),
  LumenAvatar(initials: 'DD'),
  LumenAvatar(initials: 'EE'),
];

void main() {
  testWidgets('LumenAvatarGroup mostra maxVisible e o excedente', (
    tester,
  ) async {
    await pumpBare(
      tester,
      const LumenAvatarGroup(avatars: _five, maxVisible: 3, radius: 20),
    );
    expect(find.byType(LumenAvatar), findsNWidgets(3));
    expect(find.text('+2'), findsOneWidget);
    expect(find.text('DD'), findsNothing);

    // Todos com o raio do grupo, sobrepostos.
    for (final a in tester.widgetList<LumenAvatar>(
      find.byType(LumenAvatar),
    )) {
      expect(a.radius, 20);
    }
    final x0 = tester.getTopLeft(find.byType(LumenAvatar).at(0)).dx;
    final x1 = tester.getTopLeft(find.byType(LumenAvatar).at(1)).dx;
    expect(x1 - x0, lessThan(44), reason: 'diâmetro + anel, com overlap');
  });

  testWidgets('total conta pessoas fora da amostra e +N é tocável', (
    tester,
  ) async {
    var taps = 0;
    await pumpBare(
      tester,
      LumenAvatarGroup(
        avatars: _five.take(2).toList(),
        total: 128,
        onOverflowTap: () => taps++,
      ),
    );
    expect(find.byType(LumenAvatar), findsNWidgets(2));
    await tester.tap(find.text('+126'));
    expect(taps, 1);
  });

  testWidgets('sem excedente não há chip e lista vazia não quebra', (
    tester,
  ) async {
    await pumpBare(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          LumenAvatarGroup(avatars: _five.take(3).toList()),
          const LumenAvatarGroup(avatars: <LumenAvatar>[]),
        ],
      ),
    );
    expect(find.byType(LumenAvatar), findsNWidgets(3));
    expect(find.textContaining('+'), findsNothing);
  });

  testWidgets('grupo anuncia só o rótulo, sem ler as iniciais', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpBare(
      tester,
      const LumenAvatarGroup(
        avatars: _five,
        maxVisible: 2,
        semanticLabel: '5 participantes',
      ),
    );
    expect(find.bySemanticsLabel('5 participantes'), findsOneWidget);
    expect(find.bySemanticsLabel('AA'), findsNothing);
    handle.dispose();
  });
}
