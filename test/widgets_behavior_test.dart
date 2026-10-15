// Refactor regressions: behavior, accessibility, and motion.
import 'dart:async';

import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/lumen_kit.dart';
import 'package:material_ui/material_ui.dart';

Widget _app(Widget child, {bool reduceMotion = false}) => MaterialApp(
  theme: AppTheme.fromPreset(LumenPreset.neon),
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reduceMotion),
    child: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  testWidgets('LumenTabs acompanha selectedIndex vindo de fora', (
    WidgetTester tester,
  ) async {
    const items = <LumenTabItem>[
      LumenTabItem(label: 'A'),
      LumenTabItem(label: 'B'),
      LumenTabItem(label: 'C'),
    ];
    Widget tabs(int i) =>
        _app(LumenTabs(items: items, selectedIndex: i, onChanged: (_) {}));

    await tester.pumpWidget(tabs(0));
    await tester.pumpWidget(tabs(2));
    await tester.pumpAndSettle();

    final TabBar bar = tester.widget<TabBar>(find.byType(TabBar));
    expect(bar.controller!.index, 2);
  });

  testWidgets('showLumenToast completa só quando o toast sai da tela', (
    WidgetTester tester,
  ) async {
    late BuildContext ctx;
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (BuildContext c) {
            ctx = c;
            return const SizedBox();
          },
        ),
      ),
    );

    var done = false;
    unawaited(
      showLumenToast(
        context: ctx,
        message: 'salvo',
        duration: const Duration(seconds: 1),
      ).then((_) => done = true),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300)); // entrada
    expect(find.text('salvo'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 750)); // timer dispara
    expect(done, isFalse, reason: 'ainda animando a saída');

    await tester.pumpAndSettle();
    expect(done, isTrue);
    expect(find.text('salvo'), findsNothing);
  });

  testWidgets('ação do LumenSnackBar executa e fecha o snackbar', (
    WidgetTester tester,
  ) async {
    late BuildContext ctx;
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (BuildContext c) {
            ctx = c;
            return const SizedBox();
          },
        ),
      ),
    );

    var undo = 0;
    showLumenSnackBar(
      context: ctx,
      message: 'apagado',
      action: SnackBarAction(label: 'Desfazer', onPressed: () => undo++),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Desfazer'));
    await tester.pumpAndSettle();

    expect(undo, 1);
    expect(find.text('apagado'), findsNothing);
  });

  testWidgets('controles anunciam estado para leitores de tela', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _app(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            LumenCheckbox(value: true, label: 'Aceito', onChanged: (_) {}),
            LumenSwitch(value: false, label: 'Wi-Fi', onChanged: (_) {}),
            LumenRadio<int>(
              value: 1,
              groupValue: 1,
              label: 'Um',
              onChanged: (_) {},
            ),
            LumenIconButton(
              icon: Icons.delete,
              semanticLabel: 'Apagar',
              onPressed: () {},
            ),
          ],
        ),
      ),
    );

    expect(
      tester.getSemantics(find.byType(LumenCheckbox)),
      isSemantics(
        label: 'Aceito',
        hasCheckedState: true,
        isChecked: true,
        isEnabled: true,
        hasTapAction: true,
      ),
    );
    expect(
      tester.getSemantics(find.byType(LumenSwitch)),
      isSemantics(
        label: 'Wi-Fi',
        hasToggledState: true,
        isEnabled: true,
        hasTapAction: true,
      ),
    );
    expect(
      tester.getSemantics(find.byType(LumenRadio<int>)),
      isSemantics(
        label: 'Um',
        hasCheckedState: true,
        isChecked: true,
        isEnabled: true,
        hasTapAction: true,
      ),
    );
    expect(find.bySemanticsLabel('Apagar'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('LumenSwitch alterna pelo teclado (antes era GestureDetector)', (
    WidgetTester tester,
  ) async {
    var value = false;
    await tester.pumpWidget(
      _app(
        StatefulBuilder(
          builder: (BuildContext c, StateSetter set) => LumenSwitch(
            value: value,
            onChanged: (bool v) => set(() => value = v),
          ),
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(value, isTrue);
  });

  testWidgets('label de checkbox/switch funciona dentro de Row', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            LumenCheckbox(value: false, label: 'Lembrar', onChanged: (_) {}),
            LumenSwitch(value: true, label: 'Ativo', onChanged: (_) {}),
          ],
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('LumenTextField aceita controller e valida dentro de Form', (
    WidgetTester tester,
  ) async {
    final form = GlobalKey<FormState>();
    final controller = TextEditingController(text: 'x');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _app(
        Form(
          key: form,
          child: LumenTextField(
            label: 'Bio',
            controller: controller,
            maxLines: 4,
            validator: (String? v) =>
                (v ?? '').length < 3 ? 'Muito curto' : null,
          ),
        ),
      ),
    );

    expect(form.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Muito curto'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'abc');
    expect(controller.text, 'abc');
    expect(form.currentState!.validate(), isTrue);
  });

  testWidgets('LumenDatePicker abre mesmo com "hoje" fora do intervalo', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(
        LumenDatePicker(
          value: null,
          label: 'Nascimento',
          firstDate: DateTime(1990),
          lastDate: DateTime(2000, 12, 31),
          onChanged: (_) {},
        ),
      ),
    );
    await tester.tap(find.byType(LumenDatePicker));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(DatePickerDialog), findsOneWidget);
  });

  testWidgets('LumenNavRail mostra o badge do item', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(
        SizedBox(
          height: 400,
          child: LumenNavRail(
            items: const <LumenNavItem>[
              LumenNavItem(icon: Icons.home, label: 'Início'),
              LumenNavItem(icon: Icons.mail, label: 'Inbox', badge: '3'),
            ],
            selectedIndex: 0,
            onChanged: (_) {},
          ),
        ),
      ),
    );
    expect(find.widgetWithText(LumenBadge, '3'), findsOneWidget);
  });

  testWidgets('LumenExpansionTile fechado esconde o conteúdo do leitor', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _app(
        const LumenExpansionTile(
          title: 'Detalhes',
          children: <Widget>[Text('segredo')],
        ),
      ),
    );
    expect(find.bySemanticsLabel('segredo'), findsNothing);

    await tester.tap(find.text('Detalhes'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('segredo'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('animações infinitas param com "reduzir animações"', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            LumenSkeleton(width: 100),
            SizedBox(width: 100, child: LumenLinearProgress()),
            LumenCircularProgress(),
          ],
        ),
        reduceMotion: true,
      ),
    );
    // With repeat() active, pumpAndSettle times out.
    await tester.pumpAndSettle();
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('progresso determinado anuncia a porcentagem', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _app(
        const SizedBox(
          width: 100,
          child: LumenLinearProgress(value: 0.42, semanticsLabel: 'Upload'),
        ),
      ),
    );
    expect(
      tester.getSemantics(find.byType(LumenLinearProgress)),
      matchesSemantics(label: 'Upload', value: '42%'),
    );
    handle.dispose();
  });
}
