import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

void main() {
  testWidgets('LumenEmptyState mostra o CTA só com onPressed', (tester) async {
    var taps = 0;
    await pumpBare(
      tester,
      LumenEmptyState(
        icon: Icons.inbox_outlined,
        title: 'Nada por aqui',
        message: 'Quando chegar, aparece nesta lista.',
        actionLabel: 'Atualizar',
        onPressed: () => taps++,
      ),
    );
    expect(find.text('Nada por aqui'), findsOneWidget);
    expect(find.text('Quando chegar, aparece nesta lista.'), findsOneWidget);
    await tester.tap(find.text('Atualizar'));
    await tester.pump();
    expect(taps, 1);

    await pumpBare(tester, const LumenEmptyState(title: 'Nada por aqui', actionLabel: 'Atualizar'));
    expect(find.text('Atualizar'), findsNothing);
  });
}
