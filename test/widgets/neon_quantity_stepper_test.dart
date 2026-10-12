import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:neon_ui/components.dart';

import '_harness.dart';

void main() {
  testWidgets('NeonQuantityStepper soma, subtrai e respeita min/max', (
    WidgetTester tester,
  ) async {
    int qtd = 1;
    await tester.pumpWidget(
      bareApp(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) =>
              NeonQuantityStepper(
                value: qtd,
                min: 1,
                max: 3,
                onChanged: (int v) => setState(() => qtd = v),
              ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.remove_rounded));
    await tester.pumpAndSettle();
    expect(qtd, 1, reason: '− desabilitado no mínimo');

    for (int i = 0; i < 3; i++) {
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();
    }
    expect(qtd, 3);
    expect(find.text('3'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.remove_rounded));
    await tester.pumpAndSettle();
    expect(qtd, 2);
  });

  testWidgets('step não estoura o máximo e format muda o texto', (
    WidgetTester tester,
  ) async {
    final List<int> calls = <int>[];
    await pumpBare(
      tester,
      NeonQuantityStepper(
        value: 8,
        max: 10,
        step: 5,
        format: (int v) => '$v un.',
        onChanged: calls.add,
      ),
    );
    expect(find.text('8 un.'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add_rounded));
    expect(calls, <int>[10]);
  });

  testWidgets('leitor de tela ajusta pelo increase/decrease', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    final List<int> calls = <int>[];
    await pumpBare(
      tester,
      NeonQuantityStepper(
        value: 2,
        semanticLabel: 'Quantidade',
        onChanged: calls.add,
      ),
    );

    expect(
      tester.getSemantics(find.byType(NeonQuantityStepper)),
      isSemantics(
        label: 'Quantidade',
        value: '2',
        increasedValue: '3',
        decreasedValue: '1',
        isEnabled: true,
        hasIncreaseAction: true,
        hasDecreaseAction: true,
      ),
    );
    final Semantics adjustable = tester.widget<Semantics>(
      find
          .descendant(
            of: find.byType(NeonQuantityStepper),
            matching: find.byType(Semantics),
          )
          .first,
    );
    adjustable.properties.onIncrease!();
    expect(calls, <int>[3]);
    handle.dispose();
  });

  testWidgets('sem onChanged os dois botões ficam desabilitados', (
    WidgetTester tester,
  ) async {
    await pumpBare(
      tester,
      const NeonQuantityStepper(value: 5, onChanged: null),
    );
    final Iterable<NeonIconButton> buttons = tester.widgetList(
      find.byType(NeonIconButton),
    );
    expect(buttons.every((NeonIconButton b) => b.onPressed == null), isTrue);
  });
}
