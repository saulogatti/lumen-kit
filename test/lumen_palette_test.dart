import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/lumen_kit.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('LumenPalette', () {
    test('defaultDark mantém exatamente os tokens de AppColors', () {
      final p = LumenPalette.defaultDark();
      expect(p.primary, AppColors.accentCyan);
      expect(p.secondary, AppColors.accentMagenta);
      expect(p.tertiary, AppColors.accentBlue);
      expect(p.accentGradient, AppColors.accentGradient);
      expect(p.backgroundGradient, AppColors.backgroundGradient);
    });

    test('fromSeed deriva accents e gradientes da cor informada', () {
      const green = Color(0xFF39FF14);
      final p = LumenPalette.fromSeed(primary: green);
      expect(p.primary, green);
      expect(p.secondary, isNot(green));
      expect(p.accentGradient.colors, <Color>[
        p.primary,
        p.tertiary,
        p.secondary,
      ]);
      expect(p.backgroundDeep.computeLuminance(), lessThan(0.01));

      final light = LumenPalette.fromSeed(
        primary: green,
        brightness: Brightness.light,
      );
      expect(light.backgroundDeep.computeLuminance(), greaterThan(0.8));
      expect(light.textPrimary.computeLuminance(), lessThan(0.05));
    });

    test('copyWith recalcula o gradiente quando um accent muda', () {
      final LumenPalette p = LumenPalette.defaultDark().copyWith(
        primary: const Color(0xFFFF8A00),
      );
      expect(p.accentGradient.colors.first, const Color(0xFFFF8A00));
      expect(p.backgroundGradient, AppColors.backgroundGradient);
    });

    test('aliases antigos continuam funcionando', () {
      // ignore: deprecated_member_use_from_same_package
      final LumenPalette p = LumenPalette.defaultDark().copyWith(
        // ignore: deprecated_member_use_from_same_package
        accentCyan: const Color(0xFF123456),
      );
      expect(p.primary, const Color(0xFF123456));
      // ignore: deprecated_member_use_from_same_package
      expect(p.accentCyan, p.primary);
    });

    test('light() usa contorno translúcido e fundo claro', () {
      final p = LumenPalette.light();
      expect(p.surfaceOutline.a, lessThan(0.2));
      expect(
        p.backgroundGradient.colors.first.computeLuminance(),
        greaterThan(0.8),
      );
    });
  });

  testWidgets('widgets seguem a paleta do tema, não AppColors', (
    WidgetTester tester,
  ) async {
    const orange = Color(0xFFFF8A00);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.fromSeed(primary: orange),
        home: const Scaffold(
          body: AnimatedGridBackground(
            child: Column(
              children: <Widget>[
                LumenStatusChip(label: 'info', tone: LumenStatusTone.info),
                LumenCard(child: Text('card')),
                LumenTextField(
                  label: 'nome',
                  icon: Icons.person,
                  onChanged: _ignore,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final Text chipLabel = tester.widget<Text>(find.text('info'));
    expect(chipLabel.style?.color, orange);
    final Icon fieldIcon = tester.widget<Icon>(find.byIcon(Icons.person));
    expect(fieldIcon.color, orange);
  });
}

void _ignore(String _) {}
