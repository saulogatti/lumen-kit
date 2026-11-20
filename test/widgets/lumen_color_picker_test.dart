import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

void main() {
  Future<void> open(
    WidgetTester tester, {
    required Color initial,
    required void Function(Color? color) onResult,
  }) async {
    await pumpBare(
      tester,
      Builder(
        builder: (context) => LumenButton(
          label: 'Open',
          onPressed: () {
            unawaited(showLumenColorPicker(context: context, initialColor: initial).then(onResult));
          },
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  testWidgets('showLumenColorPicker abre sem tema registrado', (tester) async {
    await open(tester, initial: const Color(0xFF00BCD4), onResult: (_) {});
    expect(find.text('Hue'), findsOneWidget);
    expect(find.text('Saturation'), findsOneWidget);
    expect(find.text('Brightness'), findsOneWidget);
    expect(find.text('OK'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('OK devolve a cor inicial', (tester) async {
    const initial = Color(0xCC00BCD4);
    Color? chosen;
    var completed = false;
    await open(
      tester,
      initial: initial,
      onResult: (color) {
        completed = true;
        chosen = color;
      },
    );

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(completed, isTrue);
    expect(find.text('Color'), findsNothing);
    final got = HSVColor.fromColor(chosen!);
    final expected = HSVColor.fromColor(initial);
    expect(got.hue, closeTo(expected.hue, 0.05));
    expect(got.saturation, closeTo(expected.saturation, 0.01));
    expect(got.value, closeTo(expected.value, 0.01));
    expect(got.alpha, closeTo(expected.alpha, 0.01));
  });

  testWidgets('arrastar a saturação e confirmar devolve o HSV', (tester) async {
    const initial = Color(0xFF00BCD4);
    Color? chosen;
    await open(tester, initial: initial, onResult: (color) => chosen = color);

    final saturation = find.byType(Slider).at(1);
    final before = tester.widget<Slider>(saturation).value;
    await tester.drag(saturation, const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(tester.widget<Slider>(saturation).value, lessThan(0.05));

    // Gray cannot store a hue. Raising saturation again must restore it.
    await tester.drag(saturation, const Offset(180, 0));
    await tester.pumpAndSettle();
    final after = tester.widget<Slider>(saturation).value;
    expect(after, greaterThan(0.15));
    expect(after, lessThan(before));

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    final got = HSVColor.fromColor(chosen!);
    final expected = HSVColor.fromColor(initial);
    expect(got.hue, closeTo(expected.hue, 0.5));
    expect(got.saturation, closeTo(after, 0.02));
    expect(got.value, closeTo(expected.value, 0.02));
  });

  testWidgets('Cancel devolve null e fecha', (tester) async {
    Color? chosen = const Color(0xFFFF0000);
    var completed = false;
    await open(
      tester,
      initial: const Color(0xFF00BCD4),
      onResult: (color) {
        completed = true;
        chosen = color;
      },
    );

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(completed, isTrue);
    expect(chosen, isNull);
    expect(find.text('Hue'), findsNothing);
  });

  testWidgets('toque na barreira devolve null e fecha', (tester) async {
    Color? chosen = const Color(0xFFFF0000);
    var completed = false;
    await open(
      tester,
      initial: const Color(0xFF00BCD4),
      onResult: (color) {
        completed = true;
        chosen = color;
      },
    );

    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();

    expect(completed, isTrue);
    expect(chosen, isNull);
    expect(find.text('Hue'), findsNothing);
  });
}
