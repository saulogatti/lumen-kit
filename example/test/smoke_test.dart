import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:lumen_kit_example/main.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('gallery renders fully without exceptions', (
    WidgetTester t,
  ) async {
    t.view.physicalSize = const Size(420, 900);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpWidget(const LumenExampleApp());
    await t.pump(const Duration(milliseconds: 500));
    final end = find.byKey(const ValueKey('gallery-end'));
    final position = t
        .state<ScrollableState>(find.byType(Scrollable).first)
        .position;
    // Advance the viewport directly so nested input gestures cannot capture
    // the smoke test's scroll before it reaches later sections.
    for (int i = 0; i < 200 && position.extentAfter > 0; i++) {
      position.jumpTo(
        (position.pixels + 600).clamp(0, position.maxScrollExtent),
      );
      await t.pump(const Duration(milliseconds: 100));
      expect(t.takeException(), isNull);
    }
    expect(position.extentAfter, 0);
    expect(end, findsOneWidget);
    expect(
      t.getRect(end).overlaps(t.getRect(find.byType(ListView).first)),
      isTrue,
    );
  });

  testWidgets('gallery toggles colors and style independently', (tester) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const LumenExampleApp());

    final title = find.text('COLORS AND STYLE');
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

    await tap('Lumen colors');
    expect(find.text('matrix'), findsNothing);
    expect(currentTheme().palette.primary, materialTheme.colorScheme.primary);
    expect(currentTheme().style.radius(14), BorderRadius.zero);

    await tap('Component style');
    expect(find.text('brutal'), findsNothing);
    expect(currentTheme().palette.primary, materialTheme.colorScheme.primary);
    expect(currentTheme().style.radius(14), BorderRadius.circular(14));
    expect(currentTheme().style.shadow, LumenShadowKind.none);

    await tap('Lumen colors');
    expect(currentTheme().palette.primary, LumenPreset.matrix.primary);
    expect(currentTheme().style.shadow, LumenShadowKind.none);

    await tap('Component style');
    expect(currentTheme().palette.primary, LumenPreset.matrix.primary);
    expect(currentTheme().style.radius(14), BorderRadius.zero);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'comparison uses Material widgets and theme and returns to the Lumen gallery',
    (tester) async {
      tester.view.physicalSize = const Size(420, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const LumenExampleApp());
      await tester.tap(find.text('matrix'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Default Material'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, 'Default Material'), findsOneWidget);
      expect(find.byType(LumenCard), findsNothing);
      final execute = find.widgetWithText(FilledButton, 'RUN');
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
      final title = find.text('COLORS AND STYLE');
      expect(
        LumenThemeExt.of(tester.element(title)).palette.primary,
        LumenPreset.matrix.primary,
      );
    },
  );
}
