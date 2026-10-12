import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:neon_ui/components.dart';

import '_harness.dart';

const List<NeonAvatar> _five = <NeonAvatar>[
  NeonAvatar(initials: 'AA'),
  NeonAvatar(initials: 'BB'),
  NeonAvatar(initials: 'CC'),
  NeonAvatar(initials: 'DD'),
  NeonAvatar(initials: 'EE'),
];

void main() {
  testWidgets('NeonAvatarGroup mostra maxVisible e o excedente', (
    WidgetTester tester,
  ) async {
    await pumpBare(
      tester,
      const NeonAvatarGroup(avatars: _five, maxVisible: 3, radius: 20),
    );
    expect(find.byType(NeonAvatar), findsNWidgets(3));
    expect(find.text('+2'), findsOneWidget);
    expect(find.text('DD'), findsNothing);

    // Todos com o raio do grupo, sobrepostos.
    for (final NeonAvatar a in tester.widgetList<NeonAvatar>(
      find.byType(NeonAvatar),
    )) {
      expect(a.radius, 20);
    }
    final double x0 = tester.getTopLeft(find.byType(NeonAvatar).at(0)).dx;
    final double x1 = tester.getTopLeft(find.byType(NeonAvatar).at(1)).dx;
    expect(x1 - x0, lessThan(44), reason: 'diâmetro + anel, com overlap');
  });

  testWidgets('total conta pessoas fora da amostra e +N é tocável', (
    WidgetTester tester,
  ) async {
    var taps = 0;
    await pumpBare(
      tester,
      NeonAvatarGroup(
        avatars: _five.take(2).toList(),
        total: 128,
        onOverflowTap: () => taps++,
      ),
    );
    expect(find.byType(NeonAvatar), findsNWidgets(2));
    await tester.tap(find.text('+126'));
    expect(taps, 1);
  });

  testWidgets('sem excedente não há chip e lista vazia não quebra', (
    WidgetTester tester,
  ) async {
    await pumpBare(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          NeonAvatarGroup(avatars: _five.take(3).toList()),
          const NeonAvatarGroup(avatars: <NeonAvatar>[]),
        ],
      ),
    );
    expect(find.byType(NeonAvatar), findsNWidgets(3));
    expect(find.textContaining('+'), findsNothing);
  });

  testWidgets('grupo anuncia só o rótulo, sem ler as iniciais', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpBare(
      tester,
      const NeonAvatarGroup(
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
