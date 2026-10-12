import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:neon_ui/components.dart';

import '_harness.dart';

void main() {
  testWidgets('NeonRating escolhe a nota pela estrela tocada', (
    WidgetTester tester,
  ) async {
    double nota = 0;
    await tester.pumpWidget(
      bareApp(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) => NeonRating(
            value: nota,
            onChanged: (double v) => setState(() => nota = v),
          ),
        ),
      ),
    );
    expect(find.byIcon(Icons.star_outline_rounded), findsNWidgets(5));
    expect(find.byIcon(Icons.star_rounded), findsNothing);

    await tester.tap(find.byIcon(Icons.star_outline_rounded).at(3));
    await tester.pump();
    expect(nota, 4);
    expect(find.byIcon(Icons.star_rounded), findsNWidgets(4));
  });

  testWidgets('allowHalf: metade esquerda dá meia estrela', (
    WidgetTester tester,
  ) async {
    final calls = <double>[];
    await pumpBare(
      tester,
      NeonRating(value: 0, allowHalf: true, size: 40, onChanged: calls.add),
    );
    final Rect second = tester.getRect(
      find.byIcon(Icons.star_outline_rounded).at(1),
    );
    await tester.tapAt(second.centerLeft + const Offset(4, 0));
    await tester.tapAt(second.centerRight - const Offset(4, 0));
    expect(calls, <double>[1.5, 2]);
  });

  testWidgets('somente leitura mostra fração e anuncia a nota', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpBare(
      tester,
      const NeonRating(value: 3.5, semanticLabel: 'Avaliação'),
    );
    final Align half = tester.widget<Align>(
      find.ancestor(
        of: find.byIcon(Icons.star_rounded).at(3),
        matching: find.byType(Align),
      ),
    );
    expect(half.widthFactor, 0.5);
    expect(find.byType(NeonPressable), findsNothing);
    expect(
      tester.getSemantics(find.byType(NeonRating)),
      isSemantics(label: 'Avaliação', value: '3.5/5'),
    );
    handle.dispose();
  });

  testWidgets('leitor de tela sobe e desce a nota', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpBare(tester, NeonRating(value: 5, onChanged: (_) {}));
    expect(
      tester.getSemantics(find.byType(NeonRating)),
      isSemantics(
        value: '5/5',
        decreasedValue: '4/5',
        hasDecreaseAction: true,
        hasIncreaseAction: false,
      ),
    );
    handle.dispose();
  });
}
