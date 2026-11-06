import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

void main() {
  testWidgets('LumenBadge ancora no canto do child e o dot não tem texto', (tester) async {
    await pumpBare(
      tester,
      const Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 24,
        children: <Widget>[
          LumenBadge(label: '3', child: Icon(Icons.mail)),
          LumenBadge.dot(child: Icon(Icons.chat)),
        ],
      ),
    );

    expect(find.byIcon(Icons.mail), findsOneWidget);
    final pin = tester.widget<Positioned>(
      find.ancestor(of: find.text('3'), matching: find.byType(Positioned)),
    );
    expect((pin.top, pin.right), (-4, -4));

    final dot = find.byWidgetPredicate((w) => w is LumenBadge && w.dot);
    expect(find.descendant(of: dot, matching: find.byType(Text)), findsNothing);
    expect(find.descendant(of: dot, matching: find.byIcon(Icons.chat)), findsOneWidget);
  });

  testWidgets('LumenBadge escolhe texto claro ou escuro pela cor de fundo', (tester) async {
    await pumpBare(
      tester,
      const Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          LumenBadge(label: 'escuro', color: Color(0xFF1A237E)),
          LumenBadge(label: 'claro', color: Color(0xFFFFEB3B)),
        ],
      ),
    );
    expect(tester.widget<Text>(find.text('escuro')).style?.color, Colors.white);
    expect(tester.widget<Text>(find.text('claro')).style?.color, Colors.black);
  });
}
