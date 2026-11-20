import 'dart:async';

import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

void main() {
  Future<void> open(
    WidgetTester tester, {
    required Color initial,
    void Function(Color? color)? onResult,
    List<Color>? swatches,
  }) async {
    await pumpBare(
      tester,
      Builder(
        builder: (context) => LumenButton(
          label: 'Open',
          onPressed: () {
            unawaited(
              showLumenColorPicker(
                context: context,
                initialColor: initial,
                swatches: swatches,
              ).then(onResult ?? (_) {}),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  String hexText(WidgetTester tester) =>
      tester.widget<EditableText>(find.byType(EditableText)).controller.text;

  String semanticValue(WidgetTester tester, String label) =>
      tester.getSemantics(find.bySemanticsLabel(label)).value;

  /// The whole saturation/brightness area: its two semantic halves side by side.
  Rect area(WidgetTester tester) => tester
      .getRect(find.bySemanticsLabel('Saturation'))
      .expandToInclude(tester.getRect(find.bySemanticsLabel('Brightness')));

  Future<void> confirm(WidgetTester tester) async {
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
  }

  testWidgets('showLumenColorPicker abre sem tema registrado', (tester) async {
    await open(tester, initial: const Color(0xFF00BCD4));
    expect(find.bySemanticsLabel('Hue'), findsOneWidget);
    expect(find.bySemanticsLabel('Saturation'), findsOneWidget);
    expect(find.bySemanticsLabel('Brightness'), findsOneWidget);
    expect(find.bySemanticsLabel('Original color'), findsOneWidget);
    expect(find.bySemanticsLabel('Selected color'), findsOneWidget);
    expect(find.text('Hex'), findsOneWidget);
    expect(hexText(tester), '#00BCD4');
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
    expect(hexText(tester), '#CC00BCD4');

    await confirm(tester);

    expect(completed, isTrue);
    expect(find.text('Color'), findsNothing);
    final got = HSVColor.fromColor(chosen!);
    final expected = HSVColor.fromColor(initial);
    expect(got.hue, closeTo(expected.hue, 0.05));
    expect(got.saturation, closeTo(expected.saturation, 0.01));
    expect(got.value, closeTo(expected.value, 0.01));
    expect(got.alpha, closeTo(expected.alpha, 0.01));
  });

  testWidgets('tocar na área define saturação e brilho e mantém o matiz', (tester) async {
    const initial = Color(0xFF00BCD4);
    Color? chosen;
    await open(tester, initial: initial, onResult: (color) => chosen = color);

    final rect = area(tester);
    await tester.tapAt(Offset(rect.left + rect.width * 0.25, rect.top + rect.height * 0.5));
    await tester.pumpAndSettle();
    expect(semanticValue(tester, 'Saturation'), '25%');
    expect(semanticValue(tester, 'Brightness'), '50%');
    expect(hexText(tester), isNot('#00BCD4'));

    await confirm(tester);

    final got = HSVColor.fromColor(chosen!);
    expect(got.hue, closeTo(HSVColor.fromColor(initial).hue, 1));
    expect(got.saturation, closeTo(0.25, 0.02));
    expect(got.value, closeTo(0.5, 0.02));
  });

  testWidgets('arrastar até o cinza e voltar preserva o matiz', (tester) async {
    const initial = Color(0xFF00BCD4);
    final hue = HSVColor.fromColor(initial).hue;
    Color? chosen;
    await open(tester, initial: initial, onResult: (color) => chosen = color);

    final rect = area(tester);
    await tester.dragFrom(rect.center, Offset(-rect.width, 0));
    await tester.pumpAndSettle();
    expect(semanticValue(tester, 'Saturation'), '0%');
    expect(semanticValue(tester, 'Hue'), '${hue.round()}°');

    await tester.dragFrom(Offset(rect.left + 1, rect.center.dy), Offset(rect.width * 0.6, 0));
    await tester.pumpAndSettle();
    await confirm(tester);

    final got = HSVColor.fromColor(chosen!);
    expect(got.hue, closeTo(hue, 1));
    expect(got.saturation, greaterThan(0.4));
  });

  testWidgets('arraste contínuo acompanha o dedo na área e na trilha', (tester) async {
    await open(tester, initial: const Color(0xFF00BCD4));

    // Several moves, as a real finger does: after the slop, each move
    // arrives as an update.
    Future<void> slide(Offset from, Offset step, int steps) async {
      final gesture = await tester.startGesture(from);
      for (var i = 0; i < steps; i++) {
        await gesture.moveBy(step);
        await tester.pump();
      }
      await gesture.up();
      await tester.pumpAndSettle();
    }

    final rect = area(tester);
    await slide(Offset(rect.left + 1, rect.center.dy), Offset(rect.width / 10, 0), 4);
    expect(semanticValue(tester, 'Saturation'), '40%');

    final track = tester.getRect(find.bySemanticsLabel('Hue'));
    await slide(Offset(track.left + 1, track.center.dy), Offset(track.width / 8, 0), 4);
    final hue = (1 + track.width / 2) / track.width * 360;
    expect(semanticValue(tester, 'Hue'), '${hue.round()}°');
  });

  testWidgets('trilha de matiz muda o matiz e mantém saturação e brilho', (tester) async {
    const initial = Color(0xFF00BCD4);
    Color? chosen;
    await open(tester, initial: initial, onResult: (color) => chosen = color);

    final track = tester.getRect(find.bySemanticsLabel('Hue'));
    await tester.tapAt(Offset(track.left + track.width / 3, track.center.dy));
    await tester.pumpAndSettle();
    expect(semanticValue(tester, 'Hue'), '120°');

    await confirm(tester);

    final got = HSVColor.fromColor(chosen!);
    final expected = HSVColor.fromColor(initial);
    expect(got.hue, closeTo(120, 1));
    expect(got.saturation, closeTo(expected.saturation, 0.02));
    expect(got.value, closeTo(expected.value, 0.02));
  });

  testWidgets('setas do teclado ajustam o matiz e a área focada', (tester) async {
    await open(tester, initial: const Color(0xFFFF0000));

    final track = tester.getRect(find.bySemanticsLabel('Hue'));
    await tester.tapAt(Offset(track.left + track.width / 4, track.center.dy));
    await tester.pumpAndSettle();
    expect(semanticValue(tester, 'Hue'), '90°');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(semanticValue(tester, 'Hue'), '91°');
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pump();
    expect(semanticValue(tester, 'Hue'), '81°');

    final rect = area(tester);
    await tester.tapAt(Offset(rect.left + rect.width / 2, rect.top + rect.height / 2));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    expect(semanticValue(tester, 'Saturation'), '49%');
    expect(semanticValue(tester, 'Brightness'), '51%');
  });

  testWidgets('ações de acessibilidade ajustam cada canal', (tester) async {
    await open(tester, initial: const HSVColor.fromAHSV(1, 120, 0.5, 0.5).toColor());

    tester.semantics.increase(find.semantics.byLabel('Saturation'));
    tester.semantics.decrease(find.semantics.byLabel('Brightness'));
    tester.semantics.increase(find.semantics.byLabel('Hue'));
    await tester.pump();

    expect(semanticValue(tester, 'Saturation'), '55%');
    expect(semanticValue(tester, 'Brightness'), '45%');
    expect(semanticValue(tester, 'Hue'), '125°');
  });

  testWidgets('hex de 6 dígitos mantém o alfa e o de 8 substitui', (tester) async {
    Color? chosen;
    await open(tester, initial: const Color(0x8000BCD4), onResult: (color) => chosen = color);

    await tester.enterText(find.byType(EditableText), '#FF0000');
    await tester.pump();
    expect(semanticValue(tester, 'Hue'), '0°');
    expect(semanticValue(tester, 'Saturation'), '100%');

    await confirm(tester);
    expect(chosen!.toARGB32(), 0x80FF0000);

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), '4000FF00');
    await tester.pump();
    await confirm(tester);
    expect(chosen!.toARGB32(), 0x4000FF00);
  });

  testWidgets('hex inválido não muda a cor e volta ao valor atual', (tester) async {
    await open(tester, initial: const Color(0xFF00BCD4));

    await tester.enterText(find.byType(EditableText), '#12');
    await tester.pump();
    expect(semanticValue(tester, 'Selected color'), '#00BCD4');

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(hexText(tester), '#00BCD4');
  });

  testWidgets('amostra aplica a cor e mantém o alfa', (tester) async {
    Color? chosen;
    await open(
      tester,
      initial: const Color(0x8000BCD4),
      swatches: const <Color>[Color(0xFFFF5722), Color(0xFF4CAF50)],
      onResult: (color) => chosen = color,
    );

    final swatch = find.bySemanticsLabel('#4CAF50');
    expect(swatch, findsOneWidget);
    await tester.tap(swatch);
    await tester.pumpAndSettle();
    expect(tester.getSemantics(swatch), isSemantics(isSelected: true, isButton: true));
    expect(hexText(tester), '#804CAF50');

    await confirm(tester);
    expect(chosen!.toARGB32(), 0x804CAF50);
  });

  testWidgets('sem swatches padrão as amostras vêm da paleta; lista vazia esconde', (tester) async {
    await open(tester, initial: const Color(0xFF00BCD4));
    final palette = LumenThemeExt.of(tester.element(find.text('Hex'))).palette;
    expect(find.bySemanticsLabel(_hex(palette.secondary)), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    await tester.pumpWidget(const SizedBox());
    await open(tester, initial: const Color(0xFF00BCD4), swatches: const <Color>[]);
    expect(find.bySemanticsLabel(_hex(palette.secondary)), findsNothing);
  });

  testWidgets('tocar na cor original restaura a inicial', (tester) async {
    const initial = Color(0xFF00BCD4);
    Color? chosen;
    await open(tester, initial: initial, onResult: (color) => chosen = color);

    await tester.enterText(find.byType(EditableText), '#123456');
    await tester.pump();
    await tester.tap(find.bySemanticsLabel('Original color'));
    await tester.pumpAndSettle();
    expect(hexText(tester), '#00BCD4');

    await confirm(tester);
    expect(chosen!.toARGB32(), initial.toARGB32());
  });

  testWidgets('com animações reduzidas o marcador não anima', (tester) async {
    // bareApp puts its MediaQuery below the navigator, out of the dialog's
    // reach. Here the reduced-motion flag wraps the navigator itself.
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: Builder(
          builder: (context) => Center(
            child: LumenButton(
              label: 'Open',
              onPressed: () => unawaited(
                showLumenColorPicker(context: context, initialColor: const Color(0xFF00BCD4)),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final rect = area(tester);
    await tester.tapAt(rect.center);
    await tester.pump();
    expect(tester.hasRunningAnimations, isFalse);
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
    expect(find.text('Hex'), findsNothing);
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
    expect(find.text('Hex'), findsNothing);
  });

  testWidgets('em tela baixa o conteúdo rola e o OK continua alcançável', (tester) async {
    // A phone with the keyboard open, or a short landscape window.
    tester.view.physicalSize = const Size(400, 420);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    Color? chosen;
    await open(tester, initial: const Color(0xFF00BCD4), onResult: (color) => chosen = color);
    expect(tester.takeException(), isNull);

    // Dragging inside the area edits the color instead of scrolling.
    final scrollable = find
        .descendant(of: find.byType(SingleChildScrollView), matching: find.byType(Scrollable))
        .first;
    final position = tester.state<ScrollableState>(scrollable).position;
    expect(position.maxScrollExtent, greaterThan(0), reason: 'the content must not fit');
    final offset = tester.state<ScrollableState>(scrollable).position.pixels;
    final rect = area(tester);
    await tester.dragFrom(Offset(rect.center.dx, rect.top + 10), Offset(0, rect.height * 0.5));
    await tester.pumpAndSettle();
    expect(tester.state<ScrollableState>(scrollable).position.pixels, offset);
    final brightness = 1 - (10 + rect.height * 0.5) / rect.height;
    expect(semanticValue(tester, 'Brightness'), '${(brightness * 100).round()}%');

    // The actions sit outside the scroll view, so OK is tappable as is.
    await confirm(tester);
    expect(chosen, isNotNull);
  });
}

String _hex(Color color) =>
    '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
