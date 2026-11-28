import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

Finder _inPanel(Type type) =>
    find.descendant(of: find.byType(LumenPanel), matching: find.byType(type));

/// Decoration of the panel's own surface (the first DecoratedBox with a fill).
BoxDecoration _surface(WidgetTester tester) => tester
    .widgetList<DecoratedBox>(_inPanel(DecoratedBox))
    .map((box) => box.decoration)
    .whereType<BoxDecoration>()
    .firstWhere((decoration) => decoration.gradient is LinearGradient);

/// Painters drawn by the panel, by runtime type name.
List<String> _painters(WidgetTester tester) => <String>[
  for (final paint in tester.widgetList<CustomPaint>(_inPanel(CustomPaint)))
    for (final painter in <CustomPainter?>[paint.painter, paint.foregroundPainter])
      if (painter != null) painter.runtimeType.toString(),
];

Widget _panel(Set<LumenPanelEffect> effects, {Color? accentColor, VoidCallback? onTap}) => SizedBox(
  width: 300,
  child: LumenPanel(
    effects: effects,
    accentColor: accentColor,
    onTap: onTap,
    child: const Text('conteúdo'),
  ),
);

void main() {
  testWidgets('LumenPanel sem efeitos é só a superfície com borda de destaque', (tester) async {
    await pumpBare(tester, _panel(const <LumenPanelEffect>{}));

    expect(find.text('conteúdo'), findsOneWidget);
    expect(_painters(tester), isEmpty);
    expect(_inPanel(Stack), findsNothing);
    final surface = _surface(tester);
    expect(surface.border, isNotNull);
    expect(surface.boxShadow, isNull);
    // Largura pedida, altura do conteúdo mais o padding de 20.
    final size = tester.getSize(find.byType(LumenPanel));
    expect(size.width, 300);
    expect(size.height, tester.getSize(find.text('conteúdo')).height + 40);
  });

  testWidgets('LumenPanel desenha grade ou pontos atrás do conteúdo, e a grade vence', (
    tester,
  ) async {
    bool dots() =>
        (tester.widget<CustomPaint>(_inPanel(CustomPaint).last).painter! as dynamic).dots as bool;

    await pumpBare(tester, _panel(const <LumenPanelEffect>{LumenPanelEffect.grid}));
    expect(_painters(tester), <String>['_PatternPainter']);
    expect(dots(), isFalse);

    await pumpBare(tester, _panel(const <LumenPanelEffect>{LumenPanelEffect.dots}));
    expect(dots(), isTrue);

    await pumpBare(
      tester,
      _panel(const <LumenPanelEffect>{LumenPanelEffect.dots, LumenPanelEffect.grid}),
    );
    expect(dots(), isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('LumenPanel com orb usa accentColor e não intercepta o toque', (tester) async {
    const accent = Color(0xFFFF8A00);
    var taps = 0;
    await pumpBare(
      tester,
      _panel(
        const <LumenPanelEffect>{LumenPanelEffect.orb},
        accentColor: accent,
        onTap: () => taps++,
      ),
    );

    final orb = tester
        .widgetList<Container>(_inPanel(Container))
        .map((c) => c.decoration)
        .whereType<BoxDecoration>()
        .firstWhere((d) => d.gradient is RadialGradient);
    expect((orb.gradient! as RadialGradient).colors.first, accent.withValues(alpha: 0.22));

    // Toca o canto superior direito, onde o orb fica.
    final rect = tester.getRect(find.byType(LumenPanel));
    await tester.tapAt(rect.topRight + const Offset(-8, 8));
    await tester.pump();
    expect(taps, 1);
  });

  testWidgets('LumenPanel com gradientBorder troca a borda sólida pela pintada em gradiente', (
    tester,
  ) async {
    await pumpBare(tester, _panel(const <LumenPanelEffect>{LumenPanelEffect.gradientBorder}));
    expect(_painters(tester), <String>['_GradientBorderPainter']);
    expect(_surface(tester).border, isNull);
  });

  testWidgets('LumenPanel com glow ganha sombra em volta', (tester) async {
    const accent = Color(0xFF39FF14);
    await pumpBare(
      tester,
      _panel(const <LumenPanelEffect>{LumenPanelEffect.glow}, accentColor: accent),
    );
    final shadows = tester
        .widgetList<DecoratedBox>(_inPanel(DecoratedBox))
        .map((box) => box.decoration)
        .whereType<BoxDecoration>()
        .firstWhere((decoration) => decoration.boxShadow != null)
        .boxShadow!;
    expect(shadows.single.color, accent.withValues(alpha: 0.22));
  });

  testWidgets('LumenPanel só vira área de toque com onTap', (tester) async {
    var taps = 0;
    await pumpBare(tester, _panel(const <LumenPanelEffect>{}));
    expect(_inPanel(LumenPressable), findsNothing);

    await pumpBare(tester, _panel(const <LumenPanelEffect>{}, onTap: () => taps++));
    await tester.tap(find.text('conteúdo'));
    await tester.pump();
    expect(taps, 1);
  });

  testWidgets('LumenPanel em estilo sem gradiente dispensa o orb e volta à borda sólida', (
    tester,
  ) async {
    final palette = LumenPalette.fromSeed(primary: const Color(0xFF39FF14));
    await pumpBare(
      tester,
      LumenScope(
        palette: palette,
        style: LumenStyle.flat,
        child: _panel(LumenPanelEffect.values.toSet()),
      ),
    );

    // Sobra só o padrão: sem orb, sem borda em gradiente.
    expect(_painters(tester), <String>['_PatternPainter']);
    final decorations = tester
        .widgetList<Container>(_inPanel(Container))
        .map((c) => c.decoration)
        .whereType<BoxDecoration>();
    expect(decorations.where((d) => d.gradient is RadialGradient), isEmpty);
    final surface = _surface(tester);
    expect(surface.border, isNotNull);
    expect((surface.border! as Border).top.color.withValues(alpha: 1), palette.primary);
    expect(surface.borderRadius, LumenStyle.flat.radius(20));
  });

  for (final entry in LumenStyle.presets.entries) {
    testWidgets('LumenPanel com todos os efeitos renderiza no estilo ${entry.key}', (tester) async {
      for (final brightness in Brightness.values) {
        await pumpBare(
          tester,
          LumenScope(
            palette: LumenPreset.neon.palette(brightness: brightness),
            style: entry.value,
            child: _panel(LumenPanelEffect.values.toSet(), onTap: () {}),
          ),
        );
        expect(tester.takeException(), isNull, reason: brightness.name);
      }
    });
  }

  testWidgets('LumenPanel ocupa o espaço dado e recorta os efeitos nos cantos', (tester) async {
    await pumpBare(
      tester,
      const SizedBox(
        width: 240,
        height: 180,
        child: LumenPanel(
          effects: <LumenPanelEffect>{LumenPanelEffect.grid, LumenPanelEffect.orb},
          borderRadius: 12,
          child: Text('fixo'),
        ),
      ),
    );
    expect(tester.getSize(find.byType(LumenPanel)), const Size(240, 180));
    expect(tester.widget<ClipRRect>(_inPanel(ClipRRect)).borderRadius, BorderRadius.circular(12));
  });

  test('LumenPanel recusa patternSpacing não positivo', () {
    expect(() => LumenPanel(patternSpacing: 0, child: const Text('x')), throwsAssertionError);
  });
}
