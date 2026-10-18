import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

void main() {
  testWidgets('LumenLoadingOverlay bloqueia toques só enquanto carrega', (tester) async {
    var taps = 0;
    Widget build(bool loading) => bareApp(
      LumenLoadingOverlay(
        loading: loading,
        message: 'Salvando…',
        child: SizedBox(
          width: 300,
          height: 300,
          child: Center(
            child: LumenButton(label: 'Salvar', onPressed: () => taps++),
          ),
        ),
      ),
    );

    await tester.pumpWidget(build(true));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Salvando…'), findsOneWidget);
    await tester.tap(find.text('Salvar'), warnIfMissed: false);
    expect(taps, 0);

    await tester.pumpWidget(build(false));
    await tester.pumpAndSettle();
    expect(find.text('Salvando…'), findsNothing);
    await tester.tap(find.text('Salvar'));
    expect(taps, 1);
  });

  testWidgets('showLumenLoading cobre a tela e devolve o resultado', (tester) async {
    late BuildContext ctx;
    await pumpBare(
      tester,
      Builder(
        builder: (c) {
          ctx = c;
          return const Text('tela');
        },
      ),
    );

    final job = Completer<int>();
    int? result;
    unawaited(
      showLumenLoading<int>(
        context: ctx,
        message: 'Enviando…',
        task: () => job.future,
      ).then((v) => result = v),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Enviando…'), findsOneWidget);

    // Voltar não fecha a camada.
    await tester.binding.handlePopRoute();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Enviando…'), findsOneWidget);

    job.complete(42);
    await tester.pumpAndSettle();
    expect(result, 42);
    expect(find.text('Enviando…'), findsNothing);
    expect(find.text('tela'), findsOneWidget);
  });

  testWidgets('showLumenLoading fecha a camada e repassa o erro', (tester) async {
    late BuildContext ctx;
    await pumpBare(
      tester,
      Builder(
        builder: (c) {
          ctx = c;
          return const SizedBox();
        },
      ),
    );

    Object? error;
    unawaited(
      showLumenLoading<void>(
        context: ctx,
        message: 'Enviando…',
        task: () async => throw StateError('falhou'),
      ).catchError((Object e) => error = e),
    );
    await tester.pumpAndSettle();

    expect(error, isA<StateError>());
    expect(find.text('Enviando…'), findsNothing);
  });
}
