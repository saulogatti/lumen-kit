import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:lumen_kit_example/main.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('galeria renderiza inteira sem exceção', (WidgetTester t) async {
    t.view.physicalSize = const Size(420, 900);
    t.view.devicePixelRatio = 1;
    await t.pumpWidget(const LumenExampleApp());
    await t.pump(const Duration(milliseconds: 500));
    for (int i = 0; i < 40; i++) {
      await t.drag(find.byType(Scrollable).first, const Offset(0, -300));
      await t.pump(const Duration(milliseconds: 100));
      expect(t.takeException(), isNull);
    }
  });

  testWidgets('galeria alterna as cores e o estilo de forma independente', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const LumenExampleApp());

    final title = find.text('CORES E ESTILO');
    LumenThemeExt currentTheme() => LumenThemeExt.of(tester.element(title));
    Future<void> tap(String label) async {
      await tester.tap(find.text(label));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }

    final materialTheme = ThemeData.light();
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.theme?.textTheme, materialTheme.textTheme);

    await tap('matrix');
    await tap('brutal');
    expect(currentTheme().palette.primary, LumenPreset.matrix.primary);
    expect(currentTheme().style.radius(14), BorderRadius.zero);

    await tap('Cores do Lumen');
    expect(find.text('matrix'), findsNothing);
    expect(currentTheme().palette.primary, materialTheme.colorScheme.primary);
    expect(currentTheme().style.radius(14), BorderRadius.zero);

    await tap('Estilo dos componentes');
    expect(find.text('brutal'), findsNothing);
    expect(currentTheme().palette.primary, materialTheme.colorScheme.primary);
    expect(currentTheme().style.radius(14), BorderRadius.circular(14));
    expect(currentTheme().style.shadow, LumenShadowKind.none);

    await tap('Cores do Lumen');
    expect(currentTheme().palette.primary, LumenPreset.matrix.primary);
    expect(currentTheme().style.shadow, LumenShadowKind.none);

    await tap('Estilo dos componentes');
    expect(currentTheme().palette.primary, LumenPreset.matrix.primary);
    expect(currentTheme().style.radius(14), BorderRadius.zero);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'comparação usa widgets e tema Material e volta à galeria Lumen',
    (tester) async {
      tester.view.physicalSize = const Size(420, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const LumenExampleApp());
      await tester.tap(find.text('matrix'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Material padrão'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, 'Material padrão'), findsOneWidget);
      expect(find.byType(LumenCard), findsNothing);
      final execute = find.widgetWithText(FilledButton, 'EXECUTAR');
      final materialTheme = Theme.of(tester.element(execute));
      expect(materialTheme.colorScheme, ThemeData.light().colorScheme);
      expect(materialTheme.extension<LumenThemeExt>(), isNull);

      await tester.tap(execute);
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);

      final list = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.byType(DataTable),
        280,
        scrollable: list,
      );
      expect(tester.takeException(), isNull);

      await tester.pageBack();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      final title = find.text('CORES E ESTILO');
      expect(
        LumenThemeExt.of(tester.element(title)).palette.primary,
        LumenPreset.matrix.primary,
      );
    },
  );
}
