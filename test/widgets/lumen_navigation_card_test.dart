import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

Widget _card({String? tag, VoidCallback? onTap}) => LumenNavigationCard(
  title: 'Pedidos',
  subtitle: 'fila do dia',
  icon: Icons.inbox,
  accent: const Color(0xFF00E5FF),
  tag: tag,
  onTap: onTap ?? () {},
);

/// Deslocamento vertical do card (negativo = levantado).
double _lift(WidgetTester tester) => tester
    .widget<AnimatedContainer>(
      find
          .descendant(
            of: find.byType(LumenNavigationCard),
            matching: find.byType(AnimatedContainer),
          )
          .first,
    )
    .transform!
    .getTranslation()
    .y;

void main() {
  testWidgets('LumenNavigationCard mostra a tag e dispara o toque', (tester) async {
    var taps = 0;
    await pumpBare(tester, _card(tag: '3', onTap: () => taps++));

    expect(find.text('Pedidos'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    await tester.tap(find.text('Pedidos'));
    await tester.pump();
    expect(taps, 1);
  });

  testWidgets('LumenNavigationCard sobe com hover do mouse e volta ao sair', (tester) async {
    await pumpBare(tester, _card());

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    expect(_lift(tester), 0);

    await mouse.moveTo(tester.getCenter(find.byType(LumenNavigationCard)));
    await tester.pumpAndSettle();
    expect(_lift(tester), -4);

    await mouse.moveTo(Offset.zero);
    await tester.pumpAndSettle();
    expect(_lift(tester), 0);
  });

  testWidgets('LumenNavigationCard sobe também com foco de teclado', (tester) async {
    await pumpBare(tester, _card());
    expect(_lift(tester), 0);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(_lift(tester), -4);
  });
}
