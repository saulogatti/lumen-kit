// Simulates an app that already has its own theme (and classes with the same
// names as the kit) and imports only the components.
import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

class AppTheme {
  static ThemeData get light =>
      ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo));
}

class AppColors {
  static const Color brand = Color(0xFF3F51B5);
}

void main() {
  testWidgets('widgets funcionam sem LumenThemeExt no ThemeData', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: ListView(
            children: <Widget>[
              const LumenStatusChip(label: 'info', tone: LumenStatusTone.info),
              LumenButton(label: 'go', onPressed: () {}),
              LumenSwitch(value: true, onChanged: (_) {}),
              const LumenCard(child: Text('card')),
            ],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    final Text chip = tester.widget<Text>(find.text('info'));
    expect(chip.style?.color, LumenPalette.light().primary);
    // The app's theme remains intact.
    final BuildContext ctx = tester.element(find.text('card'));
    expect(Theme.of(ctx).extension<LumenThemeExt>(), isNull);
    expect(AppColors.brand, const Color(0xFF3F51B5));
  });

  testWidgets('LumenScope aplica paleta e estilo só na subárvore', (
    WidgetTester tester,
  ) async {
    const teal = Color(0xFF00BFA5);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Column(
            children: <Widget>[
              const LumenStatusChip(label: 'fora', tone: LumenStatusTone.info),
              LumenScope(
                palette: LumenPalette.fromSeed(primary: teal),
                style: LumenStyle.flat,
                child: const LumenStatusChip(
                  label: 'dentro',
                  tone: LumenStatusTone.info,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(tester.widget<Text>(find.text('dentro')).style?.color, teal);
    expect(
      tester.widget<Text>(find.text('fora')).style?.color,
      LumenPalette.light().primary,
    );
    expect(
      LumenStyle.of(tester.element(find.text('dentro'))),
      same(LumenStyle.flat),
    );
  });
}
