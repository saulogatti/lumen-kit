import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

void main() {
  testWidgets('LumenSearchBar avisa a digitação e limpa o texto', (
    WidgetTester tester,
  ) async {
    final values = <String>[];
    await pumpBare(tester, LumenSearchBar(onChanged: values.add));

    await tester.enterText(find.byType(TextField), 'neon');
    await tester.pump();
    expect(values, <String>['neon']);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();
    expect(values, <String>['neon', '']);
    expect(find.text('neon'), findsNothing);
  });
}
