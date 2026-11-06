import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

void main() {
  testWidgets('LumenTextField que larga o controller externo mantém o texto', (tester) async {
    final external = TextEditingController(text: 'digitado');
    addTearDown(external.dispose);
    Widget field(TextEditingController? c) => SizedBox(
      width: 320,
      child: LumenTextField(label: 'Nome', controller: c),
    );

    await pumpBare(tester, field(external));
    expect(find.text('digitado'), findsOneWidget);

    await pumpBare(tester, field(null));
    expect(find.text('digitado'), findsOneWidget);

    // O texto agora vive no controller interno: mexer no externo não reflete.
    external.text = 'outro';
    await tester.pump();
    expect(find.text('outro'), findsNothing);
  });
}
