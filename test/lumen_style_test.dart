import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/lumen_kit.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('LumenStyle', () {
    test('neon mantém os glows originais', () {
      final out = LumenStyle.neon.shadows(_glow);
      expect(out, hasLength(2));
      expect(out!.first.color, _glow.first.color);
    });

    test('elevation troca glow por sombra neutra e descarta glows pequenos', () {
      final out = LumenStyle.flat.shadows(_glow);
      expect(out, hasLength(1));
      expect(out!.single.color.r, 0);
      expect(out.single.offset.dy, greaterThan(0));
    });

    test('hard vira sombra sem blur deslocada', () {
      final s = LumenStyle.brutal.shadows(_glow)!.single;
      expect(s.blurRadius, 0);
      expect(s.offset, const Offset(4, 4));
    });

    test('none remove as sombras', () {
      expect(LumenStyle.neon.copyWith(shadow: LumenShadowKind.none).shadows(_glow), isNull);
    });

    test('copyWith preserva os tokens que não foram passados', () {
      final s = LumenStyle.brutal.copyWith(radiusScale: 2);
      expect(s.radius(10), BorderRadius.circular(20));
      expect(s.shadow, LumenStyle.brutal.shadow);
      expect(s.borderScale, LumenStyle.brutal.borderScale);
      expect(s.gradients, LumenStyle.brutal.gradients);
    });

    test('fill vira cor sólida quando gradients é falso', () {
      const g = LinearGradient(colors: <Color>[Color(0xFF111111), Color(0xFF222222)]);
      expect(LumenStyle.neon.fill(g), g);
      expect((LumenStyle.flat.fill(g)! as LinearGradient).colors, <Color>[
        const Color(0xFF111111),
        const Color(0xFF111111),
      ]);
    });

    test('radius e borda seguem as escalas', () {
      expect(LumenStyle.brutal.radius(20), BorderRadius.zero);
      expect(LumenStyle.soft.borderAll(width: 1.2), const Border());
      expect(LumenStyle.brutal.borderAll(width: 1.2).top.width, 2.4);
    });
  });

  for (final e in LumenStyle.presets.entries) {
    testWidgets('estilo ${e.key} renderiza o kit sem erros', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.fromPreset(LumenPreset.matrix, style: e.value),
          home: Scaffold(
            body: LumenAnimatedGridBackground(
              child: ListView(
                children: <Widget>[
                  const LumenCard(glow: true, child: Text('card')),
                  LumenButton(label: 'go', onPressed: () {}),
                  LumenButton.outline(label: 'out', onPressed: () {}),
                  LumenIconButton.solid(icon: Icons.add, onPressed: () {}),
                  LumenSwitch(value: true, onChanged: (_) {}),
                  LumenCheckbox(value: true, onChanged: (_) {}),
                  LumenSlider(value: 0.4, onChanged: (_) {}),
                  const LumenLinearProgress(value: 0.5),
                  const LumenCircularProgress(value: 0.5),
                  const LumenStatusChip(label: 'ok', tone: LumenStatusTone.success),
                  LumenListTile(title: 'tile', selected: true, onTap: () {}),
                ],
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('card'), findsOneWidget);
    });
  }
}

const List<BoxShadow> _glow = <BoxShadow>[
  BoxShadow(color: Color(0x5900E5FF), blurRadius: 14, spreadRadius: -2),
  BoxShadow(color: Color(0x9900E5FF), blurRadius: 6),
];
