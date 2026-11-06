import 'package:flutter/gestures.dart' show kSecondaryButton;
import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

void main() {
  testWidgets('LumenMenuButton abre o menu e devolve a ação escolhida', (tester) async {
    String? picked;
    await pumpBare(tester, LumenMenuButton<String>(items: _items, onSelected: (v) => picked = v));

    await tester.tap(find.byType(LumenMenuButton<String>));
    await tester.pumpAndSettle();
    expect(find.text('Editar'), findsOneWidget);
    expect(find.byType(PopupMenuDivider), findsOneWidget);

    final del = tester.widget<Text>(find.text('Excluir'));
    expect(del.style?.color, LumenPalette.light().danger);

    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();
    expect(picked, 'del');
    expect(find.text('Editar'), findsNothing);
  });

  testWidgets('item desabilitado não dispara e fechar chama onCanceled', (tester) async {
    String? picked;
    var canceled = 0;
    await pumpBare(
      tester,
      LumenMenuButton<String>(
        items: _items,
        onSelected: (v) => picked = v,
        onCanceled: () => canceled++,
      ),
    );

    await tester.tap(find.byType(LumenMenuButton<String>));
    await tester.pumpAndSettle();
    final dim = tester.widget<Opacity>(
      find.ancestor(of: find.text('Arquivar'), matching: find.byType(Opacity)),
    );
    expect(dim.opacity, kLumenDisabledOpacity);
    await tester.tap(find.text('Arquivar'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(picked, isNull);

    await tester.tapAt(const Offset(5, 5)); // fora do menu
    await tester.pumpAndSettle();
    expect(canceled, 1);
    expect(picked, isNull);
  });

  testWidgets('LumenMenuButton sem onSelected fica desabilitado', (tester) async {
    await pumpBare(tester, const LumenMenuButton<String>(items: _items, onSelected: null));
    await tester.tap(find.byType(LumenMenuButton<String>));
    await tester.pumpAndSettle();
    expect(find.text('Editar'), findsNothing);
  });

  testWidgets('LumenContextMenu abre com toque longo e clique direito', (tester) async {
    final picked = <String>[];
    await pumpBare(
      tester,
      LumenContextMenu<String>(
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

  testWidgets('initialValue marca a ação atual com check', (tester) async {
    await pumpBare(
      tester,
      LumenMenuButton<String>(items: _items, initialValue: 'edit', onSelected: (_) {}),
    );
    await tester.tap(find.byType(LumenMenuButton<String>));
    await tester.pumpAndSettle();

    final check = find.descendant(
      of: find.widgetWithText(PopupMenuItem<String>, 'Editar'),
      matching: find.byIcon(Icons.check_rounded),
    );
    expect(check, findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
  });

  testWidgets('LumenContextMenu sem onSelected é só o child', (tester) async {
    await pumpBare(
      tester,
      const LumenContextMenu<String>(
        items: _items,
        onSelected: null,
        child: SizedBox(width: 200, height: 80, child: Text('alvo')),
      ),
    );
    expect(
      find.ancestor(of: find.text('alvo'), matching: find.byType(GestureDetector)),
      findsNothing,
    );
    await tester.longPress(find.text('alvo'));
    await tester.pumpAndSettle();
    expect(find.text('Editar'), findsNothing);
  });

  testWidgets('LumenContextMenu abre pela ação de toque longo do leitor de tela', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpBare(
      tester,
      LumenContextMenu<String>(
        items: _items,
        onSelected: (_) {},
        child: const SizedBox(width: 200, height: 80, child: Text('alvo')),
      ),
    );
    tester.semantics.longPress(find.semantics.byLabel('alvo'));
    await tester.pumpAndSettle();
    expect(find.text('Editar'), findsOneWidget);
    handle.dispose();
  });
}

const List<LumenMenuEntry<String>> _items = <LumenMenuEntry<String>>[
  LumenMenuItem<String>(value: 'edit', label: 'Editar', icon: Icons.edit),
  LumenMenuItem<String>(value: 'off', label: 'Arquivar', enabled: false),
  LumenMenuDivider<String>(),
  LumenMenuItem<String>(value: 'del', label: 'Excluir', destructive: true),
];
