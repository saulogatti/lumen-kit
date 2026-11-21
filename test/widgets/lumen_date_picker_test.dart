import 'dart:async';

import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

Widget _picker({required ValueChanged<DateTime>? onChanged, String Function(DateTime)? format}) =>
    SizedBox(
      width: 320,
      child: LumenDatePicker(
        value: DateTime(2026, 3, 5),
        firstDate: DateTime(2026),
        lastDate: DateTime(2026, 12, 31),
        label: 'Data',
        format: format,
        onChanged: onChanged,
      ),
    );

/// Button that opens [showLumenDatePicker] and records each result.
Widget _opener({
  required List<DateTime?> results,
  DateTime? initial,
  DateTime? first,
  DateTime? last,
  Color? accentColor,
  String? helpText,
}) => Builder(
  builder: (context) => LumenButton(
    label: 'Open',
    onPressed: () => unawaited(
      showLumenDatePicker(
        context: context,
        initialDate: initial ?? DateTime(2026, 3, 5),
        firstDate: first ?? DateTime(2026),
        lastDate: last ?? DateTime(2026, 12, 31),
        accentColor: accentColor,
        helpText: helpText,
      ).then(results.add),
    ),
  ),
);

Future<List<DateTime?>> _open(
  WidgetTester tester, {
  DateTime? initial,
  DateTime? first,
  DateTime? last,
  Color? accentColor,
  String? helpText,
  bool reduceMotion = false,
}) async {
  final results = <DateTime?>[];
  await pumpBare(
    tester,
    _opener(
      results: results,
      initial: initial,
      first: first,
      last: last,
      accentColor: accentColor,
      helpText: helpText,
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

/// Decoration of the day cell that shows [day].
BoxDecoration _dayDecoration(WidgetTester tester, String day) =>
    tester
            .widget<AnimatedContainer>(
              find.ancestor(of: find.text(day), matching: find.byType(AnimatedContainer)),
            )
            .decoration!
        as BoxDecoration;

Color? _dayTextColor(WidgetTester tester, String day) =>
    tester.widget<Text>(find.text(day)).style?.color;

LumenIconButton _iconButton(WidgetTester tester, IconData icon) =>
    tester.widget<LumenIconButton>(find.widgetWithIcon(LumenIconButton, icon));

void main() {
  testWidgets('LumenDatePicker mostra dd/MM/yyyy e devolve o dia escolhido', (tester) async {
    final picked = <DateTime>[];
    await pumpBare(tester, _picker(onChanged: picked.add));
    expect(find.text('05/03/2026'), findsOneWidget);

    await tester.tap(find.byType(LumenDatePicker));
    await tester.pumpAndSettle();
    expect(find.text('Select date'), findsOneWidget);
    expect(find.text('Thursday, March 5, 2026'), findsOneWidget);
    await tester.tap(find.text('20'));
    await tester.pump();
    expect(find.text('Friday, March 20, 2026'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(picked, <DateTime>[DateTime(2026, 3, 20)]);
  });

  testWidgets('cancelar o LumenDatePicker não chama onChanged', (tester) async {
    final picked = <DateTime>[];
    await pumpBare(tester, _picker(onChanged: picked.add));

    await tester.tap(find.byType(LumenDatePicker));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Select date'), findsNothing);
    expect(picked, isEmpty);
  });

  testWidgets('LumenDatePicker com value antes de firstDate abre no firstDate', (tester) async {
    await pumpBare(
      tester,
      SizedBox(
        width: 320,
        child: LumenDatePicker(
          value: DateTime(1980, 6),
          firstDate: DateTime(1990, 2),
          lastDate: DateTime(2000),
          onChanged: (_) {},
        ),
      ),
    );
    await tester.tap(find.byType(LumenDatePicker));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Thursday, February 1, 1990'), findsOneWidget);
    expect(find.text('February 1990'), findsOneWidget);
  });

  testWidgets('showLumenDatePicker leva initialDate depois de lastDate para lastDate', (
    tester,
  ) async {
    final results = await _open(tester, initial: DateTime(2030, 1, 1, 15, 30));
    expect(find.text('Thursday, December 31, 2026'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(results, <DateTime?>[DateTime(2026, 12, 31)]);
  });

  testWidgets('LumenDatePicker usa o format e não abre desabilitado', (tester) async {
    await pumpBare(tester, _picker(onChanged: null, format: (d) => 'ano ${d.year}'));
    expect(find.text('ano 2026'), findsOneWidget);

    await tester.tap(find.byType(LumenDatePicker));
    await tester.pumpAndSettle();
    expect(find.text('Select date'), findsNothing);
  });

  testWidgets('helpText troca o título e o accent pinta o dia escolhido', (tester) async {
    const accent = Color(0xFFFF4081);
    await _open(tester, helpText: 'Start date', accentColor: accent);
    expect(find.text('Start date'), findsOneWidget);
    expect(find.text('Select date'), findsNothing);
    expect(_dayDecoration(tester, '5').color, accent);
    expect(tester.widget<LumenDialog>(find.byType(LumenDialog)).accent, accent);
  });

  testWidgets('sem accentColor o dia escolhido usa o primary', (tester) async {
    await _open(tester);
    final BuildContext dialog = tester.element(find.byType(LumenDialog));
    final palette = LumenThemeExt.of(dialog).palette;
    expect(_dayDecoration(tester, '5').color, palette.primary);
    expect(_dayTextColor(tester, '6'), palette.textPrimary);
  });

  for (final dark in <bool>[true, false]) {
    testWidgets('o texto do dia escolhido contrasta com accent ${dark ? 'escuro' : 'claro'}', (
      tester,
    ) async {
      await _open(tester, accentColor: dark ? const Color(0xFF202020) : const Color(0xFFFFEB3B));
      final palette = LumenThemeExt.of(tester.element(find.byType(LumenDialog))).palette;
      final tones = <Color>[palette.backgroundDeep, palette.textPrimary]
        ..sort((a, b) => a.computeLuminance().compareTo(b.computeLuminance()));
      expect(_dayTextColor(tester, '5'), dark ? tones.last : tones.first);
    });
  }

  testWidgets('a paleta e o estilo vêm do LumenScope de quem chama', (tester) async {
    final palette = LumenPreset.values.last.palette(brightness: Brightness.light);
    final results = <DateTime?>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LumenScope(
            palette: palette,
            style: LumenStyle.brutal,
            child: Center(child: _opener(results: results)),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    final BuildContext dialog = tester.element(find.byType(LumenDialog));
    expect(LumenThemeExt.of(dialog).palette, palette);
    expect(LumenStyle.of(dialog), LumenStyle.brutal);
  });

  testWidgets('botões de mês navegam e param nos limites', (tester) async {
    await _open(tester, first: DateTime(2026, 1, 15), last: DateTime(2026, 3, 10));
    expect(find.text('March 2026'), findsOneWidget);
    expect(_iconButton(tester, Icons.chevron_right_rounded).onPressed, isNull);

    await tester.tap(find.byTooltip('Previous month'));
    await tester.pumpAndSettle();
    expect(find.text('February 2026'), findsOneWidget);
    expect(_iconButton(tester, Icons.chevron_right_rounded).onPressed, isNotNull);

    await tester.tap(find.byTooltip('Previous month'));
    await tester.pumpAndSettle();
    expect(find.text('January 2026'), findsOneWidget);
    expect(_iconButton(tester, Icons.chevron_left_rounded).onPressed, isNull);

    await tester.tap(find.byTooltip('Next month'));
    await tester.pumpAndSettle();
    expect(find.text('February 2026'), findsOneWidget);
    // Browsing months does not change the selection.
    expect(find.text('Thursday, March 5, 2026'), findsOneWidget);
  });

  testWidgets('dias fora do intervalo ficam desabilitados', (tester) async {
    await _open(tester, first: DateTime(2026, 3, 10));
    expect(find.text('Tuesday, March 10, 2026'), findsOneWidget);
    await tester.tap(find.text('5'));
    await tester.pump();
    expect(find.text('Tuesday, March 10, 2026'), findsOneWidget);
    await tester.tap(find.text('12'));
    await tester.pump();
    expect(find.text('Thursday, March 12, 2026'), findsOneWidget);
  });

  testWidgets('leitor de tela lê a data completa, hoje e o selecionado', (tester) async {
    final handle = tester.ensureSemantics();
    final today = DateUtils.dateOnly(DateTime.now());
    final other = DateTime(today.year, today.month, today.day == 1 ? 2 : 1);
    await _open(
      tester,
      initial: today,
      first: DateTime(today.year - 1),
      last: DateTime(today.year + 1, 12, 31),
    );
    final l = MaterialLocalizations.of(tester.element(find.byType(LumenDialog)));
    expect(
      tester.getSemantics(find.bySemanticsLabel('${l.formatFullDate(today)}, Today')),
      isSemantics(isSelected: true, isButton: true, hasTapAction: true, isEnabled: true),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel(RegExp('^${l.formatFullDate(other)}\$'))),
      isSemantics(isButton: true, hasTapAction: true, isEnabled: true),
    );
    expect(find.bySemanticsLabel(RegExp('Select year')), findsOneWidget);
    handle.dispose();
  });

  testWidgets('setas, Page Up e Page Down movem a seleção', (tester) async {
    await _open(tester, last: DateTime(2027, 12, 31));
    await _key(tester, LogicalKeyboardKey.arrowRight);
    expect(find.text('Friday, March 6, 2026'), findsOneWidget);
    await _key(tester, LogicalKeyboardKey.arrowDown);
    expect(find.text('Friday, March 13, 2026'), findsOneWidget);
    await _key(tester, LogicalKeyboardKey.arrowLeft);
    expect(find.text('Thursday, March 12, 2026'), findsOneWidget);
    await _key(tester, LogicalKeyboardKey.arrowUp);
    expect(find.text('Thursday, March 5, 2026'), findsOneWidget);
    await _key(tester, LogicalKeyboardKey.pageDown);
    expect(find.text('Sunday, April 5, 2026'), findsOneWidget);
    expect(find.text('April 2026'), findsOneWidget);
    await _key(tester, LogicalKeyboardKey.pageUp);
    expect(find.text('Thursday, March 5, 2026'), findsOneWidget);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pumpAndSettle();
    expect(find.text('Friday, March 5, 2027'), findsOneWidget);

    // Past lastDate the selection stops at the end of the range.
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pumpAndSettle();
    expect(find.text('Friday, December 31, 2027'), findsOneWidget);

    // Other keys are left to the dialog.
    await _key(tester, LogicalKeyboardKey.keyA);
    expect(find.text('Friday, December 31, 2027'), findsOneWidget);
  });

  testWidgets('Page Down no dia 31 vai para o último dia do mês seguinte', (tester) async {
    await _open(tester, initial: DateTime(2026, 1, 31));
    await _key(tester, LogicalKeyboardKey.pageDown);
    expect(find.text('Saturday, February 28, 2026'), findsOneWidget);
  });

  testWidgets('em RTL as setas laterais invertem', (tester) async {
    final results = <DateTime?>[];
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, navigator) =>
            Directionality(textDirection: TextDirection.rtl, child: navigator!),
        home: Scaffold(
          body: Center(child: _opener(results: results)),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await _key(tester, LogicalKeyboardKey.arrowLeft);
    expect(find.text('Friday, March 6, 2026'), findsOneWidget);
    await _key(tester, LogicalKeyboardKey.arrowRight);
    expect(find.text('Thursday, March 5, 2026'), findsOneWidget);

    await tester.tap(find.text('March 2026'));
    await tester.pumpAndSettle();
    await _key(tester, LogicalKeyboardKey.arrowLeft);
    await _key(tester, LogicalKeyboardKey.enter);
    expect(find.text('Thursday, March 5, 2026'), findsOneWidget);
  });

  testWidgets('Enter confirma e Escape cancela', (tester) async {
    final results = await _open(tester);
    await _key(tester, LogicalKeyboardKey.arrowRight);
    await _key(tester, LogicalKeyboardKey.enter);
    expect(results, <DateTime?>[DateTime(2026, 3, 6)]);

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await _key(tester, LogicalKeyboardKey.escape);
    expect(results, <DateTime?>[DateTime(2026, 3, 6), null]);
    expect(find.byType(LumenDialog), findsNothing);
  });

  testWidgets('a grade ganha contorno só com foco de teclado', (tester) async {
    await _open(tester);
    Border? frame() {
      final decorated = tester.widget<Container>(
        find.byWidgetPredicate(
          (widget) => widget is Container && widget.padding == const EdgeInsets.all(2),
        ),
      );
      return (decorated.decoration! as BoxDecoration).border as Border?;
    }

    final BuildContext dialog = tester.element(find.byType(LumenDialog));
    final primary = LumenThemeExt.of(dialog).palette.primary;
    expect(frame()!.top.color, primary.withValues(alpha: 0));
    await _key(tester, LogicalKeyboardKey.arrowRight);
    expect(frame()!.top.color, primary);
  });

  testWidgets('o título do mês abre a lista de anos e um toque escolhe o ano', (tester) async {
    await _open(tester, first: DateTime(2000), last: DateTime(2050, 12, 31));
    await tester.tap(find.text('March 2026'));
    await tester.pumpAndSettle();
    expect(find.text('2026'), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);

    await tester.tap(find.text('2030'));
    await tester.pumpAndSettle();
    expect(find.byType(GridView), findsNothing);
    expect(find.text('Tuesday, March 5, 2030'), findsOneWidget);
    expect(find.text('March 2030'), findsOneWidget);
  });

  testWidgets('setas andam pelos anos, rolam a lista e Enter volta à grade', (tester) async {
    await _open(tester, first: DateTime(2000), last: DateTime(2050, 6, 30));
    await tester.tap(find.text('March 2026'));
    await tester.pumpAndSettle();

    await _key(tester, LogicalKeyboardKey.arrowRight);
    expect(find.text('Friday, March 5, 2027'), findsOneWidget);
    await _key(tester, LogicalKeyboardKey.arrowDown);
    expect(find.text('Wednesday, March 5, 2031'), findsOneWidget);
    await _key(tester, LogicalKeyboardKey.arrowUp);
    await _key(tester, LogicalKeyboardKey.arrowLeft);
    expect(find.text('Thursday, March 5, 2026'), findsOneWidget);
    await _key(tester, LogicalKeyboardKey.keyA);
    expect(find.text('Thursday, March 5, 2026'), findsOneWidget);

    final scroll = tester.state<ScrollableState>(
      find.descendant(of: find.byType(GridView), matching: find.byType(Scrollable)),
    );
    final before = scroll.position.pixels;
    for (var i = 0; i < 8; i++) {
      await _key(tester, LogicalKeyboardKey.arrowDown);
    }
    expect(find.text('Saturday, March 5, 2050'), findsOneWidget);
    expect(scroll.position.pixels, greaterThan(before));
    expect(find.text('2050'), findsOneWidget);
    expect(
      tester.getRect(find.text('2050')).bottom,
      lessThanOrEqualTo(tester.getRect(find.byType(GridView)).bottom),
    );

    for (var i = 0; i < 12; i++) {
      await _key(tester, LogicalKeyboardKey.arrowUp);
    }
    expect(find.text('Tuesday, March 5, 2002'), findsOneWidget);
    expect(
      tester.getRect(find.text('2002')).top,
      greaterThanOrEqualTo(tester.getRect(find.byType(GridView)).top),
    );

    await _key(tester, LogicalKeyboardKey.enter);
    expect(find.byType(GridView), findsNothing);
    expect(find.text('March 2002'), findsOneWidget);
    await _key(tester, LogicalKeyboardKey.arrowRight);
    expect(find.text('Wednesday, March 6, 2002'), findsOneWidget);
  });

  testWidgets('trocar de ano ajusta 29 de fevereiro e respeita o intervalo', (tester) async {
    await _open(
      tester,
      initial: DateTime(2024, 2, 29),
      first: DateTime(2024),
      last: DateTime(2025, 1, 31),
    );
    await tester.tap(find.text('February 2024'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2025'));
    await tester.pumpAndSettle();
    expect(find.text('Friday, January 31, 2025'), findsOneWidget);
  });

  testWidgets('entrada por texto valida o formato e o intervalo', (tester) async {
    final results = await _open(tester);
    await tester.tap(find.byTooltip('Switch to input'));
    await tester.pumpAndSettle();
    expect(find.byType(GridView), findsNothing);
    expect(find.text('Enter Date'), findsOneWidget);
    expect(find.text('03/05/2026'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '13/45/2026');
    await tester.tap(find.text('OK'));
    await tester.pump();
    expect(find.text('Invalid format.'), findsOneWidget);
    expect(results, isEmpty);

    await tester.enterText(find.byType(TextField), '03/05/2030');
    await tester.pump();
    expect(find.text('Invalid format.'), findsNothing);
    await tester.tap(find.text('OK'));
    await tester.pump();
    expect(find.text('Out of range.'), findsOneWidget);
    expect(find.text('Thursday, March 5, 2026'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '07/04/2026');
    await tester.pump();
    expect(find.text('Saturday, July 4, 2026'), findsOneWidget);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(results, <DateTime?>[DateTime(2026, 7, 4)]);
  });

  testWidgets('voltar ao calendário mostra o mês do texto digitado', (tester) async {
    await _open(tester);
    await tester.tap(find.byTooltip('Switch to input'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '07/04/2026');
    await tester.tap(find.byTooltip('Switch to calendar'));
    await tester.pumpAndSettle();
    expect(find.text('July 2026'), findsOneWidget);
    // The grid takes focus back, so the arrows work again.
    await _key(tester, LogicalKeyboardKey.arrowRight);
    expect(find.text('Sunday, July 5, 2026'), findsOneWidget);
    expect(_dayDecoration(tester, '4').color, isNot(const Color(0x00000000)));
  });

  testWidgets('reduce motion troca o mês e o dia sem transição', (tester) async {
    await _open(tester, reduceMotion: true);
    expect(tester.hasRunningAnimations, isFalse);
    // Keyboard changes leave no ripple, so only the picker's own motion counts.
    await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
    await tester.pump();
    expect(tester.hasRunningAnimations, isFalse);
    expect(find.text('April 2026'), findsOneWidget);
    expect(find.text('March 2026'), findsNothing);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(tester.hasRunningAnimations, isFalse);
    expect(
      tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer)).map((w) => w.duration),
      everyElement(Duration.zero),
    );
  });

  testWidgets('em tela baixa o conteúdo rola e o OK continua ao alcance', (tester) async {
    tester.view.physicalSize = const Size(400, 420);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final results = await _open(tester);
    expect(tester.takeException(), isNull);

    final scroll = tester.state<ScrollableState>(
      find.descendant(of: find.byType(LumenDialog), matching: find.byType(Scrollable)),
    );
    expect(scroll.position.maxScrollExtent, greaterThan(0));
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(scroll.position.pixels, greaterThan(0));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(results, <DateTime?>[DateTime(2026, 3, 5)]);
  });

  for (final brightness in Brightness.values) {
    for (final entry in LumenStyle.presets.entries) {
      testWidgets('renderiza em ${brightness.name} ${entry.key}', (tester) async {
        final palette = LumenPreset.neon.palette(brightness: brightness);
        final results = <DateTime?>[];
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
        expect(_dayDecoration(tester, '5').color, palette.primary);
        expect(_dayTextColor(tester, '6'), palette.textPrimary);

        await tester.tap(find.text('March 2026'));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Switch to input'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }
}
