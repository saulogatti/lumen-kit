import 'dart:async';

import 'package:flutter/rendering.dart' show SemanticsAction;
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

/// Button that opens [showLumenTimePicker] and records each result.
Widget _opener({
  required List<TimeOfDay?> results,
  TimeOfDay initial = const TimeOfDay(hour: 14, minute: 30),
  Color? accentColor,
  String? helpText,
  bool? use24HourFormat,
  TimePickerEntryMode entryMode = TimePickerEntryMode.dial,
}) => Builder(
  builder: (context) => LumenButton(
    label: 'Open',
    onPressed: () => unawaited(
      showLumenTimePicker(
        context: context,
        initialTime: initial,
        accentColor: accentColor,
        helpText: helpText,
        use24HourFormat: use24HourFormat,
        initialEntryMode: entryMode,
      ).then(results.add),
    ),
  ),
);

Future<List<TimeOfDay?>> _open(
  WidgetTester tester, {
  TimeOfDay initial = const TimeOfDay(hour: 14, minute: 30),
  Color? accentColor,
  String? helpText,
  bool? use24HourFormat,
  TimePickerEntryMode entryMode = TimePickerEntryMode.dial,
  bool reduceMotion = false,
}) async {
  final results = <TimeOfDay?>[];
  await pumpBare(
    tester,
    _opener(
      results: results,
      initial: initial,
      accentColor: accentColor,
      helpText: helpText,
      use24HourFormat: use24HourFormat,
      entryMode: entryMode,
    ),
    reduceMotion: reduceMotion,
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
  return results;
}

Future<void> _key(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyEvent(key);
  await tester.pumpAndSettle();
}

Future<void> _ok(WidgetTester tester) async {
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

/// Taps the up (`delta > 0`) or down button of the [index]th column.
Future<void> _step(WidgetTester tester, int index, int delta) async {
  final icon = delta > 0 ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded;
  await tester.tap(find.byIcon(icon).at(index));
  await tester.pump();
}

/// Decoration of the AM or PM option labeled [label].
BoxDecoration _periodDecoration(WidgetTester tester, String label) =>
    tester
            .widget<AnimatedContainer>(
              find.ancestor(of: find.text(label), matching: find.byType(AnimatedContainer)),
            )
            .decoration!
        as BoxDecoration;

void main() {
  testWidgets('LumenTimePicker mostra o horário e devolve o escolhido', (tester) async {
    TimeOfDay? picked;
    await pumpBare(
      tester,
      LumenTimePicker(
        label: 'Horário',
        value: const TimeOfDay(hour: 9, minute: 5),
        use24HourFormat: true,
        onChanged: (t) => picked = t,
      ),
    );
    expect(find.text('09:05'), findsOneWidget);

    await tester.tap(find.byType(LumenTimePicker));
    await tester.pumpAndSettle();
    expect(find.text('Select time'), findsOneWidget);
    expect(find.text('09'), findsOneWidget);
    expect(find.text('05'), findsOneWidget);
    expect(find.text('AM'), findsNothing);

    await _step(tester, 1, 1);
    await _ok(tester);
    expect(picked, const TimeOfDay(hour: 9, minute: 6));
  });

  testWidgets('LumenTimePicker usa o format customizado e o hint', (tester) async {
    await pumpBare(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          LumenTimePicker(
            value: const TimeOfDay(hour: 14, minute: 30),
            format: (t) => '${t.hour}h${t.minute}',
            onChanged: (_) {},
          ),
          const LumenTimePicker(value: null, hint: 'Escolha a hora', onChanged: null),
        ],
      ),
    );
    expect(find.text('14h30'), findsOneWidget);
    expect(find.text('Escolha a hora'), findsOneWidget);

    // Desabilitado: tocar não abre nada.
    await tester.tap(find.text('Escolha a hora'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byType(LumenDialog), findsNothing);
  });

  testWidgets('cancelar o LumenTimePicker não chama onChanged', (tester) async {
    final picked = <TimeOfDay>[];
    await pumpBare(
      tester,
      LumenTimePicker(value: const TimeOfDay(hour: 8, minute: 0), onChanged: picked.add),
    );
    await tester.tap(find.byType(LumenTimePicker));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(LumenDialog), findsNothing);
    expect(picked, isEmpty);
  });

  testWidgets('12 h: a hora gira dentro do período e AM/PM troca o período', (tester) async {
    final results = await _open(tester, initial: const TimeOfDay(hour: 23, minute: 30));
    expect(find.text('11:30 PM'), findsOneWidget);
    expect(find.text('11'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);

    await _step(tester, 0, 1);
    expect(find.text('12:30 PM'), findsOneWidget);
    await _step(tester, 0, 1);
    expect(find.text('1:30 PM'), findsOneWidget);
    await _step(tester, 0, -1);
    await _step(tester, 0, -1);
    expect(find.text('11:30 PM'), findsOneWidget);

    await tester.tap(find.text('AM'));
    await tester.pump();
    expect(find.text('11:30 AM'), findsOneWidget);
    await tester.tap(find.text('PM'));
    await tester.pump();
    await tester.tap(find.text('AM'));
    await tester.pump();
    await _ok(tester);
    expect(results, <TimeOfDay?>[const TimeOfDay(hour: 11, minute: 30)]);
  });

  testWidgets('24 h: horas e minutos dão a volta sem mudar a outra coluna', (tester) async {
    final results = await _open(
      tester,
      initial: const TimeOfDay(hour: 23, minute: 59),
      use24HourFormat: true,
    );
    expect(find.text('AM'), findsNothing);
    await _step(tester, 0, 1);
    expect(find.text('00:59'), findsOneWidget);
    await _step(tester, 1, 1);
    expect(find.text('00:00'), findsOneWidget);
    await _step(tester, 1, -1);
    await _step(tester, 0, -1);
    expect(find.text('23:59'), findsOneWidget);
    await _ok(tester);
    expect(results, <TimeOfDay?>[const TimeOfDay(hour: 23, minute: 59)]);
  });

  testWidgets('sem use24HourFormat segue o MediaQuery de quem chama', (tester) async {
    final results = <TimeOfDay?>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
              child: Center(child: _opener(results: results)),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('14:30'), findsOneWidget);
    expect(find.text('PM'), findsNothing);
  });

  testWidgets('use24HourFormat false usa o formato do idioma', (tester) async {
    await _open(tester, use24HourFormat: false);
    expect(find.text('2:30 PM'), findsOneWidget);
  });

  testWidgets('helpText troca o título e o accent pinta o período', (tester) async {
    const accent = Color(0xFFFF4081);
    await _open(tester, helpText: 'Start time', accentColor: accent);
    expect(find.text('Start time'), findsOneWidget);
    expect(find.text('Select time'), findsNothing);
    expect(_periodDecoration(tester, 'PM').color, accent);
    expect(_periodDecoration(tester, 'AM').color, accent.withValues(alpha: 0));
    expect(tester.widget<LumenDialog>(find.byType(LumenDialog)).accent, accent);
  });

  testWidgets('sem accentColor usa o primary da paleta', (tester) async {
    await _open(tester);
    final palette = LumenThemeExt.of(tester.element(find.byType(LumenDialog))).palette;
    expect(_periodDecoration(tester, 'PM').color, palette.primary);
  });

  testWidgets('a paleta e o estilo vêm do LumenScope de quem chama', (tester) async {
    final palette = LumenPreset.values.last.palette(brightness: Brightness.light);
    final results = <TimeOfDay?>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LumenScope(
            palette: palette,
            style: LumenStyle.soft,
            child: Center(child: _opener(results: results)),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    final BuildContext dialog = tester.element(find.byType(LumenDialog));
    expect(LumenThemeExt.of(dialog).palette, palette);
    expect(LumenStyle.of(dialog), LumenStyle.soft);
  });

  testWidgets('teclado: setas mudam a coluna focada, Enter confirma', (tester) async {
    final results = await _open(tester, use24HourFormat: true);
    await _key(tester, LogicalKeyboardKey.arrowUp);
    expect(find.text('15:30'), findsOneWidget);
    await _key(tester, LogicalKeyboardKey.arrowDown);
    await _key(tester, LogicalKeyboardKey.arrowDown);
    expect(find.text('13:30'), findsOneWidget);
    await _key(tester, LogicalKeyboardKey.keyA);
    expect(find.text('13:30'), findsOneWidget);

    await _key(tester, LogicalKeyboardKey.arrowRight);
    await _key(tester, LogicalKeyboardKey.arrowUp);
    expect(find.text('13:31'), findsOneWidget);
    await _key(tester, LogicalKeyboardKey.arrowLeft);
    await _key(tester, LogicalKeyboardKey.arrowUp);
    expect(find.text('14:31'), findsOneWidget);

    await _key(tester, LogicalKeyboardKey.enter);
    expect(results, <TimeOfDay?>[const TimeOfDay(hour: 14, minute: 31)]);
  });

  testWidgets('Escape cancela', (tester) async {
    final results = await _open(tester);
    await _key(tester, LogicalKeyboardKey.escape);
    expect(results, <TimeOfDay?>[null]);
    expect(find.byType(LumenDialog), findsNothing);
  });

  testWidgets('leitor de tela ajusta hora e minuto como valores', (tester) async {
    final handle = tester.ensureSemantics();
    await _open(tester, use24HourFormat: true);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Hour')),
      isSemantics(
        label: 'Hour',
        value: '14',
        increasedValue: '15',
        decreasedValue: '13',
        isSlider: true,
        hasIncreaseAction: true,
        hasDecreaseAction: true,
      ),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('Minute')),
      isSemantics(value: '30', increasedValue: '31', decreasedValue: '29'),
    );

    void perform(String label, SemanticsAction action) {
      final node = tester.getSemantics(find.bySemanticsLabel(label));
      node.owner!.performAction(node.id, action);
    }

    perform('Hour', SemanticsAction.increase);
    await tester.pump();
    perform('Minute', SemanticsAction.decrease);
    await tester.pump();
    expect(find.text('15:29'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('AM e PM são anunciados com o estado selecionado', (tester) async {
    final handle = tester.ensureSemantics();
    await _open(tester);
    expect(
      tester.getSemantics(find.bySemanticsLabel('PM')),
      isSemantics(isSelected: true, isButton: true, hasTapAction: true),
    );
    expect(tester.getSemantics(find.bySemanticsLabel('AM')), isSemantics(isButton: true));
    handle.dispose();
  });

  testWidgets('entrada por texto valida e atualiza o horário', (tester) async {
    final results = await _open(tester, use24HourFormat: true);
    await tester.tap(find.byTooltip('Switch to text input mode'));
    await tester.pumpAndSettle();
    expect(find.text('Hour'), findsOneWidget);
    expect(find.text('Minute'), findsOneWidget);
    final fields = find.byType(TextField);
    expect(tester.widget<TextField>(fields.at(0)).controller!.text, '14');
    expect(tester.widget<TextField>(fields.at(1)).controller!.text, '30');

    await tester.enterText(fields.at(0), '25');
    await _ok(tester);
    expect(find.text('Enter a valid time'), findsOneWidget);
    expect(results, isEmpty);

    await tester.enterText(fields.at(0), '7');
    await tester.pump();
    expect(find.text('Enter a valid time'), findsNothing);
    expect(find.text('07:30'), findsOneWidget);

    await tester.enterText(fields.at(1), '75');
    await _ok(tester);
    expect(find.text('Enter a valid time'), findsOneWidget);
    await tester.enterText(fields.at(1), '');
    await _ok(tester);
    expect(find.text('Enter a valid time'), findsOneWidget);

    await tester.enterText(fields.at(1), '45');
    await tester.pump();
    expect(find.text('07:45'), findsOneWidget);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(results, <TimeOfDay?>[const TimeOfDay(hour: 7, minute: 45)]);
  });

  testWidgets('Enter na hora passa para o minuto', (tester) async {
    await _open(tester, use24HourFormat: true, entryMode: TimePickerEntryMode.input);
    expect(tester.widget<EditableText>(find.byType(EditableText).at(0)).focusNode.hasFocus, isTrue);
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pump();
    expect(tester.widget<EditableText>(find.byType(EditableText).at(1)).focusNode.hasFocus, isTrue);
  });

  testWidgets('12 h na entrada por texto: 1 a 12 e o período escolhido', (tester) async {
    final results = await _open(tester, entryMode: TimePickerEntryMode.input);
    final fields = find.byType(TextField);
    expect(tester.widget<TextField>(fields.at(0)).controller!.text, '2');
    expect(find.text('PM'), findsOneWidget);

    await tester.enterText(fields.at(0), '0');
    await _ok(tester);
    expect(find.text('Enter a valid time'), findsOneWidget);
    await tester.enterText(fields.at(0), '13');
    await _ok(tester);
    expect(find.text('Enter a valid time'), findsOneWidget);

    await tester.enterText(fields.at(0), '12');
    await tester.pump();
    expect(find.text('12:30 PM'), findsOneWidget);
    await tester.tap(find.text('AM'));
    await tester.pump();
    expect(find.text('12:30 AM'), findsOneWidget);
    await _ok(tester);
    expect(results, <TimeOfDay?>[const TimeOfDay(hour: 0, minute: 30)]);
  });

  testWidgets('voltar às colunas mantém o horário digitado', (tester) async {
    await _open(tester, use24HourFormat: true, entryMode: TimePickerEntryMode.input);
    await tester.enterText(find.byType(TextField).at(0), '');
    await _ok(tester);
    expect(find.text('Enter a valid time'), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(0), '9');
    await tester.tap(find.byTooltip('Switch to dial picker mode'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNothing);
    expect(find.text('Enter a valid time'), findsNothing);
    expect(find.text('09'), findsOneWidget);
    expect(find.text('09:30'), findsOneWidget);

    // The hour column takes focus back, so the arrows work again.
    await _key(tester, LogicalKeyboardKey.arrowUp);
    expect(find.text('10:30'), findsOneWidget);
  });

  testWidgets('dialOnly e inputOnly escondem o botão de troca', (tester) async {
    await _open(tester, entryMode: TimePickerEntryMode.dialOnly);
    expect(find.byType(TextField), findsNothing);
    expect(find.byTooltip('Switch to text input mode'), findsNothing);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    await _open(tester, entryMode: TimePickerEntryMode.inputOnly);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.byTooltip('Switch to dial picker mode'), findsNothing);
  });

  testWidgets('a grade de foco ganha contorno só com teclado', (tester) async {
    await _open(tester, use24HourFormat: true);
    final primary = LumenThemeExt.of(tester.element(find.byType(LumenDialog))).palette.primary;
    Color frameColor() {
      final frame = tester.widget<Container>(
        find
            .byWidgetPredicate(
              (widget) => widget is Container && widget.padding == const EdgeInsets.all(2),
            )
            .first,
      );
      return ((frame.decoration! as BoxDecoration).border! as Border).top.color;
    }

    expect(frameColor(), primary.withValues(alpha: 0));
    await _key(tester, LogicalKeyboardKey.arrowUp);
    expect(frameColor(), primary);
  });

  testWidgets('reduce motion não deixa animação rodando', (tester) async {
    await _open(tester, reduceMotion: true);
    expect(tester.hasRunningAnimations, isFalse);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    expect(tester.hasRunningAnimations, isFalse);
    expect(
      tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer)).map((w) => w.duration),
      everyElement(Duration.zero),
    );
  });

  testWidgets('em tela baixa o conteúdo rola e o OK continua ao alcance', (tester) async {
    tester.view.physicalSize = const Size(400, 300);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final results = await _open(tester);
    expect(tester.takeException(), isNull);

    final scroll = tester.state<ScrollableState>(
      find.descendant(of: find.byType(LumenDialog), matching: find.byType(Scrollable)),
    );
    expect(scroll.position.maxScrollExtent, greaterThan(0));
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(scroll.position.pixels, greaterThan(0));
    await _ok(tester);
    expect(results, <TimeOfDay?>[const TimeOfDay(hour: 14, minute: 30)]);
  });

  for (final brightness in Brightness.values) {
    for (final entry in LumenStyle.presets.entries) {
      testWidgets('renderiza em ${brightness.name} ${entry.key}', (tester) async {
        final palette = LumenPreset.neon.palette(brightness: brightness);
        final results = <TimeOfDay?>[];
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(brightness: brightness),
            home: LumenScope(
              palette: palette,
              style: entry.value,
              child: Scaffold(
                body: Center(child: _opener(results: results)),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final BuildContext dialog = tester.element(find.byType(LumenDialog));
        expect(LumenStyle.of(dialog), entry.value);
        expect(_periodDecoration(tester, 'PM').color, palette.primary);
        expect(tester.widget<Text>(find.text('30')).style?.color, palette.textPrimary);

        await tester.tap(find.byTooltip('Switch to text input mode'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }
}
