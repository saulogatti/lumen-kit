import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('LumenAppBar mostra título, subtítulo e a ação', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: LumenAppBar(
            title: 'Painel',
            subtitle: 'agora',
            actions: <Widget>[
              IconButton(
                onPressed: () => taps++,
                icon: const Icon(Icons.settings),
              ),
            ],
          ),
          body: const SizedBox.shrink(),
        ),
      ),
    );

    expect(find.text('Painel'), findsOneWidget);
    expect(find.text('agora'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pump();
    expect(taps, 1);
    expect(tester.takeException(), isNull);
  });
}
