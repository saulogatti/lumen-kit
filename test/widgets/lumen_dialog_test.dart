import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

void main() {
  testWidgets('showLumenDialog mostra o título e devolve a ação', (tester) async {
    String? chosen;
    await pumpBare(
      tester,
      Builder(
        builder: (context) => LumenButton(
          label: 'Abrir',
          onPressed: () {
            unawaited(
              showLumenDialog<String>(
                context: context,
                title: 'Apagar',
                content: const Text('Não tem volta.'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop('ok'),
                    child: const Text('Confirmar'),
                  ),
                ],
              ).then((value) => chosen = value),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    expect(find.text('Apagar'), findsOneWidget);
    expect(find.text('Não tem volta.'), findsOneWidget);

    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();
    expect(chosen, 'ok');
    expect(find.text('Apagar'), findsNothing);
  });

  testWidgets('LumenDialog com icon mostra o ícone na cor do accent', (tester) async {
    const accent = Color(0xFFFF4081);
    await pumpBare(
      tester,
      const LumenDialog(
        title: 'Sair?',
        content: Text('A sessão será encerrada.'),
        icon: Icons.logout,
        accent: accent,
      ),
    );
    expect(tester.widget<Icon>(find.byIcon(Icons.logout)).color, accent);
  });
}
