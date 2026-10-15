import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

void main() {
  testWidgets('showLumenBottomSheet abre e devolve o valor ao fechar', (
    tester,
  ) async {
    String? result;
    await pumpBare(
      tester,
      Builder(
        builder: (context) => LumenButton(
          label: 'Abrir',
          onPressed: () {
            unawaited(
              showLumenBottomSheet<String>(
                context: context,
                builder: (ctx) => TextButton(
                  onPressed: () => Navigator.of(ctx).pop('feito'),
                  child: const Text('Fechar'),
                ),
              ).then((value) => result = value),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    expect(find.text('Fechar'), findsOneWidget);

    await tester.tap(find.text('Fechar'));
    await tester.pumpAndSettle();
    expect(result, 'feito');
    expect(find.text('Fechar'), findsNothing);
  });
}
