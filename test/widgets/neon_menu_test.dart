import 'package:flutter/gestures.dart' show kSecondaryButton;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:neon_ui/components.dart';

import '_harness.dart';

const List<NeonMenuEntry<String>> _items = <NeonMenuEntry<String>>[
  NeonMenuItem<String>(value: 'edit', label: 'Editar', icon: Icons.edit),
  NeonMenuItem<String>(value: 'off', label: 'Arquivar', enabled: false),
  NeonMenuDivider<String>(),
  NeonMenuItem<String>(value: 'del', label: 'Excluir', destructive: true),
];

void main() {
  testWidgets('NeonMenuButton abre o menu e devolve a ação escolhida', (
    WidgetTester tester,
  ) async {
    String? picked;
    await pumpBare(
      tester,
      NeonMenuButton<String>(
        items: _items,
        onSelected: (String v) => picked = v,
      ),
    );

    await tester.tap(find.byType(NeonMenuButton<String>));
    await tester.pumpAndSettle();
    expect(find.text('Editar'), findsOneWidget);
    expect(find.byType(PopupMenuDivider), findsOneWidget);

    final Text del = tester.widget<Text>(find.text('Excluir'));
    expect(del.style?.color, NeonPalette.light().danger);

    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();
    expect(picked, 'del');
    expect(find.text('Editar'), findsNothing);
  });

  testWidgets('item desabilitado não dispara e fechar chama onCanceled', (
    WidgetTester tester,
  ) async {
    String? picked;
    int canceled = 0;
    await pumpBare(
      tester,
      NeonMenuButton<String>(
        items: _items,
        onSelected: (String v) => picked = v,
        onCanceled: () => canceled++,
      ),
    );

    await tester.tap(find.byType(NeonMenuButton<String>));
    await tester.pumpAndSettle();
    final Opacity dim = tester.widget(
      find.ancestor(of: find.text('Arquivar'), matching: find.byType(Opacity)),
    );
    expect(dim.opacity, kNeonDisabledOpacity);
    await tester.tap(find.text('Arquivar'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(picked, isNull);

    await tester.tapAt(const Offset(5, 5)); // fora do menu
    await tester.pumpAndSettle();
    expect(canceled, 1);
    expect(picked, isNull);
  });

  testWidgets('NeonMenuButton sem onSelected fica desabilitado', (
    WidgetTester tester,
  ) async {
    await pumpBare(
      tester,
      const NeonMenuButton<String>(items: _items, onSelected: null),
    );
    await tester.tap(find.byType(NeonMenuButton<String>));
    await tester.pumpAndSettle();
    expect(find.text('Editar'), findsNothing);
  });

  testWidgets('NeonContextMenu abre com toque longo e clique direito', (
    WidgetTester tester,
  ) async {
    final List<String> picked = <String>[];
    await pumpBare(
      tester,
      NeonContextMenu<String>(
        items: _items,
        onSelected: picked.add,
        child: const SizedBox(width: 200, height: 80, child: Text('alvo')),
      ),
    );

    await tester.longPress(find.text('alvo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('alvo'), buttons: kSecondaryButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();

    expect(picked, <String>['edit', 'del']);
  });
}
