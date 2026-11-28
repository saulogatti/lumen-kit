import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('LumenAppBar mostra título, subtítulo e a ação', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: LumenAppBar(
            title: 'Painel',
            subtitle: 'agora',
            actions: <Widget>[
              IconButton(onPressed: () => taps++, icon: const Icon(Icons.settings)),
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

  testWidgets('LumenAppBar pinta título e subtítulo com o texto da paleta do LumenScope', (
    tester,
  ) async {
    // Paleta clara dentro de um app escuro: o texto do tema de fora seria
    // claro sobre o fundo claro.
    final palette = LumenPalette.light();
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: Brightness.dark),
        home: LumenScope(
          palette: palette,
          child: const Scaffold(
            appBar: LumenAppBar(title: 'Painel', subtitle: 'agora'),
            body: SizedBox.shrink(),
          ),
        ),
      ),
    );

    expect(tester.widget<Text>(find.text('Painel')).style?.color, palette.textPrimary);
    expect(tester.widget<Text>(find.text('agora')).style?.color, palette.textMuted);
  });
}
