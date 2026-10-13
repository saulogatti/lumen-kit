import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

void main() {
  testWidgets('LumenNavigationCard mostra a tag e dispara o toque', (
    WidgetTester tester,
  ) async {
    var taps = 0;
    await pumpBare(
      tester,
      LumenNavigationCard(
        title: 'Pedidos',
        subtitle: 'fila do dia',
        icon: Icons.inbox,
        accent: const Color(0xFF00E5FF),
        tag: '3',
        onTap: () => taps++,
      ),
    );

    expect(find.text('Pedidos'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    await tester.tap(find.text('Pedidos'));
    await tester.pump();
    expect(taps, 1);
  });
}
