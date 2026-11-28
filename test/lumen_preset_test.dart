import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/lumen_kit.dart';
import 'package:material_ui/material_ui.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (la > lb ? la + 0.05 : lb + 0.05) / (la > lb ? lb + 0.05 : la + 0.05);
}

void main() {
  test('intense e soft cobrem todos os presets, sem repetir', () {
    final all = <LumenPreset>[...LumenPreset.intense, ...LumenPreset.soft];
    expect(all.toSet(), LumenPreset.values.toSet());
    expect(all, hasLength(LumenPreset.values.length));
  });

  test('presets suaves têm acentos claros (pastel) e os intensos, saturados', () {
    for (final preset in LumenPreset.soft) {
      final hsl = HSLColor.fromColor(preset.primary);
      expect(hsl.lightness, greaterThanOrEqualTo(0.7), reason: preset.name);
    }
    for (final preset in LumenPreset.intense) {
      final hsl = HSLColor.fromColor(preset.primary);
      expect(hsl.saturation, greaterThanOrEqualTo(0.95), reason: preset.name);
      expect(hsl.lightness, lessThan(0.7), reason: preset.name);
    }
  });

  for (final preset in LumenPreset.values) {
    for (final brightness in Brightness.values) {
      test('${preset.name} ${brightness.name} mantém os acentos e texto legível', () {
        final p = preset.palette(brightness: brightness);
        expect(p.primary, preset.primary);
        expect(p.secondary, preset.secondary);
        expect(_contrast(p.textPrimary, p.backgroundDeep), greaterThanOrEqualTo(7));
        expect(_contrast(p.textPrimary, p.surface), greaterThanOrEqualTo(7));
      });
    }
  }

  for (final preset in LumenPreset.values) {
    testWidgets('${preset.name} renderiza o kit no escuro e no claro', (tester) async {
      for (final brightness in Brightness.values) {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.fromPreset(preset, brightness: brightness, style: LumenStyle.vivid),
            home: Scaffold(
              body: LumenAnimatedGridBackground(
                child: ListView(
                  children: <Widget>[
                    const LumenCard(glow: true, child: Text('card')),
                    LumenButton(label: 'go', onPressed: () {}),
                    LumenButton.outline(label: 'out', onPressed: () {}),
                    LumenSwitch(value: true, onChanged: (_) {}),
                    const LumenStatusChip(label: 'ok', tone: LumenStatusTone.success),
                    LumenListTile(title: 'tile', selected: true, onTap: () {}),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull, reason: brightness.name);
      }
    });
  }
}
