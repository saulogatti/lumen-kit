// Simula um app que já tem o próprio tema (e classes com os mesmos nomes do
// kit) e importa só os componentes.
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:neon_ui/components.dart';

class AppTheme {
  static ThemeData get light =>
      ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo));
}

class AppColors {
  static const Color brand = Color(0xFF3F51B5);
}

void main() {
  testWidgets('widgets funcionam sem NeonThemeExt no ThemeData', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: ListView(
            children: <Widget>[
              const StatusChip(label: 'info', tone: StatusTone.info),
              NeonButton(label: 'go', onPressed: () {}),
              NeonSwitch(value: true, onChanged: (_) {}),
              const NeonCard(child: Text('card')),
            ],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    final Text chip = tester.widget<Text>(find.text('info'));
    expect(chip.style?.color, NeonPalette.light().primary);
    // O tema do app continua intacto.
    final BuildContext ctx = tester.element(find.text('card'));
    expect(Theme.of(ctx).extension<NeonThemeExt>(), isNull);
    expect(AppColors.brand, const Color(0xFF3F51B5));
  });

  testWidgets('NeonScope aplica paleta e estilo só na subárvore', (
    WidgetTester tester,
  ) async {
    const Color teal = Color(0xFF00BFA5);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Column(
            children: <Widget>[
              const StatusChip(label: 'fora', tone: StatusTone.info),
              NeonScope(
                palette: NeonPalette.fromSeed(primary: teal),
                style: NeonStyle.flat,
                child: const StatusChip(label: 'dentro', tone: StatusTone.info),
              ),
            ],
          ),
        ),
      ),
    );

    expect(tester.widget<Text>(find.text('dentro')).style?.color, teal);
    expect(
      tester.widget<Text>(find.text('fora')).style?.color,
      NeonPalette.light().primary,
    );
    expect(
      NeonStyle.of(tester.element(find.text('dentro'))),
      same(NeonStyle.flat),
    );
  });
}
