import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:neon_ui/neon_ui.dart';

const List<BoxShadow> _glow = <BoxShadow>[
  BoxShadow(color: Color(0x5900E5FF), blurRadius: 14, spreadRadius: -2),
  BoxShadow(color: Color(0x9900E5FF), blurRadius: 6),
];

void main() {
  group('NeonStyle', () {
    test('neon mantém os glows originais', () {
      final List<BoxShadow>? out = NeonStyle.neon.shadows(_glow);
      expect(out, hasLength(2));
      expect(out!.first.color, _glow.first.color);
    });

    test(
      'elevation troca glow por sombra neutra e descarta glows pequenos',
      () {
        final List<BoxShadow>? out = NeonStyle.flat.shadows(_glow);
        expect(out, hasLength(1));
        expect(out!.single.color.r, 0);
        expect(out.single.offset.dy, greaterThan(0));
      },
    );

    test('hard vira sombra sem blur deslocada', () {
      final BoxShadow s = NeonStyle.brutal.shadows(_glow)!.single;
      expect(s.blurRadius, 0);
      expect(s.offset, const Offset(4, 4));
    });

    test('none remove as sombras', () {
      expect(
        NeonStyle.neon.copyWith(shadow: NeonShadowKind.none).shadows(_glow),
        isNull,
      );
    });

    test('fill vira cor sólida quando gradients é falso', () {
      const g = LinearGradient(
        colors: <Color>[Color(0xFF111111), Color(0xFF222222)],
      );
      expect(NeonStyle.neon.fill(g), g);
      expect((NeonStyle.flat.fill(g)! as LinearGradient).colors, <Color>[
        const Color(0xFF111111),
        const Color(0xFF111111),
      ]);
    });

    test('radius e borda seguem as escalas', () {
      expect(NeonStyle.brutal.radius(20), BorderRadius.zero);
      expect(NeonStyle.soft.borderAll(width: 1.2), const Border());
      expect(NeonStyle.brutal.borderAll(width: 1.2).top.width, 2.4);
    });
  });

  for (final MapEntry<String, NeonStyle> e in NeonStyle.presets.entries) {
    testWidgets('estilo ${e.key} renderiza o kit sem erros', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.fromPreset(NeonPreset.matrix, style: e.value),
          home: Scaffold(
            body: AnimatedGridBackground(
              child: ListView(
                children: <Widget>[
                  const NeonCard(glow: true, child: Text('card')),
                  NeonButton(label: 'go', onPressed: () {}),
                  NeonButton.outline(label: 'out', onPressed: () {}),
                  NeonIconButton.solid(icon: Icons.add, onPressed: () {}),
                  NeonSwitch(value: true, onChanged: (_) {}),
                  NeonCheckbox(value: true, onChanged: (_) {}),
                  NeonSlider(value: 0.4, onChanged: (_) {}),
                  const NeonLinearProgress(value: 0.5),
                  const NeonCircularProgress(value: 0.5),
                  const StatusChip(label: 'ok', tone: StatusTone.success),
                  NeonListTile(title: 'tile', selected: true, onTap: () {}),
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
